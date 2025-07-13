public class MilestoneUtils {
    public static void completeMilestone(List<Id> caseIds, String milestoneName, DateTime complDate) {
        List<CaseMilestone> cmsToUpdate = [
            SELECT Id, CompletionDate, MilestoneType.Name
            FROM CaseMilestone
            WHERE CaseId IN :caseIds
              AND MilestoneType.Name = :milestoneName
              AND CompletionDate = NULL
        ];

        if (!cmsToUpdate.isEmpty()) {
            DateTime adjustedTime = complDate.addMinutes(-1); // 1분 앞당김 Platinum Closed시 Violation때문

            for (CaseMilestone cm : cmsToUpdate) {
                cm.CompletionDate = adjustedTime;
            }

            try {
                update cmsToUpdate;
            } catch (DmlException e) {
                System.debug('Failed to complete milestones: ' + e.getMessage());
            }
        } else {
            System.debug('No active milestones to complete for: ' + milestoneName);
        }
    }
}