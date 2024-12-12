@isTest
public class ContractAPITest {

    @isTest
    static void testCreateContract() {
        Account account = new Account(Name = 'Test Account');
        insert account;

        String accountId = account.Id;
        Integer contractTerm = 12;
        String status = 'Draft';

        String contractId = ContractAPI.createContract(accountId, contractTerm, status);

        Contract createdContract = [SELECT Id, AccountId, ContractTerm, Status FROM Contract WHERE Id = :contractId];
        Assert.isTrue(createdContract != null, 'Contract should have been created');
        Assert.areEqual(accountId, createdContract.AccountId, 'Account ID should match');
        Assert.areEqual(contractTerm, createdContract.ContractTerm, 'Contract term should match');
        Assert.areEqual(status, createdContract.Status, 'Status should match');
    }

    @isTest
    static void testUpdateContract() {
        Account account = new Account(Name = 'Test Account');
        insert account;

        Contract contract = new Contract(AccountId = account.Id, ContractTerm = 6, Status = 'Draft');
        insert contract;

        ContractAPI.updateContract(contract.Id, 'Activated');

        Contract updatedContract = [SELECT Status FROM Contract WHERE Id = :contract.Id];
        Assert.areEqual('Activated', updatedContract.Status, 'Contract status should have been updated');
    }
}
