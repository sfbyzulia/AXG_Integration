@RestResource(urlMapping='/Contact/Deactivate/*')
global class ContactAPIDeactivation {

    @HttpPatch
    global static List<String> deactivateContacts() {
        RestResponse res = RestContext.response;

        // Récupérer et désérialiser le corps de la requête
        String requestBody = RestContext.request.requestBody.toString();
        Object deserializedBody = JSON.deserializeUntyped(requestBody);

        // Validation du type de l'entrée
        if (!(deserializedBody instanceof List<Object>)) {
            res.statusCode = 400; // Mauvaise requête
            res.responseBody = Blob.valueOf('{"errorCode": "INVALID_REQUEST", "message": "The request body must be a list of contact objects."}');
            return null;
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
                return null;
            }
        }

        // Validation de l'entrée
        if (contactsData.isEmpty()) {
            res.statusCode = 400; // Mauvaise requête
            res.responseBody = Blob.valueOf('{"errorCode": "MISSING_REQUIRED_FIELD", "message": "The request body must contain a list of contacts to deactivate."}');
            return null;
        }

        List<String> results = new List<String>();

        for (Map<String, Object> contactData : contactsData) {
            String contactId = (String) contactData.get('id');
            String email = (String) contactData.get('email');

            // Validation de l'ID ou de l'email
            if (String.isBlank(contactId) && String.isBlank(email)) {
                results.add('{"errorCode": "MISSING_REQUIRED_FIELD", "message": "Contact ID or Email is required."}');
                continue;
            }

            // Recherche du contact par ID ou email
            List<Contact> contacts;
            if (!String.isBlank(contactId)) {
                contacts = [SELECT Id, IsActive__c FROM Contact WHERE Id = :contactId LIMIT 1];
            } else {
                contacts = [SELECT Id, IsActive__c FROM Contact WHERE Email = :email LIMIT 1];
            }

            if (contacts.isEmpty()) {
                results.add('{"errorCode": "NOT_FOUND", "message": "Contact not found."}');
                continue;
            }

            // Désactivation du contact
            Contact contactToDeactivate = contacts[0];
            contactToDeactivate.IsActive__c = false;

            try {
                update contactToDeactivate;
                results.add('{"message": "Contact deactivated successfully.", "id": "' + contactToDeactivate.Id + '"}');
            } catch (Exception e) {
                results.add('{"errorCode": "DEACTIVATION_FAILED", "message": "' + e.getMessage() + '"}');
            }
        }

        return results;
    }
}
