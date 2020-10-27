/*******************************************************************************************************
Purpose          : 
Author           : Adam Nicholson   
Revision History : 
 * *****************************************************************************************************/
global class Forecast52WeekBatchSchedulerOEM implements Schedulable {
    
    global void execute(SchedulableContext sc) {         
        Forecast52WeekBatch s = new Forecast52WeekBatch ('Active');        
        database.executebatch( s );        
    }


}