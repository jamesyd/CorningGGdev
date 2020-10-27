@IsTest
private class SampleReminderBatchTest {
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
      
static testMethod void testSampleReminderBatch() {

        // add custom settings
        List<GGPartsSampleAutoNotifications__c> csParts = new List<GGPartsSampleAutoNotifications__c>();
        csParts.add(new GGPartsSampleAutoNotifications__c(Name = 'N~MA', message__c = '*', userIdList__c = '{005o0000001BKMPAA4}'));
        csParts.add(new GGPartsSampleAutoNotifications__c(Name = 'N~PA', message__c = '*', userIdList__c = '{005o0000001BKMPAA4}'));        
        csParts.add(new GGPartsSampleAutoNotifications__c(Name = 'Quote', message__c = '*', userIdList__c = '{005o0000001BKMPAA4}'));        
        csParts.add(new GGPartsSampleAutoNotifications__c(Name = 'Free', message__c = '*', userIdList__c = '{005o0000001BKMPAA4}'));        
        insert csParts;
        
        List<GGRawSampleAutoNotifications__c> csRaw = new List<GGRawSampleAutoNotifications__c>();
        csRaw.add(new GGRawSampleAutoNotifications__c(Name = 'N~CA', message__c = '*', userIdList__c = '{005o0000001BKMPAA4}'));
        csRaw.add(new GGRawSampleAutoNotifications__c(Name = 'CA~PA~2320', message__c = '*', userIdList__c = '{005o0000001BKMPAA4}'));        
        csRaw.add(new GGRawSampleAutoNotifications__c(Name = 'Quote', message__c = '*', userIdList__c = '{005o0000001BKMPAA4}'));        
        csRaw.add(new GGRawSampleAutoNotifications__c(Name = 'Free~Other', message__c = '*', userIdList__c = '{005o0000001BKMPAA4}'));        
        insert csRaw;
       
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
        Opportunity o3 = tUtils.createTestOppt(a.Id,oppRT2);
        Opportunity o4 = tUtils.createTestOppt(a.Id,oppRT2);
        Opportunity o5 = tUtils.createTestOppt(a.Id,oppRT2);

        Opportunity o6 = tUtils.createTestOppt(a.Id,oppRT4);
        Opportunity o7 = tUtils.createTestOppt(a.Id,oppRT4);
        Opportunity o8 = tUtils.createTestOppt(a.Id,oppRT4);
        Opportunity o9 = tUtils.createTestOppt(a.Id,oppRT4);
        
        o2.massProductionOpportunity__c = o.Id;
        o2.StageName = 'New';
        insert o2;
        
        Product2 p1 = tUtils.addTestProduct(o2.Id,'My Product 1');
        
        Id sPricebookId = Test.getStandardPricebookId();
        Id pricebookId = '01so0000004gBaQAAU';
        PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 5);
        
        OpportunityLineItem oli2 = tUtils.createTestOLI(o2.id, 1, pbe1.id);
        oli2.sampleQuantity__c = 50;
        insert oli2;
                        
        SampleFulfillment__c sf2 = tUtils.createSampleFulfillment(o2.id);
        sf2.Quantity__c = 50;
        insert sf2;

        o2.sampleCmLocations__c = 'Biel';
        o2.sampleGlassComposition__c = '2320';
        o2.sampleInnovations__c = 'Vibrant';
        o2.numberCmLocations__c = 1;
        o2.submitForApproval__c = True;
        update o2;

        o2.statusChangeDate__c = Date.newInstance(1988, 2, 17);        
        o2.StageName = 'CM Assignment';
        update o2;

        // *****

        o3.massProductionOpportunity__c = o.Id;
        o3.StageName = 'New';
        insert o3;
        
        OpportunityLineItem oli3 = tUtils.createTestOLI(o3.id, 1, pbe1.id);
        oli3.sampleQuantity__c = 50;
        insert oli3;

        SampleFulfillment__c sf3 = tUtils.createSampleFulfillment(o3.id);
        sf3.Quantity__c = 50;
        insert sf3;

        o3.sampleCmLocations__c = 'Biel';
        o3.sampleGlassComposition__c = '2320';
        o3.sampleInnovations__c = 'Vibrant';
        o3.numberCmLocations__c = 1;
        o3.submitForApproval__c = True;
        update o3;
        
        o3.statusChangeDate__c = Date.newInstance(1988, 2, 17);
        o3.StageName = 'Pricing Assignment';
        update o3;

        // *****

        o4.massProductionOpportunity__c = o.Id;
        o4.StageName = 'New';
        insert o4;
        
        OpportunityLineItem oli4 = tUtils.createTestOLI(o4.id, 1, pbe1.id);
        oli4.sampleQuantity__c = 50;
        insert oli4;

