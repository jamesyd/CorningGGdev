///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 2/5/2017 ***///
trigger SpecificationTrigger on Specification__c (before insert, before update, after insert, after update) {
    //Check the custom settings to fire this trigger
    TriggerSettings__c trigSettings = TriggerSettings__c.getInstance();    
    
    //if spec trigger is on
    if(trigSettings.specification__c){ 
        
        if (trigger.isBefore) {
            
            //can the spec records in the trigger edited by the current user?
            SpecificationTriggerHelper.validateEditAccessToSpecifications(trigger.New);
            SpecificationTriggerHelper.validateReadyForSubmit(trigger.New);
            
            if (trigger.isInsert) {
                SpecificationTriggerHelper.setVersionNumber(trigger.New);
                SpecificationTriggerHelper.onBeforeInsert(trigger.New);
            } else if (trigger.isUpdate) {
                SpecificationTriggerHelper.onBeforeUpdate(trigger.New, trigger.oldMap);
                SpecificationTriggerHelper.checkAndLoadRFI(trigger.New);
                SpecificationTriggerHelper.setFieldsFromStatusChanges(trigger.New, trigger.oldMap);               
                SpecificationTriggerHelper.setRiskAssessment(trigger.newMap);
                 
                    if (!Test.IsRunningTest()) {
                        StepDurationLogger.LogSpecificationStep(trigger.new, trigger.oldMap); 
                        SpecificationTriggerHelper.createProductAndPricebookEntry(trigger.New, trigger.oldMap);
                    }
                    
            }   
        }
        
        if (trigger.isAfter && trigger.isUpdate) {        
            ChatterHelper.followSpecification(trigger.new);
            ChatterHelper.specificationNotification(trigger.new, Trigger.oldmap);
            ChatterHelper.unFollowSpecification(trigger.new);
            SpecificationTriggerHelper.onAfterUpdate(trigger.new, Trigger.oldmap);
            //SpecificationTriggerHelper.sendNotificationToTPM(trigger.new, Trigger.oldmap);
        }
        
    }
}