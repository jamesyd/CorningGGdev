/*
    Name             : ContentDocumentLinkTriggerTest
    Description      : This is the test class for ContentDocumentLinkTrigger and ContentDocumentLinkTriggerHelper
*/

@isTest
public class ContentDocumentLinkTriggerTest {
    
    @testSetup static void testData() {
        Account acc = new Account(Name = 'Test Account', Type = 'OEM');
        insert acc;
        date myDate = date.newInstance(2020, 01, 21);
        Opportunity opp = new Opportunity(Name = 'Test Opp', AccountId = acc.Id, StageName = '0 - Status Quo',CloseDate = myDate
                                          , type = 'Raw Glass', customerProductModelName__c = 'Testing Product'
                                          , estimatedLaunchDate__c = myDate, application__c = 'Back Cover'
                                          , primaryGlassComposition__c = '1815', region__c = 'CHN', marketSegment__c = 'Wearable'
                                          , specialShapes__c = '2D', treatment__c = 'AG', marketSubSegment__c = 'Watch'
                                          , Start_of_Production__c = myDate, estimatedMonthsInProduction__c = '7'
                                          , estimatedTotalVolume__c = 5, Competitive_Material__c = 'Plastic', gorillaGlassPercent__c = 100
                                          , massProductionYield__c = 1, finalFinishedGlassPartThickness__c = '0.50'
                                          , glassSelectionDate__c = system.today() );
        insert opp;
        Specification__c spec = new Specification__c(Name = 'Test Spec Name', opportunity__c = opp.Id, glassComposition__c = '1805'
                                                     , width__c = 7387, length__c = 3748, thickness__c = 3874);
        insert spec;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument]; 
        ContentDocumentLink contentlink=new ContentDocumentLink(); 
        contentlink.LinkedEntityId=spec.id; 
        contentlink.ContentDocumentId=documents[0].Id; 
        contentlink.Visibility = 'AllUsers'; 
        contentlink.ShareType= 'V';
        insert contentlink;
        
    }
    
    @isTest
    public static void contentUnitTest1(){
        Specification__c spec = [SELECT Id, Name from Specification__c WHERE glassComposition__c = '1805' LIMIT 1];
        List<ContentDocumentLink> documents = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =: spec.Id];  
        DELETE documents; 
        documents = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =: spec.Id]; 
        System.assert(documents.size() == 0);
    }
    
    @isTest
    public static void contentUnitTest2(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standardusert57576890@testorg.com', 
                          EmployeeNumber = 'DO NOT USE');
        insert u;
        
        System.runAs(u) {
            Test.startTest();
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document 2';
            cv.PathOnClient = 'TestDocument.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            Insert cv;
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId 
                                                FROM ContentDocument 
                                                WHERE Title = :cv.Title];
            List<ContentDocumentLink> documentLinks = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId =: documents[0].Id];   
            DELETE documentLinks;
            
            Test.stopTest();
            documents = [SELECT Id, Title, LatestPublishedVersionId 
                                                FROM ContentDocument 
                                                WHERE Title = :cv.Title];
            System.assert(documents.size() == 0);
        }
    }
    
    @isTest
    public static void contentUnitTest3(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standardusert57576890@testorg.com', 
                          EmployeeNumber = 'DO NOT USE');
        insert u;
        Specification__c spec = [SELECT Id from Specification__c WHERE glassComposition__c = '1805'];
        Opportunity opp = [SELECT Id from Opportunity WHERE StageName = '0 - Status Quo' LIMIT 1];
        
        OpportunityTeamMember opm = new OpportunityTeamMember(OpportunityId=opp.id,UserId=u.id);
        insert opm;
        
        ContentVersion cv2 = new ContentVersion();
        cv2.Title = 'Test Document 2';
        cv2.PathOnClient = 'TestDocument.pdf';
        cv2.VersionData = Blob.valueOf('Test Content');
        cv2.IsMajorVersion = true;
        Insert cv2;
        
        System.runAs(u) {
            Test.startTest();
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document 2';
            cv.PathOnClient = 'TestDocument.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            Insert cv;
            
            
            
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId 
                                                FROM ContentDocument 
                                                WHERE Title = :cv.Title];
            
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=spec.id;
            contentlink.ShareType= 'V';
            contentlink.ContentDocumentId=documents[0].Id;
            contentlink.Visibility = 'AllUsers'; 
            insert contentlink;
            
            List<ContentDocumentLink> documentLinks = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId =: documents[0].Id];   
            DELETE documentLinks;
            
            Test.stopTest();
            documents = [SELECT Id, Title, LatestPublishedVersionId 
                                                FROM ContentDocument 
                                                WHERE Title = :cv.Title];
            System.assert(documents.size() == 0);
        }
    }
}