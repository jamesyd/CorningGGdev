///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 2/15/2017 ***///
///*** Test class for Class to help opportunity trigger ***///

@isTest 
private class OpportunityTriggerHelperTest {
    static TestUtilities tUtils = new TestUtilities();
    private static string acctRT;
    private static string oppRT;
    private static string oppRT2;
    private static string profileId;
    private static string specRT;
    private static string specRT2;
    private static string specRT3;
    private static string specRT4;
    
    static {
        acctRT = tUtils.getRecordTypeId('Account', 'GG Account');
        oppRT = tUtils.getRecordTypeId('Opportunity', 'GG Program');
        oppRT2 = tUtils.getRecordTypeId('Opportunity', 'GG Parts Sample Request');
        profileId = tUtils.getProfileId('GG Account Manager');
        specRT = tUtils.getRecordTypeId('Specification__c', 'Parts');
        specRT2 = tUtils.getRecordTypeId('Specification__c', 'Raw Glass');
        specRT3 = tUtils.getRecordTypeId('Specification__c', 'Concore');
        specRT4 = '0121J000001DcdR'; // Parts - RFI
    }
    
    //sample opportunities are tied to mass production opportunity through a look up. So, the trigger tries to prevent 
    //someone with read access to a mass production opportunity from creating a sample opportunity unless they are on 
    //the team of the mass prod opportunity.
    
    //Sample Opp - Team Member
    static testMethod void validateCreateAccessSampleRequestTest1() {
        tUtils.SetTriggersOnForTesting();
        User ta = (tUtils.addTestUsers(profileId,1))[0];
        Account a = tUtils.addTestAccount(acctRT);
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        
        
        
        OpportunityTeamMember otm = tUtils.addTestOppTeamMember(o.id, ta.id, 'Account Manager');
        test.startTest();
        system.runAs(ta) {
            try{
                Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
                o2.massProductionOpportunity__c = o.Id;
                insert o2;
            }
            catch (exception e) { //SHOULD NOT GET HERE
                system.assertEquals(false,e.getMessage().contains('Sample requests can only be created/edited by the program opportunity owner, program opportunity team member with edit access or program account team member with opportunity edit access.'));
            }
        }
        test.stopTest();
    }
    
    //Sample Opp - Non Team Member
    static testMethod void validateCreateAccessSampleRequestTest2() {
        //Id oppPartsSampleRtId = '0121J000000U1cY';
        //Id oppRawSampleRtId = '0121J000000U1cb';
        User ta = (tUtils.addTestUsers(profileId,1))[0];
        tUtils.SetTriggersOnForTesting();
        Account a = tUtils.addTestAccount(acctRT, 'TPM');
        a.accountType__c = 'TPM';
        update a;
        Contact con2 = new Contact(LastName='Test2');
        insert con2;
        Opportunity o = tUtils.addTestOppt2(a.Id,oppRT,false);
        o.isPreBuild__c = true;
        o.sampleCmLocations__c = 'GO;BOE';
        o.shipToContact__c = con2.Id;
        o.RSMApprovalForUrgentPaidSample__c ='YES';
        o.pricingAssignmentComplete__c = false;
        
        Insert o;
        SampleFulfillment__c sm = tUtils.createSampleFulfillment(o.Id);
        
        Specification__c sp = tUtils.addTestSpec(a.id, o.id, specRT, true);
        
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
        
        Contact con = new Contact(LastName='Test');
        insert con;
        Opportunity op = [Select id from Opportunity where id =: o.id];
        op.sampleCmLocations__c = 'CPM';
        op.shipToContact__c = con.Id;
        op.pricingAssignmentComplete__c = true;
        op.overrideShipToContactAddress__c = false;
        op.stageName = 'Order Pending';
        update op;
        test.stopTest();
    }
    
