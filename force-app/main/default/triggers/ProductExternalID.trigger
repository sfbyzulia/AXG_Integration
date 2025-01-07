trigger ProductExternalID on Product2 (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        ProductExternalIDHandler.assignExternalId(Trigger.new);
    }
}
