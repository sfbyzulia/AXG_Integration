@isTest
public class RegistrationControllerTest {

    @testSetup
    static void setupTestData() {
        Contact existingContact = new Contact(
            FirstName = 'Existing',
            LastName = 'User',
            Email = 'existing.user@example.com',
            Mot_de_passe__c = 'password123'
        );
        insert existingContact;
    }

    @isTest
    static void testSuccessfulRegistration() {
        String response = RegistrationController.registerUser(
            'New',
            'User',
            'new.user@example.com',
            'securePassword'
        );

        Assert.areEqual('Inscription réussie', response, 'The response should indicate successful registration.');

        // Verify the contact is created
        Contact newContact = [SELECT FirstName, LastName, Email, Mot_de_passe__c FROM Contact WHERE Email = 'new.user@example.com' LIMIT 1];
        Assert.areEqual('New', newContact.FirstName, 'The first name should match the input value.');
        Assert.areEqual('User', newContact.LastName, 'The last name should match the input value.');
        Assert.areEqual('new.user@example.com', newContact.Email, 'The email should match the input value.');
        Assert.areEqual('securePassword', newContact.Mot_de_passe__c, 'The password should match the input value.');
    }

    @isTest
    static void testDuplicateEmailRegistration() {
        String response = RegistrationController.registerUser(
            'Another',
            'User',
            'existing.user@example.com',
            'anotherPassword'
        );

        Assert.areEqual('Email déjà inscrit', response, 'The response should indicate that the email is already registered.');

        // Verify no new contact is created
        List<Contact> duplicateCheck = [SELECT Id FROM Contact WHERE Email = 'existing.user@example.com'];
        Assert.areEqual(1, duplicateCheck.size(), 'No new contact should be created for duplicate email.');
    }

    @isTest
    static void testMissingRequiredFields() {
        String responseMissingEmail = RegistrationController.registerUser(
            'FirstName',
            'LastName',
            '', // Empty email
            'securePassword'
        );
        Assert.areEqual('Champ requis manquant', responseMissingEmail, 'The response should indicate a missing required field.');

        // Missing first name
        String responseMissingFirstName = RegistrationController.registerUser(
            '',
            'LastName',
            'user@example.com',
            'securePassword'
        );
        Assert.areEqual('Champ requis manquant', responseMissingFirstName, 'The response should indicate a missing required field.');

        // Missing last name
        String responseMissingLastName = RegistrationController.registerUser(
            'FirstName',
            '',
            'user@example.com',
            'securePassword'
        );
        Assert.areEqual('Champ requis manquant', responseMissingLastName, 'The response should indicate a missing required field.');

        // Missing password
        String responseMissingPassword = RegistrationController.registerUser(
            'FirstName',
            'LastName',
            'user@example.com',
            '' // Empty password
        );
        Assert.areEqual('Champ requis manquant', responseMissingPassword, 'The response should indicate a missing required field.');
    }
}
