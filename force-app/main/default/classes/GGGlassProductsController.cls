/**
 * @description       : 
 * @author            : Adam Nicholson?
 * @group             : 
 * @last modified on  : 09-04-2020
 * @last modified by  : Edgar Santillana
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.1   07-12-2020   Arquimidez Mora   Fixing error string that appeared in component
 * 1.2   03/09/2020  Edgar Santillana   priceExpirationDate__c changed from 30 days to 2 years
**/
///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 2/21/2017 ***///
///*** Controller class used in the add products custom Lightning component. ***///
public class GGGlassProductsController {
    static Utilities utils = new Utilities();

    public class LISaveResult{
        @AuraEnabled public boolean success { get; set;}
        @AuraEnabled public String message { get; set;}
        
        public LISaveResult(){
            success = true;
            message = '';
        }
    }
    
    public class LineItemsSaveResults{
        @AuraEnabled public boolean success { get; set;}
        @AuraEnabled public string saveMessage { get; set;}
        @AuraEnabled public List<LISaveResult> liSaveMessages { get; set;}
        
        public LineItemsSaveResults(){
            success = true;
            liSaveMessages = new List<LISaveResult>();
        }
    }
    
    public class RecordAccess{
    //does the current user have permission to opportunity line item and fields?
        @AuraEnabled public boolean RecordEditable { get; set;}
        @AuraEnabled Public boolean RecordCreatable { get; set;}
        @AuraEnabled Public boolean RecordViewable { get; set;}
        @AuraEnabled Public boolean UnitPriceViewable { get; set;}
        @AuraEnabled Public boolean UnitPriceEditable { get; set;}
        @AuraEnabled Public boolean QuantityViewable { get; set;}
        @AuraEnabled Public boolean QuantityEditable { get; set;}
        @AuraEnabled Public boolean ForecastViewable { get; set;}
        @AuraEnabled Public boolean ForecastEditable { get; set;}
        @AuraEnabled Public boolean ServiceDateViewable { get; set;}
        @AuraEnabled Public boolean ServiceDateEditable { get; set;}
        @AuraEnabled Public boolean FreightEditable { get; set;}
        @AuraEnabled Public boolean FreightViewable { get; set;}        
    }
    
    public class QuoteLineItemsWrapper{
        private Id quoteId;
        @AuraEnabled Public RecordAccess Access { get; set;}
        @AuraEnabled Public boolean runningInSF1 { get; set;}
        @AuraEnabled Public boolean isSampleQuote { get; set;}
        @AuraEnabled Public string quoteStatus { get; set ;}
        @AuraEnabled Public boolean performFloorPriceCheck { get; set;}
        @AuraEnabled public List<QuoteLineItem> lineItems { get; set;}
        @AuraEnabled public Boolean isBlueQuote { get; set; }
        @AuraEnabled public Boolean isPartsProgramQuote { get; set; }
        @AuraEnabled public Boolean showPLMButtons { get; set;}
        
        public QuoteLineItemsWrapper(Id qId){
            quoteId = qId;
            runningInSF1 = (UserInfo.getUiThemeDisplayed() == Label.Salesforce1Theme);
            lineItems = new List<QuoteLineItem> ();
            
            Quote q = [SELECT Id, RecordTypeId, Status FROM Quote WHERE Id = :quoteId LIMIT 1];
            quoteStatus = q.Status;
            
            String rt = utils.getRecordTypeName(q.RecordTypeId);
            isSampleQuote = (rt == Label.GGQuoteSample);
            isPartsProgramQuote = (rt == Label.GGQuoteParts);
            isBlueQuote = utils.isBlueOptyOrQuote(quoteId);
            
            //don't perform floor price check once PLM approves or rejects pricing
            performFloorPriceCheck = (quoteStatus != Label.GGQuotePricingApproved && quoteStatus != Label.GGQuotePricingRejected);
            
            
            //set the access level for the current user            
            Schema.DescribeSObjectResult drSObj = Schema.sObjectType.QuoteLineItem;
            Id uId = UserInfo.getUserId();
            Access = new RecordAccess();
            
            //does user have edit or read access to the quote?           
            UserRecordAccess ur = [SELECT RecordId, HasReadAccess, HasEditAccess FROM UserRecordAccess WHERE UserId = :uId AND RecordId = :qId];             
            Access.RecordCreatable = drSObj.isCreateable() && ur.HasEditAccess;
            Access.RecordEditable = ur.HasEditAccess && drSObj.isUpdateable();
            Access.RecordViewable = ur.HasReadAccess && drSObj.isAccessible();
            Access.QuantityEditable = (Schema.SObjectType.QuoteLineItem.fields.Quantity.isUpdateable()) && (Access.RecordEditable);
            Access.UnitPriceEditable = (Schema.SObjectType.QuoteLineItem.fields.UnitPrice.isUpdateable()) && (Access.RecordEditable);
            Access.UnitPriceViewable = Schema.SObjectType.QuoteLineItem.fields.UnitPrice.isAccessible() && Access.RecordViewable;
            Access.QuantityViewable = Schema.SObjectType.QuoteLineItem.fields.Quantity.isAccessible() && Access.RecordViewable;
            Access.FreightEditable = (Schema.SObjectType.QuoteLineItem.fields.Freight__c.isUpdateable()) && (Access.RecordEditable);
            Access.FreightViewable = Schema.SObjectType.QuoteLineItem.fields.Freight__c.isAccessible() && Access.RecordViewable;
            
            
            Integer perm = [SELECT Count() FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId() AND PermissionSet.Name = :Label.GGPermSetPLMApproval];
            
            Id sysAdmin =[SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
            //only sys admins or users with permission set "PLM Approval" can access PLM approval buttons
            showPLMButtons = (perm > 0 || UserInfo.getProfileId() == sysAdmin);
        }
    }
    
