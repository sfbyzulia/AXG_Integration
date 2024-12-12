@RestResource(urlMapping='/api/contacts/*')
global with sharing class ContactAPI {

    @HttpPost
    global static String createOrUpdateContact(String firstName, String lastName, String email) {
        List<Contact> existingContacts = [SELECT Id FROM Contact WHERE Email = :email LIMIT 1];
        
        if (!existingContacts.isEmpty()) {
            // Return the existing contact's ID
            return existingContacts[0].Id;
        } else {
            Contact newContact = new Contact(
                FirstName = firstName,
                LastName = lastName,
                Email = email
            );
            insert newContact;
            return newContact.Id;
        }
    }

    @HttpPatch
    global static void updateContact(String contactId, String email) {
        Contact contactToUpdate = [SELECT Id, Email FROM Contact WHERE Id = :contactId LIMIT 1];
        contactToUpdate.Email = email;
        update contactToUpdate;
    }
}
