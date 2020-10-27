/*******************************************************************************************************
Purpose          : 
Author           : Adam Nicholson   
Revision History : 
 * *****************************************************************************************************/
global class SampleReminderScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {         
        SampleReminderBatch s = new SampleReminderBatch ();        
        database.executebatch( s );        
    }


}