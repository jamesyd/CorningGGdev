@isTest
private class CustomLookUpControllerTest {
    
    static TestUtilities tUtils = new TestUtilities();
    private static string acctRT;
    
    static {
        acctRT = tUtils.getRecordTypeId('Account', 'GG Account');   
    }
    
    static testMethod void testCustomLookUpController() {
        tUtils.SetTriggersOnForTesting();
        Account a = tUtils.addTestAccount(acctRT);
        
        Test.startTest();
        CustomLookUpController.fetchLookUpValues('CompanyName', 'Account', a.Id);  
        CustomLookUpController.fetchLookUpValues('SP', 'Specification__c', a.Id);
        Test.stopTest();
        
    }
    
}