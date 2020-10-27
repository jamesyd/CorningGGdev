@isTest
private class HomePageOpportunityControllerTest {

    static TestUtilities tUtils = new TestUtilities();
    private static string acctRT;
    private static string oppRT;
     
    static {
        acctRT = tUtils.getRecordTypeId('Account', 'GG Account');
        oppRT = tUtils.getRecordTypeId('Opportunity', 'GG Program'); 
    }  
        
    @isTest
    static void TestGetOpportunityRecords() {
         Account a = tUtils.addTestAccount(acctRT);
        a.accountType__c = 'TPM';
        update a;
        
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        
        HomePageOpportunityController.getOpportunityRecords();
        
    }
}