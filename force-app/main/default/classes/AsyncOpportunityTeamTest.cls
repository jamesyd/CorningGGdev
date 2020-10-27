@isTest
private class AsyncOpportunityTeamTest {
    static TestUtilities tUtils = new TestUtilities();
    private static string opptRT;
    private static string acctRT;

    static {
        acctRT = tUtils.getRecordTypeId('Account', 'GG Account');
        opptRT = tUtils.getRecordTypeId('Opportunity', 'GG Program');
    }

    static testMethod void changeOwner() {
        tUtils.SetTriggersOnForTesting();
        
        Account a1 = tUtils.createTestAccount(acctRT);
        insert a1;
        
        Opportunity o1 = tUtils.addTestOppt(a1.Id,opptRT);
        
        Test.startTest();

            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];

            User usr = new User(Alias = 'standt', Email='standarduser@corning.com',
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                        EmployeeNumber = 'DO NOT USE',
                        LocaleSidKey='en_US', ProfileId = p.Id,
                        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@corning.com');
            insert usr ;

            System.runAs(usr)

            {
                o1.ownerId = usr.id;
                update o1;
                
                Set<Id> changeSet = new Set<Id>(); 
                changeSet.add(o1.id);
                AsyncOppotunityTeam.processOpportunities(changeSet);
            }

        Test.stopTest();
    }

}