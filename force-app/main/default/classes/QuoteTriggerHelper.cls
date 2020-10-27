/**
 * @File Name          : QuoteTriggerHelper.cls
 * @Description        : 
 * @Author             : Adam Nicholson?
 * @Group              : 
 * @Last Modified By   : Arquimidez Mora
 * @Last Modified On   : 07-07-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.1    2/7/2020   Arquimidez Mora            Fix error on updateOpportunityFields to preempt crash when multiple quotes of same Opportunity are updated by expiration batch
 * 1.1.1  7/7/2020   Arquimidez Mora            Adding Vietnamese Dong
**/
///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 2/14/2017 ***///
///*** Class to help quote trigger ***///
public class QuoteTriggerHelper{
    static Utilities Utils = new Utilities();
    
    //validate that Blue Quote is English Only
    public static void checkBlueLanguageAndEntity(List<Quote> quotes){
        map<Id,Id> quoteOppMap = new map<Id,Id>();
        map<Id,Boolean> blueOppMap = new map<Id,Boolean>(); 
        
        for (Quote q: quotes){
            quoteOppMap.put(q.Id,q.OpportunityId);
        }
        
        //method returns map of OppId with blue boolean
        blueOppMap = utils.isBlueOptyOrQuote(quoteOppMap.values());  

        for(Quote q: quotes){
            Id oppId = quoteOppMap.get(q.Id);
            Boolean isBlue = blueOppMap.get(oppId);
            //for Blue default to CSMI, English, and Dollar
            if (isBlue){
                if (q.corningSellingEntity__c == null){
                    q.corningSellingEntity__c = 'CSMI';
                }
                if (q.currency__c == null){
                    q.currency__c = 'Dollar';
                }
                if (q.Language__c == null){
                    q.Language__c = 'English';
                }
            }
            
            if (isBlue && q.corningSellingEntity__c <> 'CSMI') {
                q.addError(Label.GGQuoteBlueEntity); 
            }
            if (isBlue && q.Language__c <> 'English') {
                q.addError(Label.GGQuoteBlueLanguage);
            }
        }
    }
                
    //Set quote price book for Gorilla Glass quotes
    public static void setGGPriceBook(List<Quote> quotes){
        //find all opportunity record types for Gorilla Glass
        Set<Id> rts = new Set<Id>();
        for (RecordType rt: [SELECT Id FROM RecordType where sobjecttype='quote' and developername like 'GG%'])
        {
            rts.add(rt.Id);
        }
        
        Id ggPriceBook = utils.getGGPriceBookId();
        if (ggPriceBook != null){
            //for GG quotes, set price book if not already set
            for (Quote q: quotes){
                if (rts.contains(q.RecordTypeId) && q.PriceBook2Id == null){
                    q.PriceBook2Id = ggPriceBook;
                }
            }
        }
        
    }
    
    //when new quotes are created from opportunities with existing line items, those line items are automatically added to quotes.
    //this function creates a record of the new quote ids in a custom object and those are then used in the quotelineitem after trigger to 
    //remove the automatically created quote line items.
    //Also, sets Opportunity StageName to Customer Decision, if Quote RT Name = GGQuoteSample
    public static void handleNewQuote(List<Quote> newQuotes){
        map<Id,Opportunity> oppMap = new map<Id,Opportunity>();
        //list<newlyCreatedQuote__c> newQs = new list<newlyCreatedQuote__c>();
        list<QuoteLineItem> lis = new list<QuoteLineItem>();
            
        Set<Id> setOppIds = new Set<Id>();
        Set<Id> sampleIds = new Set<Id>();

        //Get the RT Id for this RT Name
        RecordType sampleRT = utils.getRecordTypeID('Quote', label.GGQuoteSample);
        
        for (Quote quote : newQuotes) {
            setOppIds.add(quote.OpportunityId); //Opportunity Id for the "Main" Opportunity
            if (quote.sampleRequest__c != null){ //Opportunity Id for the "Sample" Opportunity if this is a Sample Quote
                sampleIds.add(quote.sampleRequest__c);
            }
        }
                
        //Create newlyCreatedQuote__c record for the program Opportunity that has Line Items
        /*for (Opportunity mainOpp: [select Id, StageName, HasOpportunityLineItem from Opportunity where Id in :setOppIds]){  
            for (Quote quote : newQuotes) {
                if (quote.OpportunityId == mainOpp.Id) {
                    if (mainOpp.HasOpportunityLineItem == TRUE){
                        newQs.add(new newlyCreatedQuote__c(quoteId__c = quote.Id)); 
                    }
                }
            }                          
        }*/
        
        if (sampleIds.size() > 0){
            //Create newlyCreatedQuote__c record for the sample Opportunity that has line items
            //Set Opportunity.StageName to 'Customer Quotation'
            for (Opportunity sampleOpp: [SELECT Id, StageName, HasOpportunityLineItem, 
                                            (SELECT PricebookEntryId, description, Quantity, sampleQuantity__c, UnitPrice, price__c, specification__c
                                            FROM OpportunityLineItems) 
                                        FROM Opportunity
                                        WHERE Id IN :sampleIds]) {
 
                for (Quote quote : newQuotes) {
                    if (quote.sampleRequest__c == sampleOpp.Id) {
                        if (sampleOpp.HasOpportunityLineItem == TRUE){
                            for (OpportunityLineItem sampleOLI : sampleOpp.OpportunityLineItems) {
                                QuoteLineItem li = new QuoteLineItem();
                                li.QuoteId = quote.Id;
                                li.description = sampleOLI.description; // AN 9/14
                                li.price__c = sampleOLI.price__c;
                                li.quantity = sampleOLI.Quantity;
                                li.sampleQuantity__c = sampleOLI.sampleQuantity__c;
                                li.PricebookEntryId = sampleOLI.PricebookEntryId;
                                li.Unitprice = sampleOLI.UnitPrice;
                                li.sampleAutoCreated__c = true;
                                li.specification__c = sampleOli.specification__c;
                                lis.Add(li);
                            }  
                        }
                        
                        //if Quote RT Name = GGQuoteSample, set Opportunity.StageName to 'Customer Decision'
                        if (quote.RecordTypeId == sampleRT.id && sampleOpp.StageName <> 'Customer Decision') {
                            sampleOpp.StageName = Label.GGSampleStatusQuoteCreated;//'Customer Decision';
                            oppMap.put(sampleOpp.Id,sampleOpp);
                        }
                    }
                }                          
            }
        }
         
        /*if (newQs.size() > 0){
            insert newQs;
        }*/
        
        if (lis.size() > 0){
            System.debug('All the qlis insert===&&>' + lis);
            insert lis;
        }
        
        if (oppMap.size() > 0) {
            update oppMap.values(); 
        }
    }
    