    static testMethod void validateCreateAccessSampleRequestTest3() {
        //Id oppPartsSampleRtId = '0121J000000U1cY';
        //Id oppRawSampleRtId = '0121J000000U1cb';
        User ta = (tUtils.addTestUsers(profileId,1))[0];
        tUtils.SetTriggersOnForTesting();
        Account a = tUtils.addTestAccount(acctRT, 'TPM');
        a.accountType__c = 'TPM';
        update a;
        Contact con2 = new Contact(LastName='Test2');
        insert con2;
        Opportunity o = tUtils.addTestOppt2(a.Id,oppRT2,false);
        o.isPreBuild__c = true;
        o.sampleCmLocations__c = 'GO;BOE';
        o.shipToContact__c = con2.Id;
        o.RSMApprovalForUrgentPaidSample__c ='YES';
        o.pricingAssignmentComplete__c = false;
        o.StageName = 'New';
        Insert o;
        SampleFulfillment__c sm = tUtils.createSampleFulfillment(o.Id);
        
        //Specification__c sp = tUtils.addTestSpec(a.id, o.id, specRT, true);
        
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
        //insert oli1;
        
        OpportunityLineItem oli2 = tUtils.createTestOLI(o.id, 10, pbe2.id);
        oli2.deviceTracker__c = false;
        //insert oli2;
        
        test.startTest();
        
        Contact con = new Contact(LastName='Test');
        insert con;
        Opportunity op = [Select id from Opportunity where id =: o.id];
        op.sampleCmLocations__c = 'CPM';
        op.shipToContact__c = con.Id;
        op.pricingAssignmentComplete__c = true;
        op.overrideShipToContactAddress__c = false;
        op.stageName = 'Order Pending';
        //op.freeApproved__c ='Yes';
        try{
        	update op;
        }
        catch(Exception ae){
            
        }
        test.stopTest();
    }
    
