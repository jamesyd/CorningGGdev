@isTest
private class SpecificationReminderBatchTest {
    static TestUtilities tUtils = new TestUtilities();
    private static string acctRT;
    private static string oppRT;
    private static string specRT;
    private static string specRT2;
    private static string specRT3;
    private static string profileId;
    
    static {
        acctRT = tUtils.getRecordTypeId('Account', 'GG Account');
        oppRT = tUtils.getRecordTypeId('Opportunity', 'GG Program');
        specRT = tUtils.getRecordTypeId('Specification__c', 'Parts');
        specRT2 = tUtils.getRecordTypeId('Specification__c', 'Raw Glass');
        specRT3 = tUtils.getRecordTypeId('Specification__c', 'Concore');
        profileId = tUtils.getProfileId('GG Account Manager');
    }
       
static testMethod void testSpecificationReminderBatch() {

        // add custom settings
        List<GGPartsSpecAutoNotifications__c> csParts = new List<GGPartsSpecAutoNotifications__c>();
        csParts.add(new GGPartsSpecAutoNotifications__c(Name = 'N~MIA', message__c = '*', userIdList__c = '{005o0000001BKMPAA4}'));
        csParts.add(new GGPartsSpecAutoNotifications__c(Name = 'SA~MA', message__c = '*', userIdList__c = '{005o0000001BKMPAA4}'));        
        csParts.add(new GGPartsSpecAutoNotifications__c(Name = 'MA~RA~Biel', message__c = '*', userIdList__c = '{005o0000001BKMPAA4}'));        
        csParts.add(new GGPartsSpecAutoNotifications__c(Name = 'RA~CA', message__c = '*', userIdList__c = '{005o0000001BKMPAA4}'));        
        csParts.add(new GGPartsSpecAutoNotifications__c(Name = 'CA~PA', message__c = '*', userIdList__c = '{005o0000001BKMPAA4}'));        
        insert csParts;
        
        List<GGMTOSpecAutoNotifications__c> csRaw = new List<GGMTOSpecAutoNotifications__c>();
        csRaw.add(new GGMTOSpecAutoNotifications__c(Name = 'P1~N~SAIR', message__c = '*', userIdList__c = '{005o0000001BKMPAA4}'));
        csRaw.add(new GGMTOSpecAutoNotifications__c(Name = 'P1~SIAR~PREI', message__c = '*', userIdList__c = '{005o0000001BKMPAA4}'));        
        csRaw.add(new GGMTOSpecAutoNotifications__c(Name = 'P1~PREI~PLEI', message__c = '*', userIdList__c = '{005o0000001BKMPAA4}'));        
        csRaw.add(new GGMTOSpecAutoNotifications__c(Name = 'P1~PLEI~SCI', message__c = '*', userIdList__c = '{005o0000001BKMPAA4}')); 
        csRaw.add(new GGMTOSpecAutoNotifications__c(Name = 'P1~SCI~PA', message__c = '*', userIdList__c = '{005o0000001BKMPAA4}')); 
        csRaw.add(new GGMTOSpecAutoNotifications__c(Name = 'P1~PA~BCF', message__c = '*', userIdList__c = '{005o0000001BKMPAA4}')); 
        csRaw.add(new GGMTOSpecAutoNotifications__c(Name = 'P1~BCF~COR', message__c = '*', userIdList__c = '{005o0000001BKMPAA4}'));              
        insert csRaw;
       
        Account a = tUtils.addTestAccount(acctRT);
        a.accountType__c = 'TPM';
        update a;
        
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        
        Specification__c testSpec = tUtils.createTestSpec(a.id, o.id, specRT);
        testSpec.tpm__c = a.id;
        testSpec.submitForApproval__c = true;
        testSpec.Status__c = 'New';
        testSpec.cncNeeded__c = 'No'; 
        testSpec.arEtcPvd__c = 'No';
        testSpec.screenPrint__c = 'No';
        insert testSpec;
        
        string testId = testSpec.id;
        Specification__c testSpec2 = [SELECT Id, missingInformation__c, missingInformationAssessmentComplete__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec2.missingInformation__c = 'No';
        testSpec2.missingInformationAssessmentComplete__c = True;
        update testSpec2;
        testSpec2.statusChangeDate__c = Date.newInstance(1988, 2, 17);
        update testSpec2;

        Specification__c testSpec3 = [SELECT Id, capable__c, capabilityAssessmentComplete__c FROM Specification__c WHERE id =: testId limit 1];
        testSpec3.capable__c = 'Yes';
        testSpec3.capabilityAssessmentComplete__c = True;
        update testSpec3;
        testSpec3.statusChangeDate__c = Date.newInstance(1988, 2, 17);
        update testSpec3;

        Specification__c testSpec4 = [SELECT Id, standard__c, standardAssessmentComplete__c FROM Specification__c WHERE id =: testId limit 1];     
        testSpec4.standard__c = 'Yes';
        testSpec4.standardAssessmentComplete__c = True;
        update testSpec4;
        testSpec4.statusChangeDate__c = Date.newInstance(1988, 2, 17);
        update testSpec4;
 
        Specification__c testSpec5 = [SELECT Id, location__c, manufacturingAssignmentComplete__c FROM Specification__c WHERE id =: testId limit 1];               
        testSpec5.location__c = 'Biel';
        testSpec5.manufacturingAssignmentComplete__c = True;
        update testSpec5;
        testSpec5.statusChangeDate__c = Date.newInstance(1988, 2, 17);
        update testSpec5;
 
        Specification__c testSpec6 = [SELECT Id, qualityEngineerApproval__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec6.qualityEngineerApproval__c = 'Approved - Includes Plant Eng Approval';
        update testSpec6;
        testSpec6.statusChangeDate__c = Date.newInstance(1988, 2, 17);
        update testSpec6;
 
        Specification__c testSpec7 = [SELECT Id, costApproval__c, costAssessmentComplete__c FROM Specification__c WHERE id =: testId limit 1];       
        testSpec7.costApproval__c = 'Accepted';
        testSpec7.costAssessmentComplete__c = True;
        update testSpec7;
        testSpec7.statusChangeDate__c = Date.newInstance(1988, 2, 17);
        update testSpec7;

        // **** RAW ****

        Specification__c testSpecRaw = tUtils.createTestSpec(a.id, o.id, specRT2);
        testSpecRaw.account__c = a.id;
        testSpecRaw.submitForApproval__c = true;
        testSpecRaw.Status__c = 'New';
        testSpecRaw.Urgency_of_Case__c = 'Low'; 
        testSpecRaw.Why_Ask_for_MOQ_Exception__c = 'No';
        testSpecRaw.New_Thickness_or_Size__c = 'Both';
        testSpecRaw.requestedSampleVolume__c = 100;
        testSpecRaw.potential12MoVolume__c = 1000;
        testSpecRaw.glassComposition__c = '2320 (GG3)';// 11-16-20 jd (change to '2320 (GG3)'')
        insert testSpecRaw;
        
        string testIdRaw = testSpecRaw.id;
        Specification__c testSpec2Raw = [SELECT Id, supplyAllocationInventory__c, supplyAllocInventoryReviewComplete__c FROM Specification__c WHERE id =: testIdRaw limit 1];
        testSpec2Raw.supplyAllocationInventory__c = 'Approved';
        testSpec2Raw.supplyAllocInventoryReviewComplete__c = True;
        update testSpec2Raw;
        testSpec2Raw.statusChangeDate__c = Date.newInstance(1988, 2, 17);
        update testSpec2Raw;

        Specification__c testSpec3Raw = [SELECT Id, productEngineeringInputReceived__c FROM Specification__c WHERE id =: testIdRaw limit 1];
        testSpec3Raw.productEngineeringInputReceived__c = True;
        update testSpec3Raw;
        testSpec3Raw.statusChangeDate__c = Date.newInstance(1988, 2, 17);
        update testSpec3Raw;

        Specification__c testSpec4Raw = [SELECT Id, engineeringInputReceived__c FROM Specification__c WHERE id =: testIdRaw limit 1];     
        testSpec4Raw.engineeringInputReceived__c = True;
        update testSpec4Raw;
        testSpec4Raw.statusChangeDate__c = Date.newInstance(1988, 2, 17);
        update testSpec4Raw;
 
        Specification__c testSpec5Raw = [SELECT Id, supplyChainInputReceived__c FROM Specification__c WHERE id =: testIdRaw limit 1];               
        testSpec5Raw.supplyChainInputReceived__c = True;
        update testSpec5Raw;
        testSpec5Raw.statusChangeDate__c = Date.newInstance(1988, 2, 17);
        update testSpec5Raw;
 
        Specification__c testSpec6Raw = [SELECT Id, moq__c, moqUom__c, unitCostSqFt__c, shippingCostSqFt__c, pricingAssignmentComplete__c FROM Specification__c WHERE id =: testIdRaw limit 1];       
        testSpec6Raw.moq__c = 1;
        testSpec6Raw.moqUom__c = 'Each';
        testSpec6Raw.unitCostSqFt__c = 1;
        testSpec6Raw.shippingCostSqFt__c = 1;
        testSpec6Raw.pricingAssignmentComplete__c = True;
        update testSpec6Raw;
        testSpec6Raw.statusChangeDate__c = Date.newInstance(1988, 2, 17);
        update testSpec6Raw;
 
        Specification__c testSpec7Raw = [SELECT Id, finalBusinessCaseComplete__c FROM Specification__c WHERE id =: testIdRaw limit 1];       
        testSpec7Raw.finalBusinessCaseComplete__c = True;
        update testSpec7Raw; 
        testSpec7Raw.statusChangeDate__c = Date.newInstance(1988, 2, 17);
        update testSpec7Raw;
        
        Specification__c testSpec8Raw = [SELECT Id, mtoReview__c, operationalApproval__c, commercialApproval__c FROM Specification__c WHERE id =: testIdRaw limit 1];
        testSpec8Raw.mtoReview__c = 'Approved';
        testSpec8Raw.operationalApproval__c = True;
        testSpec8Raw.commercialApproval__c = False; // don't create the product records. just testing chatter helper
        update testSpec8Raw;
        testSpec8Raw.statusChangeDate__c = Date.newInstance(1988, 2, 17);
        update testSpec8Raw;

        Test.startTest();
            Database.executeBatch(new SpecificationReminderBatch(), 200);
        Test.stopTest();  
    
}

static testMethod void testSpecificationReminderBatchScheduler() {
    Test.startTest();
        SpecificationReminderScheduler scheduledJob = new SpecificationReminderScheduler();     
        String sch = '0 0 2 * * ?';
        String jobId = System.schedule('Test Schedule', sch, scheduledJob);
    
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id =: jobId];
        System.assertEquals('0 0 2 * * ?', ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
    Test.stopTest();
}
}