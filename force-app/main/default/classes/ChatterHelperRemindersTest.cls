/**
 * @description       : 
 * @author            : Adam Nicholson?
 * @group             : 
 * @last modified on  : 07-10-2020
 * @last modified by  : Arquimidez Mora
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.1   07-10-2020   Arquimidez Mora   Fixing test class
**/
// ConnectApi methods are not supported in data siloed tests.
// Please use @IsTest(SeeAllData=true). Class.ConnectApi.ChatterFeeds.postFeedElement

@IsTest(SeeAllData=true)
private class ChatterHelperRemindersTest {
    static TestUtilities tUtils = new TestUtilities();
    private static string acctRT;
    private static string oppRT;
    private static string specRT;
    private static string specRT2;
    private static string specRT3;
    private static string specRT4;
    private static string profileId;
    
    static {
        acctRT = '0121J000000U1cV'; // GG Account
        oppRT = '0121J000000U1cZ'; // GG Program
        specRT = '0121J000000U1cj'; // Parts
        specRT2 = '0121J000000U1cm'; // Raw Glass
        specRT4 = '0121J000001DcdR'; // Parts - RFI
    }

    static Specification__c createNewTestSpec(String recordId, String acctType) { 
        Account a = tUtils.addTestAccount(acctRT, acctType);        
        Opportunity o = tUtils.addTestOppt(a.Id, oppRT);        
        Specification__c s = tUtils.createTestSpec(a.id, o.id, recordId);
        return s;
    }

    // Parts Reminder
    static testMethod void validatePartsReminderMissingInformationAssessment() {
         
        List <Specification__c> sList = new List <Specification__c>();
         
        Specification__c testSpec = createNewTestSpec(specRT, 'TPM');
        testSpec.submitForApproval__c = true;
        insert testSpec;

        string testId = testSpec.id;
        
        Specification__c testSpec2 = [SELECT Id, statusChangeDate__c, reminderCompleted__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];

        testSpec2.statusChangeDate__c = System.Date.today().addmonths(-1);
        testSpec2.reminderCompleted__c = false;
        update testSpec2;
        
        Specification__c testSpec3 = [SELECT Id, statusChangeDate__c, productLine__c, reminderCompleted__c, status__c, location__c, dsStatusChangeDate__c, dsReminderCompleted__c, dsStatus__c, dsLocation__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];        
        sList.add(testSpec3);
        
        ChatterHelper.specificationReminder( sList ); 
                
    }
 
