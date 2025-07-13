public with sharing class CaseCountOnAgentStatusHandler {

    // public static void countCases(List<Case> cases, Map<Id, Case> oldCases) {
    //     if (CaseTriggerHandlerHelper.hasRun) return;
    //     CaseTriggerHandlerHelper.hasRun = true;

    //     Set<Id> agentIds = new Set<Id>();
    //     Set<Id> accIds = new Set<Id>();
    //     List<Case> caseToUpdateEntitlementIds = new List<Case>();

    //     for (Case cs : cases) {
    //         if (cs.AccountId != null) accIds.add(cs.AccountId);
    //         if (cs.Case_Handler__c != null) agentIds.add(cs.Case_Handler__c);
    //     }

    //     Map<Id, Account> accountMap = new Map<Id, Account>(
    //         [SELECT Id, SLA__c FROM Account WHERE Id IN :accIds]
    //     );

    //     List<Entitlement> entList = [
    //         SELECT Id, AccountId, Status
    //         FROM Entitlement
    //         WHERE AccountId IN :accIds AND Status = 'Active'
    //     ];

    //     Map<String, Map<Id, Entitlement>> entBySlaAndAcc = new Map<String, Map<Id, Entitlement>>();
    //     for (Entitlement ent : entList) {
    //         String sla = accountMap.get(ent.AccountId).SLA__c;
    //         if (!entBySlaAndAcc.containsKey(sla)) {
    //             entBySlaAndAcc.put(sla, new Map<Id, Entitlement>());
    //         }
    //         entBySlaAndAcc.get(sla).put(ent.AccountId, ent);
    //     }

    //     for (Case cs : cases) {
    //         Account acc = accountMap.get(cs.AccountId);
    //         if (acc != null && entBySlaAndAcc.containsKey(acc.SLA__c)) {
    //             Entitlement ent = entBySlaAndAcc.get(acc.SLA__c).get(acc.Id);
    //             if (ent != null) {
    //                 caseToUpdateEntitlementIds.add(
    //                     new Case(Id = cs.Id, EntitlementId = ent.Id)
    //                 );
    //             }
    //         }
    //     }

    //     if (!caseToUpdateEntitlementIds.isEmpty() &&
    //         Schema.SObjectType.Case.fields.EntitlementId.isUpdateable()) {
    //         update caseToUpdateEntitlementIds;
    //     }

    //     if (oldCases != null) {
    //         for (Case oldCase : oldCases.values()) {
    //             if (oldCase.Case_Handler__c != null) {
    //                 agentIds.add(oldCase.Case_Handler__c);
    //             }
    //         }
    //     }

    //     List<Agent_Status__c> agentsWithCases = [
    //         SELECT Id, (SELECT Id FROM Cases__r)
    //         FROM Agent_Status__c
    //         WHERE Id IN :agentIds
    //     ];

    //     List<Agent_Status__c> agentsToUpdate = new List<Agent_Status__c>();
    //     for (Agent_Status__c agent : agentsWithCases) {
    //         agent.Case_Count__c = agent.Cases__r.size();
    //         agentsToUpdate.add(agent);
    //     }

    //     if (!agentsToUpdate.isEmpty()) {
    //         update agentsToUpdate;
    //     }
    // }

    // public static void deleteCount(List<Case> cases) {
    //     Set<Id> agentIds = new Set<Id>();
    //     for (Case cs : cases) {
    //         if (cs.Case_Handler__c != null) {
    //             agentIds.add(cs.Case_Handler__c);
    //         }
    //     }

    //     List<Agent_Status__c> agentsWithCases = [
    //         SELECT Id, (SELECT Id FROM Cases__r)
    //         FROM Agent_Status__c
    //         WHERE Id IN :agentIds
    //     ];

    //     List<Agent_Status__c> agentsToUpdate = new List<Agent_Status__c>();
    //     for (Agent_Status__c agent : agentsWithCases) {
    //         agent.Case_Count__c = agent.Cases__r.size();
    //         agentsToUpdate.add(agent);
    //     }

    //     if (!agentsToUpdate.isEmpty()) {
    //         update agentsToUpdate;
    //     }
    // }
}