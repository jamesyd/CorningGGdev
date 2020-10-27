///*** Added for Gorilla Glass Implementation ***///
///*** Corning IT - 4/3/2017 ***///
///*** Class to help standard product inventory loader trigger ***///

public class StandardProductDataToProductUtility{
    static Utilities Utils = new Utilities();
    
    //Product and price book entry created after spec is pricing approved
    public static void createProductAndPricebookEntry(List<StandardProductInventoryLoader__c> dataToCreateProductsFor) {
    
        // internal collections
        List<Id> accountList = new List<Id>();
        List<Id> pricebookIdList = new List<Id>();
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        List<Product2> newProductList = new List<Product2>();
        List<Price__c> productPriceList = new List<Price__c>();
        
        // query standard product matrix 
        List<StandardProductInventoryMatrix__c> matrixList = [SELECT id, isActive__c, estimatedCrateSheetCount__c, glassComposition__c, customlength__c, maximumCrateDimensions__c, MOQ__c, moqUnits__c, productLine__c, shippingCostPerSqFt__c, thickness__c, customwidth__c FROM StandardProductInventoryMatrix__c WHERE isActive__c = True];
       
        // query existing active standard raw glass product2
        List<Product2> prod2List = [SELECT id, isActive, family, name, thickness__c, glassComposition__c, width__c, length__c FROM Product2 WHERE isActive = True and family = 'Raw Glass'];

        // map of existing products based on product name
        Map<String, Product2> productMap = new Map<String, Product2>();
        for(Product2 p2 : prod2List) {
             productMap.put(p2.name, p2);
        }

        // get list of accounts in the data set
        for (StandardProductInventoryLoader__c a: dataToCreateProductsFor) {
            accountList.add(a.account__c);
        }
        
        // query accounts for exclusiveAccountType__c
        List<account> aList = [SELECT id, exclusiveAccountType__c FROM account WHERE id IN :accountList];

        // map of account and exclusive status
        Map<Id, String> exclusiveAccountMap = new Map<Id, String>();
        for(account a2 : aList) {
             exclusiveAccountMap.put(a2.id, a2.exclusiveAccountType__c);
        }
       
        // get standard and GG price books
        Id sdPriceBookId = [SELECT id FROM Pricebook2 WHERE isStandard=true LIMIT 1].id;
        Id ggPriceBookId = Utils.getGGPriceBookId();
             
        if (ggPriceBookId != null && sdPriceBookId != null) {
        
            // store price book Ids for adding products
            pricebookIdList.add(sdPricebookId);
            pricebookIdList.add(ggPricebookId);
           
            // loop through new record data
            for (StandardProductInventoryLoader__c d: dataToCreateProductsFor) {
            
                String dataKey = d.productLine__c + d.thickness__c + d.glassComposition__c;
            
                // loop through the matrix and create a product for each record
                for (StandardProductInventoryMatrix__c m: matrixList) {
                
                    String matrixKey = m.productLine__c + m.thickness__c + m.glassComposition__c;
                    String productName = m.glassComposition__c+'; '+m.thickness__c+'mm; '+m.customwidth__c+'mm x '+m.customlength__c+'mm; '+m.productLine__c;
                                       
                    // create the product for each matrix match if the product does not exist
                    if (matrixKey == dataKey) {
                    
                        Product2 p2 = new Product2(
                            Name = productName,             
                            Family = m.productLine__c,
                            glassComposition__c = m.glassComposition__c,
                            length__c = m.customlength__c,
                            thickness__c = decimal.valueof(m.thickness__c),
                            width__c = m.customwidth__c,
                            IsActive = true,
                            isStandard__c = true,
                            moq__c = m.moq__c,
                            moqUnits__c = m.moqUnits__c,
                            sku__c = d.sku__c,
                            maximumCrateDimensions__c = m.maximumCrateDimensions__c,
                            sheetsPerCrate__c = m.estimatedCrateSheetCount__c
                        );
                        
                        // only add new products
                        if (!productMap.containsKey(productName)) {
                            newProductList.add(p2);
                        }

                    }           
                
                }
            
            } // End loop through new data to add incremental product2 records
            
            insert newProductList;
            system.debug('***** ' + newProductList.size() + ' Products created *****');

            // Loop through inserted products to create PBE
            for(Product2 prod : newProductList) {
            
                // add product to standard and GG price books
                for(Integer i = 0; i < 2; i++){
                    PricebookEntry pbe = new PricebookEntry(
                        Pricebook2Id = pricebookIdList.get(i),
                        IsActive = true,
                        Product2Id = prod.Id,
                        UnitPrice = 1
                    );
                    // add price book entry to list
                    pbeList.add(pbe);
                }               
            }
            
            insert pbeList; 
            system.debug('***** ' + pbeList.size() + ' Price book entries created *****');
     
            // query post insert product2 table
            List<Product2> expandedProd2List = [SELECT id, isActive, family, name FROM Product2 WHERE isActive = True and family = 'Raw Glass'];

            // map prodcut name to ID for price lookup
            Map<String, Id> priceProductMap = new Map<String, Id>();
            for(Product2 ep2 : expandedProd2List) {
                priceProductMap.put(ep2.name, ep2.id);
            }
            
            // second pass loop through new record data to upsert pricing using external ID
            for (StandardProductInventoryLoader__c r2d2: dataToCreateProductsFor) {
               
                String dataKey = r2d2.productLine__c + r2d2.thickness__c + r2d2.glassComposition__c;
                ID specificProduct = r2d2.standardProductInventoryMatrix__c;
                                                
                // loop through the matrix and create a product for each record
                for (StandardProductInventoryMatrix__c m2: matrixList) {
                
                    String matrixKey = m2.productLine__c + m2.thickness__c + m2.glassComposition__c;
                    String productName = m2.glassComposition__c+'; '+m2.thickness__c+'mm; '+m2.customwidth__c+'mm x '+m2.customlength__c+'mm; '+m2.productLine__c;                 
                    
                    if (matrixKey == dataKey) {
                    
                        // determine if blue account
                        Boolean isBlue = False;
                        // Boolean isBLue = Utils.isBlueAccount(String.valueOf(r2d2.account__c)); // SOQL limit issue with this line
                        if (exclusiveAccountMap.get(Id.valueOf(r2d2.account__c)) == 'Blue') {
                            isBlue = True;
                        } else {
                            isBlue = False;
                        }
                    
                        // create the pricing for all product lines
                        Price__c p = new Price__c(
                            product__c = priceProductMap.get(productName),
                            extId__c = r2d2.account__c + productName,
                            account__c = r2d2.account__c,                            
                            ownerid = r2d2.ownerid__c,
                            priceIncludesShipping__c = true
                        );
                      
                        // set sheet or sqft pricing, availableTo based on account
                        // Blue can set their own price on the quote
                        if (isBlue) {
                            p.availableTo__c = 'Blue Only';
                            p.unitPrice__c = 0; // r2d2.pricePerSqFt__c;
                            p.shippingPrice__c = 0; // m2.shippingCostPerSqFt__c;
                            p.priceUnit__c = 0; //r2d2.pricePerSqFt__c + m2.shippingCostPerSqFt__c;         
                            p.unit__c = 'Sq Ft';                   
                        } else {
                            p.availableTo__c = 'All Customers';    
                            p.unitPrice__c = (((r2d2.pricePerSqFt__c * (((m2.customwidth__c * m2.customlength__c)/25.4)/25.4)/144)).setScale(4)).setScale(2); // use scale of 4 for sqare feet calculation; convert final number to scale of 2

                            if (r2d2.customShippingPricePerSqFt__c != Null) {
                                p.shippingPrice__c = (((r2d2.customShippingPricePerSqFt__c * (((m2.customwidth__c * m2.customlength__c)/25.4)/25.4)/144)).setScale(4)).setScale(2); // use scale of 4 for sqare feet calculation; convert final number to scale of 2                            
                                p.priceUnit__c = ((((r2d2.pricePerSqFt__c + r2d2.customShippingPricePerSqFt__c) * (((m2.customwidth__c * m2.customlength__c)/25.4)/25.4)/144)).setScale(4)).setScale(2); // use scale of 4 for sqare feet calculation; convert final number to scale of 2
                            } else {
                                p.shippingPrice__c = (((m2.shippingCostPerSqFt__c * (((m2.customwidth__c * m2.customlength__c)/25.4)/25.4)/144)).setScale(4)).setScale(2); // use scale of 4 for sqare feet calculation; convert final number to scale of 2
                                p.priceUnit__c = ((((r2d2.pricePerSqFt__c + m2.shippingCostPerSqFt__c) * (((m2.customwidth__c * m2.customlength__c)/25.4)/25.4)/144)).setScale(4)).setScale(2); // use scale of 4 for sqare feet calculation; convert final number to scale of 2
                            }
                            
                            // p.shippingPrice__c = (((m2.shippingCostPerSqFt__c * (((Decimal.valueOf(m2.width__c) * Decimal.valueOf(m2.length__c))/25.4)/25.4)/144)).setScale(4)).setScale(2); // use scale of 4 for sqare feet calculation; convert final number to scale of 2                                
                            // p.priceUnit__c = ((((r2d2.pricePerSqFt__c + m2.shippingCostPerSqFt__c) * (((Decimal.valueOf(m2.width__c) * Decimal.valueOf(m2.length__c))/25.4)/25.4)/144)).setScale(4)).setScale(2); // use scale of 4 for sqare feet calculation; convert final number to scale of 2
                                
                            p.unit__c = 'Each';
                        }
                        
                        // set expiration date out 365 days if not provided in data load
                        system.debug('***' + r2d2.expirationDate__c);
                        if (r2d2.expirationDate__c == Null) {
                            p.priceExpirationDate__c = Date.today().addDays(365);
                        } else {
                            p.priceExpirationDate__c = r2d2.expirationDate__c;
                        }
                      
                        // add price to list  
                        if (specificProduct == Null) { // update all dimensions
                            productPriceList.add(p);
                        } else {
                            if (specificProduct == m2.id) { // only update for specific dimension
                                productPriceList.add(p);
                            }
                        }
                
                    }           
                
                }
                            
            } // End loop through new data to upsert incremental price records
            upsert productPriceList extId__c;
            system.debug('***** ' + productPriceList.size() + '  Prices updated *****');
            
        }
        
    }
    
}