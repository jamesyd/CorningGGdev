public without sharing class OpportunityForecastActions {

    @AuraEnabled
    public static List<Opportunity> submitForecast(Id oppId) {

       List<Opportunity> updateList = new List<Opportunity>();

       List<Opportunity> oList = new List<Opportunity>([Select Id, createForecast__c
            FROM Opportunity WHERE id = :oppId]);
       
       For (Opportunity o : oList) {
           if (o.createForecast__c == FALSE) {
               o.createForecast__c = TRUE;                          
               updateList.add(o);
           }
       }

       if (updateList.size() == 0) {
       
           throw new AuraHandledException('A forecast for this program has already been created.');
       
       } else {
       
           try {
                update updateList;
           } catch (Exception e) {
                throw new AuraHandledException('Something went wrong: ' + e.getMessage() + '<P/><BR/>' + 'Please edit the record and correct errors before creating the forecast.');   
           }
       
       }
              
       List<Opportunity> returnList = new List<Opportunity>([Select Id
            FROM Opportunity WHERE id = :oppId]);    
       
       return returnList;
     
    }

    @AuraEnabled
    public static List<Opportunity> restoreForecast(Id oppId) {

        List<Opportunity> updateList = getOpportunity(oppId);
        
        // Need to restore OEM forecast *** TO DO ***
        List<ForecastOutput52Week__c> updateForecastList = getForecastOutput(oppId);
        
        
        
        if (updateList.size() == 0) {
           throw new AuraHandledException(ConstantController.RESTORE_ACTIVE_ERR_MSG);
        
        } else {
            if(updateForecastList.size() > 0){
                try {
                    UPDATE updateList;
                    UPSERT updateForecastList;
                } catch (Exception e) {
                    throw new AuraHandledException('Something went wrong: ' + e.getMessage());   
                }
            }else{
                throw new AuraHandledException(ConstantController.RESTORE_COMPLETRD_ERR_MSG);
            }
            
        }
                                 
        List<Opportunity> 
            returnList = new List<Opportunity>([Select Id
                        FROM Opportunity 
                        WHERE id = :oppId]);    
        
        return returnList;
    }
    
    //get the opportunity records.
    private static List<Opportunity> getOpportunity(Id oppId){
        List<Opportunity> updateList = new List<Opportunity>();
        
        try{
            For (Opportunity o : [Select Id, programCompleted__c, createForecast__c
                                  FROM Opportunity 
                                  WHERE id = :oppId
                                  AND programCompleted__c = true]) {
               o.programCompleted__c = FALSE;                          
               updateList.add(o);
            }
        }catch(Exception e){
        }
        return updateList;
    }
    
    //Forecast records that need to change.
    private static List<ForecastOutput52Week__c> getForecastOutput(Id oppId){
        List<ForecastOutput52Week__c> updateForecastList = new List<ForecastOutput52Week__c>();
        
        Date currentMonthDate = Date.newInstance(system.today().Year(), system.today().month(), 1);
        Date preMonthDate = currentMonthDate.addMonths(-1);
        List<Date> forecastDates = new List<Date>{currentMonthDate, preMonthDate};
        System.debug('@@## forecastDates: ' + forecastDates);
        
        List<ForecastOutput52Week__c> fList = getForecastList(oppId, forecastDates);
        System.debug('@@## fList.size=' + fList.size());
        Boolean isCurrentMonth = false;
        Boolean isPrevMonth = false;
        
        try{
            For (ForecastOutput52Week__c f : fList) {
                if(f.m1Date__c == currentMonthDate){
                   f.programCompleted__c = FALSE;     
                   f.status__c = 'Active';                      
                   isCurrentMonth = TRUE;
                   updateForecastList.add(f);
                }
            }
            if(!isCurrentMonth){
                For(ForecastOutput52Week__c f : fList) {
                   if(f.m1Date__c == preMonthDate){
                       f.programCompleted__c = FALSE;     
                       f.status__c = 'Archived'; 
                       isPrevMonth = TRUE;
                       updateForecastList.add(f);
                   }
                }
            }
            if(isPrevMonth){
                List<OpportunityLineItem> olis = getOLIs(oppId);
                List<ForecastOutput52Week__c> forecastToInsert = new List<ForecastOutput52Week__c>();
                forecastToInsert = ForecastHelper.process52(olis, 'Active');
                updateForecastList.addAll(forecastToInsert);
            }
            // JDJD
            if (!isCurrentMonth && !isPrevMonth && overrideM1Date()) {
                For (ForecastOutput52Week__c f : fList) {
                    //if(f.m1Date__c == currentMonthDate){
                       //f.programCompleted__c = FALSE;     
                       f.status__c = 'Active';                      
                       updateForecastList.add(f);
                    //}
                }             
            }
            // END JDJD
        }catch(Exception e){}
     System.debug('@@## updateForecastList size=' + updateForecastList.size())  ;
        return updateForecastList;
    }
    
    private static List<OpportunityLineItem> getOLIs(Id oppId){
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        Date som = System.Date.today().toStartOfMonth();
        try{
        // requery OLI now that schedule is added, create 52 initial week forecast
        olis = [SELECT Id, Opportunity.Id, Opportunity.OwnerId, Opportunity.ForecastCategory, Opportunity.StageName, Opportunity.Amount, 
                Opportunity.CloseDate, Opportunity.age__c, Opportunity.RecordTypeId, 
                Opportunity.Name, Opportunity.AccountId,
                Opportunity.gorillaGlassPercent__c, Opportunity.Competitive_Material__c, 
                Opportunity.pandaPercent__c, Opportunity.agcPercent__c, Opportunity.massProductionYield__c,
                Opportunity.schottPercent__c, Opportunity.negPercent__c, Opportunity.otherPercent__c, Opportunity.deviceCategory__c, 
                Opportunity.productSegmentation__c, Opportunity.competitiveGlasses__c, 
                forecastApplication__c, forecastBrandCustomer__c, coverScreenSize__c, glassComposition__c, 
                glassCurvature__c, length__c, forecastMarketSegment__c,
                forecastMarketSubSegment__c, forecastMassProductionStartDate__c, forecastModelProgramName__c, 
                forecastMonthsInProduction__c, forecastCategory__c,
                LastModifiedById, LastModifiedDate, Product2Id, forecastProductCode__c, 
                forecastProductionVolumePartsMonth__c, ProductName__c,
                forecastProgramName__c, forecastRegion__c, forecastShipToCustomer__c, specification__c,
                specification__r.name, specification__r.tpm__r.id, specification__r.tpm__r.OwnerId, 
                tpmOverride__c, tpmOverride__r.OwnerId,
                squareFeet__c, thickness__c, TotalPrice, Quantity, treatment__c, width__c,
                finisherAccount__c, finisherAccount__r.Name, finisherMix__c, finisherOwner__c, 
                finisherYield__c, comments__c, glassThickness__c,
                finalFinishedGlassPartThickness__c,
                (SELECT Id, Quantity, Revenue, Description, ScheduleDate, LastModifiedById, LastModifiedDate 
                 FROM OpportunityLineItemSchedules WHERE ScheduleDate >= :som ORDER BY ScheduleDate ASC )        
                FROM OpportunityLineItem 
                WHERE HasQuantitySchedule = True 
                AND HasRevenueSchedule = True 
                AND Opportunity.RecordTypeId = '0121J000000U1cZQAS' 
                AND OpportunityId = :oppId] ; 
        }catch(Exception e){}
        
        return olis;
    }
    
    //Method to get all the existing forecast that are created either in current month or previous month.
    private static List<ForecastOutput52Week__c> getForecastList(Id oppId, List<Date> forecastDates){
        List<ForecastOutput52Week__c> 
           fList = new List<ForecastOutput52Week__c>();
        String status = 'Completed';
        // JDJD
        if (overrideM1date()) {
System.debug('@@## overriding .. look for oppId=' + oppId +'status=' + status);
            fList = [Select Id, opportunity__c, m1Date__c,
                     programCompleted__c, status__c
                     FROM ForecastOutput52Week__c 
                     WHERE opportunity__c = :oppId
                     AND Status__c = :status
                    ];           
        }
        // END JDJD
        else {
            try{    
                fList = [Select Id, opportunity__c, m1Date__c,
                         programCompleted__c, status__c
                         FROM ForecastOutput52Week__c 
                         WHERE opportunity__c = :oppId
                         AND m1Date__c IN :forecastDates
                         AND Status__c = :status
                        ];
            }catch(Exception e){
            }
        }
        return fList;
    }
    // Method to check if we allowing current user to reopen a closed forecast ...
    public static Boolean overrideM1date() {
        Set<Id> accessiblePermissionIds = new Set<Id>();
        for (SetupEntityAccess access : [
            SELECT SetupEntityId FROM SetupEntityAccess
            WHERE SetupEntityType = 'CustomPermission' AND ParentId IN (
                SELECT PermissionSetId FROM PermissionSetAssignment
                WHERE AssigneeId = :UserInfo.getUserId()
            )
        ]) accessiblePermissionIds.add(access.SetupEntityId);

    	return 0 < [
            SELECT count() FROM CustomPermission
            WHERE Id IN :accessiblePermissionIds
            AND DeveloperName = 'GG_Allow_Reopen_Forecast'
    	];
    }