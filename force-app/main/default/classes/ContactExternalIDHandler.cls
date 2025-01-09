/**
 * Utility class for handling external IDs on Contact records.
 * - Assigns a unique external ID to each new Contact record if the `ID_Externe__c` field is null.
 * - Ensures that every Contact has a unique identifier for external system integration.
 */
public class ContactExternalIDHandler {
    public static void assignExternalId(List<Contact> newRecords) {
        for (Contact record : newRecords) {
            if (record.ID_Externe__c == null) {
                record.ID_Externe__c = UUID.randomUUID().toString();
            }
        }
    }
}
