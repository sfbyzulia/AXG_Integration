@isTest
public class ContactAPITest {

    @isTest 
    static void testCreateNewContact() {
        String accountName = 'Test Account';
        String firstName = 'John';
        String lastName = 'Doe';
        String email = 'john.doe@example.com';

        String contactId = ContactAPI.createOrUpdateContact(accountName, firstName, lastName, email);

        Contact createdContact = [SELECT Id, Email, FirstName, LastName FROM Contact WHERE Id = :contactId LIMIT 1];
        Assert.isNotNull(createdContact, 'Contact should be created');
        Assert.areEqual(email, createdContact.Email, 'Email should match');
        Assert.areEqual(firstName, createdContact.FirstName, 'First name should match');
        Assert.areEqual(lastName, createdContact.LastName, 'Last name should match');
    }

    @isTest 
    static void testExistingContact() {
        Account account = new Account(Name = 'Existing Account');
        insert account;

        Contact existingContact = new Contact(
            FirstName = 'Jane',
            LastName = 'Smith',
            Email = 'jane.smith@example.com',
            AccountId = account.Id
        );
        insert existingContact;

        String contactId = ContactAPI.createOrUpdateContact(account.Name, 'Jane', 'Smith', existingContact.Email);

        Assert.areEqual(existingContact.Id, contactId, 'Should return the existing contact ID');
    }

    @isTest 
    static void testUpdateContact() {
        Contact contact = new Contact(
            FirstName = 'Bob',
            LastName = 'Brown',
            Email = 'bob.brown@example.com'
        );
        insert contact;

        String newEmail = 'bob.newemail@example.com';

        ContactAPI.updateContact(contact.Id, newEmail);

        Contact updatedContact = [SELECT Id, Email FROM Contact WHERE Id = :contact.Id];
        Assert.areEqual(newEmail, updatedContact.Email, 'Email should be updated');
    }
}
