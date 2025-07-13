trigger CaseRelatedOps on Case (before insert, before update, before delete,
                                after insert, after update, after delete) {
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            CaseEntitlementAssignment.assignEntitlement(Trigger.new);
        } else if (Trigger.isUpdate) {
            CaseMilestoneHandler.handleMilestoneCompletion(Trigger.new, Trigger.oldMap);
        } else if (Trigger.isDelete) {
            // Delete 시점 before 핸들러
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            ClearOwnerOnCaseInsertHandler.afterInsert(Trigger.new);
            //CaseCountOnAgentStatusHandler.countCases(Trigger.new, null);
        } else if (Trigger.isUpdate) {
            //CaseCountOnAgentStatusHandler.countCases(Trigger.new, Trigger.oldMap);
        } else if (Trigger.isDelete) {
            //CaseCountOnAgentStatusHandler.deleteCount(Trigger.old);
        }
    }
}