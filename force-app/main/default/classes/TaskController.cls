// public with sharing class TaskController {
//     @AuraEnabled(cacheable = true)
//     public static List<Task> getTasks() {
//         Date today = System.today();
//         return [Select Id, Subject, Status, Priority, ActivityDate from Task where ActivityDate = :today];
//     }
// }

public with sharing class TaskController {
    // @AuraEnabled(cacheable=true)
    // public static List<Task> getTasks() {
    //     Date today = Date.today();
    //     return [
    //         SELECT Id, Subject, Status, Priority, ActivityDate, Description,
    //                CallDisposition, CallObject, What.Name
    //         FROM Task
    //         WHERE ActivityDate = :today
    //         AND OwnerId = :UserInfo.getUserId()
    //         ORDER BY ActivityDate ASC
    //     ];
    // }

    // @AuraEnabled
    // public static void completeTask(Id taskId) {
    //     Task t = [SELECT Id, Status FROM Task WHERE Id = :taskId LIMIT 1];
    //     t.Status = 'Completed';
    //     update t;
    // }

    // @AuraEnabled
    // public static void convertToCase(Id taskId) {
    //     Task t = [
    //         SELECT Id, Subject, Description, WhatId, What.Type, What.Name
    //         FROM Task
    //         WHERE Id = :taskId
    //         LIMIT 1
    //     ];
    
    //     Case newCase = new Case(
    //         Subject = t.Subject,
    //         Description = t.Description,
    //         Origin = 'Phone',
    //         Status = 'New'
    //     );
    
    //     // 예시: WhatId가 Account면 Case에 AccountId로 매핑
    //     if (t.WhatId != null && t.What.Type == 'Account') {
    //         newCase.AccountId = t.WhatId;
    //         newCase.Subject = t.What.Name + ': ' + '전화상담건';
    //     }

    //     insert newCase;
    // }
    
}