///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 4/18/2017 ***///
///*** Class to test price trigger ***///

@isTest
private class PriceTriggerHelperTest {
    static TestUtilities tUtils = new TestUtilities();
    private static string acctRT;
    private static string oppRT;
    private static string oppRT2;
    private static string quoteRT;
    private static string profileId;
    private static string profileId2;
    private static string profileId3;
    private static string roleId;
    private static string roleId2;
    
    static {
        acctRT = tUtils.getRecordTypeId('Account', 'GG Account');
        roleId = tUtils.getRoleId('GG Sales Mgr Americas/EMEA');
    }
    
    static testMethod void setAvailableToTest() {
        // TO DO: implement unit test
        
    }
    
    static testMethod void setIsMtoTest() {
        User ta;
        
        tUtils.SetTriggersOnForTesting();
        
        Account a = tUtils.addTestAccount(acctRT);
        Account tpm = tUtils.createTestAccount(acctRT);
        tpm.containsPricing__c = true;
        insert tpm;
        Account finisher = tUtils.createTestAccount(acctRT);
        finisher.containsPricing__c = true;
        insert finisher;
        
	    List<Product2> prods = new List<Product2>();
        List<PricebookEntry> priceentries = new List<PricebookEntry>();
          
        prods.add(new Product2(Name = 'Test raw glass', Family = Label.GGProductTypeRaw, isStandard__c = true, isActive=true, isMTO__c = false));   
        prods.add(new Product2(Name = 'Test raw glass', Family = Label.GGProductTypeRaw, isStandard__c = true, isActive=true, isMTO__c = true));   
        prods.add(new Product2(Name = 'Test concore', Family = Label.GGProductTypeConcore, isStandard__c = false, isActive=true, isMTO__c = false));   
        prods.add(new Product2(Name = 'Test concore', Family = Label.GGProductTypeConcore, isStandard__c = false, isActive=true, isMTO__c = true)); 
        insert prods;
	        
        test.startTest();
	        List<Price__c> prices = new List<Price__C>();
	        Price__c pr;
	        integer i = 1;
	        for (Product2 p: prods){
	            if (p.Family == Label.GGProductTypeRaw){
	                pr = new Price__c(Product__c = p.Id, PriceUnit__c = 5*i);
	                pr.Account__c = finisher.Id;
	                prices.add(pr);
	                
	                pr = new Price__c(Product__c = p.Id, PriceUnit__c = 6*i);
	                pr.Account__c = tpm.Id;
	                prices.add(pr);
	            }
	            if (p.Family == Label.GGProductTypeConcore){
	                pr = new Price__c(Product__c = p.Id, PriceUnit__c = 5*i);
	                pr.Account__c = tpm.Id;
	                prices.add(pr);
	            }
	            i++;
	        }
	        insert prices;
	        
	        system.assertEquals (3,[SELECT Count() FROM Price__c WHERE isMTO__c = true AND Product__c IN :Prods]);
	        system.assertEquals (2,[SELECT Count() FROM Price__c WHERE productFamily__c = :Label.GGProductTypeConcore AND Product__c IN :Prods]);
	        system.assertEquals (4,[SELECT Count() FROM Price__c WHERE productFamily__c = :Label.GGProductTypeRaw AND Product__c IN :Prods]);
    	test.stopTest();
    }
}