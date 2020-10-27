/**
 * @File Name          : OpportunityLITriggerHelper.cls
 * @Description        : 
 * @Author             : Adam Nicholson? Atageldi Atageldiyev?
 * @Group              : 
 * @Last Modified By   : Arquimidez Mora
 * @Last Modified On   : 09-06-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.2    28/6/2020   Arquimidez Mora           Modified to clean Spec Id and Product Information Section when deleting product from Sample Request and delete related Sample Fulfillment
**/
///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 2/14/2017 ***///
///*** Class to help opportunity li trigger ***///
public class OpportunityLITriggerHelper{
    private static TriggerUtils.TriggerRunStatus runStatus = new TriggerUtils.TriggerRunStatus();
    static Utilities Utils = new Utilities();

    /**
    * @Method name  : handleAfterUpdate
    * @description Handles after update trigger event
    * @author Arquimidez Mora | 15/10/2019 
    * @param List<CampaignMember> lstRecords 
    * @return void 
    **/
    public static void handleAfterUpdate(List<OpportunityLineItem> lstRecords, Map<Id, OpportunityLineItem> mapOldRecords) {
        if(TriggerUtils.isFirstRunUpdate(runStatus)){            
            List<String> lstPrebuildOpportunities = new List<String>();
        
            for(OpportunityLineItem objLineItem : lstRecords){
                if(objLineItem.specification__c == null && objLineItem.GG_IsRequestPrebuild__c){
                    lstPrebuildOpportunities.add(objLineItem.OpportunityId);
                }
            }

            SetOpportunityStandardFlag(lstRecords); 
            setSampleFulfillment(lstRecords);

            if(lstPrebuildOpportunities.size() > 0){
                deleteProductAndFulfillmentInfo(lstPrebuildOpportunities, false);
            }
        }
    }
    
    //if all opportunity line items of an opportunity are standard products, flag the opportunity.isStandard__c = true
    // AN 12/12/18 - remove isStandard - not used, keep sample code
    public static void SetOpportunityStandardFlag(List<OpportunityLineItem> LIs) {
        System.debug('$$$ IN OLI: *** SetOpportunityStandardFlag');
        
        Set<Id> optyIds = new Set<Id>();
        
        List<Opportunity> optysToUpdate = new List<Opportunity>();
        Map<Id, Opportunity> optyMap = new Map<Id, Opportunity>();
        Opportunity o;
        for (OpportunityLineItem li: LIs){
            optyIds.add(li.OpportunityId);
        }
        
        //find all opportunity line items 
        System.debug('$$$ IN OLI: Query OpportunityLineItem');
        for (OpportunityLineItem li: [SELECT Id, specification__c, specification__r.approvedBy__c, 
                                      specification__r.location__c, specification__r.dsLocation__c, specification__r.innovation_type__c,specification__r.Name,specification__r.productCode__c, OpportunityID, 
                                      isSampleProduct__c, glassComposition__c, isStandard__c, GG_IsRequestPhyllo__c, PricebookEntry.Product2.Name FROM OpportunityLineItem WHERE OpportunityId in :optyIds]){
            if (optyMap.containsKey(li.OpportunityId)) { // map always null first pass
                if (!li.isStandard__c) { //set opportunity to not standard if any line items are not standard
                    // optyMap.get(li.OpportunityId).isStandard__c = li.isStandard__c; // AN 12/12/18
                }
            } else {                
                // o = new Opportunity(Id=li.OpportunityId, isStandard__c = li.isStandard__c); AN 12/12/18
                o = new Opportunity(Id=li.OpportunityId);
                // AN - 1/14/18 add glass composition and innovations - samples will only ever have 1 OLI BEGIN
                if (li.isSampleProduct__c == True) {
                    if(!li.GG_IsRequestPhyllo__c){
                        o.sampleGlassComposition__c = li.glassComposition__c;
                    }
                    if (li.specification__c != Null) { // Parts & MTO
                        o.sampleInnovations__c = li.specification__r.innovation_type__c;   
                        if (li.specification__r.approvedBy__c != Null) { // AN 5/21
                            o.specApprovedBy__c = li.specification__r.approvedBy__c;           
                        }
                        if (li.specification__r.location__c != Null) { // Parts
                            o.sampleCmLocations__c = li.specification__r.location__c;
                            if(li.specification__r.dsLocation__c != null && !String.isBlank(li.specification__r.dsLocation__c)){
                                o.sampleCmLocations__c += ';'+li.specification__r.dsLocation__c;
                            }
                            String[] tmpString = o.sampleCmLocations__c.split(';');
                            o.numberCmLocations__c = tmpString.size();
                        } else { // MTO
                            o.numberCmLocations__c = 0;
                        }
                        o.SpecId__c = li.specification__r.Name;
                        if(li.specification__r.productCode__c != null){
                            o.ProductCode__c = li.specification__r.productCode__c;
                        }
                    }else{
                        o.sampleInnovations__c = null;
                        o.specApprovedBy__c = null;
                        o.sampleCmLocations__c = null;
                        o.numberCmLocations__c = null;
                        o.SpecId__c = null;
                        o.ProductCode__c = null;
                        if(li.GG_IsRequestPhyllo__c){
                            o.sampleCmLocations__c = 'Not Applicable';
                            o.sampleFulfillmentLocations__c = 'Not Applicable';
                        }
                    }
                }
                // AN - 1/14/18 END
                optysToUpdate.add(o);
                optyMap.put(li.OpportunityId, o);
            }
            
        }
        
        System.debug('$$$ IN OLI: Update optysToUpdate - ' + optysToUpdate.size());
        update optysToUpdate; //update opportunities
    }
    
