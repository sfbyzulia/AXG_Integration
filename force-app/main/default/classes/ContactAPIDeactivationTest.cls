@isTest
public class ContactAPIDeactivationTest {

    /**
     * Test setup method to create shared test data.
     */
    @testSetup
    static void setupTestData() {
        // Create a test contact
        Contact contact = new Contact(
            FirstName = 'Sarah',
            LastName = 'Goldman',
            Email = 's.goldman@example.com'
        );
        insert contact;
    }

    /**
     * Helper method to configure RestRequest and RestResponse.
     */
    private static void configureRestContext(String requestURI, String httpMethod, String requestBody) {
        RestRequest req = new RestRequest();
        req.requestURI = requestURI;
        req.httpMethod = httpMethod;
        req.requestBody = Blob.valueOf(requestBody);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
    }

    /**
     * Test the createOrFindContact method for new contact creation.
     */
    @isTest
    static void testCreateNewContact() {
        configureRestContext('/services/apexrest/Contact/CreateOrFind/', 'POST',
            '{"firstName": "New", "lastName": "Contact", "email": "new.contact@example.com"}');

        Test.startTest();
        String contactId = ContactAPI.createOrFindContact('New', 'Contact', 'new.contact@example.com');
        Test.stopTest();

        Contact newContact = [SELECT Id, Email, FirstName, LastName FROM Contact WHERE Id = :contactId];
        Assert.isNotNull(newContact, 'New contact should be created');
        Assert.areEqual('new.contact@example.com', newContact.Email, 'Email should match');
        Assert.areEqual('New', newContact.FirstName, 'First name should match');
        Assert.areEqual('Contact', newContact.LastName, 'Last name should match');
    }

    /**
     * Test the createOrFindContact method with missing email.
     */
    @isTest
    static void testCreateContactMissingEmail() {
        configureRestContext('/services/apexrest/Contact/CreateOrFind/', 'POST',
            '{"firstName": "New", "lastName": "Contact"}');

        Test.startTest();
        ContactAPI.createOrFindContact('New', 'Contact', null);
        Test.stopTest();

        RestResponse res = RestContext.response;
        Assert.areEqual(400, res.statusCode, 'Response status should be 400');
        Assert.isTrue(res.responseBody.toString().contains('Email is a required field'), 'Error message should indicate missing email');
    }

    /**
     * Test the createOrFindContact method for existing contact.
     */
    @isTest
    static void testFindExistingContact() {
        configureRestContext('/services/apexrest/Contact/CreateOrFind/', 'POST',
            '{"firstName": "Sarah", "lastName": "Goldman", "email": "s.goldman@example.com"}');

        Test.startTest();
        String contactId = ContactAPI.createOrFindContact('Sarah', 'Goldman', 's.goldman@example.com');
        Test.stopTest();

        Contact existingContact = [SELECT Id, Email, FirstName, LastName FROM Contact WHERE Id = :contactId];
        Assert.isNotNull(existingContact, 'Contact should exist');
        Assert.areEqual('s.goldman@example.com', existingContact.Email, 'Email should match');
    }

    /**
     * Test the updateContact method for valid input.
     */
    @isTest
    static void testUpdateContact() {
        Contact contact = [SELECT Id, Email FROM Contact WHERE Email = 's.goldman@example.com'];

        configureRestContext('/services/apexrest/Contact/Update/', 'PATCH',
            '{"contactId": "' + contact.Id + '", "email": "sarah.updated@example.com"}');

        Test.startTest();
        ContactAPI.updateContact(contact.Id, 'sarah.updated@example.com');
        Test.stopTest();

        RestResponse res = RestContext.response;
        Assert.areEqual(200, res.statusCode, 'Response status should be 200');
        Assert.isTrue(res.responseBody.toString().contains('Contact updated successfully'), 'Success message should match');

        Contact updatedContact = [SELECT Id, Email FROM Contact WHERE Id = :contact.Id];
        Assert.areEqual('sarah.updated@example.com', updatedContact.Email, 'Email should be updated');
    }

    /**
     * Test the updateContact method with missing parameters.
     */
    @isTest
    static void testUpdateContactMissingParameters() {
        configureRestContext('/services/apexrest/Contact/Update/', 'PATCH', '{}');

        Test.startTest();
        ContactAPI.updateContact(null, null);
        Test.stopTest();

        RestResponse res = RestContext.response;
        Assert.areEqual(400, res.statusCode, 'Response status should be 400');
        Assert.isTrue(res.responseBody.toString().contains('Contact ID and Email are required'), 'Error message should indicate missing parameters');
    }

    /**
     * Test the updateContact method with non-existent contactId.
     */
    @isTest
    static void testUpdateContactNonExistentId() {
        configureRestContext('/services/apexrest/Contact/Update/', 'PATCH',
            '{"contactId": "003000000000000AAA", "email": "nonexistent@example.com"}');

        Test.startTest();
        ContactAPI.updateContact('003000000000000AAA', 'nonexistent@example.com');
        Test.stopTest();

        RestResponse res = RestContext.response;
        Assert.areEqual(404, res.statusCode, 'Response status should be 404');
        Assert.isTrue(res.responseBody.toString().contains('Contact not found'), 'Error message should match');
    }

    /**
     * Test the deactivateContact method with a valid contactId.
     */
    @isTest
    static void testDeactivateContactValidId() {
        Contact contact = [SELECT Id, IsActive__c FROM Contact WHERE Email = 's.goldman@example.com'];

        configureRestContext('/services/apexrest/Contact/Deactivate/', 'PATCH',
            '{"contactId": "' + contact.Id + '"}');

        Test.startTest();
        ContactAPIDeactivation.deactivateContact();
        Test.stopTest();

        RestResponse res = RestContext.response;
        Assert.areEqual(200, res.statusCode, 'Response status should be 200');
        Assert.isTrue(res.responseBody.toString().contains('Contact successfully deactivated'), 'Success message should be returned');

        Contact updatedContact = [SELECT Id, IsActive__c FROM Contact WHERE Id = :contact.Id];
        Assert.isFalse(updatedContact.IsActive__c, 'Contact should be deactivated');
    }

    /**
     * Test the deactivateContact method with a missing contactId.
     */
    @isTest
    static void testDeactivateContactMissingId() {
        configureRestContext('/services/apexrest/Contact/Deactivate/', 'PATCH', '{}');

        Test.startTest();
        ContactAPIDeactivation.deactivateContact();
        Test.stopTest();

        RestResponse res = RestContext.response;
        Assert.areEqual(400, res.statusCode, 'Response status should be 400');
        Assert.isTrue(res.responseBody.toString().contains('Contact ID is required'), 'Error message should match');
    }

    /**
     * Test the deactivateContact method with a non-existent contactId.
     */
    @isTest
    static void testDeactivateContactNonExistentId() {
        configureRestContext('/services/apexrest/Contact/Deactivate/', 'PATCH',
            '{"contactId": "003000000000000AAA"}');

        Test.startTest();
        ContactAPIDeactivation.deactivateContact();
        Test.stopTest();

        RestResponse res = RestContext.response;
        Assert.areEqual(404, res.statusCode, 'Response status should be 404');
        Assert.isTrue(res.responseBody.toString().contains('Contact not found'), 'Error message should match');
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
}