    public class OpttyLineItemsWrapper{
        private Id optyId;
        
        //does the current user have permission to opportunity line item and fields?
        @AuraEnabled public RecordAccess Access { get; set;}
        @AuraEnabled Public boolean runningInSF1 { get; set;}
        @AuraEnabled Public boolean isSampleOptty { get; set;}
        @AuraEnabled public List<OpportunityLineItem> lineItems { get; set;}
        @AuraEnabled public Boolean showPLMButtons { get; set;}
        @AuraEnabled public Integer totalNumberOfOLIs {get; set;}
        
        public OpttyLineItemsWrapper(Id oId){
            optyId = oId;
            runningInSF1 = (UserInfo.getUiThemeDisplayed() == Label.Salesforce1Theme);
            lineItems = new List<OpportunityLineItem> ();
            Access = new RecordAccess();
            
            //set the access level for the current user            
            Schema.DescribeSObjectResult drSObj = Schema.sObjectType.OpportunityLineItem;
            
            Id uId = UserInfo.getUserId();
            //does user have edit or read access to the opportunity?
            UserRecordAccess ur = [SELECT RecordId, HasReadAccess, HasEditAccess FROM UserRecordAccess WHERE UserId = :uId AND RecordId = :optyId];             
            Access.RecordEditable = ur.HasEditAccess && drSObj.isUpdateable();
            Access.RecordViewable = ur.HasReadAccess && drSObj.isAccessible();
            Access.RecordCreatable = ur.HasEditAccess && drSObj.isCreateable();
            Access.UnitPriceViewable = Schema.SObjectType.OpportunityLineItem.fields.UnitPrice.isAccessible() && Access.RecordViewable;
            Access.UnitPriceEditable = (Schema.SObjectType.OpportunityLineItem.fields.UnitPrice.isUpdateable()) && (Access.RecordEditable);
            Access.QuantityViewable = Schema.SObjectType.OpportunityLineItem.fields.Quantity.isAccessible() && Access.RecordViewable;
            Access.QuantityEditable = (Schema.SObjectType.OpportunityLineItem.fields.Quantity.isUpdateable()) && (Access.RecordEditable);
            Access.ForecastViewable = Schema.SObjectType.OpportunityLineItem.fields.forecastCategory__c.isAccessible() && Access.RecordViewable;
            Access.ForecastEditable = (Schema.SObjectType.OpportunityLineItem.fields.forecastCategory__c.isUpdateable()) && (Access.RecordEditable);
            Access.ServiceDateViewable = Schema.SObjectType.OpportunityLineItem.fields.serviceDate__c.isAccessible() && Access.RecordViewable;
            Access.ServiceDateEditable = (Schema.SObjectType.OpportunityLineItem.fields.serviceDate__c.isUpdateable()) && (Access.RecordEditable);
            
            Integer perm = [SELECT Count() FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId() AND PermissionSet.Name = :Label.GGPermSetPLMApproval];
            String pricingAssignment = Label.GGSamplePricingAssignment;
            String plmAssessment = Label.GGSamplePLMAssessment;
            //is the sample request in PLM Assessment (for Raw) or Pricing Assignment (for Parts) stage?
            Boolean isInPLMAssignmentStatus = [SELECT Count() FROM Opportunity WHERE Id = :oId AND (StageName= :pricingAssignment OR StageName= :plmAssessment) ] == 1;
            
            Id sysAdmin =[SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
            //only sys admins or users with permission set "PLM Approval" can access PLM approval buttons
            //and when the sample request in PLM Assessment stage
            showPLMButtons = (perm > 0 || UserInfo.getProfileId() == sysAdmin) && isInPLMAssignmentStatus;
        }
    }

