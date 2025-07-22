public with sharing class RepairAssignmentService {

    @AuraEnabled(cacheable=true)
    public static List<UserRepairInfo> getAssignableUsers() {
        List<User> userList = [
            SELECT Id, Name
            FROM User
            WHERE Profile.Name = 'System Administrator' AND IsActive = true
        ];

        Map<Id, Integer> userRepairCountMap = new Map<Id, Integer>();
        for (AggregateResult ar : [
            SELECT User__c userId, COUNT(Id) cnt
            FROM Repair__c
            WHERE Repair_Status__c != '완료'
            GROUP BY User__c
        ]) {
            userRepairCountMap.put((Id)ar.get('userId'), (Integer)ar.get('cnt'));
        }

        List<UserRepairInfo> result = new List<UserRepairInfo>();
        for (User u : userList) {
            Integer currentCount = userRepairCountMap.get(u.Id);
            result.add(new UserRepairInfo(u.Id, u.Name, currentCount == null ? 0 : currentCount));
        }

        return result;
    }

    @AuraEnabled
    public static Id createRepair(Id userId, Id caseId, Id assetId) {
        if (userId == null || caseId == null || assetId == null) {
            throw new AuraHandledException('모든 필드를 입력해야 합니다.');
        }
        Case c = [Select Id, Subject
        FROM Case
        WHERE Id = :caseId];
        Repair__c repair = new Repair__c();
        repair.User__c = userId;
        repair.Case__c = caseId;
        repair.Repair_Status__c = '대기';
        repair.Name = c.Subject + ' 수리요청';

        insert repair;
        return repair.Id;
    }

    @AuraEnabled(cacheable=true)
    public static Id getCaseIdByRepair(Id repairId) {
        Repair__c r = [SELECT Case__c FROM Repair__c WHERE Id = :repairId LIMIT 1];
        return r.Case__c;
    }

    public class UserRepairInfo {
        @AuraEnabled public Id userId;
        @AuraEnabled public String userName;
        @AuraEnabled public Integer currentCount;

        public UserRepairInfo(Id id, String name, Integer count) {
            this.userId = id;
            this.userName = name;
            this.currentCount = count;
        }
    }
}
