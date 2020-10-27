///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 3/1/2017 ***///
///*** Class to test quote trigger helper***///
//

@isTest

private class QuoteTriggerHelperTest {
    static TestUtilities tUtils = new TestUtilities();
    private static string acctRT;
    private static string oppRT;
    private static string oppRT2;
    private static string quoteRT;
    private static string quoteRT2;
    private static string profileId;
    private static string roleId;
    
    static {
        acctRT = tUtils.getRecordTypeId('Account', 'GG Account');
        oppRT = tUtils.getRecordTypeId('Opportunity', 'GG Program');
        oppRT2 = tUtils.getRecordTypeId('Opportunity', 'GG Parts Sample Request');
        quoteRT = tUtils.getRecordTypeId('Quote', Label.GGQuoteParts);
        quoteRT2 = tUtils.getRecordTypeId('Quote', Label.GGQuoteSample);
        profileId = tUtils.getProfileId('GG Account Manager');
        roleId = tUtils.getRoleId('GG Exclusive (Blue)');
    }
    @testsetup static void TestData(){
        tUtils.SetTriggersOnForTesting();
        
    }
    
    static testMethod void setGGPriceBookTest() {
        TriggerSettings__c trigSettings = TriggerSettings__c.getInstance();   
        system.debug('trigSettings: '+ trigSettings);
        list<Quote> qList = new list<Quote>();
        
        User ta = (tUtils.addTestUsers(profileId,1))[0];
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT2,false);
        o.pricingAssignmentComplete__c=true;
        insert o;
        
