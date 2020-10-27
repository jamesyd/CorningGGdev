///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 2/15/2017 ***///
///*** Test class for Class to help specification trigger ***///
// @isTest // ConnectApi methods are not supported in data siloed tests. Please use @IsTest(SeeAllData=true). Class.ConnectApi.ChatterFeeds.postFeedElement
@IsTest(SeeAllData=true)
private class SpecificationTriggerHelperTest {
    static TestUtilities tUtils = new TestUtilities();
    private static string acctRT;
    private static string oppRT;
    private static string specRT;
    private static string specRT2;
    private static string specRT3;
    private static string specRT4;
    private static string profileId;
    
    static {
        acctRT = tUtils.getRecordTypeId('Account', 'GG Account');
        oppRT = tUtils.getRecordTypeId('Opportunity', 'GG Program');
        specRT = tUtils.getRecordTypeId('Specification__c', 'Parts');
        specRT2 = tUtils.getRecordTypeId('Specification__c', 'Raw Glass');
        specRT3 = tUtils.getRecordTypeId('Specification__c', 'Concore');
        specRT4 = '0121J000001DcdR'; // Parts - RFI
        profileId = tUtils.getProfileId('GG Account Manager');
    }
    
    //Submitted - Team Member
    static testMethod void validateEditAccessToSpecificationsTest1() {
        //tUtils.SetTriggersOnForTesting();
        //tUtils.SetAutoNotificationSettingsForTesting();
        UserRole roleObj=new UserRole(Name= 'GG Mgr Taiwan'); 
        insert roleObj; 
        list<User> tas = tUtils.addTestUsers(profileId,2, roleObj.Id);
        Specification__c testSpec;
        
        System.runAs(tas[0]) {
            Account a = tUtils.addTestAccount(acctRT, 'TPM');
            a.accountType__c = 'TPM';
            update a;
            Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
            OpportunityTeamMember otm = tUtils.addTestOppTeamMember(o.id, tas[1].id, 'Account Manager');
            testSpec = tUtils.createTestSpec(a.id, o.id, specRT);
            testSpec.TPM__c = a.id;
            testSpec.SubmitforApproval__c = true;
            testSpec.ioxNeeded__c = 'No';
            testSpec.Innovation_Type__c = 'EZ/AR';
            testSpec.arSolution__c = 'AR Only – One Side';
            insert testSpec;
            testSpec = [SELECT RecordType.Name FROM Specification__c WHERE Id = :testSpec.Id LIMIT 1];
            system.assertEquals('Parts - Submitted', testSpec.RecordType.Name);
        }
        
        test.startTest();
        System.runAs(tas[1]) {
            testSpec.Application__c = 'Camera lens cover';
            try{
                update testSpec;
            }
            catch (exception e) { //SHOULD NOT GET HERE
                system.assertEquals(false,e.getMessage().contains(Label.SpecificationEditError));
            }
        }
        test.stopTest();
    }
    
    //Submitted - Non Team Member
    static testMethod void validateEditAccessToSpecificationsTest2() {
        //tUtils.SetTriggersOnForTesting();
        //tUtils.SetAutoNotificationSettingsForTesting();
        UserRole roleObj=new UserRole(Name= 'GG Mgr Taiwan'); 
        insert roleObj; 
        list<User> tas = tUtils.addTestUsers(profileId,2, roleObj.Id);
        Specification__c testSpec;
        
        System.runAs(tas[0]) {
            Account a = tUtils.addTestAccount(acctRT, 'TPM');
            a.accountType__c = 'TPM';
            update a;
            Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
            testSpec = tUtils.createTestSpec(a.id, o.id, specRT);
            testSpec.TPM__c = a.id;
            testSpec.SubmitforApproval__c = true;
            testSpec.ioxNeeded__c = 'No';
            testSpec.Innovation_Type__c = 'EZ/AR';
            testSpec.arSolution__c = 'AR Only – One Side';
            insert testSpec;
            testSpec = [SELECT RecordType.Name FROM Specification__c WHERE Id = :testSpec.Id LIMIT 1];
            system.assertEquals('Parts - Submitted', testSpec.RecordType.Name);
        }
        
        test.startTest();
        System.runAs(tas[1]) {
            testspec.Application__c = 'Camera lens cover';//'Lens';
            try{
                update testSpec;
            }
            catch (exception e) { //SHOULD NOT GET HERE
                system.debug('exception: ' + e);
                system.debug('e.message: ' + e.getMessage());
                
                system.assertEquals(false,e.getMessage().contains(Label.SpecificationEditError));
            }
        }
        test.stopTest();
    }
    
    
    //Not Submitted - Team Member
    static testMethod void validateEditAccessToSpecificationsTest3() {
        UserRole roleObj=new UserRole(Name= 'GG Mgr Taiwan'); 
        insert roleObj; 
        list<User> tas = tUtils.addTestUsers(profileId,2, roleObj.Id);
        Specification__c testSpec;
        
        System.runAs(tas[0]) {
            Account a = tUtils.addTestAccount(acctRT, 'TPM');
            Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
            OpportunityTeamMember otm = tUtils.addTestOppTeamMember(o.id, tas[1].id, 'Account Manager');
            testSpec = tUtils.addTestSpec(a.id, o.id, specRT);
            testSpec = [SELECT RecordType.Name FROM Specification__c WHERE Id = :testSpec.Id LIMIT 1];
            system.assertEquals('Parts',testSpec.RecordType.Name);
        }
        
        test.startTest();
        System.runAs(tas[1]) {
            testSpec.Application__c = 'Camera lens cover';//'Button';
            try{
                update testSpec; 
            }
            catch (exception e) { //SHOULD NOT GET HERE
                system.assertEquals(false,e.getMessage().contains(Label.SpecificationEditError));
            }
        }
        test.stopTest();
    }
    
