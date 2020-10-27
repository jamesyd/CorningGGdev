// ConnectApi methods are not supported in data siloed tests.
// Please use @IsTest(SeeAllData=true). Class.ConnectApi.ChatterFeeds.postFeedElement

@IsTest(SeeAllData=true)
private class ChatterHelperSamplesTest {
    static TestUtilities tUtils = new TestUtilities();
    private static string acctRT;
    private static string oppRT;
    private static string oppRT2;
    private static string oppRT3;
    private static string oppRT4;
    private static string oppRT5;    
    
    static {
        acctRT = '0121J000000U1cVQAS'; //tUtils.getRecordTypeId('Account', 'GG Account');
        oppRT = '0121J000000U1cZQAS'; //tUtils.getRecordTypeId('Opportunity', 'GG Program');
        oppRT2 = '0121J000000U1cXQAS'; //tUtils.getRecordTypeId('Opportunity', 'GG Parts Sample Request');
        oppRT3 = '0121J000000U1cYQAS'; //tUtils.getRecordTypeId('Opportunity', 'GG Parts Sample - Submitted');        
        oppRT4 = '0121J000000U1caQAC'; //tUtils.getRecordTypeId('Opportunity', 'GG Raw Glass/Concore Sample Request');        
        oppRT5 = '0121J000000U1cbQAC'; //tUtils.getRecordTypeId('Opportunity', 'GG Raw Glass/Concore Sample - Submitted');        
    }
    
    // Parts-: New -> CM Assignment
    static testMethod void validatePartsN2CA() {
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
        o2.massProductionOpportunity__c = o.Id;
        o2.StageName = 'New';
        insert o2;
        
        Product2 p1 = tUtils.addTestProduct(o2.Id,'My Product 1');
        
        Id sPricebookId = Test.getStandardPricebookId();
        Id pricebookId = '01so0000004gBaQAAU';
        PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 5);
        
        OpportunityLineItem oli1 = tUtils.createTestOLI(o2.id, 1, pbe1.id);
        oli1.sampleQuantity__c = 50;
        insert oli1;
        
