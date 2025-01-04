trigger Contact on Contact (before delete) {
    for (Contact c : Trigger.old) {
        // Prevent deletion by adding an error message
        c.addError('Contacts cannot be deleted. Please deactivate the contact instead deleting with PATCH request.');
    }
}