    //Not used
    //get the product type strings to search for
    //@AuraEnabled 
    //public static String getBaseUrl(){
    //    return URL.getSalesforceBaseUrl().getPath();
    //}
      
    @AuraEnabled 
    public static OpttyLineItemsWrapper getOptyLineItems(String oId){
        if (oId == null) return null;
        Id optyId = oId;
        
        OpttyLineItemsWrapper wrapper = new OpttyLineItemsWrapper(oId);
        wrapper.isSampleOptty = utils.IsSampleOpportunity2(oId).isSample;
        wrapper.totalNumberOfOLIs = utils.IsSampleOpportunity2(oId).countSampleOptyLineItems;
        wrapper.lineItems = [SELECT Id, Product2.Name, description, OpportunityId, Discount, sampleQuantity__c, ServiceDate, PricebookEntryId, TotalPrice, Specification__c,
                                 Quantity, UnitPrice, forecastCategory__c, Price__c, Price__r.samplePrice__c, Price__r.price1__c, Price__r.Price2__c, Price__r.Price3__c, 
                                 Price__r.Price4__c, Price__r.upperLimit1__c, Price__r.upperLimit2__c, Price__r.upperLimit3__c, Price__r.upperLimit4__c, 
                                 Price__r.priceUnit__c, Price__r.unit__c, Product2.MOQ__c, Product2.moqUnits__c,  Product2.isMTO__c, Product2.Family, Product2.isPrebuild__c 
                            	 ,Opportunity.isPreBuild__c, Opportunity.massProductionOpportunity__c , Specification__r.Name 
                            FROM OpportunityLineItem 
                            WHERE OpportunityId =: optyId 
                            ORDER BY Product2.Name, ServiceDate]; 
        
        //if this is a sample opportunity, copy total price to unitprice
        if (wrapper.isSampleOptty){
            for (OpportunityLineItem li: wrapper.lineItems){
                if (li.totalPrice != null){
                    li.unitPrice = li.totalPrice;
                }
                if (li.sampleQuantity__c != null){
                    li.quantity = li.sampleQuantity__c;//for samples, store quantity in samplequantity field
                }
            }
        }else{
            for (OpportunityLineItem li: wrapper.lineItems){
                if (li.forecastCategory__c == null){
                    li.forecastCategory__c = 'Pipeline';
                }
            }
        }
        return wrapper;
    }
    
    //deletes opportunity line items by ids
    @AuraEnabled
    public static LineItemsSaveResults deleteOptyLineItems(String strOptyLineItems){
        OpportunityLineItem[] lstLineItems = (List<OpportunityLineItem>)System.JSON.deserializeStrict(strOptyLineItems, List<OpportunityLineItem>.Class);
        
        Set<Id> linesToDelete = new Set<Id>();
        OpportunityLineItem newLI;
        
        //can't save total price and unit price together
        for (OpportunityLineItem li: lstLineItems){
            //newLI = new OpportunityLineItem();
            if (li.Id != null){
                linesToDelete.add(li.Id);
                //newLi.Id = li.Id;
            }
            else{
                continue;
            }
            //linesToDelete.add(newLI);
        }
        
        LineItemsSaveResults results = new LineItemsSaveResults();
        LISaveResult liResult;
        try{
            deleteLIs(results, linesToDelete);
            /*integer iSaved = 0, iError = 0, iTotal = 0;
            Database.DeleteResult[] deleteResults = Database.Delete(linesToDelete, true);
            for (Database.DeleteResult dr: deleteResults){
                liResult = new LISaveResult();
                if (dr.isSuccess() == false){
                    iError++;
                    results.success = false;
                    liResult.success = false;
                    for (Database.Error er: dr.getErrors()){
                        liResult.message = er.getMessage();
                        break;
                    }
                }else{
                    iSaved++;
                    liResult.message = 'Deleted!';
                }
                results.liSaveMessages.add(liResult);
                iTotal++;
            }
            results.saveMessage = 'Deleted ' + iSaved + ' of ' + iTotal + ' records';*/
        }
        catch(Exception e){
            results.success = false;
            results.saveMessage = 'Unknown error deleting record: ' + e.getMessage();
            for (OpportunityLineItem li: lstLineItems){
                liResult = new LISaveResult();
                liResult.success = false;
                liResult.message = e.getMessage();
                results.liSaveMessages.add(liResult);
            }
        }
        
        return results;
    }
    
    
    //Approves floor price and extends expiry date on quote's related price records by 30 days
    //This function is called from the Lightning UI by the PLMs
    @AuraEnabled
    public static LineItemsSaveResults processPLMApprovalSample(String opttyId, String strOptyLineItems){
        OpportunityLineItem[] lstLineItems = (List<OpportunityLineItem>)System.JSON.deserializeStrict(strOptyLineItems, List<OpportunityLineItem>.Class);
        LineItemsSaveResults results = new LineItemsSaveResults();
        Opportunity optty = [SELECT Id, StageName, RecordTypeId, pricingAssignmentComplete__c FROM Opportunity WHERE Id = :opttyId LIMIT 1];
                            
        String rt = utils.getRecordTypeName(optty.RecordTypeId);
        
        if (rt.containsIgnoreCase('sample') == false){
            results.success = false;
            results.saveMessage = 'Not a sample request';
            return results;
        }
        
        //List<QuoteLineItem> linesToUpsert = new List<QuoteLineItem>();
        OpportunityLineItem newLI;
        
        List<OpportunityLineItem> updateOLIs = new List<OpportunityLineItem>();

        for (OpportunityLineItem oli: lstLineItems){ 
            newLI = new OpportunityLineItem();
            newLI.Id = oli.Id;
            newLI.sampleQuantity__c = oli.quantity;
            newLI.totalPrice = oli.unitPrice;
            updateOLIs.add(newLI);
        }
        system.debug('optty.StageName='+optty.StageName);
        system.debug('Label.GGSamplePLMAssessment='+Label.GGSamplePricingAssignment);
        //for parts sample, set the pricing assignment complete
        if (optty.StageName == Label.GGSamplePricingAssignment){
            optty.pricingAssignmentComplete__c = true;
        }
        //for raw sample, set the PLM Approved 
        system.debug('optty.StageName='+optty.StageName);
        system.debug('Label.GGSamplePLMAssessment='+Label.GGSamplePLMAssessment);
        if (optty.StageName == Label.GGSamplePLMAssessment){
            optty.PLMApproved__c = 'Yes';
        }
        
        LISaveResult liResult;
        
        try{
            Update(updateOLIs);
            Update(optty); 
            
        }
        catch(Exception e){
            results.success = false;
            results.saveMessage = 'Unknown error approving records: ' + e.getMessage();
            for (OpportunityLineItem li: lstLineItems){
                liResult = new LISaveResult();
                liResult.success = false;
                liResult.message = e.getMessage();
                results.liSaveMessages.add(liResult);
            }
        }
        return results;
        
    }
    
