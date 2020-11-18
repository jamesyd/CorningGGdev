/**
 * @File Name          : OpportunityLineItemTrigger.trigger
 * @Description        : 
 * @Author             : Arquimidez Mora
 * @Group              : 
 * @Last Modified By   : Arquimidez Mora
 * @Last Modified On   : 28/6/2020 21:30:30
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    28/6/2020   Arquimidez Mora     Initial Version
**/
trigger OpportunityLineItemTrigger on OpportunityLineItem (before delete, before insert, before update, after insert, after update, after delete) {
    //Check the custom settings to fire this trigger
    TriggerSettings__c trigSettings = TriggerSettings__c.getInstance();    
System.debug('@@ JD OLI trigger: isInsert=' + trigger.isInsert + ' isDelete=' + trigger.isDelete + ' isUpdate=' + trigger.isUpdate);    
    if(trigSettings.opportunityLineItem__c){ 
        
        if (trigger.isBefore){
            if (trigger.isDelete){
                //OpportunityLITriggerHelper.onBeforeInsert(trigger.new); 
            }
            if (trigger.isDelete){
                OpportunityLITriggerHelper.CheckHasForecast(trigger.old);
            }
            if (trigger.isInsert || trigger.isUpdate){
                OpportunityLITriggerHelper.setSpecificationLookup(trigger.new, trigger.isInsert);
            }
        }
        else if (trigger.isAfter) {
            if (trigger.isInsert) {
System.debug('@@ JD afterInsert,  opptyId=' + trigger.new[0].OpportunityId);
                OpportunityLITriggerHelper.TransferDefaultForecast(trigger.new);
                OpportunityLITriggerHelper.onAfterInsert(trigger.new);
                OpportunityLITriggerHelper.SetOpportunityStandardFlag(trigger.new); 
                OpportunityLITriggerHelper.setSampleFulfillment(trigger.new);
            }            
            if (trigger.isUpdate) {
System.debug('@@ JD afterUpdate,  opptyId=' + trigger.new[0].OpportunityId);
                OpportunityLITriggerHelper.handleAfterUpdate(trigger.new, trigger.oldMap);
            }
            if(trigger.isDelete){
System.debug('@@ JD afterDelete,  opptyId=' + trigger.old[0].OpportunityId);
               
                OpportunityLITriggerHelper.onAfterDelete(trigger.old, trigger.oldMap);
            }
        }
    }
}