    //this function gets the quote ids from the newlyCreatedQuote__c object and deletes any line 
    //items automatically created for those records. Then it clears the newlyCreatedQuote__c records so future line items can be created.
    public static void handleAutoCreatedLineItems(List<QuoteLineItem> newLIs){
        Set<Id> setQuoteIds = new Set<Id>();
        /*Map<Id, newlyCreatedQuote__c> mapNewlyCreatedQuoteRecords = new Map<Id,newlyCreatedQuote__c>();
        
        List<newlyCreatedQuote__c> newlyCreatedQuoteRecords = new List<newlyCreatedQuote__c>();
        //find all records in the newlyCreateQuote object
        for (newlyCreatedQuote__c n: [SELECT Id, quoteId__c FROM newlyCreatedQuote__c]){
            //qIds.add(n.quoteId__c);
            mapNewlyCreatedQuoteRecords.put(n.quoteId__c, n);
        }*/
        
        for (QuoteLineItem qli : newLIs) {
            if (//mapNewlyCreatedQuoteRecords.containsKey(qli.QuoteId) && 
                !setQuoteIds.contains(qli.QuoteId)
                && qli.sampleAutoCreated__c <> true) { //Added to avoid deleting trigger created Parts OLI's
                setQuoteIds.add(qli.QuoteId);
                //newlyCreatedQuoteRecords.add(mapNewlyCreatedQuoteRecords.get(qli.QuoteId));
            }
            else{
                if (!qli.manuallyAdded__c && !qli.sampleAutoCreated__c){
                    setQuoteIds.add(qli.QuoteId);
                }
            }
        }
        system.debug('in quoteLineItem trigger - deleting qlis - ' + setQuoteIds.size());
        if (!setQuoteIds.isEmpty()) {
            //Added to avoid deleting trigger created auto created sample Parts quote LI copied from sample opportunity
            List<QuoteLineItem> lstQLIsTodelete = [select Id from QuoteLineItem where QuoteId in :setQuoteIds AND sampleAutoCreated__c <> TRUE and manuallyAdded__c <> TRUE];
            delete lstQLIsTodelete; // Delete the QLIs that automatically created from creating a new Quote from Opportunity with Line Items
            //delete newlyCreatedQuoteRecords; // Remove Quote Ids , so the trigger won't fire when we create a new Line Item for quote later
            
        }
    }
     