    @AuraEnabled
    public static LineItemsSaveResults saveOptyLineItems(String optyId, Boolean isSampleOptty, String strOptyLineItems){
        OpportunityLineItem[] lstLineItems = (List<OpportunityLineItem>)System.JSON.deserializeStrict(strOptyLineItems, List<OpportunityLineItem>.Class);
        
        List<OpportunityLineItem> linesToUpsert = new List<OpportunityLineItem>();
        OpportunityLineItem newLI;
        
        //can't save total price and unit price together
        for (OpportunityLineItem li: lstLineItems){
            System.debug('Li ===>' + li);
            newLI = new OpportunityLineItem();
            if (li.Id != null){
                newLi.Id = li.Id;
            }
            else{
                newLI.OpportunityId = optyId;
                newLI.PricebookEntryId = li.PriceBookEntryId; 
                newLI.price__c = li.price__c;
            }
            newLi.specification__c = li.specification__c; 
            newLi.description = li.description;
            newLi.forecastCategory__c = li.forecastCategory__c;     
            newLI.ServiceDate = li.ServiceDate;
            //for sample opportunity save price to total price
            if (isSampleOptty){// && li.Product2.Family == Label.GGProductTypeParts){
                newLI.totalPrice = li.unitPrice;
                newLI.sampleQuantity__c = li.quantity;//for samples, store quantity in samplequantity field
            }
            else{
                newLI.unitPrice = li.unitPrice;
                newLI.Quantity = li.quantity;
            }
            //newLi.Discount = li.Discount;
            linesToUpsert.add(newLI);
        }
        
        LineItemsSaveResults results = new LineItemsSaveResults();
        Schema.SObjectField f = OpportunityLineItem.Fields.Id;
        LISaveResult liResult;
        try{
            integer iSaved = 0, iError = 0, iTotal = 0;
            Database.UpsertResult[] upsertResults = Database.Upsert(linesToUpsert, f, false);
            for (Database.UpsertResult ur: upsertResults){
                liResult = new LISaveResult();
                system.debug('ur-' + iTotal);
                if (ur.isSuccess() == false){
                    iError++;
                    results.success = false;
                    liResult.success = false;
                    for (Database.Error er: ur.getErrors()){
                        liResult.message = er.getMessage();
                        break;
                    }
                }
                else{
                    system.debug('setting calc price-' + linesToUpsert[iTotal].TotalPrice);
                    iSaved++;
                    liResult.message = 'Saved!';
                }
                results.liSaveMessages.add(liResult);
                iTotal++;
            }
            results.saveMessage = 'Saved ' + iSaved + ' of ' + iTotal + ' records';
        }
        catch(Exception e){
            results.success = false;
            results.saveMessage = 'Unknown error saving record: ' + e.getMessage();
            for (OpportunityLineItem li: lstLineItems){
                liResult = new LISaveResult();
                liResult.success = false;
                liResult.message = e.getMessage();
                results.liSaveMessages.add(liResult);
            }
        }
        return results;
    }
    
