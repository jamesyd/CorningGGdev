global class AsyncOppotunityTeam {
 
    @future 
    public static void processOpportunities(Set<Id> oppIds) {
        RecordType rt = [SELECT Id, Name FROM RECORDTYPE WHERE Name like '%program%' AND SObjectType='opportunity'];       
        List<OpportunityTeamMember> memberList = new List<OpportunityTeamMember>();
        List<Opportunity> oppList = [select id, ownerId, RecordTypeId, previousOwnerID__c from Opportunity where Id IN :oppIds];
        List<String> oldOwnerList = new List<String>();
        Map<String, Boolean> oldOwnerListActive = new Map<String, Boolean>();
        
        // create list of old owner IDs
        for(Opportunity opp: oppList) {
            oldOwnerList.add(opp.previousOwnerID__c);
        }
        
        // query old owner user records
        List<User> userList = [Select isActive From User Where ID IN :oldOwnerList];
        
        // loop through old owner user records and create map of their active status
        for(User u: userList) {
            oldOwnerListActive.put(u.ID, u.isActive);
        }
        
        // only add active previous owners
        for(Opportunity o: oppList) {
            if ((!String.isBlank(o.previousOwnerID__c)) && (o.RecordTypeId == rt.id) && (o.ownerId != o.previousOwnerID__c) && (oldOwnerListActive.get(Id.valueOf(o.previousOwnerID__c)) == true)) {

                OpportunityTeamMember member = new OpportunityTeamMember();  
                member.OpportunityId = o.Id;  
                member.UserId = o.previousOwnerID__c;  
                member.TeamMemberRole = 'Previous Record Owner';
                member.OpportunityAccessLevel = 'Edit';
                memberList.add(member);
            }
        }
        insert memberList;
    }
}