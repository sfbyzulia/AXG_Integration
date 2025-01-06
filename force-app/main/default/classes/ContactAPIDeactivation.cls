@RestResource(urlMapping='/Contact/Deactivate/*')
global class ContactAPIDeactivation {

    @HttpPatch
    global static void deactivateContact() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

         // Parse the contactId from the request body
         Map<String, Object> requestBody = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
         String contactId = requestBody != null && requestBody.containsKey('contactId') ? (String) requestBody.get('contactId') : null; 

        // If contactId is blank, return an error response
        if (String.isBlank(contactId)) {
            res.statusCode = 400; // Bad Request
            res.responseBody = Blob.valueOf('{"errorCode": "MISSING_REQUIRED_FIELD", "message": "Contact ID is required."}');
            return;
        }

        // Query the contact
        List<Contact> contacts = [SELECT Id, IsActive__c FROM Contact WHERE Id = :contactId LIMIT 1];

        // Check if the contact exists
        if (contacts.isEmpty()) {
            res.statusCode = 404; // Not Found
            res.responseBody = Blob.valueOf('{"errorCode": "NOT_FOUND", "message": "Contact not found."}');
            return;
        }

        // Deactivate the contact
        Contact contact = contacts[0];
        contact.IsActive__c = false;
        update contact;

        // Send success response
        res.statusCode = 200; // OK
        res.responseBody = Blob.valueOf('{"message": "Contact successfully deactivated."}');
    }
}
