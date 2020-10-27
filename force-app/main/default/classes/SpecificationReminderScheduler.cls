/*******************************************************************************************************
Purpose          : 
Author           : Adam Nicholson   
Revision History : 
 * *****************************************************************************************************/
global class SpecificationReminderScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {        
        SpecificationReminderBatch s = new SpecificationReminderBatch ();        
        database.executebatch( s );        
    }


}