    //Not Submitted - Non Team Member
    static testMethod void validateEditAccessToSpecificationsTest4() {
        //tUtils.SetTriggersOnForTesting();
        //tUtils.SetAutoNotificationSettingsForTesting();
        UserRole roleObj=new UserRole(Name= 'GG Mgr Taiwan'); 
        insert roleObj; 
        list<User> tas = tUtils.addTestUsers(profileId,2, roleObj.Id);
        Specification__c testSpec;
        
        System.runAs(tas[0]) {
            Account a = tUtils.addTestAccount(acctRT, 'TPM');
            Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
            testSpec = tUtils.addTestSpec(a.id, o.id, specRT, false);
            testSpec.Status__c = 'Pricing Assignment';
            INSERT testSpec;
            
            testSpec = [SELECT RecordType.Name FROM Specification__c WHERE Id = :testSpec.Id LIMIT 1];
            system.assertEquals('Parts',testSpec.RecordType.Name);
        }
        test.startTest();
        System.runAs(tas[1]) {
            testSpec.Application__c = 'Camera lens cover';//'Button';
            testSpec.qualityEngineerApproval__c = 'Reviewed - More Information Required';
            testSpec.Status__c = 'Pricing Approved';
            testSpec.Finance_Review_Complete__c = true;
            try{
                update testSpec;
            }
            catch (exception e) { //SHOULD GET HERE
                system.debug('e.Message: ' + e.getMessage());
                //either fails because this AM doesn't have access to someone else's opportunity or our trigger errors out
                system.assertEquals(true,e.getMessage().contains(Label.SpecificationEditError)
                                    || e.getMessage().contains('INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY'));
            }
        }
        test.stopTest();       
    }
    
    //Not Submitted - Non Team Member
    static testMethod void validateEditAccessToSpecificationsTest5() {
        //tUtils.SetTriggersOnForTesting();
        //tUtils.SetAutoNotificationSettingsForTesting();
        Specification__c testSpec;
        Account a = tUtils.addTestAccount(acctRT, 'TPM');
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        testSpec = tUtils.addTestSpec(a.id, o.id, specRT, false);
        testSpec.Status__c = 'Pricing Assignment';
        INSERT testSpec;
        
        testSpec = [SELECT RecordType.Name FROM Specification__c WHERE Id = :testSpec.Id LIMIT 1];
        system.assertEquals('Parts',testSpec.RecordType.Name);
        test.startTest();
        testSpec.Application__c = 'Camera lens cover';//'Button';
        testSpec.qualityEngineerApproval__c = 'Reviewed - More Information Required';
        testSpec.Status__c = 'Pricing Approved';
        testSpec.Finance_Review_Complete__c = true;
        update testSpec;
        test.stopTest();       
    }
    
