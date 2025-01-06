@RestResource(urlMapping='/api/contracts/*')
global with sharing class ContractAPI {

    // Create a new contract
    @HttpPost
    global static String createContract(String accountId, String contractName, String startDate, Integer contractTerm) {
        RestResponse res = RestContext.response;

        // Validate input parameters
        if (String.isBlank(accountId) || String.isBlank(contractName) || String.isBlank(startDate) || contractTerm == null) {
            res.statusCode = 400; // Bad Request
            res.responseBody = Blob.valueOf('{"errorCode": "MISSING_REQUIRED_FIELD", "message": "All parameters are required."}');
            return null; // End processing
        }

        // Check if the account exists
        List<Account> accList = [SELECT Id FROM Account WHERE Id = :accountId LIMIT 1];
        if (accList.isEmpty()) {
            res.statusCode = 404; // Not Found
            res.responseBody = Blob.valueOf('{"errorCode": "NOT_FOUND", "message": "Account not found."}');
            return null; // End processing
        }

        // Create a new contract
        Contract newContract = new Contract(
            AccountId = accountId,
            Name = contractName,
            StartDate = Date.valueOf(startDate),
            ContractTerm = contractTerm
        );
        insert newContract;

        // Retrieve the ContractNumber after insert
        newContract = [SELECT ContractNumber FROM Contract WHERE Id = :newContract.Id LIMIT 1];

        // Return the new Contract's ContractNumber
        return newContract.ContractNumber;
    }

    // Update an existing contract by Contract Number
    @HttpPatch
    global static String updateContract(String contractNumber, String newStartDate, Integer newContractTerm) {
        RestResponse res = RestContext.response;

        // Validate input parameters
        if (String.isBlank(contractNumber) || String.isBlank(newStartDate) || newContractTerm == null) {
            res.statusCode = 400; // Bad Request
            res.responseBody = Blob.valueOf('{"errorCode": "MISSING_REQUIRED_FIELD", "message": "All parameters are required."}');
            return null; // End processing
        }

        // Query contract using Contract Number
        List<Contract> contractList = [SELECT Id, StartDate, ContractTerm FROM Contract WHERE ContractNumber = :contractNumber LIMIT 1];
        if (contractList.isEmpty()) {
            res.statusCode = 404; // Not Found
            res.responseBody = Blob.valueOf('{"errorCode": "NOT_FOUND", "message": "Contract not found."}');
            return null; // End processing
        }

        // Update contract fields
        Contract contractToUpdate = contractList[0];
        contractToUpdate.StartDate = Date.valueOf(newStartDate);
        contractToUpdate.ContractTerm = newContractTerm;
        update contractToUpdate;

        // Send success response
        res.statusCode = 200; // OK
        res.responseBody = Blob.valueOf('{"message": "Contract updated successfully."}');
        return null;
    }
}
