@isTest
public class ContactAPITest {

    @testSetup
    static void setupTestData() {
        User axguser = [SELECT Id FROM User WHERE Username = 'zulfiyyar27@gmail.com'];
        System.runAs(axguser) {
            Account testAccount = new Account(Name = 'Test Account');
            insert testAccount;

            Contact testContact = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@example.com', AccountId = testAccount.Id, IsActive__c = true);
            insert testContact;
        }
    }

    @isTest
    static void testCreateOrFindContacts() {
        // Mocking HTTP request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        // Test missing email
        req.requestBody = Blob.valueOf('[{"firstName": "Jane", "lastName": "Doe"}]');
        ContactAPI.createOrFindContacts();
        Assert.areEqual(400, res.statusCode, 'The response status code should be 400 for missing email.');
        Assert.isTrue(res.responseBody.toString().contains('Email est un champ requis'), 'The response should indicate email is required.');

        // Test existing contact
        Contact existingContact = [SELECT Id, Email FROM Contact LIMIT 1];
        req.requestBody = Blob.valueOf('[{"email": "' + existingContact.Email + '", "firstName": "John", "lastName": "Doe"}]');
        ContactAPI.createOrFindContacts();
        Assert.areEqual(200, res.statusCode, 'The response status code should be 200 for existing contact.');
        Assert.isTrue(res.responseBody.toString().contains('Contact existe'), 'The response should indicate the contact exists.');

        // Test creating new contact
        req.requestBody = Blob.valueOf('[{"email": "new.contact@example.com", "firstName": "New", "lastName": "Contact"}]');
        ContactAPI.createOrFindContacts();
        Assert.areEqual(200, res.statusCode, 'The response status code should be 200 for creating a new contact.');
        Assert.isTrue(res.responseBody.toString().contains('Contact créé avec succès'), 'The response should indicate the contact was created.');

        Contact newContact = [SELECT Email FROM Contact WHERE Email = 'new.contact@example.com'];
        Assert.areEqual('new.contact@example.com', newContact.Email, 'The new contact should be created with the correct email.');
    }

    @isTest
    static void testUpdateContacts() {
        Contact existingContact = [SELECT Id FROM Contact LIMIT 1];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        // Test missing contact ID
        req.requestBody = Blob.valueOf('[{"LastName": "UpdatedLastName"}]');
        ContactAPI.updateContacts();
        Assert.areEqual(400, res.statusCode, 'The response status code should be 400 for missing contact ID.');
        Assert.isTrue(res.responseBody.toString().contains('Contact ID est un champ requis'), 'The response should indicate contact ID is required.');

        // Test non-existent contact
        req.requestBody = Blob.valueOf('[{"id": "nonexistentId", "LastName": "UpdatedLastName"}]');
        ContactAPI.updateContacts();
        Assert.areEqual(404, res.statusCode, 'The response status code should be 404 for non-existent contact.');
        Assert.isTrue(res.responseBody.toString().contains('Contact non trouvé'), 'The response should indicate the contact was not found.');

        // Test updating existing contact
        req.requestBody = Blob.valueOf('[{"id": "' + existingContact.Id + '", "LastName": "UpdatedLastName", "FirstName": "UpdatedFirstName"}]');
        ContactAPI.updateContacts();
        Assert.areEqual(200, res.statusCode, 'The response status code should be 200 for updating an existing contact.');
        Assert.isTrue(res.responseBody.toString().contains('Contact mis à jour avec succès'), 'The response should indicate the contact was updated.');

        Contact updatedContact = [SELECT FirstName, LastName FROM Contact WHERE Id = :existingContact.Id];
        Assert.areEqual('UpdatedFirstName', updatedContact.FirstName, 'The contact first name should be updated.');
        Assert.areEqual('UpdatedLastName', updatedContact.LastName, 'The contact last name should be updated.');
    }

    @isTest
    static void testDeleteContact() {
        Contact existingContact = [SELECT Id FROM Contact LIMIT 1];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        req.requestURI = '/api/contacts/' + existingContact.Id;

        ContactAPI.deleteContact();

        Assert.areEqual(400, res.statusCode, 'The response status code should be 400.');
        Assert.isTrue(res.responseBody.toString().contains('Les contacts ne peuvent pas être supprimés'), 'The response should indicate contacts cannot be deleted.');
    }

    @isTest
    static void testDeactivateContacts() {
        Contact existingContact = [SELECT Id FROM Contact WHERE IsActive__c = true LIMIT 1];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        // Test missing ID or email
        req.requestBody = Blob.valueOf('[{}]');
        ContactAPIDeactivation.deactivateContacts();
        Assert.areEqual(400, res.statusCode, 'The response status code should be 400 for missing ID or email.');
        Assert.isTrue(res.responseBody.toString().contains('Contact ID ou Email champ est requis'), 'The response should indicate missing ID or email.');

        // Test non-existent contact by email
        req.requestBody = Blob.valueOf('[{"email": "nonexistent@example.com"}]');
        ContactAPIDeactivation.deactivateContacts();
        Assert.areEqual(404, res.statusCode, 'The response status code should be 404 for non-existent contact by email.');
        Assert.isTrue(res.responseBody.toString().contains('Contact non trouvé'), 'The response should indicate the contact was not found.');

        // Test deactivating existing contact
        req.requestBody = Blob.valueOf('[{"id": "' + existingContact.Id + '"}]');
        ContactAPIDeactivation.deactivateContacts();

        Assert.areEqual(200, res.statusCode, 'The response status code should be 200.');
        String responseBody = res.responseBody.toString();
        Assert.isTrue(responseBody.contains('"message": "Contact désactivé avec succès."'), 'The response should indicate a contact was deactivated.');

        Contact deactivatedContact = [SELECT IsActive__c FROM Contact WHERE Id = :existingContact.Id];
        Assert.isFalse(deactivatedContact.IsActive__c, 'The contact should be deactivated.');
    }
}
