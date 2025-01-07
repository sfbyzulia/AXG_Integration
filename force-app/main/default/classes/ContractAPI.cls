@RestResource(urlMapping='/api/contracts/*')
global with sharing class ContractAPI {

    /**
     * Crée ou met à jour une liste de contrats en Bulk.
     * Chaque élément doit contenir les champs nécessaires pour créer ou mettre à jour un contrat.
     */
    @HttpPost
    global static List<String> createContracts() {
        RestResponse res = RestContext.response;

        // Récupérer et désérialiser le corps de la requête
        String requestBody = RestContext.request.requestBody.toString();
        Object deserializedBody = JSON.deserializeUntyped(requestBody);

        // Validation du type de l'entrée
        if (!(deserializedBody instanceof List<Object>)) {
            res.statusCode = 400; // Mauvaise requête
            res.responseBody = Blob.valueOf('{"errorCode": "INVALID_REQUEST", "message": "The request body must be a list of contract objects."}');
            return null;
        }

        List<Object> inputList = (List<Object>) deserializedBody;
        List<Map<String, Object>> contractsData = new List<Map<String, Object>>();

        // Vérification que chaque élément est un map
        for (Object item : inputList) {
            if (item instanceof Map<String, Object>) {
                contractsData.add((Map<String, Object>) item);
            } else {
                res.statusCode = 400; // Mauvaise requête
                res.responseBody = Blob.valueOf('{"errorCode": "INVALID_REQUEST", "message": "Each item in the request body must be a contract object."}');
                return null;
            }
        }

        // Validation de l'entrée
        if (contractsData.isEmpty()) {
            res.statusCode = 400; // Mauvaise requête
            res.responseBody = Blob.valueOf('{"errorCode": "MISSING_REQUIRED_FIELD", "message": "The request body must contain a list of contracts."}');
            return null;
        }

        List<String> results = new List<String>();

        for (Map<String, Object> contractData : contractsData) {
            String accountId = (String) contractData.get('accountId');
            String contractName = (String) contractData.get('contractName');
            String startDate = (String) contractData.get('startDate');
            Integer contractTerm = (Integer) contractData.get('contractTerm');

            // Validation des champs requis
            if (String.isBlank(accountId) || String.isBlank(contractName) || String.isBlank(startDate) || contractTerm == null) {
                results.add('{"errorCode": "MISSING_REQUIRED_FIELD", "message": "All required fields (accountId, contractName, startDate, contractTerm) must be provided."}');
                continue;
            }

            // Vérification de l'existence de l'accountId
            List<Account> accList = [SELECT Id FROM Account WHERE Id = :accountId LIMIT 1];
            if (accList.isEmpty()) {
                results.add('{"errorCode": "NOT_FOUND", "message": "Account not found for accountId: ' + accountId + '"}');
                continue;
            }

        // Création du contrat
        try {
            Contract newContract = new Contract(
                AccountId = accountId,
                Name = contractName,
                StartDate = Date.valueOf(startDate),
                ContractTerm = contractTerm
            );
            insert newContract;

            // Requête pour récupérer le numéro de contrat généré automatiquement
            newContract = [SELECT ContractNumber FROM Contract WHERE Id = :newContract.Id LIMIT 1];

            results.add('{"message": "Contract created successfully.", "contractNumber": "' + newContract.ContractNumber + '"}');
        } catch (Exception e) {
            results.add('{"errorCode": "INSERT_FAILED", "message": "' + e.getMessage() + '"}');
        }
        }

        return results;
    }

    @HttpPatch
    global static List<String> updateContracts() {
        RestResponse res = RestContext.response;

        // Récupérer et désérialiser le corps de la requête
        String requestBody = RestContext.request.requestBody.toString();
        Object deserializedBody = JSON.deserializeUntyped(requestBody);

        // Validation du type de l'entrée
        if (!(deserializedBody instanceof List<Object>)) {
            res.statusCode = 400; // Mauvaise requête
            res.responseBody = Blob.valueOf('{"errorCode": "INVALID_REQUEST", "message": "The request body must be a list of contract objects."}');
            return null;
        }

        List<Object> inputList = (List<Object>) deserializedBody;
        List<Map<String, Object>> contractsData = new List<Map<String, Object>>();

        // Vérification que chaque élément est un map
        for (Object item : inputList) {
            if (item instanceof Map<String, Object>) {
                contractsData.add((Map<String, Object>) item);
            } else {
                res.statusCode = 400; // Mauvaise requête
                res.responseBody = Blob.valueOf('{"errorCode": "INVALID_REQUEST", "message": "Each item in the request body must be a contract object."}');
                return null;
            }
        }

        // Validation de l'entrée
        if (contractsData.isEmpty()) {
            res.statusCode = 400; // Mauvaise requête
            res.responseBody = Blob.valueOf('{"errorCode": "MISSING_REQUIRED_FIELD", "message": "The request body must contain a list of contracts."}');
            return null;
        }

        List<String> results = new List<String>();

        for (Map<String, Object> contractData : contractsData) {
            String contractNumber = (String) contractData.get('contractNumber');
            String newStartDate = (String) contractData.get('newStartDate');
            Integer newContractTerm = (Integer) contractData.get('newContractTerm');

            // Validation des champs requis
            if (String.isBlank(contractNumber) || String.isBlank(newStartDate) || newContractTerm == null) {
                results.add('{"errorCode": "MISSING_REQUIRED_FIELD", "message": "All required fields (contractNumber, newStartDate, newContractTerm) must be provided."}');
                continue;
            }

            // Vérification de l'existence du contrat
            List<Contract> contractList = [SELECT Id, StartDate, ContractTerm FROM Contract WHERE ContractNumber = :contractNumber LIMIT 1];
            if (contractList.isEmpty()) {
                results.add('{"errorCode": "NOT_FOUND", "message": "Contract not found for contractNumber: ' + contractNumber + '"}');
                continue;
            }

            // Mise à jour du contrat
            try {
                Contract contractToUpdate = contractList[0];
                contractToUpdate.StartDate = Date.valueOf(newStartDate);
                contractToUpdate.ContractTerm = newContractTerm;
                update contractToUpdate;

                results.add('{"message": "Contract updated successfully.", "contractNumber": "' + contractToUpdate.ContractNumber + '"}');
            } catch (Exception e) {
                results.add('{"errorCode": "UPDATE_FAILED", "message": "' + e.getMessage() + '"}');
            }
        }

        return results;
    }
}
