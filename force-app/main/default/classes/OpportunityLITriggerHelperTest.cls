/**
 * @File Name          : OpportunityLITriggerHelperTest.cls
 * @Description        : 
 * @Author             : Adam Nicholson? Atageldi Atageldiyev?
 * @Group              : 
 * @Last Modified By   : Arquimidez Mora
 * @Last Modified On   : 30/6/2020 11:51:58
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    30/6/2020   Arquimidez Mora            Fix test delete opp line items
**/
///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 3/22/2017 ***///
///*** Class to help opportunity li trigger ***///
@isTest
private class OpportunityLITriggerHelperTest {
    static TestUtilities tUtils = new TestUtilities();
    private static string acctRT;
    private static string oppRT;
    private static string oppRT2;
    private static string conRT;
    
    static {
        acctRT = tUtils.getRecordTypeId('Account', 'GG Account');
        oppRT = tUtils.getRecordTypeId('Opportunity', 'GG Program');
        oppRT2 = tUtils.getRecordTypeId('Opportunity', 'GG Parts Sample Request');
        conRT = tUtils.getRecordTypeId('Contact', 'GG Contact');
    }
    
    static testMethod void DeviceTrackerDeleteTest() {
        tUtils.SetTriggersOnForTesting();
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt2(a.Id,oppRT,true);
        Product2 p1 = tUtils.addTestProductSecond(o.Id,'My Product 1');
        Product2 p2 = tUtils.addTestProductSecond(o.Id,'My Product 2');
          
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id sPricebookId = Test.getStandardPricebookId();
        Id pricebookId = '01so0000004gBaQAAU';         
        PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 5);
        PricebookEntry pbe2 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p2.id, 15);
        
        OpportunityLineItem oli1 = tUtils.createTestOLI(o.id, 5, pbe1.id);
        // oli1.deviceTracker__c = true; // AN - 8/6/18 - remove device tracker - field not used anymore
        insert oli1;
        
        OpportunityLineItem oli2 = tUtils.createTestOLI(o.id, 10, pbe2.id);
        oli2.deviceTracker__c = false;
        insert oli2;
        
        test.startTest();
            try {
                delete oli1;
            }
            catch (exception e) { //SHOULD GET HERE
                system.assertEquals(true,e.getMessage().contains(Label.DeleteOLIError));
            }
            
            try {
                delete oli2;
            }
            catch (exception e) { //SHOULD NOT GET HERE
                system.assertEquals(true,e.getMessage().contains(Label.DeleteOLIError));
            }
        test.stopTest();
    }
    
    static testMethod void setSampleFulfillmentTest1() {
        tUtils.SetTriggersOnForTesting();
        Account a = tUtils.addTestAccount(acctRT);
        Contact c = tUtils.createTestContact(a.Id, conRT);
        c.FirstName = 'Joey';
        insert c;
        
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
        o2.massProductionOpportunity__c = o.Id;
        o2.StageName = 'Fulfillment';
        o2.requestingContact__c = c.id;
        
        insert o2;
        
        Product2 p1 = tUtils.addTestProduct(o2.Id,'My Product 1');
          
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id sPricebookId = Test.getStandardPricebookId();
        Id pricebookId = '01so0000004gBaQAAU';         
        PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 8);
        
        test.startTest();
            OpportunityLineItem oli1 = tUtils.createTestOLI(o2.id, 5, pbe1.id);
            oli1.sampleQuantity__c = 5;
            insert oli1;
            
            system.AssertEquals(1,[SELECT Count() FROM SampleFulfillment__c WHERE Opportunity__c = :o2.Id AND Quantity__c = 5]);
        test.stopTest();
    }
    
    static testMethod void setSampleFulfillmentTest2() {     
        tUtils.SetTriggersOnForTesting();
        Account a = tUtils.addTestAccount(acctRT);
        Contact c = tUtils.createTestContact(a.Id, conRT);
        c.FirstName = 'Joey';
        insert c;
        Contact c2 = tUtils.createTestContact(a.Id, conRT);
        c2.FirstName = 'Wally';
        insert c2;
        Opportunity o = tUtils.addTestOppt2(a.Id,oppRT,true);
        Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
        o2.massProductionOpportunity__c = o.Id;
        o2.StageName = 'Fulfillment';
        o2.requestingContact__c = c.id;
        o2.internalChargeNumber__c = '2324';
        insert o2;
        
        Product2 p1 = tUtils.addTestProductSecond(o2.Id,'My Product 1');
        
        
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id sPricebookId = Test.getStandardPricebookId();
        Id pricebookId = '01so0000004gBaQAAU';         
        PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 8);
        
        OpportunityLineItem oli1 = tUtils.createTestOLI(o2.id, 5, pbe1.id);
        oli1.sampleQuantity__c = 5;
        insert oli1;
        
        Opportunity tempOpp = new Opportunity();
        tempOpp = [Select Id, Name,defaultForecast__c from Opportunity where Id = :o2.Id ];
        system.debug('O<-----$$$$@@@@@--->'+ tempOpp);
        OpportunityLineItem tp = [Select Id,Name,OpportunityId from OpportunityLineItem where id = :oli1.Id  ];
        System.debug('oli<-----$$$$@@@@@--->'+ tp);
        
        test.startTest();
            
            oli1.sampleQuantity__c = 3;
        	oli1.addedBySystem__c = true;
        	//oli1.containsDefaultForecast__c = true;
        	oli1.isDefaultForecast__c = false;
            update oli1;
            List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
            oliList.add(oli1);
            OpportunityLITriggerHelper.TransferDefaultForecast(oliList);
        //OpportunityLITriggerHelper.updateOpportunityOnSpecRemove(oliList);
        
            delete oliList;
            system.AssertEquals(0,[SELECT Count() FROM SampleFulfillment__c WHERE Opportunity__c = :o2.Id AND Quantity__c = 3 ]);
        test.stopTest();
    }
}