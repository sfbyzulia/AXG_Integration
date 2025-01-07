trigger ContactExternalID on Contact (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        ContactExternalIDHandler.assignExternalId(Trigger.new);
    }
}
