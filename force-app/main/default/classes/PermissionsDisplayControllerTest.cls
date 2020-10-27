///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 4/14/2017 ***///
///*** Controller test class to display user Permissions on Quote, Specification, and Opportunity ***///
@isTest
private class PermissionsDisplayControllerTest {
    static TestUtilities tUtils = new TestUtilities();
    private static string acctRT;
    private static string oppRT;
    private static string profileId;
    private static string roleId;
    private static string profileId2;
    private static string roleId2;
    
    static {
        acctRT = tUtils.getRecordTypeId('Account', 'GG Account');
        oppRT = tUtils.getRecordTypeId('Opportunity', 'GG Program');
        profileId = tUtils.getProfileId('GG Account Manager');
        profileId2 = tUtils.getProfileId('GG Plant Engineering');
        roleId = tUtils.getRoleId('GG Sales Americas/EMEA');
        roleId2 = tUtils.getRoleId('GG Engineering');
    }

    //Edit
    static testMethod void getPermissionsTest1() {
        User ta;
        
        tUtils.SetTriggersOnForTesting();
        
        Account a = tUtils.addTestAccount(acctRT);
	    Opportunity o = tUtils.addTestOppt(a.Id,oppRT);

		test.startTest();
		PageReference pageRef = Page.OpportunityPermissionsDisplay;
		Test.setCurrentPage(pageRef);
		
		ApexPages.currentPage().getParameters().put('id', o.Id);
		
		ApexPages.StandardController stdController = new ApexPages.StandardController(o);
	    PermissionsDisplayController con = new PermissionsDisplayController(stdController);
			
		con.getPermissions(); 
    	system.assertEquals(Label.GGRecordEditable + ' record',con.message);	
		test.stopTest();
    }
    
    //View
/*    static testMethod void getPermissionsTest2() {
        User ta;
        Account a;
        Opportunity o;
        
        tUtils.SetTriggersOnForTesting();
        
        User thisUser = [Select Id From User Where Id =: UserInfo.getUserId() ];
    	system.runAs ( thisUser ) {
    		ta = (tUtils.addTestUsers(profileId2,1,roleId2))[0];
    		a = tUtils.addTestAccount(acctRT);
	        o = tUtils.addTestOppt(a.Id,oppRT);
    	}
        
        system.runAs ( ta ) {
	        test.startTest();
				PageReference pageRef = Page.OpportunityPermissionsDisplay;
				Test.setCurrentPage(pageRef);
				
				ApexPages.currentPage().getParameters().put('id', o.Id);
				
				ApexPages.StandardController stdController = new ApexPages.StandardController(o);
			    PermissionsDisplayController con = new PermissionsDisplayController(stdController);
					
				con.getPermissions(); 
		    	system.assertEquals(Label.GGRecordViewable + ' record',con.message);	
		    	system.assertEquals('Opportunity',con.theWrapper.sObjectType);
		    	system.assertEquals(o.id,con.theWrapper.RecordId);
		    	system.assertEquals(ta.id,con.theWrapper.UserId);
		    	system.assertEquals(false,con.theWrapper.RecordCreatable);
		    	system.assertEquals(false,con.theWrapper.RecordEditable);
		    	system.assertEquals(true,con.theWrapper.RecordViewable);
			test.stopTest();
        }	
    }
    
    static testMethod void getUserRecordAccessTest() {
        User ta;
        Account a;
        Opportunity o;
        
        tUtils.SetTriggersOnForTesting();
        
        User thisUser = [Select Id From User Where Id =: UserInfo.getUserId() ];
    	system.runAs ( thisUser ) {
    		ta = (tUtils.addTestUsers(profileId2,1,roleId2))[0];
    		a = tUtils.addTestAccount(acctRT);
	        o = tUtils.addTestOppt(a.Id,oppRT);
    	}
    	
    	Utilities utils = new Utilities();
    	Utilities.RecordAccessWrapper theWrapper = new Utilities.RecordAccessWrapper(); 
    	theWrapper = utils.getUserRecordAccess(o.id, ta.id); 
        system.assertEquals('Opportunity',theWrapper.sObjectType);
    	system.assertEquals(o.id,theWrapper.RecordId);
    	system.assertEquals(ta.id,theWrapper.UserId);
    	system.assertEquals(false,theWrapper.RecordCreatable);
    	system.assertEquals(false,theWrapper.RecordEditable);
    	system.assertEquals(true,theWrapper.RecordViewable);
    }*/
}