/**
 * Trigger to assign unique external IDs to new Product2 records.
 * - Ensures that each new Product2 record has a globally unique identifier in the `External_ID__c` field.
 * - Delegates the logic to the `ProductExternalIDHandler` class for maintainability and reusability.
 */
trigger ProductExternalID on Product2 (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        ProductExternalIDHandler.assignExternalId(Trigger.new);
    }
}
