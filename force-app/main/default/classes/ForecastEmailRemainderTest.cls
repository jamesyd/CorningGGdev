/*****
    Name                : ForecastEmailRemainderHelper
    Description         : This is the test class for the class 
                          ForecastEmailRemainderHelper and ForecastEmailRemainderSchedular.
*****/

@IsTest
public class ForecastEmailRemainderTest{
    @testSetup
    public static void testData(){
        //Create Parent Group
        Group grp = new Group();
        grp.name = System.Label.ForecastReminderGroupName;
        grp.Type = 'Regular'; 
        Insert grp; 
 
        //Create Sub group
        Group subGrp  = new Group();
        subGrp.name = 'Test Group2';
        subGrp.Type = 'Regular'; 
        Insert subGrp; 
 
        //Assign Role To Parent Group
        GroupMember grpMem2 = new GroupMember();
        grpMem2.UserOrGroupId = subGrp.Id;
        grpMem2.GroupId = grp.Id;
        Insert grpMem2;  
 
        //Create Group Map Data
        Map<String,Id> groupNameRoleIdMap = new Map<String,Id>();
        for(Group gp: [SELECT Id, Name FROM Group WHERE Type = 'Role']){
            groupNameRoleIdMap.put('SuperAdmin', gp.Id);
        }     
 
        //Assign role to parent group
        GroupMember grpMem3 = new GroupMember();
        grpMem3.UserOrGroupId = groupNameRoleIdMap.get('SuperAdmin');
        grpMem3.GroupId = grp.Id;
        Insert grpMem3; 
 
        //Create Group And Sub Group Map Data
        Map<String,Id> groupNameRoleAndSubordinatesIdMap = new Map<String,Id>();
        for(Group gp: [SELECT Id, Name FROM Group WHERE Type = 'RoleAndSubordinates']){
            groupNameRoleAndSubordinatesIdMap.put('Admin', gp.Id);
        } 
 
        //Assign Role To Parent Group
        GroupMember grpMem4 = new GroupMember();
        grpMem4.UserOrGroupId = groupNameRoleAndSubordinatesIdMap.get('Admin');
        grpMem4.GroupId = grp.Id;
        Insert grpMem4;  
    }
    
    public static testMethod void testUnitOne(){
        test.startTest();
        ForecastEmailReminderSchedular reminder = new ForecastEmailReminderSchedular();
        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String sch = '20 30 8 10 2 ?';
        String jobID = System.schedule('Remind Opp Owners', sch, reminder);
        test.stopTest();
    }
}