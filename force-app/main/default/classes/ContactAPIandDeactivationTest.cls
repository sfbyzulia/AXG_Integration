@isTest
public class ContactAPIandDeactivationTest { 

    /**
     * Test setup method to create shared test data.
     */
    @testSetup
    static void setupTestData() {
        // Create a test contact
        Contact contact = new Contact(
            FirstName = 'Sarah',
            LastName = 'Goldman',
            Email = 's.goldman@example.com',
            IsActive__c = true // Custom field for active/inactive status
        );
        insert contact;
    }

    /**
     * Test the createOrFindContact method for new contact creation.
     */
    @isTest
    static void testCreateNewContact() {
        String newEmail = 'new.contact@example.com';
        String firstName = 'New';
        String lastName = 'Contact';

        Id contactId = ContactAPI.createOrFindContact(firstName, lastName, newEmail);
        Contact newContact = [SELECT Id, Email, FirstName, LastName FROM Contact WHERE Id = :contactId];

        Assert.isNotNull(newContact, 'New contact should be created');
        Assert.areEqual(newEmail, newContact.Email, 'Email should match the provided email');
        Assert.areEqual(firstName, newContact.FirstName, 'First name should match');
        Assert.areEqual(lastName, newContact.LastName, 'Last name should match');
    }

    /**
     * Test the createOrFindContact method for existing contact.
     */
    @isTest
    static void testFindExistingContact() {
        String existingEmail = 's.goldman@example.com';
        String firstName = 'Sarah';
        String lastName = 'Goldman';

        Id contactId = ContactAPI.createOrFindContact(firstName, lastName, existingEmail);
        Contact existingContact = [SELECT Id, Email, FirstName, LastName FROM Contact WHERE Id = :contactId];

        Assert.isNotNull(existingContact, 'Contact should exist');
        Assert.areEqual(existingEmail, existingContact.Email, 'Email should match the existing contact');
    }

    /**
     * Test the updateContact method.
     */
    @isTest
    static void testUpdateContact() {
        Contact contact = [SELECT Id, Email FROM Contact WHERE Email = 's.goldman@example.com'];
        String updatedEmail = 'sarah.updated@example.com';

        ContactAPI.updateContact(contact.Id, updatedEmail);

        Contact updatedContact = [SELECT Id, Email FROM Contact WHERE Id = :contact.Id];
        Assert.areEqual(updatedEmail, updatedContact.Email, 'Email should be updated');
    }

    /**
     * Test the deactivateContact method.
     */
    @isTest
    static void testDeactivateContact() {
        Contact contact = [SELECT Id, IsActive__c FROM Contact WHERE Email = 's.goldman@example.com'];
        Assert.isTrue(contact.IsActive__c, 'Contact should initially be active');

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Contact/Deactivate/' + contact.Id;
        req.httpMethod = 'PATCH';
        req.params.put('contactId', contact.Id);

        RestContext.request = req;

        ContactDeactivationAPI.deactivateContact();

        Contact deactivatedContact = [SELECT Id, IsActive__c FROM Contact WHERE Id = :contact.Id];
        Assert.isFalse(deactivatedContact.IsActive__c, 'Contact should be deactivated');
    }

    /**
     * Test the Contact trigger for preventing deletion.
     */
    @isTest
    static void testPreventContactDeletion() {
        Contact contact = [SELECT Id FROM Contact WHERE Email = 's.goldman@example.com'];

        Test.startTest();
        try {
            delete contact;
            Assert.fail('Deletion should have been prevented by the trigger');
        } catch (DmlException e) {
            Assert.isTrue(e.getMessage().contains('Contacts cannot be deleted'), 'Proper error message should be shown');
        }
        Test.stopTest();
    }

    /**
     * Test the deactivateContact method for missing contactId.
     */
    @isTest
    static void testDeactivateContactMissingId() {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Contact/Deactivate/';
        req.httpMethod = 'PATCH';

        RestContext.request = req;

        Test.startTest();
        try {
            ContactDeactivationAPI.deactivateContact();
            Assert.fail('Exception should have been thrown for missing contactId');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Contact ID is required'), 'Proper error message should be shown');
        }
        Test.stopTest();
    }

    /**
     * Test the deactivateContact method for non-existent contact.
     */
    @isTest
    static void testDeactivateContactNonExistent() {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/Contact/Deactivate/fakeId';
        req.httpMethod = 'PATCH';
        req.params.put('contactId', 'fakeId');

        RestContext.request = req;

        Test.startTest();
        try {
            ContactDeactivationAPI.deactivateContact();
            Assert.fail('Exception should have been thrown for non-existent contact');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Contact not found'), 'Proper error message should be shown');
        }
        Test.stopTest();
    }
}
