@RestResource(urlMapping='/api/contacts/*')
global class ContactAPI {

    @HttpPost
    global static String createOrFindContact(String firstName, String lastName, String email) {
        // Search contact by email
        List<Contact> existingContacts = [SELECT Id FROM Contact WHERE Email = :email LIMIT 1];
        
        if (!existingContacts.isEmpty()) {
            // If contact exists, return its Id
            return existingContacts[0].Id;
        } else {
            // If contact doesn't exist, create a new contact
            Contact newContact = new Contact(
                FirstName = firstName,
                LastName = lastName,
                Email = email
            );
            insert newContact;
    
            // Return the new contact's Id
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
}