    //Not Submitted - Non Team Member
    static testMethod void validateEditAccessToSpecificationsTest6() {
        //tUtils.SetTriggersOnForTesting();
        //tUtils.SetAutoNotificationSettingsForTesting();
        Specification__c testSpec;
        Account a = tUtils.addTestAccount(acctRT, 'TPM');
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        testSpec = tUtils.addTestSpec(a.id, o.id, specRT, false);
        testSpec.Status__c = 'Pricing Assignment';
        INSERT testSpec;
        
        testSpec = [SELECT RecordType.Name FROM Specification__c WHERE Id = :testSpec.Id LIMIT 1];
        system.assertEquals('Parts',testSpec.RecordType.Name);
        test.startTest();
        testSpec.Application__c = 'Camera lens cover';//'Button';
        testSpec.qualityEngineerApproval__c = 'Approved - Includes Plant Eng Approval';
        testSpec.Status__c = 'Pricing Approved';
        testSpec.dsStatus__c = 'Risk Assessment';
        testSpec.dsQualityEngineerApproval__c = 'Approved - Includes Plant Eng Approval';
        testspec.cncNeeded__c = 'Yes';
        testspec.ioxNeeded__c = 'Yes';
        testspec.screenPrint__c = 'Yes';
        testspec.ioxNeeded__c = 'Yes';
        update testSpec;
        test.stopTest();       
    }
    
    //Not Submitted - Non Team Member
    static testMethod void validateEditAccessToSpecificationsTest7() {
        //tUtils.SetTriggersOnForTesting();
        //tUtils.SetAutoNotificationSettingsForTesting();
        Specification__c testSpec;
        Account a = tUtils.addTestAccount(acctRT, 'TPM');
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        testSpec = tUtils.addTestSpec(a.id, o.id, specRT, false);
        testSpec.Status__c = 'Pricing Approved';
        INSERT testSpec;
        
        testSpec = [SELECT RecordType.Name FROM Specification__c WHERE Id = :testSpec.Id LIMIT 1];
        system.assertEquals('Parts',testSpec.RecordType.Name);
        test.startTest();
        testSpec.Application__c = 'Camera lens cover';//'Button';
        testSpec.qualityEngineerApproval__c = 'Approved - Includes Plant Eng Approval';
        testSpec.Status__c = 'Pricing Approved';
        update testSpec;
        test.stopTest();       
    }
    
    static testMethod void setInnovationAssessmentTest() {
        //tUtils.SetTriggersOnForTesting();
        //tUtils.SetAutoNotificationSettingsForTesting();
        Account a = tUtils.addTestAccount(acctRT, 'TPM');
        a.accountType__c = 'TPM';
        update a;
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Specification__c testSpec = tUtils.createTestSpec(a.id, o.id, specRT);
        testSpec.TPM__c = a.id;
        testSpec.SubmitforApproval__c = true;
        testSpec.ioxNeeded__c = 'No';
        testSpec.Innovation_Type__c = 'Screen Protector';
        insert testSpec;
        
        system.assertEquals(false,[SELECT innovationAssessmentComplete__c 
                                   FROM Specification__c 
                                   WHERE Id = :testSpec.id].innovationAssessmentComplete__c);
        
        test.startTest();
        testSpec.screenProtector__c = 'Approved';
        update testSpec;
        //system.assertEquals(true,[SELECT innovationAssessmentComplete__c 
        //                            FROM Specification__c 
        //                            WHERE Id = :testSpec.id].innovationAssessmentComplete__c);
        
        testSpec.vibrant__c = 'Approved';
        testSpec.declineReason__c = 'Supply Constraint';
        update testSpec;
        //system.assertEquals(true,[SELECT innovationAssessmentComplete__c 
        //                            FROM Specification__c 
        //                            WHERE Id = :testSpec.id].innovationAssessmentComplete__c);
        test.stopTest();
    }
    
    static testMethod void createSpecificationProductTest() {
        //tUtils.SetTriggersOnForTesting();
        //tUtils.SetAutoNotificationSettingsForTesting();
        Account a = tUtils.addTestAccount(acctRT, 'TPM');
        a.accountType__c = 'TPM';
        update a;
        
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        
        Specification__c testSpec = tUtils.createTestSpec(a.id, o.id, specRT);
        testSpec.TPM__c = a.id;
        testSpec.SubmitforApproval__c = true;
        testSpec.ioxNeeded__c = 'No';
        testSpec.Innovation_Type__c = 'EZ/AR';
        testSpec.arSolution__c = 'AR Only – One Side';
        insert testSpec;
        
        //testSpec.ezAr__c = 'Approved';
        //testSpec.phire20__c = 'Not Approved';
        //testSpec.vibrant__c = 'Approved';
        //testSpec.declineReason__c = 'Supply Constraint';
        //update testSpec;
        
        testSpec.moq__c = 100;
        testSpec.price1__c = 1000;
        testSpec.upperLimit1__c = 1000;
        testSpec.Status__c = 'Pricing Assignment';
        testSpec.PricingAssignmentComplete__c = true;
        update testSpec;
        
        testSpec.Status__c = 'Pricing Approved';
        update testSpec;
    }
    
