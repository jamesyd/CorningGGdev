/**
 * @File Name          : OpportunityTriggerHelper.cls
 * @Description        : 
 * @Author             : Adam Nicholson?
 * @Group              : 
 * @Last Modified By   : Arquimidez Mora
 * @Last Modified On   : 2/7/2020 13:15:25
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.1    2/7/2020   Arquimidez Mora        Fixing setOpportunityStage method to not crash when user doesn't have a rol
**/
///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 2/14/2017 ***///
///*** Class to help opportunity trigger ***///
public class OpportunityTriggerHelper{
    static Utilities Utils = new Utilities();
    
    // AN - 8/7/18 - set Ship To Contact Address
    public static void updateShipToContactAddress(List<Opportunity> newList) {
        System.debug('$$$ IN O: *** checkIfStageCanbeDraft');
        
        Set<Id> sampleContactIdSet = new Set<Id>();
        Map<Id, Contact> sampleContactIDMap = new Map<Id, Contact>();
        
        for (Opportunity o : newList) { 
            if (o.shipToContact__c <> NULL) {
                sampleContactIdSet.add(o.shipToContact__c);
            }
        }
        
        if (sampleContactIDSet.size() > 0) { // AN 12/14/18 - wrap SOQL with if
            System.debug('$$$ IN O: Query contactList');
            list<Contact> contactList = [SELECT Id, MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity 
                                         FROM Contact
                                         WHERE Id IN :sampleContactIdSet];          
            System.debug('$$$ IN O: Size ' + contactList.size());
            
            for (Contact c : contactList) { 
                sampleContactIdMap.put(c.id, c);
            }                
            
            for (Opportunity opp : newList) {
                if (opp.shipToContact__c <> NULL && opp.overrideShipToContactAddress__c == FALSE) {
                    opp.streetAddress__c = sampleContactIdMap.get(opp.shipToContact__c).MailingStreet;
                    opp.city__c = sampleContactIdMap.get(opp.shipToContact__c).MailingCity;
                    opp.state__c = sampleContactIdMap.get(opp.shipToContact__c).MailingState;
                    opp.zip__c = sampleContactIdMap.get(opp.shipToContact__c).MailingPostalCode;
                    opp.country__c = sampleContactIdMap.get(opp.shipToContact__c).MailingCountry;       
                }    
            }
        }
    }      
    
    public static void afterUpdate(List<Opportunity> newList, Map<ID, Opportunity> oldMap){
        Map<Id,Opportunity> oldOppById = new Map<Id,Opportunity>();
        for(Opportunity opp : newList){
            if(opp.sampleCmLocations__c != NULL 
            && opp.isPrebuild__c 
            && oldMap.get(opp.Id).sampleCmLocations__c != opp.sampleCmLocations__c){
            
                oldOppById.put(opp.id, opp);
            }
        }
        if(oldOppById.size() > 0){
            copyLoationValuetoFullFilment(oldOppById);
        }
        /*
Set<Id> opportunityIds = new Set<id>(); 
for(Opportunity opp: newList){
if(opp.programCompleted__c
&& opp.programCompleted__c != oldMap.get(opp.Id).programCompleted__c){
opportunityIds.add(opp.Id);
}
}
if(opportunityIds.size() > 0){
updateRelatedForecast(getActiveForecast(opportunityIds));
}
*/
    }
    /*
private static List<ForecastOutput52Week__c> getActiveForecast(Set<Id> opportuintyIds){
try{
return [SELECT Id, Name, opportunity__c, programcompleted__c, status__c
FROM ForecastOutput52Week__c 
WHERE status__c != 'Completed'
AND programcompleted__c = false
AND opportunity__c IN :opportuintyIds];
}catch(Exception e){}
return new List<ForecastOutput52Week__c>();
}

private static void updateRelatedForecast(List<ForecastOutput52Week__c> activeForecast){
List<ForecastOutput52Week__c> toUpdateActiveForecast = new List<ForecastOutput52Week__c>();
for(ForecastOutput52Week__c forecast: activeForecast){
if(forecast.programcompleted__c != true && forecast.status__c != 'Completed'){
forecast.programcompleted__c = true;
forecast.status__c = 'Completed';
toUpdateActiveForecast.add(forecast);  
}

}
if(toUpdateActiveForecast.size() > 0){
UPDATE toUpdateActiveForecast;
}
}
*/
    
