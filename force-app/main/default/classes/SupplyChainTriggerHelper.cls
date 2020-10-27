///*** Added for Gorilla Glass Implementation ***///
///*** Corning - 3/13/2017 ***///
///*** Class to help supply chain trigger ***///

public class SupplyChainTriggerHelper{
    static Utilities Utils = new Utilities();
        
    //Set opportunity team when AM changes
    public static void setOppTeam(List<SupplyChain__c> newlist){
    
        // build list of accounts from supply chain 
        Set<Id> accountSet = new Set<Id>();                    
        for (SupplyChain__c s : newList) {
            accountSet.add(s.finisher__c);
            accountSet.add(s.lcm__c);            
            accountSet.add(s.odm__c);
            accountSet.add(s.panelMaker__c);
            accountSet.add(s.tpm__c); 
            accountSet.add(Id.valueOf(s.oemId__c));                        
        }
        
        List<Id> accountList = new List<Id>(accountSet);
        List<Account> accounts = [Select id, ownerId, ae__c From Account Where ID IN :accountList];
        
        // create account map & user set
        Map<Id,Account> accountMap = new Map<Id,Account>();
        Set<Id> accountUserSet = new Set<Id>();
        
        for (Account a : accounts) {
            accountMap.put(a.id, a);
            accountUserSet.add(a.ownerId);
            accountUserSet.add(a.ae__c); 
        }
                 
        List<Id> userList = new List<Id>(accountUserSet);
        List<User> users = [Select isActive From User Where ID IN :userList];
        
         // create user map
        Map<Id,Boolean> userMap = new Map<Id,Boolean>();
        for (User u : users) {
            userMap.put(u.id, u.isActive);
        }       
        
        // list of team members
        List<OpportunityTeamMember> newMemberList = new List<OpportunityTeamMember>();
                
        Id oemAE;
        Id odmAM;
        Id odmAE;
        Id tpmAM;
        Id tpmAE;
        Id finisherAM;
        Id finisherAE;
        Id panelMakerAM;
        Id panelMakerAE;
        Id lcmAM;
        Id lcmAE;         
     
        for (SupplyChain__c sc : newList) {
            if (sc.oemId__c != null) {
                oemAE = accountMap.get(Id.valueOf(sc.oemId__c)).ae__c;
            }
            if (sc.odm__c != null) { 
                odmAM = accountMap.get(sc.odm__c).ownerId;
                odmAE = accountMap.get(sc.odm__c).ae__c;
            }
            if (sc.tpm__c != null) { 
                tpmAM = accountMap.get(sc.tpm__c).ownerId;
                tpmAE = accountMap.get(sc.tpm__c).ae__c;
            }
            if (sc.finisher__c != null) { 
                finisherAM = accountMap.get(sc.finisher__c).ownerId;
                finisherAE = accountMap.get(sc.finisher__c).ae__c;
            }
            if (sc.panelMaker__c != null) { 
                panelMakerAM = accountMap.get(sc.panelMaker__c).ownerId;
                panelMakerAE = accountMap.get(sc.panelMaker__c).ae__c;
            }
            if (sc.lcm__c != null) { 
                lcmAM = accountMap.get(sc.lcm__c).ownerId;
                lcmAE = accountMap.get(sc.lcm__c).ae__c;   
            }   
                              
            // OEM AE
            if (sc.oem__c != null && userMap.get(oemAE) == True) {    
            system.debug('**6');    
                OpportunityTeamMember aeOemMember = new OpportunityTeamMember();  
                aeOemMember.OpportunityId = sc.opportunity__c;  
                aeOemMember.UserId = oemAE;  
                aeOemMember.TeamMemberRole = 'OEM Application Engineer';
                aeOemMember.OpportunityAccessLevel = 'Edit';
                newMemberList.add(aeOemMember);                
            }
            
            // ODM AM 
            if (sc.odm__c != null && userMap.get(odmAM) == True) {       
                OpportunityTeamMember odmAmMember = new OpportunityTeamMember();  
                odmAmMember.OpportunityId = sc.opportunity__c;  
                odmAmMember.UserId = odmAM;  
                odmAmMember.TeamMemberRole = 'ODM Account Manager';
                odmAmMember.OpportunityAccessLevel = 'Edit';
                newMemberList.add(odmAmMember);                
            }           
            
            // ODM AE        
            if (sc.odm__c != null && userMap.get(odmAE) == True) {
                OpportunityTeamMember odmAeMember = new OpportunityTeamMember();  
                odmAeMember.OpportunityId = sc.opportunity__c;  
                odmAeMember.UserId = odmAE; 
                odmAeMember.TeamMemberRole = 'ODM Application Engineer';
                odmAeMember.OpportunityAccessLevel = 'Edit';
                newMemberList.add(odmAeMember);
            }

            // TPM AM   
            if (sc.tpm__c != null && userMap.get(tpmAM) == True) {
                OpportunityTeamMember tpmAmMember = new OpportunityTeamMember();  
                tpmAmMember.OpportunityId = sc.opportunity__c;  
                tpmAmMember.UserId = tpmAM;  
                tpmAmMember.TeamMemberRole = 'TPM Account Manager';
                tpmAmMember.OpportunityAccessLevel = 'Edit';
                newMemberList.add(tpmAmMember); 
            }         
            
            // TPM AE        
            if (sc.tpm__c != null && userMap.get(tpmAE) == True) {
                OpportunityTeamMember tpmAeMember = new OpportunityTeamMember();  
                tpmAeMember.OpportunityId = sc.opportunity__c;  
                tpmAeMember.UserId = tpmAE; 
                tpmAeMember.TeamMemberRole = 'TPM Application Engineer';
                tpmAeMember.OpportunityAccessLevel = 'Edit';
                newMemberList.add(tpmAeMember);
            }

            // Finisher AM        
            if (sc.finisher__c != null && userMap.get(finisherAM) == True) {
                OpportunityTeamMember finAmMember = new OpportunityTeamMember();  
                finAmMember.OpportunityId = sc.opportunity__c;  
                finAmMember.UserId = finisherAM;  
                finAmMember.TeamMemberRole = 'Finisher Account Manager';
                finAmMember.OpportunityAccessLevel = 'Edit';
                newMemberList.add(finAmMember);   
            }        
            
            // Finisher AE 
            if (sc.finisher__c != null && userMap.get(finisherAE) == True) {       
                OpportunityTeamMember finAeMember = new OpportunityTeamMember();  
                finAeMember.OpportunityId = sc.opportunity__c;  
                finAeMember.UserId = finisherAE; 
                finAeMember.TeamMemberRole = 'Finisher Application Engineer';
                finAeMember.OpportunityAccessLevel = 'Edit';
                newMemberList.add(finAeMember);
            }          

            // Panel Maker AM        
            if (sc.panelMaker__c != null && userMap.get(panelMakerAM) == True) {
                OpportunityTeamMember finAmMember = new OpportunityTeamMember();  
                finAmMember.OpportunityId = sc.opportunity__c;  
                finAmMember.UserId = panelMakerAM;  
                finAmMember.TeamMemberRole = 'Panel Maker Account Manager';
                finAmMember.OpportunityAccessLevel = 'Edit';
                newMemberList.add(finAmMember);   
            }        
            
            // Panel Maker AE 
            if (sc.panelMaker__c != null && userMap.get(panelMakerAE) == True) {       
                OpportunityTeamMember finAeMember = new OpportunityTeamMember();  
                finAeMember.OpportunityId = sc.opportunity__c;  
                finAeMember.UserId = panelMakerAE; 
                finAeMember.TeamMemberRole = 'Panel Maker Application Engineer';
                finAeMember.OpportunityAccessLevel = 'Edit';
                newMemberList.add(finAeMember);
            }          

            // LCM AM        
            if (sc.lcm__c != null && userMap.get(lcmAM) == True) {
                OpportunityTeamMember finAmMember = new OpportunityTeamMember();  
                finAmMember.OpportunityId = sc.opportunity__c;  
                finAmMember.UserId = lcmAM;  
                finAmMember.TeamMemberRole = 'LCM Account Manager';
                finAmMember.OpportunityAccessLevel = 'Edit';
                newMemberList.add(finAmMember);   
            }        
            
            // LCM AE 
            if (sc.lcm__c != null && userMap.get(lcmAE) == True) {       
                OpportunityTeamMember finAeMember = new OpportunityTeamMember();  
                finAeMember.OpportunityId = sc.opportunity__c;  
                finAeMember.UserId = lcmAE; 
                finAeMember.TeamMemberRole = 'LCM Application Engineer';
                finAeMember.OpportunityAccessLevel = 'Edit';
                newMemberList.add(finAeMember);
            }          
                               
        }
        
        system.debug(loggingLevel.debug, newMemberList.size());
        insert newMemberList;
        
    }
}