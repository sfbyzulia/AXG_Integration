@isTest
public class ExternalIDTest {

    @testSetup
    static void setupTestData() {
        // Setup initial data for testing
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
    }

    @isTest
    static void testContactExternalIDTrigger() {
        List<Contact> contacts = new List<Contact>{
            new Contact(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@example.com'),
            new Contact(FirstName = 'Jane', LastName = 'Doe', Email = 'jane.doe@example.com')
        };

        insert contacts;

        List<Contact> insertedContacts = [SELECT ID_Externe__c FROM Contact WHERE Email IN ('john.doe@example.com', 'jane.doe@example.com')];
        for (Contact contact : insertedContacts) {
            Assert.isNotNull(contact.ID_Externe__c, 'Contact external ID should not be null.');
        }
    }

    @isTest
    static void testContractExternalIDTrigger() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        List<Contract> contracts = new List<Contract>{
            new Contract(AccountId = testAccount.Id, StartDate = Date.today(), ContractTerm = 12),
            new Contract(AccountId = testAccount.Id, StartDate = Date.today().addDays(1), ContractTerm = 24)
        };

        insert contracts;

        List<Contract> insertedContracts = [SELECT ID_Externe__c FROM Contract WHERE AccountId = :testAccount.Id];
        for (Contract contract : insertedContracts) {
            Assert.isNotNull(contract.ID_Externe__c, 'Contract external ID should not be null.');
        }
    }

    @isTest
    static void testProductExternalIDTrigger() {
        List<Product2> products = new List<Product2>{
            new Product2(Name = 'Product A'),
            new Product2(Name = 'Product B')
        };

        insert products;

        List<Product2> insertedProducts = [SELECT ExternalId FROM Product2 WHERE Name IN ('Product A', 'Product B')];
        for (Product2 product : insertedProducts) {
            Assert.isNotNull(product.ExternalId, 'Product external ID should not be null.');
        }
    }
}
