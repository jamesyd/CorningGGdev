/**
 * @File Name          : Utilities.cls
 * @Description        : 
 * @Author             : Adam Nicholson?
 * @Group              : 
 * @Last Modified By   : Jim Dickerson
 * @Last Modified On   : 04-11-2020
 * @Modification Log   : 
 * Ver       Date      Author      		  Modification
 * 1.1    29/6/2020    Arquimidez Mora    Updated code to fix chatter notification for Free Sample Request
 * 1.2    04/11/2020   Jim Dickerson      Implement changes for Corning Bendable Glass (CSMSF-23)
**/
public class Utilities {
    
    //Result class for sample opportunity
    public class SampleOptyResult{ 
        public integer countSampleOptyLineItems {get; set;}
        public boolean isSample {get; set;}
        public String recordTypeName { get; set;}
    }
    
    //A wrapper class that will return DMLResults to Lightning component
    public class DMLResult{
        @AuraEnabled public boolean success { get; set;}
        @AuraEnabled public String message { get; set;}
        @AuraEnabled public List<String> errorMessages { get; set;}
        
        public DMLResult(){
            errorMessages = new List<String>();
        }
    }
    
    public class utilityException extends Exception {}
 
    //Returns Gorilla Glass Price Book Id
    public Id getGGPriceBookId() {
        String sName = label.GGPriceBook;
        Id oId = null;
        for (PriceBook2 pb: [SELECT Id FROM Pricebook2 WHERE Name = :sName LIMIT 1]){
            oId = pb.Id;
        }
        return oId;
    }
 
    public RecordType getRecordTypeID(string objectType, string recTypeName) {
        list<RecordType> rts = [SELECT ID, Name FROM RecordType WHERE Name = :recTypeName AND sObjectType = :objectType];        
        return (rts != null && rts.size() > 0) ? rts.get(0) : null;
    }
    
    public string getRecordTypeName(string recTypeId) {
        string rt = [SELECT Name FROM RecordType WHERE id= :recTypeId LIMIT 1].Name;        
        return (rt != null) ? rt : null;
    }

    public string getProfileName(string profileId) {
        string profileName = [SELECT Name FROM Profile WHERE Id = :profileId LIMIT 1].Name;
        return (profileName != null) ? profileName : null;
    }
    
