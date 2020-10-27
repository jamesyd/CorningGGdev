@isTest
private class ContractControllerTest {
    @isTest
    static void TestGetContractRecords()
    {
        Account a = new Account();
        a.name = 'Test';
        insert a;
        
        AccountContract__c ac = new AccountContract__c();
        ac.isEvergreen__c = true;
        ac.account__c = a.id;
        insert ac;
        
        ContractController.GetContractRecords(a.id);
        
    }
}