///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 2/21/2017 ***///
///*** Controller class used in the add product line items to opportunity or quote. ***///
public class OptyQuoteLIUtility {
    private Id masterRecordId;
    private List<Id> productsToAdd;
    //private List<Id> priceIds;
    private List<Price__c> prices;
    private List<PriceBookEntry> priceBookEntrys;
    private map<Id, PriceBookEntry> productPBEntryMap;
    
    Static Utilities utils = new Utilities();
    
    public OptyQuoteLIUtility(Id mId, List<Id> pPriceIds){
        masterRecordId = mId;
        //priceIds = pPriceIds;
        
        prices = new List<Price__c>();
        productPBEntryMap = new Map<Id, PriceBookEntry>();
        
        ProductsToAdd = new List<Id>();
        
        // an 6/13 add sample pricing
        if (pPriceIds != null && pPriceIds.size() > 0){
            for (Price__c p: [SELECT Id, SystemModstamp, product__r.Family, product__r.MOQ__c, product__r.isMto__c, 
                        Product__c, priceUnit__c, unitPrice__c, price1__c, price2__c, price3__c, price4__c, 
                        UpperLimit1__c, upperLimit2__c, upperLimit3__c, upperLimit4__c, shippingPrice__c,
                        samplePrice__c, sampleRange__c, product__r.sampleMOQ__c 
                     FROM Price__c WHERE Id in :pPriceIds]){
                ProductsToAdd.add(p.Product__c);
                prices.add(p);
            }
        }
         
        Id pbId = '01so0000004gBaQAAU';//utils.getGGPriceBookId();
        
        for (PriceBookEntry pbe: [SELECT Id, Product2Id FROM PriceBookEntry WHERE Product2Id in :productsToAdd AND PriceBook2Id = :pbId]){
            productPBEntryMap.put(pbe.Product2Id, pbe);
        }
    }
    
    //add line items to the master record
    public Utilities.DMLResult addLineItems(){
        //adding product to quote or opportunity? 
        if (utils.isRecordIdForQuote(masterRecordId)){
            return addLineItemsToQuote();
        }
        else{
            return addLineItemsToOpportunity();
        }
    }
    
    //Add line items to the opportunity
    //AN 12/12 enable device tracker when added from spec to product
    private Utilities.DMLResult addLineItemsToOpportunity(){
        List<string> rMessages = new List<String>();
        List<OpportunityLineItem> lis = new List<OpportunityLineItem>();
        
        Utilities.DMLResult result = new Utilities.DMLResult();
        
        Opportunity o = new Opportunity();
        Utilities.SampleOptyResult soresult =  utils.isSampleOpportunity2(masterRecordId);
        boolean isSampleOpportunity = soresult.isSample;
        if (isSampleOpportunity && ((productsToAdd.size() > 1)|| (soresult.countSampleOptyLineItems > 0))){
            result.success = false;
            result.message = Label.SampleOnlyOneProduct;
            return result;
        }
        
        OpportunityLineItem li;
        for (Price__c p: prices){
           if (productPBEntryMap.containsKey(p.Product__c)){
               li = new OpportunityLineItem();
               li.OpportunityId = masterRecordId;
               li.PricebookEntryId = productPBEntryMap.get(p.Product__c).Id; 
               li.price__c = p.Id;
               li.Quantity = 1;
               li.unitPrice = 0;
               if (p.Product__r.Family != Label.GGProductTypeParts){// && !p.Product__r.isMto__c){
                 decimal uprice = p.unitPrice__c;
                 if (p.shippingPrice__c != null){
                   uprice += p.shippingPrice__c;
                 }
                 li.unitPrice = uprice;
               }
               if (li.unitPrice == null){
                   li.unitPrice = 0;
               }
               // if the product was created within the last minute assume the system is adding it
               if (p.SystemModstamp > Datetime.now().addMinutes(-1)) {
                   li.addedBySystem__c = true;
                   li.serviceDate = Date.Today();
               }
               lis.Add(li);
           }
        }
        
        result.Success = true;
        Integer iSuccess = 0;
        Database.SaveResult[] srList = Database.Insert(lis, true);
        for (Database.SaveResult sr : srList) {
              if (sr.isSuccess()){
                iSuccess++;
              }else{
                  result.success = false;
                  for(Database.Error err : sr.getErrors()){
                      result.ErrorMessages.add(err.getMessage());
                  }
              }
        }
        
        result.Message = String.valueOf(iSuccess) + ' of ' + String.valueOf(lis.size()) + ' products added successfully.';
        return result;
    }
    
    //Add line items to the quote
    private void addPartsLineItemsToProgramQuote(List<QuoteLineItem> lis, Id priceId, Id priceBookEntryId, decimal quantity, decimal price, string partsPricingTier, string partsTierMap){
        if (quantity == null || price == null){
            return;
        }
        QuoteLineItem li = new QuoteLineItem();
        li.manuallyAdded__c = true;
        li.QuoteId = masterRecordId;
        li.price__c = priceId;//p.Id;
        li.quantity = quantity;
        li.unitPrice = price;
        li.partsPricingTier__c = partsPricingTier;
        li.partsTierMap__c = partsTierMap;
        li.plmFloorPrice__c = price;
        li.PricebookEntryId = priceBookEntryId;//productPBEntryMap.get(p.Product__c).Id; 
        lis.Add(li);
    }
    
