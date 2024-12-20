@isTest
public class ContactAPITest {

    // Create an account for testing
    private static Account createTestAccount(String name) {
        Account acc = new Account(Name = name);
        insert acc;
        return acc;
    }

    // Test for createOrUpdateContact method
    @isTest
    static void testCreateOrUpdateContact() {
        String accountName = 'Test Account';
        String firstName = 'John';
        String lastName = 'Doe';
        String email = 'john.doe@example.com';

        // Create a contact using the method
        String contactId = ContactAPI.createOrUpdateContact(accountName, firstName, lastName, email);
        Contact insertedContact = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id = :contactId LIMIT 1];

        Assert.isTrue(insertedContact != null, 'Contact should be created');
        Assert.areEqual(email, insertedContact.Email, 'Email should match the input email');

        // Call the method again with the same email to ensure it returns the existing contact Id
        String existingContactId = ContactAPI.createOrUpdateContact(accountName, firstName, lastName, email);
        Assert.areEqual(contactId, existingContactId, 'Should return the same contact Id for the same email');
    }

    @isTest
    static void testUpdateContact() {
        Account testAccount = createTestAccount('Test Account');
        Contact testContact = new Contact(
            FirstName = 'Jane',
            LastName = 'Smith',
            Email = 'jane.smith@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;

        String newEmail = 'updated.jane@example.com';
        ContactAPI.updateContact(testContact.Id, newEmail);

        Contact updatedContact = [SELECT Id, Email FROM Contact WHERE Id = :testContact.Id LIMIT 1];
        Assert.areEqual(newEmail, updatedContact.Email, 'Email should be updated');
    }

    @isTest
    static void testDeactivateContact() {
        // Create a test account
        Account testAccount = createTestAccount('Test Account');
    
        // Create a test contact with IsActive__c set to true
        Contact testContact = new Contact(
            FirstName = 'Mark',
            LastName = 'Johnson',
            Email = 'mark.johnson@example.com',
            AccountId = testAccount.Id,
            IsActive__c = true
        );
        insert testContact;
    
        // Deactivate the contact by calling the method directly
        RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/services/apexrest/api/contacts/' + testContact.Id;
    
        ContactAPI.deactivateContact();
    
        // Verify that the contact is deactivated
        Contact deactivatedContact = [SELECT Id, IsActive__c FROM Contact WHERE Id = :testContact.Id];
        Assert.isFalse(deactivatedContact.IsActive__c, 'Contact should be deactivated');
    }    
}
