/**
 * @description       : 
 * @author            : ADAM nICHOLSON?
 * @group             : 
 * @last modified on  : 07-10-2020
 * @last modified by  : Arquimidez Mora
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   07-10-2020   Arquimidez Mora   Initial Version
**/
// ConnectApi methods are not supported in data siloed tests.
// Please use @IsTest(SeeAllData=true). Class.ConnectApi.ChatterFeeds.postFeedElement

@IsTest(SeeAllData=true)
private class ChatterHelperTest {
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
    
    // Parts - RFI
    static testMethod void validatePartsRFI() {
        
        rfiConfiguration__c r = tUtils.addTestRFI('Acer standard IT full feature spec. (ex. Origins)');
        
        Specification__c testSpec = createNewTestSpec(specRT4, 'TPM');
        testSpec.rfiConfiguration__c = 'Acer standard IT full feature spec. (ex. Origins)';   
        testSpec.submitForApproval__c = true;
        insert testSpec;
        
        string testId = testSpec.id;
        
        Specification__c testSpec2 = [SELECT Id, missingInformation__c, missingInformationAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.missingInformation__c = 'No';
        testSpec2.missingInformationAssessmentComplete__c = True;
        update testSpec2;
        
        Specification__c testSpec3 = [SELECT Id, manufacturingAssignmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];               
        testSpec3.location__c = 'Biel';        
        testSpec3.manufacturingAssignmentComplete__c = True;
        update testSpec3;
        
        Specification__c testSpec4 = [SELECT Id, costApproval__c, costAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec4.costApproval__c = 'Accepted';
        testSpec4.costAssessmentComplete__c = True;
        update testSpec4;
        
        Specification__c testSpec5 = [SELECT Id, upperLimit1__c, moqUom__c, moq__c, price1__c, plmApproval__c, pricingAssignmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];   
        testSpec5.plmApproval__c = 'Approved';
        testSpec5.pricingAssignmentComplete__c = TRUE;
        testSpec5.price1__c = 10;
        testSpec5.moq__c = 1;
        testSpec5.moqUom__c = 'Each';
        testSpec5.upperLimit1__c = 100;
        update testSpec5;
        
    }
    
    // Parts
    static testMethod void validatePartsDeclined() {
        
        Specification__c testSpec = createNewTestSpec(specRT, 'TPM');
        testSpec.submitForApproval__c = true;
        insert testSpec;
        
        string testId = testSpec.id;
        Specification__c testSpec2 = [SELECT Id, missingInformation__c, missingInformationAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.missingInformation__c = 'No';
        testSpec2.missingInformationAssessmentComplete__c = True;
        update testSpec2;
        
        testSpec2.status__c = 'Declined';
        update testSpec2;
        
    }
    
    static testMethod void validatePartsRisk() {
        
        Specification__c testSpec = createNewTestSpec(specRT, 'TPM');
        testSpec.submitForApproval__c = true;
        insert testSpec;
        
        string testId = testSpec.id;
        Specification__c testSpec2 = [SELECT Id, missingInformation__c, missingInformationAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.missingInformation__c = 'No';
        testSpec2.missingInformationAssessmentComplete__c = True;
        update testSpec2;
        
        Specification__c testSpec3 = [SELECT Id, capable__c, capabilityAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec3.capable__c = 'Yes';
        testSpec3.capabilityAssessmentComplete__c = True;
        update testSpec3;
        
        Specification__c testSpec4 = [SELECT Id, standard__c, standardAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];     
        testSpec4.standard__c = 'Yes';
        testSpec4.standardAssessmentComplete__c = True;
        update testSpec4;
        
        Specification__c testSpec5 = [SELECT Id, manufacturingAssignmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];               
        testSpec5.location__c = 'Biel';
        testSpec5.manufacturingAssignmentComplete__c = True;
        update testSpec5;
        
        Specification__c testSpec6 = [SELECT Id, qualityEngineerApproval__c, thickness__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec6.qualityEngineerApproval__c = 'Approved - Requires Plant Eng Approval';
        update testSpec6;
        
        testSpec6.qualityEngineerApproval__c = 'Reviewed - More Information Required';
        update testSpec6;
        
        testSpec6.qualityEngineerApproval__c = 'Customer Responded - QA to Confirm';
        update testSpec6;
        
        testSpec6.thickness__c = 3;
        update testSpec6;
        
        testSpec6.qualityEngineerApproval__c = 'Reassign CM';
        update testSpec6;
        
    }
    
    static testMethod void validatePartsCA2MA() {
        
        Specification__c testSpec = createNewTestSpec(specRT, 'TPM');
        testSpec.submitForApproval__c = true;
        insert testSpec;
        
        string testId = testSpec.id;
        Specification__c testSpec2 = [SELECT Id, missingInformation__c, missingInformationAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.missingInformation__c = 'No';
        testSpec2.missingInformationAssessmentComplete__c = True;
        update testSpec2;
        
        Specification__c testSpec3 = [SELECT Id, capable__c, capabilityAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec3.capable__c = 'Yes';
        testSpec3.capabilityAssessmentComplete__c = True;
        update testSpec3;
        
        Specification__c testSpec4 = [SELECT Id, standard__c, standardAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];     
        testSpec4.standard__c = 'Yes';
        testSpec4.standardAssessmentComplete__c = True;
        update testSpec4;
        
        Specification__c testSpec5 = [SELECT Id, manufacturingAssignmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];               
        testSpec5.location__c = 'Biel';
        testSpec5.manufacturingAssignmentComplete__c = True;
        update testSpec5;
        
        Specification__c testSpec6 = [SELECT Id, qualityEngineerApproval__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec6.qualityEngineerApproval__c = 'Approved - Includes Plant Eng Approval';
        update testSpec6;
        
        Specification__c testSpec7 = [SELECT Id, costApproval__c, costAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec7.costApproval__c = 'Reassign CM';
        testSpec7.costAssessmentComplete__c = True;
        update testSpec7;
        
    }
    
    static testMethod void validatePartsPA2MA() {
        
        Specification__c testSpec = createNewTestSpec(specRT, 'TPM');
        testSpec.submitForApproval__c = true;
        insert testSpec;
        
        string testId = testSpec.id;
        Specification__c testSpec2 = [SELECT Id, missingInformation__c, missingInformationAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.missingInformation__c = 'No';
        testSpec2.missingInformationAssessmentComplete__c = True;
        update testSpec2;
        
        Specification__c testSpec3 = [SELECT Id, capable__c, capabilityAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec3.capable__c = 'Yes';
        testSpec3.capabilityAssessmentComplete__c = True;
        update testSpec3;
        
        Specification__c testSpec4 = [SELECT Id, standard__c, standardAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];     
        testSpec4.standard__c = 'Yes';
        testSpec4.standardAssessmentComplete__c = True;
        update testSpec4;
        
        Specification__c testSpec5 = [SELECT Id, manufacturingAssignmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];               
        testSpec5.location__c = 'Biel';
        testSpec5.manufacturingAssignmentComplete__c = True;
        update testSpec5;
        
        Specification__c testSpec6 = [SELECT Id, qualityEngineerApproval__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec6.qualityEngineerApproval__c = 'Approved - Includes Plant Eng Approval';
        update testSpec6;
        
        Specification__c testSpec7 = [SELECT Id, costApproval__c, costAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec7.costApproval__c = 'Accepted';
        testSpec7.costAssessmentComplete__c = True;
        update testSpec7;
        
        Specification__c testSpec8 = [SELECT Id, upperLimit1__c, moqUom__c, moq__c, price1__c, plmApproval__c, pricingAssignmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];   
        testSpec8.plmApproval__c = 'Reassign CM';
        //testSpec8.pricingAssignmentComplete__c = TRUE;
        testSpec8.pricingAssignmentComplete__c = FALSE;   // 11-16-20 jd
        testSpec8.price1__c = 10;
        testSpec8.moq__c = 1;
        testSpec8.moqUom__c = 'Each';
        testSpec8.upperLimit1__c = 100;
        update testSpec8;
        
    }
    
    static testMethod void validatePartsPA2CA() {
        
        Specification__c testSpec = createNewTestSpec(specRT, 'TPM');
        testSpec.submitForApproval__c = true;
        insert testSpec;
        
        string testId = testSpec.id;
        Specification__c testSpec2 = [SELECT Id, missingInformation__c, missingInformationAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.missingInformation__c = 'No';
        testSpec2.missingInformationAssessmentComplete__c = True;
        update testSpec2;
        
        Specification__c testSpec3 = [SELECT Id, capable__c, capabilityAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec3.capable__c = 'Yes';
        testSpec3.capabilityAssessmentComplete__c = True;
        update testSpec3;
        
        Specification__c testSpec4 = [SELECT Id, standard__c, standardAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];     
        testSpec4.standard__c = 'Yes';
        testSpec4.standardAssessmentComplete__c = True;
        update testSpec4;
        
        Specification__c testSpec5 = [SELECT Id, manufacturingAssignmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];               
        testSpec5.location__c = 'Biel';
        testSpec5.manufacturingAssignmentComplete__c = True;
        update testSpec5;
        
        Specification__c testSpec6 = [SELECT Id, qualityEngineerApproval__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec6.qualityEngineerApproval__c = 'Approved - Includes Plant Eng Approval';
        update testSpec6;
        
        Specification__c testSpec7 = [SELECT Id, costApproval__c, costAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec7.costApproval__c = 'Accepted';
        testSpec7.costAssessmentComplete__c = True;
        update testSpec7;
        
        Specification__c testSpec8 = [SELECT Id, upperLimit1__c, moqUom__c, moq__c, price1__c, plmApproval__c, pricingAssignmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];   
        testSpec8.plmApproval__c = 'Reevaluate Cost';
        testSpec8.pricingAssignmentComplete__c = TRUE;
        testSpec8.price1__c = 10;
        testSpec8.moq__c = 1;
        testSpec8.moqUom__c = 'Each';
        testSpec8.upperLimit1__c = 100;
        update testSpec8;
        
    }
    
    
    static testMethod void validatePartsApproved() {
        
        Specification__c testSpec = createNewTestSpec(specRT, 'TPM');
        testSpec.submitForApproval__c = true;
        insert testSpec;
        
        string testId = testSpec.id;
        Specification__c testSpec2 = [SELECT Id, missingInformation__c, missingInformationAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.missingInformation__c = 'No';
        testSpec2.missingInformationAssessmentComplete__c = True;
        update testSpec2;
        
        Specification__c testSpec3 = [SELECT Id, capable__c, capabilityAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec3.capable__c = 'Yes';
        testSpec3.capabilityAssessmentComplete__c = True;
        update testSpec3;
        Test.startTest();
        Specification__c testSpec4 = [SELECT Id, standard__c, standardAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];     
        testSpec4.standard__c = 'Yes';
        testSpec4.standardAssessmentComplete__c = True;
        update testSpec4;
        
        Specification__c testSpec5 = [SELECT Id, manufacturingAssignmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];               
        testSpec5.location__c = 'Biel';
        testSpec5.manufacturingAssignmentComplete__c = True;
        update testSpec5;
        
        Specification__c testSpec6 = [SELECT Id, qualityEngineerApproval__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec6.qualityEngineerApproval__c = 'Approved - Includes Plant Eng Approval';
        update testSpec6;
        
        Specification__c testSpec7 = [SELECT Id, costApproval__c, costAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec7.costApproval__c = 'Accepted';
        testSpec7.costAssessmentComplete__c = True;
        update testSpec7;
        
        Specification__c testSpec8 = [SELECT Id, upperLimit1__c, moqUom__c, moq__c, price1__c, plmApproval__c, pricingAssignmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];   
        testSpec8.plmApproval__c = 'Approved';
        testSpec8.pricingAssignmentComplete__c = TRUE;
        testSpec8.price1__c = 10;
        testSpec8.moq__c = 1;
        testSpec8.moqUom__c = 'Each';
        testSpec8.upperLimit1__c = 100;
        update testSpec8;
        
        Specification__c testSpec9 = [SELECT Id, massProduction__c, plmAcknowledgement__c, dsMassProduction__c, dsPlmAcknowledgement__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec9.massProduction__c = True;
        testSpec9.dsMassProduction__c = True;       
        update testSpec9;
        
        testSpec9.plmAcknowledgement__c = True;  
        testSpec9.dsPlmAcknowledgement__c = True;                 
        update testSpec9;
        Test.stopTest();
    }
    
    static testMethod void validatePartsDualSourceManufacturerAssignment() {
        
        Specification__c testSpec = createNewTestSpec(specRT, 'TPM');
        testSpec.dsSource__c = 'Dual Source Accepted';
        testSpec.submitForApproval__c = true;
        insert testSpec;
        
        string testId = testSpec.id;
        
        Specification__c testSpec2 = [SELECT Id, missingInformation__c, missingInformationAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.missingInformation__c = 'No';
        testSpec2.missingInformationAssessmentComplete__c = True;
        update testSpec2;
        
        Specification__c testSpec3 = [SELECT Id, capable__c, capabilityAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec3.capable__c = 'Yes';
        testSpec3.capabilityAssessmentComplete__c = True;
        update testSpec3;
        
        Specification__c testSpec4 = [SELECT Id, standard__c, standardAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];     
        testSpec4.standard__c = 'Yes';
        testSpec4.standardAssessmentComplete__c = True;
        update testSpec4;
        
        Specification__c testSpec5 = [SELECT Id, dsSourceChangedReason__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];   
        testSpec5.dsSourceChangedReason__c = 'CM Specialty';                       
        update testSpec5;   
        
    }
    
    static testMethod void validatePartsDualSourceRisk() {
        
        Specification__c testSpec = createNewTestSpec(specRT, 'TPM');
        testSpec.dsSource__c = 'Dual Source Accepted';
        testSpec.submitForApproval__c = true;
        insert testSpec;
        
        string testId = testSpec.id;
        Specification__c testSpec2 = [SELECT Id, missingInformation__c, missingInformationAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.missingInformation__c = 'No';
        testSpec2.missingInformationAssessmentComplete__c = True;
        update testSpec2;
        
        Specification__c testSpec3 = [SELECT Id, capable__c, capabilityAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec3.capable__c = 'Yes';
        testSpec3.capabilityAssessmentComplete__c = True;
        update testSpec3;
        
        Specification__c testSpec4 = [SELECT Id, standard__c, standardAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];     
        testSpec4.standard__c = 'Yes';
        testSpec4.standardAssessmentComplete__c = True;
        update testSpec4;
        
        Specification__c testSpec5 = [SELECT Id, manufacturingAssignmentComplete__c, dsActualSource__c, dsLocation__c, dsManufacturingAssignmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];               
        testSpec5.location__c = 'Biel';
        testSpec5.manufacturingAssignmentComplete__c = True;
        testSpec5.dsActualSource__c = 'Dual Source';
        testSpec5.dsLocation__c = 'Biel';
        testSpec5.dsManufacturingAssignmentComplete__c = True;
        update testSpec5;
        
        Specification__c testSpec6 = [SELECT Id, dsQualityEngineerApproval__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec6.dsQualityEngineerApproval__c = 'Approved - Requires Plant Eng Approval';
        update testSpec6;
        
        testSpec6.dsQualityEngineerApproval__c = 'Reviewed - More Information Required';
        update testSpec6;
        
        testSpec6.dsQualityEngineerApproval__c = 'Customer Responded - QA to Confirm'; 
        update testSpec6;
        
        testSpec6.dsQualityEngineerApproval__c = 'Reassign CM';
        update testSpec6;
        
    }
    
    static testMethod void validatePartsDualSourceCA2MA() {
        
        Specification__c testSpec = createNewTestSpec(specRT, 'TPM');
        testSpec.dsSource__c = 'Dual Source Accepted';
        testSpec.submitForApproval__c = true;
        insert testSpec;
        
        string testId = testSpec.id;
        Specification__c testSpec2 = [SELECT Id, missingInformation__c, missingInformationAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.missingInformation__c = 'No';
        testSpec2.missingInformationAssessmentComplete__c = True;
        update testSpec2;
        
        Specification__c testSpec3 = [SELECT Id, capable__c, capabilityAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec3.capable__c = 'Yes';
        testSpec3.capabilityAssessmentComplete__c = True;
        update testSpec3;
        
        Specification__c testSpec4 = [SELECT Id, standard__c, standardAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];     
        testSpec4.standard__c = 'Yes';
        testSpec4.standardAssessmentComplete__c = True;
        update testSpec4;
        
        Specification__c testSpec5 = [SELECT Id, manufacturingAssignmentComplete__c, dsActualSource__c, dsLocation__c, dsManufacturingAssignmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];               
        testSpec5.location__c = 'Biel';
        testSpec5.manufacturingAssignmentComplete__c = True;
        testSpec5.dsActualSource__c = 'Dual Source';
        testSpec5.dsLocation__c = 'Biel';
        testSpec5.dsManufacturingAssignmentComplete__c = True;
        update testSpec5;
        
        Specification__c testSpec6 = [SELECT Id, dsQualityEngineerApproval__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec6.dsQualityEngineerApproval__c = 'Approved - Includes Plant Eng Approval';
        update testSpec6;
        
        Specification__c testSpec7 = [SELECT Id, dsCostApproval__c, dsCostAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec7.dsCostApproval__c = 'Reassign CM';
        testSpec7.dsCostAssessmentComplete__c = True;
        update testSpec7;
        
    }
    
    static testMethod void validatePartsDualSourceCA2CC() {
        
        Specification__c testSpec = createNewTestSpec(specRT, 'TPM');
        testSpec.dsSource__c = 'Dual Source Accepted';
        testSpec.submitForApproval__c = true;
        insert testSpec;
        
        string testId = testSpec.id;
        Specification__c testSpec2 = [SELECT Id, missingInformation__c, missingInformationAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.missingInformation__c = 'No';
        testSpec2.missingInformationAssessmentComplete__c = True;
        update testSpec2;
        
        Specification__c testSpec3 = [SELECT Id, capable__c, capabilityAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec3.capable__c = 'Yes';
        testSpec3.capabilityAssessmentComplete__c = True;
        update testSpec3;
        
        Specification__c testSpec4 = [SELECT Id, standard__c, standardAssessmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];     
        testSpec4.standard__c = 'Yes';
        testSpec4.standardAssessmentComplete__c = True;
        update testSpec4;
        
        Specification__c testSpec5 = [SELECT Id, manufacturingAssignmentComplete__c, dsActualSource__c, dsLocation__c, dsManufacturingAssignmentComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];               
        testSpec5.location__c = 'Biel';
        testSpec5.manufacturingAssignmentComplete__c = True;
        testSpec5.dsActualSource__c = 'Dual Source';
        testSpec5.dsLocation__c = 'Biel';
        testSpec5.dsManufacturingAssignmentComplete__c = True;
        update testSpec5;
        
        Specification__c testSpec6 = [SELECT Id, dsQualityEngineerApproval__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec6.dsQualityEngineerApproval__c = 'Approved - Includes Plant Eng Approval';
        update testSpec6;
        
        Specification__c testSpec7 = [SELECT Id, dsCostApproval__c, dsCostAssessmentComplete__c, incrementalTCOS2__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec7.incrementalTCOS2__c = 10;
        testSpec7.dsCostApproval__c = 'Accepted';
        testSpec7.dsCostAssessmentComplete__c = True;
        update testSpec7;
        
    }
    
    // Raw Path 1
    static testMethod void validateRawInventoryP1() {
        
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');
        testSpec.glassComposition__c = '2320 (GG3)'; // 2320 is Path 1  // 11-16-20 jd (change to '2320 (GG3)'')
        testSpec.submitForApproval__c = true;       
        insert testSpec;
        
        string testId = testSpec.id;
        
        Specification__c testSpec2 = [SELECT Id, supplyAllocationInventory__c, supplyAllocInventoryReviewComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.supplyAllocationInventory__c = 'Approved - Inventory';
        testSpec2.supplyAllocInventoryReviewComplete__c = True;
        update testSpec2;
        
    }
    
    // Raw Path 1
    static testMethod void validateRawDeclineP1() {
        
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');
        testSpec.glassComposition__c = '2320 (GG3)'; // 2320 is Path 1 // 11-16-20 jd (change to '2320 (GG3)'')
        testSpec.submitForApproval__c = true;       
        insert testSpec;
        
        string testId = testSpec.id;
        
        testSpec.status__c = 'Declined';
        update testSpec;
        
    }
    
    // Raw Path 2
    static testMethod void validateRawInventoryP2() {
        
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');
        testSpec.glassComposition__c = '9318'; // 9318 is Path 2
        testSpec.submitForApproval__c = true;       
        insert testSpec;
        
        string testId = testSpec.id;
        
        Specification__c testSpec2 = [SELECT Id, supplyAllocationInventory__c, supplyAllocInventoryReviewComplete__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.supplyAllocationInventory__c = 'Approved - Inventory';
        testSpec2.supplyAllocInventoryReviewComplete__c = True;
        update testSpec2;
        
    }
    
    // Raw Path 2
    static testMethod void validateRawDeclineP2() {
        
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');
        testSpec.glassComposition__c = '9318'; // 9318 is Path 2
        testSpec.submitForApproval__c = true;       
        insert testSpec;
        
        string testId = testSpec.id;
        
        testSpec.status__c = 'Declined';
        update testSpec;
        
    }
    
    @isTest
    public static void unitTestForSpecificationReminder(){
        Specification__c testSpec = createNewTestSpec(specRT, 'TPM');  
        testSpec.reminderCompleted__c = false;
        testSpec.statusChangeDate__c =Date.Today().addDays(-4);
        testSpec.status__c = 'Missing Information Assessment';
        //insert testSpec;
        //List<Specification__c> specs = new List<Specification__c>{testSpec};
        //testSpec.productLine__c = 'parts';
        //testSpec.submitForApproval__c = true;
        Test.startTest();
        insert testSpec;
        string testId = testSpec.id;
        list <Specification__c> specList = [SELECT Id, dsStatusChangeDate__c,statusChangeDate__c, productLine__c,reminderCompleted__c,status__c 
                                           , Innovation_Type__c, location__c FROM Specification__c 
                                            WHERE id =: testId limit 1];
        for(Specification__c spec :specList){
            system.debug('statusChangeDate__ccheck'+ spec.statusChangeDate__c);
            system.debug('reminderCompleted__ccheck' + spec.reminderCompleted__c);
            system.debug('productLine__ccheck'+ spec.productLine__c);
            system.debug('status__ccheck'+ spec.status__c);
        }
        
        
        ChatterHelper.specificationReminder(specList);
        Test.stopTest();
        
    }
    
    @isTest
    public static void unitTestForSpecificationReminderone(){
        Specification__c testSpec = createNewTestSpec(specRT, 'TPM');  
        testSpec.reminderCompleted__c = false;
        testSpec.statusChangeDate__c =Date.Today().addDays(-4);
        testSpec.status__c = 'Manufacturer Assignment';
        //productLine__c = 'parts';
        //testSpec.submitForApproval__c = true;
        insert testSpec;
        string testId = testSpec.id;
        list <Specification__c> specList = [SELECT Id, dsStatusChangeDate__c,statusChangeDate__c, productLine__c,reminderCompleted__c,status__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        for(Specification__c spec :specList){
            system.debug('statusChangeDate__ccheck'+ spec.statusChangeDate__c);
            system.debug('reminderCompleted__ccheck' + spec.reminderCompleted__c);
            system.debug('productLine__ccheck'+ spec.productLine__c);
            system.debug('status__ccheck'+ spec.status__c);
        }
        
        Test.startTest();
        ChatterHelper.specificationReminder(speclist);
        Test.stopTest();
        
    }
    @isTest
    public static void unitTestForSpecificationRemindertwo(){
        Specification__c testSpec = createNewTestSpec(specRT, 'TPM');  
        testSpec.reminderCompleted__c = false;
        testSpec.statusChangeDate__c =Date.Today().addDays(-4);
        testSpec.status__c = 'Risk Assessment';
        //productLine__c = 'parts';
        //testSpec.submitForApproval__c = true;
        insert testSpec;
        string testId = testSpec.id;
        list <Specification__c> specList = [SELECT Id, dsStatusChangeDate__c,statusChangeDate__c, productLine__c,reminderCompleted__c,status__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        for(Specification__c spec :specList){
            system.debug('statusChangeDate__ccheck'+ spec.statusChangeDate__c);
            system.debug('reminderCompleted__ccheck' + spec.reminderCompleted__c);
            system.debug('productLine__ccheck'+ spec.productLine__c);
            system.debug('status__ccheck'+ spec.status__c);
        }
        
        Test.startTest();
        ChatterHelper.specificationReminder(speclist);
        Test.stopTest();
        
    }
    @isTest
    public static void unitTestForSpecificationReminderthree(){
        Specification__c testSpec = createNewTestSpec(specRT4, 'TPM');  
        testSpec.reminderCompleted__c = false;
        testSpec.statusChangeDate__c =Date.Today().addDays(-4);
        testSpec.status__c = 'CM Cost Assessment';
        //productLine__c = 'parts';
        testSpec.submitForApproval__c = true;
        insert testSpec;
        string testId = testSpec.id;
        list <Specification__c> specList = [SELECT Id, dsStatusChangeDate__c,statusChangeDate__c, productLine__c,reminderCompleted__c,status__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        for(Specification__c spec :specList){
            system.debug('statusChangeDate__ccheck'+ spec.statusChangeDate__c);
            system.debug('reminderCompleted__ccheck' + spec.reminderCompleted__c);
            system.debug('productLine__ccheck'+ spec.productLine__c);
            system.debug('status__ccheck'+ spec.status__c);
        }
        
        Test.startTest();
        ChatterHelper.specificationReminder(speclist);
        Test.stopTest();
        
    }
    
    @isTest
    public static void unitTestForSpecificationReminderfour(){
        Id specRT2 = tUtils.getRecordTypeId('Specification__c', 'Raw Glass');
        Specification__c testSpec = createNewTestSpec(specRT, 'TPM');  
        testSpec.reminderCompleted__c = false;
        testSpec.statusChangeDate__c =Date.Today().addDays(-4);
        testSpec.status__c = 'Manufacturer Assignment'; 
        testSpec.dsstatus__c = 'Manufacturer Assignment';
        testSpec.dsStatusChangeDate__c = Date.Today().addDays(-4);
        testSpec.dsReminderCompleted__c = false;
        //productLine__c = 'parts';
        //testSpec.submitForApproval__c = true;
        insert testSpec;
        string testId = testSpec.id;
        list <Specification__c> specList = [SELECT Id, dsStatusChangeDate__c,statusChangeDate__c,dsstatus__c, productLine__c,reminderCompleted__c,status__c,dsReminderCompleted__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        for(Specification__c spec :specList){
            system.debug('dsStatusChangeDate__c'+ spec.dsStatusChangeDate__c);
            system.debug('dsReminderCompleted__c' + spec.dsReminderCompleted__c+spec.dsStatusChangeDate__c.daysBetween(Date.Today()));
            system.debug('productLine__ccheck'+ spec.productLine__c);
            system.debug('status__ccheck'+ spec.status__c);
        }
        Test.startTest();
        ChatterHelper.specificationReminder(speclist);
        Test.stopTest();
    }
    
    @isTest
    public static void unitTestForSpecificationReminder5(){
        Specification__c testSpec = createNewTestSpec(specRT, 'TPM');  
        testSpec.reminderCompleted__c = false;
        testSpec.statusChangeDate__c =Date.Today().addDays(-4);
        testSpec.status__c = 'Pricing Assignment';
        testSpec.dsStatusChangeDate__c = Date.Today().addDays(-4);
        testSpec.dsReminderCompleted__c = false;
        //productLine__c = 'parts';
        //testSpec.submitForApproval__c = true;
        insert testSpec;
        string testId = testSpec.id;
        list <Specification__c> specList = [SELECT Id, dsStatusChangeDate__c,statusChangeDate__c,dsstatus__c, productLine__c,reminderCompleted__c,status__c,dsReminderCompleted__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        for(Specification__c spec :specList){
            system.debug('dsStatusChangeDate__c'+ spec.dsStatusChangeDate__c);
            system.debug('dsReminderCompleted__c' + spec.dsReminderCompleted__c+spec.dsStatusChangeDate__c.daysBetween(Date.Today()));
            system.debug('productLine__ccheck'+ spec.productLine__c);
            system.debug('status__ccheck'+ spec.status__c);
        }
        Test.startTest();
        ChatterHelper.specificationReminder(speclist);
        Test.stopTest();
    }
        
    @isTest
    public static void unitTestForRawSpecification(){
        Id specRT2 = tUtils.getRecordTypeId('Specification__c', 'Raw Glass');
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');  
        testSpec.reminderCompleted__c = false;
        testSpec.statusChangeDate__c =Date.Today().addDays(-4);
        testSpec.status__c = 'Product Engineering Input';
        testSpec.dsStatusChangeDate__c = Date.Today().addDays(-4);
        testSpec.reminderCompleted__c = false;
        testSpec.glassComposition__c  = '1805';
        //productLine__c = 'parts';
        //testSpec.submitForApproval__c = true;
        insert testSpec;
        string testId = testSpec.id;
        list <Specification__c> specList = [SELECT Id, dsStatusChangeDate__c,statusChangeDate__c,mtoNotificationPath__c,dsstatus__c, productLine__c,reminderCompleted__c,status__c,dsReminderCompleted__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        for(Specification__c spec :specList){
            system.debug('dsStatusChangeDate__c'+ spec.dsStatusChangeDate__c);
            system.debug('dsReminderCompleted__c' + spec.dsReminderCompleted__c+spec.dsStatusChangeDate__c.daysBetween(Date.Today()));
            system.debug('productLine__ccheck'+ spec.productLine__c);
            system.debug('status__ccheck'+ spec.status__c);
        }
        Test.startTest();
        ChatterHelper.specificationReminder(speclist);
        Test.stopTest();
    }
    
    @isTest
    public static void unitTestForRawSpecification2(){
        Id specRT2 = tUtils.getRecordTypeId('Specification__c', 'Raw Glass');
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');  
        testSpec.reminderCompleted__c = false;
        testSpec.statusChangeDate__c =Date.Today().addDays(-4);
        testSpec.status__c = 'Supply, Allocation, and Inventory Review';
        testSpec.dsStatusChangeDate__c = Date.Today().addDays(-4);
        testSpec.reminderCompleted__c = false;
        testSpec.glassComposition__c  = '1805';
        //productLine__c = 'parts';
        //testSpec.submitForApproval__c = true;
        insert testSpec;
        string testId = testSpec.id;
        list <Specification__c> specList = [SELECT Id, dsStatusChangeDate__c,statusChangeDate__c,mtoNotificationPath__c,dsstatus__c, productLine__c,reminderCompleted__c,status__c,dsReminderCompleted__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        for(Specification__c spec :specList){
            system.debug('dsStatusChangeDate__c'+ spec.dsStatusChangeDate__c);
            system.debug('dsReminderCompleted__c' + spec.dsReminderCompleted__c+spec.dsStatusChangeDate__c.daysBetween(Date.Today()));
            system.debug('productLine__ccheck'+ spec.productLine__c);
            system.debug('status__ccheck'+ spec.status__c);
        }
        Test.startTest();
        ChatterHelper.specificationReminder(speclist);

        Test.stopTest();
    }
    
    @isTest
    public static void unitTestForRawSpecificatioProduct(){
        Id specRT2 = tUtils.getRecordTypeId('Specification__c', 'Raw Glass');
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');  
        testSpec.reminderCompleted__c = false;
        testSpec.statusChangeDate__c =Date.Today().addDays(-4);
        testSpec.status__c = 'Pricing Assignment';
        testSpec.dsStatusChangeDate__c = Date.Today().addDays(-4);
        testSpec.reminderCompleted__c = false;
        testSpec.glassComposition__c  = '1805';
        //productLine__c = 'parts';
        //testSpec.submitForApproval__c = true;
        insert testSpec;
        string testId = testSpec.id;
        list <Specification__c> specList = [SELECT Id, dsStatusChangeDate__c,statusChangeDate__c,mtoNotificationPath__c,dsstatus__c, productLine__c,reminderCompleted__c,status__c,dsReminderCompleted__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        for(Specification__c spec :specList){
            system.debug('dsStatusChangeDate__c'+ spec.dsStatusChangeDate__c);
            system.debug('dsReminderCompleted__c' + spec.dsReminderCompleted__c+spec.dsStatusChangeDate__c.daysBetween(Date.Today()));
            system.debug('productLine__ccheck'+ spec.productLine__c);
            system.debug('status__ccheck'+ spec.status__c);
        }
        Test.startTest();
        ChatterHelper.specificationReminder(speclist);
        testSpec.status__c = 'Pricing Approved';
        update testSpec;
        Test.stopTest();
    }
    
    @isTest
    public static void unitTestForRawSpecification3(){
        Id specRT2 = tUtils.getRecordTypeId('Specification__c', 'Raw Glass');
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');  
        testSpec.reminderCompleted__c = false;
        testSpec.statusChangeDate__c =Date.Today().addDays(-4);
        testSpec.status__c = 'Product Engineering Input';
        testSpec.dsStatusChangeDate__c = Date.Today().addDays(-4);
        testSpec.reminderCompleted__c = false;
        testSpec.glassComposition__c  = '1805';
        //productLine__c = 'parts';
        //testSpec.submitForApproval__c = true;
        insert testSpec;
        string testId = testSpec.id;
        list <Specification__c> specList = [SELECT Id, dsStatusChangeDate__c,statusChangeDate__c,mtoNotificationPath__c,dsstatus__c, productLine__c,reminderCompleted__c,status__c,dsReminderCompleted__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        for(Specification__c spec :specList){
            system.debug('dsStatusChangeDate__c'+ spec.dsStatusChangeDate__c);
            system.debug('dsReminderCompleted__c' + spec.dsReminderCompleted__c+spec.dsStatusChangeDate__c.daysBetween(Date.Today()));
            system.debug('productLine__ccheck'+ spec.productLine__c);
            system.debug('status__ccheck'+ spec.status__c);
        }
        Test.startTest();
        ChatterHelper.specificationReminder(speclist);
        Test.stopTest();
    }
    
    @isTest
    public static void unitTestForRawSpecification4(){
        Id specRT2 = tUtils.getRecordTypeId('Specification__c', 'Raw Glass');
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');  
        testSpec.reminderCompleted__c = false;
        testSpec.statusChangeDate__c =Date.Today().addDays(-4);
        testSpec.status__c = 'Plant Engineering Input';
        testSpec.dsStatusChangeDate__c = Date.Today().addDays(-4);
        testSpec.reminderCompleted__c = false;
        testSpec.glassComposition__c  = '1805';
        //productLine__c = 'parts';
        //testSpec.submitForApproval__c = true;
        insert testSpec;
        string testId = testSpec.id;
        list <Specification__c> specList = [SELECT Id, dsStatusChangeDate__c,statusChangeDate__c,mtoNotificationPath__c,dsstatus__c, productLine__c,reminderCompleted__c,status__c,dsReminderCompleted__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        for(Specification__c spec :specList){
            system.debug('dsStatusChangeDate__c'+ spec.dsStatusChangeDate__c);
            system.debug('dsReminderCompleted__c' + spec.dsReminderCompleted__c+spec.dsStatusChangeDate__c.daysBetween(Date.Today()));
            system.debug('productLine__ccheck'+ spec.productLine__c);
            system.debug('status__ccheck'+ spec.status__c);
        }
        Test.startTest();
        ChatterHelper.specificationReminder(speclist);
        Test.stopTest();
    }
    
    @isTest
    public static void unitTestForRawSpecification5(){
        Id specRT2 = tUtils.getRecordTypeId('Specification__c', 'Raw Glass');
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');  
        testSpec.reminderCompleted__c = false;
        testSpec.statusChangeDate__c =Date.Today().addDays(-4);
        testSpec.status__c = 'Supply Chain Input';
        testSpec.dsStatusChangeDate__c = Date.Today().addDays(-4);
        testSpec.reminderCompleted__c = false;
        testSpec.glassComposition__c  = '1805';
        //productLine__c = 'parts';
        //testSpec.submitForApproval__c = true;
        insert testSpec;
        string testId = testSpec.id;
        list <Specification__c> specList = [SELECT Id, dsStatusChangeDate__c,statusChangeDate__c,mtoNotificationPath__c,dsstatus__c, productLine__c,reminderCompleted__c,status__c,dsReminderCompleted__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        for(Specification__c spec :specList){
            system.debug('dsStatusChangeDate__c'+ spec.dsStatusChangeDate__c);
            system.debug('dsReminderCompleted__c' + spec.dsReminderCompleted__c+spec.dsStatusChangeDate__c.daysBetween(Date.Today()));
            system.debug('productLine__ccheck'+ spec.productLine__c);
            system.debug('status__ccheck'+ spec.status__c);
        }
        Test.startTest();
        ChatterHelper.specificationReminder(speclist);
        Test.stopTest();
    }
    
    @isTest
    public static void unitTestForRawPricingAssigment(){
        Id specRT2 = tUtils.getRecordTypeId('Specification__c', 'Raw Glass');
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');  
        testSpec.reminderCompleted__c = false;
        testSpec.statusChangeDate__c =Date.Today().addDays(-4);
        testSpec.status__c = 'Pricing Assignment';
        testSpec.dsStatusChangeDate__c = Date.Today().addDays(-4);
        testSpec.reminderCompleted__c = false;
        testSpec.glassComposition__c  = '1805';
        //productLine__c = 'parts';
        //testSpec.submitForApproval__c = true;
        insert testSpec;
        string testId = testSpec.id;
        list <Specification__c> specList = [SELECT Id, dsStatusChangeDate__c,statusChangeDate__c,mtoNotificationPath__c,dsstatus__c, productLine__c,reminderCompleted__c,status__c,dsReminderCompleted__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        for(Specification__c spec :specList){
            system.debug('dsStatusChangeDate__c'+ spec.dsStatusChangeDate__c);
            system.debug('dsReminderCompleted__c' + spec.dsReminderCompleted__c+spec.dsStatusChangeDate__c.daysBetween(Date.Today()));
            system.debug('productLine__ccheck'+ spec.productLine__c);
            system.debug('status__ccheck'+ spec.status__c);
        }
        Test.startTest();
        ChatterHelper.specificationReminder(speclist);
        Test.stopTest();
    }
    
    @isTest
    public static void unitTestForRawPricingAssigment2(){
        Id specRT2 = tUtils.getRecordTypeId('Specification__c', 'Raw Glass');
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');  
        testSpec.reminderCompleted__c = false;
        testSpec.statusChangeDate__c =Date.Today().addDays(-4);
        testSpec.status__c = 'Business Case Finalization';
        testSpec.dsStatusChangeDate__c = Date.Today().addDays(-4);
        testSpec.reminderCompleted__c = false;
        testSpec.glassComposition__c  = '1805';
        //productLine__c = 'parts';
        //testSpec.submitForApproval__c = true;
        insert testSpec;
        string testId = testSpec.id;
        list <Specification__c> specList = [SELECT Id, dsStatusChangeDate__c,statusChangeDate__c,mtoNotificationPath__c,dsstatus__c, productLine__c,reminderCompleted__c,status__c,dsReminderCompleted__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        for(Specification__c spec :specList){
            system.debug('dsStatusChangeDate__c'+ spec.dsStatusChangeDate__c);
            system.debug('dsReminderCompleted__c' + spec.dsReminderCompleted__c+spec.dsStatusChangeDate__c.daysBetween(Date.Today()));
            system.debug('productLine__ccheck'+ spec.productLine__c);
            system.debug('status__ccheck'+ spec.status__c);
        }
        Test.startTest();
        ChatterHelper.specificationReminder(speclist);
        Test.stopTest();
    }
    
    @isTest
    public static void unitTestForRawPricingAssigment4(){
        Id specRT2 = tUtils.getRecordTypeId('Specification__c', 'Raw Glass');
        Specification__c testSpec = createNewTestSpec(specRT2, 'TPM');  
        testSpec.reminderCompleted__c = false;
        testSpec.statusChangeDate__c =Date.Today().addDays(-4);
        testSpec.status__c = 'Commercial/Ops Review';
        testSpec.dsStatusChangeDate__c = Date.Today().addDays(-4);
        testSpec.reminderCompleted__c = false;
        testSpec.glassComposition__c  = '1805';
        //productLine__c = 'parts';
        //testSpec.submitForApproval__c = true;
        insert testSpec;
        string testId = testSpec.id;
        list <Specification__c> specList = [SELECT Id, dsStatusChangeDate__c,statusChangeDate__c,mtoNotificationPath__c,dsstatus__c, productLine__c,reminderCompleted__c,status__c,dsReminderCompleted__c, Innovation_Type__c, location__c FROM Specification__c WHERE id =: testId limit 1];
        for(Specification__c spec :specList){
            system.debug('dsStatusChangeDate__c'+ spec.dsStatusChangeDate__c);
            system.debug('dsReminderCompleted__c' + spec.dsReminderCompleted__c+spec.dsStatusChangeDate__c.daysBetween(Date.Today()));
            system.debug('productLine__ccheck'+ spec.productLine__c);
            system.debug('status__ccheck'+ spec.status__c);
        }
        Test.startTest();
        ChatterHelper.specificationReminder(speclist);
        Test.stopTest();
    }
}