trigger Contact on Contact (before delete) {
    for (Contact c : Trigger.old) {
        // Prevent deletion by throwing an error
        if (!c.IsDeleted) {
            c.addError('Contacts cannot be deleted. Please deactivate the contact instead.');
        }
    }
}
