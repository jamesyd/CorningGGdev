///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 2/15/2017 ***///
///*** Test class for Controller class used in the specification clone custom Lightning component ***///
@isTest
private class SpecificationCloneControllerTest {
    static TestUtilities tUtils = new TestUtilities();
    private static string acctRT;
    private static string oppRT;
    private static string specRT;
    
    static {
        acctRT = tUtils.getRecordTypeId('Account', 'GG Account');
        oppRT = tUtils.getRecordTypeId('Opportunity', 'GG Program');
        specRT = tUtils.getRecordTypeId('Specification__c', 'Parts');
    }

    static testMethod void testCloneSpecNoAttach() {
        tUtils.SetTriggersOnForTesting();
        Account a = tUtils.addTestAccount(acctRT);
        a.accountType__c = 'TPM';
        update a;
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Specification__c testSpec = tUtils.createTestSpec(a.id, o.id, specRT);
        testSpec.TPM__c = a.id;
        testSpec.ioxNeeded__c = 'No';
        testSpec.status__c = 'New';
        insert testSpec;
        
        Specification__c originalSpec = [SELECT application__c, RecordType.Name 
                                            FROM Specification__c 
                                            WHERE Id = :testSpec.Id LIMIT 1];
                                        
        system.assertEquals('Parts', originalSpec.RecordType.Name); 
                                        
        system.test.startTest();
            SpecificationCloneController.CloneResultWrapper cw = SpecificationCloneController.cloneSpec(testSpec.id, null, false, null);
            string newId = cw.clonedSpecId;
         
            system.assertNotEquals('', newId);
            
            Specification__c insertedSpec = [SELECT Id, status__c, SubmitforApproval__c, RecordType.Name 
                                            FROM Specification__c 
                                            WHERE Id = :newId LIMIT 1];
            
            system.assertEquals('New', insertedSpec.status__c);
            system.assertEquals(false, insertedSpec.SubmitforApproval__c);
            system.assertEquals('Parts', insertedSpec.RecordType.Name);
        system.test.stopTest();
    }
    
    static testMethod void testCloneSpecAttach() {
        tUtils.SetTriggersOnForTesting();
        Account a = tUtils.addTestAccount(acctRT);
        a.accountType__c = 'TPM';
        update a;
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        Specification__c testSpec = tUtils.createTestSpec(a.id, o.id, specRT);
        testSpec.TPM__c = a.id;
        testSpec.ioxNeeded__c = 'No';
        testSpec.status__c = 'New';
        insert testSpec;
        
        Specification__c originalSpec = [SELECT RecordType.Name 
                                            FROM Specification__c 
                                            WHERE Id = :testSpec.Id LIMIT 1];
                                        
        system.assertEquals('Parts', originalSpec.RecordType.Name);                            
        
        //Create Document to Attach
        ContentVersion newCV = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert newCV;
        
        ContentVersion newCV2 = new ContentVersion(
            Title = 'Polar Bears',
            PathOnClient = 'Bears.jpg',
            VersionData = Blob.valueOf('More Test Content'),
            IsMajorVersion = true
        );
        insert newCV2;
        
        List<ContentVersion> insertedCVs = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :newCV.Id];
        List<ContentDocument> cds = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
    
        //Attach to Spec
        ContentDocumentLink newCDL = new ContentDocumentLink();
        newCDL.Visibility = 'AllUsers';
        newCDL.ShareType = 'V';
        newCDL.LinkedEntityId = testSpec.Id;
        newCDL.ContentDocumentId = cds[0].Id;
        insert newCDL;
        
        ContentDocumentLink newCDL2 = new ContentDocumentLink();
        newCDL2.Visibility = 'AllUsers';
        newCDL2.ShareType = 'V';
        newCDL2.LinkedEntityId = testSpec.Id;
        newCDL2.ContentDocumentId = cds[1].Id;
        insert newCDL2;

        system.test.startTest();
        SpecificationCloneController.CloneResultWrapper cw = SpecificationCloneController.cloneSpec(testSpec.id, testSpec.opportunity__c, true, 'Test123');
            string newId = cw.clonedSpecId;
            system.assertNotEquals('', newId);
            
            Specification__c insertedSpec = [SELECT Id, status__c, SubmitforApproval__c, RecordType.Name,cloneReason__c 
                                            FROM Specification__c 
                                            WHERE Id = :newId LIMIT 1];
            
            system.assertEquals('New', insertedSpec.status__c);
            system.assertEquals(false, insertedSpec.SubmitforApproval__c);
            system.assertEquals('Parts', insertedSpec.RecordType.Name);
            system.assertEquals('Test123', insertedSpec.cloneReason__c);
            
            list<ContentDocumentLink> testLink =  [SELECT Visibility, ShareType, LinkedEntityId, ContentDocumentId, ContentDocument.Title
                            FROM ContentDocumentLink 
                            WHERE LinkedEntityId=:insertedSpec.Id];
                            
            system.assertEquals(2, testLink.size());    
            system.assertEquals('AllUsers', testLink[0].Visibility);    
            system.assertEquals('Penguins', testLink[0].ContentDocument.Title); 
            system.assertEquals('Polar Bears', testLink[1].ContentDocument.Title);  

        system.test.stopTest();     
    }
}