    // AN - 7/11/18 - Update sample opportunity with product and fulfillment info for Order Pending email
    public static void updateOppAttributes(List<Opportunity> newList, Map<ID, Opportunity> oldMap) {
        System.debug('$$$ IN O: *** updateOppAttributes');
        
        //get record type id of submitted samples
        Id oppPartsSampleRtId = '0121J000000U1cY';
        Id oppRawSampleRtId = '0121J000000U1cb';
        
        list<Opportunity> soList = new list<Opportunity>();
        Set<Id> soIdSet = new Set<Id>();
        list<OpportunityLineItem> oliList = new list<OpportunityLineItem>();
        list<SampleFulfillment__c> sfList = new list<SampleFulfillment__c>();
        
        // AN - 8/7/18 - get ship to contacts
        Set<Id> sampleContactIdSet = new Set<Id>();
        Map<Id, Contact> sampleContactIDMap = new Map<Id, Contact>();
        
        for (Opportunity o : newList) { 
            if (o.shipToContact__c <> NULL) {
                sampleContactIdSet.add(o.shipToContact__c);
            }
        }
        
        if (sampleContactIDSet.size() > 0) { // AN 12/14/18 - wrap SOQL with if
            System.debug('$$$ IN O: Query contactList');
            list<Contact> contactList = [SELECT Id, MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity 
                                         FROM Contact
                                         WHERE Id IN :sampleContactIdSet];                  
            System.debug('$$$ IN O: Size ' + contactList.size());         
            
            for (Contact c : contactList) { 
                sampleContactIdMap.put(c.id, c);
            }                
            
            // loop through collection
            for (Opportunity opp : newList) {
                
                // update shipping address from ship to contact
                if ((oldMap.get(opp.Id).shipToContact__c <> opp.shipToContact__c) && (opp.overrideShipToContactAddress__c == FALSE)) {
                    opp.streetAddress__c = sampleContactIdMap.get(opp.shipToContact__c).MailingStreet;
                    opp.city__c = sampleContactIdMap.get(opp.shipToContact__c).MailingCity;
                    opp.state__c = sampleContactIdMap.get(opp.shipToContact__c).MailingState;
                    opp.zip__c = sampleContactIdMap.get(opp.shipToContact__c).MailingPostalCode;
                    opp.country__c = sampleContactIdMap.get(opp.shipToContact__c).MailingCountry;       
                }                
            }
        }
        
        for (Opportunity opp : newList) {
            // log stage change date and reset chatter reminder
            if (oldMap.get(opp.Id).StageName <> opp.StageName) {
                opp.statusChangeDate__c = Date.today();
                opp.reminderCompleted__c = False;                                
            }
            
            // set previous owner
            opp.previousOwnerID__c = oldMap.get(opp.Id).OwnerId;
            
            // Filter out opportunities for order pending email
            if ((opp.recordtypeId == oppPartsSampleRtId || opp.recordtypeId == oppRawSampleRtId) && (opp.stageName == 'Order Pending' && oldMap.get(opp.Id).StageName != 'Order Pending')) {
                soList.add(opp);
                soIdSet.add(opp.id);
            }        
        }
        
        if (soIdSet.size() > 0) { // AN 12/14/18 - wrap SOQL with if
            System.debug('$$$ IN O: Query oliListList');
            oliList = [SELECT Id, OpportunityId, ProductName__c, specification__r.Name, description FROM OpportunityLineItem WHERE OpportunityId in :soIdSet];
            System.debug('$$$ IN O: Size ' + oliList.size());
            
            System.debug('$$$ IN O: Query sfList');
            sfList = [SELECT Id, opportunity__c, fulfillmentLocation__c FROM SampleFulfillment__c WHERE opportunity__c in :soIdSet];
            System.debug('$$$ IN O: Size ' + sfList.size());
            
            for (Opportunity o : soList) {
                for (OpportunityLineItem oli : oliList) {
                    if (oli.opportunityId == o.id) {
                        if (oli.description == Null) {
                            o.sampleProduct__c = oli.productName__c + '\n';
                        } else {                
                            o.sampleProduct__c = oli.productName__c + ' - ' + oli.description + '\n';
                        }
                    }
                }
                for (SampleFulfillment__c sf : sfList) {
                    if (sf.opportunity__c == o.id) {
                        o.sampleFulfillmentLocations__c = sf.fulfillmentLocation__c + '\n';
                    }           
                }
            }
        }  
    } 
    
