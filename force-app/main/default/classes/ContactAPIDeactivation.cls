/**
 * REST API class to manage contact deactivation
 * - Allows updating the IsActive__c field on contact records via RESTful API.
 */

@RestResource(urlMapping='/Contact/Deactivate/*')
global class ContactAPIDeactivation {

    @HttpPatch
    global static void deactivateContacts() {
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

        for (Map<String, Object> contactData : contactsData) {
            String contactId = (String) contactData.get('id');
            String email = (String) contactData.get('email');

            // Validate the ID or email
            if (String.isBlank(contactId) && String.isBlank(email)) {
                res.statusCode = 400; 
                res.responseBody = Blob.valueOf('{"errorCode": "MISSING_REQUIRED_FIELD", "message": "Contact ID ou Email champ est requis."}');
                return;
            }

            // Search for the contact by ID or email
            List<Contact> contacts;
            if (!String.isBlank(contactId)) {
                contacts = [SELECT Id, IsActive__c FROM Contact WHERE Id = :contactId LIMIT 1];
            } else {
                contacts = [SELECT Id, IsActive__c FROM Contact WHERE Email = :email LIMIT 1];
            }

            if (contacts.isEmpty()) {
                res.statusCode = 404; 
                res.responseBody = Blob.valueOf('{"errorCode": "NOT_FOUND", "message": "Contact non trouvé."}');
                return;
            }

            // Deactivate the contact
            Contact contactToDeactivate = contacts[0];
            contactToDeactivate.IsActive__c = false;

            update contactToDeactivate;
            res.statusCode = 200; 
            res.responseBody = Blob.valueOf('{"message": "Contact désactivé avec succès.", "id": "' + contactToDeactivate.Id + '"}');
        }
    }
}
