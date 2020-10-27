///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 2/13/2017 ***///
///*** Controller class used in the specification clone custom Lightning component. ***///
//public with sharing class SpecificationCloneController { // *an
public class SpecificationCloneController { // *an
    static Utilities Utils = new Utilities();
    
    public class CloneResultWrapper{
        @AuraEnabled
        public boolean success {get; set;}
        @AuraEnabled
        public string errorMessage { get; set;}
        @AuraEnabled
        public string clonedSpecId { get; set;}
        
        public CloneResultWrapper(){
            success = true;
        }
    }
    
    
    //CloneSpec function clones the origSpecId specification - with/without attachments and returns the id of the 
    //cloned specification record.
    @AuraEnabled
    public static CloneResultWrapper cloneSpec(Id origSpecId, String parentOptyId, boolean copyAttachments, String cloneReason) {
        Id clonedSpecId = origSpecId;
        
        CloneResultWrapper res = new CloneResultWrapper();

        
        //Create set of fields we do NOT want to clone and add them to exceptions set
        set<string> exceptions = new set<string>();
        list<Schema.FieldSetMember> nonCloneFields = Schema.SObjectType.Specification__c.fieldSets.Exclude_From_Clone.getFields();
        list<Schema.DescribeFieldResult> dfrList = convertFields(nonCloneFields, Specification__c.getSObjectType());

        for (Schema.DescribeFieldResult rsField : dfrList) {
            exceptions.add(rsField.getName());
        }
        
        //Where clause for clone query
        string myWhere = 'id=\'' + origSpecId + '\'';
        //get the SOQL for the fields we will copy
        string mySOQL = utils.getCreatableFieldsSOQL('Specification__c', exceptions, myWhere, copyAttachments); 
        
        /* CLONE */
        Specification__c recToClone = database.query(mySOQL);
        Specification__c cloned = recToClone.clone(false,true);
        
        //set the Original Spec value
        cloned.parentSpecification__c = origSpecId;
        if (cloned.originalSpecification__c == null){
            cloned.originalSpecification__c = origSpecId;
        }
        
        string errorMsg = label.GGSpecCloneEditError;//'Unable to clone. Current user doesn\'t have edit access to the opportunity.';
        //set the new parent opportunity id
        if (parentOptyId != null && parentOptyId.length() > 0 && parentOptyId != cloned.Opportunity__c){
            
            cloned.Opportunity__c = parentOptyId;
            errorMsg = label.GGSpecCloneReparentError;
            //if cloned to different opportunity, reset parent spec, original spec and version #
            cloned.parentSpecification__c = null;
            cloned.originalSpecification__c = null;
            cloned.version__c = 1;
        }else{
            parentOptyId = cloned.Opportunity__c;
            
            Integer maxV = Integer.valueOf([SELECT Max(version__c) maxV FROM Specification__c WHERE OriginalSpecification__c = :cloned.originalSpecification__c][0].get('maxV'));
            if (maxV == null || maxV == 0){
                maxV = 1;
            }
            
            //increment the version # if cloned to the same opportunity
            cloned.version__c = maxV + 1;//cloned.version__c + 1;
        }
        
        Id uId = UserInfo.getUserId();            
        //does the user have edit access to parentOptyId opportunity?
        UserRecordAccess access = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :uId AND RecordId = :parentOptyId LIMIT 1];      //or Record IN [list of IDs]
        if (access.HasEditAccess == false){
                res.errorMessage = errorMsg;
                res.success = false;
                return res;
        }
        
        String app = cloned.application__c;            
        //does the cloned spec application = the parent opportunity application?
        String oApp = [SELECT application__c FROM opportunity WHERE id = :parentOptyId LIMIT 1].application__c;

        if (app != oApp && app != Null) {
                res.errorMessage = 'That specification application does not match the application on the Opportunity.';
                res.success = false;
                return res;
        }
        
        
        cloned.cloneReason__c = cloneReason;
        
        //figure out new RecordType and set it.
        
        string recordTypeName =  utils.getRecordTypeName(recToClone.RecordTypeId);
        switch on recordTypeName {
           when 'Concore - Submitted', 'Concore - Final' {
               cloned.RecordTypeId = utils.getRecordTypeID('Specification__c', 'Concore').Id;
           }
           when 'Parts - Submitted', 'Parts - Final' {
               cloned.RecordTypeId = utils.getRecordTypeID('Specification__c', 'Parts').Id;
           }
           when 'Parts - RFI Submitted', 'Parts - RFI Final' {
               cloned.RecordTypeId = utils.getRecordTypeID('Specification__c', 'Parts - RFI').Id;
           }
           when 'Raw Glass - Submitted', 'Raw Glass - Final', 'Raw Glass - Inventory Submitted', 'Raw Glass - Inventory Final' {
               cloned.RecordTypeId = utils.getRecordTypeID('Specification__c', 'Raw Glass').Id;
           }
           when else {
               cloned.RecordTypeId = recToClone.RecordTypeId;
           }
        }
        
        insert cloned;
        clonedSpecId = cloned.id;
        /* CLONE */
        
