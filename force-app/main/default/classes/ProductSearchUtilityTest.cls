/**
 * @File Name          : ProductSearchUtilityTest.cls
 * @Description        : 
 * @Author             : Adam Nicholson?
 * @Group              : 
 * @Last Modified By   : Arquimidez Mora
 * @Last Modified On   : 2/7/2020 14:09:15
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.1    2/7/2020   Arquimidez Mora            Fixing Test Class
**/
///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 3/29/2017 ***///
///*** Class to test ProductSearchUtility ***///

@IsTest
private class ProductSearchUtilityTest {
    static TestUtilities tUtils = new TestUtilities();
    private static string acctRT;
    private static string oppRT;
    private static string oppRT2;
    private static string quoteRT;
    private static string quoteRT2;
    private static string specRT;
    private static string profileId;
    private static string roleId;

    static {
        acctRT = tUtils.getRecordTypeId('Account', 'GG Account');
        oppRT = tUtils.getRecordTypeId('Opportunity', 'GG Program');
        oppRT2 = tUtils.getRecordTypeId('Opportunity', 'GG Parts Sample Request');
        quoteRT = tUtils.getRecordTypeId('Quote', 'GG Parts');
        quoteRT2 = tUtils.getRecordTypeId('Quote', 'GG Concore');
        specRT = tUtils.getRecordTypeId('Specification__c', 'Parts');
        profileId = tUtils.getProfileId('GG Account Manager');
        roleId = tUtils.getRoleId('GG Sales Mgr Americas/EMEA');

    }
    
    static testMethod void getMTOSpecProductsTestOpp() {
        tUtils.SetTriggersOnForTesting();
        //tUtils.SetAutoNotificationSettingsForTesting();
        User ta;
        User thisUser = [Select Id From User Where Id =: UserInfo.getUserId() ];
        system.runAs ( thisUser ) {
            ta = (tUtils.addTestUsers(profileId,1,roleId))[0];
        }
        
        system.runAs ( ta ) {
            Account a = tUtils.addTestAccount(acctRT);
            Account tpm = tUtils.createTestAccount(acctRT);
            tpm.containsPricing__c = true;
            tpm.accountType__c = 'TPM';
            insert tpm;
            Account finisher = tUtils.createTestAccount(acctRT);
            finisher.containsPricing__c = true;
            insert finisher;
            Opportunity o = tUtils.addTestOppt(a.Id,oppRT);

            Specification__c testSpec = tUtils.createTestSpec(a.id, o.id, specRT);
            testSpec.TPM__c = tpm.id; 
            testSpec.Status__c = 'New';
            insert testSpec;
            
            //testSpec.submitForApproval__c = true;
            //update testSpec;
            
            tUtils.AddTestGGProductAndPriceBookEntry(o, tpm, finisher); 
                        
            test.startTest();
                ProductSearchWrapper theWrapper = ProductSearchUtility.getMTOSpecProducts(o.id, Label.GGProductTypeConcore, 0, false, 10, false, false, false); 
                system.assertEquals(1,theWrapper.totalRecordCount);
                system.assertNotEquals(null,theWrapper.searchResults);
                system.assertEquals(0,theWrapper.requestedPageNumber);
            test.stopTest();
        }
    }
    
    static testMethod void getMTOSpecProductsTestQuote() {
        tUtils.SetTriggersOnForTesting();
        //tUtils.SetAutoNotificationSettingsForTesting();
        User ta;
        User thisUser = [Select Id From User Where Id =: UserInfo.getUserId() ];
        system.runAs ( thisUser ) {
            ta = (tUtils.addTestUsers(profileId,1,roleId))[0];
        }
        
        system.runAs ( ta ) {
            Account a = tUtils.addTestAccount(acctRT);
            Account tpm = tUtils.createTestAccount(acctRT);
            tpm.containsPricing__c = true;
            tpm.accountType__c = 'TPM';            
            insert tpm;
            Account finisher = tUtils.createTestAccount(acctRT);
            finisher.containsPricing__c = true;
            insert finisher;
 
            Opportunity o = tUtils.addTestOppt(a.Id,oppRT); 
			Opportunity o2 = tUtils.createTestOppt(a.Id,oppRT2);
            o2.massProductionOpportunity__c = o.Id;
            o2.pricingAssignmentComplete__c = true;
            insert o2;
            
            Specification__c testSpec = tUtils.createTestSpec(a.id, o.id, specRT);
            testSpec.TPM__c = tpm.id; 
            testSpec.Status__c = 'New';
            insert testSpec;
            
            //testSpec.submitForApproval__c = true;
            //update testSpec;
            
            Quote q = tUtils.addTestQuote(a.Id,o.Id, o2.Id,quoteRt);
            
            tUtils.AddTestGGProductAndPriceBookEntry(o, tpm, finisher); 
            
            test.startTest();
                ProductSearchWrapper theWrapper = ProductSearchUtility.getMTOSpecProducts(q.id, Label.GGProductTypeParts, 0, false, 10, false, false, false); 
                system.assertEquals(1,theWrapper.totalRecordCount);
                system.assertNotEquals(null,theWrapper.searchResults);
                system.assertEquals(0,theWrapper.requestedPageNumber);
            test.stopTest();
        }
    }
    
