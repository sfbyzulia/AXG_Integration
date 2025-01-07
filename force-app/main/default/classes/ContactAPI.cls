@RestResource(urlMapping='/api/contacts/*')
global class ContactAPI {

    @HttpPost
    global static String createOrFindContact(String firstName, String lastName, String email) {
        RestResponse res = RestContext.response;

        // Validate input parameters
        if (String.isBlank(email)) {
            res.statusCode = 400; // Bad Request
            res.responseBody = Blob.valueOf('{"errorCode": "MISSING_REQUIRED_FIELD", "message": "Email is a required field."}');
            return null; // End processing
        }
    
        // Search contact by email
        List<Contact> existingContacts = [SELECT Id FROM Contact WHERE Email = :email LIMIT 1];
    
        if (!existingContacts.isEmpty()) {
            // If contact exists, return its Id
            return existingContacts[0].Id;
        } else {
            // If contact doesn't exist, create a new contact
            Contact newContact = new Contact(
                FirstName = firstName,
                LastName = lastName,
                Email = email
            );
            insert newContact;
    
            // Return the new contact's Id
            return newContact.Id;
        }
    }
    
 
        @HttpPatch
        global static void updateContact() {
            RestResponse res = RestContext.response;
    
                // Obtenir l'ID du contact à partir de l'URL
                String contactId = RestContext.request.requestURI.substring(
                    RestContext.request.requestURI.lastIndexOf('/') + 1
                );
    
                // Valider que l'ID du contact est présent
                if (String.isBlank(contactId)) {
                    res.statusCode = 400; // Bad Request
                    res.responseBody = Blob.valueOf('{"errorCode": "MISSING_REQUIRED_FIELD", "message": "Contact ID is required."}');
                    return; // Fin de traitement
                }
    
                // Query pour vérifier si le contact existe
                List<Contact> contacts = [SELECT Id FROM Contact WHERE Id = :contactId LIMIT 1];
                if (contacts.isEmpty()) {
                    res.statusCode = 404; // Not Found
                    res.responseBody = Blob.valueOf('{"errorCode": "NOT_FOUND", "message": "Contact not found."}');
                    return; // Fin de traitement
                }
    
                // Récupérer le corps de la requête (JSON)
                String requestBody = RestContext.request.requestBody.toString();
    
                // Convertir le JSON en objet générique pour obtenir les champs à mettre à jour
                Map<String, Object> fieldsToUpdate = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
    
                if (fieldsToUpdate.isEmpty()) {
                    res.statusCode = 400; // Bad Request
                    res.responseBody = Blob.valueOf('{"errorCode": "MISSING_REQUIRED_FIELD", "message": "At least one field is required to update."}');
                    return; // Fin de traitement
                }
    
                // Construire un objet Contact avec les champs à mettre à jour
                Contact contactToUpdate = new Contact(Id = contactId);
                for (String fieldName : fieldsToUpdate.keySet()) {
                    if (Schema.sObjectType.Contact.fields.getMap().containsKey(fieldName)) {
                        contactToUpdate.put(fieldName, fieldsToUpdate.get(fieldName));
                    } else {
                        // Gérer les champs non valides
                        res.statusCode = 400; // Bad Request
                        res.responseBody = Blob.valueOf('{"errorCode": "INVALID_FIELD", "message": "Invalid field: ' + fieldName + '"}');
                        return; // Fin de traitement
                    }
                }
    
                // Mettre à jour le contact
                update contactToUpdate;
    
                // Réponse de succès
                res.statusCode = 200; // OK
                res.responseBody = Blob.valueOf('{"message": "Contact updated successfully."}');
             }
        
        @HttpDelete
        global static void deleteContact() {
            RestResponse res = RestContext.response;

                // Obtenir l'ID du contact à supprimer à partir de l'URL
                String contactId = RestContext.request.requestURI.substring(
                    RestContext.request.requestURI.lastIndexOf('/') + 1
                );
    
                // Vérifier si le contact existe
                Contact contactToDelete = [SELECT Id FROM Contact WHERE Id = :contactId LIMIT 1];
    
                // Bloquer la suppression avec une réponse d'erreur personnalisée
                res.responseBody = Blob.valueOf('Contacts cannot be deleted. Please deactivate instead.');
                res.statusCode = 400;
        }
    }    
