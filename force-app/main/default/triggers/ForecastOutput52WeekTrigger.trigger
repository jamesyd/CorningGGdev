trigger ForecastOutput52WeekTrigger on ForecastOutput52Week__c (before insert, before update, after update) {
    if (trigger.isAfter && trigger.isUpdate) {                         
        ForecastOutput52WeekTriggerHelper.UpdateForecast(Trigger.new, trigger.oldMap);
        ForecastOutput52WeekTriggerHelper.updateRelatedForecast(Trigger.new, Trigger.oldMap);
    }
    if (trigger.isBefore && trigger.isInsert){
        ForecastOutput52WeekTriggerHelper.onBeforeInsert(Trigger.new);
    }
    if (trigger.isBefore && trigger.isUpdate){
        ForecastOutput52WeekTriggerHelper.onBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
}