    static testMethod void validateCreateAccessSampleRequestTest4() {
        //Id oppPartsSampleRtId = '0121J000000U1cY';
        //Id oppRawSampleRtId = '0121J000000U1cb';
        User ta = (tUtils.addTestUsers(profileId,1))[0];
        tUtils.SetTriggersOnForTesting();
        Account a = tUtils.addTestAccount(acctRT, 'TPM');
        a.accountType__c = 'TPM';
        update a;
        Contact con2 = new Contact(LastName='Test2');
        insert con2;
        Opportunity o = tUtils.addTestOppt2(a.Id,oppRT2,false);
        o.isPreBuild__c = true;
        o.sampleCmLocations__c = 'GO;BOE';
        o.shipToContact__c = con2.Id;
        o.RSMApprovalForUrgentPaidSample__c ='YES';
        o.pricingAssignmentComplete__c = false;
        o.StageName = 'New';
        o.estimatedTotalVolume__c = 2;
        o.estimatedMonthsInProduction__c = '2';
        o.Type = 'Parts';
        o.Start_of_Production__c = date.today().addDays(5);
        
        Insert o;
        SampleFulfillment__c sm = tUtils.createSampleFulfillment(o.Id);
        
        //Specification__c sp = tUtils.addTestSpec(a.id, o.id, specRT, true);
        
        Product2 p1 = tUtils.addTestProductSecond(o.Id,'Raw Glass Forecast',false);
        Product2 p2 = tUtils.addTestProductSecond(o.Id,'Default Part Forecast',false);
        Product2 p3 = tUtils.addTestProductSecond(o.Id,'Concore Forecast',false);
        
        p1.CanUseRevenueSchedule=true;
        p2.CanUseRevenueSchedule=true;
        p3.CanUseRevenueSchedule=true;
        
        p1.CanUseQuantitySchedule = true;
        p2.CanUseQuantitySchedule = true;
        p3.CanUseQuantitySchedule = true;

        
        insert p1;
        insert p2;
        insert p3;
        
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id sPricebookId = Test.getStandardPricebookId();
        Id pricebookId = '01so0000004gBaQAAU';         
        PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 5);
        PricebookEntry pbe2 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p2.id, 15);
        
        OpportunityLineItem oli1 = tUtils.createTestOLI(o.id, 5, pbe1.id);
        // oli1.deviceTracker__c = true; // AN - 8/6/18 - remove device tracker - field not used anymore
        //insert oli1;
        
        OpportunityLineItem oli2 = tUtils.createTestOLI(o.id, 10, pbe2.id);
        oli2.deviceTracker__c = false;
        //insert oli2;
        
        test.startTest();
        
        Contact con = new Contact(LastName='Test');
        insert con;
        Opportunity op = [Select id from Opportunity where id =: o.id];
        
        op.createForecast__c = true;
        

        update op;
        
        //op.submitForApproval__c = true;
        op.isPreBuild__c = true;
        op.StageName = 'Order Pending';
        update op;
        test.stopTest();
    }

    static testMethod void validateCreateAccessSampleRequestTest5() {
        Id oppPartsSampleRtId = '0121J000000U1cY';
        //Id oppRawSampleRtId = '0121J000000U1cb';
        User ta = (tUtils.addTestUsers(profileId,1))[0];
        tUtils.SetTriggersOnForTesting();
        Account a = tUtils.addTestAccount(acctRT, 'TPM');
        a.accountType__c = 'TPM';
        update a;
        Contact con2 = new Contact(LastName='Test2');
        insert con2;
        Opportunity o = tUtils.addTestOppt2(a.Id,oppPartsSampleRtId,false);
        o.isPreBuild__c = true;
        o.sampleCmLocations__c = 'GO;BOE';
        o.shipToContact__c = con2.Id;
        o.RSMApprovalForUrgentPaidSample__c ='YES';
        o.pricingAssignmentComplete__c = false;
        o.StageName = 'New';
        o.estimatedTotalVolume__c = 2;
        o.estimatedMonthsInProduction__c = '2';
        o.Type = 'Parts';
        o.Start_of_Production__c = date.today().addDays(5);
        
        Insert o;
        SampleFulfillment__c sm = tUtils.createSampleFulfillment(o.Id);
        
        //Specification__c sp = tUtils.addTestSpec(a.id, o.id, specRT, true);
        
        Product2 p1 = tUtils.addTestProductSecond(o.Id,'Raw Glass Forecast',false);
        Product2 p2 = tUtils.addTestProductSecond(o.Id,'Default Part Forecast',false);
        Product2 p3 = tUtils.addTestProductSecond(o.Id,'Concore Forecast',false);
        
        p1.CanUseRevenueSchedule=true;
        p2.CanUseRevenueSchedule=true;
        p3.CanUseRevenueSchedule=true;
        
        p1.CanUseQuantitySchedule = true;
        p2.CanUseQuantitySchedule = true;
        p3.CanUseQuantitySchedule = true;

        
        insert p1;
        insert p2;
        insert p3;
        
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id sPricebookId = Test.getStandardPricebookId();
        Id pricebookId = '01so0000004gBaQAAU';         
        PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 5);
        PricebookEntry pbe2 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p2.id, 15);
        
        OpportunityLineItem oli1 = tUtils.createTestOLI(o.id, 5, pbe1.id);
        oli1.deviceTracker__c = true; // AN - 8/6/18 - remove device tracker - field not used anymore
        insert oli1;
        
        OpportunityLineItem oli2 = tUtils.createTestOLI(o.id, 10, pbe2.id);
        oli2.deviceTracker__c = false;
        insert oli2;
        
        test.startTest();
        
        Contact con = new Contact(LastName='Test');
        insert con;
        Opportunity op = [Select id from Opportunity where id =: o.id];
        
       
   

        
        
        //op.submitForApproval__c = true;
        op.isPreBuild__c = true;
        op.StageName = 'Order Pending';
        update op;
        test.stopTest();
    }
    
    @IsTest(SeeAllData=true)
    static void validateCreateAccessSampleRequestTest6() {
        //Id oppPartsSampleRtId = '0121J000000U1cY';
        //Id oppRawSampleRtId = '0121J000000U1cb';
        Id ggPrebuildRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('GG Sample Parts Opportunity Prebuild').getRecordTypeId();
        
        UserRole r = [Select Id,Name From UserRole where Name = 'GG Exclusive (Blue)'];
        
        User ta = (tUtils.createTestUsers(profileId,1,r.Id))[0];
        //tUtils.SetTriggersOnForTesting();
        Account a = tUtils.addTestAccount(acctRT, 'TPM');
        a.accountType__c = 'TPM';
        //a.exclusiveAccountType__c = 'Blue';
        update a;
        Contact con2 = new Contact(LastName='Test2');
        insert con2;
        Opportunity o = tUtils.addTestOppt2(a.Id,ggPrebuildRTID,false);
        o.isPreBuild__c = true;
        o.sampleCmLocations__c = 'GO;BOE';
        o.shipToContact__c = con2.Id;
        o.RSMApprovalForUrgentPaidSample__c ='YES';
        o.pricingAssignmentComplete__c = false;
        o.StageName = 'New';
        o.estimatedTotalVolume__c = 2;
        o.estimatedMonthsInProduction__c = '2';
        o.Type = 'Parts';
        o.Start_of_Production__c = date.today().addDays(5);
        
        Insert o;
        SampleFulfillment__c sm = tUtils.createSampleFulfillment(o.Id);
        
        //Specification__c sp = tUtils.addTestSpec(a.id, o.id, specRT, true);
        
        Product2 p1 = tUtils.addTestProductSecond(o.Id,'Raw Glass Forecast',false);
        Product2 p2 = tUtils.addTestProductSecond(o.Id,'Default Part Forecast',false);
        Product2 p3 = tUtils.addTestProductSecond(o.Id,'Concore Forecast',false);
        
        p1.CanUseRevenueSchedule=true;
        p2.CanUseRevenueSchedule=true;
        p3.CanUseRevenueSchedule=true;
        
        p1.CanUseQuantitySchedule = true;
        p2.CanUseQuantitySchedule = true;
        p3.CanUseQuantitySchedule = true;

        
        insert p1;
        insert p2;
        insert p3;
        
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id sPricebookId = Test.getStandardPricebookId();
        Id pricebookId = '01so0000004gBaQAAU';         
        PricebookEntry pbe1 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p1.id, 5);
        PricebookEntry pbe2 = tUtils.addTestPBEntryGG(sPricebookId, pricebookId, p2.id, 15);
        
        OpportunityLineItem oli1 = tUtils.createTestOLI(o.id, 5, pbe1.id);
        // oli1.deviceTracker__c = true; // AN - 8/6/18 - remove device tracker - field not used anymore
        //insert oli1;
        
        OpportunityLineItem oli2 = tUtils.createTestOLI(o.id, 10, pbe2.id);
        oli2.deviceTracker__c = false;
        //insert oli2;
        
        test.startTest();
        
        Contact con = new Contact(LastName='Test');
        insert con;
        Opportunity op = [Select id from Opportunity where id =: o.id];
        
        op.freeApproved__c = 'Yes';
        op.requestFreeSample__c = 'Yes';
		op.shippingTerm__c = 'FCA';
        
        
        //op.submitForApproval__c = true;
        op.isPreBuild__c = true;
        op.StageName = 'Customer Quotation';
        op.pricingAssignmentComplete__c = true;
        try{
            update op;
        }
        catch(Exception ae){}
        
        test.stopTest();
    }
    
    static testMethod void validateCreateAccessSampleRequestTest7() {
        //Id oppPartsSampleRtId = '0121J000000U1cY';
        //Id oppRawSampleRtId = '0121J000000U1cb';
        User ta = (tUtils.addTestUsers(profileId,1))[0];
        tUtils.SetTriggersOnForTesting();
        Account a = tUtils.addTestAccount(acctRT, 'TPM');
        a.accountType__c = 'TPM';
        update a;
        Contact con2 = new Contact(LastName='Test2');
        insert con2;
        Opportunity o = tUtils.addTestOppt2(a.Id,oppRT,false);
        o.isPreBuild__c = true;
        o.sampleCmLocations__c = 'GO;BOE';
        o.shipToContact__c = con2.Id;
        o.internalChargeNumber__c = '135';
        o.Custom_PO_expected_Date__c = date.today();
        o.ProductCode__c = '1232ds';
        o.StageName = 'New';
        Insert o;
        SampleFulfillment__c sm = tUtils.createSampleFulfillment(o.Id);
        insert sm;
        Specification__c sp = tUtils.addTestSpec(a.id, o.id, specRT, false);
        sp.productCode__c = '1232ds';
        insert sp;
        
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
        
        oli1.Specification__c = sp.Id; 
        insert oli1;
        
        OpportunityLineItem oli2 = tUtils.createTestOLI(o.id, 10, pbe2.id);
        oli2.deviceTracker__c = false;
        //insert oli2;
        
        test.startTest();
        
        Contact con = new Contact(LastName='Test');
        insert con;
        Opportunity op = [Select id from Opportunity where id =: o.id];
        
        //op.pricingAssignmentComplete__c = true;
        
        //op.stageName = 'Order Pending';
        //op.freeApproved__c ='Yes';
        op.submitForApproval__c = true;
        
            op.SpecId__c = 'achdd';
        	update op;
            op.stageName = 'Order Pending';
            update op;
       
        
        test.stopTest();
    }
    
    /*static testMethod void validateCreateAccessSampleRequestTest3() {
        //Id oppPartsSampleRtId = '0121J000000U1cY';
        //Id oppRawSampleRtId = '0121J000000U1cb';
        User ta = (tUtils.addTestUsers(profileId,1))[0];
        tUtils.SetTriggersOnForTesting();
        Account a = tUtils.addTestAccount(acctRT, 'TPM');
        a.accountType__c = 'TPM';
        update a;
        Contact con2 = new Contact(LastName='Test2');
        insert con2;
        Opportunity o = tUtils.addTestOppt2(a.Id,oppRT2,false);
        o.isPreBuild__c = true;
        o.sampleCmLocations__c = 'GO;BOE';
        o.shipToContact__c = con2.Id;
        o.RSMApprovalForUrgentPaidSample__c ='YES';
        o.pricingAssignmentComplete__c = false;
        o.createForecast__c = false;
        Insert o;
        
        
        SampleFulfillment__c sm = tUtils.createSampleFulfillment(o.Id);
        
        //Specification__c sp = tUtils.addTestSpec(a.id, o.id, specRT, true);
        
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
        //insert oli1;
        
        OpportunityLineItem oli2 = tUtils.createTestOLI(o.id, 10, pbe2.id);
        oli2.deviceTracker__c = false;
        //insert oli2;
        
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(o);
        Map<Id,Opportunity> oppById = new Map<Id,Opportunity>();
        oppById.put(o.Id, o);
        test.startTest();
        
        	OpportunityTriggerHelper.onAfterInsert(oppList);
        
            //OpportunityTriggerHelper.setOppStageForPhyllo(oppList,oppById);
        
            Contact con = new Contact(LastName='Test');
            insert con;
            Opportunity op = [Select id from Opportunity where id =: o.id];
            op.sampleCmLocations__c = 'CPM';
            op.shipToContact__c = con.Id;
            op.pricingAssignmentComplete__c = true;
            op.overrideShipToContactAddress__c = false;
            op.stageName = 'Order Pending';
            op.createForecast__c = true;
            op.Quantity__c = 1.00;
            op.estimatedTotalVolume__c = 2;
            op.estimatedMonthsInProduction__c = '2';
            update op;	
        test.stopTest();
    }*/
}