@isTest
private class HomePageForecastControllerTest {

    static TestUtilities tUtils = new TestUtilities();
    private static string opptRT;
    private static string acctRT;

    static {
        acctRT = tUtils.getRecordTypeId('Account', 'GG Account');
        opptRT = tUtils.getRecordTypeId('Opportunity', 'GG Program');        
    }

    static testMethod void manageForecast() {
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
        update o;
        
       
        
        List<ForecastOutput52Week__c> foList = new List<ForecastOutput52Week__c>();               
        
        // query and update the 52 week forecast
        foList = [SELECT id, status__c, opportunity__c, m2Qty__c, massProductionStartDate__c,
            tpmAccount__c, programCompleted__c, opportunityLineItemID__c
            FROM ForecastOutput52Week__c
            WHERE opportunity__c = :o.id AND status__c = 'Active'];
        
        test.startTest(); 
        HomePageForecastController.getForecastRecords('Test');
        HomePageForecastController.getForecastRecordDetail(foList[0].id);
        String jsonData = '{"recordId":"'+foList[0].id+'","m1qUpdate":0,"m2qUpdate":10000,"m3qUpdate":10000,"m4qUpdate":10000,"m5qUpdate":10000,"m6qUpdate":10000,"m7qUpdate":1,"m8qUpdate":1,"m9qUpdate":1,"m10qUpdate":1111111,"m11qUpdate":0,"m12qUpdate":0,"m13qUpdate":0,"m14qUpdate":1000,"m15qUpdate":0,"m16qUpdate":0,"m17qUpdate":0,"m18qUpdate":0,"m1pUpdate":0,"m2pUpdate":10,"m3pUpdate":10,"m4pUpdate":10,"m5pUpdate":10,"m6pUpdate":10,"m7pUpdate":0,"m8pUpdate":0,"m9pUpdate":0,"m10pUpdate":0,"m11pUpdate":0,"m12pUpdate":0,"m13pUpdate":0,"m14pUpdate":0,"m15pUpdate":2,"m16pUpdate":3,"m17pUpdate":0,"m18pUpdate":0}';
        HomePageForecastController.updateForecastSchedule(jsonData); 
        HomePageForecastController.updateForecastDetails(foList[0].id,a.id,a.OwnerId,a.Name,foList[0].massProductionStartDate__c,0,0);
        HomePageForecastController.getOLIsWithSchedules(foList[0].opportunityLineItemID__c);
        HomePageForecastController.getOLIsWithoutSchedules(foList[0].opportunityLineItemID__c);  
        test.stopTest();    
    }
    
    static testMethod void manageForecast2() {
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
        update o;
        
        List<ForecastOutput52Week__c> foList = new List<ForecastOutput52Week__c>();               
        List<String> idList = new List<String>(); 
        // query and update the 52 week forecast
        foList = [SELECT id, status__c, opportunity__c, m2Qty__c, massProductionStartDate__c,
            tpmAccount__c, programCompleted__c, opportunityLineItemID__c
            FROM ForecastOutput52Week__c
            WHERE opportunity__c = :o.id AND status__c = 'Active'];
        
        for (ForecastOutput52Week__c f : foList) {
  
            idList.add(f.opportunityLineItemID__c);      
        
        }
        
        List<String> lstRecordId = new List<String>();
        lstRecordId.add(foList[0].opportunityLineItemID__c);
        List<String> lstRecordIdTarget = new List<String>();
        lstRecordIdTarget.add(foList[0].opportunityLineItemID__c);
        
        test.startTest(); 
        HomePageForecastController.getOLIsWithSchedules(foList[0].opportunityLineItemID__c);
        HomePageForecastController.getOLIsWithoutSchedules(foList[0].opportunityLineItemID__c);
        HomePageForecastController.completeProgram(foList[0].id);
        String jsonData = '{"recordId":"'+foList[0].id+'","m1qUpdate":0,"m2qUpdate":10000,"m3qUpdate":10000,"m4qUpdate":10000,"m5qUpdate":10000,"m6qUpdate":10000,"m7qUpdate":1,"m8qUpdate":1,"m9qUpdate":1,"m10qUpdate":1111111,"m11qUpdate":0,"m12qUpdate":0,"m13qUpdate":0,"m14qUpdate":1000,"m15qUpdate":0,"m16qUpdate":0,"m17qUpdate":0,"m18qUpdate":0,"m1pUpdate":0,"m2pUpdate":10,"m3pUpdate":10,"m4pUpdate":10,"m5pUpdate":10,"m6pUpdate":10,"m7pUpdate":0,"m8pUpdate":0,"m9pUpdate":0,"m10pUpdate":0,"m11pUpdate":0,"m12pUpdate":0,"m13pUpdate":0,"m14pUpdate":0,"m15pUpdate":2,"m16pUpdate":3,"m17pUpdate":0,"m18pUpdate":0}';
        HomePageForecastController.updateForecastSchedule(jsonData);
        HomePageForecastController.copyRecords(lstRecordId,lstRecordIdTarget);
        HomePageForecastController.deleteRecords(idList);
        HomePageForecastController.updateForecastDetails(foList[0].id,a.id,a.OwnerId,a.Name,foList[0].massProductionStartDate__c,0,0);
        test.stopTest(); 
    }

