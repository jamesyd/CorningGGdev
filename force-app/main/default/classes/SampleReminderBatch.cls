/*******************************************************************************************************
Class Name       : 
Purpose          : 
Author           : Adam Nicholson
Revision History : 
 * *****************************************************************************************************/
global class SampleReminderBatch implements Database.Batchable<sObject> , Database.Stateful{
    
    global integer failedRecCount = 0;
    global integer totalRecCount = 0;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {        
        return Database.getQueryLocator( [select id, name, programOpportunityName__c, sampleInnovations__c, sampleCmLocations__c, ownerId, Owner_Role__c, sampleGlassComposition__c, accountAEId__c, recordTypeId, reminderCompleted__c, statusChangeDate__c, stageName from Opportunity where isClosed = False] );
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        try{
            if(scope!=null){
                totalReccount = totalReccount+scope.size();
            } 
            
            // call chatter helper class
            List<Opportunity> oppListForUpdate = ChatterHelperSamples.sampleReminder(scope);
            List<Database.SaveResult> results = new List<Database.SaveResult>();            
            
            results = Database.update(oppListForUpdate, false);
            
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