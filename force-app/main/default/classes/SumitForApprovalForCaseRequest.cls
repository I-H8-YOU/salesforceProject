public with sharing class SumitForApprovalForCaseRequest {
    public static void submitForApproval(List<Case_Request__c> cList){
        List<Approval.ProcessSubmitRequest> approvalRequests = new List<Approval.ProcessSubmitRequest>();
        for(Case_Request__c cr : cList){
            if (chkForStatus(cr)) {
                Approval.ProcessSubmitRequest reqApproval = new Approval.ProcessSubmitRequest();
                reqApproval.setObjectId(cr.Id);
                reqApproval.setSubmitterId(UserInfo.getUserId());
                approvalRequests.add(reqApproval);
            }
        }

        for (Approval.ProcessSubmitRequest apr : approvalRequests) {
            try {
                Approval.ProcessResult result = Approval.process(apr);
                System.debug('Approval submitted: ' + result.isSuccess());
            } catch (Exception e) {
                System.debug('Approval submission failed: ' + e.getMessage());
            }
        }
    }

    private static boolean chkForStatus(Case_Request__c cr){
        if(cr.Status__c == '요청됨'){
            return true;
        }else{
            return false;
        }
    }
}