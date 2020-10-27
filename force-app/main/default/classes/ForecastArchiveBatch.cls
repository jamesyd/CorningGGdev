/*******************************************************************************************************
Class Name       : 
Purpose          : 
Author           : Adam Nicholson
Revision History : 
 * *****************************************************************************************************/
global class ForecastArchiveBatch implements Database.Batchable<sObject> , Database.Stateful{
        
    global integer failedRecCount = 0;
    global integer totalRecCount = 0;
    global Date som = System.Date.today().toStartOfMonth();
    
    global Database.QueryLocator start(Database.BatchableContext BC) { return Database.getQueryLocator( 
        [SELECT Id, status__c FROM ForecastOutput52Week__c WHERE  status__c = 'Active'] );        
    }

    global void execute(Database.BatchableContext BC, List<ForecastOutput52Week__c> scope) {
        system.debug('$$$ Scope ' + scope.size());
        
        try{
            if (scope!=null) {
                totalReccount = totalReccount+scope.size();                                            
            } 
            system.debug('$$$ Scope ' + '1');
            List<ForecastOutput52Week__c> forecast52ListForUpdate = ForecastHelper.archive(scope);    
            system.debug('$$$ Scope ' + '2');
            List<Database.SaveResult> results = new List<Database.SaveResult>();
            system.debug('$$$ Scope ' + '3');
            results = Database.update(forecast52ListForUpdate, false);
            system.debug('$$$ Scope ' + '4');
                
            
            // errors count
            for(database.SaveResult ds : results){                
                if (!ds.isSuccess()){
                    failedRecCount++;
                }  
            }   
        }
        Catch(Exception e){
            system.debug('Exception In Execute ' + e);
        }
    }    
    
    global void finish(Database.BatchableContext BC) {
        System.debug('Number of Records Processed -  ' + totalReccount );
        System.debug('Number of Records Failed  - ' + failedRecCount );
        System.debug('Number of Records Passed  - ' + (totalRecCount-failedRecCount) );
    }
    
}