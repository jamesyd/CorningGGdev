/*******************************************************************************************************
Class Name       : ImportCostSpecificationDataController
Purpose          : This Class is to import specification data and to export errors in csv file
Author           : 
Revision History : 
 * *****************************************************************************************************/
public class ImportCostSpecificationDataController {

    // Variable declartions
    public transient Blob csvFileBody{get;set;}   // store input csv file
    public transient string csvAsString{get;set;}   // split csv file as string
    public transient String[] csvFileLines{get;set;}  // stores multiple csv lines
    
    public transient List<Specification__c> sidlist{get;set;} // List to store csv specification data records
    public List<ImportCostSpecificationDataWrapper> errorsidlist{get;set;} // Wrapper list to store errors from csv file
    public transient List<ImportCostSpecificationDataWrapper> sidlistWrapper{get;set;} // Wrapper to store success records from csv file
    public List<ImportCostSpecificationDataWrapper> sidSetlist{get;set;}  // List to hold specification records based on pagination size
    public transient List<Specification__c> specificationlist{get;set;}  // List to get existing specification records
    public transient Map<String,Specification__c> mapsidValues;  // Map to store existing specification records (spec id string, specification)
    public List<String> specNumberList;  // List to store all Spec #'s
    public Map<String,String> specNumberMapCostStatus;  // List to store all Spec #'s in the correct status
    public String finalErrorMessage{get;set;}  // String to store csv error messages and display on vf page
   
    public List<Specification__c> UpdatesidData; // List to update valid csv data
    public transient List<Specification__c> sidlist1; // List to hold valid csv data
    public transient String errorMessages; // String to hold error messages for each line in csv
    public Boolean iserror {get;set;} // This variable value will update to true if csv contains any erros
    public integer delaytime {get;set;} // To delay the page refresh after export errors csv file downloaded
    
    // Pagination Variables
    public ImportCostSpecificationCustomIterable obj; // Instance of Iterator
    public Integer startRecCount{get;set;} // Current page start record count
    public Integer endRecCount {get;set;} // Current page end record count
    public Integer TotErrorRecCount{get;set;} // Total error records count in csv
    public Integer TotRecCount{get;set;} // Total records count in csv
    public Boolean isFlagUpdated; // Flag to set start and end record count
    public Integer cpage {get;set;} // Current page count
    public Integer tpage {get;set;} // Total pages count
    public Integer pageSize; // Pagination page size
    
    //Constructor for importDataFromCSVController
    public ImportCostSpecificationDataController() {
        csvFileLines = new String[]{};
        obj = new ImportCostSpecificationCustomIterable();
        iserror = false;
        
        //Get pagination size from custom settings
        // Global_Variable__c myCS2 = Global_Variable__c.getInstance('Trainin
        pageSize = 10; // integer.valueOf(myCS2.Value__c);
    }
    
    //Redirect Page after csv error file generation
    public void redirectpage() {
       sidSetlist.clear();
       iserror = false;
       
       //Apex message to show csv file downloaded message
       ApexPages.Message eMessage1 = new ApexPages.Message(ApexPages.severity.Info,'Export Error CSV file downloaded');
       ApexPages.addMessage(eMessage1);
    }
  
