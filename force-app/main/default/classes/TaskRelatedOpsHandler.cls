public with sharing class TaskRelatedOpsHandler {

    public static void assignTaskToQueueBySLA(List<Task> newtasks) {
        Set<Id> accId = new Set<Id>();
        for (Task t : newtasks) {
            if (t.WhatId != null && String.valueOf(t.WhatId).startsWith('001')) {
                accId.add(t.WhatId);
            }
        }

        Map<Id, Account> accMap = new Map<Id, Account>(
            [SELECT Id, SLA__c FROM Account WHERE Id IN :accId]
        );

        for (Task t : newtasks) {
            if (accMap.containsKey(t.WhatId)) {
                Account acc = accMap.get(t.WhatId);
                switch on acc.SLA__c {
                    when 'Platinum' {
                        assignPlatinumTaskToAgent(new List<Task>{ t });
                       // t.OwnerId = UserInfo.getUserId();
                        // sendPlatinumNotification(t); (옵션)
                    }
                    when '골드' {
                        t.OwnerId = '00GgK000002x7fRUAQ';
                    }
                    when '실버' {
                        t.OwnerId = '00GgK000002x7h3UAA';
                    }
                    when '브론즈' {
                        t.OwnerId = '00GgK000002x7ifUAA';
                    }
                    when else {
                        System.debug('Error: Unknown SLA - ' + acc.SLA__c);
                        t.OwnerId = UserInfo.getUserId();
                    }
                }
            }
        }
    }

    public static void handleAfterTriggerEvents(List<Task> newList, List<Task> oldList) {
        Set<Id> affectedUserIds = new Set<Id>();

        if (newList != null) {
            affectedUserIds.addAll(getUserIdsFromTasks(newList));
        }
        if (oldList != null) {
            affectedUserIds.addAll(getUserIdsFromTasks(oldList));
        }

        if (!affectedUserIds.isEmpty()) {
            countOpenTasksByUser(affectedUserIds);
        }
    }

    private static Set<Id> getUserIdsFromTasks(List<Task> tasks) {
        Set<Id> userIds = new Set<Id>();
        for (Task t : tasks) {
            if (t.OwnerId != null && String.valueOf(t.OwnerId).startsWith('005')) {
                userIds.add(t.OwnerId);
            }
        }
        return userIds;
    }

    public static void countOpenTasksByUser(Set<Id> userIds) {
        AggregateResult[] results = [
            SELECT OwnerId, COUNT(Id) cnt
            FROM Task
            WHERE OwnerId IN :userIds
            AND Status != 'Completed'
            GROUP BY OwnerId
        ];

        Map<Id, Integer> taskCountByUser = new Map<Id, Integer>();
        for (AggregateResult ar : results) {
            taskCountByUser.put((Id)ar.get('OwnerId'), (Integer)ar.get('cnt'));
        }

        List<Agent_Status__c> updates = new List<Agent_Status__c>();
        for (Agent_Status__c agent : [
            SELECT Id, User__c, Task_Count__c FROM Agent_Status__c
            WHERE User__c IN :userIds
        ]) {
            Integer count = taskCountByUser.get(agent.User__c);
            agent.Task_Count__c = (count == null) ? 0 : count;
            updates.add(agent);
        }

        update updates;
    }

    public static void assignPlatinumTaskToAgent(List<Task> platTasks){
        List<Agent_Status__c> agentList = [SELECT Id, User__c, Task_Count__c 
        FROM Agent_Status__c
        WHERE Status__c = '상담가능' 
        AND User__c != null
        ORDER BY Task_Count__c ASC
        LIMIT 1];
        
        if(agentList.isEmpty()){
            System.debug('No Agent Available');
            return;
        }else{
            Id assignedUserId = agentList[0].User__c;
            for(Task t : platTasks){
                t.OwnerId = assignedUserId;
            }
        }
    }
}