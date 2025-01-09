/**
 * Trigger to assign unique external IDs to new Contact records.
 * - Ensures that each new Contact has a globally unique identifier in the `ID_Externe__c` field.
 * - Delegates the logic to the `ContactExternalIDHandler` class for maintainability and reusability.
 */
trigger ContactExternalID on Contact (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        ContactExternalIDHandler.assignExternalId(Trigger.new);
    }
}