    static testMethod void manageForecast3() {
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
        
        update o;
        
        List<ForecastOutput52Week__c> foList = new List<ForecastOutput52Week__c>();       
        List<String> idList = new List<String>();        
        
        // query and update the 52 week forecast
        foList = [SELECT id, status__c, opportunity__c, m2Qty__c, massProductionStartDate__c,
            tpmAccount__c, programCompleted__c, opportunityLineItemID__c
            FROM ForecastOutput52Week__c
            WHERE opportunity__c = :o.id AND status__c = 'Active'];
        
        for (ForecastOutput52Week__c f : foList) {
  
            idList.add(f.opportunityLineItemID__c);      
        
        }
        
        Test.startTest();
        //HomePageForecastController.copyRecords(List <String> lstRecordId, List <String> lstRecordIdTarget); OLI
        HomePageForecastController.deleteRecords(idList);
        //HomePageForecastController.updateForecastDetails(Id recordId, Id accountId, Id accountOwnerId, String accountName, Date mpStartDate);
         HomePageForecastController.getForecastRecords('Test');
        HomePageForecastController.getForecastRecordDetail(foList[0].id);
        String jsonData = '{"recordId":"'+foList[0].id+'","m1qUpdate":0,"m2qUpdate":10000,"m3qUpdate":10000,"m4qUpdate":10000,"m5qUpdate":10000,"m6qUpdate":10000,"m7qUpdate":1,"m8qUpdate":1,"m9qUpdate":1,"m10qUpdate":1111111,"m11qUpdate":0,"m12qUpdate":0,"m13qUpdate":0,"m14qUpdate":1000,"m15qUpdate":0,"m16qUpdate":0,"m17qUpdate":0,"m18qUpdate":0,"m1pUpdate":0,"m2pUpdate":10,"m3pUpdate":10,"m4pUpdate":10,"m5pUpdate":10,"m6pUpdate":10,"m7pUpdate":0,"m8pUpdate":0,"m9pUpdate":0,"m10pUpdate":0,"m11pUpdate":0,"m12pUpdate":0,"m13pUpdate":0,"m14pUpdate":0,"m15pUpdate":2,"m16pUpdate":3,"m17pUpdate":0,"m18pUpdate":0}';
        HomePageForecastController.updateForecastSchedule(jsonData); 
        HomePageForecastController.updateForecastDetails(foList[0].id,a.id,a.OwnerId,a.Name,foList[0].massProductionStartDate__c,0,0);
        HomePageForecastController.getOLIsWithSchedules(foList[0].opportunityLineItemID__c);
        HomePageForecastController.getOLIsWithoutSchedules(foList[0].opportunityLineItemID__c);
        Test.stopTest();
        
    }
    

}