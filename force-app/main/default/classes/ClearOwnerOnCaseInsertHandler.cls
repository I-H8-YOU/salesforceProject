// public with sharing class ClearOwnerOnCaseInsertHandler {
//     public static void beforeInsert(List<Case> cases){
//         Set<Id> accountIds = new Set<Id>();
//         Account acc;
//         for(Case c : cases){
//             if(c.AccountId != null){
//                 accountIds.add(c.AccountId);
//             }
//         }
//         Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, Total_Doc__c, SLA__c  FROM Account WHERE Id IN :accountIds]);
//         if(!cases.isEmpty()){
//             for(Case cs : cases){
//                 acc = null;
//                 if(cs.Status != '완료'){
//                     if(accMap.containsKey(cs.AccountId)){
//                         acc = accMap.get(cs.AccountId);
//                         Switch on acc.SLA__c{
//                             When 'Platinum'{
//                                 cs.OwnerId = '00GgK000002odJZUAY';
//                             }
//                             When 'Gold'{
//                                 cs.OwnerId = '00GgK000002odHxUAI';
//                             }
//                             When 'Silver'{
//                                 cs.OwnerId = '00GgK000002odGLUAY';
//                             }
//                             When 'Bronze'{
//                                 cs.OwnerId = '00GgK000002ocLtUAI';
//                             }
//                             When else{
//                                 System.debug('큐 지정 오류');
//                                 cs.OwnerId = UserInfo.getUserId();
//                             }
//                         }
//                     }else{
//                         System.debug('Account 존재 오류');
//                     }
//                 }else{
//                     System.debug('Status 완료 선택 오류');
//                     return;
//                 }
//             }
//         }
//     }
// }
public with sharing class ClearOwnerOnCaseInsertHandler {
    public static void afterInsert(List<Case> cases) {
        Set<Id> accountIds = new Set<Id>();
        for (Case c : cases) {
            if (c.AccountId != null) {
                accountIds.add(c.AccountId);
            }
        }

        Map<Id, Account> accMap = new Map<Id, Account>(
            [SELECT Id, SLA__c FROM Account WHERE Id IN :accountIds]
        );

        List<Case> casesToUpdate = new List<Case>();

        for (Case cs : cases) {
            // Trigger.new 레코드 읽기 전용이므로 복사본 생성
            Case caseCopy = new Case(Id = cs.Id);

            if (cs.Status == '완료') continue;

            Account acc = accMap.get(cs.AccountId);

            if (acc == null) {
                System.debug('Account 없음: ' + cs.AccountId);
                caseCopy.OwnerId = UserInfo.getUserId();
            } else {
                switch on acc.SLA__c {
                    when '플래티넘' {
                        caseCopy.OwnerId = '00GgK000002odJZUAY';
                    }
                    when '골드' {
                        caseCopy.OwnerId = '00GgK000002odHxUAI';
                    }
                    when '실버' {
                        caseCopy.OwnerId = '00GgK000002odGLUAY';
                    }
                    when '브론즈' {
                        caseCopy.OwnerId = '00GgK000002ocLtUAI';
                    }
                    when else {
                        caseCopy.OwnerId = UserInfo.getUserId();
                    }
                }
            }
            casesToUpdate.add(caseCopy);
        }

        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
    }
}