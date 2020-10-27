@isTest
private class ForecastOutput52WeekTriggerHelperTest {
    static TestUtilities tUtils = new TestUtilities();
    private static string opptRT;
    private static string acctRT;

    static {
        acctRT = tUtils.getRecordTypeId('Account', 'GG Account');
        opptRT = tUtils.getRecordTypeId('Opportunity', 'GG Program');        
    }

    static testMethod void changeForecast() {
        tUtils.SetTriggersOnForTesting();
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,opptRT);
        Product2 p1 = tUtils.addDefaultForecastProduct();
          
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id sPricebookId = Test.getStandardPricebookId();
        Id pricebookId = '01so0000004gBaQAAU';         
        PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 5);
        
        o.createForecast__c = TRUE;
        Test.startTest();
        update o;
        
        List<ForecastOutput52Week__c> foList = new List<ForecastOutput52Week__c>();
        List<ForecastOutput52Week__c> foUpdateQtyList = new List<ForecastOutput52Week__c>();
                     
        
        // query and update the 52 week forecast
        foList = [SELECT id, status__c, opportunity__c, m2Qty__c, massProductionStartDate__c,
            tpmAccount__c, programCompleted__c
            FROM ForecastOutput52Week__c
            WHERE opportunity__c = :o.id AND status__c = 'Active'];
        
        for (ForecastOutput52Week__c f : foList) {
            f.m2Qty__c = 1;
            foUpdateQtyList.add(f);            
        }
        
        update foUpdateQtyList;
        Test.stopTest();
        
        
    }
    
    static testMethod void changeForecast1() {
        tUtils.SetTriggersOnForTesting();
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,opptRT);
        Product2 p1 = tUtils.addDefaultForecastProduct();
          
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id sPricebookId = Test.getStandardPricebookId();
        Id pricebookId = '01so0000004gBaQAAU';         
        PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 5);
        
        o.createForecast__c = TRUE;
        Test.startTest();
        update o;
        
        List<ForecastOutput52Week__c> foList = new List<ForecastOutput52Week__c>();
        List<ForecastOutput52Week__c> foUpdateDateList = new List<ForecastOutput52Week__c>();                     
        
        // query and update the 52 week forecast
        foList = [SELECT id, status__c, opportunity__c, m2Qty__c, massProductionStartDate__c,
            tpmAccount__c, programCompleted__c
            FROM ForecastOutput52Week__c
            WHERE opportunity__c = :o.id AND status__c = 'Active'];
        
        for (ForecastOutput52Week__c f : foList) {
            f.massProductionStartDate__c = System.Date.today().addMonths(1);
            foUpdateDateList.add(f);            
        }
        
        foUpdateDateList.remove(1);
        update foUpdateDateList;
        Test.stopTest();
        
    }

    static testMethod void changeForecast2() {
        tUtils.SetTriggersOnForTesting();
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,opptRT);
        Product2 p1 = tUtils.addDefaultForecastProduct();
          
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id sPricebookId = Test.getStandardPricebookId();
        Id pricebookId = '01so0000004gBaQAAU';         
        PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 5);
        
        o.createForecast__c = TRUE;
        Test.startTest();
        update o;
        
        List<ForecastOutput52Week__c> foList = new List<ForecastOutput52Week__c>();
        List<ForecastOutput52Week__c> foUpdateEndList = new List<ForecastOutput52Week__c>();
        List<ForecastOutput52Week__c> foUpdateTPMList = new List<ForecastOutput52Week__c>();                        
        
        // query and update the 52 week forecast
        foList = [SELECT id, status__c, opportunity__c, m2Qty__c, massProductionStartDate__c,
            tpmAccount__c, programCompleted__c
            FROM ForecastOutput52Week__c
            WHERE opportunity__c = :o.id AND status__c = 'Active'];
        
        for (ForecastOutput52Week__c f : foList) {
            f.tpmAccount__c = a.id;
            foUpdateTPMList.add(f);            
        }
        
        update foUpdateTPMList;
 
        for (ForecastOutput52Week__c f : foList) {
            f.programCompleted__c = TRUE;
            foUpdateEndList.add(f);            
        }
        
        update foUpdateEndList;
        Test.stopTest();
        

        
    }

        
}