    //A sample opportunity can only be created by owner of the mass production opportunity, or an opportunity team member with edit access to the 
    //program opportunity.
    public static void validateCreateAccessSampleRequest(List<Opportunity> optys){    
        System.debug('$$$ IN O: *** validateCreateAccessSampleRequest');
        
        Id userId = UserInfo.getUserId();
        Id profileId = UserInfo.getProfileId();
        string profileName = Utils.getProfileName(profileId);
        
        //system admins can always edit any specs
        if (profileName == 'System Administrator' || profileName == 'System Administrator Plus'){
            return;
        }
        
        //get record type ids of sample opportunity record types
        Map<Id, Id> sampleRTs = new Map<Id, Id>();
        // an 7/23/18 - sql query limit - removed query for sample record type IDs
        //for (RecordType rt: [SELECT Id, Name FROM RECORDTYPE WHERE Name like '%sample%' AND SObjectType='opportunity']){
        // sampleRTs.put(rt.Id, rt.Id);
        sampleRTs.put('0121J000000U1cYQAS', '0121J000000U1cYQAS'); // GG Parts Sample - Submitted
        sampleRTs.put('0121J000000U1cXQAS', '0121J000000U1cXQAS'); // GG Parts Sample Request
        sampleRTs.put('0121J000000U1cbQAC', '0121J000000U1cbQAC'); // GG Raw Glass/Concore Sample - Submitted
        sampleRTs.put('0121J000000U1caQAC', '0121J000000U1caQAC'); // GG Raw Glass/Concore Sample Request
        //} 
        
        list<Id> optyIds = new List<Id>();
        list<Id> actIds = new List<Id>();
        list<Opportunity> optysToCheck = new List<Opportunity>();
        
        //only need to check sample opportunities
        for (Opportunity o: optys){
            if (sampleRTs.containsKey(o.RecordTypeId) && o.massOptyOwnerId__c != userId ){
                optyIds.add(o.MassProductionOpportunity__c);
                actIds.add(o.programOpportunityAccountId__c);
                system.debug('$$$: ' + o.programOpportunityAccountId__c);
                optysToCheck.add(o);
            }
        } 
        
        //user can only create sample opportunities if the user is on opportunity team 
        //with edit access on the related program opportunity
        //Retrieve Team Members for the program Opportunity
        set <id> optyTeamMembers = new set<id>();
        System.debug('$$$ IN O: Query OpportunityTeamMember');
        for (OpportunityTeamMember om: [SELECT Id, OpportunityId, UserId 
                                        FROM OpportunityTeamMember 
                                        WHERE OpportunityId in :optyIds 
                                        AND UserId = :userId 
                                        AND IsDeleted = FALSE 
                                        AND OpportunityAccessLevel = 'Edit']){
                                            optyTeamMembers.add(om.OpportunityId);
                                        }
        
        // AN - 8/6/18 - extend opportunity team check to include account team
        set <id> actTeamMembers = new set<id>();
        System.debug('$$$ IN O: Query AccountTeamMember');
        for (AccountTeamMember am: [SELECT Id, AccountId, OpportunityAccessLevel, UserId 
                                    FROM AccountTeamMember 
                                    WHERE AccountId in :actIds 
                                    AND UserId = :userId 
                                    AND IsDeleted = FALSE 
                                    AND OpportunityAccessLevel = 'Edit']){
                                        actTeamMembers.add(am.AccountId);
                                    }        
        
        string sError = label.SampleRequestEditError;
        for (Opportunity o: optysToCheck){ //Incoming Sample Request Opportunities
            if ((optyTeamMembers.contains(o.MassProductionOpportunity__c) == false) && (actTeamMembers.contains(o.programOpportunityAccountId__c) == false)){
                o.addError(sError);
            }
        }
    }
    
    //Set opportunity price book for Gorilla Glass opportunities
    public static void setGGPriceBook(List<Opportunity> optys){
        System.debug('$$$ IN O: *** setGGPriceBook');
        
        //find all opportunity record types for Gorilla Glass
        Set<Id> rts = new Set<Id>();
        System.debug('$$$ IN O: Query RecordType');
        for (RecordType rt: [SELECT Id FROM RecordType where sobjecttype='opportunity' and developername like 'GG%'])
        {
            rts.add(rt.Id);
        }
        
        System.debug('*** !!! ' + rts);
        
        
        Id ggPriceBook = '01so0000004gBaQAAU'; //utils.getGGPriceBookId();
        
        if (ggPriceBook != null){
            //for GG opportunities, set price book if not already set
            for (Opportunity o: optys){
                //added the check for record type - Ajay 5/17
                if (rts.contains(o.RecordTypeId) && o.PriceBook2Id == null){
                    o.PriceBook2Id = ggPriceBook;
                }
                
            }
        }
        
        
    }
    
