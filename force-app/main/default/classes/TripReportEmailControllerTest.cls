///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 2/24/2017 ***///
///*** Test class for Controller used for sending Trip Report Emails

@isTest
private class TripReportEmailControllerTest {
    static TestUtilities tUtils = new TestUtilities();
    private static string acctRT;
    private static string conRT;
    
    static {
        acctRT = tUtils.getRecordTypeId('Account', 'GG Account');
        conRT = tUtils.getRecordTypeId('Contact', 'GG Contact');
    }
    
    //No Distro Group
    static testMethod void sendEmailTest1() {
        tUtils.SetTriggersOnForTesting();
        
        Account a = tUtils.addTestAccount(acctRT);
        Contact c = tUtils.createTestContact(a.Id, conRT);
        c.FirstName = 'Joey';
        insert c;
        
        TripReportDistribution__c trd = tUtils.addTestTripReportDistribution (a.id, 'test@test.com', NULL);
        Trip_Visit_Report__c tvr = tUtils.addTestTVR(a.id, false);
        tvr.otherEmailRecipients__c = '1@corning.com,2@corning.com';
        update tvr;
        
        Attendees__c att = tUtils.addTestAttendees(c.id, '', tvr.id);
        
        test.startTest();
            system.assertEquals('Trip report sent by email...', TripReportEmailController.sendEmail(tvr.id));
        test.stoptest();
    }
    
    //Distro Group Only
    static testMethod void sendEmailTest2() {
        tUtils.SetTriggersOnForTesting();
        
        Account a = tUtils.addTestAccount(acctRT);
        Contact c = tUtils.createTestContact(a.Id, conRT);
        c.FirstName = 'Joey';
        insert c;
        distributiongroup__c dg = tUtils.addTestDistributionGroup ();
        EmailAddress__c ea = tUtils.addTestEmailAddress(dg.id,'Test1');
        TripReportDistribution__c trd = tUtils.addTestTripReportDistribution (a.id, '', dg.id);
        Trip_Visit_Report__c tvr = tUtils.addTestTVR(a.id, false);
        Attendees__c att = tUtils.addTestAttendees(c.id, '', tvr.id);
        
        test.startTest();
            system.assertEquals('Trip report sent by email...', TripReportEmailController.sendEmail(tvr.id));
        test.stoptest();
    }
    
    //Distro Group and Solo
    static testMethod void sendEmailTest3() {
        tUtils.SetTriggersOnForTesting();
        
        Account a = tUtils.addTestAccount(acctRT);
        Contact c = tUtils.createTestContact(a.Id, conRT);
        c.FirstName = 'Joey';
        insert c;
        
        distributiongroup__c dg = tUtils.addTestDistributionGroup ();
        EmailAddress__c ea = tUtils.addTestEmailAddress(dg.id,'Test1');
        TripReportDistribution__c trd1 = tUtils.addTestTripReportDistribution (a.id, '', dg.id);
        TripReportDistribution__c trd2 = tUtils.addTestTripReportDistribution (a.id, 'test@test.com', NULL);
        Trip_Visit_Report__c tvr = tUtils.addTestTVR(a.id, false);
        Attendees__c att = tUtils.addTestAttendees(c.id, '', tvr.id);
        
        test.startTest();
            system.assertEquals('Trip report sent by email...', TripReportEmailController.sendEmail(tvr.id));
        test.stoptest();
    }
    
    //Private
    static testMethod void sendEmailTest4() {
        tUtils.SetTriggersOnForTesting();
        
        Account a = tUtils.addTestAccount(acctRT);
        Trip_Visit_Report__c tvr = tUtils.addTestTVR(a.id, true);

        test.startTest();
        try{
            TripReportEmailController.sendEmail(tvr.id);
        }
        catch (exception e) { //SHOULD GET HERE
            //system.assertEquals(true,e.getMessage().contains('Trip Report has been marked Private. No email will be sent.'));
            system.assertEquals('Script-thrown exception',e.getMessage());
        }
        test.stoptest();
    }
    