    public Id getProfileId(string profileName) {
        Id profileId = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1].Id;
        return (profileId != null) ? profileId : null;
    }

    // Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    public string getCreatableFieldsSOQL(string objectName, set <string> exceptions, string whereClause, boolean attachment){
         
        String selects = '';
         
        if (whereClause == null || whereClause == ''){ return null; }
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                //if (fd.isCreateable()) { // field is creatable
                    if(!(exceptions.contains(fd.getName()))) {
                        selectFields.add(fd.getName());
                    }
                //}
            }
        }
        
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ', ';
            }
            
            if (selects.endsWith(', ')){selects = selects.substring(0,selects.lastIndexOf(', '));}
        }
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
         
    }
    
    public boolean isRecordIdForQuote(Id rId){
        //for quotes, get the owner opportunity
        String strRId = rId;
        if (strRId.length() > 0 && strRId.startsWith('0Q0')){
            return true;
        }
        return false;
    }
    
    public boolean includeSamplesForQuote(Id rId){
        //for quotes, get the owner opportunity
        String strRId = rId;
        Quote q = [SELECT Id, includeSamplePrice__c FROM Quote WHERE Id = :rId LIMIT 1];
        return q.includeSamplePrice__c;
    }
    
    //is this a sample quote record?
    public boolean isProgramPartsQuote(Id rId){
        if (isRecordIdForQuote(rId)){
            Quote o = [SELECT Id, RecordTypeId FROM Quote WHERE Id = :rId LIMIT 1];
            String rt = getRecordTypeName(o.RecordTypeId);
            return (rt == Label.GGQuoteParts);
        }
        return false;
    }
    
    //is this a sample quote record?
    public boolean isSampleQuote(Id rId){
        if (isRecordIdForQuote(rId)){
            Quote o = [SELECT Id, RecordTypeId FROM Quote WHERE Id = :rId LIMIT 1];
            String rt = getRecordTypeName(o.RecordTypeId);
            return (rt == Label.GGQuoteSample);
        }
        return false;
    }

    //checks if opportunity is sample opportunity
    public SampleOptyResult isSampleOpportunity2(Id recordId){
        SampleOptyResult result = new SampleOptyResult();
        result.isSample = false;
        if (recordId == null){
            return result;
        }
        
        Opportunity o = [SELECT Id, RecordTypeId, countOpportunityLineItems__c FROM Opportunity WHERE Id = :recordId LIMIT 1];
        if (o != null){
            result.recordTypeName = getRecordTypeName(o.RecordTypeId);
            if (result.recordTypeName.containsIgnoreCase('sample')){
                result.countSampleOptyLineItems = (Integer)o.countOpportunityLineItems__c;
                result.isSample = true;
            }
        }

        return result;
    }
    
    public integer quoteLineItemCount(Id quoteId){
        integer count = [SELECT Count() FROM QuoteLineItem WHERE QuoteId = :quoteId];
        return count;
    }
    
    //returns the opportunity record with the optyToReturn parameter
    /*public boolean isSampleOpportunity(Id recordId, Opportunity optyToReturn){
        if (recordId == null){
            return false;
        }
        
        Opportunity o = [SELECT Id, RecordTypeId, countOpportunityLineItems__c FROM Opportunity WHERE Id = :recordId LIMIT 1];
        if (o != null){
            String str = getRecordTypeName(o.RecordTypeId);
            if (str.containsIgnoreCase('sample')){
                return true;
            }
        }
        return false;
    }*/
    
    public double getPriceForParts(Decimal quantity, Price__c price){
        double rVal = 0;
        if (price.upperLimit1__c != null && quantity < price.upperLimit1__c){
            rVal = price.price1__c;
        }else 
        if (price.upperLimit2__c != null && quantity < price.upperLimit2__c){
            rVal = price.price2__C;
        }else 
        if (price.upperLimit3__c != null && quantity < price.upperLimit3__c){
            rVal = price.price3__C;
        }else 
        if (price.upperLimit4__c != null && quantity < price.upperLimit4__c){
            rVal = price.price4__C;
        }
        return rVal;
    }
    
    //Is this a blue account?
    public boolean isBlueAccount(String actId){
        Account act = [SELECT exclusiveAccountType__c FROM Account WHERE Id = :actId LIMIT 1];
        
        return (act != null && act.exclusiveAccountType__c == 'Blue');
    }
    
    //Is this opportunity or quote for Blue account?
    public boolean isBlueOptyOrQuote(String recordId){
        String optyId = recordId;
        if (recordId.startsWith('0Q0')){
            optyId = [SELECT OpportunityId FROM Quote WHERE Id = :recordId LIMIT 1].OpportunityId; 
        }
        if (optyId.startsWith('006')){
            Opportunity o = [SELECT Account.exclusiveAccountType__c FROM Opportunity WHERE Id = :optyId LIMIT 1];
            
            return o.Account.exclusiveAccountType__c == 'Blue';
        }
        
        return false;
    }
    
    //Are these opportunities for Blue account?
    public map <Id,boolean> isBlueOptyOrQuote(list<string> opportunityIdList){
        map<Id, boolean> blueOppMap = new map<Id, boolean>();
        
        list<Opportunity> oList = [SELECT Id, Account.exclusiveAccountType__c FROM Opportunity WHERE Id IN :opportunityIdList];
        
        for (Opportunity opp : oList) {
              blueOppMap.put(opp.Id, opp.Account.exclusiveAccountType__c == 'Blue');
        }
        return blueOppMap;
    }
    
    public class RecordAccessWrapper{
    //does the specified user have permission to the specified record?
        @AuraEnabled public String sObjectType { get; set;}
        @AuraEnabled public Id RecordId { get; set;}
        @AuraEnabled public Id UserId { get; set;}
        @AuraEnabled public boolean RecordCreatable { get; set;}
        @AuraEnabled public boolean RecordEditable { get; set;}
        @AuraEnabled public boolean RecordViewable { get; set;}
        
        public RecordAccessWrapper(){}
    }
    
    public RecordAccessWrapper getUserRecordAccess(Id recId, Id userId) {
        Schema.DescribeSObjectResult drSObj = recId.getSObjectType().getDescribe();
        
        UserRecordAccess ur = [SELECT RecordId, HasReadAccess, HasEditAccess FROM UserRecordAccess WHERE UserId = :userId AND RecordId = :recId]; 
        RecordAccessWrapper accessWrapper = new RecordAccessWrapper();       
        accessWrapper.sObjectType = drSobj.getLabel();
        accessWrapper.RecordId = recId;
        accessWrapper.UserId = userId;
        accessWrapper.RecordCreatable = drSObj.isCreateable() && ur.HasEditAccess;
        accessWrapper.RecordEditable = ur.HasEditAccess && drSObj.isUpdateable();
        accessWrapper.RecordViewable = ur.HasReadAccess && drSObj.isAccessible();
        return accessWrapper;
    }
    
    public String doFormatting(Decimal val, integer dec, String tSep, String dSep) {
        String s, tmp;
        Integer i = 4 + dec;
     
        // If the number of decimals is zero (0)... prevents the first 1000s seperator from being set at the 4th.
        if(dec == 0){
            i--;
        }
     
        s = val.setScale(dec).toPlainString().replace(tSep, dSep);
        while(s.length() > i) {
            tmp = s.substring(0, s.length() - i) + tSep + s.substring(s.length() - i);
            s = tmp;
            i += 4;
        }
     
        // If the number is negative and has a number non-decimal digits divisible by 3, it prevents putting a comma before the 1st digit (ex -300,000.00  comes out -,300,000.00)
        //if (s.substring(0,1) == '-') {
        //  if (s.substring(1,2) == tSep) {
        //      s = '-' + s.substring(2);
        //  }
        //}
     
        return s;
    }
    
    public String getMessageInnovationOnly(String name, Specification__c spec) {
        String msg = '';
        String baseMessage = '';
        baseMessage = GGPartsSpecAutoNotifications__c.getValues(name).message__c;
                    
        // final message - includes innovation
        if (String.isEmpty(spec.innovation_type__c) == False) {
            msg = baseMessage + ' with ' + spec.innovation_type__c;
        } else {
            msg = baseMessage + ' with no innovations.';
        }   
        msg = msg.replaceAll(';', ' + '); 
        return msg;
    }
    
    public String getMessageInnovationAndLocation(String name, Specification__c spec) {
        String msg = '';
        String baseMessage = '';
        baseMessage = GGPartsSpecAutoNotifications__c.getValues(name).message__c;
        
        // final message - includes innovation and CM
        if (String.isEmpty(spec.innovation_type__c) == False && String.isEmpty(spec.location__c) == False) {
            msg = baseMessage + ' with ' + spec.innovation_type__c + ' at ' + spec.location__c;
        } else if (String.isEmpty(spec.innovation_type__c) == True && String.isEmpty(spec.location__c) == False) {
            msg = baseMessage + ' with no innovations at ' + spec.location__c;
        } else if (String.isEmpty(spec.innovation_type__c) == False && String.isEmpty(spec.location__c) == True) {
            msg = baseMessage + ' with ' + spec.innovation_type__c + ' at no locations';
        } else if (String.isEmpty(spec.innovation_type__c) == True && String.isEmpty(spec.location__c) == True) {
            msg = baseMessage + ' with no innovations at no locations';
        }
                    
        msg = msg.replaceAll(';', ' + ');
        return msg;
    }
    
    public String getMessageInnovationAndLocationDS(String name, Specification__c spec) {
        String msg = '';
        String baseMessage = '';
        baseMessage = GGPartsSpecAutoNotifications__c.getValues(name).message__c;
        
        // final message - includes innovation and CM
        if (String.isEmpty(spec.innovation_type__c) == False && String.isEmpty(spec.dsLocation__c) == False) {
            msg = baseMessage + ' with ' + spec.innovation_type__c + ' at ' + spec.dsLocation__c;
        } else if (String.isEmpty(spec.innovation_type__c) == True && String.isEmpty(spec.dsLocation__c) == False) {
            msg = baseMessage + ' with no innovations at ' + spec.dsLocation__c;
        } else if (String.isEmpty(spec.innovation_type__c) == False && String.isEmpty(spec.dsLocation__c) == True) {
            msg = baseMessage + ' with ' + spec.innovation_type__c + ' at no locations';
        } else if (String.isEmpty(spec.innovation_type__c) == True && String.isEmpty(spec.dsLocation__c) == True) {
            msg = baseMessage + ' with no innovations at no locations';
        }
                    
        msg = msg.replaceAll(';', ' + ');
        return msg;
    }
    
    public String getInnovationRecipients(Specification__c spec) {
                
        String invRecipients = '';
        invRecipients = spec.innovation_type__c.contains( GGPartsSpecAutoNotifications__c.getValues('AntiGlare (AG)').name )
            ? invRecipients + ',' + GGPartsSpecAutoNotifications__c.getValues('AntiGlare (AG)').userIdList__c 
            : invRecipients;
        invRecipients = spec.innovation_type__c.contains( GGPartsSpecAutoNotifications__c.getValues('AntiMicrobial').name )
            ? invRecipients + ',' + GGPartsSpecAutoNotifications__c.getValues('AntiMicrobial').userIdList__c 
            : invRecipients;    
        invRecipients = spec.innovation_type__c.contains( GGPartsSpecAutoNotifications__c.getValues('EZ/AR').name )
            ? invRecipients + ',' + GGPartsSpecAutoNotifications__c.getValues('EZ/AR').userIdList__c 
            : invRecipients;    
        invRecipients = spec.innovation_type__c.contains( GGPartsSpecAutoNotifications__c.getValues('FPS').name )
            ? invRecipients + ',' + GGPartsSpecAutoNotifications__c.getValues('FPS').userIdList__c 
            : invRecipients;
        invRecipients = spec.innovation_type__c.contains( GGPartsSpecAutoNotifications__c.getValues('Glass Back').name )
            ? invRecipients + ',' + GGPartsSpecAutoNotifications__c.getValues('Glass Back').userIdList__c 
            : invRecipients;
        invRecipients = spec.innovation_type__c.contains( GGPartsSpecAutoNotifications__c.getValues('Glass Ceramics').name )
            ? invRecipients + ',' + GGPartsSpecAutoNotifications__c.getValues('Glass Ceramics').userIdList__c 
            : invRecipients;
        invRecipients = spec.innovation_type__c.contains( GGPartsSpecAutoNotifications__c.getValues('Large Cover Glass').name )
            ? invRecipients + ',' + GGPartsSpecAutoNotifications__c.getValues('Large Cover Glass').userIdList__c 
            : invRecipients;
        invRecipients = spec.innovation_type__c.contains( GGPartsSpecAutoNotifications__c.getValues('NextGenSRPlus').name )
            ? invRecipients + ',' + GGPartsSpecAutoNotifications__c.getValues('NextGenSRPlus').userIdList__c 
            : invRecipients;
        invRecipients = spec.innovation_type__c.contains( GGPartsSpecAutoNotifications__c.getValues('DXPlus').name )
            ? invRecipients + ',' + GGPartsSpecAutoNotifications__c.getValues('DXPlus').userIdList__c 
            : invRecipients;            
        invRecipients = spec.innovation_type__c.contains( GGPartsSpecAutoNotifications__c.getValues('non-CE AR').name )
            ? invRecipients + ',' + GGPartsSpecAutoNotifications__c.getValues('non-CE AR').userIdList__c 
            : invRecipients;
        invRecipients = spec.innovation_type__c.contains( GGPartsSpecAutoNotifications__c.getValues('Screen Protector').name )
            ? invRecipients + ',' + GGPartsSpecAutoNotifications__c.getValues('Screen Protector').userIdList__c 
            : invRecipients;
        invRecipients = spec.innovation_type__c.contains( GGPartsSpecAutoNotifications__c.getValues('SRPlus').name )
            ? invRecipients + ',' + GGPartsSpecAutoNotifications__c.getValues('SRPlus').userIdList__c 
            : invRecipients;
        invRecipients = spec.innovation_type__c.contains( GGPartsSpecAutoNotifications__c.getValues('Vibrant').name )
            ? invRecipients + ',' + GGPartsSpecAutoNotifications__c.getValues('Vibrant').userIdList__c 
            : invRecipients; 
        invRecipients = spec.innovation_type__c.contains( GGPartsSpecAutoNotifications__c.getValues('ArtEng').name )
            ? invRecipients + ',' + GGPartsSpecAutoNotifications__c.getValues('ArtEng').userIdList__c 
            : invRecipients;                    
        invRecipients = spec.innovation_type__c.contains( GGPartsSpecAutoNotifications__c.getValues('Phyllo').name )
            ? invRecipients + ',' + GGPartsSpecAutoNotifications__c.getValues('Phyllo').userIdList__c 
            : invRecipients;                    
        invRecipients = spec.innovation_type__c.contains( GGPartsSpecAutoNotifications__c.getValues('DX').name )
            ? invRecipients + ',' + GGPartsSpecAutoNotifications__c.getValues('DX').userIdList__c 
            : invRecipients;
        invRecipients = spec.innovation_type__c.contains( GGPartsSpecAutoNotifications__c.getValues('DX-C').name )
            ? invRecipients + ',' + GGPartsSpecAutoNotifications__c.getValues('DX-C').userIdList__c 
            : invRecipients;
        invRecipients = spec.innovation_type__c.contains( GGPartsSpecAutoNotifications__c.getValues('DXC').name )
            ? invRecipients + ',' + GGPartsSpecAutoNotifications__c.getValues('DXC').userIdList__c 
            : invRecipients;    
        invRecipients = spec.innovation_type__c.contains( GGPartsSpecAutoNotifications__c.getValues('DAR2.0').name )
            ? invRecipients + ',' + GGPartsSpecAutoNotifications__c.getValues('DAR2.0').userIdList__c 
            : invRecipients;
        invRecipients = spec.innovation_type__c.contains( GGPartsSpecAutoNotifications__c.getValues('IT Size 3D').name )
            ? invRecipients + ',' + GGPartsSpecAutoNotifications__c.getValues('IT Size 3D').userIdList__c 
            : invRecipients;         
        invRecipients = spec.innovation_type__c.contains( GGPartsSpecAutoNotifications__c.getValues('AR – Camera Hole').name )
            ? invRecipients + ',' + GGPartsSpecAutoNotifications__c.getValues('AR – Camera Hole').userIdList__c 
            : invRecipients;      
        invRecipients = spec.innovation_type__c.contains( GGPartsSpecAutoNotifications__c.getValues('Corning Bendable Glass').name )
            ? invRecipients + ',' + GGPartsSpecAutoNotifications__c.getValues('Corning Bendable Glass').userIdList__c 
            : invRecipients;         // CSMSF-23                                                             
        return invRecipients;
    }

    
    public String getMessageInnovationOnlySamples(String name, opportunity o) {
        String msg = '';
        String baseMessage = '';
        baseMessage = GGPartsSampleAutoNotifications__c.getValues(name).message__c;
        if(o.isPrebuild__c && o.StageName != 'Non-paid Request'){
            baseMessage = baseMessage.replaceAll(': Free Parts ', ': Urgent Paid ');
        }
                    
        // final message - includes innovation
        if (String.isEmpty(o.sampleInnovations__c) == False) {
            msg = baseMessage + ' with ' + o.sampleInnovations__c;
        } else {
            msg = baseMessage + ' with no innovations.';
        }   
        msg = msg.replaceAll(';', ' + '); 
        return msg;
    }
    
    public String getMessageInnovationAndLocationSamples(String name, opportunity o) {
        String msg = '';
        String baseMessage = '';
        baseMessage = GGPartsSampleAutoNotifications__c.getValues(name).message__c;
        Id rawGlassRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('GG_Raw_Glass_Sample_Request').getRecordTypeId();
        Id rawGlassSubmittedRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('GG_Raw_Glass_Sample_Submitted').getRecordTypeId();
        if(o.isPrebuild__c && o.StageName != 'Non-paid Request' && (o.RecordTypeId != rawGlassRTId && o.RecordTypeId != rawGlassSubmittedRTId)){
            baseMessage = baseMessage.replaceAll(': Free Parts ', ': Urgent Paid ');
        }else{
            if(o.StageName == 'Non-paid Request' && (o.RecordTypeId == rawGlassRTId || o.RecordTypeId == rawGlassSubmittedRTId)){
                baseMessage = baseMessage.replaceAll(': Free Parts ', ': Free Raw Glass ');
            }
        }
                    
        // final message - includes innovation and CM
        if (String.isEmpty(o.sampleInnovations__c) == False && String.isEmpty(o.sampleCmLocations__c) == False) {
            msg = baseMessage + ' with ' + o.sampleInnovations__c + ' at ' + o.sampleCmLocations__c;
        } else if (String.isEmpty(o.sampleInnovations__c) == True && String.isEmpty(o.sampleCmLocations__c) == False) {
            msg = baseMessage + ' with no innovations at ' + o.sampleCmLocations__c;
        } else if (String.isEmpty(o.sampleInnovations__c) == False && String.isEmpty(o.sampleCmLocations__c) == True) {
            msg = baseMessage + ' with ' + o.sampleInnovations__c + ' in Inventory';
        } else if (String.isEmpty(o.sampleInnovations__c) == True && String.isEmpty(o.sampleCmLocations__c) == True) {
            msg = baseMessage + ' with no innovations in Inventory';
        }
        
        msg = msg.replaceAll(';', ' + ');
        return msg;
    }
    
    public String getInnovationRecipientsSamples(opportunity o) {
                
        String invRecipients = '';
        invRecipients = o.sampleInnovations__c.contains( GGPartsSampleAutoNotifications__c.getValues('AntiGlare (AG)').name )
            ? invRecipients + ',' + GGPartsSampleAutoNotifications__c.getValues('AntiGlare (AG)').userIdList__c 
            : invRecipients;
        invRecipients = o.sampleInnovations__c.contains( GGPartsSampleAutoNotifications__c.getValues('AntiMicrobial').name )
            ? invRecipients + ',' + GGPartsSampleAutoNotifications__c.getValues('AntiMicrobial').userIdList__c 
            : invRecipients;    
        invRecipients = o.sampleInnovations__c.contains( GGPartsSampleAutoNotifications__c.getValues('EZ/AR').name )
            ? invRecipients + ',' + GGPartsSampleAutoNotifications__c.getValues('EZ/AR').userIdList__c 
            : invRecipients;    
        invRecipients = o.sampleInnovations__c.contains( GGPartsSampleAutoNotifications__c.getValues('FPS').name )
            ? invRecipients + ',' + GGPartsSampleAutoNotifications__c.getValues('FPS').userIdList__c 
            : invRecipients;
        invRecipients = o.sampleInnovations__c.contains( GGPartsSampleAutoNotifications__c.getValues('Glass Back').name )
            ? invRecipients + ',' + GGPartsSampleAutoNotifications__c.getValues('Glass Back').userIdList__c 
            : invRecipients;
        invRecipients = o.sampleInnovations__c.contains( GGPartsSampleAutoNotifications__c.getValues('Glass Ceramics').name )
            ? invRecipients + ',' + GGPartsSampleAutoNotifications__c.getValues('Glass Ceramics').userIdList__c 
            : invRecipients;
        invRecipients = o.sampleInnovations__c.contains( GGPartsSampleAutoNotifications__c.getValues('Large Cover Glass').name )
            ? invRecipients + ',' + GGPartsSampleAutoNotifications__c.getValues('Large Cover Glass').userIdList__c 
            : invRecipients;
        invRecipients = o.sampleInnovations__c.contains( GGPartsSampleAutoNotifications__c.getValues('NextGenSRPlus').name )
            ? invRecipients + ',' + GGPartsSampleAutoNotifications__c.getValues('NextGenSRPlus').userIdList__c 
            : invRecipients;
        invRecipients = o.sampleInnovations__c.contains( GGPartsSampleAutoNotifications__c.getValues('DXPlus').name )
            ? invRecipients + ',' + GGPartsSampleAutoNotifications__c.getValues('DXPlus').userIdList__c 
            : invRecipients;    
        invRecipients = o.sampleInnovations__c.contains( GGPartsSampleAutoNotifications__c.getValues('non-CE AR').name )
            ? invRecipients + ',' + GGPartsSampleAutoNotifications__c.getValues('non-CE AR').userIdList__c 
            : invRecipients;
        invRecipients = o.sampleInnovations__c.contains( GGPartsSampleAutoNotifications__c.getValues('Screen Protector').name )
            ? invRecipients + ',' + GGPartsSampleAutoNotifications__c.getValues('Screen Protector').userIdList__c 
            : invRecipients;
        invRecipients = o.sampleInnovations__c.contains( GGPartsSampleAutoNotifications__c.getValues('SRPlus').name )
            ? invRecipients + ',' + GGPartsSampleAutoNotifications__c.getValues('SRPlus').userIdList__c 
            : invRecipients;
        invRecipients = o.sampleInnovations__c.contains( GGPartsSampleAutoNotifications__c.getValues('Vibrant').name )
            ? invRecipients + ',' + GGPartsSampleAutoNotifications__c.getValues('Vibrant').userIdList__c 
            : invRecipients;       
        invRecipients = o.sampleInnovations__c.contains( GGPartsSampleAutoNotifications__c.getValues('ArtEng').name )
            ? invRecipients + ',' + GGPartsSampleAutoNotifications__c.getValues('ArtEng').userIdList__c 
            : invRecipients;
        invRecipients = o.sampleInnovations__c.contains( GGPartsSampleAutoNotifications__c.getValues('Phyllo').name )
            ? invRecipients + ',' + GGPartsSampleAutoNotifications__c.getValues('Phyllo').userIdList__c 
            : invRecipients;             
        invRecipients = o.sampleInnovations__c.contains( GGPartsSampleAutoNotifications__c.getValues('DX').name )
            ? invRecipients + ',' + GGPartsSampleAutoNotifications__c.getValues('DX').userIdList__c 
            : invRecipients;
        invRecipients = o.sampleInnovations__c.contains( GGPartsSampleAutoNotifications__c.getValues('DX-C').name )
            ? invRecipients + ',' + GGPartsSampleAutoNotifications__c.getValues('DX-C').userIdList__c 
            : invRecipients;
        invRecipients = o.sampleInnovations__c.contains( GGPartsSampleAutoNotifications__c.getValues('DXC').name )
            ? invRecipients + ',' + GGPartsSampleAutoNotifications__c.getValues('DXC').userIdList__c 
            : invRecipients;            
        invRecipients = o.sampleInnovations__c.contains( GGPartsSampleAutoNotifications__c.getValues('DAR2.0').name )
            ? invRecipients + ',' + GGPartsSampleAutoNotifications__c.getValues('DAR2.0').userIdList__c 
            : invRecipients;                       
        invRecipients = o.sampleInnovations__c.contains( GGPartsSpecAutoNotifications__c.getValues('IT Size 3D').name )
            ? invRecipients + ',' + GGPartsSpecAutoNotifications__c.getValues('IT Size 3D').userIdList__c 
            : invRecipients;    
        invRecipients = o.sampleInnovations__c.contains( GGPartsSpecAutoNotifications__c.getValues('AR – Camera Hole').name )
            ? invRecipients + ',' + GGPartsSpecAutoNotifications__c.getValues('AR – Camera Hole').userIdList__c 
            : invRecipients;                                                                                       
  
        return invRecipients;
    }

    
    public String cleanRecipients(String combinedRecipients) {
        String recipients = '';
        List<String> lstRecipients = new List<String>();
        Set<String> setRecipients = new Set<String>();
        lstRecipients.clear();
        setRecipients.clear();
                            
        // create the finalRecipient string for the post
        lstRecipients = combinedRecipients.split(',');
        setRecipients.addAll(lstRecipients);  
        for (String s : setRecipients) {
            if (s.length() > 17) { recipients = recipients + ' ' + s; } // 17 = {000000000000000}
        }
        
        return recipients;
    }

}