        Product2 p1 = tUtils.addTestProduct(o.Id,'My Product 1');
        Product2 p2 = tUtils.addTestProduct(o.Id,'My Product 2');
          
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id sPricebookId = Test.getStandardPricebookId();
        Id pricebookId = '01so0000004gBaQAAU';         
        PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 5);
        PricebookEntry pbe2 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p2.id, 15);
        
        OpportunityLineItem oli1 = tUtils.createTestOLI(o.id, 5, pbe1.id);
        // oli1.deviceTracker__c = true; // AN - 8/6/18 - remove device tracker - field not used anymore
        insert oli1;
        
        
        for (Integer i = 0; i <1; i++)  {
            Quote q = tUtils.createTestQuote(a.Id,o.Id,quoteRt);           
            qList.add(q);
        }
        
        insert qList;
        
        system.debug('qList'+ qList);
        for(Quote q1 : qList){
            system.debug('q1'+ q1);
            //INSERT tUtils.createTestQLI(q1.Id,10, customPB.Id);
        }
        
        list<QuoteLineItem> qliList = [SELECT Id, sampleAutoCreated__c, quantity, PricebookEntryId, price__c FROM QuoteLineItem WHERE QuoteId IN :qList];
        for (QuoteLineItem qli : qliList) {
            qli.quantity = 10;
            system.assertEquals(true, qli.sampleAutoCreated__c); 
        }
        update qliList;
        // QuoteTriggerHelper.checkLIPrices(qliList);
       // QuoteTriggerHelper.setPricingFlags(qliList);
        test.startTest();
        system.runAs(ta) {
            list<Quote> qListAFter = new list<Quote>();
            qListAFter = [SELECT Id, PriceBook2Id FROM Quote WHERE Id IN :qList];
            for (Quote q : qListAFter) {
                system.assertNotEquals (null, q.PriceBook2Id);
            }
        }
        test.stopTest();
    }
    
    static testMEthod void checkBlueLanguageAndEntityTest(){
    tUtils.SetTriggersOnForTesting();
        User ta;
        Account a;
        
        User thisUser = [Select Id From User Where Id =: UserInfo.getUserId() ];
        system.runAs ( thisUser ) {
            ta = (tUtils.addTestUsers(profileId,1,roleId))[0];
        }
        
        system.runAs ( ta ) {
            a = tUtils.addTestAccount(acctRT);
        }
        
        system.runAs ( thisUser ) {
            Opportunity o = tUtils.addTestOppt(a.Id,oppRT2,false);
            o.pricingAssignmentComplete__c=true;
            insert o;
            list<Quote> qList = new list<Quote>();
            for (Integer i = 0; i <1; i++)  {
                Quote q = tUtils.createTestQuote(a.Id,o.Id,quoteRt);
                q.CorningSellingEntity__c = Null;
                q.Language__c = Null;
                 q.currency__c =Null;
                
                qList.add(q);
            }
            insert qList;
            try{
                
            }
            catch (exception e) { //SHOULD NOT GET HERE
                // system.assertEquals(true,e.getMessage().contains('Quote cannot be saved. Blue quotes are limited to English only.'));
            }
            
            system.assertEquals (1, [SELECT Count() FROM Quote WHERE Id IN :qList]);
        }
    }
    static testMethod void testUpdateQuote(){
          TriggerSettings__c trigSettings = TriggerSettings__c.getInstance();   
        system.debug('trigSettings: '+ trigSettings);
        list<Quote> qList = new list<Quote>();
        
        User ta = (tUtils.addTestUsers(profileId,1))[0];
        Account a = tUtils.addTestAccount(acctRT);
        
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT2,false);
        o.pricingAssignmentComplete__c=true;
        insert o;
        tUtils.AddTestGGProductAndPriceBookEntry2(o,a,a);
        Product2 p1 = tUtils.addTestProduct(o.Id,'My Product 1');
        Product2 p2 = tUtils.addTestProduct(o.Id,'My Product 2');
          
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id sPricebookId = Test.getStandardPricebookId();
        Id pricebookId = '01so0000004gBaQAAU';         
        PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 5);
        PricebookEntry pbe2 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p2.id, 15);
        
        OpportunityLineItem oli1 = tUtils.createTestOLI(o.id, 5, pbe1.id);
        // oli1.deviceTracker__c = true; // AN - 8/6/18 - remove device tracker - field not used anymore
        insert oli1;
        
        
        for (Integer i = 0; i <1; i++)  {
            Quote q = tUtils.createTestQuote(a.Id,o.Id,quoteRt);           
            qList.add(q);
        }
         test.startTest();
        insert qList;
        
        
        list<QuoteLineItem> qliList = [SELECT Id, sampleAutoCreated__c, quantity, PricebookEntryId, price__c FROM QuoteLineItem WHERE QuoteId IN :qList];
        for (QuoteLineItem qli : qliList) {
            qli.quantity = 10;
            system.assertEquals(true, qli.sampleAutoCreated__c); 
        }
        update qliList;
        
        for(Quote qq: qList){
            qq.sampleRequest__c = NULL;
            qq.Status = 'Customer Accepted';            
        }
        UPDATE qList;
        
        //Delete qliList;
        system.runAs(ta) {
            list<Quote> qListAFter = new list<Quote>();
            qListAFter = [SELECT Id, PriceBook2Id FROM Quote WHERE Id IN :qList];
            for (Quote q : qListAFter) {
                system.assertNotEquals (null, q.PriceBook2Id);
            }
        }
        test.stopTest();
        
    }
    
     static testMethod void testpreventSampleDelete(){
          TriggerSettings__c trigSettings = TriggerSettings__c.getInstance();   
        system.debug('trigSettings: '+ trigSettings);
        list<Quote> qList = new list<Quote>();
        
        User ta = (tUtils.addTestUsers(profileId,1))[0];
        Account a = tUtils.addTestAccount(acctRT);
        
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT2,false);
        o.pricingAssignmentComplete__c=true;
        insert o;
        tUtils.AddTestGGProductAndPriceBookEntry2(o,a,a);
        Product2 p1 = tUtils.addTestProduct(o.Id,'My Product 1');
        Product2 p2 = tUtils.addTestProduct(o.Id,'My Product 2');
          
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id sPricebookId = Test.getStandardPricebookId();
        Id pricebookId = '01so0000004gBaQAAU';         
        PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 5);
        PricebookEntry pbe2 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p2.id, 15);
        
        OpportunityLineItem oli1 = tUtils.createTestOLI(o.id, 5, pbe1.id);
        // oli1.deviceTracker__c = true; // AN - 8/6/18 - remove device tracker - field not used anymore
        insert oli1;
        
        
        for (Integer i = 0; i <1; i++)  {
            Quote q = tUtils.createTestQuote(a.Id,o.Id,quoteRt);           
            qList.add(q);
        }
         test.startTest();
        insert qList;
        
        
        list<QuoteLineItem> qliList = [SELECT Id, sampleAutoCreated__c, quantity, PricebookEntryId, price__c FROM QuoteLineItem WHERE QuoteId IN :qList];
        for (QuoteLineItem qli : qliList) {
            qli.quantity = 10;
            system.assertEquals(true, qli.sampleAutoCreated__c); 
        }
        update qliList;
        
         Delete qliList; 
        system.runAs(ta) {
            list<Quote> qListAFter = new list<Quote>();
            qListAFter = [SELECT Id, PriceBook2Id FROM Quote WHERE Id IN :qList];
            for (Quote q : qListAFter) {
                system.assertNotEquals (null, q.PriceBook2Id);
            }
        }
        test.stopTest();
        
    }
    
    
    static testMethod void testSetOppStageName() {
        tUtils.SetTriggersOnForTesting();
        list<Quote> qList = new list<Quote>();
        
        User ta = (tUtils.addTestUsers(profileId,1))[0];
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT2,false);
        o.pricingAssignmentComplete__c=true;
        insert o;
        
        Opportunity o3 = tUtils.createTestOppt(a.Id,oppRT2);
        o3.PricingAssignmentComplete__c = true;
        insert o3;
        
        for (Integer i = 0; i <1; i++)  { // 100
            Quote q = tUtils.createTestQuote(a.Id,o.Id,quoteRt);
            qList.add(q);
        }
        for (Integer i = 0; i <1; i++)  { // 50
            Quote q3 = tUtils.createTestQuote(a.Id,o3.Id,quoteRt2);
            q3.sampleRequest__c = o3.id;
            q3.Status = 'Draft'; 
            qList.add(q3);
        }
        insert qList;
        
        test.startTest();
        String qStatus = Label.GGSampleStatusQuoteCreated;
        system.assertNotEquals(qStatus,[SELECT Id, StageName FROM Opportunity WHERE Id = :o.id].StageName);
        system.assertEquals(qStatus,[SELECT Id, StageName FROM Opportunity WHERE Id = :o3.id].StageName);
        test.stopTest();
        
    }
    
    /*
static testMethod void testCopyPartsSampleLI() {
tUtils.SetTriggersOnForTesting();
list<Quote> qList = new list<Quote>();

User ta = (tUtils.addTestUsers(profileId,1))[0];
Account a = tUtils.addTestAccount(acctRT);
// Get standard price book ID.
// This is available irrespective of the state of SeeAllData.

Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
o2.PricingAssignmentComplete__c = true;
insert o2;

Id pricebookId = Test.getStandardPricebookId();
// Create a custom price book
Pricebook2 customPB = new Pricebook2(Name='GG Price Book', isActive=true);
insert customPB;

Product2 p1 = tUtils.addTestProduct(o.Id,'My Product 1');
PricebookEntry pbe1 = tUtils.addTestPBEntry(pricebookId, p1.id, 5);
PricebookEntry pbe2 = tUtils.addTestPBEntry(customPB.Id, p1.id, 5);

Product2 p2 = tUtils.addTestProduct(o2.Id,'My Product 2');
PricebookEntry pbe3 = tUtils.addTestPBEntry(pricebookId, p2.id, 15);
PricebookEntry pbe4 = tUtils.addTestPBEntry(customPB.Id, p2.id, 15);

OpportunityLineItem oli1 = tUtils.createTestOLI(o.id, 5, pbe2.id);
insert oli1;

OpportunityLineItem oli2 = tUtils.createTestOLI(o2.id, 10, pbe4.id);
insert oli2;

for (Integer i = 0; i < 2; i++)  { // 100
Quote q = tUtils.createTestQuote(a.Id,o.Id,quoteRt);
qList.add(q);
}

for (Integer i = 0; i < 2; i++)  { // 50
Quote q2 = tUtils.createTestQuote(a.Id,o.Id,quoteRt2);
q2.sampleRequest__c = o2.id;
q2.Pricebook2Id = customPB.Id;
qList.add(q2);
}
insert qList;

test.startTest();
list<QuoteLineItem> qliList = [SELECT Id, sampleAutoCreated__c, quantity, PricebookEntryId, price__c FROM QuoteLineItem WHERE QuoteId IN :qList];
for (QuoteLineItem qli : qliList) {
system.assertEquals(true, qli.sampleAutoCreated__c); 
}
system.assertEquals(50,qliList.size()); 
test.stopTest();
} */
    
    //Owner.UserRole.Name == "GG Exclusive (Blue)" - Success
    static testMethod void BlueLanguageTest1() {
        tUtils.SetTriggersOnForTesting();
        User ta;
        Account a;
        
        User thisUser = [Select Id From User Where Id =: UserInfo.getUserId() ];
        system.runAs ( thisUser ) {
            ta = (tUtils.addTestUsers(profileId,1,roleId))[0];
        }
        
        system.runAs ( ta ) {
            a = tUtils.addTestAccount(acctRT);
        }
        
        system.runAs ( thisUser ) {
            Opportunity o = tUtils.addTestOppt(a.Id,oppRT2,false);
            o.pricingAssignmentComplete__c=true;
            insert o;
            list<Quote> qList = new list<Quote>();
            for (Integer i = 0; i <1; i++)  {
                Quote q = tUtils.createTestQuote(a.Id,o.Id,quoteRt);
                q.CorningSellingEntity__c = 'CSMI';
                q.Language__c = 'English';
                
                qList.add(q);
            }
            insert qList;
            try{
                
            }
            catch (exception e) { //SHOULD NOT GET HERE
                // system.assertEquals(true,e.getMessage().contains('Quote cannot be saved. Blue quotes are limited to English only.'));
            }
            
            system.assertEquals (1, [SELECT Count() FROM Quote WHERE Id IN :qList]);
        }
    }
    
    //Owner.UserRole.Name == "GG Exclusive (Blue)"
    static testMethod void BlueLanguageTest2() {
        tUtils.SetTriggersOnForTesting();
        User ta;
        Account a;
        
        
        User thisUser = [Select Id From User Where Id =: UserInfo.getUserId() ];
        system.runAs ( thisUser ) {
            ta = (tUtils.addTestUsers(profileId,1,roleId))[0];
        }
        
        system.runAs ( ta ) {
            a = tUtils.addTestAccount(acctRT);
        }
        
        system.runAs ( thisUser ) {
            Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
            list<Quote> qList = new list<Quote>();
            
            try {
                
                for (Integer i = 0; i < 51; i++)  {
                    Quote q = tUtils.createTestQuote(a.Id,o.Id,quoteRt);
                    q.CorningSellingEntity__c = 'CSMI';
                    qList.add(q);
                }
                insert qList;
            }
            catch (exception e) { //SHOULD GET HERE
                system.assertEquals(true,e.getMessage().contains('Quote cannot be saved. Blue quotes are limited to English only.'));
            }
        }
        
    } 
}