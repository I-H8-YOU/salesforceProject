public class CaseMilestoneHandler {
    private static final Map<String, List<String>> milestoneMap = new Map<String, List<String>>{
        'New' => new List<String>{'First Response - Platinum Support', 'First Response - Silver Support', 'First Response - Bronze Support', 'First Response - Endoscope Support'},
        'Working' => new List<String>{'In Progress - Platinum Support', 'In Progress - Silver Support', 'In Progress - Bronze Support', 'In Progress - Endoscope Support'},
        'Escalated' => new List<String>{'Escalation - Platinum Support', 'Escalation - Silver Support', 'Escalation - Bronze Support','Escalation - Endoscope Support'},
        'Closed' => new List<String>{'Completion - Platinum Support (Optional)', 'Completion - Silver Support', 'Completion - Bronze Support', 'Case Closure - Endoscope Support'}
    };

    public static void handleMilestoneCompletion(List<Case> newList, Map<Id, Case> oldMap) {
        DateTime now = System.now();
        Map<String, Set<Id>> milestoneToCaseIds = new Map<String, Set<Id>>();

        for (Case c : newList) {
            if (!oldMap.containsKey(c.Id)) continue;

            Case oldCase = oldMap.get(c.Id);
            if (c.Status == oldCase.Status) continue;

            List<String> milestoneNames = new List<String>();

            if (oldCase.Status == 'New' && (c.Status == 'Working' || c.Status == 'Escalated')) {
                milestoneNames.addAll(milestoneMap.get('New'));
            }
            if (oldCase.Status == 'Working' && (c.Status == 'Escalated' || c.Status == 'Closed')) {
                milestoneNames.addAll(milestoneMap.get('Working'));
            }
            if (oldCase.Status == 'Escalated' && c.Status == 'Closed') {
                milestoneNames.addAll(milestoneMap.get('Escalated'));
            }
            if (c.Status == 'Closed') {
                milestoneNames.addAll(milestoneMap.get('Closed'));
            }

            for (String milestoneName : milestoneNames) {
                if (!milestoneToCaseIds.containsKey(milestoneName)) {
                    milestoneToCaseIds.put(milestoneName, new Set<Id>());
                }
                milestoneToCaseIds.get(milestoneName).add(c.Id);
            }
        }

        for (String milestoneName : milestoneToCaseIds.keySet()) {
            Set<Id> caseIds = milestoneToCaseIds.get(milestoneName);
            if (!caseIds.isEmpty()) {
                MilestoneUtils.completeMilestone(new List<Id>(caseIds), milestoneName, now);
            }
        }
    }
}