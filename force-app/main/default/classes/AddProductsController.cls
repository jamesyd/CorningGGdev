///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 2/21/2017 ***///
///*** Controller class used in the add products custom Lightning component. ***///
public class AddProductsController {
        
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
        
    @AuraEnabled public static string ProductTypeRaw { get {return Label.GGProductTypeRaw;}}
    @AuraEnabled public static string ProductTypeConcore { get { return Label.GGProductTypeConcore;}}
    @AuraEnabled public static string ProductTypeParts { get { return Label.GGProductTypeParts;}}
    
    public class currentRecordInfoWrapper{
        
        private Id recordId;
        @AuraEnabled public string recordTypeName { get; set;}
        @AuraEnabled public string rawProductType {get { return AddProductsController.ProductTypeRaw;} set;}
        @AuraEnabled public string concoreProductType { get{ return AddProductsController.ProductTypeConcore;} set;}
        @AuraEnabled public string partsProductType  { get{ return AddProductsController.ProductTypeParts;} set;}
        @AuraEnabled public Boolean isQuote { get; set;}
        @AuraEnabled public Boolean isSampleQuote { get; set;}
        @AuraEnabled public Boolean isSampleOpportunity { get; set;}
        //for sample opportunity, only one product can be added.
        //if the opportunity already has one product, don't let user add additional products
        @AuraEnabled public Boolean canAddProducts { get; set;}
        
        public currentRecordInfoWrapper(String rId){
            isQuote = false;
            isSampleOpportunity = false;
            isSampleQuote = false;
            canAddProducts = true;
            Opportunity o;
            if (rId != null && rId.length() > 0){
                recordId = rId;
            
                Utilities Utils = new Utilities();
                if (utils.isRecordIdForQuote(recordId)){
                    isQuote = true;
                    
                    Quote q = [SELECT Id, RecordTypeId FROM Quote WHERE Id = :rId LIMIT 1];
                    recordTypeName = utils.getRecordTypeName(q.RecordTypeId);
                    isSampleQuote = recordTypeName.containsIgnoreCase('sample');
                    if (isSampleQuote){
                        canAddProducts = utils.quoteLineItemCount(rId) == 0;
                    }
                }
                else{
                    Utilities.SampleOptyResult res = utils.isSampleOpportunity2(recordId);
                    system.debug('lineitemcount: ' + res.countSampleOptyLineItems );
                    isSampleOpportunity = res.isSample;
                    if (isSampleOpportunity && res.countSampleOptyLineItems > 0){
                        canAddProducts = false;
                    }
                    recordTypeName = res.recordTypeName;
                }
            }
        }
    }

    //get the product type strings to search for
    @AuraEnabled
    public static currentRecordInfoWrapper getRecordInfo(String recordId){
        return new currentRecordInfoWrapper(recordId);
    }
/*
    // ORIGINAL Get filtered products for the search criteria
    @AuraEnabled
    public static ProductSearchWrapper searchProducts(Id recordId, String productType, String filterStr, Double zeroIndexPageNumber, boolean restrictToSupplyChain, Double maxRecordsPerPage) {
    // public static ProductSearchWrapper searchProducts(Id recordId, String productType, String filterStr, Double zeroIndexPageNumber, boolean restrictToSupplyChain, Double maxRecordsPerPage, Boolean isQuote, Boolean isSample, Boolean isProgramOpty) { //AN
        
        if (recordId == null){
            throw new AuraHandledException('RecordId is null');
        }
       
        Integer iZeroIndexPageNumber = Integer.valueOf(zeroIndexPageNumber);
        Integer imaxRecordsPerPage = Integer.valueOf(maxRecordsPerPage);
        
        //uses the wrapper class to perform the search 
        ProductSearchWrapper srWrapper = ProductSearchUtility.searchProducts(recordId, productType, filterStr, iZeroIndexPageNumber, restrictToSupplyChain, iMaxRecordsPerPage);
        //ProductSearchWrapper srWrapper = ProductSearchUtility.searchProducts(recordId, productType, filterStr, iZeroIndexPageNumber, restrictToSupplyChain, iMaxRecordsPerPage, isQuote, isSample, isProgramOpty); // AN
        system.debug('searchProductsResults=' + srWrapper);
        return srWrapper;
    } // END ORIGINAL
*/    
    // NEW Get filtered products for the search criteria
    @AuraEnabled
    // public static ProductSearchWrapper searchProducts(Id recordId, String productType, String filterStr, /*String filterProdName, String filterThkness, String filterLength, String filterWidth, String filterComposition,*/ Double zeroIndexPageNumber, boolean restrictToSupplyChain, Double maxRecordsPerPage) {
    public static ProductSearchWrapper searchProducts(Id recordId, String productType, String filterStr, /*String filterProdName, String filterThkness, String filterLength, String filterWidth, String filterComposition,*/ Double zeroIndexPageNumber, boolean restrictToSupplyChain, Double maxRecordsPerPage, Boolean isQuote, Boolean isSample, Boolean isProgramOpty) { //AN
        
        if (recordId == null){
            throw new AuraHandledException('RecordId is null');
        }
       
        Integer iZeroIndexPageNumber = Integer.valueOf(zeroIndexPageNumber);
        Integer imaxRecordsPerPage = Integer.valueOf(maxRecordsPerPage);
        
        //uses the wrapper class to perform the search 
        //ProductSearchWrapper srWrapper = ProductSearchUtility.searchProducts(recordId, productType, filterStr, iZeroIndexPageNumber,restrictToSupplyChain, iMaxRecordsPerPage);
        ProductSearchWrapper srWrapper = ProductSearchUtility.searchProducts(recordId, productType, filterStr, iZeroIndexPageNumber, restrictToSupplyChain, iMaxRecordsPerPage, isQuote, isSample, isProgramOpty); // AN
        system.debug('searchProductsResults=' + srWrapper);
        return srWrapper;
    } // END NEW

/*    
    // ORIGINAL Get filtered products for the search criteria
    @AuraEnabled
    public static ProductSearchWrapper getMTOSpecProducts(Id recordId, String productType,  Double zeroIndexPageNumber, boolean restrictToSupplyChain, Double maxRecordsPerPage) {
    // public static ProductSearchWrapper getMTOSpecProducts(Id recordId, String productType,  Double zeroIndexPageNumber, boolean restrictToSupplyChain, Double maxRecordsPerPage, Boolean isQuote, Boolean isSample, Boolean isProgramOpty) { //AN
        
        if (recordId == null){
            throw new AuraHandledException('RecordId is null');
        }
       
        Integer iZeroIndexPageNumber = Integer.valueOf(zeroIndexPageNumber);
        Integer imaxRecordsPerPage = Integer.valueOf(maxRecordsPerPage);
        
        //uses the wrapper class to perform the search 
        ProductSearchWrapper srWrapper = ProductSearchUtility.getMTOSpecProducts(recordId, productType, iZeroIndexPageNumber, restrictToSupplyChain, iMaxRecordsPerPage);
        //ProductSearchWrapper srWrapper = ProductSearchUtility.getMTOSpecProducts(recordId, productType, iZeroIndexPageNumber, restrictToSupplyChain, iMaxRecordsPerPage, isQuote, isSample, isProgramOpty); // AN
        system.debug('getMTOSpecProducts=' + srWrapper);
        return srWrapper;
    } // END ORIGINAL
*/
    