     //if price of a parts program opportunity line item is lower than price for the quantity in the range, send the quote status 
     //to "Pricing Review"
     //this function gets the quote ids from the newlyCreatedQuote__c object and deletes any line 
    //items automatically created for those records. Then it clears the newlyCreatedQuote__c records so future line items can be created.
    public static void checkLIPrices(List<QuoteLineItem> LIs){

       Set<Id> priceIds = new Set<Id>();
       Set<Id> allQuoteIds = new Set<Id>(); 
       List<QuoteLineItem> lisToCheck = new List<QuoteLineItem>();
       
       for (QuoteLineItem qli: LIs){
           allQuoteIds.add(qli.QuoteId);
       }
       
       lisToCheck = [SELECT Id, quoteId, Quantity, qtyLessThanMOQ__c, plmFloorPrice__c, UnitPrice, Price__c FROM QuoteLineItem WHERE QuoteId IN :allQuoteIds];
       
       allQuoteIds.clear();
       
       for (QuoteLineItem qli: lisToCheck){
           priceIds.add(qli.Price__c);
           allQuoteIds.add(qli.QuoteId);
       }
       
       
       
       Id sampleQuoteRT = utils.getRecordTypeID('Quote', Label.GGQuoteSample).Id;
       Id partsQuoteRT = utils.getRecordTypeID('Quote', Label.GGQuoteParts).Id;
       
       //get parts/raw/concore program quote ids
       Set<Id> partsQuoteIds = new Set<Id>();
       Set<Id> rawConcoreQuoteIds = new Set<Id>();
       List<Quote> allQuotes = new List<Quote>();
       
       //query non-sample quotes
       for (Quote q: [SELECT Id, RecordTypeId, Status FROM Quote WHERE Id in :allQuoteIds AND RecordTypeId <> :sampleQuoteRT]){
           if (q.RecordTypeId != partsQuoteRT){
               rawConcoreQuoteIds.add(q.Id);
           }
           else{
               partsQuoteIds.add(q.id);
           }
           allQuotes.add(q);
           //quoteMap.put(q.Id, q);
       }
       
       //get price record for the quote line items
       Map<Id, Price__c> priceMap = new Map<Id, Price__c>();
       String partsStr = Label.GGProductTypeParts;
       for (Price__c p: [SELECT Id, upperLimit1__c, Price1__c, upperLimit2__c, Price2__c, upperLimit3__c, Price3__c, upperLimit4__c, Price4__c, priceUnit__c FROM Price__c WHERE Id in :priceIds]){// AND Product__r.Family = :partsStr]){
           priceMap.put(p.Id, p);
       }
       
       List<Quote> quotesToFlag = new List<Quote>();

       String pricingReview = label.GGQuotePricingReview;
       system.debug('$$$$$ ' + pricingReview); // AN 4/25 = 'PLM Review'
       double floorPrice;
       Set<Id> uniqueQToFlag = new Set<Id>();
       boolean flagQuote = false;
       //make a list of quotes that are for parts program quote and line item price < floor price for the tier
       for (QuoteLineItem qli: lisToCheck){
           flagQuote = false;

           if (uniqueQToFlag.contains(qli.quoteId)==false){
               if (!flagQuote && priceMap.containsKey(qli.price__c)){
                   if (partsQuoteIds.contains(qli.quoteId)){
                       //floorPrice = Utils.getPriceForParts(qli.Quantity, priceMap.get(qli.Price__c));
                       flagQuote = (qli.UnitPrice < qli.plmFloorPrice__c);
                   }
                   // Price check removed for raw glass and concore - per Corning 5/11 meeting - Ajay
                   // Price check added back AN - 4/25
                   else
                   if (rawConcoreQuoteIds.contains(qli.quoteId)){
                       // AN 4/27 change price unit to plm floor price
                       // look into these flags when moving to price__c for parts
                       //flagQuote = (priceMap.containsKey(qli.Price__c) && priceMap.get(qli.Price__c).priceUnit__c != null && qli.UnitPrice < priceMap.get(qli.Price__c).priceUnit__c);
                       flagQuote = (priceMap.containsKey(qli.Price__c) && priceMap.get(qli.Price__c).priceUnit__c != null && qli.UnitPrice < qli.plmFloorPrice__c);
                   }
               }
               
               if (flagQuote){
                   quotesToFlag.add(new Quote(Id=qli.QuoteId, Status= pricingReview)); 
                   uniqueQToFlag.add(qli.QuoteId);   
               }
           }
           
       }

       String draftStatus = Label.GGQuoteDraftStatus;
       //reset pricing review status for quotes that were previously flagged
       for (Quote q: allQuotes){
           system.debug('setting quote to draft OUTSIDE: ' + q.Id + ' current status ' + q.status);
           
           if (uniqueQToFlag.contains(q.Id) == false && q.Status == pricingReview){
           
               system.debug('setting quote to draft INSIDE: ' + q.Id + ' - ' + draftStatus);
               //set the ignoreQuotePriceStatusChange__c to true so the validation will allow the status to change to draft again
               quotesToFlag.add(new Quote(Id=q.Id, Status= draftStatus, ignoreQuotePriceStatusChange__c = true)); 
           }
       }


       //update the quotes to status of "Pricing Review"
       if (quotesToFlag.size() > 0){
           system.debug('quotesToFlag: ' + quotesToFlag.size());
           update(quotesToFlag);
       }
     }
     
