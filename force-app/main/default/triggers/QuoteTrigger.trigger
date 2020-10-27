///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 2/7/2017 ***///
trigger QuoteTrigger on Quote (before insert, after insert, before update, after update) {
    //Check the custom settings to fire this trigger
    TriggerSettings__c trigSettings = TriggerSettings__c.getInstance();    
    
    //if opty trigger is on
    if(trigSettings.quote__c){ 
    
        if (trigger.isBefore) {
            //validate that Blue Quote is English Only
            QuoteTriggerHelper.checkBlueLanguageAndEntity(trigger.new); 
            
            //when inserting new quote
            if (trigger.isInsert){
                //set default price book for Gorilla Glass
                QuoteTriggerHelper.setGGPriceBook(trigger.new);
            }
            if (trigger.isUpdate){
                QuoteTriggerHelper.validateWonOpportunity(trigger.new);
                QuoteTriggerHelper.checkIfStageCanbeDraft(trigger.new, trigger.oldMap);
            }
        }
        
        if (trigger.isAfter) {
            if(Trigger.isInsert) {
                QuoteTriggerHelper.handleNewQuote(trigger.new);
                QuoteTriggerHelper.onAfterInsert(trigger.new);
            }
            if (trigger.isUpdate){
                QuoteTriggerHelper.setSampleOpportunityStage(trigger.new, trigger.oldMap);
                QuoteTriggerHelper.setOpportunityStageAndPriceExpiration(trigger.new, trigger.oldMap);
                QuoteTriggerHelper.onAfterUpdate(trigger.new, trigger.oldMap);
            }  
        }        
    }
}