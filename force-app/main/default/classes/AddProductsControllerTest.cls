/**
 * @File Name          : AddProductsControllerTest.cls
 * @Description        : 
 * @Author             : Adam Nicholson?
 * @Group              : 
 * @Last Modified By   : Arquimidez Mora
 * @Last Modified On   : 2/7/2020 12:39:57
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.1    1/7/2020   Arquimidez Mora            Fixing test class errors
**/
///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 2/13/2017 ***///
///*** Test class for Class to help Add Products Apex Controller for the Lightning component ***///

@isTest 
private class AddProductsControllerTest {
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
        oppRT = tUtils.getRecordTypeId('Opportunity', 'GG Program');
        oppRT2 = tUtils.getRecordTypeId('Opportunity', 'GG Parts Sample Request');
        quoteRT = tUtils.getRecordTypeId('Quote', 'GG Parts');
        profileId = tUtils.getProfileId('GG Account Manager');
        profileId2 = tUtils.getProfileId('GG Raw Glass Product Line Manager');
        profileId3 = tUtils.getProfileId('GG Parts Product Line Manager');
        roleId = tUtils.getRoleId('GG Sales Mgr Americas/EMEA');
        roleId2 = tUtils.getRoleId('GG Product Line Manager - Parts');
    }

    //sample opportunities are tied to program opportunity through a look up. So, the trigger tries to prevent 
    //someone with read access to a program opportunity from creating a sample opportunity unless they are on 
    //the team of the program opportunity.
    
    //Test add opportunity line item
    static testMethod void TestAddOpportunityLineItem() {
        User ta;
        
        tUtils.SetTriggersOnForTesting();
        
        User thisUser = [Select Id From User Where Id =: UserInfo.getUserId() ];
        system.runAs ( thisUser ) {
            ta = (tUtils.addTestUsers(profileId,1,roleId))[0];
        }
        
        system.runAs ( ta ) {
            Account a = tUtils.addTestAccount(acctRT);
            Account tpm = tUtils.createTestAccount(acctRT);
            tpm.containsPricing__c = true;
            insert tpm;
            Account finisher = tUtils.createTestAccount(acctRT);
            finisher.containsPricing__c = true;
            insert finisher;
            
            Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
            OpportunityTeamMember otm = tUtils.addTestOppTeamMember(o.id, ta.id, 'Account Manager');
            AddTestGGProductAndPriceBookEntry(o, tpm, finisher);
            
            List<Id> pIds = new List<Id>();
            integer i = 0;
            for (Price__c p : [SELECT Id FROM Price__c]){
                pIds.add(p.Id);
            }      
        
        test.startTest();
            OptyQuoteLIUtility util = new OptyQuoteLIUtility(o.Id, pIds);
            util.addLineItems();  
            Integer ct = Database.CountQuery('SELECT Count() FROM OpportunityLineItem WHERE OpportunityId =\'' + o.Id + '\'');
            System.assertEquals(ct,pIds.size());
        test.stopTest();
        }
    }
    
    //Test add quote line item
    static testMethod void TestAddQuoteLineItem() {
        User ta;
        
        tUtils.SetTriggersOnForTesting();
        
        User thisUser = [Select Id From User Where Id =: UserInfo.getUserId() ];
        system.runAs ( thisUser ) {
            ta = (tUtils.addTestUsers(profileId,1,roleId))[0];
        }
        
        system.runAs ( ta ) {        
            Account a = tUtils.addTestAccount(acctRT);
            Account tpm = tUtils.createTestAccount(acctRT);
            tpm.containsPricing__c = true;
            insert tpm;
            Account finisher = tUtils.createTestAccount(acctRT);
            finisher.containsPricing__c = true;
            insert finisher;
    
            Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
            Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
            o2.MassProductionOpportunity__c = o.id;
            o2.pricingAssignmentComplete__c = true;
            insert o2;
            OpportunityTeamMember otm = tUtils.addTestOppTeamMember(o2.id, ta.id, 'Account Manager');
            AddTestGGProductAndPriceBookEntry(o, tpm, finisher);
            
            List<Id> pIds = new List<Id>();
            for (Price__c p : [SELECT Id FROM Price__c]){ 
                pIds.add(p.Id);
            } 
            
            Account requestingAccount = tUtils.addTestAccount(acctRT);
            Quote q = tUtils.addTestQuote(requestingAccount.Id, o2.Id, quoteRT);
            
            test.startTest();
                OptyQuoteLIUtility util = new OptyQuoteLIUtility(q.Id, pIds);
                util.addLineItems();
                Integer ct = Database.CountQuery('SELECT Count() FROM QuoteLineItem WHERE QuoteId =\'' + q.Id + '\'');
                System.assertEquals(7,ct);
            test.stopTest();
        }
    }
    
    //Test add quote line item
    static testMethod void TestSearchProducts() {
        tUtils.SetTriggersOnForTesting();
        User ta = (tUtils.addTestUsers(profileId,1))[0];
        
        Account a = tUtils.addTestAccount(acctRT);
        Account tpm = tUtils.createTestAccount(acctRT);
        tpm.containsPricing__c = true;
        insert tpm;
        Account finisher = tUtils.createTestAccount(acctRT);
        finisher.containsPricing__c = true;
        insert finisher;
        
        Opportunity o = tUtils.addTestOppt(a.Id, oppRT);
        
        OpportunityTeamMember otm = tUtils.addTestOppTeamMember(o.id, ta.id, 'Account Manager');
        AddTestGGProductAndPriceBookEntry(o, tpm, finisher);
        
        Opportunity optyWithSupplyChain = tUtils.addTestOppt(a.Id,oppRT);
        List<Opportunity> os = new List<Opportunity>();
        o.OwnerId = ta.Id;
        optyWithSupplyChain.OwnerId = ta.Id;
        update os;
        
        tUtils.addSupplychain(optyWithSupplyChain.Id, tpm.Id, finisher.Id);
        
        List<Id> pIds = new List<Id>();
        for (Price__c p : [SELECT Id FROM Price__c]){ 
            pIds.add(p.Id);
        } 
        
        Account requestingAccount = tUtils.addTestAccount(acctRT);
        Opportunity o3 = tUtils.addTestOppt(a.Id, oppRT2, false);
        o3.pricingAssignmentComplete__c = true;
        insert o3;
        Quote q = tUtils.addTestQuote(requestingAccount.Id, o3.Id, quoteRT);

        System.debug('supply chain count: ' + Database.countquery('select count() from supplychain__c'));
          
        //parts search with match for name
        ProductSearchWrapper wrapper;
        wrapper = AddProductsController.searchProducts(o.Id, Label.GGProductTypeParts, 'part', 0, false, 1, false, false, false);
        System.assert(wrapper.totalRecordCount == 1);
          
        //parts search with no match for name
        wrapper = AddProductsController.searchProducts(o.Id, Label.GGProductTypeParts, 'raw', 0, false, 1, false, false, false);
        System.assert(wrapper.totalRecordCount == 0);

        //raw search without supply chain          
        wrapper = AddProductsController.searchProducts(o.Id, Label.GGProductTypeRaw, 'part', 0, false, 1, false, false, false);
        System.assert(wrapper.totalRecordCount == 0);
          
        //raw search without supply chain - returns all standard raw products
        wrapper = AddProductsController.searchProducts(o.Id, Label.GGProductTypeRaw, 'Test', 0, false, 1, false, false, false);
        System.assert(wrapper.totalRecordCount == 2);
          
        //raw search restricted for supply chain but optty doesn't have supply chain defined - nothing returned
        wrapper = AddProductsController.searchProducts(o.Id, Label.GGProductTypeRaw, 'Test', 0, true, 1, false, false, false);
        System.assert(wrapper.totalRecordCount == 0);
          
        //raw search restricted for supply chain with optty that has supply chain defined - 2 standard products returned
        wrapper = AddProductsController.searchProducts(optyWithSupplyChain.Id, Label.GGProductTypeRaw, 'Test', 0, true, 1, false, false, false);
        System.assert(wrapper.totalRecordCount == 2);
          
        //concore search restricted for supply chain returns 1 product
        wrapper = AddProductsController.searchProducts(o.Id, Label.GGProductTypeConcore, 'concore', 0, false, 1, false, false, false);
        System.assert(wrapper.totalRecordCount == 1);
    }
        
    static void AddTestGGProductAndPriceBookEntry(Opportunity opty, Account tpm, Account finisher){
        // First, set up test price book entries.
        // Insert a test product.
        List<Product2> prods = new List<Product2>();
        List<PricebookEntry> priceentries = new List<PricebookEntry>();
        
        if (opty != null){
            prods.add(new Product2(Name = 'Test part ' + opty.Id, Family = Label.GGProductTypeParts, Opportunity__c = opty.Id));   
        }
        
        prods.add(new Product2(Name = 'Test glass', Family = Label.GGProductTypeRaw, isStandard__c =true));   
        prods.add(new Product2(Name = 'Test concore', Family = Label.GGProductTypeConcore, Opportunity__c = opty.Id, isStandard__c = false)); 
            
        insert prods;
        
        List<Price__c> prices = new List<Price__C>();
        Price__c pr;
        integer i = 1;
        for (Product2 p: prods){
            
            if (p.Family == Label.GGProductTypeParts){
                pr = new Price__c(Product__c = p.Id, Price1__c = 1*i,Price2__c = 2*i,
                                        price3__c = 3*i,price4__c=4*i, upperlimit1__c=10*i, upperlimit2__c=20*i, upperlimit3__c=30*i, upperlimit4__c=40*i);    
                prices.add(pr);
            }
            else if (p.Family == Label.GGProductTypeRaw){
                pr = new Price__c(Product__c = p.Id, PriceUnit__c = 5*i);
                pr.unitPrice__c = pr.PriceUnit__c;
                pr.shippingPrice__c = 0;
                pr.Account__C = finisher.Id;
                prices.add(pr);
                pr = new Price__c(Product__c = p.Id, PriceUnit__c = 6*i);
                pr.Account__C = tpm.Id;
                pr.unitPrice__c = pr.PriceUnit__c;
                pr.shippingPrice__c = 0;
                prices.add(pr);
            }else{
                pr = new Price__c(Product__c = p.Id, PriceUnit__c = 5*i);
                pr.unitPrice__c = pr.PriceUnit__c;
                pr.shippingPrice__c = 0;
                pr.Account__C = tpm.Id;
                prices.add(pr);
            }
            i++;
        }
        
        insert prices;
        
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();
                // Create a custom price book
        //Pricebook2 customPB = new Pricebook2(Name='GG Price Book', isActive=true);
        //insert customPB;

        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        integer iInt = 1;
        for (Product2 p: prods){
            priceentries.add(new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = p.Id,
                UnitPrice = iInt*10, IsActive = true));
        }
        
        // 2. Insert a price book entry with a custom price.
        iInt = 10;
        for (Product2 p: prods){
            // priceentries.add(new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = p.Id, UnitPrice = iInt*10, IsActive = true)); // AN 1/31/18 wrong pricebook than opp error
            priceentries.add(new PricebookEntry(Pricebook2Id = '01so0000004gBaQAAU', Product2Id = p.Id, UnitPrice = iInt*10, IsActive = true));        
        }
        
        insert priceentries;
    }
    
    static testMethod void currentRecordInfoWrapperTestOpp (){
        tUtils.SetTriggersOnForTesting();
        User ta = (tUtils.addTestUsers(profileId,1))[0];
        
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
        o2.MassProductionOpportunity__c = o.id;
        insert o2;
        
        AddProductsController.currentRecordInfoWrapper wrap = new AddProductsController.currentRecordInfoWrapper(o2.Id); 
        system.assertEquals(true, wrap.isSampleOpportunity);
    }
    
    static testMethod void currentRecordInfoWrapperTestQuote (){
        tUtils.SetTriggersOnForTesting();
        User ta = (tUtils.addTestUsers(profileId,1))[0];
        
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT2, false);
        o.pricingAssignmentComplete__c = true;
        insert o;
        Quote q = tUtils.addTestQuote(a.Id, o.Id, quoteRT);
        
        AddProductsController.currentRecordInfoWrapper wrap = new AddProductsController.currentRecordInfoWrapper(q.Id); 
        system.assertEquals(true, wrap.isQuote);
    }
    
    static testMethod void ProductTypesTest (){
        tUtils.SetTriggersOnForTesting();
        User ta = (tUtils.addTestUsers(profileId,1))[0];
        
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT2, false);
        o.pricingAssignmentComplete__c = true;
        insert o;
        Quote q = tUtils.addTestQuote(a.Id, o.Id, quoteRT);
        
        AddProductsController.currentRecordInfoWrapper wrap = new AddProductsController.currentRecordInfoWrapper(q.Id); 
        system.assertEquals(Label.GGProductTypeRaw, wrap.rawProductType);
        system.assertEquals(Label.GGProductTypeConcore, wrap.concoreProductType);
        system.assertEquals(Label.GGProductTypeParts, wrap.partsProductType);
    }
    
    static testMethod void LineItemsSaveResultsTest (){
        AddProductsController.LineItemsSaveResults theResults = new AddProductsController.LineItemsSaveResults();
        
        AddProductsController.LISaveResult theResult1 = new AddProductsController.LISaveResult();
        theResult1.success = true;
        theResult1.message = 'Hello World';
        theResults.liSaveMessages.add(theResult1);
        
        AddProductsController.LISaveResult theResult2 = new AddProductsController.LISaveResult();
        theResult2.success = false;
        theResult2.message = 'Uh oh';
        theResults.liSaveMessages.add(theResult2);

        AddProductsController.LISaveResult theResult3 = new AddProductsController.LISaveResult();
        theResult3.success = true;
        theResult3.message = 'Happy Days are Here Again';
        theResults.liSaveMessages.add(theResult3);
        
        system.AssertEquals(3, theResults.liSaveMessages.size());
        system.AssertEquals(false, theResults.liSaveMessages[1].success); 
    }
    
    static testMethod void getMTOSpecProductsTest(){
        
    }
    
    static testMethod void addProductsTest(){
        User ta;
        
        tUtils.SetTriggersOnForTesting();
        
        User thisUser = [Select Id From User Where Id =: UserInfo.getUserId() ];
        system.runAs ( thisUser ) {
            ta = (tUtils.addTestUsers(profileId,1,roleId))[0];
        }
        
        system.runAs ( ta ) {
            Account a = tUtils.addTestAccount(acctRT);
            Account tpm = tUtils.createTestAccount(acctRT);
            tpm.containsPricing__c = true;
            tpm.accountType__c = 'TPM';
            insert tpm;
            Account finisher = tUtils.createTestAccount(acctRT);
            finisher.containsPricing__c = true;
            insert finisher;
            
            Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
            OpportunityTeamMember otm = tUtils.addTestOppTeamMember(o.id, ta.id, 'Account Manager');
            tUtils.AddTestGGProductAndPriceBookEntry(o, tpm, finisher);
            
            string pIdStr = '';
            for (Price__c p : [SELECT Id FROM Price__c]){
                pIdStr += p.Id + ',';
            }
            pIdStr = pIdStr.substring(0,pIdStr.length() -1);
            
            Utilities.DMLResult res = new Utilities.DMLResult();
            res = AddProductsController.AddProducts (o.Id, pIdStr);
            
            system.assertEquals(true, res.success);
        }      
    }
    
    /*
    static testMethod void scheduleOpptyLineItemsTest() {
        User ta;
        
        tUtils.SetTriggersOnForTesting();
        
        User thisUser = [Select Id From User Where Id =: UserInfo.getUserId() ];
        system.runAs ( thisUser ) {
            ta = (tUtils.addTestUsers(profileId,1,roleId))[0];
        }
        
        system.runAs ( ta ) {
            Account a = tUtils.addTestAccount(acctRT);
            Account tpm = tUtils.createTestAccount(acctRT);
            tpm.containsPricing__c = true;
            insert tpm;
            Account finisher = tUtils.createTestAccount(acctRT);
            finisher.containsPricing__c = true;
            insert finisher;
            
            Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
            OpportunityTeamMember otm = tUtils.addTestOppTeamMember(o.id, ta.id, 'Account Manager');
            tUtils.AddTestGGProductAndPriceBookEntry(o, tpm, finisher);
            
            List<Id> pIds = new List<Id>();
            integer i = 0;
            for (Price__c p : [SELECT Id FROM Price__c]){
                pIds.add(p.Id);
            }      

            OptyQuoteLIUtility util = new OptyQuoteLIUtility(o.Id, pIds);
            util.addLineItems();
            
            list<OpportunityLineItem> oliList = new list<OpportunityLineItem>();
            
            oliList = [SELECT Id, Quantity, OpportunityId, ServiceDate, UnitPrice, PriceBookEntryId, Product2Id 
                        FROM OpportunityLineItem WHERE OpportunityId = :o.Id]; 
            
            for (OpportunityLineItem oli : oliList){
                oli.ServiceDate = date.today().addDays(1);
            }
            update oliList;
            
            string strSobjects = ' ';   
            strSobjects = JSON.serialize(oliList);
            system.debug('strSobjects: ' + strSobjects); 
        
            Utilities.DMLResult res = new Utilities.DMLResult();
            res = AddProductsController.scheduleOptyLineItems (o.Id, strSobjects);
            
            system.assertEquals(true, res.success);
        }
    } */
}