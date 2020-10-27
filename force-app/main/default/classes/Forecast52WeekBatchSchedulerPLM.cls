/*******************************************************************************************************
Purpose          : 
Author           : Adam Nicholson   
Revision History : 
 * *****************************************************************************************************/
global class Forecast52WeekBatchSchedulerPLM implements Schedulable {
    
    global void execute(SchedulableContext sc) {         
        Forecast52WeekBatch s = new Forecast52WeekBatch ('Locked');        
        database.executebatch( s );        
    }


}