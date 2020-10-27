public without sharing class ContractController {

    @AuraEnabled
    public static List<AccountContract__c> getContractRecords(string accId) {
    
        Set <Id> aIdSet = new Set <Id>();
        
        List <Account> records = new List <Account>([Select Parent.Parent.Parent.Parent.Parent.ParentId, 
             Parent.Parent.Parent.Parent.ParentId,
             Parent.Parent.Parent.ParentId,
             Parent.Parent.ParentId,
             Parent.ParentId,
             ParentId From Account Where Id =: accId LIMIT 1]);
         
        for (Account a : records) {
            aIdSet.add(a.id);
            aIdSet.add(a.ParentId);
            aIdSet.add(a.Parent.ParentId);
            aIdSet.add(a.Parent.Parent.ParentId);
            aIdSet.add(a.Parent.Parent.Parent.ParentId);
            aIdSet.add(a.Parent.Parent.Parent.Parent.ParentId);
            aIdSet.add(a.Parent.Parent.Parent.Parent.Parent.ParentId);
        }
        
        List<ID> aIdList = new List<ID>(aIdSet);
        
        return new List<AccountContract__c>([Select id, isEvergreen__c, isActive__c, accountName__c, type__c, expirationDate__c from AccountContract__c 
        Where account__c =: aIdList LIMIT 100]);
    }
    
}