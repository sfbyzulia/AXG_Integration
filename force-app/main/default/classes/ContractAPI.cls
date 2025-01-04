@RestResource(urlMapping='/Contracts/*')
global with sharing class ContractAPI {
    @HttpGet
    global static Contract getContract() {
        RestRequest req = RestContext.request;
        String contractId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        Contract con = [SELECT Id, AccountId, Status FROM Contract WHERE Id = :contractId];
        return con;
    }

    @HttpPost
    global static String createContract(String accountId, String status) {
        Contract con = new Contract(AccountId = accountId, Status = status);
        insert con;
        return con.Id;
    }

    @HttpPatch
    global static void updateContract(String contractId, String status) {
        Contract con = [SELECT Id, Status FROM Contract WHERE Id = :contractId];
        con.Status = status;
        update con;
    }
}