     //verifies if the quote status can be changed to draft - if there are any price errors 
     //or moq errors, quote status can't be changed to any other status from "PLM Review"
     public static void checkIfStageCanbeDraft(List<Quote> quotes, Map<Id, Quote> oldMap){
        String draftStatus = Label.GGQuoteDraftStatus;
        Set<Id> qIds = new Set<Id>();
        Id profileId = UserInfo.getProfileId();
        String profileName = [SELECT NAME FROM PROFILE WHERE Id = :profileId LIMIT 1].Name;
        //boolean draftStatusCanBeselected = (profileName == Label.GGPLMProfileName || profileName == 'System Administrator');
        boolean draftStatusCanBeselected = (profileName == Label.GGPartsPLMProfileName 
                                            || profileName == Label.GGRawGlassPLMProfileName 
                                            || profileName == Label.GGConcorePLMProfileName 
                                            || profileName == 'System Administrator');
        
        String msg = Label.GGQuotePLMCanChangeStatus;
        String GGQuotePricingReview = Label.GGQuotePricingReview;
        String GGQuotePricingRejected = Label.GGQuotePricingRejected;
        Quote oldQ;
        for (Quote q: quotes){
            
            //if the status was changed because the quote line item price was changed above PLM pricing, 
            //ignore the status change validation rule
            if (q.ignoreQuotePriceStatusChange__c) continue;
            
            oldQ = oldMap.get(q.Id);
            //if the old status was PLM Review, only PLM can change the status after that
            if ( (oldQ.Status == GGQuotePricingReview || oldQ.Status == GGQuotePricingRejected)
                && q.Status != oldMap.get(q.Id).Status
                && !draftStatusCanBeSelected){ 
                q.addError(msg);
            }else{
                // IMPORTANT - Set this flag back so the quote status change flag will be checked again
                q.ignoreQuotePriceStatusChange__c = false;
            }
        }
     }
     
     //For non-sample quote line items, sets the price below floor flag if applicable
     public static void setPricingFlags(List<QuoteLineItem> qlis){
         Set<Id> quoteIds = new Set<Id>();
         Set<Id> priceIds = new Set<Id>();
         for (QuoteLineItem qli: qlis){
             quoteIds.add(qli.QuoteId);
             if (qli.price__c != null){
                 priceIds.add(qli.price__c);
             }
         }
         
         Id sampleRT = utils.getRecordTypeID('Quote', Label.GGQuoteSample).Id;
         Id partsRT = utils.getRecordTypeID('Quote', Label.GGQuoteParts).Id;
         
         //only collect non-sample quotes
         Map<Id, Quote> partsQuotes = new Map<Id, Quote>();
         Map<Id, Quote> nonPartsQuotes = new Map<Id, Quote>();
         for (Quote q: [SELECT Id, RecordTypeId FROM Quote WHERE Id in :quoteIds AND RecordTypeId <> :sampleRT]){
             if (q.RecordTypeId == partsRT){
                 partsQuotes.put(q.Id, q);
             }else{
                 nonPartsQuotes.put(q.Id, q);
             }
             
         }//for q
         
         // priceUnit is for raw (includes shipping)
         Map<Id, Price__c> priceMap = new Map<Id, Price__c>();
         for (Price__c p: [SELECT Id, upperLimit1__c, Price1__c, upperLimit2__c, Price2__c, upperLimit3__c, Price3__c, upperLimit4__c, Price4__c, priceUnit__c FROM Price__c WHERE Id in :priceIds]){// AND Product__r.Family = :partsStr]){
           priceMap.put(p.Id, p);
         }
         
         //go through all quote line items in the trigger, for non-sample line items set the price below floor price flag
         for (QuoteLineItem qli: qlis){
             if (!priceMap.containsKey(qli.Price__c)){
                 continue;
             }
             //for parts, compare unit price against primap price by tier
             if (partsQuotes.containsKey(qli.QuoteId)){
                 qli.priceBelowFloor__c = qli.UnitPrice < qli.plmFloorPrice__c;
             }
             //for raw/concore, compare unit price against primap price per unit
             if (nonPartsQuotes.containsKey(qli.QuoteId)){
                 //qli.priceBelowFloor__c = qli.UnitPrice < priceMap.get(qli.Price__c).priceUnit__c;
                 // AN 4/27 - originally checking against price on spec
                 // is this the correct behavior once approved PLM price is set on price__c (need to complete)?
                 // parts & mto and raw be different - intital thought is yes - raw should be one time only  
                 qli.priceBelowFloor__c = qli.UnitPrice < qli.plmFloorPrice__c;
             }
             
         }//for qli
         
     }
/*     
     CreateQLI 
     
     
        List<string> rMessages = new List<String>();
        List<QuoteLineItem> lis = new List<QuoteLineItem>();
        QuoteLineItem li;
        for (Price__c p: prices){
           if (productPBEntryMap.containsKey(p.Product__c)){
               li = new QuoteLineItem();
               li.QuoteId = masterRecordId;
               li.price__c = p.Id;
               li.quantity = 1;
               if (p.Product__r.Family == Label.GGProductTypeParts){
                   li.unitPrice = 0;
               }else{
                   li.unitPrice = p.PriceUnit__c;
               }
               li.PricebookEntryId = productPBEntryMap.get(p.Product__c).Id; 
               lis.Add(li);
           }
        }
*/
    
