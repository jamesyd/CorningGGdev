trigger QuoteLineItemTrigger on QuoteLineItem (after insert, after update, before insert, before update, before delete) {
    //Check the custom settings to fire this trigger
    TriggerSettings__c trigSettings = TriggerSettings__c.getInstance();    
    
    //if quote line item trigger is on
    if(trigSettings.quoteLineItem__c){ 
        //remove any auto created line items
        if (trigger.isBefore){
            if (trigger.isUpdate || trigger.isInsert) {
            	QuoteTriggerHelper.setPricingFlags(Trigger.new);
            	QuoteTriggerHelper.setSpecificationLookup(Trigger.new);
            }
            else if (trigger.isDelete){
            	QuoteTriggerHelper.preventSampleDelete(trigger.old);
            }
        }          
        else if (Trigger.isAfter){
        	if (Trigger.isInsert) {
           		QuoteTriggerHelper.handleAutoCreatedLineItems(trigger.new);
        	}
        	//check if Parts line item's price is lower than floor price
        	else if (Trigger.isUpdate){
            	QuoteTriggerHelper.checkLIPrices(Trigger.new);
        	}  
        }
    }
}