    // Parts Reminder
    static testMethod void validatePartsReminderManufacturerAssignment() {
         
        List <Specification__c> sList = new List <Specification__c>();
         
        Specification__c testSpec = createNewTestSpec(specRT, 'TPM');
        testSpec.dsSource__c = 'Dual Source Accepted';
        testSpec.submitForApproval__c = true;
        insert testSpec;

        string testId = testSpec.id;
        
        Specification__c testSpec2 = [SELECT Id, missingInformation__c, missingInformationAssessmentComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.missingInformation__c = 'No';
        testSpec2.missingInformationAssessmentComplete__c = True;
        update testSpec2;
        
        Specification__c testSpec3 = [SELECT Id, capable__c, capabilityAssessmentComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec3.capable__c = 'Yes';
        testSpec3.capabilityAssessmentComplete__c = True;
        update testSpec3;

        Specification__c testSpec4 = [SELECT Id, standard__c, standardAssessmentComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];     
        testSpec4.standard__c = 'Yes';
        testSpec4.standardAssessmentComplete__c = True;
        update testSpec4;

        Specification__c testSpec5 = [SELECT Id, statusChangeDate__c, reminderCompleted__c, location__c, dsStatusChangeDate__c, dsReminderCompleted__c, dsLocation__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];               
        testSpec5.location__c = 'Biel';
        testSpec5.statusChangeDate__c = System.Date.today().addmonths(-1);
        testSpec5.reminderCompleted__c = false;
        testSpec5.dsLocation__c = 'Biel';
        testSpec5.dsStatusChangeDate__c = System.Date.today().addmonths(-1);
        testSpec5.dsReminderCompleted__c = false;        
        update testSpec5;
        
        Specification__c testSpec6 = [SELECT Id, statusChangeDate__c, productLine__c, reminderCompleted__c, status__c, location__c, dsStatusChangeDate__c, dsReminderCompleted__c, dsStatus__c, dsLocation__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];           
        sList.add(testSpec6);
        
        ChatterHelper.specificationReminder( sList ); 
                
    }

    // Parts Reminder
    static testMethod void validatePartsReminderRiskAssessment() {
         
        List <Specification__c> sList = new List <Specification__c>();
         
        Specification__c testSpec = createNewTestSpec(specRT, 'TPM');
        testSpec.dsSource__c = 'Dual Source Accepted';
        testSpec.submitForApproval__c = true;
        insert testSpec;

        string testId = testSpec.id;
        
        Specification__c testSpec2 = [SELECT Id, missingInformation__c, missingInformationAssessmentComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.missingInformation__c = 'No';
        testSpec2.missingInformationAssessmentComplete__c = True;
        update testSpec2;
        
        Specification__c testSpec3 = [SELECT Id, capable__c, capabilityAssessmentComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec3.capable__c = 'Yes';
        testSpec3.capabilityAssessmentComplete__c = True;
        update testSpec3;

        Specification__c testSpec4 = [SELECT Id, standard__c, standardAssessmentComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];     
        testSpec4.standard__c = 'Yes';
        testSpec4.standardAssessmentComplete__c = True;
        update testSpec4;

        Specification__c testSpec5 = [SELECT Id, location__c, manufacturingAssignmentComplete__c, dsActualSource__c, dsLocation__c, dsManufacturingAssignmentComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];               
        testSpec5.location__c = 'Biel';
        testSpec5.manufacturingAssignmentComplete__c = True;
        testSpec5.dsActualSource__c = 'Dual Source';
        testSpec5.dsLocation__c = 'Biel';
        testSpec5.dsManufacturingAssignmentComplete__c = True;
        update testSpec5;

        Specification__c testSpec6 = [SELECT Id, statusChangeDate__c, reminderCompleted__c, dsStatusChangeDate__c, dsReminderCompleted__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];               
        testSpec6.statusChangeDate__c = System.Date.today().addmonths(-1);
        testSpec6.reminderCompleted__c = false;
        testSpec6.dsStatusChangeDate__c = System.Date.today().addmonths(-1);
        testSpec6.dsReminderCompleted__c = false;
        update testSpec6;
        
        Specification__c testSpec7 = [SELECT Id, statusChangeDate__c, productLine__c, reminderCompleted__c, status__c, location__c, dsStatusChangeDate__c, dsReminderCompleted__c, dsStatus__c, dsLocation__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];        
        sList.add(testSpec7);
        
        ChatterHelper.specificationReminder( sList ); 
                
    }

    // Parts Reminder
    static testMethod void validatePartsReminderCMCostAssessment() {
         
        List <Specification__c> sList = new List <Specification__c>();
         
        Specification__c testSpec = createNewTestSpec(specRT, 'TPM');
        testSpec.dsSource__c = 'Dual Source Accepted';
        testSpec.submitForApproval__c = true;
        insert testSpec;

        string testId = testSpec.id;
        
        Specification__c testSpec2 = [SELECT Id, missingInformation__c, missingInformationAssessmentComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.missingInformation__c = 'No';
        testSpec2.missingInformationAssessmentComplete__c = True;
        update testSpec2;
        
        Specification__c testSpec3 = [SELECT Id, capable__c, capabilityAssessmentComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec3.capable__c = 'Yes';
        testSpec3.capabilityAssessmentComplete__c = True;
        update testSpec3;

        Specification__c testSpec4 = [SELECT Id, standard__c, standardAssessmentComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];     
        testSpec4.standard__c = 'Yes';
        testSpec4.standardAssessmentComplete__c = True;
        update testSpec4;

        Specification__c testSpec5 = [SELECT Id, status__c, dsStatus__c, location__c, manufacturingAssignmentComplete__c, dsActualSource__c, dsLocation__c, dsManufacturingAssignmentComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];               
        system.debug('!!!!! ' + testSpec5.status__c + ' | ' + testSpec5.dsStatus__c); 

        testSpec5.location__c = 'Biel';
        testSpec5.manufacturingAssignmentComplete__c = True;
        testSpec5.dsActualSource__c = 'Dual Source';
        testSpec5.dsLocation__c = 'Biel';
        testSpec5.dsManufacturingAssignmentComplete__c = True;
        update testSpec5;

        Specification__c testSpec6 = [SELECT Id, status__c, dsStatus__c, qualityEngineerApproval__c, dsQualityEngineerApproval__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];       
        system.debug('!!!!! ' + testSpec6.status__c + ' | ' + testSpec6.dsStatus__c); 

        testSpec6.qualityEngineerApproval__c = 'Approved - Includes Plant Eng Approval';
        testSpec6.dsQualityEngineerApproval__c = 'Approved - Includes Plant Eng Approval';
        update testSpec6;

        Specification__c testSpec7 = [SELECT Id, status__c, dsStatus__c, statusChangeDate__c, reminderCompleted__c, dsStatusChangeDate__c, dsReminderCompleted__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];               
        system.debug('!!!!! ' + testSpec7.status__c + ' | ' + testSpec7.dsStatus__c); 
        
        testSpec7.statusChangeDate__c = System.Date.today().addmonths(-1);
        testSpec7.reminderCompleted__c = false;
        testSpec7.dsStatusChangeDate__c = System.Date.today().addmonths(-1);
        testSpec7.dsReminderCompleted__c = false;
        update testSpec7;
        
        Specification__c testSpec8 = [SELECT Id, statusChangeDate__c, productLine__c, reminderCompleted__c, status__c, location__c, dsStatusChangeDate__c, dsReminderCompleted__c, dsStatus__c, dsLocation__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];        
        system.debug('!!!!! ' + testSpec8.status__c + ' | ' + testSpec8.dsStatus__c);        

        sList.add(testSpec8);
        
        ChatterHelper.specificationReminder( sList ); 
                
    }
    
    // Parts Reminder
    static testMethod void validatePartsReminderPricingAssignment() {
         
        List <Specification__c> sList = new List <Specification__c>();
         
        Specification__c testSpec = createNewTestSpec(specRT, 'TPM');
        testSpec.submitForApproval__c = true;
        insert testSpec;

        string testId = testSpec.id;
        
        Specification__c testSpec2 = [SELECT Id, missingInformation__c, missingInformationAssessmentComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.missingInformation__c = 'No';
        testSpec2.missingInformationAssessmentComplete__c = True;
        update testSpec2;
        
        Specification__c testSpec3 = [SELECT Id, capable__c, capabilityAssessmentComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec3.capable__c = 'Yes';
        testSpec3.capabilityAssessmentComplete__c = True;
        update testSpec3;

        Specification__c testSpec4 = [SELECT Id, standard__c, standardAssessmentComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];     
        testSpec4.standard__c = 'Yes';
        testSpec4.standardAssessmentComplete__c = True;
        update testSpec4;

        Specification__c testSpec5 = [SELECT Id, location__c, manufacturingAssignmentComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];               
        testSpec5.location__c = 'Biel';
        testSpec5.manufacturingAssignmentComplete__c = True;
        update testSpec5;

        Specification__c testSpec6 = [SELECT Id, qualityEngineerApproval__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec6.qualityEngineerApproval__c = 'Approved - Includes Plant Eng Approval';
        update testSpec6;
        
        Specification__c testSpec7 = [SELECT Id, costApproval__c, costAssessmentComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec7.costApproval__c = 'Accepted';
        testSpec7.costAssessmentComplete__c = True;
        update testSpec7;

        Specification__c testSpec8 = [SELECT Id, statusChangeDate__c, reminderCompleted__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];               
        testSpec8.statusChangeDate__c = System.Date.today().addmonths(-1);
        testSpec8.reminderCompleted__c = false;
        update testSpec8;
        
        Specification__c testSpec9 = [SELECT Id, statusChangeDate__c, productLine__c, reminderCompleted__c, status__c, location__c, dsStatusChangeDate__c, dsReminderCompleted__c, dsStatus__c, dsLocation__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];        
        sList.add(testSpec9);
        
        ChatterHelper.specificationReminder( sList ); 
                
    }
        
    // Raw Path 1
    static testMethod void validateRawReminderSAIR() {

        List <Specification__c> sList = new List <Specification__c>();
         
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');
        testSpec.glassComposition__c = '2320 (GG3)'; // 2320 is Path 1 // 11-16-20 jd (change to '2320 (GG3)'')
        testSpec.submitForApproval__c = true;       
        insert testSpec;
        
        string testId = testSpec.id;
        
        Specification__c testSpec2 = [SELECT Id, statusChangeDate__c, reminderCompleted__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.statusChangeDate__c = System.Date.today().addmonths(-1);
        testSpec2.reminderCompleted__c = false;
        update testSpec2;
        
        Specification__c testSpec3 = [SELECT Id, statusChangeDate__c, productLine__c, reminderCompleted__c, status__c, mtoNotificationPath__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];        
        sList.add(testSpec3);
        
        ChatterHelper.specificationReminder( sList ); 
        
    }
    
    // Raw Path 1
    static testMethod void validateRawReminderProductEngineeringInput() {

        List <Specification__c> sList = new List <Specification__c>();
         
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');
        testSpec.glassComposition__c = '2320 (GG3)'; // 2320 is Path 1 // 11-16-20 jd (change to '2320 (GG3)'')
        testSpec.submitForApproval__c = true;       
        insert testSpec;
        
        string testId = testSpec.id;
        
        Specification__c testSpec2 = [SELECT Id, supplyAllocationInventory__c, supplyAllocInventoryReviewComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.supplyAllocationInventory__c = 'Approved';
        testSpec2.supplyAllocInventoryReviewComplete__c = True;
        update testSpec2;
       
        Specification__c testSpec3 = [SELECT Id, statusChangeDate__c, reminderCompleted__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec3.statusChangeDate__c = System.Date.today().addmonths(-1);
        testSpec3.reminderCompleted__c = false;
        update testSpec3;
        
        Specification__c testSpec4 = [SELECT Id, statusChangeDate__c, productLine__c, reminderCompleted__c, status__c, mtoNotificationPath__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];        
        sList.add(testSpec4);
        
        ChatterHelper.specificationReminder( sList ); 
        
    }

    // Raw Path 1
    static testMethod void validateRawReminderPlantEngineeringInput() {

        List <Specification__c> sList = new List <Specification__c>();
         
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');
        testSpec.glassComposition__c = '2320 (GG3)'; // 2320 is Path 1 // 11-16-20 jd (change to '2320 (GG3)'')
        testSpec.submitForApproval__c = true;       
        insert testSpec;
        
        string testId = testSpec.id;
        
        Specification__c testSpec2 = [SELECT Id, supplyAllocationInventory__c, supplyAllocInventoryReviewComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.supplyAllocationInventory__c = 'Approved';
        testSpec2.supplyAllocInventoryReviewComplete__c = True;
        update testSpec2;

        Specification__c testSpec3 = [SELECT Id, productEngineeringInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec3.productEngineeringInputReceived__c = True;
        update testSpec3;
       
        Specification__c testSpec4 = [SELECT Id, statusChangeDate__c, reminderCompleted__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec4.statusChangeDate__c = System.Date.today().addmonths(-1);
        testSpec4.reminderCompleted__c = false;
        update testSpec4;
        
        Specification__c testSpec5 = [SELECT Id, statusChangeDate__c, productLine__c, reminderCompleted__c, status__c, mtoNotificationPath__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];        
        sList.add(testSpec5);
        
        ChatterHelper.specificationReminder( sList ); 
        
    }

    // Raw Path 1
    static testMethod void validateRawReminderSupplyChainInput() {

        List <Specification__c> sList = new List <Specification__c>();
         
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');
        testSpec.glassComposition__c = '2320 (GG3)'; // 2320 is Path 1 // 11-16-20 jd (change to '2320 (GG3)'')
        testSpec.submitForApproval__c = true;       
        insert testSpec;
        
        string testId = testSpec.id;
        
        Specification__c testSpec2 = [SELECT Id, supplyAllocationInventory__c, supplyAllocInventoryReviewComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.supplyAllocationInventory__c = 'Approved';
        testSpec2.supplyAllocInventoryReviewComplete__c = True;
        update testSpec2;

        Specification__c testSpec3 = [SELECT Id, productEngineeringInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec3.productEngineeringInputReceived__c = True;
        update testSpec3;
        
        Specification__c testSpec4 = [SELECT Id, engineeringInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];     
        testSpec4.engineeringInputReceived__c = True;
        update testSpec4;
       
        Specification__c testSpec5 = [SELECT Id, statusChangeDate__c, reminderCompleted__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec5.statusChangeDate__c = System.Date.today().addmonths(-1);
        testSpec5.reminderCompleted__c = false;
        update testSpec5;
        
        Specification__c testSpec6 = [SELECT Id, statusChangeDate__c, productLine__c, reminderCompleted__c, status__c, mtoNotificationPath__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];        
        sList.add(testSpec6);
        
        ChatterHelper.specificationReminder( sList ); 
        
    }

    // Raw Path 1
    static testMethod void validateRawReminderPricingassignment() {

        List <Specification__c> sList = new List <Specification__c>();
         
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');
        testSpec.glassComposition__c = '2320 (GG3)'; // 2320 is Path 1 // 11-16-20 jd (change to '2320 (GG3)'')
        testSpec.submitForApproval__c = true;       
        insert testSpec;
        
        string testId = testSpec.id;
        
        Specification__c testSpec2 = [SELECT Id, supplyAllocationInventory__c, supplyAllocInventoryReviewComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.supplyAllocationInventory__c = 'Approved';
        testSpec2.supplyAllocInventoryReviewComplete__c = True;
        update testSpec2;

        Specification__c testSpec3 = [SELECT Id, productEngineeringInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec3.productEngineeringInputReceived__c = True;
        update testSpec3;
        
        Specification__c testSpec4 = [SELECT Id, engineeringInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];     
        testSpec4.engineeringInputReceived__c = True;
        update testSpec4;

        Specification__c testSpec5 = [SELECT Id, supplyChainInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];               
        testSpec5.supplyChainInputReceived__c = True;
        update testSpec5;
       
        Specification__c testSpec6 = [SELECT Id, statusChangeDate__c, reminderCompleted__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec6.statusChangeDate__c = System.Date.today().addmonths(-1);
        testSpec6.reminderCompleted__c = false;
        update testSpec6;
        
        Specification__c testSpec7 = [SELECT Id, statusChangeDate__c, productLine__c, reminderCompleted__c, status__c, mtoNotificationPath__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];        
        sList.add(testSpec7);
        
        ChatterHelper.specificationReminder( sList ); 
        
    }

    // Raw Path 1
    static testMethod void validateRawReminderBusinessCaseFinalization() {

        List <Specification__c> sList = new List <Specification__c>();
         
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');
        testSpec.glassComposition__c = '2320 (GG3)'; // 2320 is Path 1 // 11-16-20 jd (change to '2320 (GG3)'')
        testSpec.submitForApproval__c = true;       
        insert testSpec;
        
        string testId = testSpec.id;
        
        Specification__c testSpec2 = [SELECT Id, supplyAllocationInventory__c, supplyAllocInventoryReviewComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.supplyAllocationInventory__c = 'Approved';
        testSpec2.supplyAllocInventoryReviewComplete__c = True;
        update testSpec2;

        Specification__c testSpec3 = [SELECT Id, productEngineeringInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec3.productEngineeringInputReceived__c = True;
        update testSpec3;
        
        Specification__c testSpec4 = [SELECT Id, engineeringInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];     
        testSpec4.engineeringInputReceived__c = True;
        update testSpec4;

        Specification__c testSpec5 = [SELECT Id, supplyChainInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];               
        testSpec5.supplyChainInputReceived__c = True;
        update testSpec5;
 
        Specification__c testSpec6 = [SELECT Id, moq__c, moqUom__c, unitCostSqFt__c, shippingCostSqFt__c, pricingAssignmentComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec6.moq__c = 1;
        testSpec6.moqUom__c = 'Each';
        testSpec6.unitCostSqFt__c = 1;
        testSpec6.shippingCostSqFt__c = 1;
        testSpec6.pricingAssignmentComplete__c = True;
        update testSpec6;
       
        Specification__c testSpec7 = [SELECT Id, statusChangeDate__c, reminderCompleted__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec7.statusChangeDate__c = System.Date.today().addmonths(-1);
        testSpec7.reminderCompleted__c = false;
        update testSpec7;
        
        Specification__c testSpec8 = [SELECT Id, statusChangeDate__c, productLine__c, reminderCompleted__c, status__c, mtoNotificationPath__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];        
        sList.add(testSpec8);
        
        ChatterHelper.specificationReminder( sList ); 
        
    }

    // Raw Path 1
    static testMethod void validateRawReminderFinanceReview() {

        List <Specification__c> sList = new List <Specification__c>();
         
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');
        testSpec.glassComposition__c = '2320 (GG3)'; // 2320 is Path 1 // 11-16-20 jd (change to '2320 (GG3)'')
        testSpec.submitForApproval__c = true;       
        insert testSpec;
        
        string testId = testSpec.id;
        
        Specification__c testSpec2 = [SELECT Id, supplyAllocationInventory__c, supplyAllocInventoryReviewComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.supplyAllocationInventory__c = 'Approved';
        testSpec2.supplyAllocInventoryReviewComplete__c = True;
        update testSpec2;

        Specification__c testSpec3 = [SELECT Id, productEngineeringInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec3.productEngineeringInputReceived__c = True;
        update testSpec3;
        
        Specification__c testSpec4 = [SELECT Id, engineeringInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];     
        testSpec4.engineeringInputReceived__c = True;
        update testSpec4;

        Specification__c testSpec5 = [SELECT Id, supplyChainInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];               
        testSpec5.supplyChainInputReceived__c = True;
        update testSpec5;
 
        Specification__c testSpec6 = [SELECT Id, moq__c, moqUom__c, unitCostSqFt__c, shippingCostSqFt__c, pricingAssignmentComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec6.moq__c = 1;
        testSpec6.moqUom__c = 'Each';
        testSpec6.unitCostSqFt__c = 1;
        testSpec6.shippingCostSqFt__c = 1;
        testSpec6.pricingAssignmentComplete__c = True;
        update testSpec6;

        Specification__c testSpec7 = [SELECT Id, finalBusinessCaseComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec7.finalBusinessCaseComplete__c = True;
        update testSpec7; 
       
        Specification__c testSpec8 = [SELECT Id, statusChangeDate__c, reminderCompleted__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec8.statusChangeDate__c = System.Date.today().addmonths(-1);
        testSpec8.reminderCompleted__c = false;
        update testSpec8;
        
        Specification__c testSpec9 = [SELECT Id, statusChangeDate__c, productLine__c, reminderCompleted__c, status__c, mtoNotificationPath__c, recordTypeId, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];        
        sList.add(testSpec9);
        
        ChatterHelper.specificationReminder( sList ); 
        
    }

    // Raw Path 1
    static testMethod void validateRawReminderCommercialOpsReview() {

        List <Specification__c> sList = new List <Specification__c>();
         
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');
        testSpec.glassComposition__c = '2320 (GG3)'; // 2320 is Path 1 // 11-16-20 jd (change to '2320 (GG3)'')
        testSpec.submitForApproval__c = true;       
        insert testSpec;
        
        string testId = testSpec.id;
        
        Specification__c testSpec2 = [SELECT Id, supplyAllocationInventory__c, supplyAllocInventoryReviewComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.supplyAllocationInventory__c = 'Approved';
        testSpec2.supplyAllocInventoryReviewComplete__c = True;
        update testSpec2;

        Specification__c testSpec3 = [SELECT Id, productEngineeringInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec3.productEngineeringInputReceived__c = True;
        update testSpec3;
        
        Specification__c testSpec4 = [SELECT Id, engineeringInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];     
        testSpec4.engineeringInputReceived__c = True;
        update testSpec4;

        Specification__c testSpec5 = [SELECT Id, supplyChainInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];               
        testSpec5.supplyChainInputReceived__c = True;
        update testSpec5;
 
        Specification__c testSpec6 = [SELECT Id, moq__c, moqUom__c, unitCostSqFt__c, shippingCostSqFt__c, pricingAssignmentComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec6.moq__c = 1;
        testSpec6.moqUom__c = 'Each';
        testSpec6.unitCostSqFt__c = 1;
        testSpec6.shippingCostSqFt__c = 1;
        testSpec6.pricingAssignmentComplete__c = True;
        update testSpec6;
 
        Specification__c testSpec7 = [SELECT Id, finalBusinessCaseComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec7.finalBusinessCaseComplete__c = True;
        update testSpec7; 
       
        Specification__c testSpec8 = [SELECT Id, Finance_Review_Complete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec8.Finance_Review_Complete__c = True;
        update testSpec8; 

        Specification__c testSpec9 = [SELECT Id, statusChangeDate__c, reminderCompleted__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec9.statusChangeDate__c = System.Date.today().addmonths(-1);
        testSpec9.reminderCompleted__c = false;
        update testSpec9;
        
        Specification__c testSpec10 = [SELECT Id, statusChangeDate__c, productLine__c, reminderCompleted__c, status__c, mtoNotificationPath__c, recordTypeId, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];        
        sList.add(testSpec10);
        
        ChatterHelper.specificationReminder( sList ); 
        
    }

    // Raw Path 2
    static testMethod void validateRawReminderSAIR2() {

        List <Specification__c> sList = new List <Specification__c>();
         
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');
        testSpec.glassComposition__c = '9318'; // 9318 is Path 2
        testSpec.submitForApproval__c = true;       
        insert testSpec;
        
        string testId = testSpec.id;
        
        Specification__c testSpec2 = [SELECT Id, statusChangeDate__c, reminderCompleted__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.statusChangeDate__c = System.Date.today().addmonths(-1);
        testSpec2.reminderCompleted__c = false;
        update testSpec2;
        
        Specification__c testSpec3 = [SELECT Id, statusChangeDate__c, productLine__c, reminderCompleted__c, status__c, mtoNotificationPath__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];        
        sList.add(testSpec3);
        
        ChatterHelper.specificationReminder( sList ); 
        
    }
    
    // Raw Path 2
    static testMethod void validateRawReminderProductEngineeringInput2() {

        List <Specification__c> sList = new List <Specification__c>();
         
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');
        testSpec.glassComposition__c = '9318'; // 9318 is Path 2
        testSpec.submitForApproval__c = true;       
        insert testSpec;
        
        string testId = testSpec.id;
        
        Specification__c testSpec2 = [SELECT Id, supplyAllocationInventory__c, supplyAllocInventoryReviewComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.supplyAllocationInventory__c = 'Approved';
        testSpec2.supplyAllocInventoryReviewComplete__c = True;
        update testSpec2;
       
        Specification__c testSpec3 = [SELECT Id, statusChangeDate__c, reminderCompleted__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec3.statusChangeDate__c = System.Date.today().addmonths(-1);
        testSpec3.reminderCompleted__c = false;
        update testSpec3;
        
        Specification__c testSpec4 = [SELECT Id, statusChangeDate__c, productLine__c, reminderCompleted__c, status__c, mtoNotificationPath__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];        
        sList.add(testSpec4);
        
        ChatterHelper.specificationReminder( sList ); 
        
    }

    // Raw Path 2
    static testMethod void validateRawReminderPlantEngineeringInput2() {

        List <Specification__c> sList = new List <Specification__c>();
         
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');
        testSpec.glassComposition__c = '9318'; // 9318 is Path 2
        testSpec.submitForApproval__c = true;       
        insert testSpec;
        
        string testId = testSpec.id;
        
        Specification__c testSpec2 = [SELECT Id, supplyAllocationInventory__c, supplyAllocInventoryReviewComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.supplyAllocationInventory__c = 'Approved';
        testSpec2.supplyAllocInventoryReviewComplete__c = True;
        update testSpec2;

        Specification__c testSpec3 = [SELECT Id, productEngineeringInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec3.productEngineeringInputReceived__c = True;
        update testSpec3;
       
        Specification__c testSpec4 = [SELECT Id, statusChangeDate__c, reminderCompleted__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec4.statusChangeDate__c = System.Date.today().addmonths(-1);
        testSpec4.reminderCompleted__c = false;
        update testSpec4;
        
        Specification__c testSpec5 = [SELECT Id, statusChangeDate__c, productLine__c, reminderCompleted__c, status__c, mtoNotificationPath__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];        
        sList.add(testSpec5);
        
        ChatterHelper.specificationReminder( sList ); 
        
    }

    // Raw Path 2
    static testMethod void validateRawReminderSupplyChainInput2() {

        List <Specification__c> sList = new List <Specification__c>();
         
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');
        testSpec.glassComposition__c = '9318'; // 9318 is Path 2
        testSpec.submitForApproval__c = true;       
        insert testSpec;
        
        string testId = testSpec.id;
        
        Specification__c testSpec2 = [SELECT Id, supplyAllocationInventory__c, supplyAllocInventoryReviewComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.supplyAllocationInventory__c = 'Approved';
        testSpec2.supplyAllocInventoryReviewComplete__c = True;
        update testSpec2;

        Specification__c testSpec3 = [SELECT Id, productEngineeringInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec3.productEngineeringInputReceived__c = True;
        update testSpec3;
        
        Specification__c testSpec4 = [SELECT Id, engineeringInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];     
        testSpec4.engineeringInputReceived__c = True;
        update testSpec4;
       
        Specification__c testSpec5 = [SELECT Id, statusChangeDate__c, reminderCompleted__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec5.statusChangeDate__c = System.Date.today().addmonths(-1);
        testSpec5.reminderCompleted__c = false;
        update testSpec5;
        
        Specification__c testSpec6 = [SELECT Id, statusChangeDate__c, productLine__c, reminderCompleted__c, status__c, mtoNotificationPath__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];        
        sList.add(testSpec6);
        
        ChatterHelper.specificationReminder( sList ); 
        
    }

    // Raw Path 2
    static testMethod void validateRawReminderPricingassignment2() {

        List <Specification__c> sList = new List <Specification__c>();
         
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');
        testSpec.glassComposition__c = '9318'; // 9318 is Path 2
        testSpec.submitForApproval__c = true;       
        insert testSpec;
        
        string testId = testSpec.id;
        
        Specification__c testSpec2 = [SELECT Id, supplyAllocationInventory__c, supplyAllocInventoryReviewComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.supplyAllocationInventory__c = 'Approved';
        testSpec2.supplyAllocInventoryReviewComplete__c = True;
        update testSpec2;

        Specification__c testSpec3 = [SELECT Id, productEngineeringInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec3.productEngineeringInputReceived__c = True;
        update testSpec3;
        
        Specification__c testSpec4 = [SELECT Id, engineeringInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];     
        testSpec4.engineeringInputReceived__c = True;
        update testSpec4;

        Specification__c testSpec5 = [SELECT Id, supplyChainInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];               
        testSpec5.supplyChainInputReceived__c = True;
        update testSpec5;
       
        Specification__c testSpec6 = [SELECT Id, statusChangeDate__c, reminderCompleted__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec6.statusChangeDate__c = System.Date.today().addmonths(-1);
        testSpec6.reminderCompleted__c = false;
        update testSpec6;
        
        Specification__c testSpec7 = [SELECT Id, statusChangeDate__c, productLine__c, reminderCompleted__c, status__c, mtoNotificationPath__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];        
        sList.add(testSpec7);
        
        ChatterHelper.specificationReminder( sList ); 
        
    }

    // Raw Path 2
    static testMethod void validateRawReminderBusinessCaseFinalization2() {

        List <Specification__c> sList = new List <Specification__c>();
         
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');
        testSpec.glassComposition__c = '9318'; // 9318 is Path 2
        testSpec.submitForApproval__c = true;       
        insert testSpec;
        
        string testId = testSpec.id;
        
        Specification__c testSpec2 = [SELECT Id, supplyAllocationInventory__c, supplyAllocInventoryReviewComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.supplyAllocationInventory__c = 'Approved';
        testSpec2.supplyAllocInventoryReviewComplete__c = True;
        update testSpec2;

        Specification__c testSpec3 = [SELECT Id, productEngineeringInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec3.productEngineeringInputReceived__c = True;
        update testSpec3;
        
        Specification__c testSpec4 = [SELECT Id, engineeringInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];     
        testSpec4.engineeringInputReceived__c = True;
        update testSpec4;

        Specification__c testSpec5 = [SELECT Id, supplyChainInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];               
        testSpec5.supplyChainInputReceived__c = True;
        update testSpec5;
 
        Specification__c testSpec6 = [SELECT Id, moq__c, moqUom__c, unitCostSqFt__c, shippingCostSqFt__c, pricingAssignmentComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec6.moq__c = 1;
        testSpec6.moqUom__c = 'Each';
        testSpec6.unitCostSqFt__c = 1;
        testSpec6.shippingCostSqFt__c = 1;
        testSpec6.pricingAssignmentComplete__c = True;
        update testSpec6;
       
        Specification__c testSpec7 = [SELECT Id, statusChangeDate__c, reminderCompleted__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec7.statusChangeDate__c = System.Date.today().addmonths(-1);
        testSpec7.reminderCompleted__c = false;
        update testSpec7;
        
        Specification__c testSpec8 = [SELECT Id, statusChangeDate__c, productLine__c, reminderCompleted__c, status__c, mtoNotificationPath__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];        
        sList.add(testSpec8);
        
        ChatterHelper.specificationReminder( sList ); 
        
    }

    // Raw Path 2
    static testMethod void validateRawReminderFinanceReview2() {

        List <Specification__c> sList = new List <Specification__c>();
         
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');
        testSpec.glassComposition__c = '9318'; // 9318 is Path 2
        testSpec.submitForApproval__c = true;       
        insert testSpec;
        
        string testId = testSpec.id;
        
        Specification__c testSpec2 = [SELECT Id, supplyAllocationInventory__c, supplyAllocInventoryReviewComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.supplyAllocationInventory__c = 'Approved';
        testSpec2.supplyAllocInventoryReviewComplete__c = True;
        update testSpec2;

        Specification__c testSpec3 = [SELECT Id, productEngineeringInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec3.productEngineeringInputReceived__c = True;
        update testSpec3;
        
        Specification__c testSpec4 = [SELECT Id, engineeringInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];     
        testSpec4.engineeringInputReceived__c = True;
        update testSpec4;

        Specification__c testSpec5 = [SELECT Id, supplyChainInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];               
        testSpec5.supplyChainInputReceived__c = True;
        update testSpec5;
 
        Specification__c testSpec6 = [SELECT Id, moq__c, moqUom__c, unitCostSqFt__c, shippingCostSqFt__c, pricingAssignmentComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec6.moq__c = 1;
        testSpec6.moqUom__c = 'Each';
        testSpec6.unitCostSqFt__c = 1;
        testSpec6.shippingCostSqFt__c = 1;
        testSpec6.pricingAssignmentComplete__c = True;
        update testSpec6;

        Specification__c testSpec7 = [SELECT Id, finalBusinessCaseComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec7.finalBusinessCaseComplete__c = True;
        update testSpec7; 
       
        Specification__c testSpec8 = [SELECT Id, statusChangeDate__c, reminderCompleted__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec8.statusChangeDate__c = System.Date.today().addmonths(-1);
        testSpec8.reminderCompleted__c = false;
        update testSpec8;
        
        Specification__c testSpec9 = [SELECT Id, statusChangeDate__c, productLine__c, reminderCompleted__c, status__c, mtoNotificationPath__c, recordTypeId, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];        
        sList.add(testSpec9);
        
        ChatterHelper.specificationReminder( sList ); 
        
    }

    // Raw Path 2
    static testMethod void validateRawReminderCommercialOpsReview2() {

        List <Specification__c> sList = new List <Specification__c>();
         
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');
        testSpec.glassComposition__c = '9318'; // 9318 is Path 2
        testSpec.submitForApproval__c = true;       
        insert testSpec;
        
        string testId = testSpec.id;
        
        Specification__c testSpec2 = [SELECT Id, supplyAllocationInventory__c, supplyAllocInventoryReviewComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.supplyAllocationInventory__c = 'Approved';
        testSpec2.supplyAllocInventoryReviewComplete__c = True;
        update testSpec2;

        Specification__c testSpec3 = [SELECT Id, productEngineeringInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec3.productEngineeringInputReceived__c = True;
        update testSpec3;
        
        Specification__c testSpec4 = [SELECT Id, engineeringInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];     
        testSpec4.engineeringInputReceived__c = True;
        update testSpec4;

        Specification__c testSpec5 = [SELECT Id, supplyChainInputReceived__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];               
        testSpec5.supplyChainInputReceived__c = True;
        update testSpec5;
 
        Specification__c testSpec6 = [SELECT Id, moq__c, moqUom__c, unitCostSqFt__c, shippingCostSqFt__c, pricingAssignmentComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec6.moq__c = 1;
        testSpec6.moqUom__c = 'Each';
        testSpec6.unitCostSqFt__c = 1;
        testSpec6.shippingCostSqFt__c = 1;
        testSpec6.pricingAssignmentComplete__c = True;
        update testSpec6;
 
        Specification__c testSpec7 = [SELECT Id, finalBusinessCaseComplete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec7.finalBusinessCaseComplete__c = True;
        update testSpec7; 
       
        Specification__c testSpec8 = [SELECT Id, Finance_Review_Complete__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec8.Finance_Review_Complete__c = True;
        update testSpec8; 

        Specification__c testSpec9 = [SELECT Id, statusChangeDate__c, reminderCompleted__c, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec9.statusChangeDate__c = System.Date.today().addmonths(-1);
        testSpec9.reminderCompleted__c = false;
        update testSpec9;
        
        Specification__c testSpec10 = [SELECT Id, statusChangeDate__c, productLine__c, reminderCompleted__c, status__c, mtoNotificationPath__c, recordTypeId, Innovation_Type__c FROM Specification__c WHERE id =: testId limit 1];        
        sList.add(testSpec10);
        
        ChatterHelper.specificationReminder( sList ); 
        
    }

}