    //Set Opportunity StageName to Order Pending, if Quote Status = Customer Accepted
    //Set Opportunity StageName to Quote Declined, if Quote Status = Customer Rejected  
    //Set Opportunity StageName to Customer Decision, if Quote Status = Sent
    public static void setSampleOpportunityStage(List<Quote> updatedQuotes, Map<Id, Quote> oldMap){
        list<Opportunity> oppList = new list<Opportunity>();
        Set<Id> sampleIds = new Set<Id>();

        //Get the RT Id for this RT Name
        RecordType sampleRT = utils.getRecordTypeID('Quote', label.GGQuoteSample);
        
        for (Quote quote : updatedQuotes) {
            if (quote.sampleRequest__c != null){ //Opportunity Id for the "Sample" Opportunity if this is a Sample Quote
                sampleIds.add(quote.sampleRequest__c);
            }
        }        
        
        if (sampleIds.size() > 0){
            for (Opportunity sampleOpp: [SELECT Id, StageName FROM Opportunity WHERE Id IN :sampleIds]) {
                for (Quote quote : updatedQuotes) {
                    if (quote.sampleRequest__c == sampleOpp.Id && quote.RecordTypeId == sampleRT.id) {                        
                        //if Quote Status = 'Customer Accepted', set Opportunity.StageName to 'Order Pending'
                        if (quote.Status == 'Customer Accepted' && oldMap.get(quote.Id).Status <> 'Customer Accepted') {
                            // AN 11/28/17 - Only set to Order Pending if status is not Fulfillment or later
                            if (sampleOpp.StageName != 'Fulfillment' && sampleOpp.StageName != 'Shipped Partial' && sampleOpp.StageName != 'Shipped Complete') {
                                sampleOpp.StageName = 'Order Pending';
                                oppList.add(sampleOpp);
                            }
                        }
                        //if Quote Status = 'Customer Rejected', set Opportunity.StageName to 'Quote Declined'
                        else if (quote.Status == 'Customer Rejected' && oldMap.get(quote.Id).Status <> 'Customer Rejected') {
                            sampleOpp.StageName = 'Quote Declined';
                            oppList.add(sampleOpp);
                        }
                        //if Quote Status = 'Sent', set Opportunity.StageName to 'Customer Decision'
                        if (quote.Status == 'Sent' && oldMap.get(quote.Id).Status <> 'Sent') {
                            // AN 11/28/17 - Only set to Customer Decision if status is not Order Pending or later
                            if (sampleOpp.StageName != 'Order Pending' && sampleOpp.StageName != 'Fulfillment' && sampleOpp.StageName != 'Shipped Partial' && sampleOpp.StageName != 'Shipped Complete') {
                                sampleOpp.StageName = 'Customer Decision';
                                oppList.add(sampleOpp);
                            }
                        }
                    }
                }                          
            }
        }
         
        if (oppList.size() > 0) {
            update oppList; 
        }
    }

// ************************
    public static void validateWonOpportunity(List<Quote> updatedQuotes) { // AN 8/15/18
        
        Set<Id> oppIds = new Set<Id>();
        
        for (Quote q : updatedQuotes) {
            if (q.sampleRequest__c == null && q.Status == 'Customer Accepted') { // MP Quotes
                oppIds.add(q.OpportunityId);
            }     
        }
        
        list<Opportunity> oppList = new list<Opportunity>();
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>(); 
        
        oppList = [SELECT Id, recordtype.name, wlDescription__c, wonReason__c, Start_of_Production__c, IsClosed, 
                   IsWon, type, mPExchangeLockReason__c, mpExchangeRateLockDate__c, mpQuoteCurrency__c, StageName 
                   FROM Opportunity WHERE Id IN :oppIds];
       
        for (Opportunity o : oppList) {
            oppMap.put(o.Id, o);    
        }

        If (oppList.size() > 0) { // AN 8/24/18 - following code block was causing test errors - oppList was null        
        
            for (Quote quote : updatedQuotes) {
                If (oppMap.get(quote.OpportunityId).recordtype.name == 'GG Program' && (quote.quoteType__c == 'Parts – Mass Production Quote' || quote.quoteType__c == 'Parts – Mass Production Quote with Sample') ) {
                    if (oppMap.get(quote.OpportunityId).IsClosed == True && oppMap.get(quote.OpportunityId).IsWon == True) {
                        if (oppMap.get(quote.OpportunityId).wonReason__c == Null || oppMap.get(quote.OpportunityId).Start_of_Production__c == Null) {
                            quote.addError(' The Closed/Won opportunity must be updated and saved before accepting the quote. The opportunity is missing required data.');
                        }
                        if (oppMap.get(quote.OpportunityId).wonReason__c == 'Others' && oppMap.get(quote.OpportunityId).wlDescription__c == Null) {
                            quote.addError(' The Closed/Won opportunity must be updated and saved before accepting the quote. The opportunity is missing required data.');
                        }
                        
                    }
                    
                    if (oppMap.get(quote.OpportunityId).IsClosed == True && oppMap.get(quote.OpportunityId).IsWon == False) {
                        quote.addError(' Please update the opportunity stage to 6 - Post Purchase Behaviors (Closed/Won) before accepting the quote.');
                    }
                }            
            }    

        }
    }

