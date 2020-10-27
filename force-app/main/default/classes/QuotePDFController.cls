/**
 * @description       : 
 * @author            : Adam Nicholson?
 * @group             : 
 * @last modified on  : 09-04-2020
 * @last modified by  : Edgar Santillana
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.1   07-07-2020   Arquimidez Mora   Adding Vietnamese Dong 
 * 1.2   07-13-2020	  Edgar Santillana  Adding rawGlassMass
**/
///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 3/2/2017 ***///
///*** Controller class used in the Quote PDF Generation Component. ***///
public with sharing class QuotePDFController {
    public string language {get;set;}
    public string recordId {get;set;}
    public Quote theQuote {get;set;}
    public list<QuoteLineItem> itemList {get;set;}
    public list<qliWrapper> qliList {get;set;}
    public list<qliMassPartsWrapper> qliMassPartsList {get;set;}
    public QuoteBoilerplate__c theText {get;set;}
    public string lineItemType {get;set;}
    public string ccAddressString {get;set;}
    public string addressString {get;set;}
    public string currencyString {get;set;}
    public string securityString {get;set;}
    public string shippingString {get;set;}
    public string qliDescriptionString  {get;set;}
    public decimal totalPrice {get;set;}
    public decimal unitPrice {get;set;}
    public decimal importPrice {get;set;}
    public decimal incoPrice {get;set;}
    public decimal freight {get;set;}
    public decimal vatUnitPrice {get;set;}
    public decimal vatTotalPrice {get;set;}
    public boolean vatFlag {get;set;}
    public boolean phylloFlag {get;set;}
    public boolean sampleFlag {get;set;} // true if set on quote
    public boolean sampleOnlyFlag {get;set;} // true if set on quote
    public boolean containsSampleRow {get;set;} // true if coniains tier 0
    public boolean rawGlassMass {get;set;} //  if Quote Type is Raw Glass – Mass Production Quote
    
    private final Quote parent;
    static Utilities utils = new Utilities();
    
    public class pdfWrapper{
        @AuraEnabled public String language{ get; set;}
        @AuraEnabled public Boolean isPricingExpired{ get; set;}
        @AuraEnabled public List<Price__c> expiredPrices{ get; set;}
        @AuraEnabled public boolean canCreatePDF { get; set;}
        @AuraEnabled public String pdfCreationError { get; set ;}
        @AuraEnabled public List<QuoteLineItem> errorLineItems { get; set;}
        
        public pdfWrapper(){
            canCreatePDF = true;
            isPricingExpired = false;
            errorLineItems = new List<QuoteLineItem>();
        }
        
        public pdfWrapper(Boolean isPricingExpired, List<Price__c> expiredPrices){
            this.isPricingExpired = isPricingExpired;
            this.expiredPrices = expiredPrices;
        }
    }
    
    public class qliWrapper{ //each qliWrapper contains one line item record
        @AuraEnabled public QuoteLineItem lineItem { get; set;}
        @AuraEnabled public list<String> descriptions { get; set;}
        @AuraEnabled public string qliDescriptionString { get; set;}
        @AuraEnabled public decimal unitPrice { get; set;}
        @AuraEnabled public decimal totalPrice { get; set;}
        @AuraEnabled public decimal freight { get; set;}
        @AuraEnabled public decimal vatUnitPrice { get; set;}
        @AuraEnabled public decimal vatTotalPrice { get; set;}
        
        public qliWrapper(){
            lineItem = new QuoteLineItem();
            descriptions = new list<string>();
            qliDescriptionString = '';
            unitPrice = 0.0;
            totalPrice = 0.0;
            freight = 0.0;
            vatUnitPrice = 0.0;
            vatTotalPrice = 0.0;
        }
    }
    //Each qliMassPartsWrapper contains one to many qliWrapper records (each of which contains one line item)
    public class qliMassPartsWrapper{
        @AuraEnabled public list<qliWrapper> lineItems { get; set;}
        @AuraEnabled public Id productId { get; set;}
        
        public qliMassPartsWrapper(){
            lineItems = new list<qliWrapper>();
            productId = null;
        }
    }
    
    //Lightning Constructor 
    public QuotePDFController(ApexPages.StandardController controller) {
        map<String, String> URLParameters = ApexPages.currentPage().getParameters();
        language = URLParameters.get('lang');
        recordId = URLParameters.get('id');
    }

    private static list<QuoteLineItem> getQuoteLineItems(Id quoteId){
         List<QuoteLineItem> rList = [SELECT Id
                        ,Description
                        ,Discount
                        ,Quantity
                        ,sampleQuantity__c
                        ,partsPricingTier__c
                        ,partsTierMap__c
                        ,TotalPrice
                        ,UnitPrice
                        ,SortOrder
                        ,ListPrice
                        ,moq__c
                        ,freight__c
                        ,quoteSheetsSqFtPerCrate__c 
                        ,customerDrawingNumber__c
                        ,corningSpecificationNumber__c
                        ,LineNumber
                        ,Product2Id   
                        ,Product2.Name
                        ,Product2.IsPhyllo__c
                        ,Product2.isActive
                        ,Product2.Family
                        ,Product2.Width__c
                        ,Product2.Thickness__c
                        ,Product2.Length__c
                        ,Product2.glassComposition__c
                        ,Product2.ProductType__c
                        ,Product2.quoteSheetDimensionMm__c
                        ,Product2.quoteDimensionsMm__c
                        ,Product2.packingOption__c
                        ,Product2.includeCorningPackaging__c
                        ,Product2.ctLevel__c
                        //Added special requirements - Ajay 4/25/2017
                        ,Product2.specialRequirements__c
                        //Added special shapes from product2 - Adam 7/10/2017
                        ,Product2.specialShapes__c
                        // an - 2/19/18 - added spec id, moq and moq uom
                        ,Product2.specification__r.Name
                        ,Product2.specification__r.moq__c
                        ,Product2.specification__r.moquom__c
                        ,Product2.specification__r.specialShapes__c
                        ,Product2.specification__r.innovation_type__c
                        ,Product2.specification__r.glassComposition__c
                        ,Product2.specification__r.productionVolume__c
                        ,Product2.specification__r.productionVolumeType__c
                        // an - 4/18/19 - add new RMB rate lock field from spec
                        ,Product2.specification__r.mpRmbExchangeRate__c
                        ,Product2.specification__r.GG_VNDExchangeRate__c
                        ,PriceBookEntry.Product2.Description
                        ,PriceBookEntry.Product2.Name
                        ,PriceBookEntry.Product2.Family
                        ,specification__r.Name
                        ,specification__r.thickness__c
                        ,specification__r.width__c
                        ,specification__r.length__c
                        ,specification__r.glassComposition__c
                        ,specification__r.specialShapes__c
                        ,specification__r.specialRequirements__c
                    FROM QuoteLineItem
                    WHERE QuoteId = :quoteId
                    ORDER BY Product2Id ASC, Quantity ASC]; 
        System.debug('rlist$$$$>>>' + rList);
        return rList;
        
    }

    //Called by action attribute of the VF page
    //retrieves data needed by page
    public void GenerateQuotePDF () {       
        decimal currencyVal = 0.0; 
        decimal vat = 0.0;
        
        //Quote and related Contacts
        theQuote = [SELECT Id
                    ,Description
                    ,GrandTotal
                    ,Name
                    ,QuoteNumber
                    ,OpportunityId
                    ,Opportunity.Name
                    ,ShippingHandling
                    ,TotalPrice
                    ,EffectiveDate__c
                    ,ExpirationDate
                    ,Status
                    ,includeSamplePrice__c
                    ,oppRecType__c
                    ,corningSellingEntity__c 
                    ,dateOfQuote__c        
                    ,customerInquiryDate__c
                    ,additionalComments__c
                    ,shippingTerm__c
                    ,shippingTermsComment__c
                    ,paymentTerm__c
                    ,language__c
                    ,currency__c
                    ,Version__c
                    ,currencyConversionFactor__c
                    ,finalJpyExchangeValue__c 
                    ,finalRmbExchangeValue__c
                    ,GG_VNDExchangeRate__c
                    ,finalExchangeCurrency__c
                    ,importDutyLogistic__c
                    ,incotermAdder__c
                    ,quoteTypeCode__c
                    ,RecordType.Name
                    ,corningContact__c
                    ,corningContact__r.Name
                    ,corningContact__r.Title
                    ,corningContact__r.Email
                    ,corningContact__r.Phone
                    ,corningContact__r.Fax
                    ,corningContact__r.Street
                    ,corningContact__r.City
                    ,corningContact__r.State
                    ,corningContact__r.Country
                    ,corningContact__r.PostalCode
                    ,contactId
                    ,contact.Name
                    ,contact.Account.Name
                    ,contact.Account.BillingStreet
                    ,contact.Account.BillingCity
                    ,contact.Account.BillingCountry
                    ,contact.Email
                    ,contact.Phone
                    ,contact.MailingStreet
                    ,contact.MailingCity
                    ,contact.MailingState
                    ,contact.MailingPostalCode
                    ,contact.MailingCountry
                FROM Quote 
                WHERE Id = :recordId LIMIT 1];
        
        //Build Corning Contact Address string for display
        ccAddressString = '';
        if (theQuote.corningContact__c <> null) {
            if (string.isNotBlank(theQuote.corningContact__r.Street)) {
                ccAddressString += theQuote.corningContact__r.Street + ', ';
            }
            if (string.isNotBlank(theQuote.corningContact__r.City)) {
                ccAddressString += theQuote.corningContact__r.City + ', ';
            }
            if (string.isNotBlank(theQuote.corningContact__r.State)) {
                ccAddressString += theQuote.corningContact__r.State + ', ';
            }
            if (string.isNotBlank(theQuote.corningContact__r.Country)) {
                ccAddressString += theQuote.corningContact__r.Country + ', ';
            }
            if (string.isNotBlank(theQuote.corningContact__r.PostalCode)) {
                ccAddressString += theQuote.corningContact__r.PostalCode;
            }
            if (ccAddressString.endsWith(', ')) {
                ccAddressString = ccAddressString.left(ccAddressString.length()-2);
            }
        }
        else ccAddressString = '';
        
        //Build Contact Address string for display
        addressString = '';
        if (theQuote.contactId <> null) {
            if (string.isNotBlank(theQuote.contact.MailingCity)) {
                addressString += theQuote.contact.MailingCity + ', ';
            }
            if (string.isNotBlank(theQuote.contact.MailingState)) {
                addressString += theQuote.contact.MailingState + ' ';
            }
            if (string.isNotBlank(theQuote.contact.MailingPostalCode)) {
                addressString += theQuote.contact.MailingPostalCode;
            }
            if (addressString.endsWith(', ')) {
                addressString = addressString.left(addressString.length()-2);
            }
        }
        else addressString = '';
        
        //Get display version of Currency
        map<string,GG_Currency_Display_Settings__c> currencyMap = new map<string,GG_Currency_Display_Settings__c>();
        for (GG_Currency_Display_Settings__c setting : [SELECT currency__c, currencyDisplay__c, exchangeValue__c, vat__c 
                                                        FROM GG_Currency_Display_Settings__c]){ 
            currencyMap.put(setting.currency__c, setting); 
        }
        
        // AN 7/31/19 - may need to update fields on opportunity       
        List<Opportunity> oppList = new List<Opportunity>();
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        List<Opportunity> oppUpdateList = new List<Opportunity>(); 
        
        system.debug('$$$ ' + theQuote.opportunityid);
        oppList = [SELECT Id, mpExchangeRateLockDate__c, mPExchangeLockReason__c, mpQuoteCurrency__c, 
                    mpJpyExchangeRate__c, mpRmbExchangeRate__c, GG_VNDExchangeRate__c
                    FROM Opportunity 
                    WHERE Id = :theQuote.opportunityId];
        for (Opportunity o : oppList) {
            system.debug('$$$ ' + o.id);
            oppMap.put(o.id,o);        
        }
        // AN 7/31/19 END
        
        if (currencyMap.keyset().contains(theQuote.currency__c)){
            currencyString = currencyMap.get(theQuote.currency__c).currencyDisplay__c;
            // currencyVal = currencyMap.get(theQuote.currency__c).exchangeValue__c; // AN 1/3/18 removed line
            vat = currencyMap.get(theQuote.currency__c).vat__c;
            
            // AN 1/3/18 fix the exchange rate in MP Quotes where opportunity contains an exchange rate BEGIN
            if (theQuote.RecordType.Name != 'GG Parts') { // samples, raw, concore always get the current exchange rate
                currencyVal = currencyMap.get(theQuote.currency__c).exchangeValue__c;
            } else { // MP Quote
                if (theQuote.finalExchangeCurrency__c == Null) {
                    // AN 7/31/19 - if this an RMB quote and currency is null, lock in the exchange rates
                    // previously this was done when the quote was accepted
                    // specs can also lock in the exchange rate if RMB
                    currencyVal = currencyMap.get(theQuote.currency__c).exchangeValue__c;
                    
                    if (theQuote.currency__c == 'Yuan') {
                        system.debug('$$$ ' + 'here');
                        oppMap.get(theQuote.opportunityId).mpExchangeRateLockDate__c = Date.Today();
                        oppMap.get(theQuote.opportunityId).mPExchangeLockReason__c = 'First Generated RMB MP Quote';
                        oppMap.get(theQuote.opportunityId).mpQuoteCurrency__c = 'Yuan'; 
                        oppMap.get(theQuote.opportunityId).mpJpyExchangeRate__c = GG_Currency_Display_Settings__c.getValues('Japanese Yen').exchangeValue__c;
                        oppMap.get(theQuote.opportunityId).mpRmbExchangeRate__c = GG_Currency_Display_Settings__c.getValues('Chinese Yuan').exchangeValue__c;
                        oppMap.get(theQuote.opportunityId).GG_VNDExchangeRate__c = GG_Currency_Display_Settings__c.getValues('Vietnamese Dong').exchangeValue__c;
                        oppUpdateList.add(oppMap.get(theQuote.opportunityId));
                    }                    
                    
                } else {
                    if (theQuote.currency__c == 'Yen') {
                        currencyVal = theQuote.finalJpyExchangeValue__c;
                    } else if (theQuote.currency__c == 'Yuan') {
                        currencyVal = theQuote.finalRmbExchangeValue__c;
                    } else if (theQuote.currency__c == 'Dong') {
                        currencyVal = theQuote.GG_VNDExchangeRate__c;
                    } else {
                        currencyVal = 1;
                    }
                    
                }
            } // AN 1/3/18 END
            
        }         
        
        //Do we show VAT?
        if (theQuote.corningSellingEntity__c == 'CCMS' || theQuote.corningSellingEntity__c == 'CVCL'){
            if (theQuote.currency__c <> 'Dollar') {
                vatFlag = true;
            }
            else vatFlag = false;
        }
        else vatFlag = false;

        //Do we show Sample on Quote? // an - 6/22
        //Do we show only Sample on Quote // an - 9/24/19
        sampleFlag = theQuote.includeSamplePrice__c;
        sampleOnlyFlag = theQuote.oppRecType__c == 'GG Inquiry' ? TRUE : FALSE; 

        //Quote Expiration Date
        theQuote.dateOfQuote__c = system.today();
        
        //Get Display Version of Shipping Term
        shippingString = GG_Shipping_Term__c.getValues(theQuote.shippingTerm__c).shippingTerm__c;
        
        string queryLanguage = GG_Quote_Language__c.getValues(theQuote.language__c).Output_Language_Code__c;
        
        //Quote Boilerplate information
        theText = [SELECT Id 
                    ,termsAndConditions__c
                    ,thankYou__c
                    ,rawRemarks__c
                    ,concoreRemarks__c
                    ,partsRemarks__c
                    ,returnAddress__c
                    ,preparedFor__c
                    ,preparedBy__c
                    ,isActive__c
                    ,corningSellingEntityLabel__c
                FROM QuoteBoilerplate__c 
                WHERE quoteLanguage__c = :queryLanguage
                 AND corningSellingEntity__c = :theQuote.corningSellingEntity__c
                 AND isActive__c = true 
                LIMIT 1];
    	System.Debug('recordId======>' + recordId);
        //Quote Line Items and related products, pricebookeentry and specification records
        itemList = getQuoteLineItems(recordId);
        /*itemList = [SELECT Id
                        ,Description
                        ,Discount
                        ,Quantity
                        ,sampleQuantity__c
                        ,partsPricingTier__c
                        ,partsTierMap__c
                        ,TotalPrice
                        ,UnitPrice
                        ,SortOrder
                        ,ListPrice
                        ,moq__c
                        ,freight__c
                        ,quoteSheetsSqFtPerCrate__c 
                        ,customerDrawingNumber__c
                        ,corningSpecificationNumber__c
                        ,LineNumber
                        ,Product2Id   
                        ,Product2.isActive
                        ,Product2.Family
                        ,Product2.Width__c
                        ,Product2.Thickness__c
                        ,Product2.Length__c
                        ,Product2.glassComposition__c
                        ,Product2.ProductType__c
                        ,Product2.quoteSheetDimensionMm__c
                        ,Product2.quoteDimensionsMm__c
                        ,Product2.packingOption__c
                        ,Product2.includeCorningPackaging__c
                        ,Product2.ctLevel__c
                        //Added special requirements - Ajay 4/25/2017
                        ,Product2.specialRequirements__c
                        ,Product2.specification__r.specialShapes__c
                        ,Product2.specification__r.innovation_type__c
                        ,Product2.specification__r.glassComposition__c
                        ,Product2.specification__r.productionVolume__c
                        ,Product2.specification__r.productionVolumeType__c
                        ,PriceBookEntry.Product2.Description
                        ,PriceBookEntry.Product2.Name
                        ,PriceBookEntry.Product2.Family
                    FROM QuoteLineItem
                    WHERE QuoteId = :recordId
                    ORDER BY Product2Id ASC, Quantity ASC];   */        
        
        securityString = 'Corning Restricted - ';
        
        //Set lineItemType based on Quote RecordType and Product Family
        string expItemType;
        rawGlassMass = true;
        if  (utils.isBlueOptyOrQuote(recordId) == true){
            lineItemType = 'Blue';
            expItemType = 'Blue';
            securityString += 'Special Control - ';
        }
        else {  
            if (theQuote.RecordType.Name == 'GG Raw Glass') {
                lineItemType = 'Raw';
                expItemType = 'Raw';
                rawGlassMass = false;
            }
            else if (theQuote.RecordType.Name == 'GG Concore') {
                lineItemType = 'Concore';
                expItemType = 'Concore';
            }
            else if (theQuote.RecordType.Name == 'GG Parts' && theQuote.finalExchangeCurrency__c == Null) {
                lineItemType = 'MassParts';
                expItemType = 'MassParts';
            }
            else if (theQuote.RecordType.Name == 'GG Parts' && theQuote.finalExchangeCurrency__c != Null) { 
                lineItemType = 'MassParts';
                // an - 2/14 - add new expItemType for 2 year parts quote epiration
                expItemType = 'MassPartsAccepted';
            }
            else if (theQuote.RecordType.Name == 'GG Sample') {
                string  fam = itemList[0].Product2.Family;
                boolean  isphyllo = itemList[0].Product2.isPhyllo__c;
                if (fam == Label.GGProductTypeRaw) {
                    lineItemType = 'Raw';
                    expItemType = 'SampleRaw';
                }
                else if (fam == Label.GGProductTypeConcore) {
                    lineItemType = 'Concore';
                    expItemType = 'SampleConcore';
                }
                else if (fam == Label.GGProductTypeParts) {
                    lineItemType = 'SampleParts';
                    expItemType = 'SampleParts';
                }
                if(isphyllo){
                    phylloFlag = true;
                }
            }
        }
        
        system.debug('$$$: ' + theQuote.RecordType.Name);
        system.debug('$$$: ' + theQuote.finalExchangeCurrency__c);
        system.debug('$$$: ' + expItemType);         
        
        Quote updateQ = new Quote(Id=recordId, effectiveDate__c = theQuote.effectiveDate__c, dateOfQuote__c =  theQuote.dateOfQuote__c);
        updateQ.currencyConversionFactor__c = currencyVal;
                
        //Quote Expiration
        decimal dExpiration = 730;
        if (
            GG_Quote_Expiration_Settings__c.getValues(expItemType) != null && GG_Quote_Expiration_Settings__c.getValues(expItemType).setEffectiveDateToToday__c
        ){
                updateQ.effectiveDate__c = system.today();
                theQuote.effectiveDate__c = updateQ.effectiveDate__c;
        }
        
        //update expiration date only if the quote type has an active custom setting
        if (GG_Quote_Expiration_Settings__c.getValues(expItemType) != null &&
            GG_Quote_Expiration_Settings__c.getValues(expItemType).daysToExpiration__c != NULL
        ) {
            dExpiration = GG_Quote_Expiration_Settings__c.getValues(expItemType).daysToExpiration__c;
            Long expiration = Math.roundToLong(dExpiration);
            
            //theQuote.ExpirationDate = system.today().addDays(Integer.valueOf(expiration)); 
            if (updateQ.effectiveDate__c != null){
                updateQ.ExpirationDate = /*system.today()*/updateQ.effectiveDate__c.addDays(Integer.valueOf(expiration));
                theQuote.ExpirationDate = updateQ.ExpirationDate;
            }
        }   
        
        System.debug('Expiration Date: ' + theQuote.ExpirationDate);

        // an - 2/19/18 - add the spec IDs and MOQs to the quote so it can be emailed out once custoemr accepted
        String specDetails = '';
        String specId = '';
        containsSampleRow = False; // default
        
        for(QuoteLineItem items : itemList) {
            System.debug('$$$ ' + theQuote.RecordType.Name);
            System.debug('$$$ ' + specId);
            System.debug('$$$ ' + items.Product2.specification__r.Name);                        
            if (theQuote.RecordType.Name == 'GG Parts' && (specId == Null || items.Product2.specification__r.Name <> specId)) {
                specDetails = specDetails + '\n' + items.Product2.specification__r.Name + ' (' + items.Product2.specification__r.moq__c + ' ' + items.Product2.specification__r.moquom__c + ')';
                specId = items.Product2.specification__r.Name;
            }     
            // an 6/27 - determine if lines incle sample line; partsTierMap__c = tier 0 
            if (items.partsTierMap__c == '0') {
                containsSampleRow = True;
            }
                   
        }
        updateQ.specDetails__c = specDetails;      
        // an - 2/19/18 - END 
        
        // update updateQ; AN 4/18/19 move closer to end of code
        
        //Create Strings for Display and Wrap itemList
        qliList = new list<qliWrapper>();
        for(QuoteLineItem item : itemList) {
            //Description String
            qliDescriptionString = item.Product2.glassComposition__c + '; ';
            qliDescriptionString += item.Product2.specialShapes__c;
            // AN - referencing special shapes from Product2 now vs Specification for ST1/2, Inv
            /*Special requirments added as a separate row in the page - Ajay 4/25/17
            if (item.Product2.specification__r.innovation_type__c <> null) {
                qliDescriptionString +=  '; ' + item.Product2.specification__r.innovation_type__c;
            }*/
                        
            //Foreign Exchange
            unitPrice = 0.0;
            totalPrice = 0.0;
            importPrice = 0.0;
            incoPrice = 0.0;
            freight = 0.0;
            vatUnitPrice = 0.0;
            vatTotalPrice = 0.0;
            
            system.debug('%%% ' + currencyVal);
            system.debug('%%% ' + theQuote.corningSellingEntity__c);
            system.debug('%%% ' + theQuote.currency__c);

            // AN 7/31/19 - Revert back to pulling from opportunity
            // AN 4/18/19 - Try and pull RMB conversion rate from spec if available            
            /*
            if (theQuote.corningSellingEntity__c == 'CCMS') {
                if (theQuote.currency__c == 'Yuan') {
                    if (item.Product2.specification__r.mpRmbExchangeRate__c != Null) {
                        system.debug('%%% Set Currency Val');
                        currencyVal = item.Product2.specification__r.mpRmbExchangeRate__c; 
                        system.debug('%%% ' + currencyVal);
                        // this could be an issue if AGS and multiple line items. is the field even used by anyone?
                        updateQ.currencyConversionFactor__c = item.Product2.specification__r.mpRmbExchangeRate__c;        
                    }    
                }
            }
            */
                                    
            if (item.freight__c <> null) {
                freight = (item.freight__c * currencyVal).setScale(2); 
            }
            System.debug('***- lineItemType: '+lineItemType);
            if (item.UnitPrice <> null) {                
                unitPrice = (item.UnitPrice * currencyVal).setScale(2);
                
                // AN 1/4/18 Check CCMS & RMB then add Import Duty/Logistic to UnitPrice BEGIN
                // AN 8/7/18 Check Parts non EXW then add Incoterms Adder to UnitPrice
                if (lineItemType == 'MassParts') { 
                
                    if (theQuote.shippingTerm__c <> 'EXW' && theQuote.shippingTerm__c <> 'DAP - HK - Truck') {
                        if (theQuote.incotermAdder__c == Null) {
                            incoPrice = 0.0;
                        } else {
                            incoPrice = theQuote.incotermAdder__c;
                        }
                        unitPrice = ((item.UnitPrice + incoPrice) * currencyVal).setScale(2); 
                    }
                    
                    if (theQuote.corningSellingEntity__c == 'CCMS' || theQuote.corningSellingEntity__c == 'CVCL') {
                        if (theQuote.currency__c <> 'Dollar') {
                            if (theQuote.importDutyLogistic__c == Null) {
                                importPrice = 0.0;
                            } else {
                                importPrice = theQuote.importDutyLogistic__c;
                            }
                            unitPrice = ((item.UnitPrice + incoPrice + importPrice) * currencyVal).setScale(2);
                        }
                    }                  
                    
                }
                // AN 1/4/18 END    
                
                // AN 3/12/18 change item.unitPrice to unitPrice and remove additional * currencyVal calaculation
                vatUnitPrice = 0.00;           
                if (vat <> null && vat <> 0.0) {
                    // vatUnitPrice = ( (item.UnitPrice * ( (vat/100) + 1 ) ) * currencyVal ).setScale(4); 
                    vatUnitPrice = ( (UnitPrice * ( (vat/100) + 1 ) ) ).setScale(4); 
                }
            }
            
            if (item.TotalPrice <> null) {
                totalPrice = (item.TotalPrice * currencyVal).setScale(2); 
                
                // AN 1/4/18 Check CCMS & RMB then add Import Duty/Logistic to TotalPrice BEGIN
                // AN 8/7/18 Check Parts non EXW then add Incoterms Adder to TotalPrice
                if (lineItemType == 'SampleParts') { 
                
                   if (theQuote.shippingTerm__c <> 'EXW' && theQuote.shippingTerm__c <> 'DAP - HK - Truck') {
                        if (theQuote.incotermAdder__c == Null) {
                            incoPrice = 0.0;
                        } else {
                            incoPrice = theQuote.incotermAdder__c;
                        }
                        totalPrice = ((item.TotalPrice + (incoPrice * item.sampleQuantity__c)) * currencyVal).setScale(2);
                    }
                        
                    if (theQuote.corningSellingEntity__c == 'CCMS' || theQuote.corningSellingEntity__c == 'CVCL') {
                        if (theQuote.currency__c <> 'Dollar') {
                            if (theQuote.importDutyLogistic__c == Null) {
                                importPrice = 0.0;
                            } else {
                                importPrice = theQuote.importDutyLogistic__c;
                            }
                            totalPrice = ((item.TotalPrice + ((incoPrice + importPrice) * item.sampleQuantity__c)) * currencyVal).setScale(2);
                        }
                    }
                }    
                // AN 1/4/18 END    
                
                // AN 3/12/18 - calculation was referncing item.totalprice - changed to totalPrice variable + remove additional currencyVal
                vatTotalPrice = 0.0000;
                if (vat <> null && vat <> 0.0) {
                    //vatTotalPrice = ( (item.totalPrice * ( (vat/100) + 1 ) ) * currencyVal ).setScale(4);
                    //vatTotalPrice = ( (totalPrice * ( (vat/100) + 1 ) ) ).setScale(4); // AN 5/10
                    
                    if (lineItemType == 'SampleParts') { 
                    
                        if (theQuote.shippingTerm__c <> 'EXW' && theQuote.shippingTerm__c <> 'DAP - HK - Truck') {
                            if (theQuote.incotermAdder__c == Null) {
                                incoPrice = 0.0;
                            } else {
                                incoPrice = theQuote.incotermAdder__c;
                            }
                            vatTotalPrice = ((((item.TotalPrice + (incoPrice * item.sampleQuantity__c)) * currencyVal).setScale(2)) * ( (vat/100) + 1 )).setScale(4);
                        }
                    
                        if (theQuote.corningSellingEntity__c == 'CCMS' || theQuote.corningSellingEntity__c == 'CVCL') {
                            if (theQuote.currency__c <> 'Dollar') {
                                if (theQuote.importDutyLogistic__c == Null) {
                                    importPrice = 0.0;
                                } else {
                                    importPrice = theQuote.importDutyLogistic__c;
                                }            
                                vatTotalPrice = ((((item.TotalPrice + ((incoPrice + importPrice) * item.sampleQuantity__c)) * currencyVal).setScale(2)) * ( (vat/100) + 1 )).setScale(4);
                   
                                system.debug('$$$ IDLA: ' + theQuote.importDutyLogistic__c);    
                                system.debug('$$$ ITAL: ' + theQuote.incotermAdder__c);    
                                system.debug('$$$ ITP: ' + item.TotalPrice);
                                system.debug('$$$ IP: ' + importPrice);
                                system.debug('$$$ ISQ: ' + item.sampleQuantity__c);
                                system.debug('$$$ CV: ' + currencyVal);
                                system.debug('$$$ V: ' + vat);
                                system.debug('$$$ VTP: ' + vatTotalPrice);
                           }
                       }
                   }                          
                } // end vat <>
            }
            
            qliWrapper theWrapper = new qliWrapper();
            theWrapper.lineItem = item;
            theWrapper.descriptions.add(item.Description);
            theWrapper.qliDescriptionString = qliDescriptionString;
            theWrapper.unitPrice = unitPrice;
            theWrapper.totalPrice = totalPrice;
            theWrapper.freight = freight;
            theWrapper.vatUnitPrice = vatUnitPrice;
            theWrapper.vatTotalPrice = vatTotalPrice;
            qliList.add(theWrapper);
        }
        
        update updateQ; // AN 4/18/19 moved from line 458 to capture spec rate for currency conversion factor if RMB
        
        // AN 7/31/19
        system.debug('$$$ ' + oppUpdateList.size());
        if (oppUpdateList.size() > 0) {
            update oppUpdateList; 
        }
        
        //Wrap the Wrappers so the display will be grouped
        if (lineItemType == 'MassParts'){
            Id productId;
            qliMassPartsList = new list<qliMassPartsWrapper>();
            qliMassPartsWrapper theMassPartsWrapper = new qliMassPartsWrapper();
            
            for (qliWrapper theWrap : qliList){
                if (productId == null) { //first record
                    theMassPartsWrapper.lineItems.add(theWrap);
                    theMassPartsWrapper.productId = theWrap.lineItem.Product2Id;
                }
                else { //subsequent records
                    if (theWrap.lineItem.Product2Id == productId) { //Same Product, new Tier
                        theMassPartsWrapper.lineItems.add(theWrap);
                        theMassPartsWrapper.productId = theWrap.lineItem.Product2Id;
                    }
                    else { //new Product
                        qliMassPartsList.add(theMassPartsWrapper); //Add the old Wrapper to the list
                        theMassPartsWrapper = new qliMassPartsWrapper(); //create a new wrapper
                        theMassPartsWrapper.lineItems.add(theWrap);
                        theMassPartsWrapper.productId = theWrap.lineItem.Product2Id;
                    }
                }
                productId = theWrap.lineItem.Product2Id;
            }
            qliMassPartsList.add(theMassPartsWrapper); //Add the old Wrapper to the list
        }   
        
    } // end theQuote
    
    //Used to get the language prior to navigating to the page
    @AuraEnabled
    public static pdfWrapper getPDFInfo(string recordId) {
        Quote q = getQuoteInstance(recordId);
        
        //Check is Pricing Expired.
        if(q.RecordType.Name != 'GG Parts' && q.quoteType__c != 'Parts – Sample Request Quote'){ 
            List<Price__c> expiredPrices = getExpiredPricing(q); 
            if(expiredPrices.size() > 0){
                return new pdfWrapper(true, expiredPrices);
            }
        }
        
        
        boolean isPartsQuote = q.RecordType.Name.containsIgnoreCase('parts');
        boolean expirationDateAutoSet = false;
        
        //for parts program quote and sample quotes, expiration may be automatically set
        //in that case, don't worry about checking for expiration date
        string expItemType = '';
        if (isPartsQuote){
            expItemType = 'MassParts';
        }else{
            List<QuoteLineItem> itemList = getQuoteLineItems(recordId);
            if (q.RecordType.Name.containsIgnoreCase('sample') && itemList.size() > 0){
                string  fam = itemList[0].Product2.Family;
                if (fam == Label.GGProductTypeParts) {
                    expItemType = 'SampleParts';
                }
                
            }
        }
        
        boolean setEffectiveDateToToday = false;
        //is the effective date automatically set to today? - for parts it is for now but this is controlled by the custom setting
        if (GG_Quote_Expiration_Settings__c.getValues(expItemType) != null && GG_Quote_Expiration_Settings__c.getValues(expItemType).setEffectiveDateToToday__c){
            setEffectiveDateToToday = true;
        }
        
        //expiration date is auto set from custom settings
        if (expItemType != '' && GG_Quote_Expiration_Settings__c.getValues(expItemType) != null &&
            GG_Quote_Expiration_Settings__c.getValues(expItemType).daysToExpiration__c != NULL
        ){
            expirationDateAutoSet = true;
        }
        
        
        pdfWrapper wrapper = new pdfWrapper();
        wrapper.language = GG_Quote_Language__c.getValues(q.language__c).Output_Language_Code__c;
        Date today = System.Date.today();
        boolean isSampleQuote = utils.isSampleQuote(recordId);
        
        Utilities.RecordAccessWrapper theWrapper = new Utilities.RecordAccessWrapper(); 
        theWrapper = utils.getUserRecordAccess(recordId, UserInfo.getUserId()); 
        
        if (!theWrapper.RecordEditable){
            wrapper.canCreatePdf = false;
            wrapper.pdfCreationError = Label.GGQuoteViewOnlyNoPdf;
        }
        else if (isSampleQuote && getExistingPDFCount(recordId) > 0){
            wrapper.canCreatePdf = false;
            wrapper.pdfCreationError = Label.GGSampleQuoteOnlyOnePDF;
        }
        else if (q.Language__c == null){
            wrapper.canCreatePdf = false;
            wrapper.pdfCreationError = Label.GGLanguageQuoteError;
        }
        else if (q.corningSellingEntity__c == null){
            wrapper.canCreatePdf = false;
            wrapper.pdfCreationError = Label.GGSellingEntityQuoteError;
        }
        else if (q.Currency__c == null){
            wrapper.canCreatePdf = false;
            wrapper.pdfCreationError = Label.GGLanguageCurrencyError;
        }
        else if (q.Status == Label.GGQuotePricingReview || q.Status == Label.GGQuotePricingRejected){
            wrapper.canCreatePdf = false;
            wrapper.pdfCreationError = Label.GGPricingReviewQuoteError;
        }
        else if (q.plmApprovalExpired__c){
            wrapper.canCreatePdf = false;
            wrapper.pdfCreationError = Label.GGQuotePLMApprovalExpired;
        }
        else if (q.effectiveDate__c == null || (q.expirationDate == null) ){
            if (q.expirationDate == null && !expirationDateAutoSet ){
                wrapper.canCreatePdf = false;
                wrapper.pdfCreationError = Label.GGQuoteMissingExpirationDate;
            }
            //for parts effective date is automatically set to today, user doesn't have to enter the effective date 
            if (q.effectiveDate__c == null && !setEffectiveDateToToday){
                wrapper.canCreatePdf = false;
                wrapper.pdfCreationError = Label.GGQuoteMissingEffectiveDate;
            }
            
        }
        else {
            integer i = [SELECT Count() 
                         FROM QuoteBoilerplate__c  
                         WHERE quoteLanguage__c = :wrapper.language 
                         AND corningSellingEntity__c = :q.corningSellingEntity__c
                         AND isActive__c = true];
                
            if (i == 0) {
                wrapper.canCreatePdf = false;
                wrapper.pdfCreationError = Label.GGQuoteBoilerplateError; 
            }
            // AN 1/11/18 Validate line items are present
            if (q.QuoteLineItems.size() > 0) {
                for (QuoteLineItem qli : q.QuoteLineItems) {
                    if (qli.Product2.isActive == false) {
                        wrapper.canCreatePdf = false;
                        wrapper.pdfCreationError = Label.GGInactiveProductQuoteError;
                    }
                    // AN 1/9/18 - validate PLM Import Duty BEGIN
                    if (qli.plmRequiredToQuote__c == true) {
                        wrapper.canCreatePdf = false;
                        wrapper.pdfCreationError = Label.GGQuotePDFImportDuty;
                    }
                    // AN 1/9/18 - END
                     // AN 8/7/18 - validate PLM Import Duty BEGIN
                    if (qli.plmRequiredToQuoteInco__c == true) {
                        wrapper.canCreatePdf = false;
                        if(wrapper.pdfCreationError != null && wrapper.pdfCreationError.length() > 0){
                            if(!wrapper.pdfCreationError.contains('Incoterms Adder')){
                                wrapper.pdfCreationError += ', ' + Label.GGQuotePDFInco;
                            }
                        }else{
                            wrapper.pdfCreationError = Label.GGQuotePDFInco;
                        }
                    }
                    // AN 8/7/18 - END
                    //if quote has parts line items and price has expired, can't create pdf
                    // AN 5/4/18 - only prevent MP Quotes from being created with expired parts. Now ignore Sample Quotes
                    
                    if ((qli.Price__r.priceExpirationDate__c != null 
                            && qli.Price__r.priceExpirationDate__c < today) 
                            && qli.Product2.Family == Label.GGProductTypeParts
                            && expItemType == 'MassParts'){ // AN 5/4/18 added condition
                        wrapper.canCreatePdf = false;
                        wrapper.pdfCreationError = Label.GGPartsPriceExpired;
                        //wrapper.errorLineItems.add(qli);
                        break;
                    }
                }
            } else {
                wrapper.canCreatePdf = false;
                wrapper.pdfCreationError = Label.GGCorningLineItemQuoteError;
            }
        }
        
        //if quote has parts line items and price has expired, can't create pdf
        if (!wrapper.canCreatePdf && !isSampleQuote) {
            for (QuoteLineItem qli : q.QuoteLineItems) {
                if (qli.Product2.isActive == false
                        || (qli.Price__r.priceExpirationDate__c != null 
                            && qli.Price__r.priceExpirationDate__c < today 
                            && qli.Product2.Family == Label.GGProductTypeParts)
                        || (qli.priceBelowFloor__c 
                            && qli.Product2.Family == Label.GGProductTypeParts)
                        || (qli.qtyLessThanMOQ__c) ){
                        
                    if(qli.Price__r.priceExpirationDate__c < q.expirationDate){
                        wrapper.errorLineItems.add(qli);
                    }
                    
                }     
            }
        }
        
        //increment the version # of the quote pdf and save it so the pdf generator will have the new version #
        if (Wrapper.canCreatePdf){
            Quote updateQ = new Quote(Id=recordId);
            if (q.version__c == null){
                updateQ.version__c = 1;
            }
            else{
                updateQ.version__c = q.version__c + 1;
            }
            updateQ.Status = 'Created';
            
            // an - 2/19/18 - add the spec IDs and MOQs to the quote so it can be emailed out once custoemr accepted
            
            
            update updateQ;
        }
        
        return wrapper;
    }
    
    private static boolean checkExpiratioDate(Quote qt){    
        if(getExpiredPricing(qt).size() > 0){
            return true;
        }
        return false;
    }
    
    
    //Check any pricing expired before the expiration date.
    private static List<Price__c> getExpiredPricing(Quote qt){
        List<Price__c> pricingList = new List<Price__c>();
        try{
            for(QuoteLineItem qli: qt.QuoteLineItems){
                if(qli.Price__r.priceExpirationDate__c < qt.expirationDate){
                    pricingList.add(qli.Price__r);
                }
            }
            
        }catch(Exception e){
        }
        return pricingList;
    }
    
    private static Quote getQuoteInstance(String recordId){
        Quote q = [SELECT language__c, Status, Version__c, currency__c, corningSellingEntity__c, 
                    plmPricingDecisionDate__c, plmApprovalExpired__c, Opportunity.Type,
                    RecordTypeId, RecordType.Name, effectiveDate__c, expirationDate, AccountId, quoteType__c, 
                    (SELECT Id, partsTierMap__c, plmRequiredToQuote__c, plmRequiredToQuoteInco__c, 
                      Product2.isActive, Product2.Family, priceBelowFloor__c, Product2.Name, 
                      Price__r.priceExpired__c, Price__r.priceExpirationDate__c, Price__r.Product__r.Name,
                      qtyLessThanMOQ__c
                      FROM QuoteLineItems) 
                    FROM Quote 
                    WHERE Id = :recordId 
                    LIMIT 1];
        return q;
    }
    
    //return existing pdf count for the quote
    public static integer getExistingPDFCount(Id quoteId){
        Integer pdfCount = [Select Count() FROM QuoteDocument WHERE QuoteId = :quoteId];
        
        return pdfCount;
    }
    
    
    @AuraEnabled
    public static void savePDFtoQuote (string recordId, string language) {
        PageReference pdf = Page.QuotePDFGenerator;
        pdf.getParameters().put('id',recordId);
        pdf.getParameters().put('lang',language);
        
        Blob pdfBlob;
        try{
            pdfBlob = pdf.getContent();
        }
        catch(VisualforceException e){
            pdfBlob  = Blob.valueOf(e.getMessage());
        }
 
        QuoteDocument qd = new QuoteDocument();
        qd.QuoteId = recordId;
        qd.Document = pdfBlob;
        insert qd;
    }
}