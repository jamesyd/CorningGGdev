///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 3/29/2017 ***///
///*** Class to help test sample fulfillment trigger ***///

// ConnectApi methods are not supported in data siloed tests.
// Please use @IsTest(SeeAllData=true). Class.ConnectApi.ChatterFeeds.postFeedElement

@IsTest(SeeAllData=true) // to read cusomt settings and post @mention

private class SampleFulfillmentHelperTest {
    static TestUtilities tUtils = new TestUtilities();
    private static string acctRT;
    private static string oppRT;
    private static string oppRT2;
    private static string oppRT3;
    private static string conRT;

    static {
        acctRT = '0121J000000U1cVQAS'; //tUtils.getRecordTypeId('Account', 'GG Account');
        oppRT = '0121J000000U1cZQAS'; //tUtils.getRecordTypeId('Opportunity', 'GG Program');
        oppRT2 = '0121J000000U1cYQAS'; //tUtils.getRecordTypeId('Opportunity', 'GG Parts Sample - Submitted');        
        oppRT3 = '0121J000000U1cXQAS'; //tUtils.getRecordTypeId('Opportunity', 'GG Parts Sample Request');
        conRT = '0121J000000U1cWQAS'; //tUtils.getRecordTypeId('Contact', 'GG Contact');
    }
    
    static testMethod void setOpportunityStageTest1() {
        //tUtils.SetTriggersOnForTesting();
        
        list<SampleFulfillment__c> sList = new list<SampleFulfillment__c>();
        
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
        o2.massProductionOpportunity__c = o.Id;
        insert o2;
        o2.StageName = 'Fulfillment';
        update o2;
       
        for (Integer i = 0; i < 10; i++)  {
            SampleFulfillment__c sf = tUtils.createSampleFulfillment(o2.id);
            sf.Status__c = 'Open';
            sList.add(sf);
        }
        insert sList;
        List<SampleFulfillment__c> sfs = new List<SampleFulfillment__c>();
        for (SampleFulfillment__c sf: [SELECT Id, Status__c FROM SampleFulfillment__c WHERE opportunity__c = :o2.Id]){
            sf.status__c = 'Cancelled';
            sfs.add(sf);
        }
        update sfs;
        
        test.startTest();
            system.assertEquals ('Cancelled',[SELECT StageName FROM Opportunity WHERE Id = : o2.Id].StageName);
        test.stoptest();
    }
    
    static testMethod void setOpportunityStageTest2() {
        //tUtils.SetTriggersOnForTesting();
                
        list<SampleFulfillment__c> sList = new list<SampleFulfillment__c>();

        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
        o2.massProductionOpportunity__c = o.Id;
        insert o2;
        o2.StageName = 'Fulfillment';
        update o2;
        
        for (Integer i = 0; i < 10; i++)  {
            SampleFulfillment__c sf = tUtils.createSampleFulfillment(o2.id);
            sf.Status__c = 'Shipped';
            sList.add(sf);
        }
        insert sList;
        
        test.startTest();
            system.assertEquals ('Shipped Complete',[SELECT StageName FROM Opportunity WHERE Id = : o2.Id].StageName);
        test.stoptest();
    }
    
    static testMethod void setOpportunityStageTest3() {
        //tUtils.SetTriggersOnForTesting();
        
        list<SampleFulfillment__c> sList = new list<SampleFulfillment__c>();
        
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
        o2.massProductionOpportunity__c = o.Id;
        insert o2;
        o2.StageName = 'Fulfillment';
        update o2;
        
        for (Integer i = 0; i < 5; i++)  {
            SampleFulfillment__c sf = tUtils.createSampleFulfillment(o2.id);
            sf.Status__c = 'Scheduled';
            sList.add(sf);
        }
        insert sList;
        
        test.startTest();
            system.assertEquals ('Fulfillment',[SELECT StageName FROM Opportunity WHERE Id = : o2.Id].StageName);
        test.stoptest();
    }
    