    //Add line items to the quote
    private Utilities.DMLResult addLineItemsToQuote(){
        List<string> rMessages = new List<String>();
        List<QuoteLineItem> lis = new List<QuoteLineItem>();
        QuoteLineItem li;
        for (Price__c p: prices){
           if (productPBEntryMap.containsKey(p.Product__c)){

               if (!utils.isSampleQuote(masterRecordId) && p.Product__r.Family == Label.GGProductTypeParts){
                   Set<Id> priceIds = new Set<Id>();
                   //only add the product is it doesn't already exist
                   Integer count = [SELECT Count() FROM QuoteLineItem WHERE QuoteId = :masterRecordId AND Price__c = :p.Id];
                   
                   //for program parts quotes, add all tiers
                   // AN - 4/30/18 - adding additional paramenter to set new field partsTierMap__c on QLI
                   system.debug('$$$ Count: ' + count);
                   system.debug('$$$ Sample Price: ' + p.samplePrice__c);
                   system.debug('$$$ Include?: ' + utils.includeSamplesForQuote(masterRecordId));
                   if (count == 0){
                       string tier;
                       
                       // an - 6/13/18 - add sample price
                       if (p.samplePrice__c != null && utils.includeSamplesForQuote(masterRecordId)){
                           // tier =  p.sampleRange__c;
                           tier =  utils.doFormatting(p.product__r.sampleMOQ__c,0,',','.') + ' - ' + utils.doFormatting(p.product__r.MOQ__c - 1,0,',','.');
         
                           addPartsLineItemsToProgramQuote(lis, p.Id, productPBEntryMap.get(p.Product__c).Id, p.upperLimit1__c - 1, p.samplePrice__c, tier, '0');
                       }                       
                       
                  
                       
                       
                       //if (p.product__r.MOQ__c != null){
                       //    tier =  utils.doFormatting(p.product__r.MOQ__c,0,',','.') + ' - ' + utils.doFormatting(p.upperLimit1__c,0,',','.');
                       //}
                       //else{
                       //    tier = ' < ' + utils.doFormatting(p.upperLimit1__c,0,',','.');
                       //}
                       
                       // AN - 8/24/18 - if there is only one tier then show > MOQ - 1, not range           
                       if (p.product__r.MOQ__c == null && p.upperLimit2__c == null) {
                           tier = ' < ' + utils.doFormatting(p.upperLimit1__c,0,',','.');       
                       }
                       if (p.product__r.MOQ__c != null && p.upperLimit2__c == null) {
                           tier = ' > ' + utils.doFormatting(p.product__r.MOQ__c - 1,0,',','.');
                       }
                       if (p.product__r.MOQ__c != null && p.upperLimit2__c != null && p.price2__c == null) {
                           tier = ' > ' + utils.doFormatting(p.product__r.MOQ__c - 1,0,',','.');
                       }
                       if (p.product__r.MOQ__c != null && p.upperLimit2__c != null && p.price2__c != null) {
                           tier =  utils.doFormatting(p.product__r.MOQ__c,0,',','.') + ' - ' + utils.doFormatting(p.upperLimit1__c,0,',','.');
                       }
                       
                       // ADD TIER 1 - line will not be added if either spec upper limit or price is null
                       addPartsLineItemsToProgramQuote(lis, p.Id, productPBEntryMap.get(p.Product__c).Id, p.upperLimit1__c, p.price1__c, tier, '1');
                       // ----------


                       
                       if (p.upperLimit3__c == null){
                           tier = ' > ' + utils.doFormatting(p.upperLimit1__c,0,',','.');
                       }
                       else{
                           tier = utils.doFormatting((p.upperLimit1__c + 1),0,',','.') + ' - ' +  utils.doFormatting(p.upperLimit2__c,0,',','.');
                       }
                       
                       // ADD TIER 2 - line will not be added if either spec upper limit or price is null
                       addPartsLineItemsToProgramQuote(lis, p.Id, productPBEntryMap.get(p.Product__c).Id, p.upperLimit2__c, p.price2__c, tier, '2');
                       // ----------



                       if (p.upperLimit3__c != null){
                           
                           if (p.upperLimit4__c == null){
                               tier = ' > ' + utils.doFormatting(p.upperLimit2__c,0,',','.');
                           }
                           else{
                               tier = utils.doFormatting((p.upperLimit2__c + 1),0,',','.') + ' - ' +  utils.doFormatting(p.upperLimit3__c,0,',','.');
                           }
                           
                           // TIER 3 - line will not be added if either spec upper limit or price is null
                           addPartsLineItemsToProgramQuote(lis, p.Id, productPBEntryMap.get(p.Product__c).Id, p.upperLimit3__c, p.price3__c, tier, '3');
                           // ----------

                           
                           tier = ' > ' + utils.doFormatting(p.upperLimit3__c,0,',','.');
                           // TIER 4 - line will not be added if either spec upper limit or price is null
                           addPartsLineItemsToProgramQuote(lis, p.Id, productPBEntryMap.get(p.Product__c).Id, p.upperLimit4__c, p.price4__c, tier, '4');  
                           // ----------

                       }
                   }
               }
               else{
                   li = new QuoteLineItem();
                   li.manuallyAdded__c = true;
                   li.QuoteId = masterRecordId;
                   li.price__c = p.Id;
                   li.quantity = 1;
                   if (p.Product__r.Family == Label.GGProductTypeParts){
                       li.unitPrice = 0;
                   }
                   else{
                       li.unitPrice = p.PriceUnit__c;
                       li.freight__c = p.shippingPrice__c;
                       li.plmFloorPrice__c = p.PriceUnit__c;
                   }
                   li.PricebookEntryId = productPBEntryMap.get(p.Product__c).Id; 
                   lis.Add(li);
               }
           }
        }
        
        Utilities.DMLResult result = new Utilities.DMLResult();
        result.Success = true;
        Integer iSuccess = 0;
        Database.SaveResult[] srList = Database.Insert(lis, true);
        for (Database.SaveResult sr : srList) {
              if (sr.isSuccess()){
                iSuccess++;
              }
              else{
                  result.success = false;
                  for(Database.Error err : sr.getErrors()){
                      result.ErrorMessages.add(err.getMessage());
                  }
              }
        }
        
        result.Message = String.valueOf(iSuccess) + ' of ' + String.valueOf(lis.size()) + ' products added successfully.';
        return result;
               
    }
    
