///*** Added for Gorilla Glass Implementation ***///
///*** AN - 7/8/2018 ***///
///*** Test Class for supply chain ***///

@isTest
public class SupplyChainTest {
    static TestUtilities tUtils = new TestUtilities();
    private static string acctRT;
    private static string oppRT;
    
    static {
        acctRT = tUtils.getRecordTypeId('Account', 'GG Account');
        oppRT = tUtils.getRecordTypeId('Opportunity', 'GG Program');
    }
    
    static testMethod void TestSupplyChain() {
        tUtils.SetTriggersOnForTesting();
        Account a = tUtils.addTestAccount(acctRT);
        a.containsPricing__c = TRUE;
        update a;
        
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        SupplyChain__c sc = new SupplyChain__c();
        
        sc.opportunity__c = o.id;
        sc.application__c = 'Other';
        sc.decisionMaker__c = a.id;
        sc.odm__c = a.id;
        sc.tpm__c = a.id;
        sc.odm__c = a.id;
        sc.finisher__c = a.id;
        sc.panelMaker__c = a.id;
        sc.lcm__c = a.id; 
        
        insert sc;

    }
}