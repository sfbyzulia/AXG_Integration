public class ProductExternalIDHandler {
    public static void assignExternalId(List<Product2> newRecords) {
        for (Product2 record : newRecords) {
            if (record.External_ID__c == null) {
                record.External_ID__c = UUID.randomUUID().toString();
            }
        }
    }
}