    public static void createSampleQuote(List<Opportunity> newList, Map<ID, Opportunity> oldMap){
        System.debug('$$$ IN O: *** createSampleQuote');
        
        list<Opportunity> oppList = new list<Opportunity>();
        list<Quote> quotesToAdd = new list<Quote>();
        
        //get record type id of sample quote record type
        Id quoteRtId = '0121J000000U1cfQAC'; //Utils.getRecordTypeId('Quote','GG Sample').Id;
        
        //get record type ids of sample opportunity record types
        Map<Id, Id> sampleRTs = new Map<Id, Id>();
        // an 7/23/18 - sql query limit - removed query for sample record type IDs
        //for (RecordType rt: [SELECT Id, Name FROM RECORDTYPE WHERE Name like '%sample%' AND SObjectType='opportunity']){
        // sampleRTs.put(rt.Id, rt.Id);
        Id ggPrebuildRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('GG Sample Parts Opportunity Prebuild').getRecordTypeId();
        //Id ggPhylloRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('GG Sample Parts Opportunity Phyllo').getRecordTypeId();
        
        sampleRTs.put('0121J000000U1cYQAS', '0121J000000U1cYQAS'); // GG Parts Sample - Submitted
        sampleRTs.put('0121J000000U1cXQAS', '0121J000000U1cXQAS'); // GG Parts Sample Request
        sampleRTs.put('0121J000000U1cbQAC', '0121J000000U1cbQAC'); // GG Raw Glass/Concore Sample - Submitted
        sampleRTs.put('0121J000000U1caQAC', '0121J000000U1caQAC'); // GG Raw Glass/Concore Sample Request
     
        sampleRTs.put(ggPrebuildRTID, ggPrebuildRTID); // GG Sample Parts Opportunity Prebuild
        //sampleRTs.put(ggPhylloRTID, ggPhylloRTID); // GG Sample Parts Opportunity Phyllo
        //} 
        
        Set<Id> freeSampleIds = new Set<Id>();
        
        for (Opportunity opp : newList){
            if (sampleRTs.containsKey(opp.RecordTypeId)){
                if (opp.pricingAssignmentComplete__c == true && oldMap.get(opp.Id).pricingAssignmentComplete__c == false){
                    oppList.add(opp);
                }
                if (opp.freeApproved__c=='Yes' && oldMap.get(opp.Id).freeApproved__c != 'Yes'){
                    freeSampleIds.add(opp.Id);
                }
            }
        }
        
        for (Opportunity opp : oppList){
            Quote newQuote = new Quote();
            newQuote.OpportunityId = opp.massProductionOpportunity__c;
            newQuote.customerInquiryDate__c = opp.customerInquiryDate__c;
            newQuote.RecordTypeId = quoteRTId;
            newQuote.sampleRequest__c = opp.Id;
            newQuote.requestingAccount__C = opp.AccountId;
            newQuote.ContactId = opp.shipToContact__c;
            newQuote.shippingTerm__c = opp.shippingTerm__c;
            newQuote.shippingTermsComment__c = opp.shippingTermsComment__c;
            newQuote.language__c = null;
            newQuote.Name = 'placeholder';
            QuotesToAdd.add(newQuote);
        }
        
        System.debug('$$$ IN O: Insert QuotesToAdd - ' + QuotesToAdd.size());
        insert QuotesToAdd;
        
        // set unit price to 0 for free samples -Ajay 5/9/2017
        Set<Id> freeQuoteIds = new Set<Id>();
        if (freeSampleIds.size() > 0){
            for (Quote q: [SELECT Id FROM Quote WHERE sampleRequest__c in :freeSampleIds]){
                freeQuoteIds.add(q.Id);
            }
        }
        if (freeQuoteIds.size() > 0){
            List<QuoteLineItem> qlis = new List<QuoteLineItem>();
            System.debug('$$$ IN O: Query qli');
            for (QuoteLineItem qli: [SELECT Id FROM QuoteLineItem WHERE QuoteId in: freeQuoteIds]){
                qli.unitPrice = 0;
                qlis.add(qli);
            }
            if (qlis.size() > 0){
                System.debug('$$$ IN O: Update qlis - ' + qlis.size());
                update qlis;
            }
        }
    }
    
