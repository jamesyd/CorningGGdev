/*********
Name                : ForecstEmailReminderHandler
Description         : This is the handler class that will send the reminder email to the Forecast.
*********/


public class ForecastEmailReminderHandler {
    
    //Method to get all the user ids from the Group via Group Member.
    private static Set<Id> getUserIds(){
        Set<Id> userIds = new Set<Id>();
        Set<Id> groupIds = new Set<Id>();
        List<GroupMember> groupMemberList = new List<GroupMember>();
        Map<Id, Group> 
            groupById = new  Map<id, Group>([SELECT 
                              (SELECT UserOrGroupId 
                               FROM GroupMembers) 
                            FROM Group 
                            WHERE Name =: System.Label.ForecastReminderGroupName]);
        
        for(Group grp: groupById.values()){
            groupMemberList.addAll(grp.GroupMembers);
        }
        
        if(groupById.size() > 0){
            if(groupMemberList.size() > 0){    
                userIds.addAll(getUserFromMembersIds(groupMemberList, userIds));
            }
            userIds.addAll(getUserIdsFromRole(groupById.keySet(), userIds));
        }
        return userIds;
    }
    
    //Method to get the User Ids from the associate Role.
    private static Set<id> getUserIdsFromRole(Set<Id> groupIds, Set<Id> userIds){
        Set<Id> roleIds = new Set<id>();
        for(Group grp: [SELECT Id,Name,DeveloperName,RelatedId 
                            FROM Group 
                            WHERE Type = 'Role' 
                            AND Id IN :groupIds]){
            roleIds.add(grp.RelatedId);
        }
        
        if(roleIds.size() > 0){
            Map<id, User> userById = new Map<Id, User>([SELECT id 
                                                     FROM User 
                                                     WHERE UserRoleId IN :roleIds]);
        
            userIds.addAll(userById.keySet());
        }
        return userIds;
    }
    
    //Method of the user list from Group Member.
    private static Set<id> getUserFromMembersIds(List<GroupMember> groupMembers, Set<Id> userIds){
        Set<Id> groupIds = new Set<Id>();
        for (GroupMember gm : groupMembers) {
            if(gm.UserOrGroupId.getSobjectType() == Schema.User.getSObjectType()){
                userIds.add(gm.UserOrGroupId);
            }else{
                groupIds.add(gm.UserOrGroupId);
            }
        }
        if(groupIds.size() > 0){
            userIds.addAll(getUserIdsfromGroup(groupIds, userIds));
        }
        return userIds;
    }
    
    //Method to get the User From Group.
    private static Set<id> getUserIdsfromGroup(Set<Id> groupIds, Set<Id> userIds){
        List<GroupMember> groupMemberList = new List<GroupMember>();
        Map<Id, Group> 
            groupById = new  Map<id, Group>([SELECT 
                              (SELECT UserOrGroupId 
                               FROM GroupMembers) 
                            FROM Group 
                            WHERE Id IN :groupIds]);
        
        for(Group grp: groupById.values()){
            groupMemberList.addAll(grp.GroupMembers);
        }
        if(groupById.size() > 0){
            if(groupMemberList.size() > 0){    
                userIds.addAll(getUserFromMembersIds(groupMemberList, userIds));
            }
            userIds.addAll(getUserIdsFromRole(groupById.keySet(), userIds));
        }
        return userIds;
    }
    
    //Method to send email to the user.
    public static void sendMailToGroupMember() {
       EmailTemplate templateId = [SELECT Id 
                                    FROM EmailTemplate 
                                    WHERE DeveloperName =: System.Label.ForecastReminderEmailTemplate];
        
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        
        Set<Id> userIds = getUserIds();
        for(String mailadd : userIds){
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(templateId.Id);
            mail.setTargetObjectId(mailadd);
            mail.setSaveAsActivity(false);
            mail.setUseSignature(false);
            
            allmsg.add(mail);
        }
        try{
            Messaging.sendEmail(allmsg,false);
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
}