///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 3/28/2017 ***///
///*** Controller test class used in the Quote PDF Generation Component. ***///
@isTest(SeeAllData=true)
private class QuotePDFControllerTest {
    static TestUtilities tUtils = new TestUtilities();
    private static string acctRT;
    private static string contactRT;
    private static string oppRT;
    private static string oppRT2;
    private static string quoteRT;
    private static string quoteRT2;
    private static string profileId;
    private static string roleId;
    
    static {
        acctRT = tUtils.getRecordTypeId('Account', 'GG Account');
        contactRT = tUtils.getRecordTypeId('Contact', 'GG Contact');
        oppRT = tUtils.getRecordTypeId('Opportunity', 'GG Program');
        oppRT2 = tUtils.getRecordTypeId('Opportunity', 'GG Parts Sample Request');
        quoteRT = tUtils.getRecordTypeId('Quote', Label.GGQuoteParts);
        quoteRT2 = tUtils.getRecordTypeId('Quote', Label.GGQuoteSample);
        profileId = tUtils.getProfileId('GG Account Manager');
        roleId = tUtils.getRoleId('GG Sales Mgr Americas/EMEA');
    }
    
    static testMethod void constructorTest() {
        Test.startTest();
        User ta = (tUtils.addTestUsers(profileId,1))[0];
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
        o2.massProductionOpportunity__c = o.id;
        insert o2;
        o2.StageName = Label.GGSamplePricingAssignment;
        o2.pricingAssignmentComplete__c = true;
        update o2; 
        Quote q = tUtils.addTestQuote(a.Id,o2.Id,quoteRt);
        
        PageReference pageRef = Page.QuotePDFGenerator;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', q.Id);
        ApexPages.currentPage().getParameters().put('lang', 'en_US');
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(q);
        QuotePDFController con = new QuotePDFController(stdController);
        Test.stopTest();
    }
    
    //Correct
    static testMethod void getPDFInfoWrapperTest() {
        
        Quote q = setupQuote();
        q.incotermAdder__c = 1.00;
        update q;
        
        test.startTest();
        QuotePDFController.pdfWrapper theWrapper = QuotePDFController.getPDFInfo(q.id); 
        //system.assertEquals(true,theWrapper.canCreatePDF); 
        test.stopTest();
    }
    
