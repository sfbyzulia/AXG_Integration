@RestResource(urlMapping='/api/contracts/*')
global with sharing class ContractAPI {

    @HttpPost
    global static String createContract(String accountId, Integer contractTerm, String status) {
        Contract newContract = new Contract(
            AccountId = accountId,
            ContractTerm = contractTerm,
            Status = status
        );
        insert newContract;
        return newContract.Id;
    }

    @HttpPatch
    global static void updateContract(String contractId, String status) {
        Contract contractToUpdate = [SELECT Id, Status FROM Contract WHERE Id = :contractId LIMIT 1];
        contractToUpdate.Status = status;
        update contractToUpdate;
    }
}