    // Set Opportunity StageName to 5 - Implement Solutions, if Quote Status = Customer Accepted
    // Extend Spcification MP price expiration date
    public static void setOpportunityStageAndPriceExpiration(List<Quote> updatedQuotes, Map<Id, Quote> oldMap){
        list<Opportunity> oppList = new list<Opportunity>();
        list<Price__c> priceList = new list<Price__c>();
        list<QuoteLineItem> qliList = new list<QuoteLineItem>(); // AN 8/29/18
        list<Specification__c> specList = new list<Specification__c>(); // AN 8/29/18
        
        Set<Id> qIds = new Set<Id>();
        Set<Id> specIds = new Set<Id>();
        Set<Id> p2Ids = new Set<Id>();        
        Set<Id> oppIds = new Set<Id>();   
        Map<Id,String> oppToQuoteCurrencyMap = new Map<Id,String>(); // AN 1/3/18
        Map<Id,String> oppToQuoteTypeMap = new Map<Id,String>(); // AN 1/15/18
        Map<String,QuoteLineItem> specToQLIMap = new Map<String,QuoteLineItem>(); // AN 8/29/18
                
        // limit to MP & Customer Accepted
        for (Quote quote : updatedQuotes) {
            if (quote.sampleRequest__c == null && quote.Status == 'Customer Accepted' && oldMap.get(quote.Id).Status <> 'Customer Accepted') {
                oppIds.add(quote.OpportunityId);
                qIds.add(quote.id);
                oppToQuoteCurrencyMap.put(quote.OpportunityId,quote.currency__c); // AN 1/3/18
                oppToQuoteTypeMap.put(quote.OpportunityId,quote.quoteType__c); // AN 1/15/18
            }
        }        

        if (qIds.size() > 0) {
            qliList = [SELECT Id, UnitPrice, partsTierMap__c, specification__c FROM QuoteLineItem WHERE QuoteId IN :qIds];
            
            for (QuoteLineItem li:qliList) {
                specIds.add(li.specification__c); 
                // AN - 8/29/18 - build a concatinated key (SpecId + PartsTierMamp) to reference the quoted tier price    
                system.debug('***specToQLIMap ' + li.specification__c + li.partsTierMap__c);         
                specToQLIMap.put(li.specification__c + li.partsTierMap__c,li);                      
            }
        }

        if (specIds.size() > 0) {
            for (Product2 p2: [SELECT Id, specification__c FROM Product2 WHERE specification__c IN :specIds]) {
                p2Ids.add(p2.id);
                system.debug('***P2 ' + p2.id);                                           
            }
        }
        
        if (p2Ids.size() > 0) {
        
            for (Price__c p: [SELECT Id, product__r.name, specification__c, mpQuotePrice1__c, mpQuotePrice2__c, mpQuotePrice3__c, mpQuotePrice4__c, productFamily__c, priceExpirationDate__c, createdDate FROM Price__c WHERE Product__c IN :p2Ids]) {
                system.debug('$$$: ' + p.id + ' - ' + p.product__r.name + p.specification__c + ' - ' + p.productFamily__c);      
                // only update for parts
                if (p.productFamily__c == 'Parts' && p.specification__c != Null) { // Inventory Part does not have a spec
                    ID i = Id.valueOf(p.specification__c);
                    
                    Date dt;
                    Date crDate = date.newinstance(p.createdDate.year(), p.createdDate.month(), p.createdDate.day());
                    If (Date.today() >= p.createdDate.addYears(2)) {
                        dt = crDate.addYears(3);
                    } else {
                        dt = crDate.addYears(2);
                    }
                    p.priceExpirationDate__c = dt;
                                        
                    // AN - 8/29/18 update MP quote prices
                    system.debug('***specToQLIMapMatch ' + String.valueOf(i) + '1');
                    system.debug('***specToQLIMapMatch ' + String.valueOf(i) + '2');
                    system.debug('***specToQLIMapMatch ' + String.valueOf(i) + '3');
                    system.debug('***specToQLIMapMatch ' + String.valueOf(i) + '4');
                    
                    if (specToQLIMap.containsKey(String.valueOf(i) + '1')) {
                        p.mpQuotePrice1__c = specToQLIMap.get(String.valueOf(i) + '1').UnitPrice;
                    }
                    if (specToQLIMap.containsKey(String.valueOf(i) + '2')) {
                        p.mpQuotePrice2__c = specToQLIMap.get(String.valueOf(i) + '2').UnitPrice;
                    }
                    if (specToQLIMap.containsKey(String.valueOf(i) + '3')) {
                        p.mpQuotePrice3__c = specToQLIMap.get(String.valueOf(i) + '3').UnitPrice;
                    }
                    if (specToQLIMap.containsKey(String.valueOf(i) + '4')) {
                        p.mpQuotePrice4__c = specToQLIMap.get(String.valueOf(i) + '4').UnitPrice;
                    }     
                    
                    priceList.add(p);  
                }                                                
            }
        }
        
        if (oppIds.size() > 0) {
            for (Opportunity programOpp: [SELECT Id, recordtype.name, wlDescription__c, wonReason__c, Start_of_Production__c, IsClosed, IsWon, type, mPExchangeLockReason__c, mpExchangeRateLockDate__c, mpQuoteCurrency__c, StageName 
                                            FROM Opportunity WHERE Id IN :oppIds]) { // AN 1/3/18 added fields to query
                If (programOpp.IsClosed == False) {
                    programOpp.StageName = '5 - Implement Solutions';
                                        
                    // AN 1/3/18 for locking in exchange rate BEGIN
                    If (programOpp.recordtype.name == 'GG Program' && (oppToQuoteTypeMap.get(programOpp.Id) == 'Parts – Mass Production Quote' || oppToQuoteTypeMap.get(programOpp.Id) == 'Parts – Mass Production Quote with Sample') ) {
                        If (programOpp.mpQuoteCurrency__c == Null) { // lock in only once only for MP Parts Quotes
                            programOpp.mpExchangeRateLockDate__c = Date.Today();
                            programOpp.mPExchangeLockReason__c = 'MP Quote Customer Accepted';
                            programOpp.mpQuoteCurrency__c = oppToQuoteCurrencyMap.get(programOpp.Id); 
                            programOpp.mpJpyExchangeRate__c = GG_Currency_Display_Settings__c.getValues('Japanese Yen').exchangeValue__c;
                            programOpp.mpRmbExchangeRate__c = GG_Currency_Display_Settings__c.getValues('Chinese Yuan').exchangeValue__c;
                            programOpp.GG_VNDExchangeRate__c = GG_Currency_Display_Settings__c.getValues('Vietnamese Dong').exchangeValue__c;
                        }
                    }
                    oppList.add(programOpp); 
                    // AN 1/3/18 END new code
                    
                } else { // AN 8/14/18 also enable for won opportunities that have required info completed
                    If (programOpp.IsWon == True ) {
                        If (programOpp.recordtype.name == 'GG Program' && (oppToQuoteTypeMap.get(programOpp.Id) == 'Parts – Mass Production Quote' || oppToQuoteTypeMap.get(programOpp.Id) == 'Parts – Mass Production Quote with Sample') ) {
                            if (programOpp.wonReason__c != Null && programOpp.Start_of_Production__c != Null) {
                                If (programOpp.wonReason__c != 'Others') { 
                                    If (programOpp.mpQuoteCurrency__c == Null) { // lock in only once only for MP Parts Quotes
                                        programOpp.mpExchangeRateLockDate__c = Date.Today();
                                        programOpp.mPExchangeLockReason__c = 'MP Quote Customer Accepted';
                                        programOpp.mpQuoteCurrency__c = oppToQuoteCurrencyMap.get(programOpp.Id); 
                                        programOpp.mpJpyExchangeRate__c = GG_Currency_Display_Settings__c.getValues('Japanese Yen').exchangeValue__c;
                                        programOpp.mpRmbExchangeRate__c = GG_Currency_Display_Settings__c.getValues('Chinese Yuan').exchangeValue__c;
                                        programOpp.GG_VNDExchangeRate__c = GG_Currency_Display_Settings__c.getValues('Vietnamese Dong').exchangeValue__c;
                                        oppList.add(programOpp);
                                    }
                                } else {
                                    If (programOpp.wlDescription__c != Null) { // Others requires description to be populaetd
                                        If (programOpp.mpQuoteCurrency__c == Null) { // lock in only once only for MP Parts Quotes
                                            programOpp.mpExchangeRateLockDate__c = Date.Today();
                                            programOpp.mPExchangeLockReason__c = 'MP Quote Customer Accepted';
                                            programOpp.mpQuoteCurrency__c = oppToQuoteCurrencyMap.get(programOpp.Id); 
                                            programOpp.mpJpyExchangeRate__c = GG_Currency_Display_Settings__c.getValues('Japanese Yen').exchangeValue__c;
                                            programOpp.mpRmbExchangeRate__c = GG_Currency_Display_Settings__c.getValues('Chinese Yuan').exchangeValue__c;
                                            programOpp.GG_VNDExchangeRate__c = GG_Currency_Display_Settings__c.getValues('Vietnamese Dong').exchangeValue__c;
                                            oppList.add(programOpp);
                                        }   
                                    }
                                }
                            }
                        }
                    } // end review won opportunitites
                }
            }
        }

        system.debug('*** ' + priceList.size());
        system.debug('*** ' + oppList.size());

        if (priceList.size() > 0) {
            update priceList; 
        }
         
        if (oppList.size() > 0) {
            update oppList; 
        }
    }
// ************************
    
