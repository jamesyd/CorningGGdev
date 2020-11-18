/**
 * @description       : 
 * Added for Gorilla Glass Implementation 
 * Salesforce Cloud Services - 2/21/2017 
 * Product and price search class used in the add products custom Lightning component.
 * Inventory Product will return for owner of price records in all situations. Sys Admin should own the inventory price records.
 * @author            : Adam Nicholson?
 * @group             : 
 * @last modified on  : 08-04-2020
 * @last modified by  : Arquimidez Mora
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0.1   08-04-2020   Arquimidez Mora   Fixed Product Query to avoid duplicates and missing specs
**/
public with sharing class ProductSearchUtility{
 
     static Utilities Utils = new Utilities();
     
     //Max number of records to return
     private static Integer searchSize { get { 
        if (GGCustomSettings__c.getOrgDefaults() != null){
            return (Integer)GGCustomSettings__c.getOrgDefaults().productSearchPageSize__c;
        }
        else {return 10;} } }
     
     public Id recordId { get; set;}

     public boolean isQuote { get; set;} // AN
     public boolean isSample { get; set;} // AN
     public boolean isProgramOpty { get; set;} // AN
        
     public String productType {get; set;}
     
     public String filterStr { get; set; }
     public integer zeroIndexPageNumber {get; set;}
     public boolean restrictToSupplyChain {get; set;}
     public ProductSearchWrapper srWrapper {get; set;}
     public integer maxRecordsPerPage {get; set;}
     
/*         
     // ORIGINAL constructor
     public ProductSearchUtility(Id rId, String pType, String fStr, Integer fPage, boolean restrict, Integer imaxRecordsPerPage){
            
         recordId = rId; // Always program opportunity Id
         String sobjectType = rId.getSObjectType().getDescribe().getName();         
         isQuote = false;//rIQ;
         isSample = false;//rIS;
         isProgramOpty = false;//rPO;
         
         // AN 7/11 figure out if inventory should be returned

         
         productType = pType;
         
         if (fStr == null){
             fStr = '  ';
         }
         
         filterStr = String.escapeSingleQuotes(fStr);
         zeroIndexPageNumber = fPage >= 0? fPage : 0;
         restrictToSupplyChain = restrict;
         maxRecordsPerPage = imaxRecordsPerPage > 0 ? imaxRecordsPerPage : 10;
         
         srWrapper = new ProductSearchWrapper();
         srWrapper.requestedPageNumber = zeroIndexPageNumber;
         srWrapper.totalRecordCount = 0;
         srWrapper.searchResults = new List<SearchResult>();
         
         system.debug('$$$: ' + rId + ' $ ' + isQuote + ' $ ' + isSample + ' $ ' + isProgramOpty + ' $ ' + sobjectType);
     } // END ORIGINAL
*/
     // NEW constructor
     public ProductSearchUtility(Id rId, String pType, String fStr, Integer fPage, boolean restrict, Integer imaxRecordsPerPage, Boolean rIQ, Boolean rIS, Boolean rPO) {
         
         system.debug('$$$ Variables: '
          + rId + ' $ '
          + pType + ' $ '
          + fStr + ' $ '
          + fPAge + ' $ '
          + restrict + ' $ '
          + imaxRecordsPerPage + ' $ '
          + rIQ + ' $ '
          + rIS + ' $ '
          + rPO);
            
         recordId = rId; // AN - Always program opportunity Id
         String sobjectType = rId.getSObjectType().getDescribe().getName(); // AN - not used. was used in debugging     
         isQuote = rIQ; // AN - new. now we know if the component is loaded from a quote
         isSample = rIS; // AN - new. now we know if the component is loaded from a sample opportunity
         isProgramOpty = rPO; // AN - new. now we know if the component is loaded from a program opportunity
         
         productType = pType;
         
         if (fStr == null) {
             fStr = '  ';
         }
         
         filterStr = String.escapeSingleQuotes(fStr);
         zeroIndexPageNumber = fPage >= 0? fPage : 0;
         restrictToSupplyChain = restrict;
         maxRecordsPerPage = imaxRecordsPerPage > 0 ? imaxRecordsPerPage : 10;
         
         srWrapper = new ProductSearchWrapper();
         srWrapper.requestedPageNumber = zeroIndexPageNumber;
         srWrapper.totalRecordCount = 0;
         srWrapper.searchResults = new List<SearchResult>();
         
     } // END NEW




/*     
     // ORIGINAL Return all MTO/Spec products that match productType associated with this quote/opportunity
     public static ProductSearchWrapper getMTOSpecProducts(Id recordId, String productType, integer zeroIndexPageNumber, boolean restrictToSupplyChain, Integer maxRecordsPerPage)
     {
        Id optyId = recordId;
        
        if (optyId == null){
          throw new AuraException(Label.ProductSearchNullOptyError);  
        }       
         
        String strRId = recordId;
        Id filterQuoteProductsForAccount = null;
        //for quotes, get the owner opportunity
        if (utils.isRecordIdForQuote(recordId)){
            for (Quote q: [SELECT Id, OpportunityId, requestingAccount__c, AccountId FROM Quote WHERE Id = :RecordId]){
                optyId = q.OpportunityId;
                restrictToSupplyChain = false;//for quotes don't filter by supply chain, filter by account requesting the quote
            }
        }
        else{
            //for sample opportunities, use program opty id
            for (Opportunity o: [SELECT Id, Name, massProductionOpportunity__c FROM Opportunity WHERE Id = :optyId LIMIT 1]){
                if (o.massProductionOpportunity__c != null){
                    optyId = o.massProductionOpportunity__c;
                    break;
                }
            }
        }
        // ProductSearchUtility psUtilsOld = new ProductSearchUtility(optyId, productType, '', zeroIndexPageNumber, restrictToSupplyChain, maxRecordsPerPage);
        ProductSearchUtility psUtils = new ProductSearchUtility(optyId, productType, '', zeroIndexPageNumber, restrictToSupplyChain, maxRecordsPerPage);
        try{
            psUtils.searchMTORawSpecPartsProducts();
            
        }
        catch (Exception e){
            system.debug('Error in search: '+ e.getMessage());
        }
        return psUtils.srWrapper;
         
     } // END ORIGINAL
*/     
     

     // NEW Return all MTO/Spec products that match productType associated with this quote/opportunity - this is run when add product loads or a tab is clicked to change product type
     public static ProductSearchWrapper getMTOSpecProducts(Id recordId, String productType, integer zeroIndexPageNumber, boolean restrictToSupplyChain, Integer maxRecordsPerPage, Boolean isQuote, Boolean isSample, Boolean isProgramOpty) {
        Id optyId = recordId;
        
        if (optyId == null) {
          throw new AuraException(Label.ProductSearchNullOptyError);  
        }       
         
        String strRId = recordId;
        Id filterQuoteProductsForAccount = null;
        // for quotes, get the owner opportunity
        if (utils.isRecordIdForQuote(recordId)) {
            for (Quote q: [SELECT Id, OpportunityId, requestingAccount__c, AccountId FROM Quote WHERE Id = :RecordId]) {
                optyId = q.OpportunityId;
                restrictToSupplyChain = false; // for quotes don't filter by supply chain, filter by account requesting the quote
            }
        } else {
            // for sample opportunities, use program opty id
            for (Opportunity o: [SELECT Id, Name, massProductionOpportunity__c FROM Opportunity WHERE Id = :optyId LIMIT 1]) {
                if (o.massProductionOpportunity__c != null) {
                    optyId = o.massProductionOpportunity__c;
                    break;
                }
            }
        }
        
        ProductSearchUtility psUtils = new ProductSearchUtility(optyId, productType, '', zeroIndexPageNumber, restrictToSupplyChain, maxRecordsPerPage, isQuote, isSample, isProgramOpty);
        try {
            psUtils.searchMTORawSpecPartsProducts(isSample); // pass variable to inidicate if sample request (show inventory if sample request)           
        } catch (Exception e) {
            system.debug('Error in search: '+ e.getMessage());
        }
        
        return psUtils.srWrapper;
         
     } // END NEW







/*     
     //ORIGIANL Search results static method to search products for opportunities, sample opportunities, and quotes
     public static ProductSearchWrapper searchProducts(Id recordId, String productType, String filterStr, integer zeroIndexPageNumber, boolean restrictToSupplyChain, Integer maxRecordsPerPage){
        Id optyId = recordId;
        
        if (optyId == null){
          throw new AuraException(Label.ProductSearchNullOptyError);  
        }       
         
        //List<SearchResult> sResults = new List<SearchResult>();
        String strRId = recordId;
        Id filterQuoteProductsForAccount = null;
        //for quotes, get the owner opportunity
        if (utils.isRecordIdForQuote(recordId)){
            for (Quote q: [SELECT Id, OpportunityId, requestingAccount__c, AccountId FROM Quote WHERE Id = :RecordId]){
                optyId = q.OpportunityId;
                restrictToSupplyChain = false;//for quotes don't filter by supply chain, filter by account requesting the quote
                //filterQuoteProductsForAccount = (q.requestingAccount__c == null) ? q.AccountId : q.requestingAccount__c;
            }
        }
        else{
            //for sample opportunities, use program opty id
            for (Opportunity o: [SELECT Id, Name, massProductionOpportunity__c FROM Opportunity WHERE Id = :optyId LIMIT 1]){
                if (o.massProductionOpportunity__c != null){
                    optyId = o.massProductionOpportunity__c;
                    break;
                }
            }
        }

        //ProductSearchUtility psUtilsOld = new ProductSearchUtility(optyId, productType, filterStr, zeroIndexPageNumber, restrictToSupplyChain, maxRecordsPerPage);
        ProductSearchUtility psUtils = new ProductSearchUtility(optyId, productType, filterStr, zeroIndexPageNumber, restrictToSupplyChain, maxRecordsPerPage);   
        
        //SOSL search needs at least 2 chars
        if (filterStr != null && filterStr.length() > 1){
            try{     
                if (productType == AddProductsController.ProductTypeParts){
                //psUtils.searchParts();
                    psUtils.searchPartsSOSL();
                //sResults = searchParts(optyId, filterProdName, filterThkness, filterLength, filterWidth, filterComposition, zeroIndexPageNumber, productType);
                }
                else if (productType == AddProductsController.ProductTypeRaw || productType == AddProductsController.ProductTypeConcore){ 
                    psUtils.searchRawConcoreSOSL(filterQuoteProductsForAccount);
                //sResults = searchRawConcore(optyId, filterProdName, filterThkness, filterLength, filterWidth, filterComposition, zeroIndexPageNumber, restrictToSupplyChain, productType,filterQuoteProductsForAccount);
                }
            }
            catch (Exception e){
                system.debug('Error in search: '+ e.getMessage());
            }
        } else {
            // AN - reset search
            try{
                psUtils.searchMTORawSpecPartsProducts();
            
            }
            catch (Exception e){
                system.debug('Error in search: '+ e.getMessage());
            }
       
        }
        
        //if (sResults.size() > 0){
        //    system.debug('First search result: ' + sResults[0]);
        //}
        return psUtils.srWrapper;
     } // END ORIGINAL
*/

     // NEW Search results static method to search products for opportunities, sample opportunities, and quotes
     public static ProductSearchWrapper searchProducts(Id recordId, String productType, String filterStr, integer zeroIndexPageNumber, boolean restrictToSupplyChain, Integer maxRecordsPerPage, Boolean isQuote, Boolean isSample, Boolean isProgramOpty) {
        Id optyId = recordId;
        
        if (optyId == null) {
          throw new AuraException(Label.ProductSearchNullOptyError);  
        }       
         
        String strRId = recordId;
        Id filterQuoteProductsForAccount = null;
        // for quotes, get the owner opportunity
        if (utils.isRecordIdForQuote(recordId)) {
            for (Quote q: [SELECT Id, OpportunityId, requestingAccount__c, AccountId FROM Quote WHERE Id = :RecordId]) {
                optyId = q.OpportunityId;
                restrictToSupplyChain = false; // for quotes don't filter by supply chain, filter by account requesting the quote
            }
        } else {
            // for sample opportunities, use program opty id
            for (Opportunity o: [SELECT Id, Name, massProductionOpportunity__c FROM Opportunity WHERE Id = :optyId LIMIT 1]) {
                if (o.massProductionOpportunity__c != null) {
                    optyId = o.massProductionOpportunity__c;
                    break;
                }
            }
        }

        ProductSearchUtility psUtils = new ProductSearchUtility(optyId, productType, filterStr, zeroIndexPageNumber, restrictToSupplyChain, maxRecordsPerPage, isQuote, isSample, isProgramOpty);   
        
        //SOSL search needs at least 2 chars
        if (filterStr != null && filterStr.length() > 1) {
            try {     
                if (productType == AddProductsController.ProductTypeParts) {
                    psUtils.searchPartsSOSL(isSample);
                } else if (productType == AddProductsController.ProductTypeRaw || productType == AddProductsController.ProductTypeConcore) { 
                    psUtils.searchRawConcoreSOSL(filterQuoteProductsForAccount);
                }
            } catch (Exception e) {
                system.debug('Error in search: '+ e.getMessage());
            }
        } else {
            // AN - reset search
            try {
                psUtils.searchMTORawSpecPartsProducts(isSample);            
            } catch (Exception e) {
                system.debug('Error in search: '+ e.getMessage());
            }       
        }
        
        return psUtils.srWrapper;
     } // END NEW
         
     // builds the where clause
     private static String buildWhereClauseSingleFilter(String filter) {
         String rStr = ''; // whereClause;
         String sW;
         if (filter != null) {
             rStr = ' AND ( searchText__c LIKE \'%' + filter + '%\')';
         }
         
         system.debug('rStr: ' + rStr);
         return rStr;
     }
     
     // for the opportunity id, returns finisher/tpms to be used as filter for raw glass & concore
     private static void getFinisherTPMs(Id optyId, List<Id> supplyChainIds, string prodType){
         // only include TPM/Finisher supply chain accounts for raw glass search
         // only include TPM supply chain accounts for concore search
         for (SupplyChain__c sc: [SELECT Id, finisher__c, tpm__c FROM SupplyChain__c WHERE Opportunity__c =: optyId ]) {
            
            // include finishers in raw search
            if (prodType == AddProductsController.ProductTypeRaw && sc.finisher__c != null) {
                supplyChainIds.add(sc.finisher__c);
            }
            
            if (sc.tpm__c != null) {
                supplyChainIds.add(sc.tpm__c);
            }
         }       
     }
     
     private static String buildQueryforRawConcore(Id optyId, boolean filterBySupplyChain, List<Id> supplyChainIds, String prodType, Id filterQuoteProductsForAccount){
         String strQuery = ' WHERE Product__r.Family = \'' + prodType + '\'';
         
         if (filterBySupplyChain != null && filterBySupplyChain) {
             getFinisherTPMs(optyId, supplyChainIds, prodType);
             strQuery += ' AND ( (Product__r.isStandard__c = TRUE';
             if (supplyChainIds.size() > 0) {
                 strQuery += ' AND Account__c in :supplyChainIds';
             }
             strQuery += ')';
         } else {
             if (filterQuoteProductsForAccount != null) {
                 strQuery += ' AND ( ( Account__c = :filterQuoteProductsForAccount AND Product__r.isStandard__c = TRUE)';
             } else {
                 strQuery += ' AND ( (Product__r.isStandard__c = TRUE)';
             }
         }
         
         strQuery += ' OR (Product__r.isStandard__c = FALSE AND Product__r.Opportunity__c = :optyId) )';
         
         return strQuery;
     }
     
     private static String LimitStr(Integer iSearchSize) {
         String rStr = '';
         // does the limit the 
         if (isearchSize > 0) {
             rStr = rStr + ' LIMIT ' + String.valueOf((Integer)isearchSize);
         }
         
         return rStr;
    }
     
     private static String buildLimitOffset(Integer zeroIndexPageNumber, Integer iSearchSize) {
         Integer iNum = zeroIndexPageNumber;
         String rStr = '';
         
         rStr += LimitStr(iSearchSize);
         
         if (iNum > 0 && (iSearchSize > 0)) {
             rStr += ' OFFSET ' +  String.valueOf((Integer)(zeroIndexPageNumber*iSearchSize));
         }
         return rStr;
     }
     
     // Search button method for parts - 
     private void searchPartsSOSL(Boolean isSample) {
         Id optyId = recordId;
         String getInventory = (isSample) ? 'OR (Product__r.isInventory__c = TRUE)' : ''; // AN - drives dynamic where clause to include inventory or not
         String prodQuerySOSL = 'FIND :filterStr IN ALL FIELDS RETURNING Price__c' + 
                             ' (Id, price1__c, price2__c, price3__c, price4__c, samplePrice__c, Product__r.sampleMOQ__c, upperLimit1__c, upperLimit2__c, upperLimit3__c,' +
                             ' upperLimit4__c,  Product__c, Product__r.Name, Product__r.MOQ__c, Product__r.UnitOfMeasure__c,' +
                             ' Product__r.specificationName__c, Product__r.Specification__r.tpmName__c, Product__r.Specification__r.version__c, Account__r.Name,'+
                             ' Product__r.isInventory__c, Product__r.specialRequirements__c,Product__r.specification__r.isMTO__c ';
         // AN - changed Product__r.specification__r.specialRequirements__c to Product__r.specialRequirements__c
         // AN - added Product__r.isInventory__c to prodQuerySOSL
         String prodFamilyWhere = 'WHERE Product__r.Family = \'' + productType + '\'' + ' AND ((Product__r.Opportunity__c = \'' + optyId + '\')' + getInventory + ')'; // AN - updated where clause to include inventory if necessary 
         
         prodQuerySOSL += prodFamilyWhere + ' ORDER BY Product__r.Name' + buildLimitOffset(zeroIndexPageNumber, maxRecordsPerPage) + ')';                
         String prodQueryWOfields =  'FROM Price__c ' + prodFamilyWhere;    

         // add the filter to the query
         prodQueryWOfields = prodQueryWOfields + buildWhereClauseSingleFilter(filterStr);

         SearchResult sr;         
         
         String countQuery = 'SELECT COUNT() ' + prodQueryWOfields + LimitStr(searchSize);
               
         srWrapper.totalRecordCount = Database.countQuery(countQuery);
System.debug('@@ JD SOSL search trc=' + srWrapper.totalRecordCount);
System.debug('@@ JD query=' + prodQueryWOfields);
    
         for (Price__c p: (list<Price__c>)(Search.query(prodQuerySOSL)[0])) {
             sr = new SearchResult();
             sr.priceId = p.Id;
             sr.ProductId = p.Product__c;
             sr.Productname = p.Product__r.Name;
             sr.MOQ = (integer)p.Product__r.MOQ__c;
             sr.unitOfMeasure = p.Product__r.UnitOfMeasure__c;
             sr.spec = '';
             
             if (p.Product__r.specificationName__c != null && p.Product__r.specificationName__c != '') {
                 sr.spec = p.Product__r.specificationName__c;                   
                 sr.specialRequirements = p.Product__r.specialRequirements__c; // AN - changed Product__r.specification__r.specialRequirements__c to Product__r.specialRequirements__c                 
                 sr.isMTO = p.Product__r.specification__r.isMTO__c;
             }     
                 
             sr.price1 = p.price1__c;
             sr.price2 = p.price2__c;
             sr.price3 = p.price3__c;
             sr.price4 = p.price4__c;
             if (p.Account__c == null) {
                 sr.Account = '-';
             } else {
                 sr.Account = p.Account__r.Name;
             }
             sr.Limit1 = (Integer)p.upperLimit1__c;
             sr.Limit2 = (Integer)p.upperLimit2__c;
             sr.Limit3 = (Integer)p.upperLimit3__c;
             sr.Limit4 = (Integer)p.upperLimit4__c;
             sr.tieredPricing = getPartTieredPriceStr(p);              
             srWrapper.SearchResults.add(sr);
         }         
     }     
     
     // returns list of parts products/prices matching filters
     public void searchRawConcoreSOSL(Id filterQuoteProductsForAccount) {                               
         List<SearchResult> results = srWrapper.searchResults;
         
         //return results;
         Id optyId = recordId;
         
         List<Id> supplyChainIds = new List<Id>();         
         
         String prodQuerySOSL = 'FIND :filterStr IN ALL FIELDS RETURNING Price__c' + 
                             ' (Id, priceUnit__c, isProductActive__c,' +
                             ' Product__c, Product__r.Name, Product__r.MOQ__c, Product__r.UnitOfMeasure__c,' +
                             ' Product__r.specificationName__c, Product__r.Specification__r.version__c,  Product__r.Specification__r.tpmName__c, Account__r.Name,' +
                             ' Product__r.specification__r.specialRequirements__c,Product__r.specification__r.isMTO__c ';
         
         String prodQueryWOFields = buildQueryforRawConcore(optyId, restrictToSupplyChain, supplyChainIds, productType, filterQuoteProductsForAccount);
         if (restrictToSupplyChain != null && restrictToSupplyChain) {
             if (supplyChainIds.size() == 0){ // if supply chain not defined
                 return;// results;
             }
         }
         
         Integer maxSearchSize = searchSize;
         
         //add the filter criteria to the query
         prodQueryWOfields = prodQueryWOfields + buildWhereClauseSingleFilter(filterStr);
         
         String prodQuery = prodQuerySOSL + prodQueryWOFields + ' ' + ' ORDER BY Product__r.Name' + buildLimitOffset(zeroIndexPageNumber, maxRecordsPerPage) + ')';
         String countQuery = 'SELECT Count() FROM Price__c' + prodQueryWOFields + LimitStr(maxSearchSize);
                
         srWrapper.totalRecordCount = Database.countQuery(countQuery);
         system.debug('Concore - srWrapper.totalRecordCount='+srWrapper.totalRecordCount);
         system.debug('Concore prodQuery: ' + prodQuery);
         SearchResult sr;         
         
         system.debug('Concore - Search.query(prodQuery)='+Search.query(prodQuery));
         
         // find products that match the filter
         for (Price__c p: (List<Price__C>)(Search.query(prodQuery)[0])) {
             sr = new SearchResult();
             sr.priceId = p.Id;
             sr.ProductId = p.Product__c;
             sr.Productname = p.Product__r.Name;
             sr.MOQ = (integer)p.Product__r.MOQ__c;
             sr.unitOfMeasure = p.Product__r.UnitOfMeasure__c;
             
             sr.mto = '-';
             system.debug('sr.SpecName' + sr.mto);
             if (p.Product__r.specificationName__c != null && p.Product__r.specificationName__c != '' && p.Product__r.specificationName__c != 'undefined') {
                 sr.mto = p.Product__r.specificationName__c;  
                 sr.specialRequirements = p.Product__r.specification__r.specialRequirements__c;
                 sr.isMTO = p.Product__r.specification__r.isMTO__c;
             }  
                    
             system.debug('sr.SpecName' + sr.mto);
                        
             sr.priceUnit = p.priceUnit__c;             
             sr.Account = p.Account__r.Name; 
             
             // AN 10/8/18 - only return active products
             if (p.isProductActive__c == TRUE) {
                 results.add(sr);
             }
         }                  
     }
     
     // Returns tiered pricing string used in the UI
     private string getPartTieredPriceStr(price__c p) {
         String str = '';
         Integer num;
         if (p.price1__c == null) return str;
         List<String> args = new String[]{'0','number','###,###,##0.00'};
         
         str = '';
         // an 6/13/18 - add sampletier to interface if selected on quote
         if (p.samplePrice__c != null && isQuote && !isSample) {
             str += p.Product__r.sampleMoq__c.format();
             str += '-' + (p.Product__r.moq__c-1).format();
             str += ' @ $' + String.format(p.samplePrice__c.format(), args);
             str += ' for SAMPLES';
             str += '<br/>';
         }
         
         
         if (p.Product__r.moq__c != null) {
             str += p.Product__r.moq__c.format();
         } else {
             str += '1';
         }
         str += '-' + p.upperlimit1__C.format();
         str += ' @ $' + String.format(p.price1__c.format(), args);
         str += ' for MP';
         
         if (p.price2__c != null) {
             str += '<br/>';
             num = ((Integer)p.upperLimit1__c) + 1;
             if (p.price3__c != null){
                 str += num.format() + '-' + p.upperLimit2__c.format();
             }else{
                 str += '>' + p.upperLimit1__c.format();
             }
             str += ' @ $' + String.format(p.price2__c.format(), args);
             str += ' for MP';
         }
         
         if (p.price3__c != null) {
             str += '<br/>';
             num = ((Integer)p.upperLimit2__c) + 1;
             if (p.price4__c != null) {
                 str += num.format() + '-' + p.upperLimit3__c.format();
             } else {
                 str += '>' + p.upperLimit2__c.format();
             }
             str += ' @ $' + String.format(p.price3__c.format(), args);
             str += ' for MP';
         }
         
         if (p.price4__c != null){
             str += '<br/> >' + p.upperLimit3__c.format();
             str += ' @ $' + String.format(p.price4__c.format(), args);  
             str += ' for MP';           
         }
         
         return str;
     }
     
     // Searches parts and MTO raw/concore on Page Load
     public void searchMTORawSpecPartsProducts(Boolean isSample) {
         Id optyId = recordId;
         String getInventory = (isSample) ? 'OR (Product__r.isInventory__c = TRUE)' : ''; // AN - drives dynamic where clause to include inventory or not

         List<SearchResult> results = srWrapper.searchResults;
         Id UserId = UserInfo.getUserId();
         string whereClause = ' WHERE Product__r.isActive = TRUE AND Product__r.Family = \'' + productType + '\'' + ' AND ( (Product__r.Opportunity__c = \'' + optyId + '\')' + ' OR (OwnerId=\'' + userId + '\' AND Product__r.Opportunity__c = null)' + getInventory + ')'; // AN - updated where clause to include inventory if necessary   
         String countQuery = 'SELECT Count() FROM Price__c' + whereClause;
         srWrapper.totalRecordCount = Database.countQuery(countQuery);
         
         if (srWrapper.totalRecordCount > 0) {
            String prodQuery = 'SELECT Id, Product__c, Product__r.Name, Product__r.isInventory__c, Product__r.Specification__r.tpmName__c, Account__r.Name, priceUnit__c, Product__r.sampleMOQ__c, Product__r.MOQ__c, '
            + 'Product__r.UnitOfMeasure__c, Product__r.specificationName__c, samplePrice__c, price1__c, price2__c, price3__c, price4__c, '
            + 'upperLimit1__c,upperLimit2__c,upperLimit3__c,upperLimit4__c, Product__r.specification__r.version__c, Product__r.specialRequirements__c,Product__r.specification__r.isMTO__c '
            + 'FROM Price__c' + whereClause + ' ORDER BY Product__r.Name, Product__r.specificationName__c ' 
            + buildLimitOffset(zeroIndexPageNumber, maxRecordsPerPage); 
            // an 6/13/18 add samplePrice and sampleMOQ          
            // AN - added Product__r.isInventory__c to prodQuery              
            // AN - changed Product__r.specification__r.specialRequirements__c to Product__r.specialRequirements__c 
            SearchResult sr;
            System.debug('***- prodQuery: '+prodQuery);
             
            //find products that match the filter
            for (Price__c p: (List<Price__c>)(Database.query(prodQuery))) {
                sr = new SearchResult();
                sr.priceId = p.Id;
                sr.ProductId = p.Product__c;
                sr.Productname = p.Product__r.Name;
                sr.MOQ = (integer)p.Product__r.MOQ__c;
                sr.unitOfMeasure = p.Product__r.UnitOfMeasure__c;
                sr.mto = '-';
             
                if (p.Product__r.specificationName__c != null 
                    && p.Product__r.specificationName__c != '' 
                    && p.Product__r.specificationName__c != 'undefined'){
                    sr.mto = p.Product__r.specificationName__c;  
                    sr.specialRequirements = p.Product__r.specialRequirements__c; // AN - changed Product__r.specification__r.specialRequirements__c to Product__r.specialRequirements__c                    
                    sr.isMTO = p.Product__r.specification__r.isMTO__c;
                }  
                
                sr.spec = sr.mto;      
                sr.priceUnit = p.priceUnit__c;     
                sr.price1 = p.price1__c;
                sr.price2 = p.price2__c;
                sr.price3 = p.price3__c;
                sr.price4 = p.price4__c;
                
                if (!p.Product__r.specification__r.isMTO__C) {
                    sr.tieredPricing = getPartTieredPriceStr(p);
                }
                
                if (p.Account__c == null) {
                    sr.Account = '-';
                } else {
                    sr.Account = p.Account__r.Name;
                }
                
                sr.TPM = p.Product__r.Specification__r.tpmName__c; // AN - 8/28/18 - add TPM to search results
                
                sr.Limit1 = (Integer)p.upperLimit1__c;
                sr.Limit2 = (Integer)p.upperLimit2__c;
                sr.Limit3 = (Integer)p.upperLimit3__c;
                sr.Limit4 = (Integer)p.upperLimit4__c;
                 
                results.add(sr);
            }
            System.debug('***- Search Result: '+sr);
        }
    } 
}