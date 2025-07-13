trigger CaseRequestRelatedOps on Case_Request__c (after insert) {
    if(trigger.isAfter){
        if(trigger.isInsert){
            SumitForApprovalForCaseRequest.submitForApproval(trigger.new);
        }
    }
}