/**
 * @File Name          : AccountTriggerHelperTest.cls
 * @Description        : 
 * @Author             : Adam Nicholson?
 * @Group              : 
 * @Last Modified By   : Arquimidez Mora
 * @Last Modified On   : 2/7/2020 12:02:50
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.1    2/7/2020   Arquimidez Mora            Fixing test clases
**/
///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 3/27/2017 ***///
///*** Class to help Account trigger ***///
@isTest
private class AccountTriggerHelperTest {
    static TestUtilities tUtils = new TestUtilities();
    private static string acctRT;
    private static string oppRT;

    static {
        acctRT = tUtils.getRecordTypeId('Account', 'GG Account');
        oppRT = tUtils.getRecordTypeId('Opportunity', 'GG Inquiry');
    }

    static testMethod void checkContainsPricingTest() {
        tUtils.SetTriggersOnForTesting();
        
        Account a1 = tUtils.createTestAccount(acctRT);
        a1.containsPricing__c = true;
        insert a1;
        
        Account a2 = tUtils.createTestAccount(acctRT);
        a2.Name = '123 Corp Test';
        a2.containsPricing__c = false;
        insert a2;
        
        test.startTest();
            try {
                delete a1;
            }
            catch (exception e) { //SHOULD GET HERE
                system.assertEquals(true,e.getMessage().contains(Label.DeleteAccountError));
            }
            
            try {
                delete a2;
            }
            catch (exception e) { //SHOULD NOT GET HERE
                system.assertEquals(true,e.getMessage().contains(Label.DeleteAccountError));
            }
        test.stopTest();
    }
    
    @isTest
    private static void unitTestPriceOwnerChange(){
        tUtils.SetTriggersOnForTesting();
        
        Account a1 = tUtils.createTestAccount(acctRT);
        a1.accountType__c = 'TPM';
        insert a1;
        Opportunity o = tUtils.addTestOppt(a1.Id,oppRT);
        tUtils.AddTestGGProductAndPriceBookEntry(o,a1,a1);
        
        AccountContract__c aContract = new AccountContract__c(
            Account__c = a1.Id,
            expirationDate__c = System.today().addDays(4)
        );
        INSERT aContract;
        
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
 
        // Test INSERT
        ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.assertEquals(documents.size(), 1);
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.ShareType= 'I';
        contentlink.LinkedEntityId = aContract.Id; 
        contentlink.ContentDocumentId=documents[0].Id;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        List<User> uList = tUtils.createTestUsers(UserInfo.getProfileId(), 1, null);
        INSERT uList;
        User u = uList.get(0);
        System.runAs(u){
            test.startTest();
            a1.OwnerId = u.Id;
            UPDATE a1;
            test.stopTest();
            for(Price__c p : [SELECT OwnerId FROM Price__c WHERE isMTO__c = false AND Account__c = :a1.Id]){
                System.assertEquals(u.Id, p.OwnerId); // Owner Id of Price should be changed to the new Owner of Account
            }
        }
        
    }
}