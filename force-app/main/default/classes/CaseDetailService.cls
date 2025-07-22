public with sharing class CaseDetailService {
    @AuraEnabled(cacheable=true)
    public static CaseDTO getCaseDetail(Id caseId) {
        Case c = [
            SELECT Subject, Description, Status, Priority, Type, CreatedDate
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];
        CaseDTO dto = new CaseDTO();
        dto.Subject = c.Subject;
        dto.Description = c.Description;
        dto.Status = c.Status;
        dto.Priority = c.Priority;
        dto.Type = c.Type;
        dto.CreatedDate = String.valueOf(c.CreatedDate);
        return dto;
    }

    public class CaseDTO {
        @AuraEnabled public String Subject;
        @AuraEnabled public String Description;
        @AuraEnabled public String Status;
        @AuraEnabled public String Priority;
        @AuraEnabled public String Type;
        @AuraEnabled public String CreatedDate;
    }
}
