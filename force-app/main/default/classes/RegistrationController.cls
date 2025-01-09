/**
 * REST API controller to handle user registration.
 * - Allows potential customers to self-register by providing their first name, last name, email, and password.
 * - Validates if the email is already registered to avoid duplicate entries.
 * - Creates a new Contact record in Salesforce for successful registrations.
 */
@RestResource(urlMapping='/register')
global with sharing class RegistrationController {
    @HttpPost
    global static String registerUser(String firstName, String lastName, String email, String password) {
        // Validate required fields
        if (String.isBlank(firstName) || String.isBlank(lastName) || String.isBlank(email) || String.isBlank(password)) {
            return 'Champ requis manquant';
        }

        // Check if the email is already registered.
        List<Contact> existingContacts = [SELECT Id, Email FROM Contact WHERE Email = :email LIMIT 1];

        // If the email already exists, return an error message to avoid duplicate registrations.
        if (!existingContacts.isEmpty()) {
            return 'Email déjà inscrit';
        }

        // Create a new Contact record.
        Contact newContact = new Contact(
            FirstName = firstName,
            LastName = lastName,
            Email = email,
            Mot_de_passe__c = password
        );

        insert newContact;

        return 'Inscription réussie';
    }
}
