@isTest
public class ContactAPITest {

    @isTest
    static void createNewContact() {
        String firstName = 'John';
        String lastName = 'Doe';
        String email = 'john.doe@example.com';

        String contactId = ContactAPI.createOrUpdateContact(firstName, lastName, email);

        Contact createdContact = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id = :contactId];
        Assert.isTrue(createdContact != null, 'Contact should have been created');
        Assert.areEqual(firstName, createdContact.FirstName, 'First name should match');
        Assert.areEqual(lastName, createdContact.LastName, 'Last name should match');
        Assert.areEqual(email, createdContact.Email, 'Email should match');
    }

    @isTest
    static void checkExistingContact() {
        Contact existingContact = new Contact(FirstName = 'Jane', LastName = 'Doe', Email = 'jane.doe@example.com');
        insert existingContact;

        String contactId = ContactAPI.createOrUpdateContact('Jane', 'Doe', 'jane.doe@example.com');

        Assert.areEqual(existingContact.Id, contactId, 'Existing contact ID should be returned');
    }

    @isTest
    static void testUpdateContact() {
        Contact contact = new Contact(FirstName = 'Alice', LastName = 'Smith', Email = 'alice.smith@example.com');
        insert contact;

        ContactAPI.updateContact(contact.Id, 'new.email@example.com');

        Contact updatedContact = [SELECT Email FROM Contact WHERE Id = :contact.Id];
        Assert.areEqual('new.email@example.com', updatedContact.Email, 'Email should have been updated');
    }
}