    //set specification lookup on opty line item to product's specification__c
    public static void setSpecificationLookup(List<OpportunityLineItem> olis, boolean copySpecFields) {
        System.debug('$$$ IN OLI: *** setSpecificationLookup');
        
        // AN 12/14/18 only update if needed
        List<OpportunityLineItem> reducedList = new List<OpportunityLineItem>();
        
        for (OpportunityLineItem li: olis){
            if (li.specification__c == Null) {
                reducedList.add(li);
            }            
        } 
        
        if (reducedList.size() > 0) {
            
            Set<Id> products = new Set<Id>();
            
            for (OpportunityLineItem li: reducedList){
                products.add(li.Product2Id);
            } 
            
            Map<Id, Product2> prMap = new Map<Id, product2>();
            Set<Id> specIds = new Set<Id>();
            
            System.debug('$$$ IN OLI: Query Product2');
            for (Product2 p: [SELECT Id, Specification__c FROM Product2 WHERE Id in :products]){
                prMap.put(p.Id, p);
                if (p.Specification__c != null){
                    specIds.add(p.Specification__c);
                }
            }
            
            Map<Id, Specification__c> specsMap = new Map<Id, Specification__c>();
            System.debug('$$$ IN OLI: Query Specification__c');
            for (Specification__c s: [SELECT Id, application__c, applicationOfGlass__c, marketSegment__c, marketSubSegment__c
                                      FROM Specification__C WHERE Id in :specIds]){
                                          specsMap.put(s.Id, s);
                                      }
            
            Product2 pr;
            Specification__c sp;
            for (OpportunityLineItem li: olis){
                pr = prMap.get(li.Product2Id);
                if (pr != null){
                    li.specification__c = pr.specification__c;
                    //on insert trigger, copy some values from specification to opportunity line item.
                    
                    
                    if (specsMap.containsKey(pr.Specification__c) && copySpecFields){
                        sp = specsMap.get(pr.Specification__c);
                        // 1/8/18 - add TPM lookup so the same specification can be changed to a different TPM
                        //li.marketSegment__c = sp.marketSegment__c;
                        //li.marketSubSegment__c = sp.marketSubSegment__c;
                        
                    }
                }
            }
        }            
    }
    
