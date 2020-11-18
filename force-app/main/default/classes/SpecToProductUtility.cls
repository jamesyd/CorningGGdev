/**
 * @File Name          : SpecToProductUtility.cls
 * @Description        : 
 * @Author             : Arquimidez Mora
 * @Group              : 
 * @Last Modified By   : Jim Dickerson
 * @Last Modified On   : 11-09-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    28/6/2020   Arquimidez Mora     Initial Version
 * 1.1    03/09/2020  Edgar Santillana     partExpDate changed from 30 days to 2 years
 * 1.2    11/09/2020  Jim Dickerson        set isPhyllo__c if spec has Corning Bendable Glass innovation
**/
///*** Added for Gorilla Glass Implementation ***///
///*** Corning IT - 2/24/2017 ***///
///*** Class to help specification trigger ***///
public class SpecToProductUtility{
    static Utilities Utils = new Utilities();
    
    //Product and price book entry created after spec is pricing approved
    public static void CreateProductAndPricebookEntry(List<Specification__c> specsToCreateProductsFor){
    
        // internal collections
        List<Id> pricebookIdList = new List<Id>();
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        List<Product2> newProductList = new List<Product2>();
        List<Price__c> productPriceList = new List<Price__c>();
        Map<String, Specification__c> specMap = new Map<String, Specification__c>();
        Boolean isCBG;
    
        // get standard and GG price books
        Id sdPriceBookId = [SELECT id FROM Pricebook2 WHERE isStandard=true LIMIT 1].id;
        Id ggPriceBookId = Utils.getGGPriceBookId();
        
        // create expiration date
        Date partExpDate = Date.today().addYears(2);
        Date concoreExpDate = Date.today().addDays(90);
        Date rawExpDate = Date.today().addDays(365);
        System.debug('specsToCreateProductsFor&&>' + specsToCreateProductsFor);     
        if (ggPriceBookId != null && sdPriceBookId != null){
        
            // store price book Ids for adding products
            pricebookIdList.add(sdPricebookId);
            pricebookIdList.add(ggPricebookId);
           
            for (specification__c s: specsToCreateProductsFor) {
            
                // build specMap for price lookup when adding price__c
                specMap.put(s.id, s); 

                // CSMSF-23 (Corning Bendable Glass)
                isCBG=false;
                if (s.Innovation_Type__c != null) {
                    for (String sIT : s.Innovation_Type__c.split(';')) {
                        if ( sIT == 'Corning Bendable Glass') {
                            isCBG=true;     // 
                        }
                    }
                }
                // create the product for the spec
                Product2 p2 = new Product2(
                    Name = s.productName__c,
                    Description = s.description__c,
                    Family = s.productLine__c,
                    glassComposition__c = s.glassComposition__c,
                    isInnovation__c = s.isInnovation__c,
                    isMTO__c = s.isMTO__c,
                    isStandard__c = s.isStandardOverride__c,
                    length__c = s.length__c,
                    moq__c = s.moq__c,
                    sampleMoq__c = s.sampleMoq__c,
                    moqUnits__c = s.moqUOM__c,
                    opportunity__c = s.opportunity__c,
                    sku__c = s.sku__c,
                    specification__c = s.id,
                    
                    thickness__c = s.thickness__c,
                    width__c = s.width__c,
                    IsActive = true,
                    ctLevel__c = s.ctLevel__c,
                    specialShapes__c = s.specialShapes__c,
                    specialRequirements__c = s.specialRequirements__c,
                    includeCorningPackaging__c = s.includeCorningPacking__c,
                    maximumCrateDimensions__c = s.maximumCrateDimensions__c,
                    sheetsPerCrate__c = s.estimatedCrateSheetCount__c,
                    CanUseQuantitySchedule = True,
                    CanUseRevenueSchedule = True,
                    isPhyllo__c = isCBG                                       
                );
                // packingOption__c = s.packingOption__c;
                
                // add product to list
                newProductList.add(p2);
            }
            
            insert newProductList;
            system.debug('***** ' + newProductList.size() + ' Products created *****');
            
            // query post insert product2 table
            List<Product2> insertedProductList = [SELECT id, name, glassComposition__c, Length__c, 
                                                   Width__c, Thickness__c, Opportunity__c, Specification__c 
                                                   , Specification__r.Name 
                                                   , Opportunity__r.programName__c 
                                                   , Specification__r.specialRequirements__c 
                                      			   , Specification__r.squareFeet__c
                                                   , Opportunity__r.customerProductModelName__c
                                                   , Specification__r.productCode__c
                                                   , Specification__r.generalComments__c
                                                   FROM Product2 
                                                   WHERE id IN :newProductList];
            
            // map prodcut name to ID for price lookup
            Map<Id, String> productNameMap = new Map<Id, String>();
            for(Product2 p2 : insertedProductList) {
                productNameMap.put(p2.id, p2.name + ';' + p2.Id); //productNameMap.put(p2.id, p2.name); 
            }
           
            //Added 4/12/2017 MPARRA - Salesforce Services
            sendNotificationEmail(insertedProductList);
            //End
            
            // Loop through inserted products
            for(Product2 prod : newProductList) {
                        
                // get specification for this product
                specification__c specLookup = specMap.get(prod.specification__c);
            
                // determine if blue account
                Boolean isBLue = Utils.isBlueOptyOrQuote(String.valueOf(specLookup.opportunity__c));  
               
                // add product to standard and GG price books
                for(Integer i = 0; i < 2; i++){
                    PricebookEntry pbe = new PricebookEntry(
                        Pricebook2Id = pricebookIdList.get(i),
                        IsActive = true,
                        Product2Id = prod.Id,
                        UnitPrice = 1,
                        UseStandardPrice = false
                    );
                    // add price book entry to list
                    pbeList.add(pbe);
                }
                
                // create the pricing for all product lines
                Price__c p = new Price__c(
                    product__c = prod.id,
                    account__c = specLookup.account__c
                );
                
                if (isBlue) {
                    p.availableTo__c = 'Blue Only';
                    p.unitPrice__c = specLookup.unitCostSqFt__c;
                    p.shippingPrice__c = specLookup.shippingCostSqFt__c;
                    p.priceUnit__c = specLookup.unitCostSqFt__c + specLookup.shippingCostSqFt__c;
                    p.originalPriceUnit__c = specLookup.unitCostSqFt__c + specLookup.shippingCostSqFt__c;
                } else {
                    p.availableTo__c = 'All Customers';
                    p.unitPrice__c = (((specLookup.unitCostSqFt__c * (((specLookup.width__c * specLookup.length__c)/25.4)/25.4)/144)).setScale(4)).setScale(2); // use scale of 4 for sqare feet calculation; convert final number to scale of 2
                    p.shippingPrice__c = (((specLookup.shippingCostSqFt__c * (((specLookup.width__c * specLookup.length__c)/25.4)/25.4)/144)).setScale(4)).setScale(2); // use scale of 4 for sqare feet calculation; convert final number to scale of 2
                    p.priceUnit__c = ((((specLookup.unitCostSqFt__c + specLookup.shippingCostSqFt__c) * (((specLookup.width__c * specLookup.length__c)/25.4)/25.4)/144)).setScale(4)).setScale(2); // use scale of 4 for sqare feet calculation; convert final number to scale of 2
                    p.originalPriceUnit__c = ((((specLookup.unitCostSqFt__c + specLookup.shippingCostSqFt__c) * (((specLookup.width__c * specLookup.length__c)/25.4)/25.4)/144)).setScale(4)).setScale(2); // use scale of 4 for sqare feet calculation; convert final number to scale of 2
                }
                System.debug('specLookup.productLine__c ' + specLookup.productLine__c);
                // set product line specific fields
                if (specLookup.productLine__c == 'Parts') {
                    p.extId__c = specLookup.id + productNameMap.get(prod.id);
                    p.priceExpirationDate__c = partExpDate;
                    p.ownerid = specLookup.ownerid__c; // opportunity owner
                    p.price1__c = specLookup.price1__c;
                    p.price2__c = specLookup.price2__c;
                    p.price3__c = specLookup.price3__c;
                    p.price4__c = specLookup.price4__c;
                    p.originalPrice1__c = specLookup.price1__c;
                    p.originalPrice2__c = specLookup.price2__c;
                    p.originalPrice3__c = specLookup.price3__c;
                    p.originalPrice4__c = specLookup.price4__c;                    
                    p.upperLimit1__c = specLookup.upperLimit1__c;
                    p.upperLimit2__c = specLookup.upperLimit2__c;
                    p.upperLimit3__c = specLookup.upperLimit3__c;
                    p.upperLimit4__c = specLookup.upperLimit4__c;
                    p.samplePrice__c = specLookup.samplePrice__c;
                    p.originalSamplePrice__c = specLookup.samplePrice__c;
                } else if (specLookup.productLine__c == 'Concore') {
                    p.extId__c = specLookup.account__c + productNameMap.get(prod.id); 
                    p.priceExpirationDate__c = concoreExpDate;
                    p.ownerid = specLookup.accountownerid__c; // spec account lookup owner                   
                    p.unit__c = specLookup.unit__c;
                    p.priceIncludesShipping__c = specLookup.priceIncludesShipping__c;
                    p.unitPrice__c = (specLookup.unitCostSqFt__c * (((specLookup.width__c * specLookup.length__c)/25.4)/25.4)/144);
                    p.shippingPrice__c = (specLookup.shippingCostSqFt__c * (((specLookup.width__c * specLookup.length__c)/25.4)/25.4)/144);
                    p.priceUnit__c = specLookup.priceUnit__c;
                } else if (specLookup.productLine__c == 'Raw Glass' && specLookup.isMTO__c == FALSE) {
                    p.extId__c = specLookup.account__c + productNameMap.get(prod.id);  
                    p.priceExpirationDate__c = rawExpDate;
                    p.ownerid = specLookup.accountownerid__c; // spec account lookup owner                    
                    p.priceIncludesShipping__c = specLookup.priceIncludesShipping__c;
                } else if (specLookup.productLine__c == 'Raw Glass' && specLookup.isMTO__c == TRUE) { // MTO
                    p.extId__c = specLookup.id + productNameMap.get(prod.id);  
                    p.priceExpirationDate__c = rawExpDate;
                    p.ownerid = specLookup.accountownerid__c; // spec account lookup owner                    
                    p.priceIncludesShipping__c = specLookup.priceIncludesShipping__c;
                }
                
                System.debug('Price Expiration Date ' +  p.priceExpirationDate__c);
                // add price to list  
                productPriceList.add(p);
            }

            insert pbeList; 
            system.debug('***** Price book entries created *****');
            
            insert productPriceList;
            system.debug('***** Prices created *****');
            
            // ALN 12/7/2017 - auto add the product to the opportunity - query the products and prices
            List<Product2> addProductToOpportunityList = [SELECT id, opportunity__c FROM Product2 WHERE id IN :newProductList];
            
            List<Price__c> priceList = [SELECT id, product__c FROM Price__c WHERE product__c IN :newProductList];
            
            if (!addProductToOpportunityList.isEmpty()) {

                // map product ID to opp ID
                Map<Id, Id> productOppMap = new Map<Id, Id>();
                for(Product2 p2 : addProductToOpportunityList) {
                    productOppMap.put(p2.id, p2.opportunity__c);
                }
            
                Map<Id, List<Id>> productToPricesMap = new Map<Id, List<Id>>();
                for(Price__c p : priceList) {
                  
                    if(productToPricesMap.containsKey(p.product__c)) {
                        List<Id> pricesId = productToPricesMap.get(p.product__c);
                        pricesId.add(p.Id);
                        productToPricesMap.put(p.product__c, pricesId);
                    } else {
                        productToPricesMap.put(p.product__c, new List<Id> { p.Id });
                    }  
                  
                }
            
                // Loop through map and add OLI
                for ( ID mapID : productToPricesMap.keySet() ) {
                    SpecToProductUtility.addProducts(String.valueOf(productOppMap.get(mapID)), String.join(productToPricesMap.get(mapID), ','));                   
                }
            
            } 
        }
        
    }

