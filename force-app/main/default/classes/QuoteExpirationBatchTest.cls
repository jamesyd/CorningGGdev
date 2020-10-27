/**
 * @File Name          : QuoteExpirationBatchTest.cls
 * @Description        : 
 * @Author             : Adam Nicholson?
 * @Group              : 
 * @Last Modified By   : Arquimidez Mora
 * @Last Modified On   : 2/7/2020 14:47:21
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.1    2/7/2020   Arquimidez Mora            Fixing test class
**/
///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 3/24/2017 ***///
///*** Test class for QuotreExpirationBatch ***///
@isTest
private class QuoteExpirationBatchTest {
    static TestUtilities tUtils = new TestUtilities();
    private static string acctRT;
    private static string oppRT;
    private static string quoteRT;
    private static string profileId;
	private static string oppRT2;
	static {
		acctRT = tUtils.getRecordTypeId('Account', 'GG Account');
        oppRT = tUtils.getRecordTypeId('Opportunity', 'GG Program');
        quoteRT = tUtils.getRecordTypeId('Quote', 'GG Parts');
        profileId = tUtils.getProfileId('GG Account Manager');
        oppRT2 = tUtils.getRecordTypeId('Opportunity', 'GG Parts Sample Request');
	}
			
	static testMethod void testQuoteExpirationBatch() {
		tUtils.SetTriggersOnForTesting();
        list<Quote> qList = new list<Quote>();
        list<Quote> qListA = new list<Quote>();
        list<Quote> qListB = new list<Quote>();
        
        User ta = (tUtils.addTestUsers(profileId,1))[0];
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
        o2.massProductionOpportunity__c = o.Id;
        o2.pricingAssignmentComplete__c = true;
        insert o2;
        
        for (Integer i = 0; i < 100; i++)  {
            Quote q = tUtils.createTestQuote(a.Id,o2.Id,quoteRt);
            q.ExpirationDate = date.today().addDays(1);
            qList.add(q);
        }
        for (Integer i = 0; i < 100; i++)  {
            Quote q2 = tUtils.createTestQuote(a.Id,o2.Id,quoteRt);
            q2.ExpirationDate = date.today().addDays(-1);
            qList.add(q2);
        }
        insert qList;
        
		Test.startTest();
            Database.executeBatch(new QuoteExpirationBatch(), 200);
        Test.stopTest();	

		qListA = [SELECT Id FROM Quote WHERE Status = 'Expired'];
		system.assertEquals(100, qListA.size());
		qListB = [SELECT Id FROM Quote WHERE Status <> 'Expired'];
		system.assertEquals(100, qListB.size());
	}
	
	static testMethod void testQuoteExpirationBatchScheduler() {
		Test.startTest();
			QuoteExpirationBatch scheduledJob = new QuoteExpirationBatch();	   
			String sch = '0 0 2 * * ?';
			String jobId = System.schedule('Test Schedule', sch, scheduledJob);
			
			CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id =: jobId];
			System.assertEquals('0 0 2 * * ?', ct.CronExpression);
			System.assertEquals(0, ct.TimesTriggered);
		Test.stopTest();
	}
}