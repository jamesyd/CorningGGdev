///*** Added for Gorilla Glass Implementation ***///
///*** Corning - 5/2/2017 ***///

@isTest
private class StandardProductDataToProductUtilityTest {
    static TestUtilities tUtils = new TestUtilities();
    private static string acctRT;

    static {
        acctRT = tUtils.getRecordTypeId('Account', 'GG Account');
    }

    static testMethod void checkContainsPricingTest() {
        // tUtils.createTestMatrixRecord();
        
        Pricebook2 standardPricebook = new Pricebook2(Id=Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;
        
        Pricebook2 customPB = new Pricebook2(Name='GG Price Book', isActive=true);
        insert customPB;
        
        Account a1 = tUtils.createTestAccount(acctRT);
        a1.containsPricing__c = true;
        insert a1;
        
         //create product matrix record
        StandardProductInventoryMatrix__c m = new StandardProductInventoryMatrix__c();
        m.name = 'x';
        m.glassComposition__c = '2320 (GG3)';// 11-16-20 jd (change to '2320 (GG3)'')
        m.thickness__c = '0.40';
        m.width__c = '1520';
        m.customwidth__c = 1520;
        m.length__c = '1460';
        m.customlength__c = 1460;
        m.productLine__c = 'Raw Glass';
        m.isActive__c = TRUE;
        m.estimatedCrateSheetCount__c = 450;
        m.maximumCrateDimensions__c = '1690 x 1910 x 900';
        m.moq__c = 450;
        m.moqUnits__c = 'Each';
        insert m;
        
        //test.startTest();
            StandardProductInventoryLoader__c l = new StandardProductInventoryLoader__c();
            l.glassComposition__c = '2320 (GG3)'; // 11-16-20 jd (change to '2320 (GG3)'')
            l.thickness__c = '0.40';
            l.pricePerSqFt__c = 16.33;
            l.account__c = a1.id;
            l.productLine__c = 'Raw Glass';
            insert l;
        //test.stopTest();
    }

}