        o2.sampleCmLocations__c = 'Fuzhou';
        o2.sampleGlassComposition__c = '2320';
        o2.sampleInnovations__c = 'Vibrant';
        o2.numberCmLocations__c = 2;
        o2.submitForApproval__c = True;
        o2.StageName = 'CM Assignment';
        update o2; 
        
    }
    
    // Parts-: New -> Pricing Assignment
    static testMethod void validatePartsN2PA() {
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
        o2.massProductionOpportunity__c = o.Id;
        o2.StageName = 'New';
        insert o2;
        
        Product2 p1 = tUtils.addTestProduct(o2.Id,'My Product 1');
        
        Id sPricebookId = Test.getStandardPricebookId();
        Id pricebookId = '01so0000004gBaQAAU';
        PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 5);
        
        OpportunityLineItem oli1 = tUtils.createTestOLI(o2.id, 1, pbe1.id);
        oli1.sampleQuantity__c = 50;
        insert oli1;
        
        o2.sampleCmLocations__c = 'Fuzhou';
        o2.sampleGlassComposition__c = '2320';
        o2.sampleInnovations__c = 'Vibrant';
        o2.numberCmLocations__c = 1;
        o2.submitForApproval__c = True; 
        o2.stageName = 'RSM Approval';
        update o2;
        o2.stageName = 'Non-paid Declined';
        update o2;
        o2.StageName = 'Pricing Assignment';
        update o2; 
        
        o2.StageName = 'Customer Quotation';
        update o2; 
    }
    
    // Parts-: CM Assignment -> Pricing Assignment
    static testMethod void validatePartsCA2PA() {
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
        o2.massProductionOpportunity__c = o.Id;
        o2.StageName = 'New';
        insert o2;
        
        Product2 p1 = tUtils.addTestProduct(o2.Id,'My Product 1');
        
        Id sPricebookId = Test.getStandardPricebookId();
        Id pricebookId = '01so0000004gBaQAAU';
        PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 5);
        
        OpportunityLineItem oli1 = tUtils.createTestOLI(o2.id, 1, pbe1.id);
        oli1.sampleQuantity__c = 50;
        insert oli1;
        
        o2.sampleCmLocations__c = 'Fuzhou';
        o2.sampleGlassComposition__c = '2320';
        o2.sampleInnovations__c = 'Vibrant';
        o2.numberCmLocations__c = 2;
        o2.submitForApproval__c = True;
        o2.StageName = 'CM Assignment';
        update o2;   
        
        SampleFulfillment__c sf = [SELECT id, fulfillmentLocation__c FROM SampleFulfillment__c LIMIT 1];
        sf.fulfillmentLocation__c = 'Fuzhou';
        update sf;
        
        o2.StageName = 'Pricing Assignment';
        update o2;   
    }
    
    // Parts-: Pricing Assignment -> Customer Quotation 
    /*
static testMethod void validatePartsPA2CQ() {
Account a = tUtils.addTestAccount(acctRT);
Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
o2.massProductionOpportunity__c = o.Id;
o2.StageName = 'New';
insert o2;

Product2 p1 = tUtils.addTestProduct(o2.Id,'My Product 1');

Id sPricebookId = Test.getStandardPricebookId();
Id pricebookId = '01so0000004gBaQAAU';
PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 5);

OpportunityLineItem oli1 = tUtils.createTestOLI(o2.id, 1, pbe1.id);
oli1.sampleQuantity__c = 50;
insert oli1;

o2.sampleCmLocations__c = 'Fuzhou';
o2.sampleGlassComposition__c = '2320';
o2.sampleInnovations__c = 'Vibrant';
o2.numberCmLocations__c = 1;
o2.submitForApproval__c = True;
o2.StageName = 'Pricing Assignment';
update o2;  

o2.pricingAssignmentComplete__c = TRUE;
o2.StageName = 'Customer Quotation';
update o2;  
} */
    
    // Parts-: Customer Quotation -> Non-paid Request + Approve
    static testMethod void validatePartsCQ2NPR() {
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
        o2.massProductionOpportunity__c = o.Id;
        o2.StageName = 'Customer Quotation';
        o2.sampleCmLocations__c = 'Fuzhou';
        o2.sampleGlassComposition__c = '2320';
        o2.sampleInnovations__c = 'Vibrant';
        o2.numberCmLocations__c = 1;
        o2.RecordTypeId = '0121J000000U1cYQAS';
        o2.pricingAssignmentComplete__c = TRUE;
        o2.requestFreeSample__c = 'Yes';
        o2.internalChargeNumber__c  = 'abc123';
        insert o2;
        
        o2.StageName = 'Non-paid Request';
        update o2;
        
        o2.freeApproved__c = 'Yes';
        o2.StageName = 'Order Pending';
        update o2;                
    }
    
    // Parts-: Customer Quotation -> Non-paid Request + Decline
    static testMethod void validatePartsCQ2NPD() {
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
        o2.massProductionOpportunity__c = o.Id;
        o2.StageName = 'Customer Quotation';
        o2.sampleCmLocations__c = 'Fuzhou';
        o2.sampleGlassComposition__c = '2320';
        o2.sampleInnovations__c = 'Vibrant';
        o2.numberCmLocations__c = 1;
        o2.RecordTypeId = '0121J000000U1cYQAS';
        o2.pricingAssignmentComplete__c = TRUE;
        o2.requestFreeSample__c = 'Yes';
        o2.internalChargeNumber__c  = 'abc123';
        insert o2;
        
        o2.StageName = 'Non-paid Request';
        update o2;
        
        o2.freeApproved__c = 'No';
        o2.declineReason__c = 'Supply Constraint';
        o2.StageName = 'Non-paid Declined';
        update o2;        
        
    }
    
    // Parts-: Cancelled
    static testMethod void validatePartsCancelled() {
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
        o2.massProductionOpportunity__c = o.Id;
        o2.StageName = 'New';
        insert o2;
        
        Product2 p1 = tUtils.addTestProduct(o2.Id,'My Product 1');
        
        Id sPricebookId = Test.getStandardPricebookId();
        Id pricebookId = '01so0000004gBaQAAU';
        PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 5);
        
        OpportunityLineItem oli1 = tUtils.createTestOLI(o2.id, 1, pbe1.id);
        oli1.sampleQuantity__c = 50;
        insert oli1;
        
        o2.sampleCmLocations__c = 'Fuzhou';
        o2.sampleGlassComposition__c = '2320';
        o2.sampleInnovations__c = 'Vibrant';
        o2.numberCmLocations__c = 1;
        o2.submitForApproval__c = True;
        o2.StageName = 'Pricing Assignment';        
        update o2;
        
        o2.StageName = 'Cancelled';        
        update o2;
        
    }
    
    // Raw: New -> Commercial Assessment
    static testMethod void validateRawN2CA() {
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT4);
        o2.massProductionOpportunity__c = o.Id;
        o2.StageName = 'New';
        insert o2;
        
        Product2 p1 = tUtils.addTestProduct(o2.Id,'My Product 1');
        
        Id sPricebookId = Test.getStandardPricebookId();
        Id pricebookId = '01so0000004gBaQAAU';
        PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 5);
        
        OpportunityLineItem oli1 = tUtils.createTestOLI(o2.id, 1, pbe1.id);
        oli1.sampleQuantity__c = 50;
        insert oli1;
        
        o2.sampleGlassComposition__c = '2320';
        o2.submitForApproval__c = True;
        o2.StageName = 'Commercial Assessment';
        update o2;         
    }
    
    // Raw: Commercial Assessment -> PLM Assessment -> Customer Quotation
    static testMethod void validateRawCA2CQ() {
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT4);
        o2.massProductionOpportunity__c = o.Id;
        o2.StageName = 'New';
        insert o2;
        
        Product2 p1 = tUtils.addTestProduct(o2.Id,'My Product 1');
        
        Id sPricebookId = Test.getStandardPricebookId();
        Id pricebookId = '01so0000004gBaQAAU';
        PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 5);
        
        OpportunityLineItem oli1 = tUtils.createTestOLI(o2.id, 1, pbe1.id);
        oli1.sampleQuantity__c = 50;
        insert oli1;
        
        o2.sampleGlassComposition__c = '2320';
        o2.submitForApproval__c = True;
        o2.StageName = 'Commercial Assessment';
        update o2;
        
        o2.commercialApproved__c = 'Yes';
        o2.StageName = 'PLM Assessment';
        update o2;
        
        o2.plmApproved__c = 'Yes';
        o2.StageName = 'Customer Quotation';
        update o2;         
    }
    
    // Raw-: Customer Quotation -> Non-paid Request + Approve
    static testMethod void validateRawCQ2NPR() {
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT4);
        o2.massProductionOpportunity__c = o.Id;        
        o2.StageName = 'Customer Quotation';
        o2.sampleGlassComposition__c = '2320';
        o2.RecordTypeId = '0121J000000U1cbQAC';
        o2.commercialApproved__c = 'Yes';
        o2.plmApproved__c = 'Yes';
        o2.requestFreeSample__c = 'Yes';
        o2.internalChargeNumber__c  = 'abc123';
        insert o2;
        
        o2.StageName = 'Non-paid Request';
        update o2;
        
        o2.freeApproved__c = 'Yes';
        o2.StageName = 'Order Pending';
        update o2;                
    }
    
    // Raw-: Customer Quotation -> Non-paid Request + Decline
    static testMethod void validateRawCQ2NPD() {
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT4);
        o2.massProductionOpportunity__c = o.Id;
        o2.StageName = 'Customer Quotation';
        o2.sampleGlassComposition__c = '2320';
        o2.RecordTypeId = '0121J000000U1cbQAC';
        o2.commercialApproved__c = 'Yes';
        o2.plmApproved__c = 'Yes';
        o2.requestFreeSample__c = 'Yes';
        o2.internalChargeNumber__c  = 'abc123';
        insert o2;
        
        o2.StageName = 'Non-paid Request';
        update o2;
        
        o2.freeApproved__c = 'No';
        o2.declineReason__c = 'Supply Constraint';
        o2.StageName = 'Non-paid Declined';
        update o2;        
        
    }
    
    static testMethod void validateRawCancelled() {
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT4);
        o2.massProductionOpportunity__c = o.Id;
        o2.StageName = 'New';
        insert o2;
        
        Product2 p1 = tUtils.addTestProduct(o2.Id,'My Product 1');
        
        Id sPricebookId = Test.getStandardPricebookId();
        Id pricebookId = '01so0000004gBaQAAU';
        PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 5);
        
        OpportunityLineItem oli1 = tUtils.createTestOLI(o2.id, 1, pbe1.id);
        oli1.sampleQuantity__c = 50;
        insert oli1;
        
        o2.sampleGlassComposition__c = '2320';
        o2.submitForApproval__c = True;
        update o2;
        
        o2.StageName = 'Cancelled';
        update o2;
        
    }
    
    @IsTest
    public static void unitTestForSampleReminder(){
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
        Opportunity o3 = tUtils.createTestOppt(a.Id,oppRT3);
        Opportunity o4 = tUtils.createTestOppt(a.Id,oppRT3);
        Opportunity o5 = tUtils.createTestOppt(a.Id,oppRT3);
        Opportunity o6 = tUtils.createTestOppt(a.Id,oppRT4);
        Opportunity o7 = tUtils.createTestOppt(a.Id,oppRT4);
        Opportunity o8 = tUtils.createTestOppt(a.Id,oppRT4);
        o2.massProductionOpportunity__c = o.Id;
        o2.StageName = 'CM Assignment'; 
        o2.reminderCompleted__c = false;
        o2.statusChangeDate__c = Date.Today().addDays(-4);
        
        
        o3.StageName = 'Pricing Assignment'; 
        o3.reminderCompleted__c = false;
        o3.statusChangeDate__c = Date.Today().addDays(-7);
        
        o4.massProductionOpportunity__c = o.Id;
        o4.StageName = 'RSM Approval'; 
        o4.reminderCompleted__c = false;
        o4.statusChangeDate__c = Date.Today().addDays(-5);
        
        o5.StageName = 'Customer Quotation'; 
        o5.reminderCompleted__c = false;
        o5.statusChangeDate__c = Date.Today().addDays(-8);
        
        o6.massProductionOpportunity__c = o.Id;
        o6.StageName = 'Commercial Assessment';
        o6.reminderCompleted__c = false;
        o6.statusChangeDate__c = Date.Today().addDays(-4); 
        
        o7.StageName = 'PLM Assessment';
        o7.reminderCompleted__c = false;
        o7.statusChangeDate__c = Date.Today().addDays(-4);
        o7.sampleGlassComposition__c = '3318';
        
        o8.massProductionOpportunity__c = o.Id;
        o8.StageName = 'Customer Quotation';
        o8.reminderCompleted__c = false;
        o8.statusChangeDate__c = Date.Today().addDays(-4);
        
        GGPartsSampleAutoNotifications__c cSetting = new GGPartsSampleAutoNotifications__c(Name = 'Free'
                                                                                           , message__c = 'test message'
                                                                                           , userIdList__c = '{005o0000003emHYAAY}');
        INSERT cSetting;
        List<Opportunity> opportunities = new List<Opportunity>{o2, o3, o4, o5, o6,o7, o8}; 
            insert opportunities;
        Test.startTest();
        ChatterHelperSamples.sampleReminder(opportunities);
        Test.stopTest();
    }
}