public with sharing class AICaseController {
    @AuraEnabled
    public static AICaseResult generateCaseDetails(String customerName, String issueDescription) {
        String firstName = customerName.length() > 1 ? customerName.substring(1) : '';
        String lastName = customerName.substring(0, 1);

        Contact c = [
            SELECT Id, AccountId, Account.Name 
            FROM Contact 
            WHERE FirstName = :firstName AND LastName = :lastName 
            LIMIT 1
        ];

        List<Asset> assets = [
            SELECT Name 
            FROM Asset 
            WHERE AccountId = :c.AccountId
        ];
        List<String> assetNames = new List<String>();
        for (Asset a : assets) {
            assetNames.add(a.Name);
        }
        String assetList = String.join(assetNames, '\n');

        Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>{
            'Input:customer_name' => wrap(customerName),
            'Input:description' => wrap(issueDescription),
            'Input:account_name' => wrap(c.Account.Name),
            'Input:asset_list' => wrap(assetList)
        };

        // Prompt 호출 파라미터 설정
        ConnectApi.EinsteinPromptTemplateGenerationsInput input = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        input.inputParams = inputParams;
        input.isPreview = false;
        input.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
        input.additionalConfig.applicationName = 'PromptBuilderPreview';

        try {
            // Prompt 호출
            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation response =
                ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate('Case_Generation_With_Prompt', input);

            if (response.generations.isEmpty()) {
                throw new AuraHandledException('⚠️ LLM 응답이 비어 있습니다. Prompt 설정 또는 입력값을 확인하세요.');
            }

            String json = response.generations[0].text;
            System.debug('== LLM JSON 응답 ==\n' + json);

            Map<String, Object> parsed = (Map<String, Object>) System.JSON.deserializeUntyped(json);

            AICaseResult result = new AICaseResult();
            result.contactId = c.Id;
            result.accountId = c.AccountId;
            result.subject = (String) parsed.get('subject');
            result.description = (String) parsed.get('description');
            result.assetName = (String) parsed.get('asset_name');
            return result;
        } catch (Exception e) {
            System.debug('🔥 AI 케이스 생성 중 오류: ' + e.getMessage());
            throw new AuraHandledException('AI 분석 중 문제가 발생했습니다. 관리자에게 문의해주세요.');
        }
    }

    @AuraEnabled
    public static List<IdNameWrapper> getAssetsByAccountId(Id accountId) {
        List<Asset> assets = [SELECT Id, Name FROM Asset WHERE AccountId = :accountId];
        List<IdNameWrapper> result = new List<IdNameWrapper>();
        for (Asset a : assets) {
            result.add(new IdNameWrapper(a.Id, a.Name));
        }
        return result;
    }

    private static ConnectApi.WrappedValue wrap(String value) {
        ConnectApi.WrappedValue w = new ConnectApi.WrappedValue();
        w.value = value;
        return w;
    }

    public class AICaseResult {
        @AuraEnabled public String contactId;
        @AuraEnabled public String accountId;
        @AuraEnabled public String subject;
        @AuraEnabled public String description;
        @AuraEnabled public String assetName;
    }

    public class IdNameWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        public IdNameWrapper(Id id, String name) {
            this.id = id;
            this.name = name;
        }
    }
}