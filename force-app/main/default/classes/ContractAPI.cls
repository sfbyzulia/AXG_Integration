@RestResource(urlMapping='/api/contracts/*')
global with sharing class ContractAPI {

    @HttpPost
    global static void createContracts() {
        RestResponse res = RestContext.response;

        // Récupérer et désérialiser le corps de la requête
        String requestBody = RestContext.request.requestBody.toString();
        Object deserializedBody = JSON.deserializeUntyped(requestBody);

        // Validation du type de l'entrée
        if (!(deserializedBody instanceof List<Object>)) {
            res.statusCode = 400; // Mauvaise requête
            res.responseBody = Blob.valueOf('{"errorCode": "INVALID_REQUEST", "message": "The request body must be a list of contract objects."}');
            return;
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
                return;
            }
        }

        // Validation de l'entrée
        if (contractsData.isEmpty()) {
            res.statusCode = 400; // Mauvaise requête
            res.responseBody = Blob.valueOf('{"errorCode": "MISSING_REQUIRED_FIELD", "message": "The request body must contain a list of contracts."}');
            return;
        }

        try {
            List<Contract> newContracts = new List<Contract>();
            for (Map<String, Object> contractData : contractsData) {
                String accountId = (String) contractData.get('accountId');
                String contractName = (String) contractData.get('contractName');
                String startDate = (String) contractData.get('startDate');
                Integer contractTerm = (Integer) contractData.get('contractTerm');

                // Validation des champs requis
                if (String.isBlank(accountId) || String.isBlank(contractName) || String.isBlank(startDate) || contractTerm == null) {
                    res.statusCode = 400; // Mauvaise requête
                    res.responseBody = Blob.valueOf('{"errorCode": "MISSING_REQUIRED_FIELD", "message": "All required fields (accountId, contractName, startDate, contractTerm) must be provided."}');
                    return;
                }

                // Vérification de l'existence de l'accountId
                List<Account> accList = [SELECT Id FROM Account WHERE Id = :accountId LIMIT 1];
                if (accList.isEmpty()) {
                    res.statusCode = 404; // Non trouvé
                    res.responseBody = Blob.valueOf('{"errorCode": "NOT_FOUND", "message": "Account not found for accountId: ' + accountId + '"}');
                    return;
                }

                // Création du contrat
                newContracts.add(new Contract(
                    AccountId = accountId,
                    Name = contractName,
                    StartDate = Date.valueOf(startDate),
                    ContractTerm = contractTerm
                ));
            }

            insert newContracts;

            // Générer une réponse pour chaque contrat créé
            List<Map<String, Object>> successResults = new List<Map<String, Object>>();
            for (Contract newContract : [SELECT Id, ContractNumber FROM Contract WHERE Id IN :newContracts]) {
                Map<String, Object> success = new Map<String, Object>();
                success.put('message', 'Contract created successfully.');
                success.put('contractNumber', newContract.ContractNumber);
                successResults.add(success);
            }

            res.statusCode = 200; // Succès
            res.responseBody = Blob.valueOf(JSON.serialize(successResults));
        } catch (Exception e) {
            res.statusCode = 500; // Erreur interne
            res.responseBody = Blob.valueOf('{"errorCode": "INSERT_FAILED", "message": "' + e.getMessage() + '"}');
        }
    }

    @HttpPatch
    global static void updateContracts() {
        RestResponse res = RestContext.response;

        // Récupérer et désérialiser le corps de la requête
        String requestBody = RestContext.request.requestBody.toString();
        Object deserializedBody = JSON.deserializeUntyped(requestBody);

        // Validation du type de l'entrée
        if (!(deserializedBody instanceof List<Object>)) {
            res.statusCode = 400; // Mauvaise requête
            res.responseBody = Blob.valueOf('{"errorCode": "INVALID_REQUEST", "message": "The request body must be a list of contract objects."}');
            return;
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
                return;
            }
        }

        // Validation de l'entrée
        if (contractsData.isEmpty()) {
            res.statusCode = 400; // Mauvaise requête
            res.responseBody = Blob.valueOf('{"errorCode": "MISSING_REQUIRED_FIELD", "message": "The request body must contain a list of contracts."}');
            return;
        }

        try {
            for (Map<String, Object> contractData : contractsData) {
                String contractNumber = (String) contractData.get('contractNumber');
                String newStartDate = (String) contractData.get('newStartDate');
                Integer newContractTerm = (Integer) contractData.get('newContractTerm');

                // Validation des champs requis
                if (String.isBlank(contractNumber) || String.isBlank(newStartDate) || newContractTerm == null) {
                    res.statusCode = 400; // Mauvaise requête
                    res.responseBody = Blob.valueOf('{"errorCode": "MISSING_REQUIRED_FIELD", "message": "All required fields (contractNumber, newStartDate, newContractTerm) must be provided."}');
                    return;
                }

                // Vérification de l'existence du contrat
                List<Contract> contractList = [SELECT Id FROM Contract WHERE ContractNumber = :contractNumber LIMIT 1];
                if (contractList.isEmpty()) {
                    res.statusCode = 404; // Non trouvé
                    res.responseBody = Blob.valueOf('{"errorCode": "NOT_FOUND", "message": "Contract not found for contractNumber: ' + contractNumber + '"}');
                    return;
                }

                // Mise à jour du contrat
                Contract contractToUpdate = contractList[0];
                contractToUpdate.StartDate = Date.valueOf(newStartDate);
                contractToUpdate.ContractTerm = newContractTerm;
                update contractToUpdate;
            }

            res.statusCode = 200; // Succès
            res.responseBody = Blob.valueOf('{"message": "All contracts updated successfully."}');
        } catch (Exception e) {
            res.statusCode = 500; // Erreur interne
            res.responseBody = Blob.valueOf('{"errorCode": "UPDATE_FAILED", "message": "' + e.getMessage() + '"}');
        }
    }
}
