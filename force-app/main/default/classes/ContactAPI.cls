/**
 * REST API class to manage contacts.
 *  - Allows creation, update and deletion of contacts via RESTful API methods.
 */

@RestResource(urlMapping='/api/contacts/*') 
global with sharing class ContactAPI {
    
    @HttpPost
    global static void createOrFindContacts() {
        RestResponse res = RestContext.response;
    
        // Retrieve and deserialize the request body
        String requestBody = RestContext.request.requestBody.toString();
        Object deserializedBody = JSON.deserializeUntyped(requestBody);
    
        List<Object> inputList = (List<Object>) deserializedBody;
        List<Map<String, Object>> contactsData = new List<Map<String, Object>>();
    
        // Add elements to the contacts data list
        for (Object item : inputList) {
            if (item instanceof Map<String, Object>) {
                contactsData.add((Map<String, Object>) item);
            }
        }
    
        List<Contact> newContacts = new List<Contact>();
        List<String> responseList = new List<String>();
    
        for (Map<String, Object> contactData : contactsData) {
            String email = (String) contactData.get('email');
            String firstName = (String) contactData.get('firstName');
            String lastName = (String) contactData.get('lastName');
    
            // Validate requiered fields
            if (String.isBlank(email)) {
                res.statusCode = 400; 
                res.responseBody = Blob.valueOf('{"errorCode": "MISSING_REQUIRED_FIELD", "message": "Email est un champ requis."}');
                return;
            }
    
            // Search for the email in Salesforce
            List<Contact> existingContacts = [SELECT Id FROM Contact WHERE Email = :email LIMIT 1];
    
            if (!existingContacts.isEmpty()) {
                // If the contact exists, return its ID
                responseList.add('{"message": "Contact existe.", "id": "' + existingContacts[0].Id + '"}');
            } else {
                // If not, create a contact
                newContacts.add(new Contact(
                    FirstName = firstName,
                    LastName = lastName,
                    Email = email
                ));
            }
        }
    
        // Bulk insert new contacts
        insert newContacts;
    
        // Add newly created contacts to the response
        for (Contact newContact : newContacts) {
            responseList.add('{"message": "Contact créé avec succès.", "id": "' + newContact.Id + '"}');
        }
    
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(responseList));
    }    

    @HttpPatch
    global static void updateContacts() {
        RestResponse res = RestContext.response;
    
        // Retrieve and deserialize the request body
        String requestBody = RestContext.request.requestBody.toString();
        Object deserializedBody = JSON.deserializeUntyped(requestBody);
    
        List<Object> inputList = (List<Object>) deserializedBody;
        List<Map<String, Object>> contactsData = new List<Map<String, Object>>();
    
        // Add elements to the contacts data list
        for (Object item : inputList) {
            if (item instanceof Map<String, Object>) {
                contactsData.add((Map<String, Object>) item);
            }
        }
    
        List<String> responseList = new List<String>();
    
        for (Map<String, Object> contactData : contactsData) {
            String contactId = (String) contactData.get('id');
    
            // Validate the contact ID
            if (String.isBlank(contactId)) {
                res.statusCode = 400; 
                res.responseBody = Blob.valueOf('{"errorCode": "MISSING_REQUIRED_FIELD", "message": "Contact ID est un champ requis."}');
                return;
            }
    
            // Search for the contact by ID
            List<Contact> contacts = [SELECT Id FROM Contact WHERE Id = :contactId LIMIT 1];
            if (contacts.isEmpty()) {
                res.statusCode = 404; 
                res.responseBody = Blob.valueOf('{"errorCode": "NOT_FOUND", "message": "Contact non trouvé."}');
                return;
            }
    
            // Update fields
            Contact contactToUpdate = contacts[0];
            for (String fieldName : contactData.keySet()) {
                if (!fieldName.equals('id') && Schema.sObjectType.Contact.fields.getMap().containsKey(fieldName)) {
                    contactToUpdate.put(fieldName, contactData.get(fieldName));
                }
            }
    
            update contactToUpdate;
            responseList.add('{"message": "Contact mis à jour avec succès.", "id": "' + contactToUpdate.Id + '"}');
        }
    
        res.statusCode = 200; 
        res.responseBody = Blob.valueOf(JSON.serialize(responseList));
    }    
    
        @HttpDelete
        global static void deleteContact() {
            RestResponse res = RestContext.response;

                // Retrieve the contact ID to delete from the URL
                String contactId = RestContext.request.requestURI.substring(
                    RestContext.request.requestURI.lastIndexOf('/') + 1
                );
    
                // Check if the contact exists
                Contact contactToDelete = [SELECT Id FROM Contact WHERE Id = :contactId LIMIT 1];
    
                // Block deletion with a custom error response
                res.responseBody = Blob.valueOf('Les contacts ne peuvent pas être supprimés. Veuillez désactiver le contact.');
                res.statusCode = 400;
        }
    }    