    //Method to import CSV File and data validations
    public void importCSVFile() {
        try{
           finalErrorMessage = '';
           sidlist = New List<Specification__c>(); 
           sidSetlist = New List<ImportCostSpecificationDataWrapper>(); 
           sidlistWrapper = New List<ImportCostSpecificationDataWrapper>(); 
           errorsidlist = New List<ImportCostSpecificationDataWrapper>(); 
           specNumberList = new List<String>();
           specNumberMapCostStatus = new Map<String,String>();
           mapsidValues = new Map<String,Specification__c>(); 
           delaytime = 0;
           
           //Condition to check whether csv selected or not
           if(csvFileBody != null) { 
               csvAsString = csvFileBody.toString(); // Convert csv into string 
               csvFileLines = csvAsString.split('\n'); // Split csv file into multiple lines
               
               //Loop on all csv lines 
               for(Integer i=1; i < csvFileLines.size(); i++) {
                   Specification__c sidObj = new Specification__c() ;
                   string[] csvRecordData = csvFileLines[i].split(','); // Split each csv line with comma separated value
                   
                   //NullPointer conditon check for each new line
                   if (csvRecordData != null) {
                   
                       sidObj.Name = csvRecordData[0].trim();
                       system.debug('$$$-00 ' + sidObj.Name);
                       
                       sidObj.costApproval__c = csvRecordData[1].trim() == '' ? '' : csvRecordData[1].trim();
                       system.debug('$$$-01 ' + sidObj.costApproval__c);
                       
                       sidObj.costAssessmentComplete__c = csvRecordData[2].trim() == '' ? FALSE : Boolean.valueOf(csvRecordData[2].trim()); 
                       system.debug('$$$-02 ' + sidObj.costAssessmentComplete__c);
                       
                       sidObj.costAssessmentComment__c = csvRecordData[3].trim();
                       system.debug('$$$-03 ' + sidObj.costAssessmentComment__c);
                       
                       sidObj.incrementalGFO__c = csvRecordData[4].trim() == '' ? 0.0 : Decimal.valueOf(csvRecordData[4].trim());                       
                       system.debug('$$$-04 ' + sidObj.incrementalGFO__c);
                       
                       sidObj.incrementalGlassCostRoof1__c = csvRecordData[5].trim() == '' ? 0.0 : Decimal.valueOf(csvRecordData[5].trim());
                       system.debug('$$$-05 ' + sidObj.incrementalGlassCostRoof1__c);
                       
                       sidObj.incrementalGlassCostRoof2__c = csvRecordData[6].trim() == '' ? 0.0 : Decimal.valueOf(csvRecordData[6].trim());
                       system.debug('$$$-06 ' + sidObj.incrementalGlassCostRoof2__c);
                       
                       sidObj.incrementalGlassCostNoYL__c = csvRecordData[7].trim() == '' ? 0.0 : Decimal.valueOf(csvRecordData[7].trim());
                       system.debug('$$$-07 ' + sidObj.incrementalGlassCostNoYL__c);
                       
                       sidObj.incrementalProcessFeeRoofOne__c = csvRecordData[8].trim() == '' ? 0.0 : Decimal.valueOf(csvRecordData[8].trim());
                       system.debug('$$$-08 ' + sidObj.incrementalProcessFeeRoofOne__c);
                       
                       sidObj.incrementalProcessFeeRoofTwo__c = csvRecordData[9].trim() == '' ? 0.0 : Decimal.valueOf(csvRecordData[9].trim());
                       system.debug('$$$-09 ' + sidObj.incrementalProcessFeeRoofTwo__c);
                       
                       sidObj.incrementalRoofOne__c = csvRecordData[10].trim();
                       system.debug('$$$-10 ' + sidObj.incrementalRoofOne__c);
                       
                       sidObj.incrementalRoofTwo__c = csvRecordData[11].trim();
                       system.debug('$$$-11 ' + sidObj.incrementalRoofTwo__c);
                       
                       sidObj.incrementalTCO__c = csvRecordData[12].trim() == '' ? 0.0 : Decimal.valueOf(csvRecordData[12].trim());
                       system.debug('$$$-12 ' + sidObj.incrementalTCO__c);
                       
                       sidObj.incrementalTransportation__c = csvRecordData[13].trim() == '' ? 0.0 : Decimal.valueOf(csvRecordData[13].trim());
                       system.debug('$$$-13 ' + sidObj.incrementalTransportation__c);
                       
                       sidObj.incrementalYieldRoofOne__c = csvRecordData[14].trim() == '' ? 0.0 : Decimal.valueOf(csvRecordData[14].trim());
                       system.debug('$$$-14 ' + sidObj.incrementalYieldRoofOne__c);
                       
                       sidObj.incrementalYieldRoofTwo__c = csvRecordData[15].trim() == '' ? 0.0 : Decimal.valueOf(csvRecordData[15].trim());
                       system.debug('$$$-15 ' + sidObj.incrementalYieldRoofTwo__c);
                       
                       sidObj.incrementalGFOS2__c = csvRecordData[16].trim() == '' ? 0.0 : Decimal.valueOf(csvRecordData[16].trim());
                       system.debug('$$$-16 ' + sidObj.incrementalGFOS2__c);
                       
                       sidObj.incrementalGlassCostRoof1S2__c = csvRecordData[17].trim() == '' ? 0.0 : Decimal.valueOf(csvRecordData[17].trim());
                       system.debug('$$$-17 ' + sidObj.incrementalGlassCostRoof1S2__c);
                       
                       sidObj.incrementalGlassCostRoof2S2__c = csvRecordData[18].trim() == '' ? 0.0 : Decimal.valueOf(csvRecordData[18].trim());
                       system.debug('$$$-18 ' + sidObj.incrementalGlassCostRoof2S2__c);
                       
                       sidObj.incrementalGlassCostNoYLS2__c = csvRecordData[19].trim() == '' ? 0.0 : Decimal.valueOf(csvRecordData[19].trim());
                       system.debug('$$$-19 ' + sidObj.incrementalGlassCostNoYLS2__c);
                       
                       sidObj.incrementalProcessFeeRoofOneS2__c = csvRecordData[20].trim() == '' ? 0.0 : Decimal.valueOf(csvRecordData[20].trim());
                       system.debug('$$$-20 ' + sidObj.incrementalProcessFeeRoofOneS2__c);
                       
                       sidObj.incrementalProcessFeeRoofTwoS2__c = csvRecordData[21].trim() == '' ? 0.0 : Decimal.valueOf(csvRecordData[21].trim());
                       system.debug('$$$-21 ' + sidObj.incrementalProcessFeeRoofTwoS2__c);
                       
                       sidObj.incrementalRoofOneS2__c = csvRecordData[22].trim();
                       system.debug('$$$-22 ' + sidObj.incrementalRoofOneS2__c);
                       
                       sidObj.incrementalRoofTwoS2__c = csvRecordData[23].trim();
                       system.debug('$$$-23 ' + sidObj.incrementalRoofTwoS2__c);
                       
                       sidObj.incrementalTCOS2__c = csvRecordData[24].trim() == '' ? 0.0 : Decimal.valueOf(csvRecordData[24].trim());
                       system.debug('$$$-24 ' + sidObj.incrementalTCOS2__c);
                       
                       sidObj.finalIncrementalTransportationS2__c = csvRecordData[25].trim() == '' ? 0.0 : Decimal.valueOf(csvRecordData[25].trim());
                       system.debug('$$$-25 ' + sidObj.finalIncrementalTransportationS2__c);
                       
                       sidObj.finalIncrementalYieldRoofOneS2__c = csvRecordData[26].trim() == '' ? 0.0 : Decimal.valueOf(csvRecordData[26].trim());
                       system.debug('$$$-26 ' + sidObj.finalIncrementalYieldRoofOneS2__c);
                       
                       sidObj.finalIncrementalYieldRoofTwoS2__c = csvRecordData[27].trim() == '' ? 0.0 : Decimal.valueOf(csvRecordData[27].trim());
                       system.debug('$$$-27 ' + sidObj.finalIncrementalYieldRoofTwoS2__c);
                           
                       if(sidObj.Name != null) {
                           specNumberList.add(sidObj.Name);
                       }

                       sidlist.add(sidObj);

                    }
               }
               
               // Setting time delay based on csv record count
               if (sidlist.size() > 1000) {
                   delaytime = 10000; //Set delay time to 10 secs if csv record count greater than 1000
               } else {
                   delaytime = 5000; //Set delay time to 5 secs if csv record count less than 1000      
               }
                             
               // Query Secification records 
               // - only return those with Status CM Cost Assessment
               specificationlist = [ SELECT
                       Id,
                       Status__c,
                       Name,
                       costApproval__c, 
                       costAssessmentComplete__c,   
                       costAssessmentComment__c,    
                       incrementalGFO__c,   
                       incrementalGlassCostRoof1__c, 
                       incrementalGlassCostRoof2__c,    
                       incrementalGlassCostNoYL__c, 
                       incrementalProcessFeeRoofOne__c, 
                       incrementalProcessFeeRoofTwo__c, 
                       incrementalRoofOne__c,   
                       incrementalRoofTwo__c,   
                       incrementalTCO__c,   
                       incrementalTransportation__c,    
                       incrementalYieldRoofOne__c,  
                       incrementalYieldRoofTwo__c,  
                       incrementalGFOS2__c, 
                       incrementalGlassCostRoof1S2__c,  
                       incrementalGlassCostRoof2S2__c,  
                       incrementalGlassCostNoYLS2__c,   
                       incrementalProcessFeeRoofOneS2__c,   
                       incrementalProcessFeeRoofTwoS2__c,   
                       incrementalRoofOneS2__c, 
                       incrementalRoofTwoS2__c, 
                       incrementalTCOS2__c, 
                       finalIncrementalTransportationS2__c, 
                       finalIncrementalYieldRoofOneS2__c,   
                       finalIncrementalYieldRoofTwoS2__c
                       FROM Specification__c where Name IN: specNumberList];
                       
                       // AND status__c = 'CM Cost Assessment'
               
               system.debug('$$$ SOQL RESULTS: ' + specificationlist.size());
                             
               // Update Map with Spec Id and Specification record
               // Update List with Spec Name
               if (specificationlist.size() > 0) {
                   for (Specification__c sid : specificationlist) {
                       mapsidValues.put(sid.name, sid);
                       
                       if (sid.status__c == 'CM Cost Assessment' ) {
                           specNumberMapCostStatus.put(sid.Name, 'CM Cost Assessment');
                       }
                   
                   }
               }
               
               integer erow = 1; // to recognise error row count
               
               Map<String, List<Integer>> mapConcatStrvsRows = new Map<String, List<Integer>>(); // Map to hold Spec ID and matched entries row list
               List<Integer> rowList; // List to hold matched entires rows
               sidlist1 = new List<Specification__c>(); // List to hold valid csv data
               
               // Loop all specification records came from csv (SIDLIST)
               for(Specification__c sid : sidlist) {
               
                    // SpecID validation
                    errorMessages='';
                    
                    // Spec Number Validation
                    if (sid.name.length() == 0) {                   
                        errorMessages = 'Specification Name Missing' + ' | ';
                    }    
                    
                    if (sid.name.length() > 0) {
                       if (!validateSpecName(sid.name)) {
                           errorMessages = 'Cannot recognize Specification Name' + ' | ';
                       }
                    }             
                    
                    // Status validation
                    if(sid.name.length() > 0) {
                       if (!specNumberMapCostStatus.containsKey(sid.Name) && validateSpecName(sid.name)) {
                           errorMessages = 'Specification is not in CM Cost Assessment' + ' | ';
                       }
                    }         
                    
                    // Condition to check each csv contains any errors or not
                    if(errorMessages.length() > 0) {
                        errorMessages = 'Row ' + erow + ' : ' + sid.Name + ' : ' + errorMessages.removeEnd(' | ');
                        errorsidlist.add(new ImportCostSpecificationDataWrapper(erow,sid,errorMessages)); // Update list with errored records
                        errorMessages = errorMessages+'<br/>';
                        finalErrorMessage = finalErrorMessage+errorMessages; // Update final error message string with list of all error messages
                        iserror = true;
                    } else {
                        sidlist1.add(sid); // Add specification data valid values that came from csv
                    }
                    erow++;
                    
               }
               
               // Initialise new list to update specification data
               UpdatesidData = new List<Specification__c>();
               
               // Condition to check valid data list size
               if (sidlist1.size() > 0) {
               
                   for (Specification__c sid : sidlist1) { // ONLY VALID ROWS FROM CSV
                   
                        system.debug('$$$ SIDLIST1: ' + sid.name );               
                        if (mapsidValues.containsKey(sid.Name)) {
                            Specification__c sidObj2 = mapsidValues.get(sid.Name); // if map contains the Spec ID Name, then update all field values with new values and process step value to update
                                                  
                            sidObj2.costApproval__c = sid.costApproval__c;
                            sidObj2.costAssessmentComplete__c = sid.costAssessmentComplete__c;
                            sidObj2.costAssessmentComment__c = sid.costAssessmentComment__c;    
                            sidObj2.incrementalGFO__c = sid.incrementalGFO__c;   
                            sidObj2.incrementalGlassCostRoof1__c = sid.incrementalGlassCostRoof1__c; 
                            sidObj2.incrementalGlassCostRoof2__c = sid.incrementalGlassCostRoof2__c;     
                            sidObj2.incrementalGlassCostNoYL__c = sid.incrementalGlassCostNoYL__c; 
                            sidObj2.incrementalProcessFeeRoofOne__c = sid.incrementalProcessFeeRoofOne__c; 
                            sidObj2.incrementalProcessFeeRoofTwo__c = sid.incrementalProcessFeeRoofTwo__c; 
                            sidObj2.incrementalRoofOne__c = sid.incrementalRoofOne__c;   
                            sidObj2.incrementalRoofTwo__c = sid.incrementalRoofTwo__c;   
                            sidObj2.incrementalTCO__c = sid.incrementalTCO__c;   
                            sidObj2.incrementalTransportation__c = sid.incrementalTransportation__c;    
                            sidObj2.incrementalYieldRoofOne__c = sid.incrementalYieldRoofOne__c;  
                            sidObj2.incrementalYieldRoofTwo__c = sid.incrementalYieldRoofTwo__c;  
                            sidObj2.incrementalGFOS2__c = sid.incrementalGFOS2__c; 
                            sidObj2.incrementalGlassCostRoof1S2__c = sid.incrementalGlassCostRoof1S2__c;  
                            sidObj2.incrementalGlassCostRoof2S2__c = sid.incrementalGlassCostRoof2S2__c;  
                            sidObj2.incrementalGlassCostNoYLS2__c = sid.incrementalGlassCostNoYLS2__c;   
                            sidObj2.incrementalProcessFeeRoofOneS2__c = sid.incrementalProcessFeeRoofOneS2__c;   
                            sidObj2.incrementalProcessFeeRoofTwoS2__c = sid.incrementalProcessFeeRoofTwoS2__c;   
                            sidObj2.incrementalRoofOneS2__c = sid.incrementalRoofOneS2__c; 
                            sidObj2.incrementalRoofTwoS2__c = sid.incrementalRoofTwoS2__c; 
                            sidObj2.incrementalTCOS2__c = sid.incrementalTCOS2__c; 
                            sidObj2.finalIncrementalTransportationS2__c = sid.finalIncrementalTransportationS2__c;
                            sidObj2.finalIncrementalYieldRoofOneS2__c = sid.finalIncrementalYieldRoofOneS2__c;   
                            sidObj2.finalIncrementalYieldRoofTwoS2__c = sid.finalIncrementalYieldRoofTwoS2__c;
                                                    
                            UpdatesidData.add(sidObj2);
                       }        
                   }
               }
               
               system.debug('$$$ H');
               
               // Condition to check any error messages in csv
               if(finalErrorMessage != '' && finalErrorMessage != null) {
               
               system.debug('$$$ I');
               
                    obj = new ImportCostSpecificationCustomIterable(errorsidlist); // Initializing the iterator
                    if (sidlist.size() > pageSize) {
                        obj.setPageSize = pageSize;
                    } else {
                        obj.setPageSize = pageSize;
                    }
                    
                    system.debug('$$$ J');
                    
                    if (errorsidlist.size() > 0) { //Check error list size and update pagination values
                    
                    system.debug('$$$ K');
                    
                        if (errorsidlist.size() > pageSize) {
                            cpage = 0;
                            integer temp = Math.mod(errorsidlist.size(),pageSize);
                            tpage = errorsidlist.size()/pageSize;
                            if(temp > 0) 
                                tpage++;
                        } else {
                            cpage = 0;
                            tpage = 1;
                        }
                        
                        startRecCount = 1;
                        endRecCount = 0;
                        TotErrorRecCount = errorsidlist.size();
                        TotRecCount = sidlist.size();
                        isFlagUpdated = false;
                    }
                    // Table size
                    next();
                    throw new MethodException(finalErrorMessage); 
               }
               else {                 
               
               system.debug('$$$ L');
                 
                   // Update Existing Specification records
                   if(UpdatesidData.size() > 0)
                       update UpdatesidData;
                                      
                   //Code commented to show record on csv successfull Import    
                   /*obj = new ImportCostSpecificationCustomIterable(sidlistWrapper); //Initializing the iterator
                   if (sidlist.size() > pageSize) {
                       obj.setPageSize = pageSize;
                   } else {
                       obj.setPageSize = sidlistWrapper.size();
                   }
                    // Table size
                   next();*/
                   
                   // Page message to show success message after csv import  
                   ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.Confirm,'CM Cost Assessment data has been updated for ' + UpdatesidData.size() + ' specification(s)');
                   ApexPages.addMessage(errorMessage);
              
               }  
           } else {
           
           system.debug('$$$ M');
           
               // Page message to show warning message on clicking import Data button with no csv selection
               ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.Warning,'Please upload the CSV File and Click Import Data.');
               ApexPages.addMessage(errorMessage);
           }
        }
        catch (Exception e)
        {   
            // Page message to add all validation messages to visualforce page
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.Error,e.getMessage());
            ApexPages.addMessage(errorMessage);
            
            // Page message to show to download csv error file
            ApexPages.Message errorMessage1 = new ApexPages.Message(ApexPages.severity.Info,'Please click Export Errors button to insert valid data and to export errors to a CSV file');
            ApexPages.addMessage(errorMessage1);
        }  
    }
  
    //Method to export errors in csv file
    public PageReference ExportCSVFile(){
    
        //Update Existing Specification Data records
        if (UpdatesidData != null)
        if (UpdatesidData.size() > 0)
        update UpdatesidData;
    
        PageReference pageRef = new PageReference('/apex/DownloadCostSpecificationDataErrors');  
        pageRef.setRedirect(false);
        return pageRef;
    }
  
    //Pagination Next variable
    public Boolean hasNext {
        get {
            return obj.hasNext();
        }
        set;
    }  
  
    //Pagination Previous variable
    public Boolean hasPrevious {
        get {
            return obj.hasPrevious();
        }
        set;
    }
  
    //Pagination next method  
    public void next() {
        sidSetlist = obj.next();
        cpage++;
        if (isFlagUpdated) {
            startRecCount = startRecCount + pageSize;
        }
        endRecCount = endRecCount + sidSetlist.size();
        isFlagUpdated = true;                    
    }
    
    //Pagination previous method
    public void previous() {
        endRecCount = endRecCount - sidSetlist.size();  
        sidSetlist = obj.previous();
        cpage--;
        if (isFlagUpdated) {
            startRecCount = startRecCount - pageSize;
        }
    }
    
    //Method to validate specification name  
    public static Boolean validateSpecName(String n) {
        Boolean res = true;

        system.debug('$$$: ' + n.length());
        if (n.length() != 12) {
            res = false;
        }

         
        if (n.length() == 12) {
            system.debug('$$$: ' + n.substring(0,3));       
            if (n.substring(0,3) != 'SP-') {
                res = false;
            }
        }

        if (n.length() == 12) {
            system.debug('$$$: ' + n.substring(3,9));  
            if (!n.substring(3,9).isNumeric()) {
                res = false;
            } 
        }    

        if (n.length() == 12) {        
            system.debug('$$$: ' + n.substring(9,10));  
            if (n.substring(9,10) != '-') {
                res = false;
            }   
        }

        if (n.length() == 12) {
            system.debug('$$$: ' + n.substring(10,12));  
            if (!n.substring(10,12).isNumeric()) {
                res = false;
            }    
        }    
        
        return res; 
    }  
    
   
}