    static testMethod void emailSendToOnlyTest() {
        tUtils.SetTriggersOnForTesting();
        
        Account a = tUtils.addTestAccount(acctRT);
        Account a2 = tUtils.createTestAccount(acctRT);
        a2.Name = 'Corning Test';
        insert a2;
        
        Contact c = tUtils.createTestContact(a.Id, conRT);
        c.FirstName = 'Joe';
        insert c;
        
        Contact c2 = tUtils.createTestContact(a2.Id, conRT);
        c2.FirstName = 'Walter';
        insert c2; 
                                        
        distributiongroup__c dg = tUtils.addTestDistributionGroup ();
        
        EmailAddress__c ea = tUtils.addTestEmailAddress(dg.id,'Test1');
        EmailAddress__c ea2 = tUtils.addTestEmailAddress(dg.id,'Test2'); 
        
        TripReportDistribution__c trd1 = tUtils.addTestTripReportDistribution (a.id, '', dg.id);
        TripReportDistribution__c trd2 = tUtils.addTestTripReportDistribution (a.id, 'test3@test.com', NULL);
        TripReportDistribution__c trd3 = tUtils.addTestTripReportDistribution (a.id, 'test4@test.com', NULL);
        
        Trip_Visit_Report__c tvr = tUtils.addTestTVR(a.id, false);
        
        Attendees__c att = tUtils.addTestAttendees(c2.id, '', tvr.id);
        Attendees__c att2 = tUtils.addTestAttendees(null, 'Susan Smith', tvr.id);
        Attendees__c att3 = tUtils.addTestAttendees(null, 'Jeremy Biffster', tvr.id);
                                       
        test.startTest();
            TripReportEmailController.sendEmail(tvr.id);
            system.assertEquals(4, TripReportEmailController.sendto.size());
        test.stoptest();
    }
    
    //Body
    static testMethod void emailBodyOnlyTest() {
        tUtils.SetTriggersOnForTesting();
        
        Account a = tUtils.addTestAccount(acctRT);
        Account a2 = tUtils.createTestAccount(acctRT);
        a2.Name = 'Corning Test';
        insert a2;
        
        Contact c = tUtils.createTestContact(a.Id, conRT);
        c.FirstName = 'Joe';
        insert c;
        
        Contact c2 = tUtils.createTestContact(a2.Id, conRT);
        c2.FirstName = 'Walter';
        insert c2; 
                                        
        distributiongroup__c dg = tUtils.addTestDistributionGroup ();
        
        EmailAddress__c ea = tUtils.addTestEmailAddress(dg.id,'Test1');
        EmailAddress__c ea2 = tUtils.addTestEmailAddress(dg.id,'Test2'); 
        
        TripReportDistribution__c trd1 = tUtils.addTestTripReportDistribution (a.id, '', dg.id);
        TripReportDistribution__c trd2 = tUtils.addTestTripReportDistribution (a.id, 'test3@test.com', NULL);
        TripReportDistribution__c trd3 = tUtils.addTestTripReportDistribution (a.id, 'test4@test.com', NULL);
        
        Trip_Visit_Report__c tvr = tUtils.addTestTVR(a.id, false);
        tvr = [SELECT Id, Account__c, Account__r.Name, Account__r.Owner.Name, Location_Event__c, tripReportTitle__c, 
                        Date_of_Meeting__c, Location__c, Owner.Name, Key_Highlights__c, private__c, venue__c, topicsDiscussed__c,
                        Purpose_Objective__c, Competative_Information_Shared__c, businessUnit__c, contractStatus__c, technolgiesDiscussed__c,
                        actualOrImplied__c,
                        competitor__c,fit__c ,Source__c,sourceCompanyName__c,sourceDepartmentName__c ,Product__c,thickness__c,glassUSPer_Sqft__c,
                        quoteInWhatCurrency__c,rebateOfferToOEM__c,rebateUsPerSqFt__c,corningSource__c,corningSource__r.Name,sheetSize__c,
                        executiveSummary__c, followUpActions__c,
                        technologiesDiscussedOther__c, oemInnovationTechnologyComments__c, comments__c, topicsDiscussedOther__c,
                        processImprovements__c, challengesCorningShouldAddress__c, specificActionToImproveInfoExchange__c             
                FROM Trip_Visit_Report__c
                WHERE Id = :tvr.id LIMIT 1];
                              
        list <string> aList = new list <string>();
        aList.add('Susan Smith');
        aList.add('Jeremy Biffster');
                                
        list <Contact> clist = [SELECT Id, FirstName, LastName, Title, Account.Name, AccountId
                                FROM Contact
                                WHERE Id = :c2.Id];         
        
        test.startTest();
            system.assertNotEquals('', TripReportEmailController.buildEmailBody(tvr, aList, cList)); 
            system.assertEquals(1, ((TripReportEmailController.corningAttendees).split(',')).size());
            system.assertEquals(1, ((TripReportEmailController.nonCorningAttendees).split(',')).size());
        test.stoptest();
    }
}