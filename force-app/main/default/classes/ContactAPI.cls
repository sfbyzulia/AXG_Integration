@RestResource(urlMapping='/api/contacts/*') 
global with sharing class ContactAPI {
    
    @HttpPost
    global static void createOrFindContacts() {
        RestResponse res = RestContext.response;

        // Récupérer et désérialiser le corps de la requête
        String requestBody = RestContext.request.requestBody.toString();
        Object deserializedBody = JSON.deserializeUntyped(requestBody);

        // Validation du type de l'entrée
        if (!(deserializedBody instanceof List<Object>)) {
            res.statusCode = 400; // Mauvaise requête
            res.responseBody = Blob.valueOf('{"errorCode": "INVALID_REQUEST", "message": "The request body must be a list of contact objects."}');
            return;
        }

        List<Object> inputList = (List<Object>) deserializedBody;
        List<Map<String, Object>> contactsData = new List<Map<String, Object>>();

        // Vérification que chaque élément est un map
        for (Object item : inputList) {
            if (item instanceof Map<String, Object>) {
                contactsData.add((Map<String, Object>) item);
            } else {
                res.statusCode = 400; // Mauvaise requête
                res.responseBody = Blob.valueOf('{"errorCode": "INVALID_REQUEST", "message": "Each item in the request body must be a contact object."}');
                return;
            }
        }

        // Validation de l'entrée
        if (contactsData.isEmpty()) {
            res.statusCode = 400; // Mauvaise requête
            res.responseBody = Blob.valueOf('{"errorCode": "MISSING_REQUIRED_FIELD", "message": "The request body must contain a list of contacts."}');
            return;
        }

        try {
            List<Contact> newContacts = new List<Contact>();
            List<String> responseList = new List<String>();

            for (Map<String, Object> contactData : contactsData) {
                String email = (String) contactData.get('email');
                String firstName = (String) contactData.get('firstName');
                String lastName = (String) contactData.get('lastName');

                // Validation des champs requis
                if (String.isBlank(email)) {
                    res.statusCode = 400; // Mauvaise requête
                    res.responseBody = Blob.valueOf('{"errorCode": "MISSING_REQUIRED_FIELD", "message": "Email is a required field."}');
                    return;
                }

                // Recherche de l'email dans Salesforce
                List<Contact> existingContacts = [SELECT Id FROM Contact WHERE Email = :email LIMIT 1];

                if (!existingContacts.isEmpty()) {
                    // Si le contact existe, retourner son Id
                    responseList.add('{"message": "Contact exists.", "id": "' + existingContacts[0].Id + '"}');
                } else {
                    // Si le contact n'existe pas, le créer
                    newContacts.add(new Contact(
                        FirstName = firstName,
                        LastName = lastName,
                        Email = email
                    ));
                }
            }

            // Insertion en bulk des nouveaux contacts
            insert newContacts;

            // Ajouter les nouveaux contacts créés à la réponse
            for (Contact newContact : newContacts) {
                responseList.add('{"message": "Contact created successfully.", "id": "' + newContact.Id + '"}');
            }

            res.statusCode = 200; // Succès
            res.responseBody = Blob.valueOf(JSON.serialize(responseList));
        } catch (Exception e) {
            res.statusCode = 500; // Erreur interne
            res.responseBody = Blob.valueOf('{"errorCode": "INSERT_FAILED", "message": "' + e.getMessage() + '"}');
        }
    }

    @HttpPatch
    global static void updateContacts() {
        RestResponse res = RestContext.response;

        // Récupérer et désérialiser le corps de la requête
        String requestBody = RestContext.request.requestBody.toString();
        Object deserializedBody = JSON.deserializeUntyped(requestBody);

        // Validation du type de l'entrée
        if (!(deserializedBody instanceof List<Object>)) {
            res.statusCode = 400; // Mauvaise requête
            res.responseBody = Blob.valueOf('{"errorCode": "INVALID_REQUEST", "message": "The request body must be a list of contact objects."}');
            return;
        }

        List<Object> inputList = (List<Object>) deserializedBody;
        List<Map<String, Object>> contactsData = new List<Map<String, Object>>();

        // Vérification que chaque élément est un map
        for (Object item : inputList) {
            if (item instanceof Map<String, Object>) {
                contactsData.add((Map<String, Object>) item);
            } else {
                res.statusCode = 400; // Mauvaise requête
                res.responseBody = Blob.valueOf('{"errorCode": "INVALID_REQUEST", "message": "Each item in the request body must be a contact object."}');
                return;
            }
        }

        try {
            List<String> responseList = new List<String>();

            for (Map<String, Object> contactData : contactsData) {
                String contactId = (String) contactData.get('id');

                // Validation de l'ID du contact
                if (String.isBlank(contactId)) {
                    res.statusCode = 400; // Mauvaise requête
                    res.responseBody = Blob.valueOf('{"errorCode": "MISSING_REQUIRED_FIELD", "message": "Contact ID is required."}');
                    return;
                }

                // Recherche du contact par ID
                List<Contact> contacts = [SELECT Id FROM Contact WHERE Id = :contactId LIMIT 1];
                if (contacts.isEmpty()) {
                    res.statusCode = 404; // Non trouvé
                    res.responseBody = Blob.valueOf('{"errorCode": "NOT_FOUND", "message": "Contact not found."}');
                    return;
                }

                // Mise à jour des champs
                Contact contactToUpdate = contacts[0];
                for (String fieldName : contactData.keySet()) {
                    if (!fieldName.equals('id') && Schema.sObjectType.Contact.fields.getMap().containsKey(fieldName)) {
                        contactToUpdate.put(fieldName, contactData.get(fieldName));
                    }
                }

                update contactToUpdate;
                responseList.add('{"message": "Contact updated successfully.", "id": "' + contactToUpdate.Id + '"}');
            }

            res.statusCode = 200; // Succès
            res.responseBody = Blob.valueOf(JSON.serialize(responseList));
        } catch (Exception e) {
            res.statusCode = 500; // Erreur interne
            res.responseBody = Blob.valueOf('{"errorCode": "UPDATE_FAILED", "message": "' + e.getMessage() + '"}');
        }
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