    public static void setSampleFulfillment(List<OpportunityLineItem> newList){
        System.debug('$$$ IN OLI: *** setSampleFulfillment');
        map<Id, Id> sampleRTs = new Map<Id, string>();
        map<Id, Id> oliToOpp = new map<Id,Id>();
        map<Id, SampleFulfillment__c> oIdToSFRecMap = new map<Id,SampleFulfillment__c>();
        list<Opportunity> oppList = new list<Opportunity>();
        list<SampleFulfillment__c> sfList = new list<SampleFulfillment__c>();
        
        //get record type ids of sample opportunity record types
        System.debug('$$$ IN OLI: Query RecordType');
        for (RecordType rt: [SELECT Id, Name FROM RecordType WHERE Name like '%sample%' AND SObjectType='opportunity']){
            sampleRTs.put(rt.Id, rt.Name);
        } 
        
        //map OLI to Opportunity Parent
        for (OpportunityLineItem li: newList){
            oliToOpp.put(li.Id,li.OpportunityId);
        }
        
        //Get Records for Sample Opportunities whose OLI's have changed
        System.debug('$$$ IN OLI: Query oppList & Sample_Fulfillment');
        oppList = [SELECT Id, requestingContact__c, sampleCmLocations__c, numberCmLocations__c, isPhyllo__c,
                   (SELECT Id, Quantity__c, Opportunity__c, shipToContact__c FROM Sample_Fulfillments__r) 
                   FROM Opportunity 
                   WHERE Id IN :oliToOpp.values() 
                   AND RecordTypeId IN :sampleRTs.keyset()]; 
        
        for (OpportunityLineItem li: newList){
            for (Opportunity o: oppList){
                if (o.id == li.OpportunityId) {
                    if(o.Sample_Fulfillments__r.size() == 1){ // Update the Sample Fulfillment Record
                        //system.debug('Sample_Fulfillments__r=' + o.Sample_Fulfillments__r);
                        SampleFulfillment__c theSample = new SampleFulfillment__c(Id=o.Sample_Fulfillments__r[0].Id);
                        theSample.specification__c = li.specification__c;
                        
                        // if (theSample.Quantity__c <> li.sampleQuantity__c || theSample.shipToContact__c <> o.requestingContact__c){
                        if (theSample.Quantity__c <> li.sampleQuantity__c) { // AN - 8/7/18 - remove ship to from sample fulfillment  
                            theSample.Quantity__c = li.sampleQuantity__c;
                            // theSample.shipToContact__c = o.requestingContact__c; // AN - 8/7/18 - remove ship to from sample fulfillment
                            sfList.add(theSample);
                        }
                    }   
                    else if (o.Sample_Fulfillments__r.size() == 0) { //Create a Sample Fulfillment Record
                        //system.debug('Opportunity='+o);
                        SampleFulfillment__c theSample = new SampleFulfillment__c();
                        theSample.Opportunity__c = o.Id;
                        theSample.Quantity__c = li.sampleQuantity__c;
                        // theSample.shipToContact__c = o.requestingContact__c; // AN - 8/7/18 - remove ship to from sample fulfillment
                        // AN 1/14/18 - auto assign CM if only one CM
                        if (o.numberCmLocations__c == 1) {
                            System.debug('***- Opp: '+o.Id);
                            System.debug('***- Opp: '+o.sampleCmLocations__c);
                            if(!(o.sampleCmLocations__c != null && o.sampleCmLocations__c.contains(';'))){
                                theSample.fulfillmentLocation__c = o.sampleCmLocations__c;
                            }
                        }
                        //Product is Phyllo
                        if(o.isPhyllo__c){
                            theSample.fulfillmentLocation__c = 'Not Applicable';
                        }
                        // AN 1/14/18 END
                        sfList.add(theSample);
                    }
                    else {
                        //Invalid Condition - Should Never Get Here
                    }
                }
            }
        }
        //system.debug('sfList=' + sfList);
        if (sfList.size() > 0){
            upsert sfList;
        }
    }
    
