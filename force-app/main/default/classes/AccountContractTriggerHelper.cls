/********
    Name                : AccountContractTriggerHelper
    Description         : This is the helper class
********/

Public class AccountContractTriggerHelper{
    public static void beforeInsert(List<AccountContract__c> accoutContractList){
        updateContractOwner(accoutContractList);
    }
    
    private static void updateContractOwner(List<AccountContract__c> accoutContractList){
        Set<id> accountIds = new Set<id>();
        for(AccountContract__c accContract: accoutContractList){
            if(accContract.account__c != NULL){
                accountIds.add(accContract.account__c);
            }
        }
        if(accountIds.size() > 0){
            Map<id, Account> accountById = getAccountById(accountIds);
            for(AccountContract__c accContract: accoutContractList){
                if(accountById.containsKey(accContract.account__c)){
                    accContract.ownerId = accountById.get(accContract.account__c).OwnerId;
                }
            }
        }
    }
    
    private static Map<Id, Account> getAccountById(Set<id> accountIds){
        try{
            Map<id, Account> accountById = new Map<id, Account>([SELECT id, OwnerId 
                                            FROM Account 
                                            WHERE Id IN: accountIds]);
            return accountById;
        }catch(Exception e){
        }
        return new Map<id, Account>();
    }
}