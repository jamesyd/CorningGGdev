/*******************************************************************************************************
Class Name       : 
Purpose          : 
Author           : Adam Nicholson
Revision History : 
 * *****************************************************************************************************/
global class SpecificationReminderBatch implements Database.Batchable<sObject> , Database.Stateful{
    
    global integer failedRecCount = 0;
    global integer totalRecCount = 0;
        global integer totalRecCount2 = 0;
    global List<Specification__c> totalProcessedSpecs = new List<Specification__c>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {        
        return Database.getQueryLocator( [SELECT id, createdbyid, opportunityName__c, rfiConfiguration__c, recordtypeid, innovation_type__c, productLine__c, mtoNotificationPath__c, accountAEId__c, isOmega__c, location__c, reminderCompleted__c, statusChangeDate__c, status__c, dsLocation__c, dsReminderCompleted__c, dsStatusChangeDate__c, dsStatus__c FROM Specification__c 
                                          WHERE isClosed__c = False AND ( (statusChangeDate__c != null AND reminderCompleted__c = False) OR (dsStatusChangeDate__c != null AND dsReminderCompleted__c = False) )] );
    }

    global void execute(Database.BatchableContext BC, List<Specification__c> scope) {
        try{
            if(scope!=null){
                totalReccount = totalReccount + scope.size();
                system.debug('TRC Original: ' + totalReccount);
            } 
            
            // call chatter helper class
            List<Specification__c> specListForUpdate = ChatterHelper.specificationReminder(Scope);
            system.debug('TRC: ' + totalReccount);
            
            //totalProcessedSpecs.addAll(specListForUpdate);
            //system.debug('TPS: ' + totalProcessedSpecs.size()); 
            
            List<Database.SaveResult> results = new List<Database.SaveResult>();                        
            system.debug('RES: ' + results.size());
            
            results = Database.update(specListForUpdate, false);
            
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