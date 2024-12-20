@RestResource(urlMapping='/api/contacts/*')
global with sharing class ContactAPI {

    @HttpPost
    global static String createOrUpdateContact(String accountName, String firstName, String lastName, String email) {
        // Search contact by mail
        List<Contact> existingContacts = [SELECT Id, AccountId FROM Contact WHERE Email = :email LIMIT 1];
        
        if (!existingContacts.isEmpty()) {
            // If contact exists, return his Id
            return existingContacts[0].Id;
        } else {
            // If contact doesn't exist, check if account exists
            List<Account> existingAccounts = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
            Account account;

            if (!existingAccounts.isEmpty()) {
                account = existingAccounts[0];
            } else {
                // Create an account if no account exists
                account = new Account(Name = accountName);
                insert account;
            }

            // Create a new contact
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

    // Update contact
    @HttpPatch
    global static void updateContact(String contactId, String email) {
        Contact contactToUpdate = [SELECT Id, Email FROM Contact WHERE Id = :contactId LIMIT 1];
        contactToUpdate.Email = email;
        update contactToUpdate;
    }

    @HttpDelete
    global static void deactivateContact() {
        // Retrieve the contactId from the request URL
        String contactId = RestContext.request.requestURI.substringAfterLast('/');
    
        // Query the contact by Id
        Contact contactToDeactivate = [SELECT Id, IsActive__c FROM Contact WHERE Id = :contactId LIMIT 1];
    
        // Deactivate the contact by setting the custom field IsActive__c to false
        contactToDeactivate.IsActive__c = false;
        update contactToDeactivate;
    }    
}