    // AN - 11/28/18 add opportunity default part forecast product and forecast to opportunity
    // this is the initial part forecast before any speifications have been approved
    public static void createDefaultOLIForecast(List<Opportunity> newList, Map<ID, Opportunity> oldMap) {
        System.debug('$$$ IN O: *** createDefaultOLIForecast');
        
        List<Opportunity> oppListAdd = new list<Opportunity>(); // the opps ready for the first forecast to be added         
        List<OpportunityLineItem> oliListAdd = new List<OpportunityLineItem>();
        List<OpportunityLineItem> insertedOliList = new List<OpportunityLineItem>();   
        List<OpportunityLineItemSchedule> olisList = new List<OpportunityLineItemSchedule>();                        
        
        // query the default part forecast product
        // ** this needs to be added as a product in production. Is is selectable?
        System.debug('$$$ IN O: Query defaultForecastProduct');
        
        // filter out which opportunities require the default forecast
        // we know if treatment is set then the opportunity is ready for a forecast
        // do not create a forecast for 0 months
        
        for (Opportunity o: newList) {       
            
            If (oldMap.get(o.ID).createForecast__c == FALSE && o.createForecast__c == TRUE) {                         
                oppListAdd.add(o);
            }
            
        }       
        if (oppListAdd.size() > 0) { // Process the ADDs
            
            //Id defaultForecastProduct = [SELECT id, isForecasting__c FROM Product2 WHERE isForecasting__c = TRUE Limit 1].id;
            Map<String, ID> productIdByOppType = getProductIdByOppType();
            
            
            Id pbId = '01so0000004gBaQAAU'; // GG Price Book
            Map<Id, Id> priceBookEntryByProductId = new Map<Id, Id>();
            List<Id> productIds = productIdByOppType.values();
            String queryStr = 'SELECT Id, Product2Id ';
            queryStr += ' FROM PricebookEntry'; 
            queryStr += ' WHERE Product2Id IN :productIds ';
            
            if(!test.isRunningTest()){
                queryStr += ' AND Pricebook2.Name = \'GG Price Book\' ';
            }
            System.debug('@@##queryStr: ' + queryStr);
            for(PricebookEntry pbEntry: database.query(queryStr)){
                priceBookEntryByProductId.put(pbEntry.Product2Id, pbEntry.Id);
            }
            // an 10/13/18 - ADD - monthly forecast schedule and set up product for proper pipleline with proper price and quantity
            for (Opportunity parent: oppListAdd) {
                OpportunityLineItem li = new OpportunityLineItem();
                li.OpportunityId = parent.Id;
                //li.Product2Id = defaultForecastProduct;
                if(productIdByOppType.containsKey(parent.Type)){
                    li.Product2Id = productIdByOppType.get(parent.Type);
                }
                
                li.isDefaultForecast__c = True;
                
                Decimal productionVolume = parent.estimatedTotalVolume__c != NULL ? parent.estimatedTotalVolume__c : 0;
                li.Quantity = productionVolume * integer.valueof(parent.estimatedMonthsInProduction__c != NULL ? parent.estimatedMonthsInProduction__c : '0');
                
                li.PricebookEntryId = priceBookEntryByProductId.get(li.Product2Id);
                
                if(parent.Type == 'Parts'){
                    li.unitPrice = parent.estimatedUnitPrice__c != NULL ? parent.estimatedUnitPrice__c : 0;
                }else{
                    li.unitPrice = 0;
                }
                
                li.forecastCategory__c = 'Pipeline'; // might be able to remove this field
                li.finisherYield__c = parent.massProductionYield__c;
                oliListAdd.Add(li);         
            } 
            
            System.debug('$$$ IN O: Insert oliListAdd - ' + oliListAdd.size());
            insert oliListAdd;
            // query the inserted opportunity line items           
            if (oliListAdd.size() > 0) { // AN 12/14/18 - wrap SOQL with if
                System.debug('$$$ IN O: Query insertedOliList');
                insertedOliList = [SELECT id, quantity, unitPrice, totalPrice, Opportunity.Type, Opportunity.Start_of_Production__c, 
                                   Opportunity.estimatedMonthsInProduction__c, Opportunity.estimatedTotalVolume__c, 
                                   Opportunity.estimatedUnitPrice__c
                                   FROM OpportunityLineItem 
                                   WHERE id IN :oliListAdd];
                System.debug('$$$ IN O: Size ' + insertedOliList.size());                   
                
                for (OpportunityLineItem oli: insertedOliList) {   
                    Integer months = integer.valueof(oli.Opportunity.estimatedMonthsInProduction__c);
                    Date m1Date = oli.Opportunity.Start_of_Production__c.toStartofMonth();       
                    
                    Decimal unitPiecePrice = oli.Opportunity.estimatedUnitPrice__c != NULL ? oli.Opportunity.estimatedUnitPrice__c : 0;
                    Decimal productionVolume = oli.Opportunity.estimatedTotalVolume__c != NULL ? oli.Opportunity.estimatedTotalVolume__c : 0;
                    Integer qty = (productionVolume).intValue();
                    Decimal rev = (unitPiecePrice * productionVolume); //.intValue();
                    
                    //Loop # months
                    for (Integer i = 0; i < months; i++) {
                        opportunityLineItemSchedule ols = new opportunityLineItemSchedule();
                        ols.ScheduleDate = m1Date.addMonths(i);
                        ols.opportunityLineItemID = oli.id;
                        ols.type = 'Both';
                        if(oli.Opportunity.Type == 'Parts'){
                            //store unit price in description since Corning want unit pice decay and can't add fields to schedule
                            ols.description = oli.unitPrice.toPlainString(); 
                            ols.Revenue = rev;  
                        }else{
                            ols.description = '0';
                            ols.Revenue = 0; 
                        }
                        ols.Quantity = qty;
                        olisList.add(ols);
                    }
                }
                
                System.debug('$$$ IN O: Insert olisList - ' + olisList.size());
                insert olisList;
                
                Date som = System.Date.today().toStartOfMonth();
                
                // requery OLI now that schedule is added, create 52 initial week forecast
                oliListAdd = [SELECT Id, Opportunity.Id, Opportunity.OwnerId, Opportunity.ForecastCategory, Opportunity.StageName, Opportunity.Amount, 
                              Opportunity.CloseDate, Opportunity.age__c, Opportunity.RecordTypeId, Opportunity.Name, Opportunity.AccountId,
                              Opportunity.gorillaGlassPercent__c, Opportunity.Competitive_Material__c, Opportunity.pandaPercent__c, Opportunity.agcPercent__c, 
                              Opportunity.schottPercent__c, Opportunity.negPercent__c, Opportunity.otherPercent__c, Opportunity.deviceCategory__c, 
                              Opportunity.productSegmentation__c, Opportunity.competitiveGlasses__c, Opportunity.massProductionYield__c,
                              forecastApplication__c, forecastBrandCustomer__c, coverScreenSize__c, glassComposition__c, glassCurvature__c, length__c, forecastMarketSegment__c,
                              forecastMarketSubSegment__c, forecastMassProductionStartDate__c, forecastModelProgramName__c, forecastMonthsInProduction__c, forecastCategory__c,
                              LastModifiedById, LastModifiedDate, Product2Id, forecastProductCode__c, forecastProductionVolumePartsMonth__c, ProductName__c,
                              forecastProgramName__c, forecastRegion__c, forecastShipToCustomer__c, specification__c,
                              specification__r.name, specification__r.tpm__r.id, specification__r.tpm__r.OwnerId, tpmOverride__c, tpmOverride__r.OwnerId,
                              squareFeet__c, thickness__c, TotalPrice, Quantity, treatment__c, width__c,
                              finisherAccount__c, finisherAccount__r.Name, finisherMix__c, finisherOwner__c, finisherYield__c, comments__c, glassThickness__c,
                              finalFinishedGlassPartThickness__c,
                              (SELECT Id, Quantity, Revenue, Description, ScheduleDate, LastModifiedById, LastModifiedDate 
                               FROM OpportunityLineItemSchedules WHERE ScheduleDate >= :som ORDER BY ScheduleDate ASC )        
                              FROM OpportunityLineItem 
                              WHERE HasQuantitySchedule = True AND HasRevenueSchedule = True AND Opportunity.RecordTypeId = '0121J000000U1cZQAS' AND id IN :oliListAdd] ;       
                
                List<ForecastOutput52Week__c> forecast52ListForUpdate = ForecastHelper.process52(oliListAdd, 'Active');
                List<Database.SaveResult> results = new List<Database.SaveResult>();            
                results = Database.insert(forecast52ListForUpdate, false);
            }
        }         
    }
    
