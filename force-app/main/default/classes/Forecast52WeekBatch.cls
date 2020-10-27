/*******************************************************************************************************
Class Name       : 
Purpose          : 
Author           : Adam Nicholson
Revision History : 
 * *****************************************************************************************************/
global class Forecast52WeekBatch implements Database.Batchable<sObject> , Database.Stateful{

    global String strParameter;

    global Forecast52WeekBatch(String strParam) {
        strParameter = strParam;
    }
    
    global integer failedRecCount = 0;
    global integer totalRecCount = 0;
    global Date som = System.Date.today().toStartOfMonth();
    global List<ForecastOutput52Week__c> statefulForecast52ListForUpdate = new List<ForecastOutput52Week__c>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) { return Database.getQueryLocator( 
        [SELECT Id, Opportunity.Id, Opportunity.OwnerId, Opportunity.ForecastCategory, Opportunity.StageName, Opportunity.Amount, 
         Opportunity.CloseDate, Opportunity.age__c, Opportunity.RecordTypeId, Opportunity.Name, Opportunity.AccountId, Opportunity.programCompleted__c,
         Opportunity.gorillaGlassPercent__c, Opportunity.Competitive_Material__c, Opportunity.pandaPercent__c, Opportunity.agcPercent__c, 
         Opportunity.schottPercent__c, Opportunity.negPercent__c, Opportunity.otherPercent__c, Opportunity.deviceCategory__c, 
         Opportunity.productSegmentation__c, Opportunity.competitiveGlasses__c, Opportunity.massProductionYield__c,
         forecastApplication__c, forecastBrandCustomer__c, coverScreenSize__c, glassComposition__c, 
         glassCurvature__c, length__c, forecastMarketSegment__c,
         forecastMarketSubSegment__c, forecastMassProductionStartDate__c, forecastModelProgramName__c, 
         forecastMonthsInProduction__c, forecastCategory__c,
         LastModifiedById, LastModifiedDate, Product2Id, forecastProductCode__c, forecastProductionVolumePartsMonth__c, ProductName__c,
         forecastProgramName__c, forecastRegion__c, forecastShipToCustomer__c, specification__c,
         specification__r.name, specification__r.tpm__r.id, specification__r.tpm__r.OwnerId,  tpmOverride__c, tpmOverride__r.OwnerId,
         squareFeet__c, thickness__c, TotalPrice, Quantity, treatment__c, width__c,
         finisherAccount__c, finisherAccount__r.Name, glassThickness__c, finisherMix__c, finisherOwner__c, finisherYield__c, comments__c,
         finalFinishedGlassPartThickness__c,
         (SELECT Id, Quantity, Description, Revenue, ScheduleDate, LastModifiedById, LastModifiedDate 
             FROM OpportunityLineItemSchedules 
             WHERE ScheduleDate >= :som ORDER BY ScheduleDate ASC )        
         FROM OpportunityLineItem 
         WHERE HasQuantitySchedule = True 
         AND HasRevenueSchedule = True 
         AND Opportunity.RecordTypeId = '0121J000000U1cZQAS' 
         AND Opportunity.programCompleted__c = False ] ); // where Opportunity.IsWon=true and Opportunity.CloseDate = THIS_QUARTER ] );        
    }

    global void execute(Database.BatchableContext BC, List<OpportunityLineItem> scope) {
        system.debug('$$$ Scope ' + scope.size());
        system.debug('$$$ Scope ' + strParameter);
        
        try{
            if (scope!=null) {
                totalReccount = totalReccount+scope.size();                                            
            } 
            system.debug('$$$ Scope ' + '1');
            List<ForecastOutput52Week__c> forecast52ListForUpdate = ForecastHelper.process52(scope, strParameter);    
            system.debug('$$$ Scope ' + '2');
            List<Database.SaveResult> results = new List<Database.SaveResult>();
            system.debug('$$$ Scope ' + '3');
            results = Database.insert(forecast52ListForUpdate, false);
            system.debug('$$$ Scope ' + '4');
            
            statefulForecast52ListForUpdate.addAll(forecast52ListForUpdate);
            
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
        
        //Update Account
        System.debug('@@## statefulForecast52ListForUpdate' + statefulForecast52ListForUpdate);
        ForecastHelper.updateForeCastAccount(statefulForecast52ListForUpdate);
    }
    
}