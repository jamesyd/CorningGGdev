///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 3/27/2017 ***///
///*** Class to help Account trigger ***///
public with sharing class AccountTriggerHelper {
    
    static Utilities Utils = new Utilities();
    
    //if containsPricing__c = true, Account cannot be deleted
    public static void CheckContainsPricing(List<Account> accts){
        for (Account a: accts) {
            if (a.containsPricing__c == true) { 
                a.addError(Label.DeleteAccountError);
            }
        }
    }
    
    // Method to update the Price Owner where isMTO__c is false and Account owner is changed
    public static void updatePriceOwner(List<Account> accountList,Map<Id,Account> oldMap){
        Map<Id,Id> ownerByAccountId = new Map<Id,Id>();
        for(Account a : accountList){
            if(a.OwnerId != oldMap.get(a.Id).OwnerId){
                ownerByAccountId.put(a.Id,a.OwnerId);
            }
        }
        
        if(ownerByAccountId.size() > 0){
            AccountOwnerChangeController.updatePriceAndAccContractOwner(ownerByAccountId, getContractManagementUser());
        }
    }
    
    // Method to update the Trip Visit Report Owner when Account owner is changed
    public static void updateTripVisitReportOwner(List<Account> accountList,Map<Id,Account> oldMap){
    	Map<Id,Id> ownerByAccountId = new Map<Id,Id>();
        for(Account a : accountList){
            if(a.OwnerId != oldMap.get(a.Id).OwnerId){
                ownerByAccountId.put(a.Id,a.OwnerId);
            }
        }
        List<Trip_Visit_Report__c> tripReportList = new List<Trip_Visit_Report__c>();
        //Query to get Trip Report Owner with Account
        for(Trip_Visit_Report__c tripVisitReportObj : [SELECT Id,OwnerId,Account__C 
                                                       FROM Trip_Visit_Report__c
                                                       WHERE Account__c IN:ownerByAccountId.keySet()]){
        	tripVisitReportObj.OwnerId = ownerByAccountId.get(tripVisitReportObj.Account__c);
            tripReportList.add(tripVisitReportObj);                                   
                                                       }
        if(tripReportList.size() > 0){
            UPDATE tripReportList;
        }
    }
    
    
    //Get Contract_Management permission set Users.
    public static Set<Id> getContractManagementUser(){
        Set<Id> contractManagerIds = new Set<Id>();
        for(PermissionSetAssignment permissionsetAssignment: [SELECT Id, PermissionSet.Name, AssigneeId 
                                                               FROM PermissionSetAssignment
                                                               WHERE PermissionSet.Name =: SYSTEM.LABEL.Contract_Management]){
            contractManagerIds.add(permissionsetAssignment.AssigneeId);
        }
        return contractManagerIds;
    }
}