    @AuraEnabled
    public static QuoteLineItemsWrapper getQuoteLineItems(String qId){
        if (qId == null) return null;
        Id quoteId = qId;
        
        QuoteLineItemsWrapper wrapper = new QuoteLineItemsWrapper(qId);        
        wrapper.lineItems = [SELECT Id, Product2.Name, description, QuoteId, sampleQuantity__c, Discount, Freight__c, ServiceDate, PricebookEntryId, TotalPrice, 
                                    Quantity, UnitPrice, Price__c, Price__r.samplePrice__c, Price__r.price1__c, Price__r.Price2__c, Price__r.Price3__c, Price__r.Price4__c, 

                                    Price__r.priceUnit__c, Price__r.unit__c, Product2.MOQ__c, Product2.moqUnits__c, Product2.isMTO__c, Product2.Family, partsTierMap__c, partsPricingTier__c,
                                    plmFloorPrice__c, productFamily__c, isMTO__c,  Product2.isPrebuild__c,
                                    priceBelowFloor__c, priceExpired__c, specification__r.Name/*, quantityLessThanMOQ__c*/ 
                                FROM QuoteLineItem 
                                WHERE QuoteId = :qId 
                                ORDER BY Product2.Name, Quantity]; // AN - 05/01/18 partsTierMap__c to make available to GGQuoteLineItem.cmp via GorillaGlassProducts.cmp
        
        //if this is a sample opportunity, copy total price to unitprice
        if (wrapper.isSampleQuote){
            for (QuoteLineItem li: wrapper.lineItems){
                if (li.description == null){
                    li.description = '';
                }
                
                if (li.Product2.Family == Label.GGProductTypeParts){
                    li.unitPrice = li.totalPrice;
                }
                li.quantity = li.sampleQuantity__c;//for samples, store quantity in samplequantity field
            }
        }
        else{
            
            for (QuoteLineItem li: wrapper.lineItems){
                if (li.description == null){
                    li.description = '';
                }
                //deduct freight for the UI since the Blue unit price is saved with freight but freight and price are displayed separately on the UI
                if (/*li.Freight__C != null*/wrapper.isBlueQuote){
                    li.unitPrice = li.unitPrice - li.Freight__c;
                }
            }
        }

        System.debug('Show PLM Buttons: ' + wrapper.ShowPLMButtons);
        System.debug('Is Sample Queue ' + wrapper.isSampleQuote);
        return wrapper;
    }
    
    private static void createQuoteLineItemsToSave(Boolean approvePrice, Boolean isSampleQuote, List<QuoteLineItem> lstLineItems, List<QuoteLineItem> updateQLIs){
        QuoteLineItem newLI;
        boolean isBlueQuote = false;
        if (lstLineItems.size() > 0){
            isBlueQuote =  utils.isBlueOptyOrQuote(lstLineItems[0].quoteId);
        }
        for (QuoteLineItem qli: lstLineItems){ 
            	System.debug(qli.specification__c);
                newLI = new QuoteLineItem();
                //if (qli.Id != null){
                newLi.Id = qli.Id;
                //}
                    
                newLi.freight__c = qli.freight__c;
                newLi.description = qli.description;
                //for sample quotes, store quantity in sampleQuantity
                if (isSampleQuote){
                    newLI.sampleQuantity__c = qli.quantity; 
                }
                else{
                    newLI.Quantity = qli.quantity;
                    newLI.plmFloorPrice__c = qli.plmFloorPrice__c;
                }
                if (approvePrice){
                    newLI.plmFloorPrice__c = qli.UnitPrice;
                    newLI.priceBelowFloor__c = false;
                }else{
                    newLI.priceBelowFloor__c = qli.priceBelowFloor__c;
                }
                newLI.unitPrice = qli.unitPrice;
                newLI.specification__c = qli.specification__c;
                //for Blue quotes, store unit price inclusive of freight so the quote line item total amount in the system will be inclusive of freight
                if (isBlueQuote){
                  newLI.unitPrice = newLI.unitPrice + newLi.freight__c; 
                }
                
                updateQLIs.add(newLI);
            
            }
        if(updateQLIs.size() > 0){
        	UPDATE updateQLIs;    
        }
        
    }
    
