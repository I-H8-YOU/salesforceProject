public with sharing class CaseEntitlementAssignment {
    public static void assignEntitlement(List<Case> cList){
        Map<Id, Entitlement> eMap = new Map<Id, Entitlement>();
        Set<Id> accIds = new Set<Id>();
        for(Case c : cList){
            if(c.AccountId != null){
                accIds.add(c.AccountId);
            }
        }
       
        for(Entitlement e :[SELECT Id, AccountId 
        FROM Entitlement
        WHERE AccountId in :accIds]){
            eMap.put(e.AccountId, e);
        }
        
        for(Case c : cList){
            if(eMap.containsKey(c.AccountId)){
                c.EntitlementId = eMap.get(c.AccountId).Id;
            }
        }
    }
}