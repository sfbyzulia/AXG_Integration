/**
 * Utility class for handling external IDs on Contract records.
 * - Assigns a unique external ID to each new Contract record if the `ID_Externe__c` field is null.
 * - This ensures that every Contract has a globally unique identifier for external system integration.
 */
public class ContractExternalIDHandler {
    public static void assignExternalId(List<Contract> newRecords) {
        for (Contract record : newRecords) {
            if (record.ID_Externe__c == null) {
                record.ID_Externe__c = UUID.randomUUID().toString();
            }
        }
    }
}
