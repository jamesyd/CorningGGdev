///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 3/16/2017 ***///
trigger SampleFulfillmentTrigger on SampleFulfillment__c (before insert, before update, after insert, after update) {
   TriggerSettings__c trigSettings = TriggerSettings__c.getInstance();    
    
    //if Sample Fulfillment trigger is on
    if(trigSettings.SampleFulfillment__c){ 
        if (trigger.isBefore){ //Insert or Update
            SampleFulfillmentHelper.checkSampleQuantities(trigger.new);
            // SampleFulfillmentHelper.setShippingAddress(trigger.new); // AN - 8/7/18 move shipping to SR
            SampleFulfillmentHelper.setSpecification(trigger.new);
        }
        if (trigger.isBefore && trigger.isInsert) {        
            SampleFulfillmentHelper.onBeforeInsert(trigger.new);
        }
        
        if (trigger.isBefore && trigger.isUpdate) { // Update Only        
            SampleFulfillmentHelper.setOriginalCommitDate(trigger.new, trigger.oldmap);      
            SampleFulfillmentHelper.setLocationAssignmentDate(trigger.new, trigger.oldmap);
            //update status if commit date is set or ship date is set but the status is not updated with it 
            SampleFulfillmentHelper.updateStatus(trigger.new, trigger.oldMap);        
            SampleFulfillmentHelper.onBeforeUpdate(trigger.new, trigger.oldmap);
        }
        
        if (trigger.isAfter){ //Insert or Update
            SampleFulfillmentHelper.setOpportunityStage(trigger.new);
            
        }
        
        if (trigger.isAfter && trigger.isInsert) {        
            SampleFulfillmentHelper.onAfterInsert(trigger.new);
        }
        
        if (trigger.isAfter && trigger.isUpdate) { // Update Only        
            SampleFulfillmentHelper.onAfterUpdate(trigger.new, trigger.oldmap);
        }
    }
}