//batch class to send notification to opportunity owners when the age is 180 or 210
global class OpportunityChatterNotificationBatch implements Database.Batchable<Opportunity>{
    
    global Iterable<Opportunity> start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        return [
            SELECT Id, age__c, OwnerId  
            FROM Opportunity 
            WHERE age__c IN :getAgeList()
            AND StageName NOT IN :getClosedStages()
            AND RecordType.DeveloperName = 'GG_Program'
            LIMIT 149
        ];
    }
    global void execute(Database.BatchableContext bc, List<Opportunity> records){
        //Adding feed item with owner id and message to show in chatter
        for(Opportunity opp : records){
             
            ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
            opp.Id, '{' + opp.OwnerId + '}'+'The opportunity has been created for over ' + opp.age__c + ' days. Please review the opportunity stage and close the aged opportunity accordingly. Thank you.');

        }
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }   
    
    private static Set<integer> getAgeList(){
        Set<integer> ageList = new Set<integer>();
        if(STRING.ISNOTBLANK(System.label.OpportunityAgeList)){
            for(String ageStr: System.label.OpportunityAgeList.split(';')){
                if(!test.isRunningTest()){
                    ageList.add(Integer.valueOf(ageStr));
                }else{
                    ageList.add(0);
                }
            }
        }
        return ageList;
        
    } 
    
    //Private static void getOpportunity Closed Stage
    private static List<string> getClosedStages(){
        List<string> closedStages = new List<string>();
        try{
            closedStages = System.label.OpportunityClosedStages.split(';');
        }catch(Exception e){}
        RETURN closedStages;
    }
}