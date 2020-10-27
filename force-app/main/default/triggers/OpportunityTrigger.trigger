///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 2/7/2017 ***///
///*** AN - 3/27 - Added 'after update' and trigger.isAfter code
trigger OpportunityTrigger on Opportunity (before insert, before update, after update) {
    //Check the custom settings to fire this trigger
    TriggerSettings__c trigSettings = TriggerSettings__c.getInstance();    
    
    //if opty trigger is on
    if(trigSettings.opportunity__c) { 
    
        if (trigger.isBefore) {
                        
            if (trigger.isInsert) {
                OpportunityTriggerHelper.setGGPriceBook(trigger.New);   
                OpportunityTriggerHelper.validateCreateAccessSampleRequest(trigger.New); // only program opty owners/team members can create sample optys
                OpportunityTriggerHelper.updateShipToContactAddress(trigger.New);
            }
            
            if (trigger.isUpdate) {               
                OpportunityTriggerHelper.updateOppAttributes(trigger.New, trigger.oldMap); // AN - 7/23/18 - track when the stage changes, setPreviousOwnerID, roll-up fulfillment and product data for email                
                OpportunityTriggerHelper.onBeforeUpdate(trigger.new, Trigger.oldmap);
                if (!Test.IsRunningTest()) {
                    ChatterHelperOpportunities.atMentionNew(trigger.new);
                }
                OpportunityTriggerHelper.onBeforeUpdate(trigger.new, Trigger.oldmap);
                StepDurationLogger.LogOpportunityStep(trigger.new, trigger.oldMap);                
            }
               
        }
        
        if (trigger.isAfter) {  
                 

            if(trigger.isUpdate) {
                OpportunityTriggerHelper.afterUpdate(trigger.new, Trigger.oldmap);
                OpportunityTriggerHelper.createDefaultOLIForecast(trigger.new, Trigger.oldmap); //AN 11-28-2018            
                OpportunityTriggerHelper.createSampleQuote(trigger.new, trigger.oldMap); //MP 4-7-2017   
                ChatterHelperSamples.followSample(trigger.new);
                ChatterHelperSamples.sampleNotification(trigger.new, Trigger.oldmap);
                ChatterHelperSamples.unFollowSample(trigger.new);
                //ChatterHelperSamples.sendApprovalNotification(trigger.new, Trigger.oldmap);
                OpportunityTriggerHelper.sendEmailNotification(trigger.new, Trigger.oldmap);
                 
                if (!checkRecursive.runOnce()) {
                    if (!Test.IsRunningTest()) {
                        ChatterHelperOpportunities.atMentionEdits(trigger.new, Trigger.oldmap);
                    }
                    //AsyncOppotunityTeam.processOpportunities(Trigger.newMap.keySet());                    
                }
            }
        }
                
    }
}