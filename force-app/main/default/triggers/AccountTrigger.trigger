///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 3/27/2017 ***///
 trigger AccountTrigger on Account (before delete, after update) {
    //Check the custom settings to fire this trigger
    TriggerSettings__c trigSettings = TriggerSettings__c.getInstance(); 
    
    if(trigSettings.account__c){ 
        if (trigger.isBefore) {
            if (trigger.isDelete){
                AccountTriggerHelper.CheckContainsPricing(trigger.old);
            }
        }
    }
    if(Trigger.isUpdate && Trigger.isAfter){
        AccountTriggerHelper.updatePriceOwner(Trigger.new, Trigger.oldmap);
        //AccountTriggerHelper.updateTripVisitReportOwner(Trigger.new, Trigger.oldmap);
    }
}