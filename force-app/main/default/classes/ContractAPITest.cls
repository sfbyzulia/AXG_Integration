@isTest
public class ContractAPITest {
    
    // Test the createContract method when the Account exists
    @isTest static void testCreateContractWithExistingAccount() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Call the API method
        String contractId = ContractAPI.createContract('Test Account', 12, 'Draft');
        
        // Verify the Contract was created
        Contract createdContract = [SELECT Id, AccountId, ContractTerm, Status FROM Contract WHERE Id = :contractId LIMIT 1];
        
        Assert.isTrue(createdContract != null, 'Contract should be created');
        Assert.areEqual(testAccount.Id, createdContract.AccountId, 'Contract should be linked to the existing Account');
        Assert.areEqual(12, createdContract.ContractTerm, 'Contract term should match');
        Assert.areEqual('Draft', createdContract.Status, 'Contract status should match');
    }
    
    // Test the createContract method when the Account does not exist
    @isTest static void testCreateContractWithNewAccount() {
        String accountName = 'New Test Account';
        
        // Call the API method
        String contractId = ContractAPI.createContract(accountName, 24, 'Draft');
        
        // Verify the Account was created
        Account createdAccount = [SELECT Id, Name FROM Account WHERE Name = :accountName LIMIT 1];
        Assert.isTrue(createdAccount != null, 'Account should be created');
        
        // Verify the Contract was created and linked to the new Account
        Contract createdContract = [SELECT Id, AccountId, ContractTerm, Status FROM Contract WHERE Id = :contractId LIMIT 1];
        Assert.areEqual(createdAccount.Id, createdContract.AccountId, 'Contract should be linked to the new Account');
        Assert.areEqual(24, createdContract.ContractTerm, 'Contract term should match');
        Assert.areEqual('Draft', createdContract.Status, 'Contract status should match');
    }
    
    // Test the updateContract method
    @isTest static void testUpdateContract() {
        // Create a test Account
        Account testAccount = new Account(Name = 'Update Test Account');
        insert testAccount;
        
        // Create a test Contract
        Contract testContract = new Contract(
            AccountId = testAccount.Id,
            ContractTerm = 12,
            Status = 'Draft'
        );
        insert testContract;
        
        // Call the API method to update the contract status
        ContractAPI.updateContract(testContract.Id, 'Activated');
        
        // Verify the Contract status was updated
        Contract updatedContract = [SELECT Id, Status FROM Contract WHERE Id = :testContract.Id LIMIT 1];
        Assert.areEqual('Activated', updatedContract.Status, 'Contract status should be updated to Activated');
    }
}