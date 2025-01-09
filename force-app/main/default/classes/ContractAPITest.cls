@isTest
public class ContractAPITest {

    @testSetup
    static void setupTestData() {
        User axguser = [SELECT Id FROM User WHERE Username = 'zulfiyyar27@gmail.com'];
        System.runAs(axguser) {
            // Create test data
            Account testAccount = new Account(Name = 'Test Account');
            insert testAccount;

            Contract testContract = new Contract(
                AccountId = testAccount.Id,
                Name = 'Test Contract',
                StartDate = Date.today(),
                ContractTerm = 12
            );
            insert testContract;
        }
    }

    @isTest
    static void testCreateContracts() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        // Test creating new contracts
        req.requestBody = Blob.valueOf('[{"accountId": "' + testAccount.Id + '", "contractName": "New Contract", "startDate": "2025-01-01", "contractTerm": 24}]');
        ContractAPI.createContracts();

        Assert.areEqual(200, res.statusCode, 'The response status code should be 200 for creating contracts.');
        Assert.isTrue(res.responseBody.toString().contains('Contrats créés avec succès'), 'The response should indicate the contracts were created successfully.');

        Contract newContract = [SELECT Name, ContractTerm FROM Contract WHERE Name = 'New Contract' LIMIT 1];
        Assert.areEqual('New Contract', newContract.Name, 'The contract name should match the expected value.');
        Assert.areEqual(24, newContract.ContractTerm, 'The contract term should match the expected value.');
    }

    @isTest
    static void testUpdateContracts() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Contract existingContract = [SELECT Id, ContractNumber FROM Contract LIMIT 1];

        // Test updating contracts
        req.requestBody = Blob.valueOf('[{"contractNumber": "' + existingContract.ContractNumber + '", "newStartDate": "2025-02-01", "newContractTerm": 36}]');
        ContractAPI.updateContracts();

        Assert.areEqual(200, res.statusCode, 'The response status code should be 200 for updating contracts.');
        Assert.isTrue(res.responseBody.toString().contains('Contrats mis à jour avec succès'), 'The response should indicate the contracts were updated successfully.');

        Contract updatedContract = [SELECT StartDate, ContractTerm FROM Contract WHERE Id = :existingContract.Id];
        Assert.areEqual(Date.valueOf('2025-02-01'), updatedContract.StartDate, 'The contract start date should be updated.');
        Assert.areEqual(36, updatedContract.ContractTerm, 'The contract term should be updated.');
    }

    @isTest
    static void testCreateContractsMissingFields() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        // Test missing required fields
        req.requestBody = Blob.valueOf('[{"accountId": "", "contractName": "", "startDate": "", "contractTerm": null}]');
        ContractAPI.createContracts();

        Assert.areEqual(500, res.statusCode, 'The response status code should be 500 for missing required fields.');
        Assert.isTrue(res.responseBody.toString().contains('Champ requis manquant'), 'The response should indicate missing required fields.');
    }

    @isTest
    static void testUpdateContractsMissingFields() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        // Test missing required fields
        req.requestBody = Blob.valueOf('[{"contractNumber": "", "newStartDate": "", "newContractTerm": null}]');
        ContractAPI.updateContracts();

        Assert.areEqual(500, res.statusCode, 'The response status code should be 500 for missing required fields.');
        Assert.isTrue(res.responseBody.toString().contains('Champ requis manquant'), 'The response should indicate missing required fields.');
    }

    @isTest
    static void testCreateContractsInvalidAccount() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        // Test invalid account ID with valid format but nonexistent
        String invalidAccountId = '001000000000001AAA'; // Valid ID format but not existing in the database

        // Ensure the ID is not accessible
        req.requestBody = Blob.valueOf('[{"accountId": "' + invalidAccountId + '", "contractName": "Invalid Contract", "startDate": "2025-01-01", "contractTerm": 24}]');
        ContractAPI.createContracts();

        Assert.areEqual(500, res.statusCode, 'The response status code should indicate an error for invalid account ID.');
        Assert.isTrue(res.responseBody.toString().contains('ID de compte invalide'), 'The response should indicate invalid account ID.');
    }
}
