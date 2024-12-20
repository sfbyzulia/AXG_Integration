@RestResource(urlMapping='/api/contracts/*')
global with sharing class ContractAPI {

    // Create a new Contract
    @HttpPost
    global static String createContract(String accountName, Integer contractTerm, String status) {
        // Check if the Account exists
        List<Account> existingAccounts = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
        Account account;

        if (!existingAccounts.isEmpty()) {
            account = existingAccounts[0];
        } else {
            // Create a new Account if none exists
            account = new Account(Name = accountName);
            insert account;
        }

        // Create the Contract linked to the Account
        Contract newContract = new Contract(
            AccountId = account.Id,
            ContractTerm = contractTerm,
            Status = status
        );
        insert newContract;

        return newContract.Id;
    }

    // Update an existing Contract
    @HttpPatch
    global static void updateContract(String contractId, String status) {
        // Retrieve the contract to update
        Contract contractToUpdate = [SELECT Id, Status FROM Contract WHERE Id = :contractId LIMIT 1];
        contractToUpdate.Status = status;
        update contractToUpdate;
    }
}
