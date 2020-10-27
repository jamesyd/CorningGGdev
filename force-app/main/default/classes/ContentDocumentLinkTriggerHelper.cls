/*
    Name            : ContentDocumentLinkTriggerHelper
    Description     : This is the helper class of ContentDocumentLinkTrigger.
    
*/

public class ContentDocumentLinkTriggerHelper{
    
    public static void afterInsert(List<ContentDocumentLink> contentDocumentLinks){
        boolean isErrorAdded = false;
        User usr = getCurrentuser();
        
        if(isSuperUserPermission(usr)){
            createFileNotification(contentDocumentLinks);
            return;
        }
        
        checkAndValidateForDelete(contentDocumentLinks);
        createFileNotification(contentDocumentLinks);
    }
    
    //Check User is valid to make changes or not.
    public static boolean isValidUser(User usr){
        return checkValidUser(usr);
    }
    
    private static Boolean isSuperUserPermission(User usr){
        boolean SystemAdminProfile = System.Label.GGSpecificationSystemAdminProfileName.contains(usr.Profile.Name);
        return (SystemAdminProfile || checkPermissionSet());
    }
    
    public static void beforeDelete(List<ContentDocumentLink> contentDocumentLinks){
        boolean isErrorAdded = false;
        User usr = getCurrentuser();
        
        if(isSuperUserPermission(usr)){
            createFileNotification(contentDocumentLinks);
            return;
        }
        
        if(!isValidUser(usr)){
            
            Map<Id, Id> conDocLinkIdByConDocId = getConDocLinkIdByConDocId(contentDocumentLinks);
            Map<Id, Boolean> validityByConDocLinkId = getValidityByConDocLinkId(conDocLinkIdByConDocId);
            
            Map<id, Set<Id>> oppUserListByConDoc = getoppUserListByConDoc(contentDocumentLinks);
            
            Map<Id, Id> conDocIdBySpecId = getSpecificationInfos(contentDocumentLinks);
        
            Map<id, Specification__c> specificationById = getSpecification(conDocIdBySpecId.values());
            Map<id, Boolean> conDocIdByFileValidOwner = getSpecificationAccountValidity(conDocIdBySpecId, specificationById);
            
            for(ContentDocumentLink contDocLink: contentDocumentLinks){
                if(validityByConDocLinkId.containsKey(contDocLink.Id) && validityByConDocLinkId.get(contDocLink.Id)){
                    if(oppUserListByConDoc.containsKey(contDocLink.Id)){
                        Set<Id> oppTemUsers = oppUserListByConDoc.get(contDocLink.Id);
                        System.debug('@@## oppTemUsers ' + oppTemUsers + ' ' + userinfo.getUserId());
                        if(!oppTemUsers.contains(userinfo.getUserId())){
                            
                            if(conDocIdByFileValidOwner.containsKey(contDocLink.Id)){
                                if(conDocIdByFileValidOwner.get(contDocLink.Id)){
                                    contDocLink.addError(System.Label.GGSpecificationDelPermissonErrMsg);
                                    isErrorAdded = true;
                                }
                            }else{
                            }
                            
                        }
                    }else{
                        contDocLink.addError(System.Label.GGSpecificationDelPermissonErrMsg);
                        isErrorAdded = true;
                    }
                    
                }
                
            }
        }
        
        if(!isErrorAdded){
            checkAndValidateForDelete(contentDocumentLinks);
        }
        createFileNotification(contentDocumentLinks);
    }
    
    //Function to create Events Recrods
    private static void createFileNotification(List<ContentDocumentLink> contentDocumentLinks){
        Set<Id> linkedEntityIds = new Set<Id>();
        List<File_Notification__e> notificationRecord = new List<File_Notification__e>();
        
        for(ContentDocumentLink conDocLink: contentDocumentLinks){
            if(!linkedEntityIds.contains(conDocLink.LinkedEntityId)){
                linkedEntityIds.add(conDocLink.LinkedEntityId);
                notificationRecord.add(getNotificationInstance(conDocLink));
            }
        }
        
        if(notificationRecord.size() > 0)
            List<Database.SaveResult> sr = EventBus.publish(notificationRecord);
        
    }
    