        //Process Content records - formerly called Attachments
        if (copyAttachments == true) {
            set<string> cdIdSet = new set<string>();
            
            map<string,Id> newCDMap = new map<string,Id>();
            list<ContentVersion> newCVList = new list<ContentVersion>();
            
            list<ContentDocumentLink> linkList = new list<ContentDocumentLink>();
            list<ContentDocumentLink> newLinkList = new list<ContentDocumentLink>();

            // an - 2/16 lists and sets to clean description
            set<string> clonedCdIdSet = new set<string>();
            list<ContentDocumentLink> clonedLinkList = new list<ContentDocumentLink>();
            list<ContentVersion> updateClonedCVList = new list<ContentVersion>(); 
            
            try{
                //get Docs that are Linked to our Spec
                linkList =  [SELECT Visibility, ShareType, LinkedEntityId, ContentDocumentId, ContentDocument.Title, ContentDocument.OwnerId
                            FROM ContentDocumentLink 
                            WHERE LinkedEntityId=:origSpecId
                            //only content owned by the user can be cloned
                            //AND contentDocument.OwnerId = :uId // an
                            ];
            
                //Load set of Doc Ids
                for (ContentDocumentLink link : linkList) {
                    system.debug('link.Visibility: ' + link.Visibility + ' link.ShareType: ' + link.ShareType +' link.ContentDocumentId: ' + link.ContentDocumentId +  ' contentDocument.OwnerId: ' + link.contentDocument.OwnerId + ' userid: ' +  userInfo.getUserId());
                    cdIdSet.add(link.ContentDocumentId);
                }
            
                if(cdIdSet.size() > 0) {
                    //Get Version records for our Docs and Clone them
                    //Since we are NOT including the ContentDocumentId in the Clone, 
                    //we will end up with Version = 1 and a new Content Document record for each document
                    for (ContentVersion cv : [SELECT Id, VersionData, Title, SharingOption, ReasonForChange, 
                                                PublishStatus, PathOnClient, OwnerId, Origin, IsMajorVersion, IsLatest, 
                                                FileType, FileExtension, Description, CreatedDate, 
                                                ContentSize, Checksum, ContentDocumentId
                                            FROM ContentVersion c
                                            WHERE ContentDocumentId IN :cdIdSet]) {
                        //Since we are NOT including the ContentDocumentId in the Clone, 
                        //we will end up with ContentVersion = 1 and a new ContentDocument record for each document
                        ContentVersion newCV = cv.clone(false, true);
                        newCV.ContentDocumentId = Null;                        
                        newCV.ReasonForChange = 'Cloned from file: ' + cv.ContentDocumentId; // store the original contentdocumentId    
                        newCV.isMajorVersion = true;
                        newCV.OwnerId = uId; // *an
                        newCVList.add(newCV);
                    }   
                    
                    if(newCVList.size() > 0){
                        insert newCVList;
                    }
                    
                    for (ContentVersion newCV : [SELECT Id, Title, ReasonForChange, VersionNumber, ContentDocumentId, Description
                                                    FROM ContentVersion
                                                    WHERE Id IN :newCVList]) {
                        newCDMap.put(newCV.ReasonForChange.substringAfterLast(' '), newCV.ContentDocumentId);
                    }
                    
                    //Create new Link record from old link records
                    //Change LinkedEntity to our new Spec
                    //Change ContentDocument to our newly generated ContentDocument record
                    for (ContentDocumentLink link : linkList) {
                        ContentDocumentLink newCDL = new ContentDocumentLink();
                        newCDL.Visibility = link.Visibility;
                        newCDL.ShareType = link.shareType;
                        newCDL.LinkedEntityId = clonedSpecId;
                        //newCDL.ContentDocumentId = newCDMap.get(link.ContentDocument.Title); // an 2/16 removed
                        newCDL.ContentDocumentId = newCDMap.get(link.ContentDocumentId); // an 2/16
                        newLinkList.add(newCDL);
                    }
                
                    if(newLinkList.size() > 0){
                        upsert newLinkList;
                    }                                        
                }
            }
            catch(Exception e){
                throw new AuraHandledException(e.getmessage());
            }
        }       
        res.clonedSpecId = clonedSpecId;
        return res;
    }
   
   //This code converts Schema.FieldSetMember records to Schema.DescribeFieldResult records
   //From Adrian Larson http://www.apexlarson.com/
    public static List<Schema.DescribeFieldResult> convertFields(List<Schema.FieldSetMember> members, Schema.SObjectType theType)
    {
        List<Schema.DescribeFieldResult> describes = new List<Schema.DescribeFieldResult>();
        for (Schema.FieldSetMember member : members)
        {
            describes.add(new Parser(member, theType).getDFR());
        }
        return describes;
    }

    private class Parser 
    {
        list<string> path = new list<string>();
        Schema.SObjectType theType;
        
        public Parser(Schema.FieldSetMember member, Schema.SObjectType theType)
        {           
            this.path.add(member.getFieldPath());
            this.theType = theType;
        }
    
        public Schema.DescribeFieldResult getDFR()
        {
            return describe(path[0]);
        }
    
    
        public Schema.DescribeFieldResult describe(String field) 
        {
            return theType.getDescribe().fields.getMap().get(field).getDescribe();
        }
    }    
}