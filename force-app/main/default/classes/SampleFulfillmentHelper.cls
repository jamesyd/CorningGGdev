///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 3/16/2017 ***///
///*** Class to help sample fulfillment trigger ***///

/*11 June 2020, Ata, Added the functionality to check the Planner Role, if the stage changed to "cancelled"*/

public with sharing class SampleFulfillmentHelper {
    static Utilities Utils = new Utilities();
    
    // set location assignent date once is is set and saved for the first time
    public static void setLocationAssignmentDate(List<SampleFulfillment__c> fulfillments, Map<Id, SampleFulfillment__c> oldMap) {
        for (SampleFulfillment__c f : fulfillments) {
            // only set once
            if ((oldMap.get(f.Id).locationAssignmentDate__c == Null && f.fulfillmentLocation__c != Null)) {
                f.locationAssignmentDate__c = Date.today();
            }
        }
    }
    
    // set original commit date once is is set and saved for the first time
    // updated method to include other dates
    public static void setOriginalCommitDate(List<SampleFulfillment__c> fulfillments, Map<Id, SampleFulfillment__c> oldMap) {
        //Set<Id> sampleOppIdSet = new Set<Id>(); 
        Map<Id, Opportunity> opportunityByOppId = new Map<Id, Opportunity>();
        for(SampleFulfillment__c f : fulfillments){
            opportunityByOppId.put(f.opportunity__c, null);    
        }
        for(Opportunity opp : [Select Id, OwnerId, Sample_Request_Number__c From Opportunity WHERE Id IN :opportunityByOppId.keySet()]){
            opportunityByOppId.put(opp.Id, opp);
        }
        for (SampleFulfillment__c f : fulfillments) {
            //sampleOppIdSet.add(f.opportunity__c);
            // set original commit date and the date the field was set
            if ((oldMap.get(f.Id).originalCommitDate__c == Null && f.commitDate__c != Null)) {
                f.originalCommitDate__c = f.commitDate__c;
                f.commitDateSetDate__c = Date.today();
            }
            
            // set maintenance commit date when commit date changes
            // if ((oldMap.get(f.Id).originalCommitDate__c != Null && f.commitDate__c != Null) && (oldMap.get(f.Id).originalCommitDate__c != f.commitDate__c)) {
            if ((oldMap.get(f.Id).commitDate__c != f.commitDate__c)) {         
                f.commitDateMaintenanceDate__c = Date.today();
                Datetime dtStartDate = (Datetime)f.commitDate__c;
                //Opportunity op = [Select Id, OwnerId, Sample_Request_Number__c From Opportunity WHERE Id IN :sampleOppIdSet];
                //User name =  [SELECT FirstName, LastName FROM User WHERE Id=:op.OwnerId];
                Opportunity opp = opportunityByOppId.get(f.opportunity__c);
                ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                         f.Id, '{' + opp.OwnerId + '}'+' Commit Date is updated as '+ dtStartDate.format('MM/dd/yyyy')+' - '+ opp.Sample_Request_Number__c);
            }
            
            // set date the ship date field was set            
            if ((oldMap.get(f.Id).shipDate__c == Null && f.shipDate__c != Null)) {
                f.shipDateSetDate__c = Date.today();
            }
            
            // set maintenance ship date when ship date changes
            if ((oldMap.get(f.Id).shipDate__c != f.shipDate__c)) {
                f.shipDateMaintenanceDate__c = Date.today();
                Datetime dtStartDate = (Datetime)f.shipDate__c;
                //Opportunity op = [Select Id, OwnerId, Sample_Request_Number__c From Opportunity WHERE Id IN :sampleOppIdSet];
                // User name =  [SELECT FirstName, LastName FROM User WHERE Id=:op.OwnerId];
                Opportunity opp = opportunityByOppId.get(f.opportunity__c);
                ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                         f.Id, '{' + opp.OwnerId + '}'+' Ship Date is updated as '+ dtStartDate.format('MM/dd/yyyy')+' - '+ opp.Sample_Request_Number__c);
                
            } 
            
        }
    }
    
    
    
    // set specification on sample fulfillment record to specification tied to product if available (Parts and MTO)
    public static void setSpecification(List<SampleFulfillment__c> fulfillments) {
        
        Set<Id> sampleOppIdSet = new Set<Id>();        
        for (SampleFulfillment__c f : fulfillments) {
            sampleOppIdSet.add(f.opportunity__c);
        }
        
        // query opportunity products associated with these sample fulfillments' related opportunity
        List<OpportunityLineItem> oliList = [SELECT Id, OpportunityId, specification__c FROM OpportunityLineItem WHERE OpportunityId IN :sampleOppIdSet];
        
        // create a oppId & specId map; there is one OLI for each sample request opportuniy
        Map<String, Id> oppSpecMap = new Map<String, Id>();
        for (OpportunityLineItem oli : oliList) {
            oppSpecMap.put(oli.opportunityId, oli.specification__c);
        }
        
        for (SampleFulfillment__c sf : fulfillments) {
            sf.specification__c = oppSpecMap.get(sf.opportunity__c);
        }
    }
    
    // AN - 8/7/18 this method is not used since shipping address has been removed from sample fulfillment 
    public static void setShippingAddress(list<SampleFulfillment__c> samples) {
        Set<Id> sampleContactIdSet = new Set<Id>();
        
        for (SampleFulfillment__c sample : samples) { 
            sampleContactIdSet.add(sample.shipToContact__c);
        }
        
        list<Contact> contactList = [SELECT Id, MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity 
                                     FROM Contact
                                     WHERE Id IN :sampleContactIdSet];                           
        
        for (SampleFulfillment__c sample : samples) { 
            for (Contact c : contactList) {
                if (sample.shipToContact__c == c.id) {
                    if (string.isBlank(sample.streetAddress__c) && string.isBlank(sample.zip__c) 
                        && string.isBlank(sample.city__c) && string.isBlank(sample.state__c) && string.isBlank(sample.country__c)) {
                            sample.streetAddress__c = c.MailingStreet;
                            sample.city__c = c.MailingCity;
                            sample.state__c = c.MailingState;
                            sample.zip__c = c.MailingPostalCode;
                            sample.country__c = c.MailingCountry;
                        }
                }
            }   
        } 
    }
    
    public static void checkSampleQuantities(list<SampleFulfillment__c> samples){
        Set<Id> sampleOppIdSet = new Set<Id>();
        Set<Id> sampleIdSet = new Set<Id>();
        map<Id,decimal> sampleQuantityMap = new map<id, decimal>();
        map<Id,decimal> oliQuantityMap = new map<id, decimal>();
        //system.debug('samples='+samples);
        
        for (SampleFulfillment__c sample : samples) {
            sampleOppIdSet.add(sample.opportunity__c);
            if (sample.Id <> null){
                sampleIdSet.add(sample.id);
            }
        }
        //system.debug('sampleOppIdSet='+sampleOppIdSet);
        //Retrieve all OpportunityLineItem records for the Opportunities referenced in the incoming Sample Fulfillment records. 
        //Sum the quantities shown in the OLI records
        //Build a map of that quantity to Opp Id
        for (OpportunityLineItem sampleOLI : [SELECT Id, OpportunityId, sampleQuantity__c 
                                              FROM OpportunityLineItem 
                                              WHERE OpportunityId IN :sampleOppIdSet]) {
                                                  //system.debug('sampleOLI='+sampleOLI);
                                                  decimal x = 0;
                                                  if (oliQuantityMap.get(sampleOLI.OpportunityId) == NULL) {
                                                      oliQuantityMap.put(sampleOLI.OpportunityId, sampleOLI.sampleQuantity__c);
                                                  }
                                                  else {
                                                      x = oliQuantityMap.get(sampleOLI.OpportunityId);
                                                      x +=  sampleOLI.sampleQuantity__c;
                                                      oliQuantityMap.put(sampleOLI.OpportunityId, x); 
                                                  }
                                              }
        //system.debug('oliQuantityMap='+oliQuantityMap);
        
        //Retrieve all the Sample Fulfillment records for the Opportunities referenced in the incoming Sample Fulfillment records
        //Sum the quantities shown in the Sample Fulfillment records.
        //Build a map of that quantity to Opp Id
        for (SampleFulfillment__c sample : [SELECT Id, quantity__c, Opportunity__c 
                                            FROM SampleFulfillment__c 
                                            WHERE Opportunity__c IN :sampleOppIdSet]) {
                                                decimal y = 0;
                                                if (!sampleIdSet.contains(sample.Id)) { 
                                                    if (sampleQuantityMap.get(sample.Opportunity__c) == NULL) {
                                                        sampleQuantityMap.put(sample.Opportunity__c, sample.quantity__c);
                                                    }
                                                    else {
                                                        y = sampleQuantityMap.get(sample.Opportunity__c);
                                                        y +=  sample.quantity__c;
                                                        sampleQuantityMap.put(sample.Opportunity__c, y); 
                                                    }
                                                }
                                            }
        //system.debug('sampleQuantityMap='+sampleQuantityMap);
        for (SampleFulfillment__c sample : samples) {
            //system.debug('sample.Quantity__c='+sample.quantity__c);
            //Summed Quantity from OLI records related to this sample Opportunity
            decimal oliSampleQuantity = 0;
            if (oliQuantityMap.get(sample.Opportunity__c) <> null){
                oliSampleQuantity = oliQuantityMap.get(sample.Opportunity__c);
            }
            //system.debug('oliSampleQuantity='+oliSampleQuantity);
            //Summed Quantity from Sample Fulfillment records related to this sample Opportunity
            decimal sampleFulfillmentQuantity = 0;
            if (sampleQuantityMap.get(sample.Opportunity__c) <> null){
                sampleFulfillmentQuantity = sampleQuantityMap.get(sample.Opportunity__c);
            }
            //system.debug('sampleFulfillmentQuantity='+sampleFulfillmentQuantity);
            //Add the new fulfillment quantity to the already existing quantity and compare to OLI quantity
            if (sample.quantity__c <> NULL 
                && sample.quantity__c + sampleFulfillmentQuantity > oliSampleQuantity) {
                    sample.addError(Label.GGSampleQuantityExceeded);
                }
        } 
    }
    
    //if commit date is set, set the status to scheduled
    //if ship date is set, set the status to shipped
    public static void updateStatus(List<SampleFulfillment__c> samples, Map<Id, SampleFulfillment__c> oldMap){
        SampleFulfillment__c oldSample;
        for (SampleFulfillment__c sample: samples){
            oldSample = oldMap.get(sample.Id);
            if (oldSample.commitDate__c == null && sample.commitDate__c != null && sample.status__c != 'Scheduled'){
                sample.status__c = 'Scheduled';
            }
            if (oldSample.shipDate__c == null && sample.shipDate__c != null && sample.status__c != 'Shipped'){
                sample.status__c = 'Shipped';
            }
        }
    }
    
    public static void setOpportunityStage(list<SampleFulfillment__c> samples){
        Set<Id> sampleIdSet = new Set<Id>();
        Set<string> screeningStageSet = new Set<string>{'Fulfillment', 'Shipped Partial', 'Shipped Complete', 'Order Pending'};
            
            // AN - 11/21 - only allow cancellation at prior stages 
            Set<string> cancelOnlyScreeningStageSet = new Set<string>{'CM Assignment', 'Pricing Assignment', 'Customer Quotation', 'Customer Decision', 'Commercial Assessment', 'PLM Assessment', 'RSM Approval', 'Non-paid Declined'};
                
                list<Opportunity> oppUpdateList = new list <Opportunity>();
        
        for (SampleFulfillment__c sample : samples) {
            sampleIdSet.add(sample.opportunity__c);
        }
        
        boolean scheduled;
        //Retrieve all the Opportunity records (with their related Sample Fulfillment records) for the 
        //Opportunities referenced in the incoming Sample Fulfillment records
        for (Opportunity oppRec : [SELECT Id, StageName, 
                                   (SELECT Id, Status__c,fulfillmentLocation__c FROM Sample_Fulfillments__r) 
                                   FROM Opportunity 
                                   WHERE Id IN :sampleIdSet]){
                                       scheduled = false;
                                       //system.debug('oppRec.StageName='+oppRec.StageName);
                                       
                                       //Screen by Opportunity Stage of Fulfillment/Shipped Partial/Shipped Complete/Order Pending
                                       if (screeningStageSet.contains(oppRec.StageName)) {
                                           integer allRecs = 0, complete = 0, cancelled = 0, partial = 0;
                                           //Count up how many sample fulfillment records are in each status (for each Opportunity)
                                           for (SampleFulfillment__c oppSample : oppRec.Sample_Fulfillments__r) {
                                               allRecs++;
                                               if (oppSample.Status__c == 'Cancelled' || oppSample.Status__c == 'Shipped'){
                                                   complete++;
                                                   if (oppSample.Status__c == 'Cancelled') {
                                                       cancelled++;
                                                   }
                                               }
                                               else if (oppSample.Status__c == 'Scheduled'){// || oppSample.Status__c == 'Inventory') {
                                                   //partial++;
                                                   scheduled = true;
                                               }
                                               //system.debug('oppSample.status: ' + oppSample.Status__c);
                                           } 
                                           
                                           //If count for a particular Sample status matches total number of Sample records, set the Opportunity to specified Stage value
                                           if (partial > 0) {//== allRecs) {
                                               oppRec.StageName = 'Shipped Partial';
                                               oppUpdateList.add(oppRec);
                                           }
                                           else if (cancelled == allRecs) {
                                               oppRec.StageName = 'Cancelled';
                                               oppUpdateList.add(oppRec);
                                           }
                                           else if (complete == allRecs) {
                                               oppRec.StageName = 'Shipped Complete';
                                               oppUpdateList.add(oppRec);
                                           }else if (complete > 0 && complete < allRecs){
                                               oppRec.StageName = 'Shipped Partial';
                                               oppUpdateList.add(oppRec);
                                           }else if (scheduled && oppRec.StageName == 'Order Pending'){
                                               oppRec.StageName = 'Fulfillment';
                                               oppUpdateList.add(oppRec);
                                           }
                                       }
                                       
                                       //if the sample is in CM assignment and all the sample fulfillment records have manufacturing assignment,
                                       //set the sample to Pricing Assignment
                                       if (oppRec.StageName == 'CM Assignment'){
                                           integer sfCount = 0;
                                           integer fulfillmentAssignmentCount = 0;
                                           //Count up how many sample fulfillment records have fulfillment location assigned
                                           for (SampleFulfillment__c oppSample : oppRec.Sample_Fulfillments__r) {
                                               sfCount++;
                                               if (oppSample.fulfillmentLocation__c != null){
                                                   fulfillmentAssignmentCount++;
                                               }
                                               //system.debug('oppSample.status: ' + oppSample.Status__c);
                                           }
                                           if (sfCount == fulfillmentAssignmentCount){
                                               oppRec.stageName = Label.GGSamplePricingAssignment;
                                               oppUpdateList.add(oppRec);
                                           }
                                       }   
                                       
                                       // ***** New Code AN 11/21
                                       
                                       //Screen by Opportunity Stage that allows early cancellation
                                       if (cancelOnlyScreeningStageSet.contains(oppRec.StageName)) {
                                           integer allRecs = 0, complete = 0, cancelled = 0, partial = 0;
                                           
                                           //Count up how many sample fulfillment records are in each status (for each Opportunity)
                                           for (SampleFulfillment__c oppSample : oppRec.Sample_Fulfillments__r) { // AN - reuse original logic from above
                                               allRecs++;
                                               if (oppSample.Status__c == 'Cancelled' || oppSample.Status__c == 'Shipped'){
                                                   complete++;
                                                   if (oppSample.Status__c == 'Cancelled') {
                                                       cancelled++;
                                                   }
                                               }
                                               else if (oppSample.Status__c == 'Scheduled'){// || oppSample.Status__c == 'Inventory') {
                                                   //partial++;
                                                   scheduled = true;
                                               }
                                               
                                           } 
                                           
                                           // AN - only update cancelled for these stages
                                           if (cancelled == allRecs) {
                                               oppRec.StageName = 'Cancelled';
                                               oppUpdateList.add(oppRec);
                                           }
                                       }
                                       
                                       // ***** End New Code
                                   }
        if (oppUpdateList.size() > 0) {
            update oppUpdateList;
        }
    }
    
    //method to check if the PO Number, Peoplesoft_Order_Number__c and POReceivingDate__c have a value in them then update the stage
    //of opportunity to Cancelled
    public static void onBeforeInsert(List<SampleFulfillment__c> samples){
        List<Opportunity> opportunities = new List<Opportunity>();
        for(SampleFulfillment__c sample : samples){
            if(sample.PO_Number__c != null && sample.Peoplesoft_Order_Number__c != null &&  sample.POReceivingDate__c != null
               && sample.PO_Number__c != '' && sample.Peoplesoft_Order_Number__c != ''){
                   opportunities.add(new Opportunity(Id = sample.opportunity__c, StageName = 'PO Received'));    
               }
        }
        
        if(opportunities.size() > 0){
            //updating opportunity
            updateOpportunityStage(opportunities);
        }
        Map<Id, Opportunity> opportunityById = getOpportunities(samples);
        System.debug('opportunityById%%%%%>' + opportunityById);
        List<SampleFulfillment__c> samplesToUse = new List<SampleFulfillment__c>();
        for(SampleFulfillment__c sf : samples){
            if(sf.status__c == 'Cancelled' && opportunityById.get(sf.opportunity__c).isPreBuild__c){
                samplesToUse.add(sf);
            }
        }
        if(samplesToUse.size() > 0){
            checkSampleFulfillmentPlanner(samplesToUse);
        }
    }
    
    //method to check if the PO Number, Peoplesoft_Order_Number__c and POReceivingDate__c have a value in them then update the stage
    //of opportunity to Cancelled
    public static void onBeforeUpdate(List<SampleFulfillment__c> samples, Map<Id, SampleFulfillment__c> oldMap){
        List<Opportunity> opportunities = new List<Opportunity>();
        
        //checking if there is change in any of these three field, if true then update the change
        for(SampleFulfillment__c sample : samples){
            if((sample.PO_Number__c != oldMap.get(sample.Id).PO_Number__c 
                || sample.Peoplesoft_Order_Number__c != oldMap.get(sample.Id).Peoplesoft_Order_Number__c
                || sample.POReceivingDate__c != oldMap.get(sample.Id).POReceivingDate__c)
               && (sample.PO_Number__c != null && sample.Peoplesoft_Order_Number__c != null &&  sample.POReceivingDate__c != null
                   && sample.PO_Number__c != '' && sample.Peoplesoft_Order_Number__c != '')
              ){
                  opportunities.add(new Opportunity(Id = sample.opportunity__c, StageName = 'PO Received'));    
              }
        }
        
        if(opportunities.size() > 0){
            //updating opportunity
            updateOpportunityStage(opportunities);
        }
        Map<Id, Opportunity> opportunityById = getOpportunities(samples);
        List<SampleFulfillment__c> samplesToUse = new List<SampleFulfillment__c>();
        for(SampleFulfillment__c sf : samples){
            if(sf.status__c != oldMap.get(sf.Id).status__c && sf.status__c == 'Cancelled'  
               && opportunityById.get(sf.opportunity__c).isPreBuild__c){
                   samplesToUse.add(sf);
               }
        }
        if(samplesToUse.size() > 0){
            checkSampleFulfillmentPlanner(samplesToUse);
        }
    }
    
    public static Map<Id, Opportunity> getOpportunities(List<SampleFulfillment__c> samples){
        Map<Id, Opportunity> opportunityById = new Map<Id, Opportunity>();
        for(SampleFulfillment__c sf : samples){
            opportunityById.put(sf.opportunity__c, null);
        }
        System.debug('opportunityById$$$$$$$>' + opportunityById);
        for(Opportunity opp : [SELECT Id, isPreBuild__c
                               FROM Opportunity 
                               WHERE Id IN :opportunityById.keySet()]){
                                   opportunityById.put(opp.Id, opp);
                               }
        
        return opportunityById;
    }
    
    //updating the opportunity list if the list size is greater then zero
    private static void updateOpportunityStage(List<Opportunity> opportunities){
        if(opportunities.size() > 0){
            UPDATE opportunities;
        }     
    }
    
    private static void checkSampleFulfillmentPlanner(List<SampleFulfillment__c> samples){
        try{
            User u = [
                SELECT Id, Name, Email 
                FROM User 
                WHERE Id = :UserInfo.getUserId()
                AND (UserRole.Name = 'GG Allocation Team/Planner' 
                     OR Profile.Name = 'GG Account Manager' 
                     OR Profile.Name = 'GG Application Engineer')
                LIMIT 1
            ];
        }catch(Exception e){
            for(SampleFulfillment__c sf :samples){
                sf.addError('Only Planner can change the status of fulfillment to Cancelled');
            }
        }
    }
    
    //getting emial ids of planners that is stored in custom labels
    private static Set<String> getPlannersEmailIds(){
        Set<String> emailIds = new Set<String>();
        if(STRING.ISNOTBLANK(System.label.PlannerEmailIds)){
            for(String emailId: System.label.PlannerEmailIds.split(';')){
                emailIds.add(emailId);
            }
        }
        return emailIds;
        //return new List<String>{'atasuperfusion@gmail.com'};
    }
    
    //action on records on after Insert event call from this method 
    public static void onAfterInsert(List<SampleFulfillment__c> samples){
        Map<Id, Opportunity> opportunityById = new Map<Id, Opportunity>();
        List<SampleFulfillment__c> samplesToUse = new List<SampleFulfillment__c>();
        
        for(SampleFulfillment__c sf : samples){
            if(sf.status__c == 'Cancelled'){
                opportunityById.put(sf.opportunity__c, null);
            }
        }
        
        for(Opportunity opp : [SELECT Id, isPreBuild__c FROM Opportunity WHERE Id IN :opportunityById.keySet()]){
            opportunityById.put(opp.Id, opp);
        }
        
        //checking samples who's is stage is equal to cancelled and adding them to list
        for(SampleFulfillment__c sf : samples){
            if(sf.status__c == 'Cancelled' && opportunityById.get(sf.opportunity__c).isPreBuild__c){
                samplesToUse.add(sf);
            }
        }
        if(samplesToUse.size() > 0){
            sendChatterNotification(samplesToUse);
        }
        
        
    }
    
    //action on records on after Update event call from this method 
    public static void onAfterUpdate(List<SampleFulfillment__c> samples, Map<Id, SampleFulfillment__c> oldMap){
        Map<Id, Opportunity> opportunityById = new Map<Id, Opportunity>();
        List<SampleFulfillment__c> samplesToUse = new List<SampleFulfillment__c>();
        for(SampleFulfillment__c sf : samples){
            if(sf.status__c == 'Cancelled'){
                opportunityById.put(sf.opportunity__c, null);
            }
        }
        
        for(Opportunity opp : [SELECT Id, isPreBuild__c FROM Opportunity WHERE Id IN :opportunityById.keySet()]){
            opportunityById.put(opp.Id, opp);
        }
        
        for(SampleFulfillment__c sf : samples){
            //checking samples who's is stage is equal and changed to cancelled and adding them to list
            if(sf.status__c != oldMap.get(sf.Id).status__c && sf.status__c == 'Cancelled'  
               && opportunityById.get(sf.opportunity__c).isPreBuild__c){
                   samplesToUse.add(sf);
               }
        }
        if(samplesToUse.size() > 0){
            sendChatterNotification(samplesToUse);
        }
    }
    
    //sending notification to chatter when current user profile is AM/AE
    public static void sendChatterNotification(List<SampleFulfillment__c> samples){
        
        //getting current profile by UserInfo Class
        Profile p = [SELECT Id, Name FROM Profile WHERE id = :UserInfo.getProfileId()];
        List<User> users = [SELECT Id, Name FROM USER WHERE Email IN :getPlannersEmailIds()];
        Set<String> profileNames = new Set<String>{'GG Account Manager', 'GG Application Engineer'};
            String usersToMention = '';    
        if(users.size() > 0){
            for(User u : users){
                usersToMention += '{' + u.Id +'} ' ;
            }
        }
        System.debug('User$$$$$=>' + users);
        //checking if the current user profile is equal to AM/AE then sending chatter notification via Connect API
        if(profileNames.contains(p.Name)){
            for(SampleFulfillment__c sf :samples){
                ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                         sf.Id, 'Only Planners have permission to cancel the Urgent Paid Sample Request. Please contact ' + usersToMention + ' by mannual first.');
            }
        }
    }
}