    private static Map<String, Id> getProductIdByOppType(){
        Map<String, Id> productIdByOppType = new Map<String, Id>();
        for(Product2 product: [SELECT id, Name, isForecasting__c 
                               FROM Product2 
                               WHERE isForecasting__c = TRUE]){
                                   if(product.Name == System.label.GGDefaultPartProductName){
                                       productIdByOppType.put('Parts', product.Id);
                                   }else if(product.Name == System.label.GGDefaultRawGlassProductName){
                                       productIdByOppType.put('Raw Glass', product.Id);
                                   }else if(product.Name == System.label.GGDefaultCocoreProductName){
                                       productIdByOppType.put('Concore', product.Id);
                                   }
                               }
        
        return productIdByOppType;
    }
    
    //Sending email notification to planners when opportunity stage is in Order pending and submitted to approval
    public static void sendEmailNotification(List<Opportunity> opplist,Map<Id,Opportunity> oldOppById){
        
        Map<Id, Specification__c> specificationByOppId = new Map<Id, Specification__c>();
        Map<Id, OpportunityLineItem> opportunityLineItemByOppId = new Map<Id, OpportunityLineItem>();
        Map<Id, Quote> quoteByOppId = new Map<Id, Quote>();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        Map<Id, SampleFulfillment__c> specByOppId = new Map<Id, SampleFulfillment__c>();
        List<Opportunity> newOpplist = new List<opportunity>();
        
        //filtering opportunities those have change in stage or submitforapproval checkbox and also checking their values
        for(Opportunity opp : opplist){
            if((opp.StageName != oldOppById.get(opp.Id).StageName || opp.submitForApproval__c != oldOppById.get(opp.Id).submitForApproval__c)
               && (opp.StageName == 'Order Pending' && opp.submitForApproval__c)
               && opp.isPrebuild__c){
                   newOpplist.add(opp);
                   specificationByOppId.put(opp.Id, null);
                   opportunityLineItemByOppId.put(opp.Id, null);
               }
        }
        
        //if their is any changed on opportunity according to above criteria then perform email notification functionality on them
        if(newOpplist.size() > 0){
            for(Opportunity opp : [SELECT Id, Name, massProductionOpportunity__r.name, toLabel(QuoteCurrency__c) 
                                   , (SELECT Id, Name, tpmName__c FROM Specifications__r ORDER BY CreatedDate DESC LIMIT 1)
                                   , (SELECT Id,specification__r.tpmName__c, sampleQuantity__c FROM OpportunityLineItems ORDER BY CreatedDate DESC LIMIT 1)
                                   , (SELECT corningSellingEntity__c, currency__c FROM Quotes ORDER BY CreatedDate DESC LIMIT 1)
                                   , (SELECT Id,fulfillmentLocation__c FROM Sample_Fulfillments__r ORDER BY CreatedDate DESC LIMIT 1)
                                   FROM Opportunity
                                   WHERE Id IN :specificationByOppId.keySet()
            ]){
                System.debug('opp====>' + opp);
                oppMap.put(opp.Id, opp);
                if(opp.Specifications__r.size() > 0){
                    specificationByOppId.put(opp.Id, opp.Specifications__r.get(0));    
                }
                
                if(opp.OpportunityLineItems.size() > 0){
                    opportunityLineItemByOppId.put(opp.Id, opp.OpportunityLineItems.get(0));    
                }
                if(opp.Quotes.size() > 0){
                    quoteByOppId.put(opp.Id, opp.Quotes.get(0));
                }
                if(opp.Sample_Fulfillments__r.size() > 0){
                    specByOppId.put(opp.Id, opp.Sample_Fulfillments__r.get(0));
                }
            }
            Set<Id> setOppIds = oldOppById.keySet();
            Map<String, String> mapOppOwnerMails = new Map<String, String>();
            for(Opportunity opp :[SELECT Id, Owner.Email FROM Opportunity WHERE Id IN :setOppIds]){
                mapOppOwnerMails.put(opp.Id, opp.Owner.Email);
            }
            list<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
            for(Opportunity opp : newOpplist){
                /*List<String> sendTo = new List<String>();//new List<String>();//     //getting list of planner ids from custom label
                sendTo.add('Atasuperfusion@gmail.com');
                */
                List<String> sendTo = getPlannersEmailIds();
                sendTo.add('chenh12@corning.com');
                if(mapOppOwnerMails.containsKey(opp.Id)){
                    sendTo.add(mapOppOwnerMails.get(opp.Id));
                }
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                mail.setToAddresses(sendTo);
                String subject = 'Urgent (Paid) Parts Sample Order - ' + specByOppId.get(opp.Id).fulfillmentLocation__c;
                mail.setSubject(subject);
                
                //building html body to make html template that will be the body of our mail
                mail.setHtmlBody(buildEmailBody(opp, oppMap, specificationByOppId.get(opp.Id), opportunityLineItemByOppId.get(opp.Id), quoteByOppId.get(opp.Id), specByOppId.get(opp.Id)));
                //mail.setSenderDisplayName('Do Not Reply');
                emailMessages.add(mail);
            }
            
            if(!emailMessages.isEmpty()){ 
                Messaging.SendEmailResult[] serList = Messaging.sendEmail(emailMessages);
                if (serList[0].isSuccess()) {
                    system.debug ('SUCCESS');
                } 
                else {
                    Messaging.SendEmailError[] errors = serList[0].getErrors();
                    system.debug ('Send Email Failed: ' + errors[0].getMessage());
                }
            }
        }
    }
    
