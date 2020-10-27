///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 3/11/2017 ***///
///*** Tests for class used in the add products custom Lightning component ***///
@isTest
private class GGGlassProductsControllerTest {
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
    private static User thisUser;
    
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
        thisUser = [Select Id From User Where Id =: UserInfo.getUserId() ];
        tUtils.SetTriggersOnForTesting(false, false, false, true, true, false);
    }

    static testMethod void getOptyLineItemsTest() {
        User ta;
        
        //User 
        system.runAs ( thisUser ) {
            ta = (tUtils.addTestUsers(profileId,1,roleId))[0];
        }
        
        system.runAs ( ta ) {
            Account a = tUtils.addTestAccount(acctRT);
            Account tpm = tUtils.createTestAccount(acctRT);
            tpm.containsPricing__c = true;
            //insert tpm;
            Account finisher = tUtils.createTestAccount(acctRT);
            finisher.containsPricing__c = true;
            //insert finisher;
            
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
            
            oliList = [SELECT Id, Quantity, OpportunityId, ServiceDate, UnitPrice, PriceBookEntryId 
                        FROM OpportunityLineItem WHERE OpportunityId = :o.Id]; 
            
            system.assertEquals(4,[SELECT Count() FROM OpportunityLineItem WHERE OpportunityId = :o.Id]); 
            
            GGGlassProductsController.OpttyLineItemsWrapper theWrapper = GGGlassProductsController.getOptyLineItems(o.Id);
            
            system.assertEquals(4,theWrapper.lineItems.size()); 
        }
    }
    
    static testMethod void getOptyLineItemsTest2() {
        User ta;
        system.runAs ( thisUser ) {
            ta = (tUtils.addTestUsers(profileId,1,roleId))[0];
        }
        
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
            
            List<PricebookEntry> pbList = tUtils.AddTestGGProductAndPriceBookEntry2(o, tpm, finisher);
            List<Id> pIds = new List<Id>();
            integer i = 0;
            for (Price__c p : [SELECT Id FROM Price__c]){
                pIds.add(p.Id);
            }      
        
            OptyQuoteLIUtility util = new OptyQuoteLIUtility(o.Id, pIds);
            util.addLineItems();
            list<OpportunityLineItem> oliList = new list<OpportunityLineItem>();
            
            oliList = [SELECT Id, Quantity, OpportunityId, ServiceDate, UnitPrice, PriceBookEntryId 
                        FROM OpportunityLineItem WHERE OpportunityId = :o.Id]; 
            
            system.assertEquals(4,[SELECT Count() FROM OpportunityLineItem WHERE OpportunityId = :o.Id]); 
            
            OpportunityLineItem sample = tUtils.addTestOLI(o2.id, 5, pblist[0].Id);
            
            GGGlassProductsController.OpttyLineItemsWrapper theWrapper = GGGlassProductsController.getOptyLineItems(o2.Id);
            
            system.assertEquals(1,theWrapper.lineItems.size()); 
        }
    }
    
    static testMethod void saveOptyLineItemsTest() {
        User ta;
        system.runAs ( thisUser ) {
            ta = (tUtils.addTestUsers(profileId,1,roleId))[0];
        }
        
        system.runAs ( ta ) {
            Account a = tUtils.addTestAccount(acctRT);
            Account tpm = tUtils.createTestAccount(acctRT);
            tpm.containsPricing__c = true;
            //insert tpm;
            Account finisher = tUtils.createTestAccount(acctRT);
            finisher.containsPricing__c = true;
			//insert finisher;
            
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
            
            oliList = [SELECT Id, Quantity, OpportunityId, ServiceDate, UnitPrice, PriceBookEntryId 
                        FROM OpportunityLineItem WHERE OpportunityId = :o.Id]; 
            oliList.add(tUtils.createTestOLI(o.Id, 200, Test.getStandardPricebookId()));
            for(OpportunityLineItem oli : oliList){
                system.assertNotEquals(3000,oli.Quantity);
                // system.assertNotEquals(date.today(),oli.ServiceDate); // adding line ite now adds date
                oli.Quantity = 3000;
                oli.ServiceDate = date.today();
            }   
            
            string strSobjects = ' ';   
            strSobjects = JSON.serialize(oliList);
            
            GGGlassProductsController.LineItemsSaveResults results = GGGlassProductsController.saveOptyLineItems(o.Id, false, strSobjects);
            
            for(OpportunityLineItem oli : oliList){
                system.assertEquals(3000,oli.Quantity);
                system.assertEquals(date.today(),oli.ServiceDate);
            }   
        }
    }
    
    static testMethod void deleteOptyLineItemsTest() {
        User ta;
        system.runAs ( thisUser ) {
            ta = (tUtils.addTestUsers(profileId,1,roleId))[0];
        }
        
        system.runAs ( ta ) {
            Account a = tUtils.addTestAccount(acctRT);
            Account tpm = tUtils.createTestAccount(acctRT);
            tpm.containsPricing__c = true;
            //insert tpm;
            Account finisher = tUtils.createTestAccount(acctRT);
            finisher.containsPricing__c = true;
            //insert finisher;
            
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
            
            oliList = [SELECT Id, Quantity, OpportunityId, ServiceDate, UnitPrice, PriceBookEntryId 
                        FROM OpportunityLineItem WHERE OpportunityId = :o.Id]; 
            
            system.assertEquals(4,[SELECT Count() FROM OpportunityLineItem WHERE OpportunityId = :o.Id]); 
            
            string strSobjects = ' ';   
            strSobjects = JSON.serialize(oliList);
            
            GGGlassProductsController.LineItemsSaveResults results = GGGlassProductsController.deleteOptyLineItems(strSobjects);
            
            system.assertEquals(0,[SELECT Count() FROM OpportunityLineItem WHERE OpportunityId = :o.Id]); 
        }
    }
    
    static testMethod void scheduleOptyLineItemsTest() {
        User ta;
        system.runAs ( thisUser ) {
            ta = (tUtils.addTestUsers(profileId,1,roleId))[0];
        }
        
        system.runAs ( ta ) {
            Account a = tUtils.addTestAccount(acctRT);
            Account tpm = tUtils.createTestAccount(acctRT);
            tpm.containsPricing__c = true;
            //insert tpm;
            Account finisher = tUtils.createTestAccount(acctRT);
            finisher.containsPricing__c = true;
            //insert finisher;
            
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
            
            oliList = [SELECT Id, Quantity, OpportunityId, ServiceDate, UnitPrice, PriceBookEntryId 
                        FROM OpportunityLineItem WHERE OpportunityId = :o.Id]; 
            for(OpportunityLineItem oli : oliList){
                oli.Quantity = 3000;
                oli.ServiceDate = date.today();
            }
            update oliList;

            string strSobjects = ' ';   
            strSobjects = JSON.serialize(oliList);
            string monthsToAdd = '3,3,3,3';
            integer monthlyQuantity = 1000; //original quantity/months
            GGGlassProductsController.LineItemsSaveResults results = GGGlassProductsController.scheduleOptyLineItems(monthsToAdd,strSobjects);
 
            system.assertEquals(3,[SELECT Count() FROM OpportunityLineItem WHERE OpportunityId = :o.Id AND ServiceDate = :date.today() AND Quantity = :monthlyQuantity]); 
            system.assertEquals(3,[SELECT Count() FROM OpportunityLineItem WHERE OpportunityId = :o.Id AND ServiceDate = :date.today().addMonths(1) AND Quantity = :monthlyQuantity]); 
            system.assertEquals(3,[SELECT Count() FROM OpportunityLineItem WHERE OpportunityId = :o.Id AND ServiceDate = :date.today().addMonths(2) AND Quantity = :monthlyQuantity]); 
            system.assertEquals(3,[SELECT Count() FROM OpportunityLineItem WHERE OpportunityId = :o.Id AND ServiceDate = :date.today().addMonths(3) AND Quantity = :monthlyQuantity]); 
        }
    }
    
    static testMethod void getQuoteLineItemsTest() {
        User ta;
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
            Quote q = tUtils.addTestQuote(a.id, o2.id,quoteRT);
            
            
            List<Id> pIds = new List<Id>();
            integer i = 0;
            for (Price__c p : [SELECT Id FROM Price__c]){
                pIds.add(p.Id);
            }      
        
            OptyQuoteLIUtility util = new OptyQuoteLIUtility(q.Id, pIds);
            util.addLineItems();
            
            list<QuoteLineItem> qliList = new list<QuoteLineItem>();
            
            qliList = [SELECT Id, Quantity, QuoteId, ServiceDate, UnitPrice, PriceBookEntryId 
                        FROM QuoteLineItem WHERE QuoteId = :q.Id]; 
            
            //system.assertEquals(7,[SELECT Count() FROM QuoteLineItem WHERE QuoteId = :q.Id]);
            
            GGGlassProductsController.QuoteLineItemsWrapper theWrapper = GGGlassProductsController.getQuoteLineItems(q.Id);
            
            system.assertEquals(7,theWrapper.lineItems.size()); 
        }
    }
    
    static testMethod void saveQuoteLineItemsTest() {
        User ta;
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
            tUtils.AddTestGGProductAndPriceBookEntry(o, tpm, finisher);
            
            Quote q = tUtils.addTestQuote(a.id, o.id,quoteRT);*/
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
            Quote q = tUtils.addTestQuote(a.id, o2.id,quoteRT);
            
            List<Id> pIds = new List<Id>();
            integer i = 0;
            for (Price__c p : [SELECT Id FROM Price__c]){
                pIds.add(p.Id);
            }      
        
            OptyQuoteLIUtility util = new OptyQuoteLIUtility(q.Id, pIds);
            util.addLineItems();
            
            list<QuoteLineItem> qliList = new list<QuoteLineItem>();
            
            qliList = [SELECT Id, Quantity, QuoteId, ServiceDate, UnitPrice, PriceBookEntryId 
                        FROM QuoteLineItem WHERE QuoteId = :q.Id]; 
            
            for(QuoteLineItem qli : qliList){
                system.assertNotEquals(3000,qli.Quantity);
                system.assertNotEquals(date.today(),qli.ServiceDate);
                qli.Quantity = 3000;
                qli.ServiceDate = date.today();}    
            
            string strSobjects = ' ';   
            strSobjects = JSON.serialize(qliList);
            
            GGGlassProductsController.LineItemsSaveResults results = GGGlassProductsController.saveQuoteLineItems(q.Id, false, strSobjects);
            
            for(QuoteLineItem qli : qliList){
                system.assertEquals(3000,qli.Quantity);
                system.assertEquals(date.today(),qli.ServiceDate);
            }   
        }
    }
    
    static testMethod void deleteQuoteLineItemsTest() {
        User ta;
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
            
            Opportunity o = tUtils.addTestOppt(a.Id,oppRT2);
            OpportunityTeamMember otm = tUtils.addTestOppTeamMember(o.id, ta.id, 'Account Manager');
            tUtils.AddTestGGProductAndPriceBookEntry(o, tpm, finisher);
            */
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
            Quote q = tUtils.addTestQuote(a.id, o2.id,quoteRT);
            
            List<Id> pIds = new List<Id>();
            integer i = 0;
            for (Price__c p : [SELECT Id FROM Price__c]){
                pIds.add(p.Id);
            }      
        
            OptyQuoteLIUtility util = new OptyQuoteLIUtility(q.Id, pIds);
            util.addLineItems();
            
            list<QuoteLineItem> qliList = new list<QuoteLineItem>();
            
            qliList = [SELECT Id, Quantity, QuoteId, ServiceDate, UnitPrice, PriceBookEntryId 
                        FROM QuoteLineItem WHERE QuoteId = :q.Id]; 
            
            //system.assertEquals(7,[SELECT Count() FROM QuoteLineItem WHERE QuoteId = :q.Id]); 
            
            string strSobjects = ' ';   
            strSobjects = JSON.serialize(qliList);
            
            GGGlassProductsController.LineItemsSaveResults results = GGGlassProductsController.deleteQuoteLineItems(strSobjects);
            
            //system.assertEquals(0,[SELECT Count() FROM QuoteLineItem WHERE QuoteId = :q.Id]); 
        }
    }
    
    static testMethod void processPLMApprovalQuoteTest() {
        User ta;
        system.runAs ( thisUser ) {
            ta = (tUtils.addTestUsers(profileId2,1,roleId2))[0];
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
            tUtils.AddTestGGProductAndPriceBookEntry(o, tpm, finisher);
            
            Quote q = tUtils.addTestQuote(a.id, o.id,quoteRT);*/
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
            Quote q = tUtils.addTestQuote(a.id, o2.id,quoteRT);
            
            List<Id> pIds = new List<Id>();
            integer i = 0;
            for (Price__c p : [SELECT Id FROM Price__c]){
                pIds.add(p.Id);
            }      

            OptyQuoteLIUtility util = new OptyQuoteLIUtility(q.Id, pIds);
            util.addLineItems();
            
            list<QuoteLineItem> qliList = new list<QuoteLineItem>();
            qliList = [SELECT Id, Quantity, QuoteId, ServiceDate, UnitPrice, PriceBookEntryId, Price__c 
                        FROM QuoteLineItem WHERE QuoteId = :q.Id]; 
            qliList.get(0).partsTierMap__c = '1';
            string strSobjects = ' ';   
            strSobjects = JSON.serialize(qliList);

            GGGlassProductsController.LineItemsSaveResults results = new GGGlassProductsController.LineItemsSaveResults();
            results = GGGlassProductsController.processPLMApprovalQuote (true, true, q.Id, false, strSobjects);
            
            for (QuoteLineItem qliPrice : [SELECT Price__r.priceExpirationDate__c, Price__r.priceApprovalDate__c FROM QuoteLineItem WHERE QuoteId = :q.Id]) {
                //system.assertEquals(System.Date.today(), qliPrice.Price__r.priceApprovalDate__c);
                //system.assertEquals(System.Date.today().addDays(30), qliPrice.Price__r.priceExpirationDate__c);
            }
        }
    }
    
    static testMethod void processPLMApprovalSampleTest() {
        User ta;
        system.runAs ( thisUser ) {
            ta = (tUtils.addTestUsers(profileId3,1,roleId2))[0];
        }
        
        system.runAs ( ta ) {
            Account a = tUtils.addTestAccount(acctRT);
            Account tpm = tUtils.createTestAccount(acctRT);
            tpm.containsPricing__c = true;
            ///insert tpm;
            Account finisher = tUtils.createTestAccount(acctRT);
            finisher.containsPricing__c = true;
            //insert finisher;
            
            Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
            Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
            o2.massProductionOpportunity__c = o.id;
            insert o2;
            o2.StageName = Label.GGSamplePricingAssignment;
            update o2;
            OpportunityTeamMember otm = tUtils.addTestOppTeamMember(o2.id, ta.id, 'Account Manager');
            List<PricebookEntry> pbEntries = tUtils.AddTestGGProductAndPriceBookEntry2(o2, tpm, finisher);
            
            tUtils.addTestOLI(o2.id,5, pbEntries[1].Id);
            
            list<OpportunityLineItem> oliList = new list<OpportunityLineItem>();
            
            oliList = [SELECT Id, Quantity, OpportunityId, ServiceDate, UnitPrice, PriceBookEntryId 
                        FROM OpportunityLineItem WHERE OpportunityId = :o2.Id]; 
            
            string strSobjects = ' ';   
            strSobjects = JSON.serialize(oliList);

            GGGlassProductsController.LineItemsSaveResults results = new GGGlassProductsController.LineItemsSaveResults();
            results = GGGlassProductsController.processPLMApprovalSample (o2.Id, strSobjects);
            
            system.assertEquals(true, [SELECT pricingAssignmentComplete__c FROM Opportunity WHERE Id = :o2.Id LIMIT 1].pricingAssignmentComplete__c);
        }
    }
    
    static testMethod void processPLMApprovalSampleTest2() {
        User ta;
        system.runAs ( thisUser ) {
            ta = (tUtils.addTestUsers(profileId3,1,roleId2))[0];
        }
        
        system.runAs ( ta ) {
            Account a = tUtils.addTestAccount(acctRT);
            Account tpm = tUtils.createTestAccount(acctRT);
            tpm.containsPricing__c = true;
            //insert tpm;
            Account finisher = tUtils.createTestAccount(acctRT);
            finisher.containsPricing__c = true;
            //insert finisher;
            
            Opportunity o = tUtils.addTestOppt(a.Id,oppRT);

            OpportunityTeamMember otm = tUtils.addTestOppTeamMember(o.id, ta.id, 'Account Manager');
            List<PricebookEntry> pbEntries = tUtils.AddTestGGProductAndPriceBookEntry2(o, tpm, finisher);
            
            tUtils.addTestOLI(o.id,5, pbEntries[1].Id);
            
            list<OpportunityLineItem> oliList = new list<OpportunityLineItem>();
            
            oliList = [SELECT Id, Quantity, OpportunityId, ServiceDate, UnitPrice, PriceBookEntryId 
                        FROM OpportunityLineItem WHERE OpportunityId = :o.Id]; 
            
            string strSobjects = ' ';   
            strSobjects = JSON.serialize(oliList);

            GGGlassProductsController.LineItemsSaveResults results = new GGGlassProductsController.LineItemsSaveResults();
            results = GGGlassProductsController.processPLMApprovalSample (o.Id, strSobjects);
            
            system.assertEquals('Not a sample request', results.saveMessage);
        }
    }
    
    @isTest
    public static void unitTestForRunningInSF1(){
        GGGlassProductsController.runningInSF1();
    }
}