    //functio to create paltform Event.
    private static File_Notification__e getNotificationInstance(ContentDocumentLink conDocLink){
        return new File_Notification__e(
            LinkentityId__c = conDocLink.LinkedEntityId
        );
    }
    public static void checkAndValidateForDelete(List<ContentDocumentLink> contentDocumentLinks){
        Map<Id, Id> conDocIdBySpecId = getSpecificationInfos(contentDocumentLinks);
        
        Map<id, Specification__c> specificationById = getSpecification(conDocIdBySpecId.values());
        
        Map<id, Boolean> conDocIdByFileValidStatus = getSpecificationStatusValidity(conDocIdBySpecId, specificationById);
        
        
        for(ContentDocumentLink contDocLink: contentDocumentLinks){
            if(conDocIdByFileValidStatus.containsKey(contDocLink.Id)){
                if(conDocIdByFileValidStatus.get(contDocLink.Id)){
                    contDocLink.addError(System.Label.GGSpecificationStatusRectrictionErrorMsg);
                }
            }
        }
    }
    
    //Get Account related to the specification.
    private static Map<id, Set<Id>> getoppUserListByConDoc(List<ContentDocumentLink> contentDocumentLinks){
        Map<Id, Id> conDocIdBySpecId = getSpecificationInfos(contentDocumentLinks);
        Map<id, Id> oppIdBySpecId = new Map<id, Id>();
        Map<id, Id> oppIdByconDocId = new Map<id, Id>();
        Map<id, Set<Id>> oppUserListByOppId = new Map<id, Set<Id>>();
        Map<id, Set<Id>> oppUserListByConDoc = new Map<id, Set<Id>>();
        
        //Get Account Ids related to the specification record.
        for(Specification__c specs: [SELECT Id, Opportunity__c 
                                        FROM Specification__c
                                        WHERE Id IN: conDocIdBySpecId.values()
                                        AND Opportunity__c != NULL]){
            oppIdBySpecId.put(specs.Id, specs.Opportunity__c);
        }
        
        System.debug('@@## oppIdBySpecId ' + oppIdBySpecId);
        
        //Map the ContentDocument with the specification's Account
        for(Id conDocId: conDocIdBySpecId.keySet()){
            Id specId = conDocIdBySpecId.get(conDocId);
            if(oppIdBySpecId.containsKey(specId)){
                oppIdByconDocId.put(conDocId, oppIdBySpecId.get(specId));
            }
            
        }
        System.debug('@@## oppIdByconDocId ' + oppIdByconDocId);
        
        if(oppIdBySpecId.size() > 0){
            //Get the opportunity Memebers related to an account.
            for(OpportunityTeamMember oppTeamMember: [SELECT Id, UserId, OpportunityId
                                                        FROM OpportunityTeamMember 
                                                        WHERE OpportunityId =: oppIdBySpecId.values()]){
                Set<Id> oppTemUsers = new Set<Id>();
                if(oppUserListByOppId.containsKey(oppTeamMember.OpportunityId)){
                    oppTemUsers = oppUserListByOppId.get(oppTeamMember.OpportunityId);
                }
                oppTemUsers.add(oppTeamMember.UserId);
                oppUserListByOppId.put(oppTeamMember.OpportunityId, oppTemUsers);
            }
            
            System.debug('@@## oppUserListByOppId ' + oppUserListByOppId);
            //Map the opportunity Team Members with the ContentDocuemnt.
            for(Id conDocId: oppIdByconDocId.keySet()){
                Id opportunityId = oppIdByconDocId.get(conDocId);
                if(oppUserListByOppId.containsKey(opportunityId)){
                    oppUserListByConDoc.put(conDocId, oppUserListByOppId.get(opportunityId));
                }
            }
        }
        System.debug('@@## oppUserListByConDoc ' + oppUserListByConDoc);
        return oppUserListByConDoc;
    }
    
    
    private static Map<Id, Id> getSpecificationInfos(List<ContentDocumentLink> contentDocumentLinks){
        Map<Id, Id> conDocLinkIdBySpecId = new Map<Id, Id>();
        for(ContentDocumentLink contentDocLink: contentDocumentLinks){
            Schema.SObjectType sObjectType = contentDocLink.LinkedEntityId.getSObjectType();
            if(Schema.Specification__c.SObjectType == sObjectType){
                conDocLinkIdBySpecId.put(contentDocLink.Id, contentDocLink.LinkedEntityId);
            }
        } 
        System.debug('@@## conDocLinkIdBySpecId ' + conDocLinkIdBySpecId);
        return conDocLinkIdBySpecId;
    }
    
    
    //Function to get content Document Link by Content Document Id.
    private static Map<Id, Id> getConDocLinkIdByConDocId(List<ContentDocumentLink> contentDocumentLinks){
        Map<Id, Id> conDocLinkIdByConDocId = new Map<Id, Id>();
        for(ContentDocumentLink contentDocLink: contentDocumentLinks){
            Schema.SObjectType sObjectType = contentDocLink.LinkedEntityId.getSObjectType();
            //if(Schema.Specification__c.SObjectType == sObjectType){
                conDocLinkIdByConDocId.put(contentDocLink.Id, contentDocLink.ContentDocumentId);
            //}
        } 
        System.debug('@@## conDocLinkIdByConDocId ' + conDocLinkIdByConDocId);
        return conDocLinkIdByConDocId;
    }
    
    
    //Private static void get content Document and Owner.
    private static Map<Id, Boolean> getvalidityByConDocLinkId(Map<Id, Id> conDocLinkIdByConDocId){
        Map<Id, Boolean> validityByConDocLinkId = new Map<Id, Boolean>();
        
        Set<id> dontDelDocIds = new Set<id>();
        for(ContentDocumentLink conDocLink: [SELECT Id, ContentDocumentId 
                                        FROM ContentDocumentLink 
                                        WHERE ContentDocumentId IN: conDocLinkIdByConDocId.values()
                                        AND LinkedEntityId =: userinfo.getUserId()]){
            dontDelDocIds.add(conDocLink.ContentDocumentId);
        }        
                                
        for(Id conDocLinkId: conDocLinkIdByConDocId.keySet()){
            Id docId = conDocLinkIdByConDocId.get(conDocLinkId);
            validityByConDocLinkId.put(conDocLinkId, !dontDelDocIds.contains(docId));
        }
        
        System.debug('@@## conDocLinkIdByConDocId ' + conDocLinkIdByConDocId);
        System.debug('@@## dontDelDocIds ' + dontDelDocIds);
        System.debug('@@## validityByConDocLinkId ' + validityByConDocLinkId);
        return validityByConDocLinkId;
    }
    
