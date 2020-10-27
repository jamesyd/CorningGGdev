///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 2/5/2017 ***///
///*** Class to log step duration changes for specification and opportunity changes ***///
public class StepDurationLogger {
   static list <string> sampleOppRecordTypes;
   
   //log individual innovation approvals
   private static void logSpecificationInnovationApprovals(Specification__c oldSpec, Specification__c newSpec, list<StepDuration__c> sdList, Id businessHoursId){
       
        //log individual innovation approvals - the fields to be tracked are set up in the InnovationApprovalTrack fieldset
        List<Schema.FieldSetMember> fieldsToTrack = Schema.SObjectType.Specification__c.FieldSets.InnovationApprovalTrack.getFields();
        datetime previousStepDateTime = (oldSpec.previousStepDateTime__c != NULL) ? oldSpec.previousStepDateTime__c : system.Now();
        list<string> fNameList = new list<string>();
        String fPath;
        for (FieldSetMember f: fieldsToTrack){
            fPath = f.getFieldPath();
            if (oldSpec.get(fPath) != newSpec.get(fPath)){
                StepDurationLogger.createStepDurationRecord('SPEC',sdList, newSpec.Id, oldSpec.status__c, newSpec.status__c + ' - ' + f.getLabel() + ' ' + newSpec.get(fPath), previousStepDateTime, businessHoursId);
            }
        }
        
   }
   
   //Create a StepDuration__c record and set spec id/prior step/new step
   public static void LogSpecificationStep(list<Specification__c> afterList, map<ID, Specification__c> beforeMap){
        list<StepDuration__c> sdList = new list<StepDuration__c>();
        Id businessHoursId = getMondayFridayBusinessHours();
        for (Specification__c newSpec : afterList){
            Specification__c oldSpec = beforeMap.get(newSpec.Id);
            if (oldSpec <> NULL && newSpec.status__c <> oldSpec.status__c) {
                newSpec.previousStepDateTime__c = system.Now();
                datetime previousStepDateTime = (oldSpec.previousStepDateTime__c != NULL) ? oldSpec.previousStepDateTime__c : system.Now();
 
                StepDurationLogger.createStepDurationRecord('SPEC',sdList, newSpec.Id, oldSpec.status__c, newSpec.status__c, previousStepDateTime, businessHoursId);
            }
            
            //track innovation changes
            if (oldSpec != null){
                
                logSpecificationInnovationApprovals(oldSpec, newSpec, sdList,businessHoursId);
            }
        }
     
        if (sdList.size() > 0) insert sdList;
    }
    
    //Create a StepDuration__c  record and set optty id/prior step/new step
    public static void LogOpportunityStep(list<Opportunity> afterList, map<ID, Opportunity> beforeMap){
        list<StepDuration__c> sdList = new list<StepDuration__c>();
        set<string> oppRecTypes = new set<string>();
        oppRecTypes = StepDurationLogger.getSampleOppRecordTypes();
        Id businessHoursId = getMondayFridayBusinessHours();
        for (Opportunity newOpp : afterList){
            if (oppRecTypes.contains(newOpp.RecordTypeId)) { 
                Opportunity oldOpp = beforeMap.get(newOpp.Id);
                if (oldOpp <> NULL && newOpp.StageName <> oldOpp.StageName) {
                    newOpp.previousStepDateTime__c = system.Now();
                    datetime previousStepDateTime = (oldOpp.previousStepDateTime__c != NULL) ? oldOpp.previousStepDateTime__c : system.Now();
     
                    StepDurationLogger.createStepDurationRecord('OPP', sdList, newOpp.Id, oldOpp.StageName, newOpp.StageName, previousStepDateTime, businessHoursId);
                }
            }
        }
    
        if (sdList.size() > 0) insert sdList;
    }
    
    //If there is a Monday/Friday business hours record created, use that to calculate business hours
    public static Id getMondayFridayBusinessHours(){
        //get Monday through Friday business hours
        Id bhId = [SELECT Id FROM BusinessHours WHERE IsDefault = true][0].Id;
        for (BusinessHours bh: [SELECT Id FROM BusinessHours WHERE Name = 'Monday-Friday Only' AND IsActive=True]){
            bhId = bh.Id;
            break;
        } 
        return bhId;
    }
    
    //create a step duration record 
    @TestVisible
    private static void CreateStepDurationRecord(string obj, list<StepDuration__c> theList, Id recId, String priorStep, String newStep, Datetime stepTime, Id businessHoursId) {
        StepDuration__c newSD = new StepDuration__c();
        if (obj == 'SPEC') {
            newSD.specification__c = recId;
        }
        else if (obj =='OPP'){
            newSD.opportunity__c = recId;
        }
        
        newSD.previousStep__c = priorStep;
        newSD.newStep__c = newStep;
        newSD.previousStepDateTime__c = stepTime;
        newSd.newStepDateTime__c = DateTime.Now();
        //calculate step duration using businesshours
        //BusinessHours.diff returns time difference in miliseconds, convert it to seconds, minutes and then to hour
        newSD.calculatedStepDurationHours__c = (BusinessHours.diff(businesshoursId, newSD.previousStepDateTime__c, newSD.newStepDateTime__c)*0.001)/60/60;
        //
        
        theList.add(newSD);
        
    }
    
    @TestVisible
    private static set<string> getSampleOppRecordTypes() {
        list<RecordType> rtList = new list<RecordType>();
        set<string> rtSet = new set<string>();
        
        string fnd = '%' + 'Sample' + '%';
        rtList = [SELECT Id FROM RecordType WHERE sObjectTYPE = 'Opportunity' AND Name LIKE :FND];
        
        for (RecordType rt : rtList) {
            rtSet.add(rt.Id);
        }
        return rtSet;
    }
}