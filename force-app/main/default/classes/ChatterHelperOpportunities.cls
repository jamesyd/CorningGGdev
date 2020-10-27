public without sharing class ChatterHelperOpportunities {

    public static void atMentionEdits(List<Opportunity> newList, Map<ID, Opportunity> oldMap) {
    
        // ConnectApi methods are not supported in data siloed tests.
        // Please use @IsTest(SeeAllData=true). Class.ConnectApi.ChatterFeeds.postFeedElement
        // @IsTest(SeeAllData=true)
    
        for (Opportunity o : newList) { 
        
            if (o.recordtypeid == '0121J000000U1cZQAS') { // GG Program
    
                // @mention the account opportunity account owner ** Forecast Created
                If (o.createForecast__c == TRUE &&  oldMap.get(o.Id).createForecast__c == FALSE) {            
                    ID accountRecipient = o.accountOwnerId__c;
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                    o.id, 'Default Part Forecast has been created. {' + accountRecipient + '}');
                }
                
                // @mention the account opportunity account owner ** TRANSFER
                if (o.accountid != oldMap.get(o.Id).accountid) {
                    ID accountRecipient = o.accountOwnerId__c;
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                        o.id, 'An opportunity has been transferred. {' + accountRecipient + '}');
                }

            }            
        }
    }

    public static void atMentionNew(List<Opportunity> newList) {
    
        for (Opportunity o : newList) { 
                            
            // @mention the account opportunity account owner ** NEW   
            // time condition to prevent exeisting opportunities from @mention                                       
            If (o.newpost__c == FALSE && o.createddate >= Datetime.now().addMinutes(-1) && o.recordtypeid == '0121J000000U1cZQAS' ) {                                                  
                ID accountRecipient = o.accountOwnerId__c;
                ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                    o.id, 'An opportunity has been added. {' + accountRecipient + '}');
                o.newPost__c = TRUE;
            }           
                 
        }
    }

}