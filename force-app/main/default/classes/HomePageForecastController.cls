/**
 * @description       : 
 * @author            : Edgar Santillana
 * @group             : 
 * @last modified on  : 12-22-2021
 * @last modified by  : Jim Dickerson
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   10-16-2020   Edgar Santillana   New two Fields Added to update when the user click on Save Schedule Record
 * 1.1   12-22-2020   Jim Dickerson		 Allow search to find older program/forecasts by checking a custom permission and using a dynamic query.
 
**/
public without sharing class HomePageForecastController {
    
    public static Boolean checkPLM() {
        id pId = UserInfo.getProfileId();
        system.debug('###: ' + pId);
        
        // PLM or Admin or Sale Effectiveness can see all Active
        if (pId == '00e1J000000h0jCQAQ' || pId == '00eo0000000xZvQAAU' || pId == '00e1J000001QuadQAC') {
            return TRUE;
        } else {
            return FALSE;
        }
    }
    
    // ********** EDIT SCHEDULE CONTROLLER METHODS **********
    @AuraEnabled
    public static List<ForecastOutput52Week__c> getForecastRecords(String forecastStr) {
        
        string uId18 = UserInfo.getUserId();
        string uId15 = String.valueOf(UserInfo.getUserId()).substring(0, 15);
        Boolean plm = checkPLM();
        Boolean overrideDate = OpportunityForecastActions.overrideM1date(); // 22Dec2020 check for custom permission to find older forecasts ...
        
        forecastStr = '%' + forecastStr+'%';
/* 22Dec2020 - replace static SOQL query with a dynamic one below ...       
        List<ForecastOutput52Week__c> fList = new List<ForecastOutput52Week__c>([SELECT id, createdDate, ownerId, tpmOwner__c, plm__c,
                                                                                 opportunityName__c, opportunity__c, productName__c, productCode__c, currentProductCode__c,shipToCustomer__c, massProductionStartDate__c, status__c,
                                                                                 programCompleted__c, tpmAccount__c, m1Qty__c, m2Qty__c, m3Qty__c, m4Qty__c, m5Qty__c, m6Qty__c, m7Qty__c, m8Qty__c, 
                                                                                 m9Qty__c, m10Qty__c, m11Qty__c, m12Qty__c, m13Qty__c, m14Qty__c, m15Qty__c, m16Qty__c, m17Qty__c, m18Qty__c, 
                                                                                 m1Label__c, m2Label__c, m3Label__c, m4Label__c, m5Label__c, m6Label__c, m7Label__c, m8Label__c, m9Label__c, m10Label__c, 
                                                                                 m11Label__c, m12Label__c, m13Label__c, m14Label__c, m15Label__c, m16Label__c, m17Label__c, m18Label__c, 
                                                                                 m1UnitPrice__c, m2UnitPrice__c, m3UnitPrice__c, m4UnitPrice__c, m5UnitPrice__c, m6UnitPrice__c, m7UnitPrice__c, 
                                                                                 m8UnitPrice__c, m9UnitPrice__c, m10UnitPrice__c, m11UnitPrice__c, m12UnitPrice__c, m13UnitPrice__c, m14UnitPrice__c,
                                                                                 m15UnitPrice__c, m16UnitPrice__c, m17UnitPrice__c, m18UnitPrice__c, m14Date__c, productLine__c,
                                                                                 oliLastModifiedDate__c, oliLastModifiedBy__r.Name, LastModifiedBy.Name, LastModifiedDate, specificationNumber__c, 
                                                                                 currentOpportunityName__c, oemOwenerId__c,
                                                                                 finisherAccount__c, finisherAccount__r.Name, finisherMix__c, finisherOwner__c, finisherYield__c, currentGlassAttributes__c, comments__c
                                                                                 , opportunity__r.OpportunityAutoNamePart1__c, opportunity__r.OpportunityAutoNamePart2__c	
                                                                                 FROM ForecastOutput52Week__c
                                                                                 WHERE (((ownerId =: uId18 OR ownerId IN :getOwnerIds(uId18) OR tpmOwner__c =: uId18 OR plm__c =:plm OR oemOwenerId__c =: uId15) 
                                                                                         AND (status__c = 'Active') AND (programCompleted__c = FALSE) AND (CreatedDate = THIS_MONTH))
                                                                                        AND(currentOpportunityName__c LIKE: forecastStr 
                                                                                            OR productName__c LIKE: forecastStr 
                                                                                            OR currentProductCode__c LIKE: forecastStr 
                                                                                            OR specificationNumber__c LIKE: forecastStr))
                                                                                 ORDER BY currentOpportunityName__c ASC]);

System.debug('orig query size=' + fList.size());
*/
        // 22Dec2020 -  new dynamic SOQL so that we can override the current month requirement ...
        Set<Id> ownerIds = getOwnerIds(uId18);
        //overrideDate=false;
 		String qString = 'SELECT id, createdDate, ownerId, tpmOwner__c, plm__c,' +
            'opportunityName__c, opportunity__c, productName__c, productCode__c, currentProductCode__c,shipToCustomer__c, massProductionStartDate__c, status__c,' +
            'programCompleted__c, tpmAccount__c, m1Qty__c, m2Qty__c, m3Qty__c, m4Qty__c, m5Qty__c, m6Qty__c, m7Qty__c, m8Qty__c,' +
            'm9Qty__c, m10Qty__c, m11Qty__c, m12Qty__c, m13Qty__c, m14Qty__c, m15Qty__c, m16Qty__c, m17Qty__c, m18Qty__c,' + 
            'm1Label__c, m2Label__c, m3Label__c, m4Label__c, m5Label__c, m6Label__c, m7Label__c, m8Label__c, m9Label__c, m10Label__c,' + 
            'm11Label__c, m12Label__c, m13Label__c, m14Label__c, m15Label__c, m16Label__c, m17Label__c, m18Label__c,' + 
            'm1UnitPrice__c, m2UnitPrice__c, m3UnitPrice__c, m4UnitPrice__c, m5UnitPrice__c, m6UnitPrice__c, m7UnitPrice__c,' + 
            'm8UnitPrice__c, m9UnitPrice__c, m10UnitPrice__c, m11UnitPrice__c, m12UnitPrice__c, m13UnitPrice__c, m14UnitPrice__c,' +
            'm15UnitPrice__c, m16UnitPrice__c, m17UnitPrice__c, m18UnitPrice__c, m14Date__c, productLine__c,' +
            'oliLastModifiedDate__c, oliLastModifiedBy__r.Name, LastModifiedBy.Name, LastModifiedDate, specificationNumber__c,' + 
            'currentOpportunityName__c, oemOwenerId__c,' +
            'finisherAccount__c, finisherAccount__r.Name, finisherMix__c, finisherOwner__c, finisherYield__c, currentGlassAttributes__c, comments__c,' +
            'opportunity__r.OpportunityAutoNamePart1__c, opportunity__r.OpportunityAutoNamePart2__c '+	
            'FROM ForecastOutput52Week__c ' +
            'WHERE (((ownerId = :uId18  OR ownerId IN :ownerIds OR tpmOwner__c = :uId18 OR plm__c = :plm OR oemOwenerId__c = :uId15) ';
        	if (overrideDate) {
                //qString += 'AND ((status__c = \'Active\' AND programCompleted__c = TRUE) OR (programCompleted__c = FALSE AND CreatedDate = THIS_MONTH)) ';
                qString += 'AND ((status__c = \'Active\' AND programCompleted__c = TRUE) OR (status__c = \'Active\' AND programCompleted__c=false AND createddate=THIS_MONTH))) ';
                //qString += 'AND (status__c = \'Active\') AND (programCompleted__c = TRUE)) ';  // works
            }
            else 
				qString += 'AND (status__c = \'Active\') AND (programCompleted__c = FALSE) AND (CreatedDate = THIS_MONTH)) ';  // works
            
            qString +=  '       AND(currentOpportunityName__c LIKE :forecastStr '+
            			'           OR productName__c LIKE :forecastStr '+
            			'           OR currentProductCode__c LIKE :forecastStr '+
            			'           OR specificationNumber__c LIKE :forecastStr)) '+          
						'ORDER BY currentOpportunityName__c ASC';
       
        List<ForecastOutput52Week__c> fList = database.query(qString); 
//System.debug('fList from db.query size='+fList.size());
		// 22Dec2020 end new dynamic SOQL so that we can override the current month requirement ...
 
        return fList;
    }
    
    @AuraEnabled
    public static List<ForecastOutput52Week__c> getForecastRecordDetail(Id recordId) {
        return new List<ForecastOutput52Week__c>([Select Id, opportunityLineItemId__c,
                                                  m1Qty__c, m2Qty__c, m3Qty__c, m4Qty__c, m5Qty__c, m6Qty__c, m7Qty__c, m8Qty__c, m9Qty__c, m10Qty__c, m11Qty__c, m12Qty__c,
                                                  m13Qty__c, m14Qty__c, m15Qty__c, m16Qty__c, m17Qty__c, m18Qty__c, 
                                                  m1Label__c, m2Label__c, m3Label__c, m4Label__c, m5Label__c, m6Label__c, m7Label__c, m8Label__c, m9Label__c, m10Label__c, 
                                                  m11Label__c, m12Label__c, m13Label__c, m14Label__c, m15Label__c, m16Label__c, m17Label__c, m18Label__c, 
                                                  m1UnitPrice__c, m2UnitPrice__c, m3UnitPrice__c, m4UnitPrice__c, m5UnitPrice__c, m6UnitPrice__c, 
                                                  m7UnitPrice__c, m8UnitPrice__c, m9UnitPrice__c, m10UnitPrice__c, m11UnitPrice__c, m12UnitPrice__c, m13UnitPrice__c, m14UnitPrice__c,
                                                  m15UnitPrice__c, m16UnitPrice__c, m17UnitPrice__c, m18UnitPrice__c, m14Date__c, productLine__c,
                                                  programCompleted__c, massProductionStartDate__c, opportunityName__c, productName__c, shipToCustomer__c,
                                                  finisherAccount__c, finisherAccount__r.Name, finisherAccount__r.RecordTypeId, finisherAccount__r.accountType__c, finisherAccount__r.OwnerId,
                                                  tpmAccount__r.Name, tpmAccount__r.RecordTypeId, tpmAccount__r.accountType__c, tpmAccount__r.OwnerId, 
                                                  finisherMix__c, finisherOwner__c, finisherYield__c, comments__c
                                                  FROM ForecastOutput52Week__c
                                                  WHERE id = :recordId]);
    }
    
    @AuraEnabled
    // ligtning passes Integers as decimals
    public static List<ForecastOutput52Week__c> updateForecastSchedule(String data) {
        UpdateForecastScheduleParams forecaseScheduleObj = (UpdateForecastScheduleParams)JSON.deserialize(data, UpdateForecastScheduleParams.class);
        System.debug('@@##' + forecaseScheduleObj.m15pUpdate);
        List<ForecastOutput52Week__c> updateList = new List<ForecastOutput52Week__c>();
        
        Integer i1 = forecaseScheduleObj.m1qUpdate == null ? 0 : forecaseScheduleObj.m1qUpdate.intValue();
        Integer i2 = forecaseScheduleObj.m2qUpdate == null ? 0 : forecaseScheduleObj.m2qUpdate.intValue();
        Integer i3 = forecaseScheduleObj.m3qUpdate == null ? 0 : forecaseScheduleObj.m3qUpdate.intValue();
        Integer i4 = forecaseScheduleObj.m4qUpdate == null ? 0 : forecaseScheduleObj.m4qUpdate.intValue();
        Integer i5 = forecaseScheduleObj.m5qUpdate == null ? 0 : forecaseScheduleObj.m5qUpdate.intValue();
        Integer i6 = forecaseScheduleObj.m6qUpdate == null ? 0 : forecaseScheduleObj.m6qUpdate.intValue();
        Integer i7 = forecaseScheduleObj.m7qUpdate == null ? 0 : forecaseScheduleObj.m7qUpdate.intValue();
        Integer i8 = forecaseScheduleObj.m8qUpdate == null ? 0 : forecaseScheduleObj.m8qUpdate.intValue();
        Integer i9 = forecaseScheduleObj.m9qUpdate == null ? 0 : forecaseScheduleObj.m9qUpdate.intValue();
        Integer i10 = forecaseScheduleObj.m10qUpdate == null ? 0 : forecaseScheduleObj.m10qUpdate.intValue();
        Integer i11 = forecaseScheduleObj.m11qUpdate == null ? 0 : forecaseScheduleObj.m11qUpdate.intValue();
        Integer i12 = forecaseScheduleObj.m12qUpdate == null ? 0 : forecaseScheduleObj.m12qUpdate.intValue();
        Integer i13 = forecaseScheduleObj.m13qUpdate == null ? 0 : forecaseScheduleObj.m13qUpdate.intValue();
        Integer i14 = forecaseScheduleObj.m14qUpdate == null ? 0 : forecaseScheduleObj.m14qUpdate.intValue();
        Integer i15 = forecaseScheduleObj.m15qUpdate == null ? 0 : forecaseScheduleObj.m15qUpdate.intValue();
        Integer i16 = forecaseScheduleObj.m16qUpdate == null ? 0 : forecaseScheduleObj.m16qUpdate.intValue();
        Integer i17 = forecaseScheduleObj.m17qUpdate == null ? 0 : forecaseScheduleObj.m17qUpdate.intValue();
        Integer i18 = forecaseScheduleObj.m18qUpdate == null ? 0 : forecaseScheduleObj.m18qUpdate.intValue();
        
        List<ForecastOutput52Week__c> fList = new List<ForecastOutput52Week__c>([Select Id, 
                                                                                 m1Qty__c, m2Qty__c, m3Qty__c, m4Qty__c, m5Qty__c, m6Qty__c, m7Qty__c, m8Qty__c, m9Qty__c, m10Qty__c, m11Qty__c, m12Qty__c,
                                                                                 m13Qty__c, m14Qty__c, m15Qty__c, m16Qty__c, m17Qty__c, m18Qty__c,
                                                                                 m1UnitPrice__c, m2UnitPrice__c, m3UnitPrice__c, m4UnitPrice__c, m5UnitPrice__c, m6UnitPrice__c, 
                                                                                 m7UnitPrice__c, m8UnitPrice__c, m9UnitPrice__c, m10UnitPrice__c, m11UnitPrice__c, m12UnitPrice__c, m13UnitPrice__c, m14UnitPrice__c,
                                                                                 m15UnitPrice__c, m16UnitPrice__c, m17UnitPrice__c, m18UnitPrice__c,
                                                                                 totalQuantity__c, totalPrice__c, opportunityAmount__c, 
                                                                                 m1Rev__c, m2Rev__c, m3Rev__c, m4Rev__c, m5Rev__c, m6Rev__c, m7Rev__c,
                                                                                 m8Rev__c, m9Rev__c, m10Rev__c, m11Rev__c, m12Rev__c, m13Rev__c, m14Rev__c,
                                                                                 m14Date__c, m15Date__c, m16Date__c, m17Date__c, m18Date__c, 
                                                                                 oliLastModifiedDate__c, oliLastModifiedBy__c, GG_forecastLastModifiedDate__c, GG_forecastCountPerMonth__c
                                                                                 FROM ForecastOutput52Week__c WHERE id = :forecaseScheduleObj.recordId]);
        
        For (ForecastOutput52Week__c f : fList) {
            f.m1Qty__c = i1;
            f.m2Qty__c = i2;
            f.m3Qty__c = i3;
            f.m4Qty__c = i4;
            f.m5Qty__c = i5;
            f.m6Qty__c = i6;
            f.m7Qty__c = i7;
            f.m8Qty__c = i8;
            f.m9Qty__c = i9;
            f.m10Qty__c = i10;
            f.m11Qty__c = i11;
            f.m12Qty__c = i12;
            f.m13Qty__c = i13;
            f.m14Qty__c = i14;
            f.m15Qty__c = i15;
            f.m16Qty__c = i16;
            f.m17Qty__c = i17;
            f.m18Qty__c = i18;
            
            f.m1UnitPrice__c = forecaseScheduleObj.m1pUpdate == null ? 0 : forecaseScheduleObj.m1pUpdate.setScale(2);
            f.m2UnitPrice__c = forecaseScheduleObj.m2pUpdate == null ? 0 : forecaseScheduleObj.m2pUpdate.setScale(2);
            f.m3UnitPrice__c = forecaseScheduleObj.m3pUpdate == null ? 0 : forecaseScheduleObj.m3pUpdate.setScale(2);
            f.m4UnitPrice__c = forecaseScheduleObj.m4pUpdate == null ? 0 : forecaseScheduleObj.m4pUpdate.setScale(2);
            f.m5UnitPrice__c = forecaseScheduleObj.m5pUpdate == null ? 0 : forecaseScheduleObj.m5pUpdate.setScale(2);
            f.m6UnitPrice__c = forecaseScheduleObj.m6pUpdate == null ? 0 : forecaseScheduleObj.m6pUpdate.setScale(2);
            f.m7UnitPrice__c = forecaseScheduleObj.m7pUpdate == null ? 0 : forecaseScheduleObj.m7pUpdate.setScale(2);
            f.m8UnitPrice__c = forecaseScheduleObj.m8pUpdate == null ? 0 : forecaseScheduleObj.m8pUpdate.setScale(2);
            f.m9UnitPrice__c = forecaseScheduleObj.m9pUpdate == null ? 0 : forecaseScheduleObj.m9pUpdate.setScale(2);
            f.m10UnitPrice__c = forecaseScheduleObj.m10pUpdate == null ? 0 : forecaseScheduleObj.m10pUpdate.setScale(2);
            f.m11UnitPrice__c = forecaseScheduleObj.m11pUpdate == null ? 0 : forecaseScheduleObj.m11pUpdate.setScale(2);
            f.m12UnitPrice__c = forecaseScheduleObj.m12pUpdate == null ? 0 : forecaseScheduleObj.m12pUpdate.setScale(2);
            f.m13UnitPrice__c = forecaseScheduleObj.m13pUpdate == null ? 0 : forecaseScheduleObj.m13pUpdate.setScale(2);
            f.m14UnitPrice__c = forecaseScheduleObj.m14pUpdate == null ? 0 : forecaseScheduleObj.m14pUpdate.setScale(2);
            f.m15UnitPrice__c = forecaseScheduleObj.m15pUpdate == null ? 0 : forecaseScheduleObj.m15pUpdate.setScale(2);
            f.m16UnitPrice__c = forecaseScheduleObj.m16pUpdate == null ? 0 : forecaseScheduleObj.m16pUpdate.setScale(2);
            f.m17UnitPrice__c = forecaseScheduleObj.m17pUpdate == null ? 0 : forecaseScheduleObj.m17pUpdate.setScale(2);
            f.m18UnitPrice__c = forecaseScheduleObj.m18pUpdate == null ? 0 : forecaseScheduleObj.m18pUpdate.setScale(2);
            
            f.totalQuantity__c = i1 + i2 + i3 + i4 + i5 + i6 + i7 + i8 + i9 + i10 + i11 + i12 + i13 + i14 + i15 + i16 + i17 + i18;
            f.totalPrice__c = i1 * forecaseScheduleObj.m1pUpdate + i2 * forecaseScheduleObj.m2pUpdate  + i3 * forecaseScheduleObj.m3pUpdate  
                + i4 * forecaseScheduleObj.m4pUpdate + i5 * forecaseScheduleObj.m5pUpdate  + i6 * forecaseScheduleObj.m6pUpdate  
                + i7 * forecaseScheduleObj.m7pUpdate  + i8 * forecaseScheduleObj.m8pUpdate + i9 * forecaseScheduleObj.m9pUpdate  
                + i10 * forecaseScheduleObj.m10pUpdate  + i11 * forecaseScheduleObj.m11pUpdate  + i12 * forecaseScheduleObj.m12pUpdate 
                + i13 * forecaseScheduleObj.m13pUpdate  + i14 * forecaseScheduleObj.m14pUpdate + i15 * forecaseScheduleObj.m15pUpdate 
                + i16 * forecaseScheduleObj.m16pUpdate + i17 * forecaseScheduleObj.m17pUpdate + i18 * forecaseScheduleObj.m18pUpdate;
            
            f.m1Rev__c = i1 * forecaseScheduleObj.m1pUpdate;
            f.m2Rev__c = i2 * forecaseScheduleObj.m2pUpdate;
            f.m3Rev__c = i3 * forecaseScheduleObj.m3pUpdate;
            f.m4Rev__c = i4 * forecaseScheduleObj.m4pUpdate;
            f.m5Rev__c = i5 * forecaseScheduleObj.m5pUpdate;
            f.m6Rev__c = i6 * forecaseScheduleObj.m6pUpdate;
            f.m7Rev__c = i7 * forecaseScheduleObj.m7pUpdate;
            f.m8Rev__c = i8 * forecaseScheduleObj.m8pUpdate;
            f.m9Rev__c = i9 * forecaseScheduleObj.m9pUpdate;
            f.m10Rev__c = i10 * forecaseScheduleObj.m10pUpdate;
            f.m11Rev__c = i11 * forecaseScheduleObj.m11pUpdate;
            f.m12Rev__c = i12 * forecaseScheduleObj.m12pUpdate;
            f.m13Rev__c = i13 * forecaseScheduleObj.m13pUpdate;
            f.m14Rev__c = i14 * forecaseScheduleObj.m14pUpdate;
            f.m15Rev__c = i15 * forecaseScheduleObj.m15pUpdate;
            f.m16Rev__c = i16 * forecaseScheduleObj.m16pUpdate;
            f.m17Rev__c = i17 * forecaseScheduleObj.m17pUpdate;
            f.m18Rev__c = i18 * forecaseScheduleObj.m18pUpdate;
            
            f.oliLastModifiedDate__c = Date.Today();
            f.oliLastModifiedBy__c = UserInfo.getUserId();
            
            f.comments__c = forecaseScheduleObj.comment;
            
            if(f.m15Date__c == NULL){
                f = setNextMonthDate(f);
            }

            if(f.GG_forecastLastModifiedDate__c == null || f.GG_forecastLastModifiedDate__c != System.today()){
                
                if( f.GG_forecastCountPerMonth__c == null){
                    f.GG_forecastCountPerMonth__c = 1;
                }else{
                    f.GG_forecastCountPerMonth__c += 1;
                }
            	f.GG_forecastLastModifiedDate__c = System.today(); 
            }
            
            updateList.add(f);
        }
        
        // this update will call a trigger on ForecastOutput52Week__c to update the actual schedule
        update updateList;
        
        List<ForecastOutput52Week__c> returnList = new List<ForecastOutput52Week__c>([Select Id, 
                                                                                      m1Qty__c, m2Qty__c, m3Qty__c, m4Qty__c, m5Qty__c, m6Qty__c, m7Qty__c, m8Qty__c, m9Qty__c, m10Qty__c, m11Qty__c, m12Qty__c,
                                                                                      m13Qty__c, m14Qty__c,
                                                                                      m1UnitPrice__c, m2UnitPrice__c, m3UnitPrice__c, m4UnitPrice__c, m5UnitPrice__c, m6UnitPrice__c, 
                                                                                      m7UnitPrice__c, m8UnitPrice__c, m9UnitPrice__c, m10UnitPrice__c, m11UnitPrice__c, m12UnitPrice__c,
                                                                                      m13UnitPrice__c, m14UnitPrice__c
                                                                                      FROM ForecastOutput52Week__c WHERE id = : forecaseScheduleObj.recordId]);    
        
        return returnList;
        
    }
    
    //Method to create new product related to the opportunity
    @AuraEnabled
    public static ResponseHandler addNewProduct(String opportunityId){
        try{
            Opportunity opp = getOpportunty(opportunityId);
            
            Id newProductId = getProductId(opp.Type);
            
            getLineItemInstace(newProductId, opp);
            return new ResponseHandler(true, '');
        }catch(Exception e){
            return new ResponseHandler(false, e.getMessage());
        }
    }
    
    private static Opportunity getOpportunty(String opportunityId){
        return [SELECT id, type,
                massProductionYield__c 
                FROM Opportunity
                WHERE id =: opportunityId];
    }
    
    private static void getLineItemInstace(String newProductId, Opportunity opp){
        OpportunityLineItem existinglineItem = [SELECT opportunityId, Unitprice, Product2Id, Quantity
                                                FROM OpportunityLineItem
                                                WHERE OpportunityId =: opp.Id
                                                LIMIT 1];
        OpportunityLineItem newlineItem = existinglineItem.clone(false, false, false, false);
        newlineItem.product2Id = newProductId;
        newlineItem.finisherYield__c = opp.massProductionYield__c;
        INSERT newlineItem;
    }
    
    
    private static Id getProductId(String productLine){
        String productName = '';
        if(productLine == 'Raw Glass'){
            productName = System.label.GGDefaultRawGlassProductName;
        }else if(productLine == 'Concore'){
            productName = System.label.GGDefaultCocoreProductName;
        }
        
        Product2 product = [SELECT id 
                            FROM Product2
                            WHERE Name =: productName
                            AND isForecasting__c = true
                            LIMIT 1];
        return product.id;
    }
    
    
    private static ForecastOutput52Week__c setNextMonthDate(ForecastOutput52Week__c f){
        
        Map<Integer,String> monthMap = ForecastHelper.getMonthMap();
        
        f.m15Date__c = f.m14Date__c.addMonths(1);
        f.m16Date__c = f.m14Date__c.addMonths(2);
        f.m17Date__c = f.m14Date__c.addMonths(3);
        f.m18Date__c = f.m14Date__c.addMonths(4);
        
        f.m15Label__c = monthMap.get(f.m15Date__c.Month());
        f.m16Label__c = monthMap.get(f.m16Date__c.Month());
        f.m17Label__c = monthMap.get(f.m17Date__c.Month());
        f.m18Label__c = monthMap.get(f.m18Date__c.Month());
        return f;
    }
    
    
    // ********** MANAGE SCHEDULES CONTROLLER METHODS **********
    @AuraEnabled
    // the record ID being passed is 
    public static List<OpportunityLineItem> getOLIsWithSchedules(Id recordId) {
        return new List<OpportunityLineItem>([Select Id, ProductName__c, forecastProductCode__c, 
                                              forecastShipToCustomer__c, specification__r.Name,
                                              finisherAccount__c, finisherAccount__r.Name, finisherMix__c, finisherYield__c, 
                                              opportunity.name, forecastHasForecast__c, forecastCategory__c, Glass_Attributes__c
                                              From OpportunityLineItem 
                                              Where OpportunityId = :recordId 
                                              AND forecastHasForecast__c = True]);
    }
    
    @AuraEnabled
    public static List<OpportunityLineItem> getOLIsWithoutSchedules(Id recordId) {
        return new List<OpportunityLineItem>([Select Id, ProductName__c, forecastProductCode__c, 
                                              forecastShipToCustomer__c, specification__r.Name, 
                                              finisherAccount__c, finisherAccount__r.Name, finisherMix__c, finisherYield__c,
                                              opportunity.name, forecastHasForecast__c, forecastCategory__c, Glass_Attributes__c
                                              From OpportunityLineItem 
                                              Where OpportunityId = :recordId 
                                              AND forecastHasForecast__c = False]);
    }
    
    @AuraEnabled
    public static List <String> copyRecords(List <String> lstRecordId, List <String> lstRecordIdTarget) {
        
        // copy must create new Active Forecast record and new PLM forecast and schedule
        List<OpportunityLineItem> oliListAdd = new List<OpportunityLineItem>();
        
        List <String> oErrorMsg = new List <String>();
        List<OpportunityLineItem> targetOliList = new List<OpportunityLineItem>();  
        Map<Id,OpportunityLineItem> o2oliMap = new Map<Id,OpportunityLineItem>();
        List<OpportunityLineItemSchedule> sourceOlisList = new List<OpportunityLineItemSchedule>(); 
        List<OpportunityLineItemSchedule> targetOlisList = new List<OpportunityLineItemSchedule>(); 
        
        if (lstRecordIdTarget.size() == 1) {
            targetOliList = [SELECT id, OpportunityId 
                             FROM OpportunityLineItem 
                             WHERE Id IN :lstRecordIdTarget];       
            for (OpportunityLineItem l: targetOliList) {
                o2oliMap.put(l.opportunityId, l);
            } 
        }    
        
        if (lstRecordId.size() == 1) {
            sourceOlisList = [SELECT id, Type, Revenue, Quantity, Description, ScheduleDate, 
                              OpportunityLineItemId, OpportunityLineItem.opportunityId 
                              FROM OpportunityLineItemSchedule 
                              WHERE OpportunityLineItemId IN :lstRecordId ];
            for (OpportunityLineItemSchedule sh: sourceOlisList) {
                opportunityLineItemSchedule ols = new opportunityLineItemSchedule();
                ols.ScheduleDate = sh.ScheduleDate;
                ols.opportunityLineItemID = o2oliMap.get(sh.OpportunityLineItem.opportunityId).id;
                ols.type = sh.Type;
                ols.Quantity = sh.Quantity;
                ols.Revenue = sh.Revenue;
                ols.Description = sh.Description; 
                targetOlisList.add(ols);
            }             
            
            if (targetOlisList.size() > 0 ) {
                Database.SaveResult[] SR_Ins = Database.insert(targetOlisList, false);
                for (Database.SaveResult sr: SR_Ins) {
                    if (sr.isSuccess()) {
                        system.debug('successful insert');
                    } else {   
                        oErrorMsg.add('');
                        for (Database.Error err: sr.getErrors()) {
                            oErrorMsg.add(err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                }
            } 
            
        } 
        
        if (targetOliList.size() > 0 ) {
            
            Date som = System.Date.today().toStartOfMonth();
            
            // requery OLI now that schedule is added, create 52 initial week forecast
            oliListAdd = [SELECT Id, Opportunity.Id, Opportunity.OwnerId, Opportunity.ForecastCategory, Opportunity.StageName, Opportunity.Amount, 
                          Opportunity.CloseDate, Opportunity.age__c, Opportunity.RecordTypeId, Opportunity.Name, Opportunity.AccountId,
                          Opportunity.gorillaGlassPercent__c, Opportunity.Competitive_Material__c, Opportunity.pandaPercent__c, Opportunity.agcPercent__c, 
                          Opportunity.schottPercent__c, Opportunity.negPercent__c, Opportunity.otherPercent__c, Opportunity.deviceCategory__c, 
                          Opportunity.productSegmentation__c, Opportunity.competitiveGlasses__c, Opportunity.massProductionYield__c,
                          forecastApplication__c, forecastBrandCustomer__c, coverScreenSize__c, glassComposition__c, 
                          glassCurvature__c, length__c, forecastMarketSegment__c,
                          forecastMarketSubSegment__c, forecastMassProductionStartDate__c, forecastModelProgramName__c, 
                          forecastMonthsInProduction__c, forecastCategory__c,
                          LastModifiedById, LastModifiedDate, Product2Id, forecastProductCode__c, forecastProductionVolumePartsMonth__c, ProductName__c,
                          forecastProgramName__c, forecastRegion__c, forecastShipToCustomer__c, specification__c,
                          specification__r.name, specification__r.tpm__r.id, specification__r.tpm__r.OwnerId, tpmOverride__c, tpmOverride__r.OwnerId,
                          squareFeet__c, thickness__c, TotalPrice, Quantity, treatment__c, width__c,
                          finisherAccount__c, finisherAccount__r.Name, finisherMix__c, finisherOwner__c, finisherYield__c, comments__c,glassThickness__c,
                          finalFinishedGlassPartThickness__c,
                          (SELECT Id, Quantity, Revenue, Description, ScheduleDate, LastModifiedById, LastModifiedDate 
                           FROM OpportunityLineItemSchedules WHERE ScheduleDate >= :som ORDER BY ScheduleDate ASC )        
                          FROM OpportunityLineItem 
                          WHERE HasQuantitySchedule = True 
                          AND HasRevenueSchedule = True 
                          AND Opportunity.RecordTypeId = '0121J000000U1cZQAS' 
                          AND id IN :targetOliList] ;       
            
            List<ForecastOutput52Week__c> forecast52ListForUpdateActive = ForecastHelper.process52(oliListAdd, 'Active');
            //List<ForecastOutput52Week__c> forecast52ListForUpdateActive = ForecastHelper.process52(oliListAdd, 'Locked');
            List<Database.SaveResult> results = new List<Database.SaveResult>();            
            results = Database.insert(forecast52ListForUpdateActive, false);
            //UPDATE ACCOUNT
            //ForecastHelper.updateForeCastAccount(forecast52ListForUpdateActive);
            
        }
        
        
        
        return oErrorMsg;
    }
    
    @AuraEnabled
    public static List <String> deleteRecords(List <String> lstRecordId) {  
        // delete the schedule for the OLI IDs passed
        // if we are deleting the schedule for the Default OLI, also delete the OLI 
        // transfer, copy and delete
        // transfer - active forecast will have been updated with new OLI
        // delete - OLI will be found
        
        List <String> oErrorMsg = new List <String>();
        
        List<OpportunityLineItemSchedule> olisList = new List<OpportunityLineItemSchedule>();                         
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();        
        List<OpportunityLineItem> toDeleteOliList = new List<OpportunityLineItem>(); 
        List<OpportunityLineItem> toUpdateOliList = new List<OpportunityLineItem>();
        List<ForecastOutput52Week__c> fList = new List<ForecastOutput52Week__c>();
        
        // in this squence - delete schedule, oli, and active forecast
        // delete Active and PLM or just Active?
        fList = [Select Id, opportunityLineItemID__c, status__c FROM ForecastOutput52Week__c WHERE status__c = 'Active' AND opportunityLineItemID__c IN :lstRecordId];
        
        // only delete OLI if it is the default forecast        
        oliList = [Select Id, isDefaultForecast__c, Quantity, UnitPrice, discount FROM OpportunityLineItem WHERE id IN :lstRecordId]; 
        for (OpportunityLineItem oli: oliList) {
            if (oli.isDefaultForecast__c == TRUE) {
                toDeleteOliList.add(oli);  
            } else {
                oli.Quantity = 1;
                oli.UnitPrice = 0;
                oli.Discount = 0;
                toUpdateOLIList.add(oli);
            }
        }
        
        if (lstRecordId.size() > 0 ) {
            System.debug('$$$ IN OLI: Query olisList');
            olisList = [SELECT id FROM OpportunityLineItemSchedule WHERE OpportunityLineItemId IN :lstRecordId ];
            
            // delete schedule first       
            if (olisList.size() > 0 ) {
                Database.DeleteResult[] DR_Dels = Database.delete(olisList, false);
                for (Database.DeleteResult dr: DR_Dels) {
                    if (dr.isSuccess()) {
                        system.debug('successful delete');
                    } else {   
                        oErrorMsg.add('');
                        for (Database.Error err: dr.getErrors()) {
                            oErrorMsg.add(err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                }
            } 
            
            if (toDeleteOliList.size() > 0) {
                delete toDeleteOliList;
            }
            
            if (flist.size() > 0) {
                delete flist;
            }
            
            if (toUpdateOliList.size() > 0) {
                update toUpdateOliList;
            }
            
        }
        
        return oErrorMsg;
        
    }       
    
    
    
    
    // ********** EDIT PRODUCT CONTROLLER METHODS **********
    @AuraEnabled
    public static List<ForecastOutput52Week__c> updateForecastDetails(Id recordId, Id accountId, Id accountOwnerId, 
                                                                      String accountName, Date mpStartDate,
                                                                      decimal finisherMix, decimal finisherYeild) {
                                                                          List<ForecastOutput52Week__c> updateList = new List<ForecastOutput52Week__c>();
                                                                          
                                                                          List<ForecastOutput52Week__c> fList = new List<ForecastOutput52Week__c>([Select Id, 
                                                                                                                                                   tpmAccount__c, tpmOwner__c, massProductionStartDate__c, oliLastModifiedDate__c, oliLastModifiedBy__c,
                                                                                                                                                   productLine__c, finisherAccount__c, finisherOwner__c, finisherMix__c, finisherYield__c
                                                                                                                                                   FROM ForecastOutput52Week__c WHERE id = :recordId]);
                                                                          
                                                                          For (ForecastOutput52Week__c f : fList) {
                                                                              if (accountId != Null) {
                                                                                  if(f.productLine__c == 'Raw Glass' || f.productLine__c == 'Concore'){
                                                                                      f.finisherAccount__c = accountId;
                                                                                      f.finisherOwner__c = accountOwnerId;
                                                                                      f.finisherMix__c = finisherMix;
                                                                                      f.finisherYield__c = finisherYeild;
                                                                                  }else{
                                                                                      f.tpmAccount__c = accountId;
                                                                                      f.shipToCustomer__c = accountName;
                                                                                      f.tpmOwner__c = accountOwnerId;
                                                                                  }
                                                                                  
                                                                              }
                                                                              if (mpStartDate != Null) {
                                                                                  f.massProductionStartDate__c = mpStartDate;
                                                                              }
                                                                              If (accountId != Null || mpStartDate != Null) {
                                                                                  updateList.add(f);
                                                                              }
                                                                              
                                                                              f.oliLastModifiedDate__c = Date.Today();
                                                                              f.oliLastModifiedBy__c = UserInfo.getUserId();
                                                                          }
                                                                          
                                                                          // this update will call a trigger on ForecastOutput52Week__c to update the actual schedule
                                                                          update updateList;
                                                                          
                                                                          List<ForecastOutput52Week__c> returnList = new List<ForecastOutput52Week__c>([Select Id, 
                                                                                                                                                        m1Qty__c, m2Qty__c, m3Qty__c, m4Qty__c, m5Qty__c, m6Qty__c, m7Qty__c, m8Qty__c, m9Qty__c, m10Qty__c, 
                                                                                                                                                        m11Qty__c, m12Qty__c, m13Qty__c, m14Qty__c, m15Qty__c, m16Qty__c, m17Qty__c, m18Qty__c,
                                                                                                                                                        m1UnitPrice__c, m2UnitPrice__c, m3UnitPrice__c, m4UnitPrice__c, m5UnitPrice__c, m6UnitPrice__c, 
                                                                                                                                                        m7UnitPrice__c, m8UnitPrice__c, m9UnitPrice__c, m10UnitPrice__c, m11UnitPrice__c, 
                                                                                                                                                        m12UnitPrice__c, m13UnitPrice__c, m14UnitPrice__c
                                                                                                                                                        FROM ForecastOutput52Week__c WHERE id = :recordId]);    
                                                                          
                                                                          return returnList;
                                                                          
                                                                      }
    
    @AuraEnabled
    public static List<ForecastOutput52Week__c> completeProgram(Id recordId) {      
        List<ForecastOutput52Week__c> updateList = new List<ForecastOutput52Week__c>();
        
        List<ForecastOutput52Week__c> fList = new List<ForecastOutput52Week__c>([Select Id, programCompleted__c, status__c
                                                                                 FROM ForecastOutput52Week__c WHERE id = :recordId]);
        
        For (ForecastOutput52Week__c f : fList) {
            f.programCompleted__c = TRUE;     
            f.status__c = 'Completed';                      
            updateList.add(f);
        }
        
        // this update will call a trigger on ForecastOutput52Week__c to update the actual schedule
        update updateList;
        
        List<ForecastOutput52Week__c> returnList = new List<ForecastOutput52Week__c>([Select Id, programCompleted__c,
                                                                                      m1Qty__c, m2Qty__c, m3Qty__c, m4Qty__c, m5Qty__c, m6Qty__c, m7Qty__c, m8Qty__c, m9Qty__c, m10Qty__c, 
                                                                                      m11Qty__c, m12Qty__c, m13Qty__c, m14Qty__c, m1UnitPrice__c, m2UnitPrice__c, m3UnitPrice__c, m4UnitPrice__c, 
                                                                                      m5UnitPrice__c, m6UnitPrice__c, m7UnitPrice__c, m8UnitPrice__c, m9UnitPrice__c, m10UnitPrice__c, m11UnitPrice__c, 
                                                                                      m12UnitPrice__c, m13UnitPrice__c, m14UnitPrice__c, m15UnitPrice__c, m16UnitPrice__c, m17UnitPrice__c, m18UnitPrice__c
                                                                                      FROM ForecastOutput52Week__c WHERE id = :recordId]);           
        
        return returnList;
        
    }
    
    //method to get all userIds based on the names of their role match with the name of permission sets assigned to the current user
    private static Set<Id> getOwnerIds(Id userId){
        List<String> permissionSetNames = new List<String>();
        Set<Id> userIds = new Set<Id>();
        
        //getting permission set Ids that are assigned to the current user from the junction object PermissionSetAssignment
        for(PermissionSetAssignment psa : [SELECT Id, AssigneeId, PermissionSetId, PermissionSet.Label  
                                           FROM PermissionSetAssignment WHERE AssigneeId = :userId]){
                                               System.debug(psa.PermissionSet.Label);
                                               if(psa.PermissionSet.Label.substringAfter('-').trim() != ''){
                                                   permissionSetNames.add(psa.PermissionSet.Label.substringAfter('-').trim());     
                                               }
                                           }
        System.debug('permissionSetNames==>' + permissionSetNames);
        //getting user which have roles matched with the part of string of permission Set
        if(permissionSetNames.size() > 0){ 
            Boolean first = true;
            String query = 'SELECT Id, UserRole.Name FROM User';
            for(String str : permissionSetNames){
                if(!first){
                    query = query + ' OR';
                } else {
                    query = query + ' WHERE';
                }
                query = query + ' UserRole.Name LIKE \'%' + str + '%\'';
                first = false;
            }
            System.debug('query ====> ' + query);
            
            for(User u : DataBase.query(query)){
                userIds.add(u.Id);	    
            }
        }
        System.debug('userIds==>' + userIds);
        //returning set of user ids to the getForecastRecords() function
        return userIds;
    }
    
    public class ResponseHandler{
        @AuraEnabled public boolean isuccess;
        @AuraEnabled public String errormessage;
        
        public ResponseHandler(boolean isuccess, String errormessage){
            this.isuccess = isuccess;
            this.errormessage = errormessage;
        }
    }
    
    public class UpdateForecastScheduleParams{
        Id recordId; 
        Decimal m1qUpdate;
        Decimal m2qUpdate;
        Decimal m3qUpdate; 
        Decimal m4qUpdate; 
        Decimal m5qUpdate; 
        Decimal m6qUpdate;
        Decimal m7qUpdate; 
        Decimal m8qUpdate; 
        Decimal m9qUpdate; 
        Decimal m10qUpdate; 
        Decimal m11qUpdate; 
        Decimal m12qUpdate;
        Decimal m13qUpdate;
        Decimal m14qUpdate;
        Decimal m15qUpdate;
        Decimal m16qUpdate; 
        Decimal m17qUpdate; 
        Decimal m18qUpdate;
        
        Decimal m1pUpdate; 
        Decimal m2pUpdate; 
        Decimal m3pUpdate; 
        Decimal m4pUpdate; 
        Decimal m5pUpdate; 
        Decimal m6pUpdate;
        Decimal m7pUpdate; 
        Decimal m8pUpdate; 
        Decimal m9pUpdate;
        Decimal m10pUpdate; 
        Decimal m11pUpdate;
        Decimal m12pUpdate;
        Decimal m13pUpdate; 
        Decimal m14pUpdate; 
        Decimal m15pUpdate; 
        Decimal m16pUpdate; 
        Decimal m17pUpdate; 
        Decimal m18pUpdate;
        String comment;
    }
    
}