
/**
 * Utility class for handling external IDs on Product2 records.
 * - Assigns a unique external ID to each new Product2 record if the `ExternalId` field is null.
 * - Ensures that every Product2 record has a unique identifier for external system integration.
 */
public class ProductExternalIDHandler {
    public static void assignExternalId(List<Product2> newRecords) {
        for (Product2 record : newRecords) {
            if (record.ExternalId == null) {
                record.ExternalId = UUID.randomUUID().toString();
            }
        }
    }
}
