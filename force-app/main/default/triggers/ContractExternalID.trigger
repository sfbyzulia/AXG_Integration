/**
 * Trigger to assign unique external IDs to new Contract records.
 * - Ensures that each new Contract has a globally unique identifier in the `ID_Externe__c` field.
 * - Delegates the logic to the `ContractExternalIDHandler` class for maintainability and reusability.
 */
trigger ContractExternalID on Contract (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        ContractExternalIDHandler.assignExternalId(Trigger.new);
    }
}