    // NEW Get filtered products for the search criteria
    @AuraEnabled
    // public static ProductSearchWrapper getMTOSpecProducts(Id recordId, String productType,  Double zeroIndexPageNumber, boolean restrictToSupplyChain, Double maxRecordsPerPage) {
    public static ProductSearchWrapper getMTOSpecProducts(Id recordId, String productType,  Double zeroIndexPageNumber, boolean restrictToSupplyChain, Double maxRecordsPerPage, Boolean isQuote, Boolean isSample, Boolean isProgramOpty) { //AN
        
        if (recordId == null){
            throw new AuraHandledException('RecordId is null');
        }
       
        Integer iZeroIndexPageNumber = Integer.valueOf(zeroIndexPageNumber);
        Integer imaxRecordsPerPage = Integer.valueOf(maxRecordsPerPage);
        
        //uses the wrapper class to perform the search 
        //ProductSearchWrapper srWrapper = ProductSearchUtility.getMTOSpecProducts(recordId, productType, iZeroIndexPageNumber, restrictToSupplyChain, iMaxRecordsPerPage);
        ProductSearchWrapper srWrapper = ProductSearchUtility.getMTOSpecProducts(recordId, productType, iZeroIndexPageNumber, restrictToSupplyChain, iMaxRecordsPerPage, isQuote, isSample, isProgramOpty); // AN
        system.debug('getMTOSpecProducts=' + srWrapper);
        return srWrapper;
    } // END NEW
    
    //Add products.
    @AuraEnabled
    public static Utilities.DMLResult addProducts(String recordId, String priceIds){
        //system.debug('pRecordId: ' + recordId);
        system.debug('priceIds: ' + priceIds);
        priceIds = priceIds.trim();
        if (recordId == null || priceIds == null || priceIds.length() == 0){
            return null;
        }
        
        List<Id> priceIdList = new List<Id>();
        if (priceIds.contains(',')){
            for (String pId: priceIds.split(',')){
                priceIdList.add(pId);
            }
        }
        else{
            priceIdList.add(priceIds);
        }
        
        OptyQuoteLIUtility util = new OptyQuoteLIUtility(recordId, priceIdList);
        system.debug('in addProducts ');
        Utilities.DMLResult results = util.addLineItems();
        return results;
    }
    
    @AuraEnabled
    public static Utilities.DMLResult scheduleOptyLineItems(String recordId, string strOptyLineItems){
        if (recordId == null || strOptyLineItems == null || strOptyLineItems.length() == 0){
            return null;
        }
        OpportunityLineItem[] lstLineItems = (List<OpportunityLineItem>)System.JSON.deserializeStrict(strOptyLineItems, List<OpportunityLineItem>.Class);
        for (OpportunityLineItem oli: lstLineItems){
            system.debug('serviceDate:' + oli.serviceDate);
        }
        return OptyQuoteLIUtility.scheduleOptyLineItems(recordId, lstLineItems);
    }
}