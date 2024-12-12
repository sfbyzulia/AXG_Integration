@isTest
public class ContractAPITest {

    @isTest 
    static void testCreateNewOpportunity() {
        String opportunityName = 'New Opportunity';
        Integer contractTerm = 12;
        String status = 'Draft';
    
        String contractId = ContractAPI.createContract(opportunityName, contractTerm, status);
    
        update new Contract(Id = contractId, Status = 'Activated');
    
        // Verify the contract details
        Contract createdContract = [SELECT Id, ContractTerm, Status FROM Contract WHERE Id = :contractId LIMIT 1];
        Assert.isNotNull(createdContract, 'Contract should be created');
        Assert.areEqual(contractTerm, createdContract.ContractTerm, 'Contract term should match');
        Assert.areEqual('Activated', createdContract.Status, 'Status should match');
    }    

    @isTest 
    static void testExistingOpportunity() {
        Account account = new Account(Name = 'Test Account');
        insert account;

        Opportunity opportunity = new Opportunity(
            Name = 'Existing Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = account.Id
        );
        insert opportunity;

        Integer contractTerm = 24;
        String status = 'Activated';

        String contractId = ContractAPI.createContract(opportunity.Name, contractTerm, status);

        Contract createdContract = [SELECT Id, ContractTerm, Status FROM Contract WHERE Id = :contractId LIMIT 1];
        Assert.isNotNull(createdContract, 'Contract should be created');
        Assert.areEqual(contractTerm, createdContract.ContractTerm, 'Contract term should match');
        Assert.areEqual('Activated', createdContract.Status, 'Status should match');

        Opportunity updatedOpportunity = [SELECT Id, ContractId FROM Opportunity WHERE Id = :opportunity.Id];
        Assert.areEqual(createdContract.Id, updatedOpportunity.ContractId, 'Opportunity should be linked to the new contract');
    }

    @isTest 
    static void testUpdateContract() {
        Account account = new Account(Name = 'Test Account');
        insert account;

        Contract contract = new Contract(
            AccountId = account.Id,
            ContractTerm = 6,
            Status = 'Draft'
        );
        insert contract;

        String newStatus = 'Activated';

        ContractAPI.updateContract(contract.Id, newStatus);

        Contract updatedContract = [SELECT Id, Status FROM Contract WHERE Id = :contract.Id];
        Assert.areEqual(newStatus, updatedContract.Status, 'Contract status should be updated');
    }
}
