/*
    Name        : AccountOwnerChangeController
    Descriptino : This is the controller class that tranfer the new Account Owner to the related Records 
                  i.e. Account contracts, Price and Files.
*/

public without sharing class AccountOwnerChangeController{
    @future
    public static void updatePriceAndAccContractOwner(Map<Id,Id> ownerByAccountId, Set<Id> contractManagerIds){
        List<Price__c> priceListToUpdate = getPriceList(ownerByAccountId);
        
        Map<Id, AccountContract__c> accountContractById = getAccountContractById(ownerByAccountId);
        
        
        List<ContentDocument> contentDocumentList = getAccountContractDocument(accountContractById);
        
        try{
            //Set EmailHeader.triggerUserEmail to false, this disables send Email notification 
            if(priceListToUpdate.size() > 0){
                database.update(priceListToUpdate);
            }
            
            //UPDATE the contract Owner to the new Account Owner.
            if(accountContractById.size() > 0){
                database.update(accountContractById.values());
            }
            
            //CREATE Feed Items.
            createFeedItems(ownerByAccountId, contractManagerIds);
            
            
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        
        try{
            
            //UPDATE the files owner.
            if(contentDocumentList.size() > 0){
                database.update(contentDocumentList);
            }
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    //Get List of Price which is related to the Account.
    private static List<Price__c> getPriceList(Map<Id,Id> ownerByAccountId){
        List<Price__c> priceListToUpdate = new List<Price__c>();
        for(Price__c price : [SELECT Id, Account__c FROM Price__c 
                               WHERE Account__c IN :ownerByAccountId.keySet() 
                               AND IsMTO__c = false]){
            Database.DMLOptions dmlo = new Database.DMLOptions();
            dmlo.EmailHeader.triggerUserEmail = false;
            dmlo.EmailHeader.triggerAutoResponseEmail = false;
            dmlo.EmailHeader.triggerOtherEmail = false;
            price.OwnerId = ownerByAccountId.get(price.Account__c);
            price.setOptions(dmlo);
            priceListToUpdate.add(price);
        }
        return priceListToUpdate;
    }
    
    
    //Function to get the list of Account Contract Records that are relatd to the particular Account.
    private static Map<Id, AccountContract__c> getAccountContractById(Map<Id,Id> ownerByAccountId){
        Map<Id, AccountContract__c> accountContractById = new Map<Id, AccountContract__c>();
        
        for(AccountContract__c aContract : [SELECT Id, Account__c 
                                            FROM AccountContract__c 
                                            WHERE Account__c IN :ownerByAccountId.keySet()]){
            aContract.OwnerId = ownerByAccountId.get(aContract.Account__c);
            
            Database.DMLOptions dmlo = new Database.DMLOptions();
            dmlo.EmailHeader.triggerUserEmail = false;
            dmlo.EmailHeader.triggerAutoResponseEmail = false;
            dmlo.EmailHeader.triggerOtherEmail = false;
            aContract.setOptions(dmlo);
            accountContractById.put(aContract.Id, aContract);
        }
        return accountContractById;
    }
    
    //Function to get the ContentDocument attched to the any Account Contract Record.
    private static List<ContentDocument> getAccountContractDocument(Map<Id, AccountContract__c> accountContractById){
        List<ContentDocument> contentDocumentList = new List<ContentDocument>();
        try{
            for(ContentDocumentLink contentDocumentLink: [SELECT Id, LinkedEntityId, ContentDocumentId 
                                                            FROM ContentDocumentLink
                                                            WHERE LinkedEntityId IN: accountContractById.keySet()]){
                ContentDocument cDocument = new contentDocument();
                cDocument.Id = contentDocumentLink.ContentDocumentId;
                cDocument.OwnerId = accountContractById.get(contentDocumentLink.LinkedEntityId).OwnerId;
                contentDocumentList.add(cDocument);
            }
        }catch(Exception e){
        }
        
        return contentDocumentList;
    }
    
    //Function to post a chatter Feed Item
    private static void postChatterFeed(Set<Id> mentionedIds, String accounId, String newOwnerID){
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        //ADD MEMBERS
        for(Id mentionedId: mentionedIds){
            mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            mentionSegmentInput.id = mentionedId;
            messageBodyInput.messageSegments.add(mentionSegmentInput);
            
            textSegmentInput = new ConnectApi.TextSegmentInput();
            textSegmentInput.text = ' ';
            messageBodyInput.messageSegments.add(textSegmentInput);
        }
        //ADD TEXT
        textSegmentInput = new ConnectApi.TextSegmentInput();
        textSegmentInput.text = SYSTEM.LABEL.Chatter_Owner_Change_Msg + ' ';
        messageBodyInput.messageSegments.add(textSegmentInput);
        
        //ADD NEW OWNER
        mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        mentionSegmentInput.id = newOwnerID;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        
        
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = accounId;
        
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
    }
    
    //Create feed Item for each Account.
    private static void createFeedItems(Map<Id,Id> ownerByAccountId, Set<Id> contractManagerIds){
        for(Id accountId: ownerByAccountId.keySet()){
            if(!contractManagerIds.contains(Userinfo.getUserId())){
                Id ownerId = ownerByAccountId.get(accountId);
                postChatterFeed(contractManagerIds, accountId, ownerId);
            }
        }
    }
}