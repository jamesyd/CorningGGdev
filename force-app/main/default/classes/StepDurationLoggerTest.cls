///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 2/5/2017 ***///
///*** Test Class for Class to log step duration changes for specification and opportunity changes ***///

@isTest
public class StepDurationLoggerTest {
    static TestUtilities tUtils = new TestUtilities();
    private static string acctRT;
    private static string oppRT;
    private static string oppRT2;
    private static string specRT;
    
    static {
        acctRT = tUtils.getRecordTypeId('Account', 'GG Account');
        oppRT = tUtils.getRecordTypeId('Opportunity', 'GG Program');
        oppRT2 = tUtils.getRecordTypeId('Opportunity', 'GG Parts Sample Request');
        specRT = tUtils.getRecordTypeId('Specification__c', 'Parts');
    }
    
    static testMethod void LogSpecificationStepTest() {
        tUtils.SetTriggersOnForTesting();
        Account a = tUtils.addTestAccount(acctRT, 'TPM');
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Specification__c testSpec = tUtils.addTestSpec(a.id, o.id, specRT);
        Datetime testTime = [SELECT previousStepDateTime__c from Specification__c WHERE Id = :testSpec.Id].previousStepDateTime__c;
        
        integer i = [SELECT Count() FROM StepDuration__c WHERE Opportunity__c = :o.id];
        system.assertEquals(0,i);
            
        testSpec.status__c = 'Standard Assessment';
        update testSpec;
        
    }
    
    static testMethod void LogOpportunityStepTest1() {
        tUtils.SetTriggersOnForTesting();
        Account a = tUtils.addTestAccount(acctRT, 'TPM');
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT2);
        
        Datetime testTime = [SELECT previousStepDateTime__c from Opportunity WHERE Id = :o.Id].previousStepDateTime__c;
        integer i = [SELECT Count() FROM StepDuration__c WHERE Opportunity__c = :o.id];
            
        o.Stagename = '3 - Evaluate Options';
        update o;
        
        test.startTest();
            system.assertEquals(i+1,[SELECT Count() FROM StepDuration__c WHERE Opportunity__c = :o.id]);
            //StepDuration__c post = [SELECT Id, previousStepDateTime__c FROM StepDuration__c WHERE opportunity__c = :o.id];
            //system.assertEquals(testTime,post.previousStepDateTime__c[);
        test.stopTest();
    }

    static testMethod void LogOpportunityStepTest2() {
        tUtils.SetTriggersOnForTesting();
        
        Account a = tUtils.addTestAccount(acctRT, 'TPM');
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        
        Datetime testTime = [SELECT previousStepDateTime__c from Opportunity WHERE Id = :o.Id].previousStepDateTime__c;
        integer i = [SELECT Count() FROM StepDuration__c WHERE Opportunity__c = :o.id];
        system.assertEquals(0,i);
            
        o.Stagename = '3 - Evaluate Options';
        update o;
        
        test.startTest();
            system.assertEquals(0,[SELECT Count() FROM StepDuration__c WHERE Opportunity__c = :o.id]);
        test.stopTest();
    }


    static testMethod void CreateStepDurationRecordTest() {
        list<StepDuration__c> b4List = new list<StepDuration__c>();
        
        Id bId = StepDurationLogger.getMondayFridayBusinessHours();
        system.assertEquals(0,b4List.size());
        
        Account a = tUtils.addTestAccount(acctRT, 'TPM');
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Specification__c testSpec = tUtils.addTestSpec(a.id, o.id, specRT);
        datetime previousStepDateTime = system.Now();
        StepDurationLogger.CreateStepDurationRecord('SPEC', b4List, testSpec.Id, 'New', 'Standard Assessment', previousStepDateTime, bId);
        
        
        system.assertEquals(1,b4List.size());
    }
}