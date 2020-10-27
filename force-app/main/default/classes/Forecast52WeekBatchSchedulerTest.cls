@isTest
private class Forecast52WeekBatchSchedulerTest {
    static TestUtilities tUtils = new TestUtilities();
    private static string acctRT;
    private static string oppRT;
    
    static {
        acctRT = tUtils.getRecordTypeId('Account', 'GG Account');
        oppRT = tUtils.getRecordTypeId('Opportunity', 'GG Program');
    }
       
static testMethod void testForecast52WeekBatchOEM() {
       
        tUtils.SetTriggersOnForTesting();
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Product2 p1 = tUtils.addDefaultForecastProduct();
          
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id sPricebookId = Test.getStandardPricebookId();
        Id pricebookId = '01so0000004gBaQAAU';         
        PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 5);
        
        //o.Start_of_Production__c = date.today().addMonths(12);
        o.createForecast__c = TRUE;
        update o;
         
        Test.startTest();
            Database.executeBatch(new Forecast52WeekBatch ('Active') , 200);
        Test.stopTest();  
    
}

static testMethod void testForecast52WeekBatchPLM() {
       
        tUtils.SetTriggersOnForTesting();
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Product2 p1 = tUtils.addDefaultForecastProduct();
          
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id sPricebookId = Test.getStandardPricebookId();
        Id pricebookId = '01so0000004gBaQAAU';         
        PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 5);
        
        //o.Start_of_Production__c = date.today().addMonths(12);
        o.createForecast__c = TRUE;
        update o;
         
        Test.startTest();
            Database.executeBatch(new Forecast52WeekBatch ('Locked') , 200);
        Test.stopTest();  
    
}


static testMethod void testForecast52WeekBatchScheduleOEM() {
    Test.startTest();
        Forecast52WeekBatchSchedulerOEM  oemJob = new Forecast52WeekBatchSchedulerOEM();     
        String sch = '0 0 2 * * ?';
        String jobId = System.schedule('Test Schedule OEM', sch, oemJob);
    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id =: jobId];
        System.assertEquals('0 0 2 * * ?', ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
    Test.stopTest();
}

static testMethod void testForecast52WeekBatchSchedulePLM() {
    Test.startTest();
        Forecast52WeekBatchSchedulerPLM plmJob = new Forecast52WeekBatchSchedulerPLM();     
        String sch = '0 0 3 * * ?';
        String jobId = System.schedule('Test Schedule PLM', sch, plmJob);
    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id =: jobId];
        System.assertEquals('0 0 3 * * ?', ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
    Test.stopTest();
}

static testMethod void testForecastArchiveBatchSchedule() {
    Test.startTest();
        ForecastArchiveBatchScheduler plmJob = new ForecastArchiveBatchScheduler();     
        String sch = '0 0 4 * * ?';
        String jobId = System.schedule('Test Schedule Archive', sch, plmJob);
    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id =: jobId];
        System.assertEquals('0 0 4 * * ?', ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
    Test.stopTest();
}


}