    public static Utilities.DMLResult scheduleOptyLineItems(String recordId, List<OpportunityLineItem> optyLineItems){
        if (recordId == null || optyLineItems == null || optyLineItems.size() == 0){
            return null;
        }
        
        Set<Id> productIds = new Set<Id>();
        Set<Id> priceIds = new Set<Id>();
        for (OpportunityLineItem oli: optyLineItems){
            if (oli.product2Id != null){
                productIds.add(oli.product2Id);
            }
            if (oli.Price__c != null){
                priceIds.add(oli.Price__c);
            }
        }
        
        Map<Id, PriceBookEntry> productPBEntryMap = new Map<Id, PriceBookEntry>();
        
        Id pbId = '01so0000004gBaQAAU';//utils.getGGPriceBookId();
        
        for (PriceBookEntry pbe: [SELECT Id, Product2Id FROM PriceBookEntry WHERE Product2Id in :productIds AND PriceBook2Id = :pbId]){
            productPBEntryMap.put(pbe.Product2Id, pbe);
        }
        
        Map<Id, Price__c> priceMap = new Map<Id, Price__c>();
        for (Price__c p: [SELECT Id, PriceUnit__c, productFamily__c FROM Price__c WHERE Id in :priceIds]){
            priceMap.put(p.Id, p);
        }
        
        OpportunityLineItem[] lstLineItems = optyLineItems;
        
        List<OpportunityLineItem> lis = new List<OpportunityLineItem>();
        OpportunityLineItem newLI;
        
        for (OpportunityLineItem li: lstLineItems){
            integer numberOfMonths = (integer)li.quantity;
            //decimal quantity = 1;
            system.debug('li.Product2Id: ' + li.Product2Id);
            for (integer j=0; j < numberOfMonths ; j++) { 
                newLI = new OpportunityLineItem();
                newLI.OpportunityId = recordId;
                newLI.PricebookEntryId = productPBEntryMap.get(li.Product2Id).Id;//li.PriceBookEntryId; 
                newLI.price__c = li.price__c;
                newLi.forecastCategory__c = li.forecastCategory__c;
                newLI.Quantity = 1;
                newLI.ServiceDate = li.ServiceDate.addMonths(j);
                system.debug('serviceDate: ' + newLI.serviceDate);
                if (li.unitPrice == null){
                    newLI.unitPrice = 0;
                }else{
                    newLI.unitPrice = li.unitPrice;
                }
    
                lis.add(newLI);
            }
        }
        
        Utilities.DMLResult result = new Utilities.DMLResult();
        result.Success = true;
        Integer iSuccess = 0;
        Database.SaveResult[] srList = Database.Insert(lis, true);
        for (Database.SaveResult sr : srList) {
              if (sr.isSuccess()){
                iSuccess++;
              }else{
                  result.success = false;
                  for(Database.Error err : sr.getErrors()){
                      result.ErrorMessages.add(err.getMessage());
                  }
              }
        }
        
        result.Message = String.valueOf(iSuccess) + ' of ' + String.valueOf(lis.size()) + ' products added successfully.';
        
        return result;
    }
}