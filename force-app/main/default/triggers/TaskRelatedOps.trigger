trigger TaskRelatedOps on Task (
    before insert, before update, before delete,
    after insert, after update, after delete
) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            TaskRelatedOpsHandler.assignTaskToQueueBySLA(Trigger.new);
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            TaskRelatedOpsHandler.handleAfterTriggerEvents(Trigger.new, Trigger.old);
        } else if (Trigger.isDelete) {
            TaskRelatedOpsHandler.handleAfterTriggerEvents(null, Trigger.old);
        }
    }
}