    //set specification lookup on quote line item to product's specification__c
    public static void setSpecificationLookup(List<QuoteLineItem> qlis){
        Set<Id> products = new Set<Id>();
        Set<Id> pbes = new Set<Id>();
        for (QuoteLineItem li: qlis){
            system.debug('Product2Id: ' + li.Product2Id);
            
            //it seems Product2Id is not set in Summer 17 release, so read from pricebookentry
            if (li.PricebookEntryId != null){
                pbes.add(li.PricebookEntryId);
            }
            
            //it seems Product2Id is not set in Summer 17 release
            if (li.Product2Id != null){
                products.add(li.Product2Id);
            }
        } 
        
        Map<Id, PriceBookEntry> pbMap = new Map<Id, PriceBookEntry>();
        //it seems Product2Id is not set in Summer 17 release, so read from pricebookentry
        for (PriceBookEntry pbe: [SELECT Id, Product2Id FROM PriceBookEntry WHERE Id in: pbes]){
            products.add(pbe.Product2Id);
            pbMap.put(pbe.Id, pbe);
        }
        
        Map<Id, Product2> prMap = new Map<Id, product2>();
        for (Product2 p: [SELECT Id, isPrebuild__c, Specification__c, specification__r.approvedBy__r.Email FROM Product2 WHERE Id in :products]){
            prMap.put(p.Id, p);
        }
        Product2 pr;
        Id prId;
        PriceBookEntry pbe;
        for (QuoteLineItem li: qlis){
            prId = li.Product2Id;
            if (prId == null){
                pbe = pbMap.get(li.PricebookEntryId);
                if (pbe != null){
                    prId = pbe.Product2Id;
                }
            }
            pr = prMap.get(prId);//prMap.get(li.Product2Id);
            if (pr != null){
                if(!pr.isPrebuild__c){
                	li.specification__c = pr.specification__c; 
                }
                li.pLMApproverEmail__c = pr.specification__r.approvedBy__r.Email; // AN 5/24/18
            }
        }
    }
    