    static testMethod void checkSampleQuantitiesTest1() {
        //tUtils.SetTriggersOnForTesting();
        
        list<SampleFulfillment__c> sList = new list<SampleFulfillment__c>();
        
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
        o2.massProductionOpportunity__c = o.Id;
        o2.StageName = 'Fulfillment';
        insert o2;
        
        Product2 p1 = tUtils.addTestProduct(o2.Id,'My Product 1');
        
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id sPricebookId = Test.getStandardPricebookId();
        Id pricebookId = '01so0000004gBaQAAU';
        PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 5);
        
        OpportunityLineItem oli1 = tUtils.createTestOLI(o2.id, 50, pbe1.id);
        oli1.sampleQuantity__c = 50;
        insert oli1;
                
        test.startTest();
            for (Integer i = 0; i < 5; i++)  {
                SampleFulfillment__c sf = tUtils.createSampleFulfillment(o2.id);
                sf.Quantity__c = 50;
                sList.add(sf);
            }
            sList.get(0).status__c = 'Cancelled';
            System.debug('Cancelledlist = ' + sList);
            try {
                insert sList;
                 
            }
            catch (exception e) { //SHOULD GET HERE
                system.assertEquals(true,e.getMessage().contains(Label.GGSampleQuantityExceeded));
            }

