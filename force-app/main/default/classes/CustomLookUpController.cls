/**
 * @description       : 
 * @author            : Adam Nicholson?
 * @group             : 
 * @last modified on  : 07-29-2020
 * @last modified by  : Arquimidez Mora
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.1   ?? ??-2020   Atageldi Atageldiyev   Included query for prebuild specification(Urgent paid sample request)
 * 1.2   07 12-2020   Arquimidez Mora        Fixing issue that doesn't find finisher accounts anymore
 * 1.2.1   07 12-2020   Arquimidez Mora      Removed filter that discarded pricing approved products
**/
public class CustomLookUpController {
    @AuraEnabled
    // This component should be extended to accept the filter field and filter if reused
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, String recordId) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        
        List < sObject > returnList = new List < sObject > ();
      
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        //String sQuery = '';
        // removed TPM filter 
        //String addFilterString = 'TPM'; 
        //sQuery =  'select id, accountType__c, ownerId, Name from ' +ObjectName + ' where accountType__c INCLUDES(:addFilterString) AND Name LIKE: searchKey order by createdDate DESC limit 5';
        String sQuery =  'select id, Name from ' +ObjectName + ' where  Name LIKE: searchKey order by createdDate DESC limit 5';
        if(ObjectName == 'Specification__c'){
            sQuery =  'select id, Name from ' +ObjectName + ' where opportunity__c = \''+ recordId + '\' AND PreBuildApproved__c = TRUE AND status__c != \'Declined\' AND Name LIKE: searchKey order by createdDate DESC limit 5';
        }
		System.debug('query==>' + sQuery);        
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}