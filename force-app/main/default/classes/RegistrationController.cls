@RestResource(urlMapping='/register')
global with sharing class RegistrationController {
    @HttpPost
    global static String registerUser(String firstName, String lastName, String email, String password) {
        try {
            // Vérifier si l'email existe déjà
            List<Contact> existingContacts = [SELECT Id, Email FROM Contact WHERE Email = :email LIMIT 1];

            if (!existingContacts.isEmpty()) {
                return 'Email already registered';
            }

            // Créer un nouveau contact
            Contact newContact = new Contact(
                FirstName = firstName,
                LastName = lastName,
                Email = email,
                Mot_de_passe__c = password
            );

            insert newContact;

            return 'Registration successful';
        } catch (Exception e) {
            return 'Registration failed: ' + e.getMessage();
        }
    }
}
