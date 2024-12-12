@RestResource(urlMapping='/api/contracts/*')
global with sharing class ContractAPI {

    @HttpPost
    global static String createContract(String opportunityName, Integer contractTerm, String status) {
        // Check if the Opportunity exists
        List<Opportunity> existingOpportunities = [SELECT Id, AccountId FROM Opportunity WHERE Name = :opportunityName LIMIT 1];
        Opportunity opportunity;

        if (!existingOpportunities.isEmpty()) {
            opportunity = existingOpportunities[0];
        } else {
            // Create a new Account for the new Opportunity
            Account account = new Account(Name = 'Default Account');
            insert account;

            opportunity = new Opportunity(
                Name = opportunityName,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                AccountId = account.Id
            );
            insert opportunity;
        }

        // Create the Contract linked to the Opportunity's Account
        Contract newContract = new Contract(
            AccountId = opportunity.AccountId, 
            ContractTerm = contractTerm,
            Status = 'Draft'
        );
        insert newContract;
        newContract.Status = 'Activated';
        update newContract;        

        // Update the Opportunity with the new Contract's ID
        opportunity.ContractId = newContract.Id;
        update opportunity;

        return newContract.Id;
    }

    @HttpPatch
    global static void updateContract(String contractId, String status) {
        // Retrieve the contract to update
        Contract contractToUpdate = [SELECT Id, Status FROM Contract WHERE Id = :contractId LIMIT 1];
        contractToUpdate.Status = status;
        update contractToUpdate;
    }
}