    //Approves floor price and extends expiry date on quote's related price records by 30 days
    //This function is called from the Lightning UI by the PLMs
    @AuraEnabled
    public static LineItemsSaveResults processPLMApprovalQuote(Boolean approvePrice, Boolean extendExpiry, String quoteId, Boolean isSampleQuote, String strQuoteLineItems){
        QuoteLineItem[] lstLineItems = (List<QuoteLineItem>)System.JSON.deserializeStrict(strQuoteLineItems, List<QuoteLineItem>.Class);
        
        Quote q = [SELECT Id, RecordTypeId, Status FROM Quote WHERE Id = :quoteId LIMIT 1];
                            
        String rt = utils.getRecordTypeName(q.RecordTypeId);                
        isSampleQuote = (rt == Label.GGQuoteSample);
        
        //List<QuoteLineItem> linesToUpsert = new List<QuoteLineItem>();
        QuoteLineItem newLI;
        
        map<Id,Price__c> updatePrices = new map<Id,Price__c>();
        list<QuoteLineItem> updateQLIs = new List<QuoteLineItem>();
        Set<Id> priceIds = new Set<Id>();
      
        if (approvePrice){
            createQuoteLineItemsToSave(true, isSampleQuote, lstLineItems, updateQLIs);
        }

        for (QuoteLineItem qli: lstLineItems){ 
            
            if (extendExpiry){ // this fires from extend or approve
                Price__c p = new Price__c();
                p.Id = qli.price__c;
                p.priceApprovalDate__c = System.Date.today();
                // AN 6/11/18 move extend expiry from worflow into code
                system.debug('$$$$$ Product Family ' + qli.productFamily__c + ': ' + qli.isMTO__c); // AN 5/1/18
                if (qli.productFamily__c == 'Parts') {
                    p.priceExpirationDate__c = System.Date.today().addDays(730);
                } else if (qli.productFamily__c == 'Raw Glass' && qli.isMTO__c == TRUE) {
                    p.priceExpirationDate__c = System.Date.today().addDays(365);
                }
                               
                if (approvePrice) { // AN 4/30/18
                    // update different price record fields based om parts, raw, mto
                    // partsTierMap__c is null for Raw and MTO
                    If (qli.partsTierMap__c == Null) { // Raw and MTO
                        if (qli.productFamily__c == 'Raw Glass' && qli.isMTO__c == TRUE) {
                            p.priceExpirationDate__c = System.Date.today().addDays(365);
                        }                         
                    } else { // Parts
                        p.priceExpirationDate__c = System.Date.today().addDays(730);
                        system.debug('$$$$$ Parts Tier ' + qli.partsTierMap__c); // AN 4/30/18
                        system.debug('$$$$$ Unit Price ' + qli.UnitPrice); // AN 5/1/18
                        
                        // loop through QLI to update all tiers on same prce record
                        for (QuoteLineItem qli2: lstLineItems) {         
                            If (qli2.partsTierMap__c == '0') p.samplePrice__c = qli2.UnitPrice;
                            If (qli2.partsTierMap__c == '1') p.price1__c = qli2.UnitPrice;
                            If (qli2.partsTierMap__c == '2') p.price2__c = qli2.UnitPrice;
                            If (qli2.partsTierMap__c == '3') p.price3__c = qli2.UnitPrice;
                            If (qli2.partsTierMap__c == '4') p.price4__c = qli2.UnitPrice;
                        }
                       
                    }                                        
                }                
                
                system.debug('$$$$$ Final Price 0 ' + p.samplePrice__c); // AN 5/1/18
                system.debug('$$$$$ Final Price 1 ' + p.price1__c); // AN 5/1/18  
                system.debug('$$$$$ Final Price 2 ' + p.price2__c); // AN 5/1/18
                system.debug('$$$$$ Final Price 3 ' + p.price3__c); // AN 5/1/18
                system.debug('$$$$$ Final Price 4 ' + p.price4__c); // AN 5/1/18
                updatePrices.put(p.Id,p); // RAW Price__c is getting updated
            }
        }
        LineItemsSaveResults results = new LineItemsSaveResults();

        LISaveResult liResult;
        try{
            integer iSaved = 0, iError = 0, iTotal = 0;
            Update(updatePrices.values());
            Update(updateQLIs);

            /*Database.SaveResult[] uResults = Database.Update(updatePrices, true);
            for (Database.SaveResult ur: uResults){
                liResult = new LISaveResult();
                if (ur.isSuccess() == false){
                    iError++;
                    results.success = false;
                    liResult.success = false;
                    for (Database.Error er: ur.getErrors()){
                        liResult.message = er.getMessage();
                        break;
                    }
                }
                else{
                    iSaved++;
                    liResult.message = 'Saved!';
                }
                results.liSaveMessages.add(liResult);
                iTotal++;
            }
            results.saveMessage = 'Saved ' + iSaved + ' of ' + iTotal + ' records';*/
        }
        catch(Exception e){
            results.success = false;
            results.saveMessage = 'Unknown error approving records: ' + e.getMessage();
            for (QuoteLineItem li: lstLineItems){
                liResult = new LISaveResult();
                liResult.success = false;
                liResult.message = e.getMessage();
                results.liSaveMessages.add(liResult);
            }
        }
        return results;
        
    }
    
