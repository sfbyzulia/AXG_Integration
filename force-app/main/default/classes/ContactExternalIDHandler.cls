public class ContactExternalIDHandler {
    public static void assignExternalId(List<Contact> newRecords) {
        for (Contact record : newRecords) {
            if (record.ID_Externe__c == null) {
                record.ID_Externe__c = UUID.randomUUID().toString();
            }
        }
    }
}