    //ALN 12/7/2017 - auto add the product to the opportunity 
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
        return null;
    } 
    
    //Added 4/12/2017 MPARRA - Salesforce Services
    @testVisible
    public static void sendNotificationEmail(list <Product2> newProducts) {
        set<Id> oppIdSet = new set<Id>();
        map<Id,Id> productOpportunityMap = new map<Id,Id>();
        list<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        
        system.debug('sendNotificationEmail');
        
        for (Product2 prod : newProducts) {
            oppIdSet.add(prod.Opportunity__c);
            productOpportunityMap.put(prod.Id,prod.Opportunity__c);
        }
        
        map<Id,Opportunity> 
            oppIdMap = new map<Id, Opportunity>([SELECT Id, Name, OwnerId, 
                                                  (SELECT UserId 
                                                    FROM OpportunityTeamMembers) 
                                                 FROM Opportunity 
                                                 WHERE Id IN :oppIdSet]);
        for (Product2 newProduct : newProducts) {
            List<string> sendTo = new List<String>(); 
            Id oppId = productOpportunityMap.get(newProduct.Id);
            Opportunity theOpp = oppIdMap.get(oppId);
            sendTo.add(theOpp.OwnerId);
            //sendTo.add('atasuperfusion@gmail.com');
            //If there are Team Members to send to
            //if (theOpp.OpportunityTeamMembers.size() > 0) {
                //Build sendTo list
                if(theOpp.OpportunityTeamMembers.size() > 0)
                for (OpportunityTeamMember theOppTeamMember : theOpp.OpportunityTeamMembers){
                    sendTo.add(theOppTeamMember.UserId);
                }
                //Build messages and add to mailing list
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                
                mail.setToAddresses(sendTo);
                mail.setSubject('New Product Created for ' + theOpp.Name);
                mail.setHtmlBody(buildEmailBody(newProduct));
                //mail.setSenderDisplayName('Do Not Reply');
                emailMessages.add(mail);
            //}
            //else {
                //newProduct.addError('No addresses to send to');
                //system.debug ('No addresses to send to');
            //}
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
    
    //Added 4/12/2017 MPARRA - Salesforce Services
    @testVisible
    private static string buildEmailBody (Product2 theProduct) {        
        /*string body = '<B>Name: </B>' + theProduct.Name + ' <BR/>';
        body += '<B>Glass Composition: </B> ' +  theProduct.glassComposition__c + '<BR/>';
        body += '<B>Length: </B> ' + theProduct.Length__c + '<BR/>';
        body += '<B>Width:</B> ' + theProduct.Width__c + '<BR/>';
        body += '<B>Thickness: </B> ' + theProduct.Thickness__c + '<BR/>';
        
        //body += '<B>Link: </B><A href="'+System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + theProduct.Id + '" >Product</A>';
        body += '<B>Link: </B><A href="'+ System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + theProduct.Opportunity__c + '">Opportunity</A><BR/>';
        body += '<B>Link: </B><A href="'+ System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + theProduct.Specification__c + '" >Specification</A><BR/>';
        body += '<B>Specification Id: </B> ' + theProduct.Specification__r.Name + '<BR/>';*/
        string body = '<B>Program Name: </B>' + checkNullString(theProduct.Opportunity__r.customerProductModelName__c) + ' <BR/>';
        body += '<B>Specification Id: </B> ' + checkNullString(theProduct.Specification__r.Name) + '<BR/>';
        body += '<B>Product Description: </B> ' + checkNullString(theProduct.Name) + '<BR/>';
        body += '<B>Special Requirements: </B> ' + checkNullString(theProduct.Specification__r.specialRequirements__c) + '<BR/>'; 
        body += '<B>Square Feet (1 Piece): </B> ' +  checkNullString(String.valueOf(theProduct.Specification__r.squareFeet__c)) + '<BR/>';
        body += '<B>Product Code: </B> ' +  checkNullString(theProduct.Specification__r.productCode__c) + '<BR/>';
        body += '<B>General Comments: </B> ' +  checkNullString(theProduct.Specification__r.generalComments__c) + '<BR/><BR/>';
        
        body += '<B>Link: </B><A href="'+ System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + theProduct.Opportunity__c + '">Opportunity</A><BR/>';
        body += '<B>Link: </B><A href="'+ System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + theProduct.Specification__c + '" >Specification</A><BR/>';
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
}