    @AuraEnabled
    public static LineItemsSaveResults saveQuoteLineItems(String quoteId, Boolean isSampleQuote, String strQuoteLineItems){
        QuoteLineItem[] lstLineItems = (List<QuoteLineItem>)System.JSON.deserializeStrict(strQuoteLineItems, List<QuoteLineItem>.Class);
        System.debug(lstLineItems);
        Quote q = [SELECT Id, RecordTypeId, Status FROM Quote WHERE Id = :quoteId LIMIT 1];
                    
        String rt = utils.getRecordTypeName(q.RecordTypeId);
        isSampleQuote = (rt == Label.GGQuoteSample);
        
        List<QuoteLineItem> linesToUpsert = new List<QuoteLineItem>();
        QuoteLineItem newLI;
        
        //can't save total price and unit price together
        /*for (QuoteLineItem li: lstLineItems){
            newLI = new QuoteLineItem();
            if (li.Id != null){
                newLi.Id = li.Id;
            }
            else{
                newLI.QuoteId = quoteId;
                newLI.PricebookEntryId = li.PriceBookEntryId; 
                newLI.price__c = li.price__c;
            }
            newLi.freight__c = li.freight__c;
            newLi.description = li.description;
            //for sample quotes, store quantity in sampleQuantity
            if (isSampleQuote){
                newLI.sampleQuantity__c = li.quantity; 
                
            }
            else{
                newLI.Quantity = li.quantity;
                newLI.plmFloorPrice__c = li.plmFloorPrice__c;
            }
            
            //newLI.quantityLessThanMOQ__c = li.quantityLessThanMOQ__c;
            newLI.priceBelowFloor__c = li.priceBelowFloor__c;
            newLI.unitPrice = li.unitPrice;
            //store unit price inclusive of freight so the quote line item total amount in the system will be inclusive of freight
            if (newLI.freight__c != null){
              newLI.unitPrice = newLI.unitPrice + newLi.freight__c; 
            }
            
            linesToUpsert.add(newLI);
        }*/
        if(lstLineItems.size() > 0){
            System.debug('spec===> ' + lstLineItems.get(0).specification__c);
        }
        createQuoteLineItemsToSave(false, isSampleQuote, lstLineItems, linesToUpsert);
        if(lstLineItems.size() > 0){
            System.debug('spec===> ' + lstLineItems.get(0).specification__c);
        }        
        LineItemsSaveResults results = new LineItemsSaveResults();
        Schema.SObjectField f = QuoteLineItem.Fields.Id;
        LISaveResult liResult;
        try{
            integer iSaved = 0, iError = 0, iTotal = 0;
            Database.UpsertResult[] upsertResults = Database.Upsert(linesToUpsert, f, false);
            for (Database.UpsertResult ur: upsertResults){
                liResult = new LISaveResult();
                if (ur.isSuccess() == false){
                    iError++;
                    results.success = false;
                    liResult.success = false;
                    for (Database.Error er: ur.getErrors()){
                        liResult.message = er.getMessage();
                        break;
                    }
                }
                else{
                    iSaved++;
                    liResult.message = 'Saved!';
                }
                results.liSaveMessages.add(liResult);
                iTotal++;
            }
            results.saveMessage = 'Saved ' + iSaved + ' of ' + iTotal + ' records';
        }
        catch(Exception e){
            results.success = false;
            results.saveMessage = 'Unknown error saving record: ' + e.getMessage();
            for (QuoteLineItem li: lstLineItems){
                liResult = new LISaveResult();
                liResult.success = false;
                liResult.message = e.getMessage();
                results.liSaveMessages.add(liResult);
            }
        }
        return results;
    }
    