    //getting emial ids of planners that is stored in custom labels
    private static List<String> getPlannersEmailIds(){
        List<String> emailIds = new List<String>();
        if(STRING.ISNOTBLANK(System.label.PlannerEmailIds)){
            for(String emailId: System.label.PlannerEmailIds.split(';')){
                emailIds.add(emailId);
            }
        }
        return emailIds;
        //return new List<String>{'atasuperfusion@gmail.com'};
    }
    
    //building email body with opportunity, specificstion and OpportunityLineItem details
    private static string buildEmailBody(Opportunity opp,Map<Id, Opportunity> oppMap, Specification__c spec, OpportunityLineItem oli, Quote q, Samplefulfillment__c sf){        
        string body = '<B>Program Opportunity: </B>' + oppMap.get(opp.Id).massProductionOpportunity__r.name + ' <BR/>'; 
        body += '<B>Sample Request ID: </B>' + checkNullString(opp.Name) + ' <BR/>';
        body += '<B>Spec Id: </B> ' +  checkNullString(opp.SpecId__c) + '<BR/>';
        body += '<B>Product Code: </B> ' + checkNullString(opp.ProductCode__c) + '<BR/>';
        body += '<B>Quantity: </B> ' +  checkNullString(String.valueOf(oli.sampleQuantity__c)) + '<BR/>';
        body += '<B>Internal Charge Code: </B> ' +  checkNullString(opp.internalChargeNumber__c) + '<BR/>';
        body += '<B>Customer Request Date: </B> ' +  checkNullString(String.valueOf(opp.customerInquiryDate__c)) + '<BR/>';
        body += '<B>Custom PO Expected Release Date: </B> ' +  checkNullString(String.valueOf(opp.Custom_PO_expected_Date__c)) + '<BR/>';
        body += '<B>General Comment: </B> ' +  checkNullString(opp.General_Comment__c) + '<BR/>';
        body += '<B>CM Location: </B> ' +  checkNullString(sf.fulfillmentLocation__c) + '<BR/>';
        body += '<B>TPM: </B> ' +  checkNullString(oli.specification__r.tpmName__c) + '<BR/>';
        body += '<B>Selling Entity: </B> ' +  checkNullString(opp.QuoteSellingEntity__c) + '<BR/>';
        body += '<B>Currency: </B> ' + checkNullString(oppMap.get(opp.Id).QuoteCurrency__c) + '<BR/>'; 
        return body;    
    }
    
    //method to check whether the string is null or not, if true returns the same string
    private static String checkNullString(String str){
        if(str == null){
            return '';
        }else{
            return str;
        }
    }    
    public static void onBeforeUpdate(List<Opportunity> opportunities,Map<Id,Opportunity> oldOppById){
        setOpportunityStage(opportunities, oldOppById);
        //setOppStageForPhyllo(opportunities, oldOppById);
    }
    /*
    public static void onAfterInsert(List<Opportunity> opportunities){
        Map<Id,Opportunity> oldOppById = new Map<Id,Opportunity>();
        for(Opportunity opp : opportunities){
            if(opp.sampleCmLocations__c != NULL){// && opp.isPrebuild__c
                oldOppById.put(opp.id, opp);
            }
        }
        
        if(oldOppById.size() > 0){
            copyLoationValuetoFullFilment(oldOppById);
        }
    }
    */
    
    
    //Method to copy the CM location to the Fullfillment Location
    private static void copyLoationValuetoFullFilment(Map<Id,Opportunity> oldOppById){
        List<SampleFulfillment__c> tuUpdateLocation = new List<SampleFulfillment__c>();
        for(SampleFulfillment__c sFulfillment: getFullfillmentList(oldOppById)){
            
            String smapleCMLocation = oldOppById.get(sFulfillment.opportunity__c).sampleCmLocations__c;
            if(STRING.ISNOTBLANK(smapleCMLocation)){
                String[] numberofCMLocation = smapleCMLocation.split(';');
                if(numberofCMLocation.size() == 1){
                    sFulfillment.fulfillmentLocation__c = smapleCMLocation;
                    tuUpdateLocation.add(sFulfillment);
                }
           }
        }
        if(tuUpdateLocation.size() > 0){
            try{
                UPDATE tuUpdateLocation;
            }catch(Exception e){
                System.debug('@@## copyLoationValuetoFullFilment: ' + e.getMessage());
            }
            
        }
    }
    