    //if forecastHasForecast__c = true OLI cannot be deleted if only schedule
    public static void CheckHasForecast(List<OpportunityLineItem> LIs){
        System.debug('$$$ IN OLI: *** CheckHasForecast');
        for (OpportunityLineItem li: LIs) {
            if (li.forecastHasForecast__c == true) {
                li.addError(Label.DeleteOLIError);
            }
        }
    }
    
    // Transfer Default Forecast on Approved Spec Addition if Default Forecast exists
    // Transfer = Add to new OLI and Delete from original OLI. Shedules are immutable
    public static void TransferDefaultForecast(List<OpportunityLineItem> LIs) {
        System.debug('$$$ IN OLI: *** TransferDefaultForecast');
        
        Set<Id> oSet = new Set<Id>(); // set of opportunity IDs from Line Item list
        Set<Id> dSet = new Set<Id>(); // set of opportunity line item IDs that will be deleted
        Set<Id> olisSet = new Set<Id>(); // set of schedule lines to delete
        
        Map<Id,OpportunityLineItem> o2oliMap = new Map<Id,OpportunityLineItem>();
        Map<Id,OpportunityLineItem> oli2oliMap = new Map<Id,OpportunityLineItem>();
        Map<Id,Id> oldOli2newOliMap = new Map<Id,Id>();
        
        List<OpportunityLineItem> toDeleteOliList = new List<OpportunityLineItem>();
        List<ForecastOutput52Week__c> toUpdateForecastOutputList = new List<ForecastOutput52Week__c>();
        List<OpportunityLineItemSchedule> olisList = new List<OpportunityLineItemSchedule>(); 
        List<OpportunityLineItemSchedule> toUpdateOlisList = new List<OpportunityLineItemSchedule>(); 
        List<OpportunityLineItemSchedule> toDeleteOlisList = new List<OpportunityLineItemSchedule>();
        
        for (OpportunityLineItem l: LIs){
            // just want OLIs that are added from approved specs and the opportunity contains a Default Forecast
            if (l.addedBySystem__c == True && l.containsDefaultForecast__c == True && l.isDefaultForecast__c == False){
                oSet.add(l.opportunityId);
                o2oliMap.put(l.opportunityId, l);
                oli2oliMap.put(l.id, l);
            }
        } 
        
        // query the default product line item to delete after moving the shedule to the approved product
        toDeleteOliList = [SELECT id, OpportunityId, isDefaultForecast__c FROM OpportunityLineItem WHERE OpportunityId IN :oSet AND isDefaultForecast__c = True];
        for (OpportunityLineItem d: toDeleteOliList){
            dSet.add(d.Id);
        } 
        
        // query the active product forecasts from the default product to transfer to the new line item
        // *** 5/14/19 *** just update the most recent active
        
        toUpdateForecastOutputList = [SELECT id, date__c, status__c, shipToCustomer__c, tpmAccount__c, tpmOwner__c,
                                      oliLastModifiedBy__c, oliLastModifiedDate__c, oliForecastCategory__c, productName__c, productionVolume__c,
                                      opportunityLineItemID__c, Product__c, specification__c, specificationNumber__c, squareFeet__c, coverScreenSize__c, 
                                      glassComposition__c, width__c, length__c, thickness__c, glassCurvature__c, treatment__c
                                      FROM ForecastOutput52Week__c WHERE opportunityLineItemID__c IN :dSet AND status__c = 'Active'];   
        
        
        
        if (dSet.size() > 0 ) {
            System.debug('$$$ IN OLI: Query olisList');
            olisList = [SELECT id, Type, quantity, revenue, description, ScheduleDate, OpportunityLineItemId, OpportunityLineItem.opportunityId FROM OpportunityLineItemSchedule WHERE OpportunityLineItemId IN :dSet ];
            for (OpportunityLineItemSchedule sh: olisList) {
                
                opportunityLineItemSchedule ols = new opportunityLineItemSchedule();
                ols.ScheduleDate = sh.ScheduleDate;
                ols.opportunityLineItemID = o2oliMap.get(sh.OpportunityLineItem.opportunityId).id;
                ols.type = sh.Type;
                ols.Quantity = sh.Quantity;
                ols.Revenue = sh.Revenue;
                ols.Description = sh.Description;      
                
                oldOli2newOliMap.put(sh.OpportunityLineItemId, o2oliMap.get(sh.OpportunityLineItem.opportunityId).id); // map the old OLI Id to the new OLI Id                                           
                toUpdateOlisList.add(ols);
                toDeleteOlisList.add(sh);
                // olisSet.add(sh.id); // use in @future method - must pass Ids
            } 
            
            // Update forecast output with new OLI information
            Id oldId;
            Id newId;
            
            for (ForecastOutput52Week__c f: toUpdateForecastOutputList) {
                oldId = f.opportunityLineItemID__c;
                newId = oldOli2newOliMap.get(oldId);
                
                f.shipToCustomer__c = oli2oliMap.get(newId).forecastShipToCustomer__c;
                f.tpmAccount__c = oli2oliMap.get(newId).tpmId__c;
                f.tpmOwner__c = oli2oliMap.get(newId).tpmOwnerId__c;
                f.oliLastModifiedBy__c = oli2oliMap.get(newId).LastModifiedById;
                f.oliLastModifiedDate__c = date.newinstance(oli2oliMap.get(newId).LastModifiedDate.year(), oli2oliMap.get(newId).LastModifiedDate.month(), oli2oliMap.get(newId).LastModifiedDate.day());
                f.oliForecastCategory__c = oli2oliMap.get(newId).forecastCategory__c;
                f.opportunityLineItemID__c = newId;
                f.Product__c = oli2oliMap.get(newId).product2Id;
                f.productName__c = oli2oliMap.get(newId).productName__c;
                f.productionVolume__c = oli2oliMap.get(newId).forecastProductionVolumePartsMonth__c;
                f.specification__c = oli2oliMap.get(newId).specification__c;
                f.specificationNumber__c = oli2oliMap.get(newId).specificationNumber__c;
                f.squareFeet__c = oli2oliMap.get(newId).squareFeet__c;
                f.coverScreenSize__c = oli2oliMap.get(newId).coverScreenSize__c;
                f.glassComposition__c = oli2oliMap.get(newId).glassComposition__c;
                f.width__c = oli2oliMap.get(newId).width__c;
                f.length__c = oli2oliMap.get(newId).length__c;
                f.thickness__c = oli2oliMap.get(newId).thickness__c;
                f.glassCurvature__c = oli2oliMap.get(newId).glassCurvature__c;
                f.treatment__c = oli2oliMap.get(newId).treatment__c;                
            } 
            
            update toUpdateForecastOutputList;
            
            System.debug('$$$ IN OLI: Insert toUpdateOlisList - ' + toUpdateOlisList.size());
            insert toUpdateOlisList;
            
            
            if (toDeleteOlisList.size() > 0 ) {
                //    AsyncDeleteDefaultProduct.process(olisSet); // delete in the future
                delete toDeleteOlisList;
                delete toDeleteOliList;
            }
            
            
        }
    }
    
    
    public static void onAfterInsert(List<OpportunityLineItem> oliList){
        
        Map<Id, Product2> productById = getProducts(oliList);
        Map<Id, Opportunity> opportunityById = getOpportunities(oliList);
        
        updatePrebuildOpptOnInsert(oliList, productById, opportunityById);
        
        updatePhylloOpptOnInsert(oliList, productById, opportunityById);
        
    }
    
