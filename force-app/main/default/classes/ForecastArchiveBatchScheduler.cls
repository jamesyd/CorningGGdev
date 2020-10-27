/*******************************************************************************************************
Purpose          : 
Author           : Adam Nicholson   
Revision History : 
 * *****************************************************************************************************/
global class ForecastArchiveBatchScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {         
        ForecastArchiveBatch s = new ForecastArchiveBatch();        
        database.executebatch( s );        
    }


}