    //Method to get the list of SampleFulfillment__c on the basis of Opportunity.
    private static List<SampleFulfillment__c> getFullfillmentList(Map<Id,Opportunity> oldOppById){
        return [
            SELECT id, fulfillmentLocation__c, opportunity__c
            FROM SampleFulfillment__c
            WHERE opportunity__c IN :oldOppById.keySet()
            //AND fulfillmentLocation__c = NULL
        ];
    }
    
    
    
    //method to update opportunity stage When AE/AM Profiles User select yes for RSM Approval for Urgent Paid SR 
    private static void setOpportunityStage(List<Opportunity> opportunities,Map<Id,Opportunity> oldOppById){
        
        //getting current user by UserInfo class method  
        User u = [
            SELECT Id, Name, UserRole.Name, ManagerId 
            FROM User 
            WHERE Id = :UserInfo.getUserId()
        ];
        
        //showing errors if the current user is not RSM and update the RSMApprovalForUrgentPaidSample__c field to Yes or No
        if((u.UserRole == null) || !(u.UserRole.Name.containsIgnoreCase(' Mgr ') || u.UserRole.Name.containsIgnoreCase(' Mgr'))){
            System.debug('UserRole.Name ==>' + u.UserRole.Name);
            for(Opportunity opp : opportunities){
                if(opp.RSMApprovalForUrgentPaidSample__c != oldOppById.get(opp.Id).RSMApprovalForUrgentPaidSample__c){
                    if(opp.RSMApprovalForUrgentPaidSample__c == 'Yes'){
                        opp.addError('Only RSM\'s can approve the Urgent Paid Sample Request');
                    }else if(opp.RSMApprovalForUrgentPaidSample__c == 'No'){
                        opp.addError('Only RSM\'s can update the RSM Approval field value to No');
                    }
                }
            }
        }
        if( u.UserRole != null && (u.UserRole.Name.containsIgnoreCase(' Mgr ') || u.UserRole.Name.containsIgnoreCase(' Mgr'))){
            System.debug('UserRole.Name ==>' + u.UserRole.Name);
            for(Opportunity opp : opportunities){
                if(opp.RSMApprovalForUrgentPaidSample__c != oldOppById.get(opp.Id).RSMApprovalForUrgentPaidSample__c
                   && opp.StageName == 'RSM Approval'){
                       if(opp.RSMApprovalForUrgentPaidSample__c == 'Yes'){
                           //Updating oppportunity stage according to number of CM locations
                           if(opp.sampleCmLocations__c != NULL){
                               String[] numberofCMLocation = opp.sampleCmLocations__c.split(';');
                               System.debug('**-numberofCMLocation: '+numberofCMLocation);
                               System.debug('**-numberofCMLocation size:' + numberofCMLocation.size());
                               if(numberofCMLocation.size() == 1){
                                   opp.StageName = 'Pricing Assignment';
                               }else if(numberofCMLocation.size() > 1){
                                   opp.StageName = 'CM Assignment';
                               }  
                           }   
                       }else if(opp.RSMApprovalForUrgentPaidSample__c == 'No'){
                           opp.StageName = 'Cancelled';
                       }
                   }
            }
        }
        
    }
    
    //method to update stage of Opportunity when the phyllo SR submitted for approval
    /* Not in Current Deployment
    public static void setOppStageForPhyllo(List<Opportunity> opportunities,Map<Id,Opportunity> oldOppById){
        
        Map<Id, List<SampleFulfillment__c>> sfListByOppId = new Map<Id, List<SampleFulfillment__c>>();
        List<Opportunity> oppsToUse = new List<Opportunity>();
        
        //adding phyllo SR to list of opportunities
        for(Opportunity opp : opportunities){
            if(opp.StageName == 'New' && opp.submitForApproval__c != oldOppById.get(opp.Id).submitForApproval__c
               && opp.submitForApproval__c 
               && opp.isPhyllo__c){
                   sfListByOppId.put(opp.Id, null);
                   oppsToUse.add(opp);
               }
        }
        
        //getting Sample fulfillments which have Not Applicable value in the FulfillmentLocation field
        for(SampleFulfillment__c sf : [SELECT Id, fulfillmentLocation__c, opportunity__c  
                                       FROM SampleFulfillment__c 
                                       WHERE fulfillmentLocation__c = 'Not Applicable'
                                       AND opportunity__c IN :sfListByOppId.keySet()]){
                                           if(sfListByOppId.get(sf.opportunity__c) == null){
                                               sfListByOppId.put(sf.opportunity__c, new List<SampleFulfillment__c>{sf});
                                           }else{
                                               sfListByOppId.get(sf.opportunity__c).add(sf);
                                           }
                                       }
        System.debug('sfListByOpp$$$$$$$$$>' + sfListByOppId);
        Id ggPhylloRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('GG Sample Parts Opportunity Phyllo').getRecordTypeId();
        //if the opportunity and samplefulfillment has Not Applicale in their location fields then update stage to Pricing Assignment or
        //else update to CM Assignment
        for(Opportunity opp : oppsToUse){
            if(sfListByOppId.get(opp.Id) != null && opp.sampleCmLocations__c == 'Not Applicable'){
                opp.StageName = 'Pricing Assignment';
            }else{
                opp.StageName = 'CM Assignment';
            }
            opp.RecordTypeId = ggPhylloRTID;
        }
        
    }
    */
}