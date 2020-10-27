/*********
    Name            : OpportunityChatterNotificationTest
    Description     : This is a test class OpportunityChatterNotificationBatch 
                      and OpportunityChatterNotificationBatch
                      
********/

@IsTest
public class OpportunityChatterNotificationTest{
    
    static TestUtilities tUtils = new TestUtilities();
    private static string opptRT;
    private static string acctRT;

    static {
        acctRT = tUtils.getRecordTypeId('Account', 'GG Account');
        opptRT = tUtils.getRecordTypeId('Opportunity', 'GG Program');        
    }
    
    @isTest(SeeAllData=true)
    public static void testUnit(){
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id, opptRT);
        test.startTest();
        String sch = '0 0 2 * * ?';
        String jobId = System.schedule('Test Schedule OEM',  sch, new OpportunityChatterNotificationScheduler());
        test.stopTest();
    }
}