    static testMethod void searchProductsConcoreTest() {
        tUtils.SetTriggersOnForTesting();
        //tUtils.SetAutoNotificationSettingsForTesting();
        User ta;
        User thisUser = [Select Id From User Where Id =: UserInfo.getUserId() ];
        system.runAs ( thisUser ) {
            ta = (tUtils.addTestUsers(profileId,1,roleId))[0];
        }
        
        system.runAs ( ta ) {
            Account a = tUtils.addTestAccount(acctRT);
            Account tpm = tUtils.createTestAccount(acctRT);
            tpm.containsPricing__c = true;
            tpm.accountType__c = 'TPM';            
            insert tpm;
            Account finisher = tUtils.createTestAccount(acctRT);
            finisher.containsPricing__c = true;
            insert finisher;
            Opportunity o1 = tUtils.addTestOppt(a.Id,oppRT);

            Opportunity o = tUtils.addTestOppt(a.Id,oppRT2, false); 
            o.massProductionOpportunity__c = o1.Id;
            o.pricingAssignmentComplete__c = true;
            insert o;
            
            Quote q = tUtils.addTestQuote(a.Id,o.Id,quoteRt);
            
            Specification__c testSpec = tUtils.createTestSpec(a.id, o1.id, specRT);
            testSpec.TPM__c = tpm.id; 
            testSpec.Status__c = 'New';
            insert testSpec;
            
            //testSpec.submitForApproval__c = true;
            //update testSpec;
            
            tUtils.AddTestGGProductAndPriceBookEntry(o1, tpm, finisher); 
            List<Id> pIds = new List<Id>();
            integer i = 0;
            for (Price__c p : [SELECT Id FROM Price__c]){
                pIds.add(p.Id);
            }      
            
            OptyQuoteLIUtility util = new OptyQuoteLIUtility(o.Id, pIds);
            util.addLineItems();
            
            string filterStr = 'Test';
            
            //Set SOSL Search results
            Test.setFixedSearchResults(pIds);
            
            test.startTest();
                ProductSearchWrapper theWrapper = ProductSearchUtility.searchProducts(o.Id, 'Concore', filterStr, 0, false, 10, false, false, false);
                system.assertEquals(true, theWrapper.totalRecordCount > 0);
            test.stoptest();
        }
    }
    
    static testMethod void searchProductsPartsTest() {
        tUtils.SetTriggersOnForTesting();
        //tUtils.SetAutoNotificationSettingsForTesting();
        User ta;
        User thisUser = [Select Id From User Where Id =: UserInfo.getUserId() ];
        system.runAs ( thisUser ) {
            ta = (tUtils.addTestUsers(profileId,1,roleId))[0];
        }
        
        system.runAs ( ta ) {
            Account a = tUtils.addTestAccount(acctRT);
            Account tpm = tUtils.createTestAccount(acctRT);
            tpm.containsPricing__c = true;
            tpm.accountType__c = 'TPM';
            insert tpm;
            Account finisher = tUtils.createTestAccount(acctRT);
            finisher.containsPricing__c = true;
            insert finisher;
            Opportunity o1 = tUtils.addTestOppt(a.Id,oppRT);

            Opportunity o = tUtils.addTestOppt(a.Id,oppRT2, false); 
            o.massProductionOpportunity__c = o1.Id;
            o.pricingAssignmentComplete__c = true;
            insert o;
            
            Specification__c testSpec = tUtils.createTestSpec(a.id, o1.id, specRT);
            testSpec.TPM__c = tpm.id; 
            testSpec.Status__c = 'New';
            insert testSpec;
            
            //testSpec.submitForApproval__c = true;
            //update testSpec;
            
            Quote q = tUtils.addTestQuote(a.Id,o.Id,quoteRt);
            
            tUtils.AddTestGGProductAndPriceBookEntry(o1, tpm, finisher); 
            List<Id> pIds = new List<Id>();
            integer i = 0;
            for (Price__c p : [SELECT Id FROM Price__c]){
                pIds.add(p.Id);
            }      
            
            OptyQuoteLIUtility util = new OptyQuoteLIUtility(o.Id, pIds);
            util.addLineItems();
            
            string filterStr = 'Test';
            
            //Set SOSL Search results
            Test.setFixedSearchResults(pIds);
            
            test.startTest();
                ProductSearchWrapper theWrapper = ProductSearchUtility.searchProducts(o.Id, 'Parts', filterStr, 0, false, 10, false, false, false);
                system.assertEquals(true, theWrapper.totalRecordCount > 0);
            test.stoptest();
        }       
    }
}