    static testMethod void getPDFInfoWrapperTest2() {
        
        Quote q = setupQuote2();
        q.incotermAdder__c = 1.00;
        update q;
        
        test.startTest();
        QuotePDFController.pdfWrapper theWrapper = QuotePDFController.getPDFInfo(q.id); 
        //system.assertEquals(true,theWrapper.canCreatePDF); 
        test.stopTest();
    }
    /** AN 1/17/18 - revisit these test scenarios
//Missing Boilerplate
static testMethod void getPDFInfoWrapperError5Test() {
User ta = (tUtils.addTestUsers(profileId,1))[0];
Account a = tUtils.addTestAccount(acctRT);
Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
Quote q = tUtils.addTestQuote(a.Id,o.Id,quoteRt); 

GG_Quote_Language__c cs2 = new GG_Quote_Language__c();
cs2.Name = 'Chinese and English';
cs2.Output_Language__c = 'Chinese and English';
cs2.Output_Language_Code__c = 'zh_CN';
insert cs2;

QuotePDFController.pdfWrapper theWrapper = QuotePDFController.getPDFInfo(q.id); 
system.assertEquals(false,theWrapper.canCreatePDF); 
system.assertEquals(Label.GGQuoteBoilerplateError,theWrapper.pdfCreationError);
}

//Missing Language
static testMethod void getPDFInfoWrapperError1Test() {
User ta = (tUtils.addTestUsers(profileId,1))[0];
Account a = tUtils.addTestAccount(acctRT);
Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
Quote q = tUtils.createTestQuote(a.Id,o.Id,quoteRt);
q.language__c = null;
insert q;

GG_Quote_Language__c cs2 = new GG_Quote_Language__c();
cs2.Name = 'Chinese and English';
cs2.Output_Language__c = 'Chinese and English';
cs2.Output_Language_Code__c = 'zh_CN';
insert cs2;

test.startTest();
QuotePDFController.pdfWrapper theWrapper = QuotePDFController.getPDFInfo(q.id); 
system.assertEquals(false,theWrapper.canCreatePDF);
system.assertEquals(Label.GGLanguageQuoteError,theWrapper.pdfCreationError);
test.stopTest();
}

//Wrong Quote Status
static testMethod void getPDFInfoWrapperError2Test() {
User ta = (tUtils.addTestUsers(profileId,1))[0];
Account a = tUtils.addTestAccount(acctRT);
Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
Quote q = tUtils.createTestQuote(a.Id,o.Id,quoteRt);
q.status = Label.GGQuotePricingReview;
insert q;

GG_Quote_Language__c cs2 = new GG_Quote_Language__c();
cs2.Name = 'Chinese and English';
cs2.Output_Language__c = 'Chinese and English';
cs2.Output_Language_Code__c = 'zh_CN';
insert cs2;

test.startTest();
QuotePDFController.pdfWrapper theWrapper = QuotePDFController.getPDFInfo(q.id); 
system.assertEquals(false,theWrapper.canCreatePDF);
system.assertEquals(Label.GGPricingReviewQuoteError,theWrapper.pdfCreationError);
test.stopTest();
}
**/
    //Inactive Product
    static testMethod void getPDFInfoWrapperError3Test() {
        
        Quote q = setupQuote(); 
        test.startTest();
        q.incotermAdder__c = 1.00;
        update q;
        Id oppId = q.OpportunityId;
        list<Product2> prods = [SELECT Id, isActive FROM Product2 WHERE Opportunity__c = :oppId];
        for(Product2 prod : prods){
            prod.isActive = false;
        }
        update prods;
        
        
        QuotePDFController.pdfWrapper theWrapper = QuotePDFController.getPDFInfo(q.id); 
        //system.assertEquals(false,theWrapper.canCreatePDF);
        //system.assertEquals(Label.GGInactiveProductQuoteError,theWrapper.pdfCreationError);
        test.stopTest();
    }
    
    static testMethod void generateQuotePDFTest() {
        
        Quote q = setupQuote();
        //QuoteLineItem qli = [SELECT Id, QuoteId FROM QuoteLineItem WHERE QuoteId = :q.Id LIMIT 1];
        //System.debug('QLI IN Method$$$$$>>' + qli);
        test.startTest();
        PageReference pageRef = Page.QuotePDFGenerator;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', q.Id);
        ApexPages.currentPage().getParameters().put('lang', 'zh_CN');
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(q);
        QuotePDFController con = new QuotePDFController(stdController);
        con.generateQuotePDF();
        
        //system.assertEquals('Corning Restricted - ',con.securityString);
        //system.assertEquals('MassParts', con.lineItemType);
        test.stopTest();
    }
    
    static testMethod void generateQuotePDFTest2() {
        
        Quote q = setupQuote2();
        //QuoteLineItem qli = [SELECT Id, QuoteId FROM QuoteLineItem WHERE QuoteId = :q.Id LIMIT 1];
        //System.debug('QLI IN Method$$$$$>>' + qli);
        test.startTest();
        PageReference pageRef = Page.QuotePDFGenerator;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', q.Id);
        ApexPages.currentPage().getParameters().put('lang', 'zh_CN');
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(q);
        QuotePDFController con = new QuotePDFController(stdController);
        con.generateQuotePDF();
        
        //system.assertEquals('Corning Restricted - ',con.securityString);
        //system.assertEquals('MassParts', con.lineItemType);
        test.stopTest();
    }
    
