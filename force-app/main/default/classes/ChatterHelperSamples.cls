/**
 * @File Name          : ChatterHelperSamples.cls
 * @Description        : 
 * @Author             : Adam Nicholson?
 * @Group              : 
 * @Last Modified By   : Edgar Santillana
 * @Last Modified On   : 08-26-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.1    29/6/2020   Arquimidez Mora     Updated code to fix chatter notification for Free Sample Request
**/
public without sharing class ChatterHelperSamples {
    
    public Static List<opportunity> sampleReminder( List<opportunity> opplist ) {
        Utilities Utils = new Utilities();
        
        String finalMessage;
        String baseRecipients;
        String combinedRecipients;
        String finalRecipients;
        String location;        
        String freeApprover = 'Free~Other'; 
        String rawApprover = 'CA~PA~Other';
        List<Opportunity> oppsToUpdate = new List<opportunity>();
        Id ggPrebuildRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('GG Sample Parts Opportunity Prebuild').getRecordTypeId();
        for(opportunity o : oppList) {
            
            if (o.statusChangeDate__c != Null) { // wait until existing spec have a value in this date field
                
                // ***** PARTS REMINDER LOGIC *****
                if ((o.RecordTypeId == '0121J000000U1cXQAS' || o.RecordTypeId == '0121J000000U1cYQAS' || o.RecordTypeId == ggPrebuildRTID) 
                    && o.reminderCompleted__c == false && o.statusChangeDate__c.daysBetween(Date.Today()) > 2 
                    && (o.stageName == 'CM Assignment' || o.stageName == 'Pricing Assignment' || o.stageName == 'RSM Approval' || o.stageName == 'Customer Quotation')) {
                        
                        system.debug('*** IN REPOST');
                        // Clear & reset variables
                        finalMessage = '';
                        baseRecipients = '';
                        combinedRecipients = '';
                        finalRecipients = '';
                        location = ''; 
                        freeApprover = 'Free~Other'; 
                        rawApprover = 'CA~PA~Other';      
                        
                        o.reminderCompleted__c = true; // apex clears this field on status change
                        oppsToUpdate.add(o); // list of specs to update to not continuously repost
                        
                        // ********************
                        
                        // Master Planner reminder logic
                        If (o.stageName == 'CM Assignment') {
                            finalMessage = Utils.getMessageInnovationOnlySamples('N~MA',o);
                            
                            // recipients - do not include innovation PLMs
                            baseRecipients = GGPartsSampleAutoNotifications__c.getValues('N~MA').userIdList__c;
                            combinedRecipients = baseRecipients;
                            
                            // clean/remove duplicate recipients
                            finalRecipients = Utils.cleanRecipients(combinedRecipients);
                            
                            // second parameter = Id of a group or user or record or 'me'
                            ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(),                          
                                                                                                                     o.id, o.programOpportunityName__c + ' ' + finalRecipients + ' ***** REMINDER ' + finalMessage);
                        }
                        
                        // PLM reminder logic
                        If (o.stageName == 'Pricing Assignment') {
                            finalMessage = Utils.getMessageInnovationAndLocationSamples('N~PA',o);
                            
                            // recipients - includes innovation PLMs
                            baseRecipients = GGPartsSampleAutoNotifications__c.getValues('N~PA').userIdList__c;
                            if (String.isEmpty(o.sampleInnovations__c) == False) {
                                combinedRecipients = baseRecipients + Utils.getInnovationRecipientsSamples(o);
                            } else {
                                combinedRecipients = baseRecipients;
                            }
                            
                            // clean/remove duplicate recipients
                            finalRecipients = Utils.cleanRecipients(combinedRecipients);
                            
                            // second parameter = Id of a group or user or record or 'me'
                            ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(),                                              
                                                                                                                     o.id, o.programOpportunityName__c + ' ' + finalRecipients + ' ***** REMINDER ' + finalMessage);                      
                        }
                        
                        // Customer Quotation reminder logic
                        If (o.stageName == 'Customer Quotation') {
                            finalMessage = Utils.getMessageInnovationAndLocationSamples('Quote',o);
                            
                            // recipients
                            baseRecipients = '{' + (Id)o.ownerId + '}';
                            if (o.accountAEID__c != Null) {
                                baseRecipients = baseRecipients + ',{' + (id)o.accountAEId__c + '}';
                            }
                            
                            // clean/remove duplicate recipients
                            finalRecipients = Utils.cleanRecipients(baseRecipients);
                            
                            // second parameter = Id of a group or user or record or 'me'
                            ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                                     o.id, o.programOpportunityName__c + ' ' + finalRecipients + ' ***** REMINDER ' + finalMessage);                   
                        }   
                        
                        // Free Requeat reminder logic
                        If (o.stageName == 'RSM Approval') {
                            finalMessage = Utils.getMessageInnovationAndLocationSamples('Free',o);
                            
                            // recipients - includes innovation PLMs
                            baseRecipients = GGPartsSampleAutoNotifications__c.getValues('Free').userIdList__c;
                            if (String.isEmpty(o.sampleInnovations__c) == False) {
                                combinedRecipients = baseRecipients + Utils.getInnovationRecipientsSamples(o);
                            } else {
                                combinedRecipients = baseRecipients;
                            }
                            
                            // clean/remove duplicate recipients
                            finalRecipients = Utils.cleanRecipients(combinedRecipients);
                            
                            // second parameter = Id of a group or user or record or 'me'
                            ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(),                                                 
                                                                                                                     o.id, o.programOpportunityName__c + ' ' + finalRecipients + ' ***** REMINDER ' + finalMessage);                      
                        }
                        
                    } 
                
                // ***** RAW GLASS LOGIC *****
                if ((o.RecordTypeId == '0121J000000U1cbQAC' || o.RecordTypeId == '0121J000000U1caQAC') 
                    && o.reminderCompleted__c == false && o.statusChangeDate__c.daysBetween(Date.Today()) > 2 
                    && (o.stageName == 'Commercial Assessment' || o.stageName == 'PLM Assessment' || o.stageName == 'RSM Approval' || o.stageName == 'Customer Quotation')) {
                        
                        system.debug('*** IN REPOST');
                        
                        o.reminderCompleted__c = true; // apex clears this field on status change
                        oppsToUpdate.add(o); // list of specs to update to not continuously repost
                        
                        // ********************
                        
                        // Demand Ops reminder logic
                        If (o.stageName == 'Commercial Assessment') {
                            
                            finalMessage = GGRawSampleAutoNotifications__c.getValues('N~CA').message__c;
                            finalRecipients = GGRawSampleAutoNotifications__c.getValues('N~CA').userIdList__c;                   
                            
                            // second parameter = Id of a group or user or record or 'me'
                            ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                                     o.id, o.programOpportunityName__c + ' ' + finalRecipients + ' ***** REMINDER ' + finalMessage);
                        } 
                        
                        // PLM reminder logic
                        If (o.stageName == 'PLM Assessment') {
                            // determine approver based on role and composition
                            
                            if (o.sampleGlassComposition__c.contains('3318')) rawApprover = 'CA~PA~3318~Blue';
                            if (o.sampleGlassComposition__c.contains('4318')) rawApprover = 'CA~PA~4318~Blue';
                            //if (o.sampleGlassComposition__c.contains('5318')) rawApprover = 'CA~PA~5318~Blue';
                            if (o.sampleGlassComposition__c.contains('7418')) rawApprover = 'CA~PA~7418~Blue';
                            if (o.sampleGlassComposition__c.contains('7518')) rawApprover = 'CA~PA~7518~Blue';
                            if (o.sampleGlassComposition__c.contains('9318')) rawApprover = 'CA~PA~9318~Blue';
                            if (o.sampleGlassComposition__c.contains('9319')) rawApprover = 'CA~PA~9319~Blue';
                            if (o.sampleGlassComposition__c.contains('Maxwell GC')) rawApprover = 'CA~PA~Maxwell~GC~Blue';
                            if (o.sampleGlassComposition__c.contains('MM-B')) rawApprover = 'CA~PA~MM-B~Blue';
                            if (o.sampleGlassComposition__c.contains('MX-B')) rawApprover = 'CA~PA~MX-B~Blue';
                            if (o.sampleGlassComposition__c.contains('PHY2')) rawApprover = 'CA~PA~PHY2~Blue';  
                            if (o.sampleGlassComposition__c.contains('9724')) rawApprover = 'CA~PA~9724~Blue'; 
                            if (o.sampleGlassComposition__c.contains('9726')) rawApprover = 'CA~PA~9726~Blue';                           
                            
                            if (o.sampleGlassComposition__c.contains('2317')) rawApprover = 'CA~PA~2317';
                            if (o.sampleGlassComposition__c.contains('2318')) rawApprover = 'CA~PA~2318';
                            if (o.sampleGlassComposition__c.contains('2319')) rawApprover = 'CA~PA~2319';
                            if (o.sampleGlassComposition__c.contains('2320')) rawApprover = 'CA~PA~2320';
                            if (o.sampleGlassComposition__c.contains('2521')) rawApprover = 'CA~PA~2521';
                            if (o.sampleGlassComposition__c.contains('3318')) rawApprover = 'CA~PA~3318';
                            if (o.sampleGlassComposition__c.contains('5318')) rawApprover = 'CA~PA~5318';
                            if (o.sampleGlassComposition__c.contains('7321')) rawApprover = 'CA~PA~7321';
                            if (o.sampleGlassComposition__c.contains('7431')) rawApprover = 'CA~PA~7431';   
                            if (o.sampleGlassComposition__c.contains('7541')) rawApprover = 'CA~PA~7541';                                                   
                            
                            
                            finalMessage = GGRawSampleAutoNotifications__c.getValues(rawApprover).message__c;
                            finalRecipients = GGRawSampleAutoNotifications__c.getValues(rawApprover).userIdList__c;                   
                            
                            // second parameter = Id of a group or user or record or 'me'
                            ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                                     o.id, o.programOpportunityName__c + ' ' + finalRecipients + ' ***** REMINDER ' + finalMessage);                         
                        } 
                        
                        // Customer Quotation reminder logic
                        If (o.stageName == 'Customer Quotation') {
                            finalMessage = GGRawSampleAutoNotifications__c.getValues('Quote').message__c;
                            
                            // recipients
                            baseRecipients = '{' + (Id)o.ownerId + '}';
                            if (o.accountAEID__c != Null) {
                                baseRecipients = baseRecipients + ',{' + (id)o.accountAEId__c + '}';
                            }
                            
                            // clean/remove duplicate recipients
                            finalRecipients = Utils.cleanRecipients(baseRecipients);
                            
                            // second parameter = Id of a group or user or record or 'me'
                            ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                                     o.id, o.programOpportunityName__c + ' ' + finalRecipients + ' ***** REMINDER ' + finalMessage);                   
                        }   
                        
                        // Free Request reminder logic
                        If (o.stageName == 'RSM Approval') {
                            // determine approver based on role
                            if (o.Owner_Role__c.contains('Americas/EMEA')) freeApprover = 'Free~Americas/EMEA';
                            if (o.Owner_Role__c.contains('China/ODM/TPM/Finisher')) freeApprover = 'Free~China/ODM/TPM/Finisher';
                            if (o.Owner_Role__c.contains('Japan')) freeApprover = 'Free~Japan';
                            if (o.Owner_Role__c.contains('Korea')) freeApprover = 'Free~Korea';
                            if (o.Owner_Role__c.contains('China/OEM')) freeApprover = 'Free~China/OEM';
                            if (o.Owner_Role__c.contains('China/India')) freeApprover = 'Free~China/India';
                            if (o.Owner_Role__c.contains('Product Line Manager')) freeApprover = 'Free~Product Line Manager';
                            if (o.Owner_Role__c.contains('South East Asia')) freeApprover = 'Free~South East Asia';
                            if (o.Owner_Role__c.contains('Taiwan')) freeApprover = 'Free~Taiwan';
                            if (o.Owner_Role__c.contains('Blue')) freeApprover = 'Free~Blue';
                            
                            finalMessage = GGRawSampleAutoNotifications__c.getValues(freeApprover).message__c;
                            if(o.isPrebuild__c && o.StageName != 'Non-paid Request'){
                                finalMessage = finalMessage.replaceAll(': Free Parts ', ': Urgent Paid ');
                            }
                            finalRecipients = GGRawSampleAutoNotifications__c.getValues(freeApprover).userIdList__c;
                            
                            // second parameter = Id of a group or user or record or 'me'
                            ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                                     o.id, o.programOpportunityName__c + ' ' + finalRecipients + ' ***** REMINDER ' + finalMessage);                   
                        }
                        
                    }                             
            }
        }        
        return oppsToUpdate;
    }
    
    public Static Void sampleNotification( List<opportunity> opplist, Map<ID, opportunity> oldmap ) {
        Utilities Utils = new Utilities();
        
        String finalMessage;
        String baseRecipients;
        String combinedRecipients;
        String finalRecipients;
        String location;
        String freeApprover = 'Free~Other'; 
        String rawApprover = 'CA~PA~Other';       
        //Id ggPhylloRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('GG Sample Parts Opportunity Phyllo').getRecordTypeId();
        for(opportunity o : opplist) {  
            // ***** PARTS LOGIC *****
            // Clear & reset variables
            finalMessage = '';
            baseRecipients = '';
            combinedRecipients = '';
            finalRecipients = '';
            location = ''; 
            freeApprover = 'Free~Other'; 
            rawApprover = 'CA~PA~Other';    
            System.debug('opplist==$$$>' + opplist.get(0).recordtypeId);
            Id ggPrebuildRTID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('GG Sample Parts Opportunity Prebuild').getRecordTypeId();
            if (o.RecordTypeId == '0121J000000U1cXQAS' || o.RecordTypeId == '0121J000000U1cYQAS' || o.RecordTypeId == ggPrebuildRTID) { 
                
                //RSM APPROVAL is similar to the Non-paid Request.
                If (oldMap.get(o.ID).stageName != 'RSM Approval' && o.stageName == 'RSM Approval') {    
                    //Determine approver based on role
                    if (o.Owner_Role__c.contains('Americas/EMEA')) freeApprover = 'Free~Americas/EMEA';
                    if (o.Owner_Role__c.contains('China/ODM/TPM/Finisher')) freeApprover = 'Free~China/ODM/TPM/Finisher';
                    if (o.Owner_Role__c.contains('Japan')) freeApprover = 'Free~Japan';
                    if (o.Owner_Role__c.contains('Korea')) freeApprover = 'Free~Korea';
                    if (o.Owner_Role__c.contains('China/OEM')) freeApprover = 'Free~China/OEM';
                    if (o.Owner_Role__c.contains('China/India')) freeApprover = 'Free~China/India';
                    if (o.Owner_Role__c.contains('Product Line Manager')) freeApprover = 'Free~Product Line Manager';
                    if (o.Owner_Role__c.contains('South East Asia')) freeApprover = 'Free~South East Asia';
                    if (o.Owner_Role__c.contains('Taiwan')) freeApprover = 'Free~Taiwan';
                    if (o.Owner_Role__c.contains('Blue')) freeApprover = 'Free~Blue';
                    
                    finalMessage = Utils.getMessageInnovationAndLocationSamples(freeApprover,o);

                    if(o.isPhyllo__c){
                        finalMessage = finalMessage.replaceAll('with no innovations at Not Applicable', 'Corning Bendable Glass with no innovations at Not Applicable');
                    }
                    
                    // recipients - includes innovation PLMs
                    baseRecipients = GGPartsSampleAutoNotifications__c.getValues(freeApprover).userIdList__c;
                    if (String.isEmpty(o.sampleInnovations__c) == False) {
                        combinedRecipients = baseRecipients + Utils.getInnovationRecipientsSamples(o);
                    } else {
                        combinedRecipients = baseRecipients;
                    }
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             o.id, o.programOpportunityName__c + ' ' + finalRecipients + ' ' + finalMessage);                   
                }
                
                // Master Planner notification logic - Path 1
                If ((oldMap.get(o.ID).stageName == 'New' || oldMap.get(o.ID).stageName == 'RSM Approval') && o.stageName == 'CM Assignment') {
                    finalMessage = Utils.getMessageInnovationOnlySamples('N~MA',o);

                    if(o.isPhyllo__c){
                        finalMessage = finalMessage.replaceAll('with no innovations at Not Applicable', 'Corning Bendable Glass with no innovations at Not Applicable');
                    }
                    
                    // recipients - do not include innovation PLMs
                    baseRecipients = GGPartsSampleAutoNotifications__c.getValues('N~MA').userIdList__c;
                    combinedRecipients = baseRecipients;
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             o.id, o.programOpportunityName__c + ' ' + finalRecipients + ' ' + finalMessage);
                }
                
                // PLM notification logic - Path 1 - include location in message
                If ((oldMap.get(o.ID).stageName == 'New' || oldMap.get(o.ID).stageName == 'RSM Approval') && o.stageName == 'Pricing Assignment') {
                    finalMessage = Utils.getMessageInnovationAndLocationSamples('N~PA',o);

                    if(o.isPhyllo__c){
                        finalMessage = finalMessage.replaceAll('with no innovations at Not Applicable', 'Corning Bendable Glass with no innovations at Not Applicable');
                    }
                    
                    // recipients - includes innovation PLMs
                    if(!o.isPhyllo__c){
                        baseRecipients = GGPartsSampleAutoNotifications__c.getValues('N~PA').userIdList__c;
                    }else{
                        baseRecipients = GGPartsSampleAutoNotifications__c.getValues('N~PA Phyllo').userIdList__c;
                    }
                    if (String.isEmpty(o.sampleInnovations__c) == False) {
                        combinedRecipients = baseRecipients + Utils.getInnovationRecipientsSamples(o);
                    } else {
                        combinedRecipients = baseRecipients;
                    }
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             o.id, o.programOpportunityName__c + ' ' + finalRecipients + ' ' + finalMessage);                   
                }          
                
                // PLM notification logic - Path 2 - include location in message
                If (oldMap.get(o.ID).stageName == 'CM Assignment' && o.stageName == 'Pricing Assignment') {
                    finalMessage = Utils.getMessageInnovationAndLocationSamples('MA~PA',o);

                    if(o.isPhyllo__c){
                        finalMessage = finalMessage.replaceAll('with no innovations at Not Applicable', 'Corning Bendable Glass with no innovations at Not Applicable');
                    }
                    
                    // recipients - includes innovation PLMs
                    baseRecipients = GGPartsSampleAutoNotifications__c.getValues('MA~PA').userIdList__c;
                    if (String.isEmpty(o.sampleInnovations__c) == False) {
                        combinedRecipients = baseRecipients + Utils.getInnovationRecipientsSamples(o);
                    } else {
                        combinedRecipients = baseRecipients;
                    }
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             o.id, o.programOpportunityName__c + ' ' + finalRecipients + ' ' + finalMessage);                   
                }                           
                
                // Customer Quotation notification logic
                If (oldMap.get(o.ID).stageName == 'Pricing Assignment' && o.stageName == 'Customer Quotation') {
                    finalMessage = Utils.getMessageInnovationAndLocationSamples('Quote',o);

                    if(o.isPhyllo__c){
                        finalMessage = finalMessage.replaceAll('with no innovations at Not Applicable', 'Corning Bendable Glass with no innovations at Not Applicable');
                    }
                    
                    // recipients
                    baseRecipients = '{' + (Id)o.ownerId + '}';
                    if (o.accountAEID__c != Null) {
                        baseRecipients = baseRecipients + ',{' + (id)o.accountAEId__c + '}';
                    }
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(baseRecipients);
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             o.id, o.programOpportunityName__c + ' ' + finalRecipients + ' ' + finalMessage);                   
                }   
                
                // Free Request notification logic
                //If (oldMap.get(o.ID).requestFreeSample__c == Null && o.requestFreeSample__c == 'Yes') {
                
                If (oldMap.get(o.ID).stageName != 'Non-paid Request' && o.stageName == 'Non-paid Request') {    
                    // determine approver based on role
                    if (o.Owner_Role__c.contains('Americas/EMEA')) freeApprover = 'Free~Americas/EMEA';
                    if (o.Owner_Role__c.contains('China/ODM/TPM/Finisher')) freeApprover = 'Free~China/ODM/TPM/Finisher';
                    if (o.Owner_Role__c.contains('Japan')) freeApprover = 'Free~Japan';
                    if (o.Owner_Role__c.contains('Korea')) freeApprover = 'Free~Korea';
                    if (o.Owner_Role__c.contains('China/OEM')) freeApprover = 'Free~China/OEM';
                    if (o.Owner_Role__c.contains('China/India')) freeApprover = 'Free~China/India';
                    if (o.Owner_Role__c.contains('Product Line Manager')) freeApprover = 'Free~Product Line Manager';
                    if (o.Owner_Role__c.contains('South East Asia')) freeApprover = 'Free~South East Asia';
                    if (o.Owner_Role__c.contains('Taiwan')) freeApprover = 'Free~Taiwan';
                    if (o.Owner_Role__c.contains('Blue')) freeApprover = 'Free~Blue';
                    
                    finalMessage = Utils.getMessageInnovationAndLocationSamples(freeApprover,o);

                    if(o.isPhyllo__c){
                        finalMessage = finalMessage.replaceAll('with no innovations at Not Applicable', 'Corning Bendable Glass with no innovations at Not Applicable');
                    }
                    
                    System.debug('Test is Phyllo '  + o.isPhyllo__c);
                    // recipients - includes innovation PLMs
                    if(!o.isPhyllo__c){
                        baseRecipients = GGPartsSampleAutoNotifications__c.getValues(freeApprover).userIdList__c;
                    }else{
                        baseRecipients = GGPartsSampleAutoNotifications__c.getValues('Phyllo').userIdList__c;
                    }
                    if (String.isEmpty(o.sampleInnovations__c) == False) {
                        combinedRecipients = baseRecipients + Utils.getInnovationRecipientsSamples(o);
                    } else {
                        combinedRecipients = baseRecipients;
                    }
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             o.id, o.programOpportunityName__c + ' ' + finalRecipients + ' ' + finalMessage);                   
                }
                
                // Non-paid Declined notification logic
                If (oldMap.get(o.ID).stageName == 'Non-paid Request' && o.stageName == 'Non-paid Declined') {
                    finalMessage = Utils.getMessageInnovationAndLocationSamples('Declined',o);

                    if(o.isPhyllo__c){
                        finalMessage = finalMessage.replaceAll('with no innovations at Not Applicable', 'Corning Bendable Glass with no innovations at Not Applicable');
                    }
                    
                    // recipients - includes innovation PLMs
                    baseRecipients = '{' + (Id)o.ownerId + '}';
                    if (o.accountAEID__c != Null) {
                        baseRecipients = baseRecipients + ',{' + (id)o.accountAEId__c + '}';
                    }
                    if (String.isEmpty(o.sampleInnovations__c) == False) {
                        combinedRecipients = baseRecipients + Utils.getInnovationRecipientsSamples(o);
                    } else {
                        combinedRecipients = baseRecipients;
                    }
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             o.id, o.programOpportunityName__c + ' ' + finalRecipients + ' ' + finalMessage);                   
                }
                
                // Cancelled notification logic - include location in message
                If (oldMap.get(o.ID).stageName != 'Cancelled' && o.stageName == 'Cancelled') {
                    finalMessage = Utils.getMessageInnovationAndLocationSamples('Cancelled',o);

                    if(o.isPhyllo__c){
                        finalMessage = finalMessage.replaceAll('with no innovations at Not Applicable', 'Corning Bendable Glass with no innovations at Not Applicable');
                    }
                    
                    // recipients - includes innovation PLMs
                    baseRecipients = GGPartsSampleAutoNotifications__c.getValues('Cancelled').userIdList__c;
                    baseRecipients = baseRecipients + ',{' + (Id)o.ownerId + '}';
                    if (o.accountAEID__c != Null) {
                        baseRecipients = baseRecipients + ',{' + (id)o.accountAEId__c + '}';
                    }
                    if (String.isEmpty(o.sampleInnovations__c) == False) {
                        combinedRecipients = baseRecipients + Utils.getInnovationRecipientsSamples(o);
                    } else {
                        combinedRecipients = baseRecipients;
                    }
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             o.id, o.programOpportunityName__c + ' ' + finalRecipients + ' ' + finalMessage);                   
                }                       
                
            }
            
            // ***** RAW GLASS LOGIC ***** 
            if (o.RecordTypeId == '0121J000000U1cbQAC' || o.RecordTypeId == '0121J000000U1caQAC') { 
                // Demand Ops notification logic
                If (oldMap.get(o.ID).stageName == 'New' && o.stageName == 'Commercial Assessment') {
                    
                    finalMessage = GGRawSampleAutoNotifications__c.getValues('N~CA').message__c;
                    finalRecipients = GGRawSampleAutoNotifications__c.getValues('N~CA').userIdList__c;                   
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             o.id, o.programOpportunityName__c + ' ' + finalRecipients + ' ' + finalMessage);
                } 
                
                // PLM notification logic
                If (oldMap.get(o.ID).stageName == 'Commercial Assessment' && o.stageName == 'PLM Assessment') {
                    // determine approver based on role and composition
                    
                    if (o.sampleGlassComposition__c.contains('3318')) rawApprover = 'CA~PA~3318~Blue';
                    if (o.sampleGlassComposition__c.contains('4318')) rawApprover = 'CA~PA~4318~Blue';
                    //if (o.sampleGlassComposition__c.contains('5318')) rawApprover = 'CA~PA~5318~Blue';
                    if (o.sampleGlassComposition__c.contains('7418')) rawApprover = 'CA~PA~7418~Blue';
                    if (o.sampleGlassComposition__c.contains('7418')) rawApprover = 'CA~PA~7518~Blue';
                    if (o.sampleGlassComposition__c.contains('9318')) rawApprover = 'CA~PA~9318~Blue';
                    if (o.sampleGlassComposition__c.contains('9319')) rawApprover = 'CA~PA~9319~Blue';
                    if (o.sampleGlassComposition__c.contains('Maxwell GC')) rawApprover = 'CA~PA~Maxwell~GC~Blue';
                    if (o.sampleGlassComposition__c.contains('MM-B')) rawApprover = 'CA~PA~MM-B~Blue';
                    if (o.sampleGlassComposition__c.contains('MX-B')) rawApprover = 'CA~PA~MX-B~Blue';
                    if (o.sampleGlassComposition__c.contains('PHY2')) rawApprover = 'CA~PA~PHY2~Blue'; 
                    if (o.sampleGlassComposition__c.contains('9724')) rawApprover = 'CA~PA~9724~Blue'; 
                    if (o.sampleGlassComposition__c.contains('9726')) rawApprover = 'CA~PA~9726~Blue';                           
                    
                    if (o.sampleGlassComposition__c.contains('2317')) rawApprover = 'CA~PA~2317';
                    if (o.sampleGlassComposition__c.contains('2318')) rawApprover = 'CA~PA~2318';
                    if (o.sampleGlassComposition__c.contains('2319')) rawApprover = 'CA~PA~2319';
                    if (o.sampleGlassComposition__c.contains('2320')) rawApprover = 'CA~PA~2320';
                    if (o.sampleGlassComposition__c.contains('2521')) rawApprover = 'CA~PA~2521';
                    if (o.sampleGlassComposition__c.contains('3318')) rawApprover = 'CA~PA~3318';
                    if (o.sampleGlassComposition__c.contains('5318')) rawApprover = 'CA~PA~5318';
                    if (o.sampleGlassComposition__c.contains('7321')) rawApprover = 'CA~PA~7321'; 
                    if (o.sampleGlassComposition__c.contains('7431')) rawApprover = 'CA~PA~7431'; 
                    if (o.sampleGlassComposition__c.contains('7541')) rawApprover = 'CA~PA~7541';                         
                    
                    
                    finalMessage = GGRawSampleAutoNotifications__c.getValues(rawApprover).message__c;
                    finalRecipients = GGRawSampleAutoNotifications__c.getValues(rawApprover).userIdList__c;                   
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             o.id, o.programOpportunityName__c + ' ' + finalRecipients + ' ' + finalMessage);                         
                } 
                
                // Customer Quotation notification logic
                If (oldMap.get(o.ID).stageName == 'PLM Assessment' && o.stageName == 'Customer Quotation') {
                    finalMessage = GGRawSampleAutoNotifications__c.getValues('Quote').message__c;
                    
                    // recipients
                    baseRecipients = '{' + (Id)o.ownerId + '}';
                    if (o.accountAEID__c != Null) {
                        baseRecipients = baseRecipients + ',{' + (id)o.accountAEId__c + '}';
                    }
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(baseRecipients);
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             o.id, o.programOpportunityName__c + ' ' + finalRecipients + ' ' + finalMessage);                   
                }   
                
                // Free Request notification logic
                //If (oldMap.get(o.ID).requestFreeSample__c == Null && o.requestFreeSample__c == 'Yes') {
                
                If (oldMap.get(o.ID).stageName != 'RSM Approval' && o.stageName == 'RSM Approval') {
                    // determine approver based on role
                    if (o.Owner_Role__c.contains('Americas/EMEA')) freeApprover = 'Free~Americas/EMEA';
                    if (o.Owner_Role__c.contains('China/ODM/TPM/Finisher')) freeApprover = 'Free~China/ODM/TPM/Finisher';
                    if (o.Owner_Role__c.contains('Japan')) freeApprover = 'Free~Japan';
                    if (o.Owner_Role__c.contains('Korea')) freeApprover = 'Free~Korea';
                    if (o.Owner_Role__c.contains('China/OEM')) freeApprover = 'Free~China/OEM';
                    if (o.Owner_Role__c.contains('China/India')) freeApprover = 'Free~China/India';
                    if (o.Owner_Role__c.contains('Product Line Manager')) freeApprover = 'Free~Product Line Manager';
                    if (o.Owner_Role__c.contains('South East Asia')) freeApprover = 'Free~South East Asia';
                    if (o.Owner_Role__c.contains('Taiwan')) freeApprover = 'Free~Taiwan';
                    if (o.Owner_Role__c.contains('Blue')) freeApprover = 'Free~Blue';
                    
                    finalMessage = GGRawSampleAutoNotifications__c.getValues(freeApprover).message__c;
                    if(o.isPrebuild__c && o.StageName != 'Non-paid Request'){
                        finalMessage = finalMessage.replaceAll(': Free Parts ', ': Urgent Paid ');
                    }
                    finalRecipients = GGRawSampleAutoNotifications__c.getValues(freeApprover).userIdList__c;
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             o.id, o.programOpportunityName__c + ' ' + finalRecipients + ' ' + finalMessage);                   
                }
                
                // Non-paid Declined notification logic
                If (oldMap.get(o.ID).stageName == 'Non-paid Request' && o.stageName == 'Non-paid Declined') {
                    finalMessage = GGRawSampleAutoNotifications__c.getValues('Declined').message__c;
                    
                    // recipients
                    baseRecipients = '{' + (Id)o.ownerId + '}';
                    if (o.accountAEID__c != Null) {
                        baseRecipients = baseRecipients + ',{' + (id)o.accountAEId__c + '}';
                    }
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(baseRecipients);
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             o.id, o.programOpportunityName__c + ' ' + finalRecipients + ' ' + finalMessage);                   
                }
                
                // Cancelled notification logic
                If (oldMap.get(o.ID).stageName != 'Cancelled' && o.stageName == 'Cancelled') {
                    finalMessage = GGRawSampleAutoNotifications__c.getValues('Cancelled').message__c;
                    
                    // recipients
                    baseRecipients = '{' + (Id)o.ownerId + '}';
                    if (o.accountAEID__c != Null) {
                        baseRecipients = baseRecipients + ',{' + (id)o.accountAEId__c + '}';
                    }
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(baseRecipients);
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             o.id, o.programOpportunityName__c + ' ' + finalRecipients + ' ' + finalMessage);                   
                }                                           
                
            }
            //sending notification to chatter when the opportunity is in Pricing Assignmnet by mentioning PLM also
            /*if(o.RecordtypeId == ggPhylloRTID){
                if(oldMap.get(o.ID).stageName == 'New' && o.StageName == 'Pricing Assignment'){
                    User u = [SELECT Id,Name FROM User WHERE Name = 'Dao Nguyen'];
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             o.id, o.programOpportunityName__c + ' {' + u.Id + '} ' + 'Opportunity is in Pricing Assignment, Please Approve it accordingly.');
                }
                
            }*/
        } 
    }
    
    public Static Void unFollowSample(List<Opportunity> opplist) {
        
        Set<Id> unfollowSet = new Set<Id>();
        system.debug('*** UNFOLLOW');
        
        // pricing approved is always the final value for all approved specs - all product lines
        for(opportunity o : opplist) {   
            system.debug('*** ' + o.stageName);
            if (o.stageName == 'Shipped Complete' || o.stageName == 'Cancelled') {
                unfollowSet.add(o.Id);
            }
        }
        
        if(unfollowSet.size() > 0) {
            try {
                List<EntitySubscription> removals = new List<EntitySubscription>();                
                removals = [SELECT Id FROM EntitySubscription WHERE ParentId IN : unfollowSet];
                if(!removals.isEmpty()){
                    delete removals ;
                }                
            } catch( Exception ex ) {
                system.debug('Exception: ' + ex.getMessage());
            }
        }
    }
    
    public Static Void followSample(List<Opportunity> opplist) {
        
        // list for EntitySubscriptions to insert
        List<EntitySubscription> subscriptionList = new List <EntitySubscription>();
        
        for (opportunity o:opplist) {
            if (((o.RecordTypeId == '0121J000000U1cXQAS' || o.RecordTypeId == '0121J000000U1cYQAS') && (o.stageName == 'CM Assignment' || o.stageName == 'Pricing Assignment')) 
                || ((o.RecordTypeId == '0121J000000U1caQAC' || o.RecordTypeId == '0121J000000U1cbQAC') && o.stageName == 'Commercial Assessment')) {
                    
                    // always add the SR owner
                    subscriptionList.add(New EntitySubscription(ParentId = o.Id, SubscriberId = String.valueOf(o.ownerid).substring(0, 15)));
                    
                    // add the AE from the SR account mapping if not already added to Subscription List
                    if (o.accountAEId__c != NULL) {
                        if (String.valueOf(o.accountAEId__c).substring(0, 15) != String.valueOf(o.ownerid).substring(0, 15)) {
                            subscriptionList.add(New EntitySubscription(ParentId = o.Id, SubscriberId = String.valueOf(o.accountAEId__c).substring(0, 15)));
                        }
                    }              
                }    
        }
        
        Database.SaveResult[] srList = Database.insert(subscriptionList, false);
        
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted EntitySubscription. EntitySubscription ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('EntitySubscription fields that affected this error: ' + err.getFields());
                }
            }
        }
        
    }
    
    /*//method to send approval notification to user manager when opportunity stage become 'Urgent Paid Sample Build Request' and submitted for approval
public Static void sendApprovalNotification(List<Opportunity> opplist,Map<Id,Opportunity> oldOppById) {
//getting current user by UserInfo class method  
User u = [SELECT Id, Name, UserRole.Name, ManagerId FROM User WHERE Id = :UserInfo.getUserId()];
System.debug('UserRole.Name ==>' + u.UserRole.Name);
for (opportunity opp : opplist) {
if(opp.StageName != oldOppById.get(opp.Id).StageName
&& opp.StageName == 'RSM Approval'
&& opp.isPrebuild__c){
System.debug('this notification has been removed.');
//ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
//opp.Id, u.ManagerId == null ? 'Please check the opportunity stage is in \'RSM Approval\' and approve it accordingly. Thank you.' 
//                    : '{' + u.ManagerId + '}'+' Please check the opportunity stage is in \'RSM Approval\' and approve it accordingly. Thank you.');    
// System.debug('Approval notification sent successfully');
}    
}

}*/
}