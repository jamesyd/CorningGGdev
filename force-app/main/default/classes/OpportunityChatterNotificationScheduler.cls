//Scheduler class to execute OpporunityChatterNotification batch class daily
global class OpportunityChatterNotificationScheduler implements Schedulable {
    
   global void execute(SchedulableContext sc) {
      OpportunityChatterNotificationBatch b = new OpportunityChatterNotificationBatch(); 
      database.executebatch(b, 149); 
   }
}