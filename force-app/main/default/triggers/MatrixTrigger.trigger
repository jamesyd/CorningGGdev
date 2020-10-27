trigger MatrixTrigger on StandardProductInventoryMatrix__c (before insert, after update) {

    if (trigger.isBefore && trigger.isInsert) {
        MatrixTriggerHelper.setExternalId(trigger.new);
    }
    
    if (trigger.isAfter && trigger.isUpdate) {
        MatrixTriggerHelper.checkForChanges(trigger.New, trigger.oldMap);
        MatrixTriggerHelper.productActivation(trigger.New, trigger.oldMap);
    }

}