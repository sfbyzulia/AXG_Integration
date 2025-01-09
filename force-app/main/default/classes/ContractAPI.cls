/**
 * REST API class to manage contracts
 * - Allows creation and updating of contracts via RESTful API methods.
 */

@RestResource(urlMapping='/api/contracts/*')
global with sharing class ContractAPI {
    @HttpPost
    global static void createContracts() {
        RestResponse res = RestContext.response;

        // Retrieve and deserialize the request body
        String requestBody = RestContext.request.requestBody.toString();
        Object deserializedBody = JSON.deserializeUntyped(requestBody);

        List<Object> inputList = (List<Object>) deserializedBody;
        List<Map<String, Object>> contractsData = new List<Map<String, Object>>();

        // Add elements to the contract data list
        for (Object item : inputList) {
            contractsData.add((Map<String, Object>) item);
        }

        List<Contract> newContracts = new List<Contract>();

        for (Map<String, Object> contractData : contractsData) {
            String accountId = (String) contractData.get('accountId');
            String contractName = (String) contractData.get('contractName');
            String startDate = (String) contractData.get('startDate');
            Integer contractTerm = (Integer) contractData.get('contractTerm');

            // Validate required fields
            if (String.isBlank(accountId) || String.isBlank(contractName) || String.isBlank(startDate) || contractTerm == null) {
                res.statusCode = 500;
                res.responseBody = Blob.valueOf('{"error": "Champ requis manquant"}');
                return;
            }

            // Verify that the Account ID exists
            List<Account> accList = [SELECT Id FROM Account WHERE Id = :accountId LIMIT 1];

            if (accList.isEmpty()) {
                res.statusCode = 500;
                res.responseBody = Blob.valueOf('{"error": "ID de compte invalide"}');
                return;
            }

            newContracts.add(new Contract(
                AccountId = accountId,
                Name = contractName,
                StartDate = Date.valueOf(startDate),
                ContractTerm = contractTerm
            ));
        }

        insert newContracts;

        res.statusCode = 200; 
        res.responseBody = Blob.valueOf('{"message": "Contrats créés avec succès."}');
    }

    @HttpPatch
    global static void updateContracts() {
        RestResponse res = RestContext.response;

        // Retrieve and deserialize the request body
        String requestBody = RestContext.request.requestBody.toString();
        Object deserializedBody = JSON.deserializeUntyped(requestBody);

        List<Object> inputList = (List<Object>) deserializedBody;
        List<Map<String, Object>> contractsData = new List<Map<String, Object>>();

        // Add elements to the contracts data list
        for (Object item : inputList) {
            contractsData.add((Map<String, Object>) item);
        }

        for (Map<String, Object> contractData : contractsData) {
            String contractNumber = (String) contractData.get('contractNumber');
            String newStartDate = (String) contractData.get('newStartDate');
            Integer newContractTerm = (Integer) contractData.get('newContractTerm');


            // Validate required fields
            if (String.isBlank(contractNumber) || String.isBlank(newStartDate) || newContractTerm == null) {
                res.statusCode = 500;
                res.responseBody = Blob.valueOf('{"error": "Champ requis manquant"}');
                return;
            }

            // Verify that the contract exists
            List<Contract> contractList = [SELECT Id FROM Contract WHERE ContractNumber = :contractNumber LIMIT 1];
            Contract contractToUpdate = contractList[0];
            contractToUpdate.StartDate = Date.valueOf(newStartDate);
            contractToUpdate.ContractTerm = newContractTerm;
            update contractToUpdate;
        }

        res.statusCode = 200; 
        res.responseBody = Blob.valueOf('{"message": "Contrats mis à jour avec succès."}');
    }
}
