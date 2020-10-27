/*
    Name        : GGSpecificationFileController
    Author      : 
    Description : This is a controller class for lightning component GGSpecificationFileComponent.
*/

public without sharing class GGSpecificationFileController{
    
    
    @AuraEnabled
    public static ResponseHandler getFilesDetails(String specificationId){
        //Get the files details.
        List<contentDocument> cdocList = getContentDocuments(specificationId);
        if(cdocList != NULL && cdocList.size() > 0){
            return new ResponseHandler(true, cdocList);
        }
        return new ResponseHandler(false, 'No Details Found.');
    }
    
    
    //Function to delete the Content Doucument and Content Document link.
    @AuraEnabled
    public static ResponseHandler deleteSpecificationFiles(List<String> documentIds, String specId){
        try{
            String filesName = getFeedItemName(documentIds);
            
            //Set<String> toDeleteDocs = getToDeleteDocuments(documentIds);
            DELETE [SELECT ID from ContentDocumentLink 
                      WHERE ContentDocumentId IN: documentIds 
                      AND LinkedEntityId =: specId];
            
            Set<String> toDeleteDocs = getToDeleteDocuments(documentIds);
            DELETE [SELECT Id from ContentDocument WHERE ID IN: toDeleteDocs];
            
            
            if(!test.isRunningTest()){
                 ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                     specId, filesName); 
            } 
            return new ResponseHandler(true);
        }catch(System.DmlException e){
            String errorMessage = '';
            for (Integer i = 0; i < e.getNumDml(); i++) {
                errorMessage += e.getDmlMessage(i); 
            }
            return new ResponseHandler(false, errorMessage);
        }
        
    }
    
    
    //Check is there is any need to delete the document or not?
    private static Set<String> getToDeleteDocuments(List<String> documentIds){
        Set<String> dndDocumentIds = new Set<String>();
        Set<String> toDeleteDocs = new Set<String>();
        for(ContentDocumentLink contentDocLink: [SELECT ID, ContentDocumentId 
                                                  FROM ContentDocumentLink 
                                                  WHERE ContentDocumentId IN: documentIds
                                                  AND LinkedEntityId !=: userInfo.getUserId()]){
            dndDocumentIds.add(contentDocLink.ContentDocumentId);
        }
        
        system.debug('@@## dndDocumentIds ' + dndDocumentIds);
        for(String docIds: documentIds){
            if(!dndDocumentIds.contains(docIds)){
                toDeleteDocs.add(docIds);
            }
        }
        return toDeleteDocs;
    }
    
    
    //Create Feed Item 
    private static String getFeedItemName(List<String> documentIds){
        String fileName = '';
        fileName += 'Deleted ' + documentIds.size() + ' File(s): ';
        for(ContentDocument conDoc: [SELECT ID, Title, FileExtension 
                                      FROM ContentDocument
                                      WHERE ID IN: documentIds]){
            fileName += conDoc.Title + '.' +conDoc.FileExtension +', ';
        }
        return fileName.substring(0, fileName.length()-2);
        
        
    }
    
    
    //Function to get the documentIds so that we can get the document detials from the server.
    private static List<contentDocument> getContentDocuments(String specificationId){
        Set<id> documentIds = new Set<id>();
        try{
            for(ContentDocumentLink cDocLink: [SELECT Id, LinkedEntityId, ContentDocumentId 
                                                 FROM ContentDocumentLink 
                                                 WHERE LinkedEntityId =: specificationId]){
                documentIds.add(cDocLink.ContentDocumentId);
            }
        }catch(Exception e){}
        return getContentDocumentById(documentIds);
    }
    
    
    //Function get the uploaded document details.
    private static List<contentDocument> getContentDocumentById(set<id> documentIds){
        try{
            return [SELECT Id, Title, ParentId, Description, 
                     ContentSize, OwnerId, Owner.Name, LastModifiedDate
                     FROM ContentDocument 
                     WHERE Id IN: documentIds
                     order by lastmodifiedDate DESC]; 
        }catch(Exception e){
        }
        return NULL;
    }
    
    public class ResponseHandler{
        @AuraEnabled public boolean isSuccess{get;set;}
        @AuraEnabled public String errorMessage{get;set;}
        @AuraEnabled public List<FileWrapper> filesList{get;set;}
        
        public ResponseHandler(boolean isSuccess, List<contentDocument> filesList){
            this.isSuccess = isSuccess;
            List<FileWrapper> fileWrapperList = new List<FileWrapper>();
            for(contentDocument cDoc: filesList){
                fileWrapperList.add(new FileWrapper(cDoc));
            }
            this.filesList = fileWrapperList; 
        }
        
        public ResponseHandler(boolean isSuccess, String errorMessage){
            this.isSuccess = isSuccess; 
            this.errorMessage = errorMessage;
        }
        
        public ResponseHandler(boolean isSuccess){
            this.isSuccess = isSuccess; 
        }
    }
    
    public class FileWrapper{
        @AuraEnabled public String recordId{get;set;}
        @AuraEnabled public String title{get;set;}
        @Auraenabled public String ownername{get;set;}
        @Auraenabled public String size{get;set;}
        @AuraEnabled public DateTime lastModifiedDate{get;set;}
        @AuraEnabled public String documentViewLink{get;set;}
        @AuraEnabled public String ownerLink{get;set;}
        
        public FileWrapper(ContentDocument cDoc){
            this.recordId = cDoc.Id;
            this.title = cDoc.title;
            this.ownername = cDoc.Owner.Name;
            this.lastmodifiedDate = cDoc.LastModifiedDate;
            this.size = (cDoc.ContentSize/1024) + 'KB';
            this.documentViewLink = URL.getSalesforceBaseUrl().toExternalForm() + '/' + cDoc.id;
            this.ownerLink = URL.getSalesforceBaseUrl().toExternalForm() + '/' + cDoc.OwnerId;
        }
    }
}