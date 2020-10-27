trigger AccountContractTrigger on AccountContract__c (before Insert) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            AccountContractTriggerHelper.beforeInsert(trigger.New);
        }
    }
}