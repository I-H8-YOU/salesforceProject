public with sharing class AgentStatusController {
    
    @AuraEnabled(cacheable=true)
    public static String getCurrentAgentStatus() {
        Agent_Status__c status = [
            SELECT Status__c 
            FROM Agent_Status__c 
            WHERE OwnerId = :UserInfo.getUserId() 
            LIMIT 1
        ];
        return status.Status__c;
    }

    @AuraEnabled
    public static void updateAgentStatus(String status) {
        if (String.isNotBlank(status)) {
            Agent_Status__c existing = [
                SELECT Id, Status__c
                FROM Agent_Status__c
                WHERE OwnerId = :UserInfo.getUserId()
                LIMIT 1
            ];

            existing.Status__c = status;
            update existing;
        } else {
            throw new AuraHandledException('상태 값이 유효하지 않습니다.');
        }
    }
}