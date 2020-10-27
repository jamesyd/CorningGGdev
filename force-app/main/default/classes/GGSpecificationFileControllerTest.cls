/**
    Name                : GGSpecificationFileControllerTest
    Description         : This is a test class for the GGSpecificationFileController.
*/


@isTest
public class GGSpecificationFileControllerTest {
    @testSetup static void methodName() {
        
        Account acc = new Account(Name = 'Test Account', Type = 'OEM');
        insert acc;
        
        Date myDate = date.newInstance(2020, 01, 21);
        Opportunity opp = new Opportunity(Name = 'Test Opp', AccountId = acc.Id, StageName = '0 - Status Quo',CloseDate = myDate
                                          , type = 'Raw Glass', customerProductModelName__c = 'Testing Product'
                                          , estimatedLaunchDate__c = myDate, application__c = 'Back Cover'
                                          , primaryGlassComposition__c = '1815', region__c = 'CHN', marketSegment__c = 'Wearable'
                                          , specialShapes__c = '2D', treatment__c = 'AG', marketSubSegment__c = 'Watch'
                                          , Start_of_Production__c = myDate, estimatedMonthsInProduction__c = '7'
                                          , estimatedTotalVolume__c = 5, Competitive_Material__c = 'Plastic', gorillaGlassPercent__c = 100
                                          , massProductionYield__c = 1, finalFinishedGlassPartThickness__c = '0.50'
                                          , glassSelectionDate__c = system.today());
        insert opp;
        
        Specification__c spec = new Specification__c(Name = 'Test Spec Name', opportunity__c = opp.Id, glassComposition__c = '1805'
                                                     , width__c = 7387, length__c = 3748, thickness__c = 3874);
        insert spec;
        
        Specification__c specTwo = new Specification__c(Name = 'Test Spec Two', opportunity__c = opp.Id, glassComposition__c = '1815', 
                                                        Status__c ='Pricing Approved'
                                                        , width__c = 7387, length__c = 3748, thickness__c = 3874);
        insert specTwo;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document one';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        ContentVersion cv2 = new ContentVersion();
        cv2.Title = 'Test Document Pricing';
        cv2.PathOnClient = 'TestDocument.pdf';
        cv2.VersionData = Blob.valueOf('Test Content');
        cv2.IsMajorVersion = true;
        Insert cv2;
        
        List<ContentDocument> documentOne = [SELECT Id, Title, LatestPublishedVersionId 
                                            FROM ContentDocument
                                            WHERE Title = 'Test Document one'];
        List<ContentDocument> documentTwo = [SELECT Id, Title, LatestPublishedVersionId 
                                            FROM ContentDocument
                                            WHERE Title = 'Test Document Pricing'];
        
        System.Assert(documentOne.size() == 1);
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=spec.id;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId=documentOne[0].Id;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        ContentDocumentLink contentlinkTwo =new ContentDocumentLink();
        contentlinkTwo.LinkedEntityId=specTwo.id;
        contentlinkTwo.ShareType= 'V';
        contentlinkTwo.ContentDocumentId=documentTwo[0].Id;
        contentlinkTwo.Visibility = 'AllUsers'; 
        insert contentlinkTwo;
    }
    
    @isTest
    public static void ggcontentUnitTest(){
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId 
                                            FROM ContentDocument
                                            WHERE Title = 'Test Document one'];
        Specification__c specification = [SELECT Id 
                                            FROM Specification__c 
                                            WHERE glassComposition__c = '1805' 
                                            LIMIT 1];
        
        
        List<String> docid = new List<String>();
        for(ContentDocument c: documents){
            docid.add(c.id);
        }
        
        GGSpecificationFileController.getFilesDetails(specification.Id); 
        GGSpecificationFileController.deleteSpecificationFiles(docid,specification.Id);
        
        documents = [SELECT Id, Title, LatestPublishedVersionId 
                                            FROM ContentDocument
                                            WHERE Title = 'Test Document one'];
        System.Assert(documents.size() == 0);
    }
    
    
    @isTest
    public static void ggcontentUnitNegativeTest(){
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId 
                                            FROM ContentDocument
                                            WHERE Title = 'Test Document Pricing'];
        List<String> docids = new List<String>();
        for(ContentDocument c: documents){
            docids.add(c.id);
        }
        
        Specification__c specidTwo = [SELECT Id 
                                       FROM Specification__c 
                                       WHERE glassComposition__c = '1815' 
                                       LIMIT 1];
        
        GGSpecificationFileController.deleteSpecificationFiles(docids, specidTwo.Id);
    }
    
}