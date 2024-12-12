@RestResource(urlMapping='/api/contacts/*')
global with sharing class ContactAPI {

    @HttpPost
    global static String createOrUpdateContact(String accountName, String firstName, String lastName, String email) {
        // Check if the Account exists
        List<Account> existingAccounts = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
        Account account;
        
        if (!existingAccounts.isEmpty()) {
            account = existingAccounts[0];
        } else {
            account = new Account(Name = accountName);
            insert account;
        }

        // Check if the Contact exists
        List<Contact> existingContacts = [SELECT Id FROM Contact WHERE Email = :email LIMIT 1];
        
        if (!existingContacts.isEmpty()) {
            return existingContacts[0].Id;
        } else {
            Contact newContact = new Contact(
                FirstName = firstName,
                LastName = lastName,
                Email = email,
                AccountId = account.Id
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