    //Function to get the Document vs Is Valid or not
    private static Map<id, Boolean> getSpecificationStatusValidity(Map<Id, Id> conDocLinkIdBySpecId, Map<id, Specification__c> specificationById){
        Map<id, Boolean> conDocLinkIdByFileValid = new Map<id, Boolean>();
        try{
            String restrictedStatus = System.Label.GGStatusRestrictedtoMakeChangesInFile;
            List<String> statusList = restrictedStatus.split(';');
            Set<String> statusListSet = new Set<String>(); 
            for(String status: statusList){
                statusListSet.add(status);
            }
            
            System.debug('@@## specificationById ' + specificationById);
            
            for(Id conDocLinkId: conDocLinkIdBySpecId.keySet()){
                String SpecId = conDocLinkIdBySpecId.get(conDocLinkId);
                if(specificationById.containsKey(SpecId)){
                    Specification__c checkSpecification = specificationById.get(SpecId);
                    conDocLinkIdByFileValid.put(conDocLinkId, statusListSet.contains(checkSpecification.status__c));
                }
            }
            
        }catch(Exception e){}
        System.debug('@@## getSpecificationStatusValidity ' + conDocLinkIdByFileValid);
        return conDocLinkIdByFileValid;
    }
    
    //Function to check specification by Account Owner
    private static Map<id, Boolean> getSpecificationAccountValidity(Map<Id, Id> conDocLinkIdBySpecId, Map<id, Specification__c> specificationById){
        Map<id, Boolean> conDocLinkIdByFileValid = new Map<id, Boolean>();
        try{
            for(Id conDocLinkId: conDocLinkIdBySpecId.keySet()){
                String SpecId = conDocLinkIdBySpecId.get(conDocLinkId);
                if(specificationById.containsKey(SpecId)){
                    Specification__c checkSpecification = specificationById.get(SpecId);
                    conDocLinkIdByFileValid.put(conDocLinkId, 
                            !(checkSpecification.account__r.OwnerId == userInfo.getUserId() 
                            || checkSpecification.Application_Engineer__c == userInfo.getUserId()));
                }else{
                    conDocLinkIdByFileValid.put(conDocLinkId, true);
                }
            }
            
        }catch(Exception e){}
        System.debug('@@## getSpecificationAccountValidity ' + conDocLinkIdByFileValid);
        return conDocLinkIdByFileValid;
    }
    