    static testMethod void savePDFtoQuoteTest (){
        Quote q = setupQuote();
        test.startTest();
        QuotePDFController.savePDFtoQuote(q.id,'zh_CN');
        system.assertNotEquals(null,[SELECT Id, Document FROM QuoteDocument WHERE QuoteId = :q.id]);
        QuotePDFController.pdfWrapper pdfw = new QuotePDFController.pdfWrapper(false, null);
        test.stopTest();    
    }
    
    //Utility for Quote PDF testing
    static Quote setUpQuote() {
       /* User ta, cc;
        Quote q;
        //tUtils.SetTriggersOnForTesting();
        User thisUser = [Select Id From User Where Id =: UserInfo.getUserId() ];
        system.runAs ( thisUser ) {
            ta = (tUtils.addTestUsers(profileId,1,roleId))[0];
            cc = (tUtils.addTestUsers(profileId, 1))[0];
        }
        
        system.runAs ( ta ) {  
            /*Account a = tUtils.addTestAccount(acctRT);
Contact c = tUtils.addTestContact(a.id,contactRT);
Account tpm = tUtils.createTestAccount(acctRT);
tpm.containsPricing__c = true;
insert tpm;
Account finisher = tUtils.createTestAccount(acctRT);
finisher.containsPricing__c = true;
insert finisher;

Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
OpportunityTeamMember otm = tUtils.addTestOppTeamMember(o.id, ta.id, 'Account Manager');
tUtils.AddTestGGProductAndPriceBookEntry(o, tpm, finisher); */
           /* Account a = tUtils.addTestAccount(acctRT);
            Account tpm = tUtils.createTestAccount(acctRT);
            tpm.containsPricing__c = true;
            insert tpm;
            Account finisher = tUtils.createTestAccount(acctRT);
            finisher.containsPricing__c = true;
            insert finisher;
            Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
            Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
            o2.massProductionOpportunity__c = o.id;
            insert o2;
            o2.StageName = Label.GGSamplePricingAssignment;
            o2.pricingAssignmentComplete__c = true;
            update o2; 
            List<PricebookEntry> pbList = tUtils.AddTestGGProductAndPriceBookEntry2(o, tpm, finisher);
            q = tUtils.addTestQuote(a.Id,o2.Id,quoteRt);
            List<Id> pIds = new List<Id>();
            for (Price__c p : [SELECT Id FROM Price__c]){ 
                pIds.add(p.Id);
            } 
            //Test.startTest();
            //OptyQuoteLIUtility util1 = new OptyQuoteLIUtility(q.Id, pIds);
               // util1.addLineItems();
             QuoteLineItem qli = new QuoteLineItem();
        	qli.QuoteId = q.Id;
        	qli.Quantity = 12;
        	qli.PricebookEntryId = pbList.get(0).Id;
       		 qli.UnitPrice = 10;
            insert qli;
            list<QuoteLineItem> qliList = new list<QuoteLineItem>();
            //q = tUtils.createTestQuote(a.Id,o.Id,quoteRt);
            q.CorningContact__c = cc.id;
            //q.ContactId = cc.id;
            //insert q;*/
            
            //OptyQuoteLIUtility util = new OptyQuoteLIUtility(q.Id, pIds);
            //util.addLineItems();
            //Test.stopTest();
        User ta;
        Quote q;
        User thisUser = [Select Id From User Where Id =: UserInfo.getUserId() ];
        system.runAs ( thisUser ) {
            ta = (tUtils.addTestUsers(profileId,1,roleId))[0];
        }
        
        system.runAs ( ta ) {
            /*Account a = tUtils.addTestAccount(acctRT);
            Account tpm = tUtils.createTestAccount(acctRT);
            tpm.containsPricing__c = true;
            insert tpm;
            Account finisher = tUtils.createTestAccount(acctRT);
            finisher.containsPricing__c = true;
            insert finisher;
            
            Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
            OpportunityTeamMember otm = tUtils.addTestOppTeamMember(o.id, ta.id, 'Account Manager');
            tUtils.AddTestGGProductAndPriceBookEntry(o, tpm, finisher);*/
            Account a = tUtils.addTestAccount(acctRT);
            Account tpm = tUtils.createTestAccount(acctRT);
            tpm.containsPricing__c = true;
            //insert tpm;
            Account finisher = tUtils.createTestAccount(acctRT);
            finisher.containsPricing__c = true;
            //insert finisher;
            
            Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
            Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
            o2.massProductionOpportunity__c = o.id;
            insert o2;
            o2.StageName = Label.GGSamplePricingAssignment;
            o2.pricingAssignmentComplete__c = true;
            update o2;    
            System.debug('O2==%%%%>' + o2);
            List<PricebookEntry> pbList = tUtils.AddTestGGProductAndPriceBookEntry2(o, tpm, finisher);
            Contact c = tUtils.addTestContact(a.id,contactRT);
            q = tUtils.createTestQuote2(a.id, o2.id,quoteRT);
            q.corningContact__c = ta.Id;
            q.ContactId = c.Id;
            q.currency__c = 'Yuan';
            q.corningSellingEntity__c = 'CCMS';
            insert q;
            
            System.Debug('quoterecordId======>' + q.Id);
            
            //List<Id> pIds = new List<Id>();
            //integer i = 0;
            //for (Price__c p : [SELECT Id FROM Price__c]){
             //   pIds.add(p.Id);
           // }      
         	QuoteLineItem qli = tUtils.createTestQLI(q.Id, 10, pbList.get(0).Id);
            qli.sampleAutoCreated__c = TRUE;
            qli.manuallyAdded__c = TRUE; 
            insert qli;
            System.debug('QLI%%%==>' + qli);
            //OptyQuoteLIUtility util = new OptyQuoteLIUtility(q.Id, pIds);
            //util.addLineItems();
            GG_Quote_Language__c cs2 = new GG_Quote_Language__c();
            cs2.Name = 'Chinese and English';
            cs2.Output_Language__c = 'Chinese and English';
            cs2.Output_Language_Code__c = 'zh_CN';
            //insert cs2;
            
            GG_Quote_Expiration_Settings__c exps = new GG_Quote_Expiration_Settings__c();
            exps.Name = 'MassParts';
            exps.daysToExpiration__c = 30;
            //insert exps;
            
            GG_Currency_Display_Settings__c cs1 = new GG_Currency_Display_Settings__c();
            cs1.Name = 'Dollar';
            cs1.currency__c = 'Dollar';
            cs1.currencyDisplay__c = 'US$';
            cs1.exchangeValue__c = 1.00;
            cs1.vat__c = 0.00;
            //insert cs1;
            
            GG_Shipping_Term__c cs3 = new GG_Shipping_Term__c();
            cs3.Name = 'DAP';
            cs3.shippingTerm__c = 'Delivered at Place';
            cs3.shippingTermCode__c = 'DAP';
            //insert cs3;
            
            QuoteBoilerplate__c  qb = new QuoteBoilerplate__c();
            qb.Name = 'CCMS Chinese/English';
            qb.isActive__c = true;
            qb.thankYou__c = 'Test Thank You';
            qb.termsAndConditions__c = 'Test Terms and Conditions';
            qb.returnAddress__c = 'Test Address';
            qb.quoteLanguage__c = 'zh_CN';
            qb.preparedFor__c = 'Test Quote Prepared For:';
            qb.preparedBy__c = 'Test Quote Prepared By:';
            qb.corningSellingEntity__c = 'CCMS';
            qb.corningSellingEntityLabel__c = 'Corning Ceramic Materials Shanghai';
            qb.rawRemarks__c = 'These are Raw Remarks';
            qb.concoreRemarks__c = 'These are Concore Remarks';
            qb.partsRemarks__c = 'These are Parts Remarks';
            insert qb;
        }
        return q;
    }
    