    //method to update opportunity, such that if any product attached to the opportunity has the "isPrebuild" checked, 
    //then it will make this "isPreBuild" on the Opportunity(SR) also checked.
    private static void updatePrebuildOpptOnInsert(List<OpportunityLineItem> oliList, Map<Id, Product2> productById, Map<Id, Opportunity> opportunityById){
        
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        
        //getting record type Id by describing the Opportunity object and record type
        Id oppSRRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('GG Parts Sample Request').getRecordTypeId();
        
        //checking the pre build product and if it is true then updating the opportunity
        for(OpportunityLineItem oli : oliList){
            if(productById.get(oli.Product2Id).isPrebuild__c 
               && opportunityById.get(oli.OpportunityId).RecordTypeId == oppSRRecordTypeId
               && opportunityById.get(oli.OpportunityId).isPrebuild__c != true){
                   Opportunity opp = new Opportunity(Id = oli.OpportunityId, isPrebuild__c = true);
                   oppsToUpdate.add(opp);
               }
        }
        System.debug('$$$ Opps to Update : ' + oppsToUpdate);
        if(oppsToUpdate.size() > 0){
            UPDATE oppsToUpdate;
        }
    }
    
    //method to update opportunity, such that if any product attached to the opportunity has the "IsPhyllo" checked, 
    //then it will make this "IsPhyllo" on the Opportunity(SR) also checked
    private static void updatePhylloOpptOnInsert(List<OpportunityLineItem> oliList, Map<Id, Product2> productById, Map<Id, Opportunity> opportunityById){
        
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        
        //getting record type Id by describing the Opportunity object and record type
        Id oppSRRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('GG Parts Sample Request').getRecordTypeId();
        
        //checking the Phyllo product and if it is true then updating the opportunity
        for(OpportunityLineItem oli : oliList){
            if(productById.get(oli.Product2Id).IsPhyllo__c 
               && opportunityById.get(oli.OpportunityId).RecordTypeId == oppSRRecordTypeId
               && opportunityById.get(oli.OpportunityId).IsPhyllo__c != true){
                   Opportunity opp = new Opportunity(Id = oli.OpportunityId, IsPhyllo__c = true);
                   oppsToUpdate.add(opp);
               }
        }
        System.debug('$$$ Opps to Update : ' + oppsToUpdate);
        if(oppsToUpdate.size() > 0){
            UPDATE oppsToUpdate;
        }
    }
    
    
    public static void onAfterDelete(List<OpportunityLineItem> lstOldLineItems, Map<Id, OpportunityLineItem> mapOldLineItems){        
        Map<Id, Opportunity> mapPhylloOpportunities = new Map<Id, Opportunity>();
        List<OpportunityLineItem> oLIsWithoutSpec = new List<OpportunityLineItem>();
        List<String> lstSampleOpportunities = new List<String>();
        
        for(OpportunityLineItem objLineItem : lstOldLineItems){
            if(objLineItem.GG_IsRequestPrebuild__c || objLineItem.isSampleProduct__c){
                lstSampleOpportunities.add(objLineItem.OpportunityId);
            }
            if(objLineItem.GG_IsRequestPhyllo__c){
                mapPhylloOpportunities.put(objLineItem.OpportunityId, null);
            }
        }

        if(lstSampleOpportunities.size() > 0){
            deleteProductAndFulfillmentInfo(lstSampleOpportunities, true);
        }
        if(mapPhylloOpportunities.size() > 0){
            updatePhylloOpptOnDelete(lstOldLineItems, mapPhylloOpportunities);
        }
    }
    
