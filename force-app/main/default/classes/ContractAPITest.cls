@isTest
private class ContractAPITest {

    /**
     * Helper method to configure RestRequest and RestResponse.
     */
    private static void configureRestContext(String requestURI, String httpMethod, String requestBody) {
        RestRequest req = new RestRequest();
        req.requestURI = requestURI;
        req.httpMethod = httpMethod;
        req.requestBody = Blob.valueOf(requestBody);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
    }

    /**
     * Helper method to create a test account.
     */
    private static Account createTestAccount() {
        Account account = new Account(Name = 'Test Account');
        insert account;
        return account;
    }

    /**
     * Helper method to create a test contract.
     */
    private static Contract createTestContract(Id accountId) {
        Contract contract = new Contract(
            AccountId = accountId,
            Name = 'Test Contract',
            StartDate = Date.valueOf('2025-01-01'),
            ContractTerm = 12
        );
        insert contract;
        return [SELECT ContractNumber FROM Contract WHERE Id = :contract.Id LIMIT 1];
    }

    @isTest
    static void testCreateContract() {
        // Create test account
        Account testAccount = createTestAccount();

        // Simulate creating a contract
        configureRestContext('/services/apexrest/Contract/Create/', 'POST',
            '{"accountId": "' + testAccount.Id + '", "contractName": "Test Contract", "startDate": "2025-01-01", "contractTerm": 12}');

        Test.startTest();
        String contractNumber = ContractAPI.createContract(testAccount.Id, 'Test Contract', '2025-01-01', 12);
        Test.stopTest();

        // Validate the created contract
        Contract createdContract = [SELECT ContractNumber, AccountId, Name, StartDate, ContractTerm FROM Contract WHERE ContractNumber = :contractNumber LIMIT 1];
        Assert.isNotNull(createdContract, 'Contract should be created');
        Assert.areEqual(testAccount.Id, createdContract.AccountId, 'AccountId should match');
        Assert.areEqual('Test Contract', createdContract.Name, 'Contract name should match');
        Assert.areEqual(Date.valueOf('2025-01-01'), createdContract.StartDate, 'Start date should match');
        Assert.areEqual(12, createdContract.ContractTerm, 'Contract term should match');
    }

    @isTest
    static void testCreateContractErrors() {
        Test.startTest();
        // Test missing parameters
        configureRestContext('/services/apexrest/Contract/Create/', 'POST', '{}');
        ContractAPI.createContract(null, null, null, null);

        RestResponse res = RestContext.response;
        Assert.areEqual(400, res.statusCode, 'Response status should be 400');
        Assert.isTrue(res.responseBody.toString().contains('All parameters are required'), 'Error message should indicate missing parameters');

        // Test non-existent account
        configureRestContext('/services/apexrest/Contract/Create/', 'POST',
            '{"accountId": "001000000000000AAA", "contractName": "Test Contract", "startDate": "2025-01-01", "contractTerm": 12}');
        ContractAPI.createContract('001000000000000AAA', 'Test Contract', '2025-01-01', 12);
        Test.stopTest();

        res = RestContext.response;
        Assert.areEqual(404, res.statusCode, 'Response status should be 404');
        Assert.isTrue(res.responseBody.toString().contains('Account not found'), 'Error message should indicate account not found');
    }

    @isTest
    static void testUpdateContract() {
        // Create test account and contract
        Account testAccount = createTestAccount();
        Contract testContract = createTestContract(testAccount.Id);

        // Simulate updating the contract
        configureRestContext('/services/apexrest/Contract/Update/', 'PATCH',
            '{"contractNumber": "' + testContract.ContractNumber + '", "newStartDate": "2025-06-01", "newContractTerm": 24}');

        Test.startTest();
        ContractAPI.updateContract(testContract.ContractNumber, '2025-06-01', 24);
        Test.stopTest();

        RestResponse res = RestContext.response;
        Assert.areEqual(200, res.statusCode, 'Response status should be 200');
        Assert.isTrue(res.responseBody.toString().contains('Contract updated successfully'), 'Success message should match');

        // Validate the updated contract
        Contract updatedContract = [SELECT StartDate, ContractTerm FROM Contract WHERE ContractNumber = :testContract.ContractNumber LIMIT 1];
        Assert.areEqual(Date.valueOf('2025-06-01'), updatedContract.StartDate, 'Start date should be updated');
        Assert.areEqual(24, updatedContract.ContractTerm, 'Contract term should be updated');
    }

    @isTest
    static void testUpdateContractErrors() {
        Test.startTest();
        // Test missing parameters
        configureRestContext('/services/apexrest/Contract/Update/', 'PATCH', '{}');
        ContractAPI.updateContract(null, null, null);

        RestResponse res = RestContext.response;
        Assert.areEqual(400, res.statusCode, 'Response status should be 400');
        Assert.isTrue(res.responseBody.toString().contains('All parameters are required'), 'Error message should indicate missing parameters');

        // Test non-existent contract
        configureRestContext('/services/apexrest/Contract/Update/', 'PATCH',
            '{"contractNumber": "CON000000000000AAA", "newStartDate": "2025-06-01", "newContractTerm": 24}');
        ContractAPI.updateContract('CON000000000000AAA', '2025-06-01', 24);
        Test.stopTest();

        res = RestContext.response;
        Assert.areEqual(404, res.statusCode, 'Response status should be 404');
        Assert.isTrue(res.responseBody.toString().contains('Contract not found'), 'Error message should indicate contract not found');
    }
}
