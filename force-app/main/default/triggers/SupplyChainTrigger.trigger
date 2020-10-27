///*** Added for Gorilla Glass Implementation ***///
///*** Corning - 3/13/2017 ***///

trigger SupplyChainTrigger on SupplyChain__c (after insert, after update) {
    //Check the custom settings to fire this trigger
    TriggerSettings__c trigSettings = TriggerSettings__c.getInstance();    
    
    //if spec trigger is on
    if(trigSettings.supplychain__c){ 
        
        if (trigger.isAfter) {
                SupplyChainTriggerHelper.setOppTeam(trigger.New);
        }
        
    }
}