    /**
    * @description Clean Spec Id and Product Information Section when deleting product from a Prebuild Sample Request and delete related Sample Fulfillment
    * @author Arquimidez Mora | 28/6/2020 
    * @param List<String> lstPrebuildOpportunities
    * @return void 
    **/
    private static void deleteProductAndFulfillmentInfo(List<String> lstSampleOpportunities, Boolean isDelete){
        List<SampleFulfillment__c> lstFulfillments = new List<SampleFulfillment__c>();
        List<Opportunity> lstOppotunities = new List<Opportunity>();

        for(SampleFulfillment__c objFulfillment :[SELECT Id FROM SampleFulfillment__c where Opportunity__c IN :lstSampleOpportunities]){
            lstFulfillments.add(objFulfillment);
        }

        if(lstFulfillments.size() > 0){
            delete lstFulfillments;
        }
        
        //Checking if the deleted product is prebuild and related opportunity is also prebuild then perform the update operation
        for(String opportunityId :lstSampleOpportunities){
            Opportunity objSampleRequest = new Opportunity(Id = opportunityId,
                SpecId__c = null,
                ProductCode__c = null,
                sampleGlassComposition__c = null,
                sampleInnovations__c = null,
                sampleCmLocations__c = null,
                numberCmLocations__c = null,
                specApprovedBy__c = null
            );
            if(isDelete){
                objSampleRequest.isPreBuild__c = false;
            }
            lstOppotunities.add(objSampleRequest);
        }
        
        System.debug('***- Clean lstOppotunities: ' + lstOppotunities);
        if(lstOppotunities.size() > 0){
            update lstOppotunities;
        }
    }
    
