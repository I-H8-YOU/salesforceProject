public with sharing class Account360Controller {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getAccount360Info(Id recordId) {
        Map<String, Object> result = new Map<String, Object>();
        Id accountId;

        String prefix = ((String)recordId).substring(0,3);
        if (prefix != Schema.SObjectType.Case.getKeyPrefix()) {
            throw new AuraHandledException('이 컴포넌트는 케이스 페이지에서만 사용할 수 있습니다.');
        }

        try {
            Case c = [
                SELECT Id, AccountId
                FROM Case
                WHERE Id = :recordId
                LIMIT 1
            ];
            if (c.AccountId == null) {
                throw new AuraHandledException('해당 케이스에 연결된 Account가 없습니다.');
            }
            accountId = c.AccountId;
        } catch (Exception e) {
            throw new AuraHandledException('Case에서 Account를 찾을 수 없습니다.');
        }

        Account acc = [
            SELECT Id, Name, Industry, Type, SLA__c
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];
        result.put('account', acc);

        List<Contact> contacts = [
            SELECT Id, Name, Title, Email
            FROM Contact
            WHERE AccountId = :accountId
            ORDER BY LastName
        ];
        result.put('contacts', contacts);

        List<Asset> assets = [
            SELECT Id, Name, Status, Product2.Name
            FROM Asset
            WHERE AccountId = :accountId
            ORDER BY Product2.Name
        ];

        List<Map<String, String>> safeAssets = new List<Map<String, String>>();
        for (Asset a : assets) {
            safeAssets.add(new Map<String, String>{
                'Id' => a.Id,
                'Product2Name' => a.Product2 != null ? a.Product2.Name : 'N/A',
                'Status' => a.Status
            });
        }

        result.put('assets', safeAssets);
        return result;
    }
}
