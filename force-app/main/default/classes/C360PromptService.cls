public with sharing class C360PromptService {

    @AuraEnabled
    public static Map<String, String> generateC360Summary(String formattedName) {
        if (String.isBlank(formattedName)) {
            throw new AuraHandledException('고객 이름이 누락되었습니다.');
        }

        List<String> nameParts = formattedName.split(' ');
        if (nameParts.size() != 2) {
            throw new AuraHandledException('이름 형식이 올바르지 않습니다.');
        }

        String firstName = nameParts[0];
        String lastName = nameParts[1];

        // Contact 조회
        Contact contact = [
            SELECT Id, FirstName, LastName, MobilePhone, AccountId, Phone, Email
            FROM Contact
            WHERE FirstName = :firstName AND LastName = :lastName
            LIMIT 1
        ];

        // Account 조회
        Account acct = [
            SELECT Id, Name, BillingCity, BillingStreet, Account_Code__c
            FROM Account
            WHERE Id = :contact.AccountId
            LIMIT 1
        ];

        // Asset 조회
        List<Asset> assetList = [
            SELECT Name, Status
            FROM Asset
            WHERE AccountId = :acct.Id
            LIMIT 5
        ];

        // Case 조회
        List<Case> recentCases = [
            SELECT Subject, Status, CreatedDate
            FROM Case
            WHERE ContactId = :contact.Id
            ORDER BY CreatedDate DESC
            LIMIT 5
        ];

        // 텍스트 조립
        String customerSummary = String.join(new List<String>{
            '- 이름: ' + contact.FirstName + ' ' + contact.LastName,
            '- 연락처: ' + (contact.Phone != null ? contact.Phone : '제공되지 않음'),
            '- 이메일: '+ (contact.Email != null ? contact.Email : '제공되지 않음')
        }, '\n');

        String accountSummary = String.join(new List<String>{
            '- 병원명: ' + acct.Name,
            '- 병원 규모: ' + (acct.Account_Code__c != null ? acct.Account_Code__c : '없음'),
            '- 주소: ' +
                (acct.BillingCity != null ? acct.BillingCity + ' ' : '') +
                (acct.BillingStreet != null ? acct.BillingStreet : '주소 없음')
        }, '\n');

        List<String> caseLines = new List<String>();
        for (Case c : recentCases) {
            caseLines.add('- ' + c.Subject + ' (' + c.Status + ', ' + String.valueOf(c.CreatedDate.date()) + ')');
        }
        String caseSummary = String.join(caseLines, '\n');

        List<String> assetLines = new List<String>();
        for (Asset a : assetList) {
            assetLines.add('- ' + a.Name + ' (' + a.Status + ')');
        }
        String assetSummary = String.join(assetLines, '\n');

        // LLM Prompt 호출 준비
        Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>{
            'Input:customerSection' => wrap(customerSummary),
            'Input:accountSection'  => wrap(accountSummary),
            'Input:caseSection'     => wrap(caseSummary),
            'Input:assetSection'    => wrap(assetSummary)
        };

        ConnectApi.EinsteinPromptTemplateGenerationsInput input = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        input.inputParams = inputParams;
        input.isPreview = false;
        input.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
        input.additionalConfig.applicationName = 'PromptBuilderPreview';

        try {
            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation response =
                ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate('Customer_Summary_Gen', input);

            if (response.generations.isEmpty()) {
                throw new AuraHandledException('⚠️ LLM 응답이 비어 있습니다.');
            }

            String json = response.generations[0].text;
            System.debug('📨 LLM 응답 JSON: ' + json);

            Map<String, Object> parsed = (Map<String, Object>) System.JSON.deserializeUntyped(json);

            return new Map<String, String>{
               
                'customerSection' => ((String) parsed.get('customerSection')).replace('\n', '<br/>'),
                'accountSection'  => ((String) parsed.get('accountSection')).replace('\n', '<br/>'),
                'caseSection'     => ((String) parsed.get('caseSection')).replace('\n', '<br/>'),
                'assetSection'    => ((String) parsed.get('assetSection')).replace('\n', '<br/>')
            };
        } catch (Exception e) {
            System.debug(' 요약 실패: ' + e.getMessage());
            throw new AuraHandledException('요약 정보를 생성하는 중 오류가 발생했습니다.');
        }
    }

    @AuraEnabled
    public static C360DataResult getContactRelatedRecords(String formattedName) {
        if (String.isBlank(formattedName)) {
            throw new AuraHandledException('고객 이름이 누락되었습니다.');
        }

        List<String> nameParts = formattedName.split(' ');
        if (nameParts.size() != 2) {
            throw new AuraHandledException('이름 형식이 올바르지 않습니다.');
        }

        String firstName = nameParts[0];
        String lastName = nameParts[1];

        Contact contact = [
            SELECT Id, AccountId
            FROM Contact
            WHERE FirstName = :firstName AND LastName = :lastName
            LIMIT 1
        ];

        List<Case> caseList = [
            SELECT Id, Subject, Description, Status, CreatedDate
            FROM Case
            WHERE ContactId = :contact.Id
            ORDER BY CreatedDate DESC
            LIMIT 5
        ];

        List<Asset> assetList = [
            SELECT Id, Name, SerialNumber, Status, InstallDate
            FROM Asset
            WHERE AccountId = :contact.AccountId
            LIMIT 5
        ];

        C360DataResult result = new C360DataResult();
        result.contactId = contact.Id;
        result.accountId = contact.AccountId;
        result.cases = caseList;
        result.assets = assetList;
        return result;
    }

    // 🔹 반환용 클래스
    public class C360DataResult {
        @AuraEnabled public Id contactId;
        @AuraEnabled public Id accountId;
        @AuraEnabled public List<Case> cases;
        @AuraEnabled public List<Asset> assets;
    }

    // 🔹 Prompt input 포맷용 wrap 함수
    private static ConnectApi.WrappedValue wrap(String value) {
        ConnectApi.WrappedValue w = new ConnectApi.WrappedValue();
        w.value = value;
        return w;
    }
}