    //QuoteLineItem records cannot be deleted if the Quote RT is "GG Sample"
    public static void preventSampleDelete(List<QuoteLineItem> qlisToDelete) {
        Set<Id> quotes = new Set<Id>();
        map<Id,Quote> sampleMap = new map<Id,Quote>();
        
        //get record type id of sample quote record type
        Id quoteRtId = Utils.getRecordTypeId('Quote','GG Sample').Id;

        System.debug('GG Sample RecordType:' + quoteRtId);
        
        //make set of Quote Id's referenced in QLI records
        for (QuoteLineItem qliToDelete : qlisToDelete) {
            quotes.add(qliToDelete.QuoteId);
        }
        
        //Add Quote records with GG Sample RT to a map
        for (Quote q : [SELECT Id, RecordTypeId FROM Quote WHERE Id IN :quotes]){
            System.debug('GG Sample RecordType:' + quoteRtId + ' quote recordtype:' + q.RecordTypeId);
            if (q.RecordTypeId == quoteRTId) {
                sampleMap.put(q.Id, q);
            }
        } 
        
        //If the map contains an entry for the Quote that owns this QLI record, prevent Delete
        for (QuoteLineItem qliToDelete : qlisToDelete) {
            System.debug('GG Sample RecordType:' + quoteRtId + ' qli ID: ' + qliToDelete.Id + ' qliToDelete QuoteId:' + qliToDelete.QuoteId);
            if (sampleMap.containsKey(qliToDelete.QuoteId)){
                qliToDelete.addError(Label.GGDeleteQLIError);
            }
        }       
    }
    
    //method on after insert which filters the quotes and call updateOpportunityFields method to 
    public static void onAfterInsert(List<Quote> newQuotes){
    	List<Quote> quotesToUse = new List<Quote>();
        for(Quote q : newQuotes){
            if(q.sampleRequest__c != null && (q.currency__c != null || q.corningSellingEntity__c != null)){
                quotesToUse.add(q);
            }    
        }
        if(quotesToUse.size() > 0){
            updateOpportunityFields(quotesToUse);
        }
    }
    
    //method to check whether the curreny and selling entitiy have changed on the quote, if true then update the parent opportunity
    public static void onAfterUpdate(List<Quote> newQuotes, Map<Id, Quote> oldQuoteMap){
    	List<Quote> quotesToUse = new List<Quote>();
        for(Quote q : newQuotes){
            if(q.currency__c != oldQuoteMap.get(q.Id).currency__c || q.corningSellingEntity__c != oldQuoteMap.get(q.Id).corningSellingEntity__c){
                quotesToUse.add(q);
            }    
        }
        if(quotesToUse.size() > 0){
            updateOpportunityFields(quotesToUse);
        }
    }
    
    //Updating opportunity by taking its instance from quote and update the required fields.
    private static void updateOpportunityFields(List<Quote> quotes){
        Map<String, Opportunity> mapOpportunities = new Map<String, Opportunity>();
        for(Quote q : quotes){
            System.debug('***- MyQuote: '+q);
            if(q.sampleRequest__c != null){
                mapOpportunities.put(q.sampleRequest__c, new Opportunity(Id = q.sampleRequest__c
                                                  , QuoteCurrency__c = q.currency__c, QuoteSellingEntity__c = q.corningSellingEntity__c));
            }
        }
        System.debug('***- Opportunities: '+mapOpportunities);
        if(mapOpportunities.size() > 0){
            UPDATE mapOpportunities.values();
        }
    }
}