    //method to update opportunity IsPhyllo field to false if a Phyllo product is deleted from Opportunity
    //and no Phyllo product is left in the same opportunity
    public static void updatePhylloOpptOnDelete(List<OpportunityLineItem> lstOldLineItems, Map<Id, Opportunity> mapPhylloOpportunities){
        //getting opportunity and all the related OpportunityLineItems with product details
        for(Opportunity opp : [SELECT Id, internalChargeNumber__c, RecordTypeId, isPrebuild__c, IsPhyllo__c
        ,(SELECT Id, Product2.isPrebuild__c, Product2.IsPhyllo__c FROM OpportunityLineItems)
        FROM Opportunity 
        WHERE Id IN :mapPhylloOpportunities.keySet()]){
            mapPhylloOpportunities.put(opp.Id, opp);
        }

        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        
        //Checking if the deleted product is Phyllo and related opportunity is also Phyllo then perform the update operation
        for(OpportunityLineItem oldOli : lstOldLineItems){
            if(mapPhylloOpportunities.get(oldOli.OpportunityId).IsPhyllo__c == true){
                Boolean isPhylloProductExists = false;
                for(OpportunityLineItem oppLI : mapPhylloOpportunities.get(oldOli.OpportunityId).OpportunityLineItems){
                    //Checking if remaining products are Phyllo or not
                    if(oppLI.Product2.IsPhyllo__c){
                        isPhylloProductExists = true;
                        break;
                    }
                }
                if(!isPhylloProductExists){
                    oppsToUpdate.add(new Opportunity(Id = oldOli.OpportunityId, IsPhyllo__c = false ));
                }
            }
        }
        
        System.debug('$$$$$ Opps to Update : ' + oppsToUpdate);
        if(oppsToUpdate.size() > 0){
            UPDATE oppsToUpdate;
        }
    }
    
    //method to get parent Opportunities for different OpportunityLineItem
    public static Map<Id, Opportunity> getOpportunities(List<OpportunityLineItem> oliList){
        Map<Id, Opportunity> opportunityById = new Map<Id, Opportunity>();
        for(OpportunityLineItem oli : oliList){
            opportunityById.put(oli.OpportunityId, null);
        }
        
        for(Opportunity opp : [SELECT Id, internalChargeNumber__c, RecordTypeId, isPrebuild__c, isPhyllo__c 
                               FROM Opportunity 
                               WHERE Id IN :opportunityById.keySet()]){
                                   opportunityById.put(opp.Id, opp);
                               }
        
        return opportunityById;
    }
    
    //method to get product information for different OLIs
    public static Map<Id, Product2> getProducts(List<OpportunityLineItem> oliList){
        Map<Id, Product2> productById = new Map<Id, Product2>();
        for(OpportunityLineItem oli : oliList){
            productById.put(oli.Product2Id, null);
        }
        
        
        for(Product2 pro : [SELECT Id, Name, isPrebuild__c, IsPhyllo__c FROM Product2 WHERE Id IN :productById.keySet()]){
            productById.put(pro.Id, pro);
        }
        return productById;
    }
}