trigger CaseCommentTrigger on CaseComment (after insert) {
    Set<Id> caseIds = new Set<Id>();

    for (CaseComment cc : Trigger.new) {
        if (cc.IsPublished) {
            caseIds.add(cc.ParentId);
        }
    }

    List<Case> casesToUpdate = [SELECT Id, First_Response_Date__c FROM Case WHERE Id IN :caseIds];

    for (Case c : casesToUpdate) {
        if (c.First_Response_Date__c == null) {
            c.First_Response_Date__c = System.now();
        }
    }

    update casesToUpdate;
}