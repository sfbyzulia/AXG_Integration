trigger ContractExternalID on Contract (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        ContractExternalIDHandler.assignExternalId(Trigger.new);
    }
}
