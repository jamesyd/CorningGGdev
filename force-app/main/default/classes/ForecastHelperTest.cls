@isTest
private class ForecastHelperTest {
    static TestUtilities tUtils = new TestUtilities();
    private static string opptRT;
    private static string acctRT;
    
    static {
        acctRT = tUtils.getRecordTypeId('Account', 'GG Account');
        opptRT = tUtils.getRecordTypeId('Opportunity', 'GG Program');        
    }
    
    static testMethod void submitForecast() {
        tUtils.SetTriggersOnForTesting();
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,opptRT);
        Product2 p1 = tUtils.addDefaultForecastProduct();
        
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id sPricebookId = Test.getStandardPricebookId();
        Id pricebookId = '01so0000004gBaQAAU';         
        PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 5);
        
        //o.Start_of_Production__c = date.today().addMonths(12);
        o.createForecast__c = TRUE;
        update o;
         Test.startTest();
        Boolean flag = false;
        List<ForecastOutput52Week__c> fcoList= ForecastHelper.archive(new List<ForecastOutput52Week__c>{new ForecastOutput52Week__c()});
        for(ForecastOutput52Week__c fco : fcoList){
            System.assertEquals(true, fco.status__C == 'Archived');  
        }
        List<ForecastOutput52Week__c> fcoList1= ForecastHelper.archive(new List<ForecastOutput52Week__c>{new ForecastOutput52Week__c()});
        for(ForecastOutput52Week__c fco : fcoList1){
            System.assertEquals(true, fco.status__C == 'Archived');   
        }
        Test.stopTest();
    }
    
    static testMethod void unitTesting(){
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,opptRT);
        Product2 p1 = tUtils.addDefaultForecastProduct();
        Id sPricebookId = Test.getStandardPricebookId();
        Id pricebookId = '01so0000004gBaQAAU';         
        PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 5);
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
          for(Integer i = 0; i < 18; i++){
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = o.Id; 
            oli.Quantity = 1000.00; 
            oli.TotalPrice = 10000;
            oli.PricebookEntryId = pbe1.Id ;
            oli.forecastCategory__c = 'Omitted';
            oliList.add(oli);
        }
        insert oliList;
        List<OpportunityLineItemSchedule> oppLISList = new List<OpportunityLineItemSchedule>();
        Integer count = 1;
        for(OpportunityLineItem oli : oliList){
            OpportunityLineItemSchedule lis = new OpportunityLineItemSchedule();
            
            lis.OpportunityLineItemId = oli.id;
            lis.Type = 'Revenue';
            lis.Revenue = 10000;
            if(count == 13){
                lis.ScheduleDate = date.newInstance(2021, count, 21);    
            }else{
                lis.ScheduleDate = date.newInstance(2020, count, 21);    
            }
            count = count + 1;
            System.debug(count);
            lis.Description = '1000.00';
            System.debug(lis);
            oppLISList.add(lis);
        }
        insert oppLISList;
      
        Test.startTest();
        Boolean flag = false;
        List<ForecastOutput52Week__c> fcoList= ForecastHelper.archive(new List<ForecastOutput52Week__c>{new ForecastOutput52Week__c()});
        for(ForecastOutput52Week__c fco : fcoList){
            System.assertEquals(true, fco.status__C == 'Archived');   
        }
        Account acc = new Account(Name = 'TestingAcc');
        insert acc;
        ForecastOutput52Week__c fco = new ForecastOutput52Week__c(account__r = acc);
        insert fco;
        List<OpportunityLineItem> oliList2 = new List<OpportunityLineItem>();
        List<ForecastOutput52Week__c> fcoList1 = ForecastHelper.process52(oliList2, 'Archived');
        for(ForecastOutput52Week__c fco1 : fcoList1){
            System.assertEquals(true, fco1.status__C == 'Archived' && fco1.totalQuantity__c == 1000.00);
        }
        List<ForecastOutput52Week__c> fcoList2 = ForecastHelper.process52(oliList2, 'Locked');
        for(ForecastOutput52Week__c fco2 : fcoList2){
            System.assertEquals(true, fco2.status__C == 'Locked' && fco2.totalQuantity__c == 1000.00);
        }
        ForecastHelper.getMonthMap();
        Test.stopTest();
        
    } 
    
    static testMethod void unitTestingForprocess52(){ 
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,opptRT);
        Product2 p1 = tUtils.addDefaultForecastProduct();
        Id sPricebookId = Test.getStandardPricebookId();
        Id pricebookId = '01so0000004gBaQAAU';         
        PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 5);
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        Test.startTest();
        
        o.estimatedMonthsInProduction__c = '11';
        update o;
        
        for(Integer i = 0; i < 18; i++){
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = o.Id; 
            oli.Quantity = 1000.00; 
            oli.TotalPrice = 10000;
            oli.PricebookEntryId = pbe1.Id ;
            oli.forecastCategory__c = 'Omitted';
            oliList.add(oli);
        }
        insert oliList;
        List<OpportunityLineItemSchedule> oppLISList = new List<OpportunityLineItemSchedule>();
        Integer count = 1;
        for(OpportunityLineItem oli : oliList){
            OpportunityLineItemSchedule lis = new OpportunityLineItemSchedule();
            
            lis.OpportunityLineItemId = oli.id;
            lis.Type = 'Revenue';
            lis.Revenue = 10000;
            if(count == 13){
                lis.ScheduleDate = date.newInstance(2021, count, 21);    
            }else{
                lis.ScheduleDate = date.newInstance(2020, count, 21);    
            }
            count = count + 1;
            System.debug(count);
            lis.Description = '1000.00';
            System.debug(lis);
            oppLISList.add(lis);
        }
        insert oppLISList;
        List<OpportunityLineItem> oliList2 = new List<OpportunityLineItem>();
        for(OpportunityLineItem oli : [SELECT Id,Name,forecastMonthsInProduction__c,Opportunity.AccountId
                                    ,forecastApplication__c 
                                    ,forecastBrandCustomer__c
                                    ,coverScreenSize__c
                                    ,glassComposition__c
                                    ,glassCurvature__c
                                    ,glassThickness__c
                                    ,finisherAccount__c
                                    ,finisherYield__c
                                    ,finisherMix__c
                                    ,finisherOwner__c    
                                    ,finalFinishedGlassPartThickness__c                               
                                    ,comments__c
                                    ,length__c
                                    ,forecastMarketSegment__c
                                    ,forecastMarketSubSegment__c
                                    ,forecastMassProductionStartDate__c
                                    ,forecastModelProgramName__c
                                    ,forecastCategory__c
                                    ,LastModifiedById
                                    ,LastModifiedDate
                                    ,OpportunityId
                                    ,Opportunity.Age__c
                                    ,Opportunity.Amount
                                    ,Opportunity.CloseDate
                                    ,Opportunity.ForecastCategory
                                    ,Opportunity.Name
                                    ,Opportunity.StageName
                                    ,Opportunity.OwnerId
                                    ,Opportunity.gorillaGlassPercent__c
                                    ,Opportunity.Competitive_Material__c
                                    ,Opportunity.pandaPercent__c
                                    ,Opportunity.competitiveGlasses__c
                                    ,Opportunity.agcPercent__c
                                    ,Opportunity.massProductionYield__c
                                    ,Opportunity.negPercent__c
                                    ,Opportunity.otherPercent__c
                                    ,Opportunity.schottPercent__c
                                    ,Opportunity.deviceCategory__c
                                    ,Opportunity.productSegmentation__c
                                    ,Product2Id
                                    ,forecastProductCode__c
                                    ,ProductName__c
                                    ,forecastProductionVolumePartsMonth__c
                                    ,forecastProgramName__c
                                    ,forecastRegion__c
                                    ,forecastShipToCustomer__c
                                    ,specification__c
                                    ,specification__r.name
                                    ,squareFeet__c
                                    ,thickness__c
                                    ,TotalPrice
                                    ,Quantity
                                    ,treatment__c
                                    ,width__c
                                    ,specification__r.tpm__r.id
                                    ,specification__r.tpm__r.OwnerId
                                    ,tpmOverride__c
                                    ,tpmOverride__r.OwnerId
                                    ,( SELECT ScheduleDate,Description,Quantity,Revenue FROM OpportunityLineItemSchedules)
                                    FROM OpportunityLineItem 
                                    WHERE id IN :oliList]){
                                            oliList2.add(oli); 
                                       }
        List<ForecastOutput52Week__c> forecastOutputList = new List<ForecastOutput52Week__c>();
        List<ForecastOutput52Week__c> fcoList = ForecastHelper.process52(oliList2, 'Archived');
        for(ForecastOutput52Week__c fco : fcoList){
            forecastOutputList.add(fco);
            System.assertEquals(true, fco.status__C == 'Archived' && fco.totalQuantity__c == 1000.00);
        }
        List<ForecastOutput52Week__c> fcoList2 = ForecastHelper.process52(oliList2, 'Locked');
        for(ForecastOutput52Week__c fco : fcoList2){
            System.assertEquals(true, fco.status__C == 'Locked' && fco.totalQuantity__c == 1000.00);
        }
        Map<Id, ForecastOutput52Week__c> fcoList3 = ForecastHelper.getM2ForecasteDetails(oliList2, 'Locked');
        for(ForecastOutput52Week__c fco : fcoList3.Values()){
            System.assertEquals(true, fco.status__C == 'Locked' && fco.totalQuantity__c == 1000.00);
        }
        Map<Id, ForecastOutput52Week__c> fcoList4 = ForecastHelper.getM2ForecasteDetails(oliList2, 'Archived');
        for(ForecastOutput52Week__c fco : fcoList4.Values()){
            System.assertEquals(true, fco.status__C == 'Archived' && fco.totalQuantity__c == 1000.00);
        }
        List<ForecastOutput52Week__c> fcoList5= ForecastHelper.archive(new List<ForecastOutput52Week__c>{new ForecastOutput52Week__c()});
        for(ForecastOutput52Week__c fco : fcoList5){
            System.assertEquals(true, fco.status__C == 'Archived');   
        }
        ForecastHelper.updateForeCastAccount(forecastOutputList);
        ForecastHelper.updateForeCastAccount(forecastOutputList);
        ForecastOutput52Week__c Obj1 = new ForecastOutput52Week__c();
        ForecastOutput52Week__c Obj2 = new ForecastOutput52Week__c();
        if(fcoList.size() > 0){
          Obj1.id = fcoList.get(0).id;   
        }
        if(fcoList2.size() > 0){
         Obj2.id =  fcoList2.get(0).id;  
        }
        ForecastHelper.calculateDelta(Obj1,Obj2);
        Test.stopTest();
    }
}