///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 3/14/2017 ***///
///*** Class to help Price trigger ***///
//This class shouldn't be run "with sharing" since the MTO flag, product family values, availableTo are set on price trigger
//The price trigger is executed in the PLM user. 
public /*with sharing*/ class PriceTriggerHelper {
    static Utilities Utils = new Utilities();
    
     public static void setAvailableTo(List<Price__c> priceRecs){ 
        map <id,Price__c> priceMap = new map<id,Price__c>();
        set <id> accountOwnerIdSet = new set<id>();
        set <id> specificationIdSet = new set<id>();
        map<id,id> specToPriceMap = new map<id,id>();
        map<id,id> userToPriceMap = new map<id,id>();
        
        for (Price__c price : priceRecs){
            priceMap.put(price.id,price);
        }
        
        //Create list of Price records with the related values we need to test
        list<Price__c> screeningList = [SELECT Id, Account__c, Account__r.OwnerId, Product__c, 
                                        Product__r.Specification__c
                                    FROM Price__c
                                    WHERE Id IN :priceMap.Keyset()]; 
        
        for (Price__c screen : screeningList){
            //Separate those with Specification values from those without 
            if (screen.Product__r.Specification__c <> null){
                //Create set of User Id's to query and create map to link Users to Prices
                specificationIdSet.add(screen.Product__r.Specification__c);
                specToPriceMap.put(screen.Product__r.Specification__c,screen.id);
            }
            else {
                //completely exclude those with no Spec OR Account      
                if (screen.Account__c <> null) {
                    //Create set of User Id's to query and create map to link Users to Prices
                    accountOwnerIdSet.add(screen.Account__r.OwnerId);
                    userToPriceMap.put(screen.Account__r.OwnerId,screen.id);
                }
                else {
                    //Do nothing
                }
            }
        }
        
        //Retrieve custom settings
        map<string,string> pricingMap = new map<string,string>();
        for (GG_Blue_Pricing_Settings__c setting : [SELECT ownerRole__c, availableTo__c FROM GG_Blue_Pricing_Settings__c]){
            pricingMap.put(setting.ownerRole__c,setting.availableTo__c); 
        }

        //Run the User query and Update AvailableTo based on Setting value
        for (User theUser : [SELECT Id, UserRole.Name FROM User WHERE Id IN :accountOwnerIdSet]) {
            if (pricingMap.keyset().contains(theUser.UserRole.Name)){
                //Update the incoming instance of the Price record with the correct value
                priceMap.get(userToPriceMap.get(theUser.Id)).availableTo__c = pricingMap.get(theUser.UserRole.Name);
            }
        }
        
        //Run the Spec query and Update AvailableTo based on Setting value
        for (Specification__c theSpec : [SELECT Id, Opportunity__r.Owner_Role__c FROM Specification__c WHERE Id IN :specificationIdSet]) {
            if (pricingMap.keyset().contains(theSpec.Opportunity__r.Owner_Role__c)){
                //Update the incoming instance of the Price record with the correct value
                priceMap.get(specToPriceMap.get(theSpec.Id)).availableTo__c = pricingMap.get(theSpec.Opportunity__r.Owner_Role__c);
            }
        }           
    }
     
    public static void setIsMTO(List<Price__c> priceRecs){ 
        map <id,Price__c> priceMap = new map<id,Price__c>();
        
        for (Price__c price : priceRecs){
            priceMap.put(price.id,price);
        }
        
        //Create list of Price records with the related values we need to test
        list<Price__c> screeningList = [SELECT Id, Product__c, Product__r.family, Product__r.isMTO__c
                                    FROM Price__c
                                    WHERE Id IN :priceMap.Keyset()]; 
                                    
        for (Price__c screeningRec : screeningList) {
            Price__c recToUpdate = priceMap.get(screeningRec.id);
            recToUpdate.productFamily__c = screeningRec.Product__r.family;
            if (screeningRec.Product__r.isMTO__c == true) {
                recToUpdate.isMto__c = true;
            }   
        }
    }
    
    public static void setSpecPricing(List<Price__c> priceRecs) { 

        system.debug('*** priceRecs: ' + priceRecs.size());

        set <Id> specSet = new set<Id>();
        map <Id, Price__c> specMap = new map<Id, Price__c>();

        // filter out non-parts
        for (Price__c p : priceRecs) {
            system.debug('*** ' + p.id + ' | ' + p.productFamily__c);
            if (p.productFamily__c == 'Parts' && p.specification__c != Null) {
                ID i = Id.valueOf(p.specification__c);
                specSet.add(i);
                specMap.put(i,p);
            }
        }
        
        // query the assoiated specs
        list<Specification__c> specList = [SELECT Id, currentSamplePrice__c, currentPrice1__c, currentPrice2__c, currentPrice3__c, currentPrice4__c, mpQuotePrice1__c, mpQuotePrice2__c, mpQuotePrice3__c, mpQuotePrice4__c
                                    FROM Specification__c WHERE Id IN :specSet];
        
        // update the spec with current pricing
        for (Specification__c s : specList) {
            s.currentPrice1__c = specMap.get((ID)s.id).price1__c; 
            s.currentPrice2__c = specMap.get((ID)s.id).price2__c;
            s.currentPrice3__c = specMap.get((ID)s.id).price3__c;
            s.currentPrice4__c = specMap.get((ID)s.id).price4__c;
            s.currentSamplePrice__c = specMap.get((ID)s.id).samplePrice__c;
            s.mpQuotePrice1__c = specMap.get((ID)s.id).mpQuotePrice1__c; 
            s.mpQuotePrice2__c = specMap.get((ID)s.id).mpQuotePrice2__c;
            s.mpQuotePrice3__c = specMap.get((ID)s.id).mpQuotePrice3__c;
            s.mpQuotePrice4__c = specMap.get((ID)s.id).mpQuotePrice4__c;
        }

        update specList;                        
 
    }
}