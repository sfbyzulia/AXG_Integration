public class ContractExternalIDHandler {
    public static void assignExternalId(List<Contract> newRecords) {
        for (Contract record : newRecords) {
            if (record.ID_Externe__c == null) {
                record.ID_Externe__c = UUID.randomUUID().toString();
            }
        }
    }
}