    static testMethod void validateRawMTORequiredFieldsForSubmitTest() {
        //tUtils.SetTriggersOnForTesting();
        //tUtils.SetAutoNotificationSettingsForTesting();
        Account a = tUtils.addTestAccount(acctRT, 'TPM');
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Specification__c testSpec = tUtils.createTestSpec(a.id, o.id, specRT2);
        
        list<string> theList = new list<string>();
        SpecificationTriggerHelper.validateRawMTORequiredFieldsForSubmit(testSpec, theList);
        system.assertNotEquals(NULL, theList); 
    }
    
    static testMethod void validateConcoreMTORequiredFieldsForSubmitTest() {
        //tUtils.SetTriggersOnForTesting();
        Account a = tUtils.addTestAccount(acctRT, 'TPM');
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Specification__c testSpec = tUtils.createTestSpec(a.id, o.id, specRT3);
        
        list<string> theList = new list<string>();
        SpecificationTriggerHelper.validateConcoreMTORequiredFieldsForSubmit(testSpec, theList);
        system.assertNotEquals(NULL, theList); 
    }
    
    //Valid
    static testMethod void validateReadyForSubmitTest1() {
        //tUtils.SetTriggersOnForTesting();
        //tUtils.SetAutoNotificationSettingsForTesting();
        list<Specification__c> theList = new list<Specification__c>();
        
        Account a = tUtils.addTestAccount(acctRT, 'TPM');
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Specification__c testSpec = tUtils.createTestSpec(a.id, o.id, specRT);
        testSpec.submitForApproval__c = true;
        testSpec.Status__c = 'New';
        testSpec.cncNeeded__c = 'Yes'; 
        testSpec.selectIoxDolCsValueTarget__c = 'Customized';
        testSpec.arEtcPvd__c = 'Yes';
        testSpec.screenPrint__c = 'Yes';
        theList.add(testSpec);
        
        SpecificationTriggerHelper.validateReadyForSubmit(theList);
        try{
            insert theList;
        }
        catch (exception e) { //get Here
            system.assertEquals(true,e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
    }
    
    static testMethod void validateReadyForSubmitTest2() {
        //tUtils.SetTriggersOnForTesting();
        //tUtils.SetAutoNotificationSettingsForTesting();
        Account a = tUtils.addTestAccount(acctRT, 'TPM');
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Specification__c testSpec = tUtils.createTestSpec(a.id, o.id, specRT2);
        testSpec.submitForApproval__c = true;
        testSpec.Status__c = 'New';
        list<Specification__c> theList = new list<Specification__c>();
        
        theList.add(testSpec);
        SpecificationTriggerHelper.validateReadyForSubmit(theList);
        try{
            insert theList;
        }
        catch (exception e) { //Don't get here
            system.assertEquals(false,e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
    }
    
    static testMethod void validateReadyForSubmitTest3() {
        //tUtils.SetTriggersOnForTesting();
        //tUtils.SetAutoNotificationSettingsForTesting();
        Account a = tUtils.addTestAccount(acctRT, 'TPM');
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Specification__c testSpec = tUtils.createTestSpec(a.id, o.id, specRT3);
        testSpec.submitForApproval__c = true;
        testSpec.Status__c = 'New';
        list<Specification__c> theList = new list<Specification__c>();
        
        theList.add(testSpec);
        SpecificationTriggerHelper.validateReadyForSubmit(theList);
        try{
            insert theList;
        }
        catch (exception e) { //Don't get here
            system.assertEquals(false,e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
    }
    
    @isTest
    public static void unitTestForCheckAndLoadRFI(){
        Account a = tUtils.addTestAccount(acctRT, 'TPM');
        a.accountType__c = 'TPM';
        update a;
        
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        
        Specification__c testSpec = tUtils.createTestSpec(a.id, o.id, specRT4);
        testSpec.TPM__c = a.id;
        testSpec.SubmitforApproval__c = true;
        insert testSpec;
        
        rfiConfiguration__c r = tUtils.addTestRFI('Corning standard 2D IT blank part spec.');
        testSpec.Status__c = 'Pricing Assignment';
        testSpec.rfiConfiguration__c = 'Corning standard 2D IT blank part spec.';    
        update testSpec;
        
        testSpec.Currency__c = 'RMB';
        testSpec.Status__c = 'Pricing Approved';
        update testSpec;
        System.debug('testSpec===%%%>' + testSpec);
    }
    
    @isTest
    public static void unitTestForProductAndPBEntry(){
        Specification__c testSpec;
        Specification__c testSpec2;
        Specification__c testSpec3;
        /*User ta;
        Account a;
        ID roleId = tUtils.getRoleId('GG Exclusive (Blue)');
        User thisUser = [Select Id From User Where Id =: UserInfo.getUserId() ];
        system.runAs ( thisUser ) {
            ta = (tUtils.addTestUsers(profileId,1,roleId))[0];
        }
        
        system.runAs ( ta ) {
            a = tUtils.addTestAccount(acctRT);
        }*/
        Account a = tUtils.addTestAccount(acctRT, 'TPM');
       // a.exclusiveAccountType__c = 'Blue';
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        testSpec = tUtils.addTestSpec(a.id, o.id, specRT, false);
        testSpec.Status__c = 'Pricing Assignment';
        testSpec.glassComposition__c = '1805';
        
        //testSpec.Innovation_Type__c = 'Glass Ceramics';
         
        //testSpec.price1__c = 100;
        //testSpec.width__c = 10.00;
        Insert testSpec;
        try{
            testSpec2 = [SELECT Id,Name,Status__c,productName__c,unitCostSqFt__c,
                        shippingCostSqFt__c,
                        ownerid__c,
                        price1__c,
                        price2__c,
                        price3__c,
                        price4__c,
                        upperLimit1__c,
                        upperLimit2__c,
                        upperLimit3__c,
                        upperLimit4__c,
                        samplePrice__c 
                        FROM Specification__c WHERE Id = :testSpec.Id];
        }catch(Exception e){
            System.debug('Error:' + e.getCause());
        }
        
        Map<Id,Specification__c> specById = new Map<Id, Specification__c>();
        specById.put(testSpec2.Id, testSpec2);
        testSpec.Status__c = 'Pricing Assignment';
        update testSpec;
        testSpec.unitCostSqFt__c = testSpec2.unitCostSqFt__c;
        testSpec.shippingCostSqFt__c = testSpec2.shippingCostSqFt__c;
        //testSpec = testSpec2;
        testSpec.Status__c = 'Pricing Approved';
        
        update testSpec;
        Test.startTest();
        /*try{
            testSpec = [SELECT Id,Name,Status__c,productName__c, 
                        description__c,
                        productLine__c,
                        glassComposition__c,
                        Innovation_Type__c,
                        isMTO__c,
                        isStandardOverride__c,
                        length__c,
                        moq__c,
                        sampleMoq__c,
                        moqUOM__c, 
                        opportunity__c,
                        sku__c,
                        thickness__c,
                        width__c,
                        ctLevel__c,
                        specialShapes__c,
                        specialRequirements__c,
                        includeCorningPacking__c,
                        maximumCrateDimensions__c,
                        estimatedCrateSheetCount__c,
                        account__c,
                        unitCostSqFt__c,
                        shippingCostSqFt__c,
                        ownerid__c,
                        price1__c,
                        price2__c,
                        price3__c,
                        price4__c,
                        upperLimit1__c,
                        upperLimit2__c,
                        upperLimit3__c,
                        upperLimit4__c,
                        samplePrice__c
                        FROM Specification__c WHERE Id = :testSpec.Id];
        }catch(Exception e){
            System.debug('Error:' + e.getCause());
        }*/
        Formula.recalculateFormulas(new List<Specification__c>{testSpec});
        List<Specification__c> specs = new List<Specification__c>{testSpec};
            System.debug('specById Product Name$$$$$$$>' + specById.get(specs.get(0).Id).productName__c);
        System.debug('specs Product Name $$$$$$$$$>' + specs.get(0).productName__c);
        System.debug('specById status$$$$$$$>' + specById.get(specs.get(0).Id).Status__c);
        System.debug('specs status$$$$$$$$$>' + specs.get(0).Status__c);
         
        SpecificationTriggerHelper.createProductAndPricebookEntry(specs, specById);
        Test.stopTest();
    }
}