    //deletes quote line items by ids
    @AuraEnabled
    public static LineItemsSaveResults deleteQuoteLineItems(String strQuoteLineItems){
        QuoteLineItem[] lstLineItems = (List<QuoteLineItem>)System.JSON.deserializeStrict(strQuoteLineItems, List<QuoteLineItem>.Class);
        
        Set<Id> linesToDelete = new Set<Id>();
        QuoteLineItem newLI;
        
        Set<Id> priceIds = new Set<Id>();
        Id QuoteId = null;
        
        for (QuoteLineItem li: lstLineItems){
            if (li.Id != null){
                quoteId = li.quoteId;
                linesToDelete.add(li.Id);
                priceIds.add(li.price__c);
            }
            else{
                continue;
            }
        }
        
        //for program quotes, if a parts quote line item is deleted make sure all tier line items are deleted
        if (quoteId != null && utils.isProgramPartsQuote(quoteId)){
            for (QuoteLineItem qli: [SELECT Id FROM QuoteLineItem WHERE Price__c in :priceIds AND QuoteId = :quoteId]){
                if (!linesToDelete.contains(qli.Id)){
                    linesToDelete.add(qli.Id);
                }
            }
        }
        
        LineItemsSaveResults results = new LineItemsSaveResults();
        
        try{
            deleteLIs(results, linesToDelete);
        }
        catch(Exception e){
            results.success = false;
            results.saveMessage = 'Unknown error deleting record: ' + e.getMessage();
            LISaveResult liResult;
            for (QuoteLineItem li: lstLineItems){
                liResult = new LISaveResult();
                liResult.success = false;
                liResult.message = e.getMessage();
                results.liSaveMessages.add(liResult);
            }
        }
        return results;
    }
    
    private static void deleteLIs(LineItemsSaveResults results, Set<Id> liToDelete){
        
        LISaveResult liResult;
        
        List<Id> linesToDelete = new List<Id>(liToDelete);
        
        if (linesToDelete == null || linesToDelete.size() == 0){
            results.success = false;
            results.savemessage = 'Nothing to delete!';
            return;
        }
        
        integer iSaved = 0, iError = 0, iTotal = 0;
        Database.DeleteResult[] deleteResults = Database.Delete(linesToDelete, true);
        for (Database.DeleteResult dr: deleteResults){
           liResult = new LISaveResult();
           if (dr.isSuccess() == false){
              iError++;
              results.success = false;
              liResult.success = false;
              for (Database.Error er: dr.getErrors()){
                 liResult.message = er.getMessage();
                 break;
              }
           }
           else{
              iSaved++;
              liResult.message = 'Deleted!';
           }
           results.liSaveMessages.add(liResult);
           iTotal++;
        }
        results.saveMessage = 'Deleted ' + iSaved + ' of ' + iTotal + ' records';
    }
   
    
   
    @AuraEnabled
    public static Boolean runningInSF1(){
        return (UserInfo.getUiThemeDisplayed() == Label.Salesforce1Theme);
    }
    
    @AuraEnabled
    public static LineItemsSaveResults scheduleOptyLineItems(string quantities, string strOptyLineItems){
        string [] strQuantity = quantities.split(',');
        OpportunityLineItem[] lstLineItems = (List<OpportunityLineItem>)System.JSON.deserializeStrict(strOptyLineItems, List<OpportunityLineItem>.Class);
        
        List<OpportunityLineItem> linesToUpsert = new List<OpportunityLineItem>();
        OpportunityLineItem newLI;
        integer i = 0;
        
        for (OpportunityLineItem li: lstLineItems){
            integer numberOfMonths = integer.valueOf(strQuantity[i]);
            decimal originalQuantity = li.Quantity;
            decimal quantity = originalQuantity/numberOfMonths; 
            
            for (integer j=0; j < numberOfMonths ; j++) { 
                newLI = new OpportunityLineItem();
                newLI.OpportunityId = li.OpportunityId;
                newLI.PricebookEntryId = li.PriceBookEntryId; 
                newLI.price__c = li.price__c;
                newLi.forecastCategory__c = li.forecastCategory__c;
                newLI.Quantity = quantity;
                newLI.ServiceDate = li.ServiceDate.addMonths(i);
                newLI.unitPrice = li.unitPrice;
                linesToUpsert.add(newLI);
            }
            i++;
        }
        
        LineItemsSaveResults results = new LineItemsSaveResults();
        Schema.SObjectField f = OpportunityLineItem.Fields.Id;
        LISaveResult liResult;
        try{
            integer iSaved = 0, iError = 0, iTotal = 0;
            Database.UpsertResult[] upsertResults = Database.Upsert(linesToUpsert, f, false);
            for (Database.UpsertResult ur: upsertResults){
                liResult = new LISaveResult();
                
                if (ur.isSuccess() == false){
                    iError++;
                    results.success = false;
                    liResult.success = false;
                    for (Database.Error er: ur.getErrors()){
                        liResult.message = er.getMessage();
                        break;
                    }
                }
                else{
                    iSaved++;
                    liResult.message = 'Saved!';
                }
                results.liSaveMessages.add(liResult);
                iTotal++;
            }
            results.saveMessage = 'Saved ' + iSaved + ' of ' + iTotal + ' records';
        }
        catch(Exception e){
            results.success = false;
            results.saveMessage = 'Unknown error scheduling record: ' + e.getMessage();
            
            for (OpportunityLineItem li: lstLineItems){
                liResult = new LISaveResult();
                liResult.success = false;
                liResult.message = e.getMessage();
                results.liSaveMessages.add(liResult);
            }
        }
        return results;
    }
}