///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 3/14/2017 ***///
trigger PriceTrigger on Price__c (before insert, before update) {
    TriggerSettings__c trigSettings = TriggerSettings__c.getInstance();    
    
    //if price trigger is on
    if(trigSettings.Price__c){ 
        if (trigger.isBefore) {
            if (trigger.isInsert || trigger.isUpdate){
                //Set Available_To value for blue Accounts
                PriceTriggerHelper.setAvailableTo(trigger.New); 
                PriceTriggerHelper.setSpecPricing(trigger.New);
                PriceTriggerHelper.setIsMTO(trigger.New);  
            }
        }
    }
}