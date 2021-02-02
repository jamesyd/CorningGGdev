/**
 * @description       : 
 * @author            :
 * @group             : 
 * @last modified on  : 21 Jan 2021
 * @last modified by  : Jim Dickerson
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   11-03-2020   Edgar Santillana   Initial Version
 * 1.1   12-11-2020   Edgar Santillana   Two methods added getActiveForcecastCurrentMonth (Loked Records) and getActiveForcecastPreviousMonth (Active Records)
*  1.2   01-21-2021   Jim Dickerson      changes for Jira issues CSMSF-50 and CSMSF-51
 **/
public without sharing class ForecastHelper {
    
    public Static List<ForecastOutput52Week__c> archive( List<ForecastOutput52Week__c> fList ) {
        
        List<ForecastOutput52Week__c> forecastToUpdate = new List<ForecastOutput52Week__c>();
        
        for (ForecastOutput52Week__c f : fList) {
            f.status__C = 'Archived';
            forecastToUpdate.add(f);
        }        
        
        return forecastToUpdate;
        
    }
    
    public static Map<Integer,String> getMonthMap(){
        Map<Integer,String> monthMap = new Map<Integer,String>();
        monthMap.put(1,'January');
        monthMap.put(2,'February');
        monthMap.put(3,'March');
        monthMap.put(4,'April');
        monthMap.put(5,'May');
        monthMap.put(6,'June');
        monthMap.put(7,'July');
        monthMap.put(8,'August');
        monthMap.put(9,'September');
        monthMap.put(10,'October');
        monthMap.put(11,'November');
        monthMap.put(12,'December'); 
        return monthMap;
    }
    
    public Static List<ForecastOutput52Week__c> process52( List<opportunityLineItem> oliList, String status ) {
        
        List<ForecastOutput52Week__c> forecastToInsert = new List<ForecastOutput52Week__c>();
        Integer Month = Date.Today().Month();
        Integer Year = Date.Today().Year();
        Integer count = 0;
        Map<Integer,String> monthMap = getMonthMap();
        
        Map<id, ForecastOutput52Week__c> forecastOutputByOliId = new Map<id, ForecastOutput52Week__c>();
        Map<id, wrapperForecast> forecastOutputByOliIdActive = new Map<id, wrapperForecast>();
        Boolean isCalculatefromPrev = false;
        if(status == 'Locked' ){//&& System.Date.today().Month() == 8
            isCalculatefromPrev = true;
            forecastOutputByOliId = getM2ForecasteDetails(oliList, status);
            forecastOutputByOliIdActive = getActiveForcecastCurrentMonth(oliList);
            System.debug('Forecast Output By Oli ' + forecastOutputByOliId );
        } else if (status == 'Active'){
            forecastOutputByOliIdActive = getActiveForcecastPreviousMonth(oliList);
        }
        wrapperForecast prevForecast; // used in following loop ..

        for(OpportunityLineItem o : oliList) {
            
            ForecastOutput52Week__c f = new ForecastOutput52Week__c();
            f.status__c = status;
            f.date__c = Date.Today();
            f.account__c = o.Opportunity.AccountId;
            f.application__c = o.forecastApplication__c;
            f.brandCustomer__c = o.forecastBrandCustomer__c;
            f.coverScreenSize__c = o.coverScreenSize__c;
            f.glassComposition__c = o.glassComposition__c;
            f.glassCurvature__c = o.glassCurvature__c;
            f.length__c = o.length__c;
            f.marketSegment__c = o.forecastMarketSegment__c;
            f.marketSubSegment__c = o.forecastMarketSubSegment__c;
            f.massProductionStartDate__c = o.forecastMassProductionStartDate__c;
            f.modelProgramName__c = o.forecastModelProgramName__c;
            f.monthsInProduction__c = integer.valueof(o.forecastMonthsInProduction__c);
            f.oliForecastCategory__c = o.forecastCategory__c;
            f.oliLastModifiedBy__c = o.LastModifiedById;
            f.oliLastModifiedDate__c = date.newinstance(o.LastModifiedDate.year(), o.LastModifiedDate.month(), o.LastModifiedDate.day());
            f.opportunity__c = o.OpportunityId;
            f.opportunityAge__c = o.Opportunity.Age__c;
            f.opportunityAmount__c = o.Opportunity.Amount;
            f.opportunityCloseDate__c = o.Opportunity.CloseDate;
            f.opportunityForecastCategory__c = o.Opportunity.ForecastCategory;
            f.opportunityLineItemId__c = o.id;
            f.opportunityName__c = o.Opportunity.Name;
            f.opportunityStage__c = o.Opportunity.StageName;
            f.ownerID = o.Opportunity.OwnerId;
            f.Product__c = o.Product2Id;
            f.productCode__c = o.forecastProductCode__c;
            f.productName__c = o.ProductName__c;
            // START CSMSF-50
            // check to see if previous forecast has changed product name and use that in the new forecast instead of the oppty value
            prevForecast = forecastOutputByOliIdActive.get(f.opportunityLineItemId__c);
            if (prevForecast != null) {
                system.debug('@@ JD last month product__c = ' + prevForecast.product + ' createdDate='+ prevForecast.createddate+ ' m1Date=' + prevForecast.m1Date);
                system.debug('@@ JD oppty product2Id = ' + o.Product2Id);
                if (prevForecast.product != o.Product2Id) {
                    f.Product__c  = prevForecast.product;
                    f.ProductName__c = prevForecast.productName;
                }
            }
            // END CSMSF-50
            f.productionVolume__c = o.forecastProductionVolumePartsMonth__c;
            f.programName__c = o.forecastProgramName__c;
            f.region__c = o.forecastRegion__c;
            f.shipToCustomer__c = o.forecastShipToCustomer__c;
            f.specification__c = o.specification__c;
            f.specificationNumber__c = o.specification__r.name;
            f.squareFeet__c = o.squareFeet__c;
            //f.thickness__c = o.thickness__c;    //code commented on 3rd march, 2020
            f.thickness__c = o.glassThickness__c != NULL ? Decimal.valueOf(o.glassThickness__c) : NULL;
            f.totalPrice__c = o.TotalPrice;
            f.totalQuantity__c = o.Quantity;
            f.finisherAccount__c = o.finisherAccount__c;
            f.finisherOwner__c = o.finisherOwner__c;
            f.finisherMix__c = o.finisherMix__c;
            //f.finisherYield__c = o.finisherYield__c;
            f.comments__c = o.comments__c;
            f.mixGorillaGlass__c = o.Opportunity.gorillaGlassPercent__c;
            f.mixCompetitiveMaterial__c = o.Opportunity.Competitive_Material__c;
            f.mixPanda__c = o.Opportunity.pandaPercent__c;
            f.mixCompetitiveGlasses__c = o.Opportunity.competitiveGlasses__c;
            f.mixAGC__c = o.Opportunity.agcPercent__c;
            f.mixSchott__c = o.Opportunity.schottPercent__c;
            f.mixNEG__c = o.Opportunity.negPercent__c;
            f.mixOther__c = o.Opportunity.otherPercent__c;
            f.deviceCategory__c = o.Opportunity.deviceCategory__c;
            f.productSegmentation__c = o.Opportunity.productSegmentation__c;
            f.finalFinishedGlassPartThickness__c = o.finalFinishedGlassPartThickness__c;
            f.finisherYield__c = o.Opportunity.massProductionYield__c;
            
            If (o.tpmOverride__c == Null) {
                f.tpmAccount__c = o.specification__r.tpm__r.id; 
                f.tpmOwner__c = o.specification__r.tpm__r.OwnerId;
            } else {
                f.tpmAccount__c = o.tpmOverride__c; 
                f.tpmOwner__c = o.tpmOverride__r.OwnerId;
            }
            
            f.treatment__c = o.treatment__c;
            f.width__c = o.width__c;
            
            
            //Initialize / 0 out Forecast       
            Date currentMonthDate = System.Date.today().toStartOfMonth();
            f.m1Date__c = currentMonthDate;
            f.m1Label__c = monthMap.get(currentMonthDate.Month()) + ', ' + currentMonthDate.Year();
            f.m1UnitPrice__c = 0;
            f.m1Qty__c = 0; 
            f.m1Rev__c = 0;
            f.m2Date__c = currentMonthDate.addMonths(1);
            f.m2Label__c = monthMap.get(currentMonthDate.addMonths(1).Month()) + ', ' + currentMonthDate.addMonths(1).Year();
            f.m2UnitPrice__c = 0;
            f.m2Qty__c = 0; 
            f.m2Rev__c = 0;
            f.m3Date__c = currentMonthDate.addMonths(2);
            f.m3Label__c = monthMap.get(currentMonthDate.addMonths(2).Month()) + ', ' + currentMonthDate.addMonths(2).Year();
            f.m3UnitPrice__c = 0;
            f.m3Qty__c = 0; 
            f.m3Rev__c = 0;
            f.m4Date__c = currentMonthDate.addMonths(3);
            f.m4Label__c = monthMap.get(currentMonthDate.addMonths(3).Month()) + ', ' + currentMonthDate.addMonths(3).Year();
            f.m4UnitPrice__c = 0;
            f.m4Qty__c = 0; 
            f.m4Rev__c = 0;
            f.m5Date__c = currentMonthDate.addMonths(4);
            f.m5Label__c = monthMap.get(currentMonthDate.addMonths(4).Month()) + ', ' + currentMonthDate.addMonths(4).Year();
            f.m5UnitPrice__c = 0;
            f.m5Qty__c = 0; 
            f.m5Rev__c = 0;
            f.m6Date__c = currentMonthDate.addMonths(5);
            f.m6Label__c = monthMap.get(currentMonthDate.addMonths(5).Month()) + ', ' + currentMonthDate.addMonths(5).Year();
            f.m6UnitPrice__c = 0;
            f.m6Qty__c = 0; 
            f.m6Rev__c = 0;
            f.m7Date__c = currentMonthDate.addMonths(6);
            f.m7Label__c = monthMap.get(currentMonthDate.addMonths(6).Month()) + ', ' + currentMonthDate.addMonths(6).Year();
            f.m7UnitPrice__c = 0;
            f.m7Qty__c = 0;
            f.m7Rev__c = 0;
            f.m8Date__c = currentMonthDate.addMonths(7);
            f.m8Label__c = monthMap.get(currentMonthDate.addMonths(7).Month()) + ', ' + currentMonthDate.addMonths(7).Year();
            f.m8UnitPrice__c = 0;
            f.m8Qty__c = 0; 
            f.m8Rev__c = 0;
            f.m9Date__c = currentMonthDate.addMonths(8);
            f.m9Label__c = monthMap.get(currentMonthDate.addMonths(8).Month()) + ', ' + currentMonthDate.addMonths(8).Year();
            f.m9UnitPrice__c = 0;
            f.m9Qty__c = 0; 
            f.m9Rev__c = 0;
            f.m10Date__c = currentMonthDate.addMonths(9);
            f.m10Label__c = monthMap.get(currentMonthDate.addMonths(9).Month()) + ', ' + currentMonthDate.addMonths(9).Year();
            f.m10UnitPrice__c = 0;
            f.m10Qty__c = 0; 
            f.m10Rev__c = 0;
            f.m11Date__c = currentMonthDate.addMonths(10);
            f.m11Label__c = monthMap.get(currentMonthDate.addMonths(10).Month()) + ', ' + currentMonthDate.addMonths(10).Year();
            f.m11UnitPrice__c = 0;
            f.m11Qty__c = 0; 
            f.m11Rev__c = 0;
            f.m12Date__c = currentMonthDate.addMonths(11);
            f.m12Label__c = monthMap.get(currentMonthDate.addMonths(11).Month()) + ', ' + currentMonthDate.addMonths(11).Year();
            f.m12UnitPrice__c = 0;
            f.m12Qty__c = 0; 
            f.m12Rev__c = 0;
            f.m13Date__c = currentMonthDate.addMonths(12);
            f.m13Label__c = monthMap.get(currentMonthDate.addMonths(12).Month()) + ', ' + currentMonthDate.addMonths(12).Year();
            f.m13UnitPrice__c = 0;
            f.m13Qty__c = 0; 
            f.m13Rev__c = 0;
            f.m14Date__c = currentMonthDate.addMonths(13);
            f.m14Label__c = monthMap.get(currentMonthDate.addMonths(13).Month()) + ', ' + currentMonthDate.addMonths(13).Year();
            f.m14UnitPrice__c = 0;
            f.m14Qty__c = 0; 
            f.m14Rev__c = 0;
            f.m15Date__c = currentMonthDate.addMonths(14);
            f.m15Label__c = monthMap.get(currentMonthDate.addMonths(14).Month()) + ', ' + currentMonthDate.addMonths(14).Year();
            f.m15UnitPrice__c = 0;
            f.m15Qty__c = 0; 
            f.m15Rev__c = 0;
            f.m16Date__c = currentMonthDate.addMonths(15);
            f.m16Label__c = monthMap.get(currentMonthDate.addMonths(15).Month()) + ', ' + currentMonthDate.addMonths(15).Year();
            f.m16UnitPrice__c = 0;
            f.m16Qty__c = 0; 
            f.m16Rev__c = 0;
            f.m17Date__c = currentMonthDate.addMonths(16);
            f.m17Label__c = monthMap.get(currentMonthDate.addMonths(16).Month()) + ', ' + currentMonthDate.addMonths(16).Year();
            f.m17UnitPrice__c = 0;
            f.m17Qty__c = 0; 
            f.m17Rev__c = 0;
            f.m18Date__c = currentMonthDate.addMonths(17);
            f.m18Label__c = monthMap.get(currentMonthDate.addMonths(17).Month()) + ', ' + currentMonthDate.addMonths(17).Year();
            f.m18UnitPrice__c = 0;
            f.m18Qty__c = 0; 
            f.m18Rev__c = 0;
            
            //Determine count begin position
            Date m1StartDate;
            
            If (o.OpportunityLineItemSchedules.size() > 0) {
                m1StartDate = o.OpportunityLineItemSchedules[0].ScheduleDate.toStartOfMonth();  
            } else {
                //This will force current forecast to all zeros
                m1StartDate = System.Date.today().toStartOfMonth().addMonths(-1);
            }       
            
            if (m1StartDate == System.Date.today().toStartOfMonth()) {
                count = 0;
            } else if (m1StartDate == System.Date.today().toStartOfMonth().addMonths(1)) {
                count = 1;            
            } else if (m1StartDate == System.Date.today().toStartOfMonth().addMonths(2)) {
                count = 2;            
            } else if (m1StartDate == System.Date.today().toStartOfMonth().addMonths(3)) {
                count = 3;            
            } else if (m1StartDate == System.Date.today().toStartOfMonth().addMonths(4)) {
                count = 4;            
            } else if (m1StartDate == System.Date.today().toStartOfMonth().addMonths(5)) {
                count = 5;            
            } else if (m1StartDate == System.Date.today().toStartOfMonth().addMonths(6)) {
                count = 6;            
            } else if (m1StartDate == System.Date.today().toStartOfMonth().addMonths(7)) {
                count = 7;            
            } else if (m1StartDate == System.Date.today().toStartOfMonth().addMonths(8)) {
                count = 8;            
            } else if (m1StartDate == System.Date.today().toStartOfMonth().addMonths(9)) {
                count = 9;            
            } else if (m1StartDate == System.Date.today().toStartOfMonth().addMonths(10)) {
                count = 10;            
            } else if (m1StartDate == System.Date.today().toStartOfMonth().addMonths(11)) {
                count = 11;            
            } else if (m1StartDate == System.Date.today().toStartOfMonth().addMonths(12)) {
                count = 12;            
            } else if (m1StartDate == System.Date.today().toStartOfMonth().addMonths(13)) {
                count = 13;            
            } else if (m1StartDate == System.Date.today().toStartOfMonth().addMonths(14)) {
                count = 14;            
            } else if (m1StartDate == System.Date.today().toStartOfMonth().addMonths(15)) {
                count = 15;            
            } else if (m1StartDate == System.Date.today().toStartOfMonth().addMonths(16)) {
                count = 16;            
            } else if (m1StartDate == System.Date.today().toStartOfMonth().addMonths(17)) {
                count = 17;            
            }
            system.debug('$$$ m1StartDate: ' + m1StartDate);
            system.debug('$$$ count: ' + count);
            
            for(OpportunityLineItemSchedule s : o.OpportunityLineItemSchedules) {
                If (count == 0) {
                    f.m1UnitPrice__c = Decimal.valueOf(s.Description);
                    f.m1Date__c = s.ScheduleDate;
                    f.m1Qty__c = s.Quantity; 
                    f.m1Rev__c = s.Revenue;
                }    
                If (count == 1) {
                    f.m2UnitPrice__c = Decimal.valueOf(s.Description);
                    f.m2Date__c = s.ScheduleDate;
                    f.m2Qty__c = s.Quantity; 
                    f.m2Rev__c = s.Revenue;                                        
                }    
                If (count == 2) {
                    f.m3UnitPrice__c = Decimal.valueOf(s.Description);
                    f.m3Date__c = s.ScheduleDate;
                    f.m3Qty__c = s.Quantity; 
                    f.m3Rev__c = s.Revenue;                                        
                }    
                If (count == 3) {
                    f.m4UnitPrice__c = Decimal.valueOf(s.Description);
                    f.m4Date__c = s.ScheduleDate;
                    f.m4Qty__c = s.Quantity; 
                    f.m4Rev__c = s.Revenue;                                        
                }    
                If (count == 4) {
                    f.m5UnitPrice__c = Decimal.valueOf(s.Description);
                    f.m5Date__c = s.ScheduleDate;
                    f.m5Qty__c = s.Quantity; 
                    f.m5Rev__c = s.Revenue;                                        
                }    
                If (count == 5) {
                    f.m6UnitPrice__c = Decimal.valueOf(s.Description);
                    f.m6Date__c = s.ScheduleDate;
                    f.m6Qty__c = s.Quantity; 
                    f.m6Rev__c = s.Revenue;                                        
                }    
                If (count == 6) {
                    f.m7UnitPrice__c = Decimal.valueOf(s.Description);
                    f.m7Date__c = s.ScheduleDate;
                    f.m7Qty__c = s.Quantity; 
                    f.m7Rev__c = s.Revenue;                                        
                }    
                If (count == 7) {
                    f.m8UnitPrice__c = Decimal.valueOf(s.Description);
                    f.m8Date__c = s.ScheduleDate;
                    f.m8Qty__c = s.Quantity; 
                    f.m8Rev__c = s.Revenue;                                        
                }    
                If (count == 8) {
                    f.m9UnitPrice__c = Decimal.valueOf(s.Description);
                    f.m9Date__c = s.ScheduleDate;
                    f.m9Qty__c = s.Quantity; 
                    f.m9Rev__c = s.Revenue;                                        
                }    
                If (count == 9) {
                    f.m10UnitPrice__c = Decimal.valueOf(s.Description);
                    f.m10Date__c = s.ScheduleDate;
                    f.m10Qty__c = s.Quantity; 
                    f.m10Rev__c = s.Revenue;                                        
                }    
                If (count == 10) {
                    f.m11UnitPrice__c = Decimal.valueOf(s.Description);
                    f.m11Date__c = s.ScheduleDate;
                    f.m11Qty__c = s.Quantity; 
                    f.m11Rev__c = s.Revenue;                                      
                }    
                If (count == 11) {
                    f.m12UnitPrice__c = Decimal.valueOf(s.Description);
                    f.m12Date__c = s.ScheduleDate;
                    f.m12Qty__c = s.Quantity; 
                    f.m12Rev__c = s.Revenue;                                        
                }  
                If (count == 12) {
                    f.m13UnitPrice__c = Decimal.valueOf(s.Description);
                    f.m13Date__c = s.ScheduleDate;
                    f.m13Qty__c = s.Quantity; 
                    f.m13Rev__c = s.Revenue;                                        
                }         
                If (count == 13) {
                    f.m14UnitPrice__c = Decimal.valueOf(s.Description);
                    f.m14Date__c = s.ScheduleDate;
                    f.m14Qty__c = s.Quantity; 
                    f.m14Rev__c = s.Revenue;                                        
                }  
                
                If (count == 14) {
                    f.m15UnitPrice__c = Decimal.valueOf(s.Description);
                    f.m15Date__c = s.ScheduleDate;
                    f.m15Qty__c = s.Quantity; 
                    f.m15Rev__c = s.Revenue;                                        
                }  
                
                If (count == 15) {
                    f.m16UnitPrice__c = Decimal.valueOf(s.Description);
                    f.m16Date__c = s.ScheduleDate;
                    f.m16Qty__c = s.Quantity; 
                    f.m16Rev__c = s.Revenue;                                        
                }  
                
                If (count == 16) {
                    f.m17UnitPrice__c = Decimal.valueOf(s.Description);
                    f.m17Date__c = s.ScheduleDate;
                    f.m17Qty__c = s.Quantity; 
                    f.m17Rev__c = s.Revenue;                                        
                }  
                
                If (count == 17) {
                    f.m18UnitPrice__c = Decimal.valueOf(s.Description);
                    f.m18Date__c = s.ScheduleDate;
                    f.m18Qty__c = s.Quantity; 
                    f.m18Rev__c = s.Revenue;                                        
                }           
                
                count = count + 1;
                
            }    
            
            //Recalculate the Amount.
            if(isCalculatefromPrev){
                if(forecastOutputByOliId.containsKey(f.opportunityLineItemId__c)){
                    f = calculateDelta(f, forecastOutputByOliId.get(f.opportunityLineItemId__c));
                }
            }

            if(forecastOutputByOliIdActive.containsKey(f.opportunityLineItemId__c)){
                f = copyCountPerMonthFields(f,forecastOutputByOliIdActive.get(f.opportunityLineItemId__c));
            }
            
            forecastToInsert.add(f); 
        }        
        
        return forecastToInsert;
    }
    
    private static Account sumUpAccount(ForecastOutput52Week__c f, Decimal prevCount){
        Decimal sumUpAmount = prevCount;
        Account acc = new Account();
        acc.Id = f.account__r.Id != NULL ? f.account__r.Id : f.account__c;
        Integer intialCount = System.Date.today().Month();
        System.debug('@@## intialCount : ' + intialCount);
        
        //JAN to DEC
        if(intialCount == 1){
            sumUpAmount += getDecimalValue(f.m1Rev__c) + getDecimalValue(f.m2Rev__c) + getDecimalValue(f.m3Rev__c) + getDecimalValue(f.m4Rev__c);
            sumUpAmount += getDecimalValue(f.m5Rev__c) + getDecimalValue(f.m6Rev__c) + getDecimalValue(f.m7Rev__c) + getDecimalValue(f.m8Rev__c);
            sumUpAmount += getDecimalValue(f.m9Rev__c) + getDecimalValue(f.m10Rev__c) + getDecimalValue(f.m11Rev__c) + getDecimalValue(f.m12Rev__c);
        }
        
        //FEB to DEC
        if(intialCount == 2){
            sumUpAmount += getDecimalValue(f.m1Rev__c) + getDecimalValue(f.m2Rev__c) + getDecimalValue(f.m3Rev__c) + getDecimalValue(f.m4Rev__c);
            sumUpAmount += getDecimalValue(f.m5Rev__c) + getDecimalValue(f.m6Rev__c) + getDecimalValue(f.m7Rev__c) + getDecimalValue(f.m8Rev__c);
            sumUpAmount += getDecimalValue(f.m9Rev__c) + getDecimalValue(f.m10Rev__c) + getDecimalValue(f.m11Rev__c);
        }
        
        //MAR to DEC
        if(intialCount == 3){
            sumUpAmount += getDecimalValue(f.m1Rev__c) + getDecimalValue(f.m2Rev__c) + getDecimalValue(f.m3Rev__c) + getDecimalValue(f.m4Rev__c);
            sumUpAmount += getDecimalValue(f.m5Rev__c) + getDecimalValue(f.m6Rev__c) + getDecimalValue(f.m7Rev__c) + getDecimalValue(f.m8Rev__c);
            sumUpAmount += getDecimalValue(f.m9Rev__c) + getDecimalValue(f.m10Rev__c);
        }
        
        //APR to DEC
        if(intialCount == 4){
            sumUpAmount += getDecimalValue(f.m1Rev__c) + getDecimalValue(f.m2Rev__c) + getDecimalValue(f.m3Rev__c) + getDecimalValue(f.m4Rev__c);
            sumUpAmount += getDecimalValue(f.m5Rev__c) + getDecimalValue(f.m6Rev__c) + getDecimalValue(f.m7Rev__c) + getDecimalValue(f.m8Rev__c);
            sumUpAmount += getDecimalValue(f.m9Rev__c);
        }
        
        //MAY to DEC
        if(intialCount == 5){
            sumUpAmount += getDecimalValue(f.m1Rev__c) + getDecimalValue(f.m2Rev__c) + getDecimalValue(f.m3Rev__c) + getDecimalValue(f.m4Rev__c);
            sumUpAmount += getDecimalValue(f.m5Rev__c) + getDecimalValue(f.m6Rev__c) + getDecimalValue(f.m7Rev__c) + getDecimalValue(f.m8Rev__c);
        }
        
        //JUN to DEC
        if(intialCount == 6){
            sumUpAmount += getDecimalValue(f.m1Rev__c) + getDecimalValue(f.m2Rev__c) + getDecimalValue(f.m3Rev__c) + getDecimalValue(f.m4Rev__c);
            sumUpAmount += getDecimalValue(f.m5Rev__c) + getDecimalValue(f.m6Rev__c) + getDecimalValue(f.m7Rev__c);
        }
        
        //JUL to DEC
        if(intialCount == 7){
            sumUpAmount += getDecimalValue(f.m1Rev__c) + getDecimalValue(f.m2Rev__c) + getDecimalValue(f.m3Rev__c) + getDecimalValue(f.m4Rev__c);
            sumUpAmount += getDecimalValue(f.m5Rev__c) + getDecimalValue(f.m6Rev__c);
        }
        
        //AUG to DEC
        if(intialCount == 8){
            sumUpAmount += getDecimalValue(f.m1Rev__c) + getDecimalValue(f.m2Rev__c) + getDecimalValue(f.m3Rev__c) + getDecimalValue(f.m4Rev__c);
            sumUpAmount += getDecimalValue(f.m5Rev__c);
        }
        
        //SEP to DEC
        if(intialCount == 9){
            sumUpAmount += getDecimalValue(f.m1Rev__c) + getDecimalValue(f.m2Rev__c) + getDecimalValue(f.m3Rev__c) + getDecimalValue(f.m4Rev__c);
        }
        
        //OCT to DEC
        if(intialCount == 10){
            sumUpAmount += getDecimalValue(f.m1Rev__c) + getDecimalValue(f.m2Rev__c) + getDecimalValue(f.m3Rev__c);
        }
        
        //NOV to DEC
        if(intialCount == 11){
            sumUpAmount += getDecimalValue(f.m1Rev__c) + getDecimalValue(f.m2Rev__c);
        }
        
        //DEC to DEC
        if(intialCount == 12){
            sumUpAmount += getDecimalValue(f.m2Rev__c);
        }
        
        System.debug('@@## sumUpAmount : ' + sumUpAmount);
        acc.Part_Revenue_Forecast__c = sumUpAmount;
        return acc;
    }   
    
    private static Decimal getDecimalValue(Decimal revenueAmount){
        return revenueAmount != NULL ? revenueAmount : 0;
    }
    
    public static void updateForeCastAccount(List<ForecastOutput52Week__c> forecastOutputList){
        Map<Id, Account> accountToUpdateById = new Map<Id, Account>();
        for(ForecastOutput52Week__c forecastOutput: forecastOutputList){
            Decimal prevCount = 0;
            if(accountToUpdateById.containsKey(forecastOutput.account__c)){
                Decimal tempPrevCount = accountToUpdateById.get(forecastOutput.account__c).Part_Revenue_Forecast__c;
                prevCount = tempPrevCount != NULL ? tempPrevCount : 0;
            }
            accountToUpdateById.put(forecastOutput.account__c, sumUpAccount(forecastOutput, prevCount));
        }
        System.debug('@@## ' + accountToUpdateById);
        if(accountToUpdateById.size() > 0){
            UPDATE accountToUpdateById.values();
        }
        
    }
    //Fuction to calculate delta for the forecast Outout based
    @testvisible
    private static ForecastOutput52Week__c calculateDelta(ForecastOutput52Week__c currentForecastM1, ForecastOutput52Week__c previousForecastM2){
        currentForecastM1.m1RevDelta__c  = getCalculateValue(currentForecastM1.m1Rev__c) - getCalculateValue(previousForecastM2.m2Rev__c);
        currentForecastM1.m2RevDelta__c  = getCalculateValue(currentForecastM1.m2Rev__c) - getCalculateValue(previousForecastM2.m3Rev__c);
        currentForecastM1.m3RevDelta__c  = getCalculateValue(currentForecastM1.m3Rev__c) - getCalculateValue(previousForecastM2.m4Rev__c);
        currentForecastM1.m4RevDelta__c  = getCalculateValue(currentForecastM1.m4Rev__c) - getCalculateValue(previousForecastM2.m5Rev__c);
        currentForecastM1.m5RevDelta__c  = getCalculateValue(currentForecastM1.m5Rev__c) - getCalculateValue(previousForecastM2.m6Rev__c);
        currentForecastM1.m6RevDelta__c  = getCalculateValue(currentForecastM1.m6Rev__c) - getCalculateValue(previousForecastM2.m7Rev__c);
        currentForecastM1.m7RevDelta__c  = getCalculateValue(currentForecastM1.m7Rev__c) - getCalculateValue(previousForecastM2.m8Rev__c);
        currentForecastM1.m8RevDelta__c  = getCalculateValue(currentForecastM1.m8Rev__c) - getCalculateValue(previousForecastM2.m9Rev__c);
        currentForecastM1.m9RevDelta__c  = getCalculateValue(currentForecastM1.m9Rev__c) - getCalculateValue(previousForecastM2.m10Rev__c);
        currentForecastM1.m10RevDelta__c  = getCalculateValue(currentForecastM1.m10Rev__c) - getCalculateValue(previousForecastM2.m11Rev__c);
        currentForecastM1.m11RevDelta__c  = getCalculateValue(currentForecastM1.m11Rev__c) - getCalculateValue(previousForecastM2.m12Rev__c);
        currentForecastM1.m12RevDelta__c  = getCalculateValue(currentForecastM1.m12Rev__c) - getCalculateValue(previousForecastM2.m13Rev__c);
        currentForecastM1.m13RevDelta__c  = getCalculateValue(currentForecastM1.m13Rev__c) - getCalculateValue(previousForecastM2.m14Rev__c);
        currentForecastM1.m14RevDelta__c  = getCalculateValue(currentForecastM1.m14Rev__c) - getCalculateValue(previousForecastM2.m15Rev__c);
        currentForecastM1.m15RevDelta__c  = getCalculateValue(currentForecastM1.m15Rev__c) - getCalculateValue(previousForecastM2.m16Rev__c);
        currentForecastM1.m16RevDelta__c  = getCalculateValue(currentForecastM1.m16Rev__c) - getCalculateValue(previousForecastM2.m17Rev__c);
        currentForecastM1.m17RevDelta__c  = getCalculateValue(currentForecastM1.m17Rev__c) - getCalculateValue(previousForecastM2.m18Rev__c);
        currentForecastM1.m18RevDelta__c  = getCalculateValue(currentForecastM1.m18Rev__c);
        
        currentForecastM1.m1QtyDelta__c  = getCalculateValue(currentForecastM1.m1Qty__c) -getCalculateValue(previousForecastM2.m2Qty__c);
        currentForecastM1.m2QtyDelta__c  = getCalculateValue(currentForecastM1.m2Qty__c) -getCalculateValue(previousForecastM2.m3Qty__c);
        currentForecastM1.m3QtyDelta__c  = getCalculateValue(currentForecastM1.m3Qty__c) -getCalculateValue(previousForecastM2.m4Qty__c);
        currentForecastM1.m4QtyDelta__c  = getCalculateValue(currentForecastM1.m4Qty__c) -getCalculateValue(previousForecastM2.m5Qty__c);
        currentForecastM1.m5QtyDelta__c  = getCalculateValue(currentForecastM1.m5Qty__c) -getCalculateValue(previousForecastM2.m6Qty__c);
        currentForecastM1.m6QtyDelta__c  = getCalculateValue(currentForecastM1.m6Qty__c) -getCalculateValue(previousForecastM2.m7Qty__c);
        currentForecastM1.m7QtyDelta__c  = getCalculateValue(currentForecastM1.m7Qty__c) -getCalculateValue(previousForecastM2.m8Qty__c);
        currentForecastM1.m8QtyDelta__c  = getCalculateValue(currentForecastM1.m8Qty__c) -getCalculateValue(previousForecastM2.m9Qty__c);
        currentForecastM1.m9QtyDelta__c  = getCalculateValue(currentForecastM1.m9Qty__c) -getCalculateValue(previousForecastM2.m10Qty__c);
        currentForecastM1.m10QtyDelta__c  = getCalculateValue(currentForecastM1.m10Qty__c) -getCalculateValue(previousForecastM2.m11Qty__c);
        currentForecastM1.m11QtyDelta__c  = getCalculateValue(currentForecastM1.m11Qty__c) -getCalculateValue(previousForecastM2.m12Qty__c);
        currentForecastM1.m12QtyDelta__c  = getCalculateValue(currentForecastM1.m12Qty__c) -getCalculateValue(previousForecastM2.m13Qty__c);
        currentForecastM1.m13QtyDelta__c  = getCalculateValue(currentForecastM1.m13Qty__c) -getCalculateValue(previousForecastM2.m14Qty__c);
        currentForecastM1.m14QtyDelta__c  = getCalculateValue(currentForecastM1.m14Qty__c) -getCalculateValue(previousForecastM2.m15Qty__c);
        currentForecastM1.m15QtyDelta__c  = getCalculateValue(currentForecastM1.m15Qty__c) -getCalculateValue(previousForecastM2.m16Qty__c);
        currentForecastM1.m16QtyDelta__c  = getCalculateValue(currentForecastM1.m16Qty__c) -getCalculateValue(previousForecastM2.m17Qty__c);
        currentForecastM1.m17QtyDelta__c  = getCalculateValue(currentForecastM1.m17Qty__c) -getCalculateValue(previousForecastM2.m18Qty__c);
        currentForecastM1.m18QtyDelta__c  = getCalculateValue(currentForecastM1.m18Qty__c);

/* Deprecated 21Jan2021 as this wasn't working due to fact that the current forecast square footage doesn't get calculated until record has been saved
**           and subsequently queried
        currentForecastM1.m1GlassSqFtDelta__c  = getCalculateValue(currentForecastM1.m1GlassSqFt__c) -getCalculateValue(previousForecastM2.m2GlassSqFt__c);
        currentForecastM1.m2GlassSqFtDelta__c  = getCalculateValue(currentForecastM1.m2GlassSqFt__c) -getCalculateValue(previousForecastM2.m3GlassSqFt__c);
        currentForecastM1.m3GlassSqFtDelta__c  = getCalculateValue(currentForecastM1.m3GlassSqFt__c) -getCalculateValue(previousForecastM2.m4GlassSqFt__c);
        currentForecastM1.m4GlassSqFtDelta__c  = getCalculateValue(currentForecastM1.m4GlassSqFt__c) -getCalculateValue(previousForecastM2.m5GlassSqFt__c);
        currentForecastM1.m5GlassSqFtDelta__c  = getCalculateValue(currentForecastM1.m5GlassSqFt__c) -getCalculateValue(previousForecastM2.m6GlassSqFt__c);
        currentForecastM1.m6GlassSqFtDelta__c  = getCalculateValue(currentForecastM1.m6GlassSqFt__c) -getCalculateValue(previousForecastM2.m7GlassSqFt__c);
        currentForecastM1.m7GlassSqFtDelta__c  = getCalculateValue(currentForecastM1.m7GlassSqFt__c) -getCalculateValue(previousForecastM2.m8GlassSqFt__c);
        currentForecastM1.m8GlassSqFtDelta__c  = getCalculateValue(currentForecastM1.m8GlassSqFt__c) -getCalculateValue(previousForecastM2.m9GlassSqFt__c);
        currentForecastM1.m9GlassSqFtDelta__c  = getCalculateValue(currentForecastM1.m9GlassSqFt__c) -getCalculateValue(previousForecastM2.m10GlassSqFt__c);
        currentForecastM1.m10GlassSqFtDelta__c  = getCalculateValue(currentForecastM1.m10GlassSqFt__c) -getCalculateValue(previousForecastM2.m11GlassSqFt__c);
        currentForecastM1.m11GlassSqFtDelta__c  = getCalculateValue(currentForecastM1.m11GlassSqFt__c) -getCalculateValue(previousForecastM2.m12GlassSqFt__c);
        currentForecastM1.m12GlassSqFtDelta__c  = getCalculateValue(currentForecastM1.m12GlassSqFt__c) -getCalculateValue(previousForecastM2.m13GlassSqFt__c);
        currentForecastM1.m13GlassSqFtDelta__c  = getCalculateValue(currentForecastM1.m13GlassSqFt__c) -getCalculateValue(previousForecastM2.m14GlassSqFt__c);
        currentForecastM1.m14GlassSqFtDelta__c  = getCalculateValue(currentForecastM1.m14GlassSqFt__c) -getCalculateValue(previousForecastM2.m15GlassSqFt__c);
        currentForecastM1.m15GlassSqFtDelta__c  = getCalculateValue(currentForecastM1.m15GlassSqFt__c) -getCalculateValue(previousForecastM2.m16GlassSqFt__c);
        currentForecastM1.m16GlassSqFtDelta__c  = getCalculateValue(currentForecastM1.m16GlassSqFt__c) -getCalculateValue(previousForecastM2.m17GlassSqFt__c);
        currentForecastM1.m17GlassSqFtDelta__c  = getCalculateValue(currentForecastM1.m17GlassSqFt__c) -getCalculateValue(previousForecastM2.m18GlassSqFt__c);
        currentForecastM1.m18GlassSqFtDelta__c  = getCalculateValue(currentForecastM1.m18GlassSqFt__c);
*/
        // START CSMSF-51
        Decimal sqFtperUnitPrev = (previousForecastM2.m2GlassSqFt__c / previousForecastM2.m2Qty__c) * (previousForecastM2.finisherYield__c/100);
 /*
        System.debug('@@ JD from oli:  finish yield=' + currentForecastM1.finisherYield__c);
        System.debug('@@ JD from prev: finish yield=' + previousForecastM2.finisherYield__c);
        System.debug('@@ JD sqFt per unit prev=' + sqFtperUnitPrev);    // this value has more decimal places than  ...
        System.debug('@@ JD sqFt from oli and in forecast=' + currentForecastM1.squareFeet__c); // .. this value, but the earlier value yields the data we see in the report
        System.debug('@@ JD curr1 m1 qty=' + currentForecastM1.m1Qty__c + ' total sqFt='+ (currentForecastM1.m1Qty__c*sqFtperUnitPrev) / (currentForecastM1.finisherYield__c/100));    
        System.debug('@@ JD curr2 m1 qty=' + currentForecastM1.m1Qty__c + ' total sqFt='+ (currentForecastM1.m1Qty__c*currentForecastM1.squareFeet__c) / (currentForecastM1.finisherYield__c/100));    
*/
        Decimal delta;
        Decimal qty;
        Decimal finisherYield = currentForecastM1.finisherYield__c/100; // this value (it is a percent, so need to convert for math) could have changed from previous forecast ...
        Decimal sqFtPerUnit=sqFtperUnitPrev;    // use previous forecast value for sq ft per unit, shouldn't change for new forecast same oppty
        //sqFtPerUnit=qty*currentForecastM1.squareFeet__c  // don't use this value as it appears the formula calculation is more accurate with the above value
        if (finisherYield > 0) {
            // update all the delta fields ...
            for (Integer month=1; month<18; month++) {
                qty = (Decimal) currentForecastM1.get('m'+month+'Qty__c');
                delta = ((qty*sqFtperUnit) / finisherYield) - 
                                            getCalculateValue((Decimal)previousForecastM2.get('m' + (month+1) + 'GlassSqFt__c')); 
                delta = delta.setScale(2);      // only use 2 decimal places ...
                currentForecastM1.put('m'+month+'GlassSqFtDelta__c',delta);
                //System.debug('@@ JD: ' + month+': qty=' + qty + ' delta='+delta + ' curr=' + ((qty*sqFtperUnit) / finisherYield) + ' prev=' +
                //                    getCalculateValue((Decimal)previousForecastM2.get('m' + (month+1) + 'GlassSqFt__c')));
            }
            currentForecastM1.m18GlassSqFtDelta__c = ((qty*sqFtperUnit) / finisherYield);
        }
        // END CSMSF-51
        return currentForecastM1;
    }
    
    //function to get the correct value.
    private static Decimal getCalculateValue(Decimal fieldVaue){
        if(fieldVaue == NULL){
            return 0;
        }else{
            return fieldVaue;
        }
    }
    
    //Function to get the Previous month Forecast ouptut based on the current seleted OLI.
    public static Map<id, ForecastOutput52Week__c> getM2ForecasteDetails(List<opportunityLineItem> oliList, String status){
        Map<id, opportunityLineItem> oliById = new Map<id, opportunityLineItem>();
        Map<id, ForecastOutput52Week__c> forecastOutputByOliId = new Map<id, ForecastOutput52Week__c>();
        
        for(opportunityLineItem oli: oliList){
            oliById.put(oli.Id, oli);
        }
        
        for(ForecastOutput52Week__c f: getPreviousForecast(oliById, status)){
            forecastOutputByOliId.put(f.opportunityLineItemId__c, f);
        }
        
        System.debug('@@## forecastOutputByOliId: ' + forecastOutputByOliId);
        return forecastOutputByOliId;
    }
    
    //Function to get the previous forecast based on the OLIs.
    private static List<ForecastOutput52Week__c> getPreviousForecast(Map<id, opportunityLineItem> oliIds,String status){
        List<ForecastOutput52Week__c> forecastOutputList = new List<ForecastOutput52Week__c>();
        Date previousMonthDate = System.Date.today().addMOnths(-1).toStartOfMonth();
        
        System.debug('@@## getPreviousForecast ' + previousMonthDate + '  ' + oliIds.keySet());
        try{
            forecastOutputLIst = [SELECT id, createdDate, ownerId, tpmOwner__c, plm__c,
                                  opportunityName__c, opportunity__c, productName__c, productCode__c, 
                                  shipToCustomer__c, massProductionStartDate__c, status__c, finisherYield__c,
                                  programCompleted__c, tpmAccount__c, m1Qty__c, m2Qty__c, m3Qty__c, m4Qty__c, m5Qty__c, 
                                  m6Qty__c, m7Qty__c, m8Qty__c, m9Qty__c, m10Qty__c, m11Qty__c, m12Qty__c, m13Qty__c, 
                                  m14Qty__c, m15Qty__c, m16Qty__c, m17Qty__c, m18Qty__c, 
                                  m1Label__c, m2Label__c, m3Label__c, m4Label__c, m5Label__c, m6Label__c, m7Label__c, 
                                  m8Label__c, m9Label__c, m10Label__c, m11Label__c, m12Label__c, m13Label__c, 
                                  m14Label__c, m15Label__c, m16Label__c, m17Label__c, m18Label__c, 
                                  m1UnitPrice__c, m2UnitPrice__c, m3UnitPrice__c, m4UnitPrice__c, m5UnitPrice__c, 
                                  m6UnitPrice__c, m7UnitPrice__c, m8UnitPrice__c, m9UnitPrice__c, m10UnitPrice__c, 
                                  m11UnitPrice__c, m12UnitPrice__c, m13UnitPrice__c, m14UnitPrice__c,
                                  m15UnitPrice__c, m16UnitPrice__c, m17UnitPrice__c, m18UnitPrice__c,
                                  m1Rev__c, m2Rev__c, m3Rev__c, m4Rev__c, m5Rev__c, 
                                  m6Rev__c, m7Rev__c, m8Rev__c, m9Rev__c, m10Rev__c, 
                                  m11Rev__c, m12Rev__c, m13Rev__c, m14Rev__c,
                                  m15Rev__c, m16Rev__c, m17Rev__c, m18Rev__c,
                                  m1Date__c, m2Date__c, m3Date__c, m4Date__c, m5Date__c, 
                                  m6Date__c, m7Date__c, m8Date__c, m9Date__c, m10Date__c, 
                                  m11Date__c, m12Date__c, m13Date__c,
                                  m14Date__c, m15Date__c, m16Date__c, m17Date__c, m18Date__c,
                                  m1GlassSqFt__c, m2GlassSqFt__c, m3GlassSqFt__c, m4GlassSqFt__c, m5GlassSqFt__c, 
                                  m6GlassSqFt__c, m7GlassSqFt__c, m8GlassSqFt__c, m9GlassSqFt__c, m10GlassSqFt__c, 
                                  m11GlassSqFt__c, m12GlassSqFt__c, m13GlassSqFt__c, m14GlassSqFt__c,
                                  m15GlassSqFt__c, m16GlassSqFt__c, m17GlassSqFt__c, m18GlassSqFt__c,
                                  oliLastModifiedDate__c, oliLastModifiedBy__r.Name, LastModifiedBy.Name, 
                                  LastModifiedDate, specificationNumber__c, currentOpportunityName__c, oemOwenerId__c, opportunityLineItemId__c
                                  FROM ForecastOutput52Week__c
                                  WHERE opportunityLineItemId__c IN: oliIds.keySet()
                                  AND m1Date__c =: previousMonthDate
                                  AND Status__c =: status];
            
        }catch(Exception e){
        }
        return forecastOutputLIst;
    }

    /**
    * @description Copy GG_forecastCountPerMonth__c and GG_forecastLastModifiedDate__c values from Active Forecast records to Locked Forecast records
    * @author Edgar Santillana | 12-09-2020 
    * @param currentForecast 
    * @param previousForecastActive 
    * @return ForecastOutput52Week__c 
    **/
    private static ForecastOutput52Week__c copyCountPerMonthFields(ForecastOutput52Week__c currentForecast, wrapperForecast previousForecastActive){
        currentForecast.GG_forecastCountPerMonth__c  = getCalculateValue(previousForecastActive.counterPerMonth);
        currentForecast.GG_forecastLastModifiedDate__c  = previousForecastActive.lastModifiedDate;
        return currentForecast;
    }


    /**
    * @description This method get all the active forecast current month records and copy GG_forecastCountPerMonth__c and GG_forecastLastModifiedDate__c values to locked forecast records current month, and in the end
        reset those fields on the active current month records
    * @author Edgar Santillana | 12-11-2020 
    * @param oliList 
    * @return Map<id, wrapperForecast> 
    **/
    public static Map<id, wrapperForecast> getActiveForcecastCurrentMonth(List<opportunityLineItem> oliList){
        List<ForecastOutput52Week__c> listForecastReset = new List<ForecastOutput52Week__c>();
        Map<id, opportunityLineItem> oliById = new Map<id, opportunityLineItem>();
        Map<id, wrapperForecast> forecastOutputByOliId = new Map<id, wrapperForecast>();

        Date previousMonthDate = System.Date.today().addMOnths(-1).toStartOfMonth();
        Date currentMonthDate = System.Date.today().toStartOfMonth();
        
        for(opportunityLineItem oli: oliList){
            oliById.put(oli.Id, oli);
        }
        
        for(ForecastOutput52Week__c f:[ SELECT Id, GG_forecastCountPerMonth__c, GG_forecastLastModifiedDate__c, opportunityLineItemId__c, m1Date__c
                                            FROM ForecastOutput52Week__c 
                                            WHERE opportunityLineItemId__c IN: oliById.keySet() 
                                            AND m1Date__c >= :currentMonthDate 
                                            AND Status__c = 'Active']){
                    wrapperForecast newForecast = new wrapperForecast();
                    newForecast.counterPerMonth = f.GG_forecastCountPerMonth__c;
                    newForecast.lastModifiedDate = f.GG_forecastLastModifiedDate__c;
                    forecastOutputByOliId.put(f.opportunityLineItemId__c, newForecast);

                System.debug('Created Date : ' + f.m1Date__c );
                System.debug('Current Date : ' + currentMonthDate );
                if(f.m1Date__c >= currentMonthDate){
                    ForecastOutput52Week__c tempForecast = new ForecastOutput52Week__c();
                    tempForecast.Id = f.Id;
                    tempForecast.GG_forecastCountPerMonth__c = 0;
                    listForecastReset.add(tempForecast);
                }
                
        }
        System.debug('Forecast Reset List : ' + listForecastReset );
        if(!listForecastReset.isEmpty() && listForecastReset.size() > 0){
            update listForecastReset;
        }
        
        System.debug('@@## forecastOutputByOliId: ' + forecastOutputByOliId);
        return forecastOutputByOliId;
    }

    /**
    * @description This method get all the active forecast previous month records and copy GG_forecastCountPerMonth__c and GG_forecastLastModifiedDate__c values to active forecast records current month
    * @author Edgar Santillana | 12-11-2020 
    * @param oliList 
    * @return Map<id, wrapperForecast> 
    **/
    public static Map<id, wrapperForecast> getActiveForcecastPreviousMonth(List<opportunityLineItem> oliList){
        List<ForecastOutput52Week__c> listForecastReset = new List<ForecastOutput52Week__c>();
        Map<id, opportunityLineItem> oliById = new Map<id, opportunityLineItem>();
        Map<id, wrapperForecast> forecastOutputByOliId = new Map<id, wrapperForecast>();

        Date previousMonthDate = System.Date.today().addMOnths(-1).toStartOfMonth();
        Date currentMonthDate = System.Date.today().toStartOfMonth();
        
        for(opportunityLineItem oli: oliList){
            oliById.put(oli.Id, oli);
        }
        
        for(ForecastOutput52Week__c f:[ SELECT Id, GG_forecastCountPerMonth__c, GG_forecastLastModifiedDate__c, opportunityLineItemId__c, m1Date__c, productName__c,product__c,createddate
                                            FROM ForecastOutput52Week__c 
                                            WHERE opportunityLineItemId__c IN: oliById.keySet() 
                                            AND m1Date__c >= :previousMonthDate 
                                            AND m1Date__c < :currentMonthDate 
                                            AND Status__c = 'Active']){
            wrapperForecast newForecast = new wrapperForecast();
            newForecast.counterPerMonth = f.GG_forecastCountPerMonth__c;
            newForecast.lastModifiedDate = f.GG_forecastLastModifiedDate__c;
            newForecast.productName = f.productName__c;
            newForecast.product = f.product__c;
            newForecast.m1Date = f.m1Date__c;
            newForecast.createdDate = f.createdDate;

            forecastOutputByOliId.put(f.opportunityLineItemId__c, newForecast);
        }

        System.debug('@@## forecastOutputByOliId: ' + forecastOutputByOliId);
        return forecastOutputByOliId;
    }

    public class wrapperForecast{

        Decimal counterPerMonth;
        Date lastModifiedDate;
        String productName;
        Id product;
        DateTime createdDate;
        Date m1Date;

        wrapperForecast(){
            counterPerMonth = 0;
            lastModifiedDate = null;
            productName ='';
            product = null;
            m1Date = null;
            createdDate = null;
        }

    }

}