        test.stopTest();
    } 

    /** an 1/29/18 - causing too many soql query - createOLI    
    static testMethod void checkSampleQuantitiesTest2() {
        //tUtils.SetTriggersOnForTesting();
        
        list<SampleFulfillment__c> sList = new list<SampleFulfillment__c>();
        
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
       
        Product2 p1 = tUtils.addTestProduct(o.Id,'My Product 2');
        
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id sPricebookId = Test.getStandardPricebookId();
        Id pricebookId = '01so0000004gBaQAAU';
        PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 5);
        OpportunityLineItem oli1 = tUtils.addTestOLI(o.id, 100, pbe1.id);
        
        Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
        o2.massProductionOpportunity__c = o.Id;
        o2.StageName = 'Fulfillment';
        insert o2;
 
        OpportunityLineItem oli2 = tUtils.createTestOLI(o2.id, 100, pbe1.id);
        oli2.sampleQuantity__c = 100;
        insert oli2;
        
        test.startTest();
            for (Integer i = 0; i < 5; i++)  {
                SampleFulfillment__c sf = tUtils.createSampleFulfillment(o2.id);
                sf.Quantity__c = 10;
                sList.add(sf);
            }
            
            try {
                insert sList;
            }
            catch (exception e) { //SHOULD GET HERE since sample fulfillment quantity is 150 now
                system.assertEquals(true,e.getMessage().contains(Label.GGSampleQuantityExceeded));
            }
        test.stopTest();
    } **/
    
     static testMethod void setShippingAddressTest() {
        //tUtils.SetTriggersOnForTesting();
        
        Account a = tUtils.addTestAccount(acctRT);
        Contact c = tUtils.createTestContact(a.Id, conRT);
        c.FirstName = 'Joey';
        c.MailingStreet = '1313 Mockingbird Lane';
        insert c;
       
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT3);
        o2.massProductionOpportunity__c = o.Id;
        o2.StageName = 'Fulfillment';
        o2.requestingContact__c = c.id;
        insert o2;
        
        Product2 p1 = tUtils.addTestProduct(o2.Id,'My Product 1');
          
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id sPricebookId = Test.getStandardPricebookId();
        Id pricebookId = '01so0000004gBaQAAU';
        PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 5);
        
        test.startTest();
            OpportunityLineItem oli1 = tUtils.createTestOLI(o2.id, 5, pbe1.id);
            oli1.sampleQuantity__c = 5;
            insert oli1;
        
            system.AssertEquals(1,[SELECT Count() FROM SampleFulfillment__c WHERE Opportunity__c = :o2.Id]);
            SampleFulfillment__c testSF = [SELECT streetAddress__c FROM SampleFulfillment__c WHERE Opportunity__c = :o2.id LIMIT 1];
            system.AssertEquals(Null,testSF.streetAddress__c); // AN - 8/19/18 - shipping address removed from SF record
        test.stopTest();
     }
    
    static testMethod void unitTestForCancelledStatus() {
        //tUtils.SetTriggersOnForTesting();
        
        list<SampleFulfillment__c> sList = new list<SampleFulfillment__c>();
        
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
        o2.massProductionOpportunity__c = o.Id;
        insert o2;
        o2.StageName = 'Fulfillment';
        update o2;
        List<String> emailIds = getPlannersEmailIds();
        Profile p = [SELECT Id FROM Profile WHERE Name='GG Account Manager']; 
        User u = new User(Alias = 'standt', Email = emailIds.get(0), 
            EmailEncodingKey='UTF-8', LastName='Testing92380', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg564353.com',EmployeeNumber = 'DO NOT USE');
        insert u;
        System.runAs(u) {
            // The following code runs as user 'u' 
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId()); 
            insert sList;
        }
        for (Integer i = 0; i < 10; i++)  {
            SampleFulfillment__c sf = tUtils.createSampleFulfillment(o2.id);
            sf.Status__c = 'Cancelled';
            sList.add(sf);
        }
        
        insert sList;
        List<SampleFulfillment__c> sfs = new List<SampleFulfillment__c>();
        for (SampleFulfillment__c sf: [SELECT Id, Status__c FROM SampleFulfillment__c WHERE opportunity__c = :o2.Id]){
            sf.status__c = 'Cancelled';
            sfs.add(sf);
        }
        System.runAs(u) {
            // The following code runs as user 'u' 
            
        }
        //insert sfs;
        SampleFulfillmentHelper.setShippingAddress(sList);
        test.startTest();
            system.assertEquals ('Cancelled',[SELECT StageName FROM Opportunity WHERE Id = : o2.Id].StageName);
        test.stoptest();
    }
    
    @isTest
    public static void insertPreBuildOppTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='GG Application Engineer']; 
        //UserRole ur = [SELECT ID,name FROM UserRole where name = 'GG Allocation Team/Planner' LIMIT 1];
        User u = new User(Alias = 'standt', Email = 'Test98392@gmail.com' , 
            EmailEncodingKey='UTF-8', LastName='Testing92380', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg564353.com',EmployeeNumber = 'DO NOT USE');
        insert u; 
        System.debug('User===>' + u);
         Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
        o2.massProductionOpportunity__c = o.Id;
        o2.isPreBuild__c = true;
        insert o2;
        
        o2.StageName = 'CM Assignment';
        update o2;
        SampleFulfillment__c sf = tUtils.createSampleFulfillment(o2.id);
        Insert sf;
        //sf.Status__c = 'Cancelled';
        //update sf;
        System.debug('query=$$$$$>' + [SELECT Id,Name,StageName FROM Opportunity WHERE id = :sf.Opportunity__c]);
        System.runAs(u) {
            System.debug('SFFFF===>' + sf);
            
        }
        sf.commitDate__c = Date.newInstance(2020, 09, 20);
        sf.shipDate__c = Date.newInstance(2020, 09, 20);
        Update sf;
        ID contactRT = tUtils.getRecordTypeId('Contact', 'GG Contact');
        Contact c = tUtils.addTestContact(a.id,contactRT);
        sf.shipToContact__c = c.Id;
        List<SampleFulfillment__c> samples = new List<SampleFulfillment__c>{sf};
        SampleFulfillmentHelper.setShippingAddress(samples);    
        SampleFulfillmentHelper.sendChatterNotification(samples);
    }
    
    //getting emial ids of planners that is stored in custom labels
    private static List<String> getPlannersEmailIds(){
        List<String> emailIds = new List<String>();
        if(STRING.ISNOTBLANK(System.label.PlannerEmailIds)){
            for(String emailId: System.label.PlannerEmailIds.split(';')){
                emailIds.add(emailId);
            }
        }
        return emailIds;
        //return new List<String>{'atasuperfusion@gmail.com'};
    }
}