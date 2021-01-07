/*
 * 22Dec2020 - Jim Dickerson - Allow for setting the programCompleted flag for older reopened programs/forecasts that are now being ended
 * 23Dec2020 - Jim Dickerson - make sure we don't try to update the same OLI multiple times when checking foir a TFM update ..
 *
*/
public without sharing class ForecastOutput52WeekTriggerHelper {
    
    public static void UpdateForecast(List<ForecastOutput52Week__c> forecasts, Map<ID, ForecastOutput52Week__c> oldMap) {
        // only run on active status__c
        // decide if (1) end program (2) MP Start Date change (3) TPM change (4) schedule update
        // (1) programCompleted__c (2) massProductionStartDate__c
        // (3) tpmAccount__c + tpmOwner__c (4) 1 or 2 don;t change - shedule update will never happen at same time 1 or 2
        // (4) update M1 -> forward, do not change any records in schdule that are older  
        
        // current schedule update                
        Map<String, Decimal> qtyForecastMap = new Map<String, Decimal>();
        Map<String, Decimal> priceForecastMap = new Map<String, Decimal>();
        Map<String, Date> dateForecastMap = new Map<String, Date>();
        Set<String> oliScheduleSet = new Set<String>(); // opportunity line item Ids from Forecasts with schedule change
        
        // Opportunity        
        Set<Id> oSet = new Set<Id>(); // opportunity Ids from all Forecasts                         
        List<Opportunity> relatedOpps = new List<Opportunity>(); // query the related opportunities
        Map<Id,Opportunity> opportunity2OpportunityMap = new Map<Id,Opportunity>();       
        Map<Id, Opportunity> updateOppsById = new Map<Id, Opportunity>();
        
        // Opportunity Line Item
        Set<String> oliSet = new Set<String>(); // opportunity line item Ids from all Forecasts
        List<OpportunityLineItem> relatedOLIs = new List<OpportunityLineItem>(); // query the related OLIs
        Map<Id,OpportunityLineItem> oli2OliMap = new Map<Id,OpportunityLineItem>();       
        List<OpportunityLineItem> updateOLIs = new List<OpportunityLineItem>();
        
        for (ForecastOutput52Week__c foId: forecasts) {
            oSet.add(foId.opportunity__c);
            oliSet.add(foId.opportunityLineItemID__c);
        }
        
        relatedOpps = [SELECT Id, programCompleted__c, Start_of_Production__c FROM Opportunity WHERE Id In :oSet];
        for (Opportunity o: relatedOpps) {
            opportunity2OpportunityMap.put(o.id, o);
        }
        
        relatedOLIs = [SELECT Id, tpmOverride__c FROM OpportunityLineItem WHERE Id In :oliSet];
        for (OpportunityLineItem oli: relatedOLIs) {
            oli2OliMap.put(oli.id, oli);
        }
        
        // new start date change
        Map<Id,Date> f2oliDateMap = new Map<Id,Date>();
        Map<Id,Date> oli2oliDateMap = new Map<Id,Date>();
        Map<Id,Id> oli2fMap = new Map<Id,Id>();
        List<OpportunityLineItemSchedule> oliScheduleList = new List<OpportunityLineItemSchedule>(); 
        List<OpportunityLineItemSchedule> toUpdateOlisList = new List<OpportunityLineItemSchedule>(); 
        List<ForecastOutput52Week__c> updateForecastList = new List<ForecastOutput52Week__c>();
        Set<String> oliDateChangeSet = new Set<String>(); // opportunity line item Ids from Forecasts with schedule date change
        Set<Id> updateForecastSet = new Set<Id>();
        Boolean overrideProgramCompleteFlag = OpportunityForecastActions.overrideM1date(); // 22Dec2020 special case where we are updating a re-opened and old program/forecast.
        
        for (ForecastOutput52Week__c f: forecasts) {

            Opportunity uOpp = new Opportunity();
            uOpp = opportunity2OpportunityMap.get(f.opportunity__c);
           // ********** END PROGRAM **********
           // 22Dec2020 allow for setting the programCompleted__c flag for an older program/forecast that was reopened and is now being ended.
            //If (oldMap.get(f.ID).programCompleted__c == FALSE && f.programCompleted__c == TRUE && f.status__c == 'Completed') {  
            If ( ((oldMap.get(f.ID).programCompleted__c == FALSE && f.programCompleted__c == TRUE) || (f.programCompleted__c == TRUE && overrideProgramCompleteFlag == TRUE)) && f.status__c == 'Completed') {     
                if(updateOppsById.containsKey(f.opportunity__c)){
                    uOpp = updateOppsById.get(f.opportunity__c);
                }
                uOpp.programCompleted__c = TRUE;
                updateOppsById.put(f.opportunity__c, uOpp);
                
                //updateOpps.add(uOpp);            
            }
            
            // ********** UPDATE TPM **********            
            If (oldMap.get(f.ID).tpmAccount__c != f.tpmAccount__c && f.status__c == 'Active') {                         
                OpportunityLineItem uOLI = oli2OliMap.get(f.opportunityLineItemID__c);
                uOLI.tpmOverride__c = f.tpmAccount__c;
                oli2OliMap.put(f.opportunityLineItemID__c, uOLI);
//System.debug('@@JDJD TPM list already contains = ' + updateOLIs.contains(uOLI) +' at index=' + updateOLIs.indexOf(uOLI));
                // 23Dec2020 Fix a problem where on approval of a spec we are trying to update all active forecasts that point to the same oppty line item
                if (!updateOLIs.contains(uOLI))
                	updateOLIs.add(uOLI);                        
            }
            // ********** UPDATE FINISHER **********
            If (oldMap.get(f.ID).finisherAccount__c != f.finisherAccount__c 
                ||oldMap.get(f.ID).finisherMix__c != f.finisherMix__c
                ||oldMap.get(f.ID).finisherOwner__c != f.finisherOwner__c
                ||oldMap.get(f.ID).finisherYield__c != f.finisherYield__c
                ||oldMap.get(f.ID).Comments__c != f.Comments__c) {                        
                    OpportunityLineItem uOLI = oli2OliMap.get(f.opportunityLineItemID__c);
                    uOLI.finisherAccount__c = f.finisherAccount__c;
                    uOLI.finisherMix__c = f.finisherMix__c;
                    uOLI.finisherOwner__c = f.finisherOwner__c;
                    uOLI.finisherYield__c = f.finisherYield__c;
                    uOLI.Comments__c = f.Comments__c;
                    // note: this may have the same issue as above if we try to create a new update record with an Id tha already exists in the list ...
                    updateOLIs.add(uOLI);                        
                }
            
            // ********** RESTART SCHEDULE **********            
            If (oldMap.get(f.ID).massProductionStartDate__c != f.massProductionStartDate__c && f.status__c == 'Active') { 
                // update opportunity     
                system.debug('$$$: IN RESTART SCHEDULE');                  
                //uOpp = opportunity2OpportunityMap.get(f.opportunity__c);    
                if(updateOppsById.containsKey(f.opportunity__c)){
                    uOpp = updateOppsById.get(f.opportunity__c);
                }
                uOpp.Start_of_Production__c = f.massProductionStartDate__c;
                updateOppsById.put(f.opportunity__c, uOpp);       
                    
                // update schedule maps/sets to process records
                oliDateChangeSet.add(f.opportunityLineItemID__c);    
                oli2fMap.put(f.opportunityLineItemID__c, f.id);   
                f2oliDateMap.put(f.id, f.massProductionStartDate__c.toStartOfMonth());
                oli2oliDateMap.put(f.opportunityLineItemID__c, f.massProductionStartDate__c.toStartOfMonth());
                updateForecastSet.add(f.id);
                
            }
            
            
            
            // ********** UPDATE SCHEDULE **********
            If ((oldMap.get(f.ID).programCompleted__c == FALSE && f.programCompleted__c == FALSE && f.status__c == 'Active')
                && (oldMap.get(f.ID).massProductionStartDate__c == f.massProductionStartDate__c)
                && (oldMap.get(f.ID).tpmAccount__c == f.tpmAccount__c)) {
                    // no change so we know it is a schedule update
                    
                    system.debug('$$$ IN UPDATE SCHEDULE ONLY ' + f.massProductionStartDate__c);
                    
                    qtyForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m1Date__c.toStartOfMonth()), f.m1Qty__c);
                    qtyForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m2Date__c.toStartOfMonth()), f.m2Qty__c);
                    qtyForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m3Date__c.toStartOfMonth()), f.m3Qty__c);
                    qtyForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m4Date__c.toStartOfMonth()), f.m4Qty__c);
                    qtyForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m5Date__c.toStartOfMonth()), f.m5Qty__c);
                    qtyForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m6Date__c.toStartOfMonth()), f.m6Qty__c);
                    qtyForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m7Date__c.toStartOfMonth()), f.m7Qty__c);
                    qtyForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m8Date__c.toStartOfMonth()), f.m8Qty__c);
                    qtyForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m9Date__c.toStartOfMonth()), f.m9Qty__c);
                    qtyForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m10Date__c.toStartOfMonth()), f.m10Qty__c);
                    qtyForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m11Date__c.toStartOfMonth()), f.m11Qty__c);
                    qtyForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m12Date__c.toStartOfMonth()), f.m12Qty__c);
                    qtyForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m13Date__c.toStartOfMonth()), f.m13Qty__c);
                    qtyForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m14Date__c.toStartOfMonth()), f.m14Qty__c);
                    qtyForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m15Date__c.toStartOfMonth()), f.m15Qty__c);
                    qtyForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m16Date__c.toStartOfMonth()), f.m16Qty__c);
                    qtyForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m17Date__c.toStartOfMonth()), f.m17Qty__c);
                    qtyForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m18Date__c.toStartOfMonth()), f.m18Qty__c);
                    
                    priceForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m1Date__c.toStartOfMonth()), f.m1UnitPrice__c);
                    priceForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m2Date__c.toStartOfMonth()), f.m2UnitPrice__c);
                    priceForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m3Date__c.toStartOfMonth()), f.m3UnitPrice__c);
                    priceForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m4Date__c.toStartOfMonth()), f.m4UnitPrice__c);
                    priceForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m5Date__c.toStartOfMonth()), f.m5UnitPrice__c);
                    priceForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m6Date__c.toStartOfMonth()), f.m6UnitPrice__c);
                    priceForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m7Date__c.toStartOfMonth()), f.m7UnitPrice__c);
                    priceForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m8Date__c.toStartOfMonth()), f.m8UnitPrice__c);
                    priceForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m9Date__c.toStartOfMonth()), f.m9UnitPrice__c);
                    priceForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m10Date__c.toStartOfMonth()), f.m10UnitPrice__c);
                    priceForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m11Date__c.toStartOfMonth()), f.m11UnitPrice__c);
                    priceForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m12Date__c.toStartOfMonth()), f.m12UnitPrice__c); 
                    priceForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m13Date__c.toStartOfMonth()), f.m13UnitPrice__c);
                    priceForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m14Date__c.toStartOfMonth()), f.m14UnitPrice__c);  
                    priceForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m15Date__c.toStartOfMonth()), f.m15UnitPrice__c);  
                    priceForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m16Date__c.toStartOfMonth()), f.m16UnitPrice__c);  
                    priceForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m17Date__c.toStartOfMonth()), f.m17UnitPrice__c);  
                    priceForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m18Date__c.toStartOfMonth()), f.m18UnitPrice__c);           
                    
                    dateForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m1Date__c.toStartOfMonth()), f.m1Date__c);
                    dateForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m2Date__c.toStartOfMonth()), f.m2Date__c);
                    dateForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m3Date__c.toStartOfMonth()), f.m3Date__c);
                    dateForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m4Date__c.toStartOfMonth()), f.m4Date__c);
                    dateForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m5Date__c.toStartOfMonth()), f.m5Date__c);
                    dateForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m6Date__c.toStartOfMonth()), f.m6Date__c);
                    dateForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m7Date__c.toStartOfMonth()), f.m7Date__c);
                    dateForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m8Date__c.toStartOfMonth()), f.m8Date__c);
                    dateForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m9Date__c.toStartOfMonth()), f.m9Date__c);
                    dateForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m10Date__c.toStartOfMonth()), f.m10Date__c);
                    dateForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m11Date__c.toStartOfMonth()), f.m11Date__c);
                    dateForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m12Date__c.toStartOfMonth()), f.m12Date__c);            
                    dateForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m13Date__c.toStartOfMonth()), f.m13Date__c);
                    dateForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m14Date__c.toStartOfMonth()), f.m14Date__c);
                    dateForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m15Date__c.toStartOfMonth()), f.m15Date__c);
                    dateForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m16Date__c.toStartOfMonth()), f.m16Date__c);
                    dateForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m17Date__c.toStartOfMonth()), f.m17Date__c);
                    dateForecastMap.put(String.valueOf(f.opportunityLineItemID__c) + String.valueOf(f.m18Date__c.toStartOfMonth()), f.m18Date__c);
                    
                    oliScheduleSet.add(f.opportunityLineItemID__c);         
                }
            
        } // end forecast loop
        
        // update schedule                 
        List<OpportunityLineItemSchedule> olisList = new List<OpportunityLineItemSchedule>(); 
        List<OpportunityLineItemSchedule> toUpsertOlisList = new List<OpportunityLineItemSchedule>(); 
        List<OpportunityLineItemSchedule> toDeleteOlisList = new List<OpportunityLineItemSchedule>(); // zero quantity dates
        //List<String> updatedScheduleLines = new List<String>(); 
        
        // PROCESS UPDATE SCHEDULE
        if (oliScheduleSet.size() > 0) {    
            olisList = [SELECT id, opportunityLineItemID, scheduledate, quantity, revenue, description 
                        FROM OpportunityLineItemSchedule 
                        WHERE OpportunityLineItemId IN :oliScheduleSet order by opportunityLineItemID asc, ScheduleDate asc];
            
            System.debug( '$$$ ************************************* LOOP THROUGH FORCAST UPDATE - UPDATE SCHEDULE'  );
            for (OpportunityLineItemSchedule sh: olisList) {
                // schedule will allow 0 qty and 0 revenue with a date
                
                String temp = String.valueOf(sh.opportunityLineItemID) + String.valueOf(sh.scheduledate.toStartOfMonth());            
                
                if (qtyForecastMap.get(temp) != Null) {                                
                    sh.quantity = qtyForecastMap.get(temp);
                    sh.description = priceForecastMap.get(temp).toPlainString();
                    sh.revenue = priceForecastMap.get(temp) * qtyForecastMap.get(temp);
                }
                
                // remove from map, remaining values to be inserted
                qtyForecastMap.remove(temp);
                priceForecastMap.remove(temp);
                dateForecastMap.remove(temp);
                
                toUpsertOlisList.add(sh);
                
            }
            
            // remaining lines need inserted       
            System.debug('$$$: BEFORE NEW LOOP');       
            String oliID;
            
            for (String key : qtyForecastMap.keySet()) {
                oliID = String.valueOf(key).left(18);            
                System.debug('$$$: ' + oliID);            
                opportunityLineItemSchedule ols = new opportunityLineItemSchedule();
                ols.ScheduleDate = dateForecastMap.get(key).toStartOfMonth();
                ols.opportunityLineItemID = oliID;
                ols.type = 'Both';
                ols.description = priceForecastMap.get(key).toPlainString();
                ols.Quantity = qtyForecastMap.get(key);
                ols.Revenue = priceForecastMap.get(key) * qtyForecastMap.get(key);                                 
                toUpsertOlisList.add(ols);
            }                
        } // end oliScheduleSize > 0
        
        
        
        
        // PROCESS UPDATE DATE CHANGE ON SCHEDULE        
        if (oliDateChangeSet.size() > 0) { // set of OLIs that need updated
            // oli2fMap.put(f.opportunityLineItemID__c, f.id); // map of OLIs back to Forecast record   
            // f2oliDateMap.put(f.id, f.massProductionStartDate__c.toStartOfMonth()); // map of Forecast to new Start Date
            // oli2oliDateMap.put(f.opportunityLineItemID__c, f.massProductionStartDate__c.toStartOfMonth()); // map of OLI to new Start Date
            Date startDate;
            Date currentDate;
            Date newDate;
            Date previousStartDate;   
            Integer i = 0;         
            
            oliScheduleList = [SELECT id, opportunityLineItemID, scheduledate, quantity, revenue, description 
                               FROM OpportunityLineItemSchedule 
                               WHERE OpportunityLineItemId IN :oliDateChangeSet order by opportunityLineItemID asc, ScheduleDate asc];
            
            
            Boolean scheduleStarted = FALSE;   
            for (OpportunityLineItemSchedule dc: oliScheduleList) {
                
                startDate = oli2oliDateMap.get(dc.opportunityLineItemID); // new start date
                system.debug('^^^ NEW START DATE FOR SCHEDULE LINES: ' + startDate);
                
                if (startDate != previousStartDate || previousStartDate == Null) {
                    i = 0;  
                    scheduleStarted = FALSE;   
                }
                
                if (startDate == previousStartDate || previousStartDate == Null) {
                    
                    // remove leading records with zero quantity
                    if (dc.quantity == 0 && scheduleStarted == FALSE) {
                        toDeleteOlisList.add(dc);
                        system.debug('^^^ REMOVING SCHEDULE LINE WITH DATE: ' + dc.scheduleDate);
                    }
                    
                    // start with first non zero schedule and keep other zero months
                    if (dc.quantity != 0 || scheduleStarted == TRUE) {
                        newDate = startDate.addMonths(i).toStartOfMonth();
                        dc.scheduledate = newDate;      
                        i++;
                        scheduleStarted = TRUE;                        
                        toUpdateOlisList.add(dc);
                        system.debug('^^^ UPDATING SCHEDULE LINE WITH DATE: ' + dc.scheduleDate);
                    }                 
                    
                }
                
                previousStartDate = oli2oliDateMap.get(dc.opportunityLineItemID); // help determine if i should reset                                                                          
                
            }
            
            system.debug('^^^ REMOVING TOTAL SCHEDULE LINES: ' + toDeleteOlisList.size());
            system.debug('^^^ UPDATING TOTAL SCHEDULE LINES: ' + toUpdateOlisList.size());                        
        }
        
        // update records
        if (updateOppsById.size() > 0) { update updateOppsById.values(); }
        if (updateOLIs.size() > 0) { update updateOLIs; }
        if (toUpsertOlisList.size() > 0) { upsert toUpsertOlisList; }
        if (toUpdateOlisList.size() > 0) { update toUpdateOlisList; }
        if (toDeleteOlisList.size() > 0) { delete toDeleteOlisList; }
        
        // PROCESS UPDATE DATE CHANGE ON FORECAST  
        Date reStartDate;      
        Date forecastDate;
        Integer Count = 0;
        Integer Diff = 0;
        if (oliDateChangeSet.size() > 0) {
            
            // requery the changed active forecast records
            updateForecastList = [SELECT Id, opportunityAmount__c, totalPrice__c, totalQuantity__c, opportunityLineItemID__c,
                                  m1Qty__c, m2Qty__c, m3Qty__c, m4Qty__c, m5Qty__c, m6Qty__c, m7Qty__c, m8Qty__c, m9Qty__c, 
                                  m10Qty__c, m11Qty__c, m12Qty__c, m13Qty__c, m14Qty__c, m1UnitPrice__c, m2UnitPrice__c, m3UnitPrice__c, 
                                  m4UnitPrice__c, m5UnitPrice__c, m6UnitPrice__c, m7UnitPrice__c, m8UnitPrice__c, m9UnitPrice__c, m10UnitPrice__c, 
                                  m11UnitPrice__c, m12UnitPrice__c, m13UnitPrice__c, m14UnitPrice__c,
                                  m1Rev__c, m2Rev__c, m3Rev__c, m4Rev__c, m5Rev__c, m6Rev__c, m7Rev__c,
                                  m8Rev__c, m9Rev__c, m10Rev__c, m11Rev__c, m12Rev__c, m13Rev__c, m14Rev__c,
                                  m15UnitPrice__c,m15Qty__c,m15Rev__c,m16UnitPrice__c,m16Qty__c,m16Rev__c,
                                  m17UnitPrice__c,m17Qty__c,m17Rev__c,m18UnitPrice__c,m18Qty__c,m18Rev__c,
                                  date__c, massProductionStartDate__c
                                  FROM ForecastOutput52Week__c 
                                  WHERE id IN :updateForecastSet];
            
            // requery the updated opportunity line item schedules - updated schedules
            oliScheduleList = [SELECT id, opportunityLineItemID, scheduledate, quantity, revenue, description 
                               FROM OpportunityLineItemSchedule 
                               WHERE OpportunityLineItemId IN :oliDateChangeSet order by opportunityLineItemID asc, ScheduleDate asc];
            
            // update the active forecast data
            for (ForecastOutput52Week__c f: updateForecastList) {
                
                // zero out fields to rebuild active forecast
                f.opportunityAmount__c = 0;
                f.totalPrice__c = 0;
                f.totalQuantity__c = 0;
                f.m1UnitPrice__c = 0;
                f.m1Qty__c = 0; 
                f.m1Rev__c = 0;
                f.m2UnitPrice__c = 0;
                f.m2Qty__c = 0; 
                f.m2Rev__c = 0;
                f.m3UnitPrice__c = 0;
                f.m3Qty__c = 0; 
                f.m3Rev__c = 0;
                f.m4UnitPrice__c = 0;
                f.m4Qty__c = 0; 
                f.m4Rev__c = 0;
                f.m5UnitPrice__c = 0;
                f.m5Qty__c = 0; 
                f.m5Rev__c = 0;
                f.m6UnitPrice__c = 0;
                f.m6Qty__c = 0; 
                f.m6Rev__c = 0;
                f.m7UnitPrice__c = 0;
                f.m7Qty__c = 0; 
                f.m7Rev__c = 0;
                f.m8UnitPrice__c = 0;
                f.m8Qty__c = 0; 
                f.m8Rev__c = 0;
                f.m9UnitPrice__c = 0;
                f.m9Qty__c = 0; 
                f.m9Rev__c = 0;
                f.m10UnitPrice__c = 0;
                f.m10Qty__c = 0; 
                f.m10Rev__c = 0;
                f.m11UnitPrice__c = 0;
                f.m11Qty__c = 0; 
                f.m11Rev__c = 0;
                f.m12UnitPrice__c = 0;
                f.m12Qty__c = 0; 
                f.m12Rev__c = 0;
                f.m13UnitPrice__c = 0;
                f.m13Qty__c = 0; 
                f.m13Rev__c = 0;
                f.m14UnitPrice__c = 0;
                f.m14Qty__c = 0; 
                f.m14Rev__c = 0;
                f.m15UnitPrice__c = 0;
                f.m15Qty__c = 0; 
                f.m15Rev__c = 0;
                f.m16UnitPrice__c = 0;
                f.m16Qty__c = 0; 
                f.m16Rev__c = 0;
                f.m17UnitPrice__c = 0;
                f.m17Qty__c = 0; 
                f.m17Rev__c = 0;
                f.m18UnitPrice__c = 0;
                f.m18Qty__c = 0; 
                f.m18Rev__c = 0;
                count = 0;
                diff = 0;
                
                System.debug( '$$$ ************************************* LOOP THROUGH UPDATED SCHEDULE'  );
                
                // loop through updated schedules
                for (OpportunityLineItemSchedule s: oliScheduleList) {
                    If (f.opportunityLineItemID__c == s.opportunityLineItemID) {
                        forecastDate = f.date__c.toStartOfMonth();
                        reStartDate = f.massProductionStartDate__c.toStartOfMonth();
                        
                        diff = forecastDate.monthsBetween(reStartDate);
                        count = diff + reStartDate.monthsBetween(s.scheduleDate.toStartOfMonth());
                        
                        System.debug( '$$$ ** Schedule Record Count: ' + oliScheduleList.size());
                        System.debug( '$$$ ** 52 Record Forecast Date: ' + forecastDate );
                        System.debug( '$$$ ** New MP Start Date: ' + reStartDate );
                        System.debug( '$$$ Schedule Date from Schedule Line: ' + s.scheduledate );
                        System.debug( '$$$ ** Adjustment Months: ' + diff );
                        System.debug( '$$$ Count 0=M1: ' + count );
                        System.debug( '$$$ Mth Qty: ' + s.Quantity );
                        
                        If (count == 0) {
                            f.m1UnitPrice__c = Decimal.valueOf(s.Description);
                            f.m1Qty__c = s.Quantity; 
                            f.m1Rev__c = s.Revenue;
                        }    
                        If (count == 1) {
                            f.m2UnitPrice__c = Decimal.valueOf(s.Description);
                            f.m2Qty__c = s.Quantity; 
                            f.m2Rev__c = s.Revenue;                                        
                        }    
                        If (count == 2) {
                            f.m3UnitPrice__c = Decimal.valueOf(s.Description);
                            f.m3Qty__c = s.Quantity; 
                            f.m3Rev__c = s.Revenue;                                        
                        }    
                        If (count == 3) {
                            f.m4UnitPrice__c = Decimal.valueOf(s.Description);
                            f.m4Qty__c = s.Quantity; 
                            f.m4Rev__c = s.Revenue;                                        
                        }    
                        If (count == 4) {
                            f.m5UnitPrice__c = Decimal.valueOf(s.Description);
                            f.m5Qty__c = s.Quantity; 
                            f.m5Rev__c = s.Revenue;                                        
                        }    
                        If (count == 5) {
                            f.m6UnitPrice__c = Decimal.valueOf(s.Description);
                            f.m6Qty__c = s.Quantity; 
                            f.m6Rev__c = s.Revenue;                                        
                        }    
                        If (count == 6) {
                            f.m7UnitPrice__c = Decimal.valueOf(s.Description);
                            f.m7Qty__c = s.Quantity; 
                            f.m7Rev__c = s.Revenue;                                        
                        }    
                        If (count == 7) {
                            f.m8UnitPrice__c = Decimal.valueOf(s.Description);
                            f.m8Qty__c = s.Quantity; 
                            f.m8Rev__c = s.Revenue;                                        
                        }    
                        If (count == 8) {
                            f.m9UnitPrice__c = Decimal.valueOf(s.Description);
                            f.m9Qty__c = s.Quantity; 
                            f.m9Rev__c = s.Revenue;                                        
                        }    
                        If (count == 9) {
                            f.m10UnitPrice__c = Decimal.valueOf(s.Description);
                            f.m10Qty__c = s.Quantity; 
                            f.m10Rev__c = s.Revenue;                                        
                        }    
                        If (count == 10) {
                            f.m11UnitPrice__c = Decimal.valueOf(s.Description);
                            f.m11Qty__c = s.Quantity; 
                            f.m11Rev__c = s.Revenue;                                      
                        }    
                        If (count == 11) {
                            f.m12UnitPrice__c = Decimal.valueOf(s.Description);
                            f.m12Qty__c = s.Quantity; 
                            f.m12Rev__c = s.Revenue;                                        
                        }  
                        If (count == 12) {
                            f.m13UnitPrice__c = Decimal.valueOf(s.Description);
                            f.m13Qty__c = s.Quantity; 
                            f.m13Rev__c = s.Revenue;                                        
                        }         
                        If (count == 13) {
                            f.m14UnitPrice__c = Decimal.valueOf(s.Description);
                            f.m14Qty__c = s.Quantity; 
                            f.m14Rev__c = s.Revenue;                                        
                        } 
                        If (count == 14) {
                            f.m15UnitPrice__c = Decimal.valueOf(s.Description);
                            f.m15Qty__c = s.Quantity; 
                            f.m15Rev__c = s.Revenue;                                        
                        } 
                        If (count == 15) {
                            f.m16UnitPrice__c = Decimal.valueOf(s.Description);
                            f.m16Qty__c = s.Quantity; 
                            f.m16Rev__c = s.Revenue;                                        
                        } 
                        If (count == 16) {
                            f.m17UnitPrice__c = Decimal.valueOf(s.Description);
                            f.m17Qty__c = s.Quantity; 
                            f.m17Rev__c = s.Revenue;                                        
                        } 
                        If (count == 18) {
                            f.m18UnitPrice__c = Decimal.valueOf(s.Description);
                            f.m18Qty__c = s.Quantity; 
                            f.m18Rev__c = s.Revenue;                                        
                        }       
                    }
                }
            }
        }
        
        update updateForecastList;
        
    }
    // Sum of m1 to m18 glassSqrt field onbefore insert and update
    public static void onBeforeInsert(List<ForecastOutput52Week__c> newList){
        functionOnBeforeInsertUpdate(newList);
    }
    public static void onBeforeUpdate(List<ForecastOutput52Week__c> newList,Map<Id,ForecastOutput52Week__c>oldMap){
        functionOnBeforeInsertUpdate(newList);
    }
    public static void functionOnBeforeInsertUpdate(List<ForecastOutput52Week__c> newList){
        for(ForecastOutput52Week__c fow : newList){
            fow.totalGlassSqFt__c = fow.m1GlassSqFt__c + fow.m2GlassSqFt__c + fow.m3GlassSqFt__c + fow.m4GlassSqFt__c
                + fow.m5GlassSqFt__c + fow.m6GlassSqFt__c + fow.m7GlassSqFt__c + fow.m8GlassSqFt__c
                + fow.m9GlassSqFt__c + fow.m10GlassSqFt__c + fow.m11GlassSqFt__c + fow.m12GlassSqFt__c
                + fow.m13GlassSqFt__c + fow.m14GlassSqFt__c + fow.m15GlassSqFt__c + fow.m16GlassSqFt__c
                + fow.m17GlassSqFt__c + fow.m18GlassSqFt__c;
        }
    }
    
    
    
    public static void updateRelatedForecast(List<ForecastOutput52Week__c> newForecast, Map<id, ForecastOutput52Week__c> oldForecast){
        Map<id, Id> currentForecastByOpportunity = new Map<id, Id>();
        for(ForecastOutput52Week__c forecast: newForecast){
            if(forecast.programCompleted__c 
            && forecast.programcompleted__c != oldForecast.get(forecast.Id).programcompleted__c
            && forecast.status__c == 'Completed'
            && forecast.status__c != oldForecast.get(forecast.Id).status__c){
                currentForecastByOpportunity.put(forecast.Id, forecast.opportunity__c);
            }
        }
        if(currentForecastByOpportunity.size() > 0){
            getUpdateRelatedForecast(currentForecastByOpportunity);
        }
    }
    
    private static void getUpdateRelatedForecast(Map<id, Id> currentForecastByOpportunity){
        List<ForecastOutput52Week__c> toUpdateForecasts = new List<ForecastOutput52Week__c>();
        for(ForecastOutput52Week__c forecast: [SELECT Id
                                                FROM ForecastOutput52Week__c
                                                WHERE ID NOT IN : currentForecastByOpportunity.keySet()
                                                AND opportunity__c IN : currentForecastByOpportunity.values()
                                                AND status__c != 'Completed'
                                                AND programcompleted__c = false]){
            forecast.programcompleted__c = true;
            forecast.status__c = 'Completed';
            toUpdateForecasts.add(forecast);
        }
        if(toUpdateForecasts.size() > 0){
            UPDATE toUpdateForecasts;
        }
    }
    
}