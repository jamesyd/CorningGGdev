public without sharing class HomePageOpportunityController {

    @AuraEnabled
    public static List<Opportunity> getOpportunityRecords() {
        
        string uId = UserInfo.getUserId();
        
        List<Opportunity> oList = new List<Opportunity>([Select id, amount, age__c, estimatedLaunchDate__c, isClosed, name, stagename, closeDate from Opportunity 
        Where (RecordTypeId = '0121J000000U1cZ' or RecordTypeId = '012o0000000U07c' or RecordTypeId = '012o0000000U07X') and closeDate <= TODAY and isClosed = False and ownerId =: uId ORDER BY closeDate]);
    
        system.debug('***' + oList);
    
        return oList;
    }
    
}