    //Function get the specification 
    private static Map<id, Specification__c> getSpecification(List<id> specificationIds){
        String restrictedStatus = System.Label.GGStatusRestrictedtoMakeChangesInFile;
        List<String> statusList = restrictedStatus.split(';');
        System.debug('@@## statusList ' + statusList);
        System.debug('@@## Userinfo. ' + userInfo.getUserId());
        Map<id, Specification__c> 
            specificationById = new Map<id, Specification__c>([SELECT Id, status__c , account__r.OwnerId, opportunity__r.Account.ae__r.Id
                                                                FROM Specification__c 
                                                                WHERE Id IN: specificationIds
                                                                AND (status__c IN: statusList
                                                                OR account__r.OwnerId =: userInfo.getUserId()
                                                                OR Application_Engineer__c =: userInfo.getuserId())]);
        return specificationById;
    }
    
    //Function to check either the user belongs to valid profile or not.
    private static boolean checkValidUser(User usr){
        try{
            Set<String> validProfileNames = getValidprofileName();
            System.debug('@@## checkValidUser ' + usr);
            return validProfileNames.contains(usr.Profile.Name);
        }catch(Exception e){}
        return false;
        
    }
    
    private static User getCurrentuser(){
        return [SELECT id, Profile.Name FROM User 
                WHERE Id =: Userinfo.getUserId()
                LIMIT 1];
    }
    
    private static Set<String> getValidprofileName(){
        String profileNamesStr = System.Label.GGUserAllowedtoMakeChangesInFile;
        List<String> profileNames = profileNamesStr.split(';');
        Set<String> validProfileNames = new Set<String>();
        for(String profileName: profileNames){
            validProfileNames.add(profileName);
        }
        return validProfileNames;
    }
    
    //Function to check either the user belongs to valid Permission Set.
    private static boolean checkPermissionSet(){
        try{
            String permissionSetName = System.Label.GGSpecificationPermissionSetName;
            PermissionSetAssignment permissionSetAssign = [SELECT Id, PermissionSetId, AssigneeId
                                                           FROM PermissionSetAssignment
                                                           WHERE PermissionSet.label =: permissionSetName
                                                           AND AssigneeId =: Userinfo.getUserId()];
            System.debug('@@## checkPermission ' + permissionSetAssign);
            return true;
        }catch(Exception e){}
        return false;
    }
}