@RestResource(urlMapping='/Contact/Deactivate/*')
global class ContactDeactivationAPI {

    @HttpPatch
    global static void deactivateContact() {
        RestRequest req = RestContext.request;
        String contactId = req.params.get('contactId');

        if (String.isBlank(contactId)) {
            throw new AuraHandledException('Contact ID is required.');
        }

        List<Contact> contacts = [SELECT Id, IsActive__c FROM Contact WHERE Id = :contactId LIMIT 1];

        if (contacts.isEmpty()) {
            return;
        }

        Contact contact = contacts[0];
        contact.IsActive__c = false;
        update contact;
    }
}