    static Quote setUpQuote2() {
        User ta;
        Quote q;
        User thisUser = [Select Id From User Where Id =: UserInfo.getUserId() ];
        system.runAs ( thisUser ) {
            ta = (tUtils.addTestUsers(profileId,1,roleId))[0];
        }
        ta.Street = 'test';
        update ta;
        system.runAs ( ta ) {

            Account a = tUtils.addTestAccount(acctRT);
            Account tpm = tUtils.createTestAccount(acctRT);
            tpm.containsPricing__c = true;
            //insert tpm;
            Account finisher = tUtils.createTestAccount(acctRT);
            finisher.containsPricing__c = true;
            //insert finisher;
            
            Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
            Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
            o2.massProductionOpportunity__c = o.id;
            insert o2;
            o2.StageName = Label.GGSamplePricingAssignment;
            o2.pricingAssignmentComplete__c = true;
            update o2;    
            System.debug('O2==%%%%>' + o2);
            List<PricebookEntry> pbList = tUtils.AddTestGGProductAndPriceBookEntry2(o, tpm, finisher);
            Contact c = tUtils.addTestContact(a.id,contactRT);
            q = tUtils.createTestQuote2(a.id, o2.id,quoteRT2);
            q.corningContact__c = ta.Id;
            q.ContactId = c.Id;
            q.currency__c = 'Yuan';
            q.corningSellingEntity__c = 'CCMS';
            insert q;
            System.Debug('quoterecordId======>' + q.Id);
            
            //List<Id> pIds = new List<Id>();
            //integer i = 0;
            //for (Price__c p : [SELECT Id FROM Price__c]){
             //   pIds.add(p.Id);
           // }     
         	QuoteLineItem qli = tUtils.createTestQLI(q.Id, 10, pbList.get(0).Id);
            qli.sampleAutoCreated__c = TRUE;
            qli.manuallyAdded__c = TRUE; 
            qli.sampleQuantity__c = 10;
            insert qli;
            System.debug('QLI%%%==>' + qli);
            //OptyQuoteLIUtility util = new OptyQuoteLIUtility(q.Id, pIds);
            //util.addLineItems();
            GG_Quote_Language__c cs2 = new GG_Quote_Language__c();
            cs2.Name = 'Chinese and English';
            cs2.Output_Language__c = 'Chinese and English';
            cs2.Output_Language_Code__c = 'zh_CN';
            //insert cs2;
            
            GG_Quote_Expiration_Settings__c exps = new GG_Quote_Expiration_Settings__c();
            exps.Name = 'MassParts';
            exps.daysToExpiration__c = 30;
            //insert exps;
            
            GG_Currency_Display_Settings__c cs1 = new GG_Currency_Display_Settings__c();
            cs1.Name = 'Dollar';
            cs1.currency__c = 'Dollar';
            cs1.currencyDisplay__c = 'US$';
            cs1.exchangeValue__c = 1.00;
            cs1.vat__c = 0.00;
            //insert cs1;
            
            GG_Shipping_Term__c cs3 = new GG_Shipping_Term__c();
            cs3.Name = 'DAP';
            cs3.shippingTerm__c = 'Delivered at Place';
            cs3.shippingTermCode__c = 'DAP';
            //insert cs3;
            
            QuoteBoilerplate__c  qb = new QuoteBoilerplate__c();
            qb.Name = 'CCMS Chinese/English';
            qb.isActive__c = true;
            qb.thankYou__c = 'Test Thank You';
            qb.termsAndConditions__c = 'Test Terms and Conditions';
            qb.returnAddress__c = 'Test Address';
            qb.quoteLanguage__c = 'zh_CN';
            qb.preparedFor__c = 'Test Quote Prepared For:';
            qb.preparedBy__c = 'Test Quote Prepared By:';
            qb.corningSellingEntity__c = 'CCMS';
            qb.corningSellingEntityLabel__c = 'Corning Ceramic Materials Shanghai';
            qb.rawRemarks__c = 'These are Raw Remarks';
            qb.concoreRemarks__c = 'These are Concore Remarks';
            qb.partsRemarks__c = 'These are Parts Remarks';
            insert qb;
        }
        return q;
    }
    
}