        SampleFulfillment__c sf4 = tUtils.createSampleFulfillment(o4.id);
        sf4.Quantity__c = 50;
        insert sf4;

        o4.sampleCmLocations__c = 'Biel';
        o4.sampleGlassComposition__c = '2320';
        o4.sampleInnovations__c = 'Vibrant';
        o4.numberCmLocations__c = 1;
        o4.submitForApproval__c = True;
        update o4;
        
        o4.statusChangeDate__c = Date.newInstance(1988, 2, 17);
        o4.StageName = 'Customer Quotation';
        update o4;
        
        // *****

        o5.massProductionOpportunity__c = o.Id;
        o5.StageName = 'New';
        insert o5;
        
        OpportunityLineItem oli5 = tUtils.createTestOLI(o5.id, 1, pbe1.id);
        oli5.sampleQuantity__c = 50;
        insert oli5;

        SampleFulfillment__c sf5 = tUtils.createSampleFulfillment(o5.id);
        sf5.Quantity__c = 50;
        insert sf5;

        o5.sampleCmLocations__c = 'Biel';
        o5.sampleGlassComposition__c = '2320';
        o5.sampleInnovations__c = 'Vibrant';
        o5.numberCmLocations__c = 1;
        o5.submitForApproval__c = True;
        update o5;
        
        o5.statusChangeDate__c = Date.newInstance(1988, 2, 17);
        o5.StageName = 'Non-paid Request';
        update o5;

        // ***** RAW *****
        
        o6.massProductionOpportunity__c = o.Id;
        o6.StageName = 'New';
        insert o6;
        
        OpportunityLineItem oli6 = tUtils.createTestOLI(o6.id, 1, pbe1.id);
        oli6.sampleQuantity__c = 50;
        insert oli6;
                        
        SampleFulfillment__c sf6 = tUtils.createSampleFulfillment(o6.id);
        sf6.Quantity__c = 50;
        insert sf6;

        o6.sampleGlassComposition__c = '2320';
        o6.submitForApproval__c = True;
        update o6;

        o6.statusChangeDate__c = Date.newInstance(1988, 2, 17);        
        o6.StageName = 'Commercial Assessment';
        update o6;

        // *****

        o7.massProductionOpportunity__c = o.Id;
        o7.StageName = 'New';
        insert o7;
        
        OpportunityLineItem oli7 = tUtils.createTestOLI(o7.id, 1, pbe1.id);
        oli7.sampleQuantity__c = 50;
        insert oli7;

        SampleFulfillment__c sf7 = tUtils.createSampleFulfillment(o7.id);
        sf7.Quantity__c = 50;
        insert sf7;

        o7.sampleGlassComposition__c = '2320';
        o7.submitForApproval__c = True;
        update o7;
        
        o7.statusChangeDate__c = Date.newInstance(1988, 2, 17);
        o7.StageName = 'PLM Assessment';
        update o7;

        // *****

        o8.massProductionOpportunity__c = o.Id;
        o8.StageName = 'New';
        insert o8;
        
        OpportunityLineItem oli8 = tUtils.createTestOLI(o8.id, 1, pbe1.id);
        oli8.sampleQuantity__c = 50;
        insert oli8;

        SampleFulfillment__c sf8 = tUtils.createSampleFulfillment(o8.id);
        sf8.Quantity__c = 50;
        insert sf8;

        o8.sampleGlassComposition__c = '2320';
        o8.submitForApproval__c = True;
        update o8;
        
        o8.statusChangeDate__c = Date.newInstance(1988, 2, 17);
        o8.StageName = 'Customer Quotation';
        update o8;
        
        // *****

        o9.massProductionOpportunity__c = o.Id;
        o9.StageName = 'New';
        insert o9;
        
        OpportunityLineItem oli9 = tUtils.createTestOLI(o9.id, 1, pbe1.id);
        oli9.sampleQuantity__c = 50;
        insert oli9;

        SampleFulfillment__c sf9 = tUtils.createSampleFulfillment(o9.id);
        sf9.Quantity__c = 50;
        insert sf9;

        o9.sampleGlassComposition__c = '2320';
        o9.submitForApproval__c = True;
        update o9;
        
        o9.statusChangeDate__c = Date.newInstance(1988, 2, 17);
        o9.StageName = 'Non-paid Request';
        update o9;

        Test.startTest();
            Database.executeBatch(new SampleReminderBatch(), 200);
        Test.stopTest();  
    
}

static testMethod void testSampleReminderBatchScheduler() {
    Test.startTest();
        SampleReminderScheduler scheduledJob = new SampleReminderScheduler();     
        String sch = '0 0 2 * * ?';
        String jobId = System.schedule('Test Schedule', sch, scheduledJob);
    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id =: jobId];
        System.assertEquals('0 0 2 * * ?', ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
    Test.stopTest();
}
}