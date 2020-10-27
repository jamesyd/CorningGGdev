/*******************************************************************************************************
Class Name       : ImportCostSpecificationDataTest
Purpose          : 
Author           : 
Revision History : 
*****************************************************************************************************/
@isTest
public class ImportCostSpecificationDataTest {    

    // Test Method for data with errors
    static testmethod void testImportCostSpecificationDataErrors(){ 
                
        //Create Data for CSV File
        string header = 'Name,Cost Approval,Cost Assessment Complete,Cost Assessment Comment,Source 1 Incremental GFO,Source 1 Incremental Glass Cost Roof 1YL,Source 1 Incremental Glass Cost Roof 2YL,Source 1 Incremental Glass Cost w/o YL,Source 1 Incremental Process Fee Roof 1,Source 1 Incremental Process Fee Roof 2,Source 1 Incremental Roof 1,Source 1 Incremental Roof 2,Source 1 Incremental TCO,Source 1 Incremental Transportation,Source 1 Incremental Yield Roof 1,Source 1 Incremental Yield Roof 2,Source 2 Incremental GFO,Source 2 Incremental Glass Cost Roof 1YL,Source 2 Incremental Glass Cost Roof 2YL,Source 2 Incremental Glass Cost w/o YL,Source 2 Incremental Process Fee Roof 1,Source 2 Incremental Process Fee Roof 2,Source 2 Incremental Roof 1,Source 2 Incremental Roof 2,Sour;ce 2 Incremental TCO,Source 2 Incremental Transportation,Source 2 Incremental Yield Roof 1,Source 2 Incremental Yield Roof 2 \n';
        string finalstr = header;
        string recordString = 'S-001530-06,Accepted,TRUE,12345,0.07,0.3,1.82,0.09,0.2,0.06,Jiangmen,Fuzhou,0.08,0.01,0.01,0,0.19,0.1,0.15,0.01,0.1,0.16,CPM,BOE,0.03,0.14,0.12,0.13 \n' +
            'SP001530-06,Accepted,TRUE,12345,0.07,0.3,1.82,0.09,0.2,0.06,Jiangmen,Fuzhou,0.08,0.01,0.01,0,0.19,0.1,0.15,0.01,0.1,0.16,CPM,BOE,0.03,0.14,0.12,0.13 \n' +
            'SP-X01530-06,Accepted,TRUE,12345,0.07,0.3,1.82,0.09,0.2,0.06,Jiangmen,Fuzhou,0.08,0.01,0.01,0,0.19,0.1,0.15,0.01,0.1,0.16,CPM,BOE,0.03,0.14,0.12,0.13 \n' +
            'SP-001530.06,Accepted,TRUE,12345,0.07,0.3,1.82,0.09,0.2,0.06,Jiangmen,Fuzhou,0.08,0.01,0.01,0,0.19,0.1,0.15,0.01,0.1,0.16,CPM,BOE,0.03,0.14,0.12,0.13 \n' +
            ',Accepted,TRUE,12345,0.07,0.3,1.82,0.09,0.2,0.06,Jiangmen,Fuzhou,0.08,0.01,0.01,0,0.19,0.1,0.15,0.01,0.1,0.16,CPM,BOE,0.03,0.14,0.12,0.13 \n' +
            ',Accepted,TRUE,12345,0.07,0.3,1.82,0.09,0.2,0.06,Jiangmen,Fuzhou,0.08,0.01,0.01,0,0.19,0.1,0.15,0.01,0.1,0.16,CPM,BOE,0.03,0.14,0.12,0.13 \n' +
            ',Accepted,TRUE,12345,0.07,0.3,1.82,0.09,0.2,0.06,Jiangmen,Fuzhou,0.08,0.01,0.01,0,0.19,0.1,0.15,0.01,0.1,0.16,CPM,BOE,0.03,0.14,0.12,0.13 \n' +
            ',Accepted,TRUE,12345,0.07,0.3,1.82,0.09,0.2,0.06,Jiangmen,Fuzhou,0.08,0.01,0.01,0,0.19,0.1,0.15,0.01,0.1,0.16,CPM,BOE,0.03,0.14,0.12,0.13 \n' +
            ',Accepted,TRUE,12345,0.07,0.3,1.82,0.09,0.2,0.06,Jiangmen,Fuzhou,0.08,0.01,0.01,0,0.19,0.1,0.15,0.01,0.1,0.16,CPM,BOE,0.03,0.14,0.12,0.13 \n' +
            ',Accepted,TRUE,12345,0.07,0.3,1.82,0.09,0.2,0.06,Jiangmen,Fuzhou,0.08,0.01,0.01,0,0.19,0.1,0.15,0.01,0.1,0.16,CPM,BOE,0.03,0.14,0.12,0.13 \n' +
            ',Accepted,TRUE,12345,0.07,0.3,1.82,0.09,0.2,0.06,Jiangmen,Fuzhou,0.08,0.01,0.01,0,0.19,0.1,0.15,0.01,0.1,0.16,CPM,BOE,0.03,0.14,0.12,0.13 \n' +
            ',Accepted,TRUE,12345,0.07,0.3,1.82,0.09,0.2,0.06,Jiangmen,Fuzhou,0.08,0.01,0.01,0,0.19,0.1,0.15,0.01,0.1,0.16,CPM,BOE,0.03,0.14,0.12,0.13 \n' +
            ',Accepted,TRUE,12345,0.07,0.3,1.82,0.09,0.2,0.06,Jiangmen,Fuzhou,0.08,0.01,0.01,0,0.19,0.1,0.15,0.01,0.1,0.16,CPM,BOE,0.03,0.14,0.12,0.13 \n' +
            ',Accepted,TRUE,12345,0.07,0.3,1.82,0.09,0.2,0.06,Jiangmen,Fuzhou,0.08,0.01,0.01,0,0.19,0.1,0.15,0.01,0.1,0.16,CPM,BOE,0.03,0.14,0.12,0.13 \n' +
            ',Accepted,TRUE,12345,0.07,0.3,1.82,0.09,0.2,0.06,Jiangmen,Fuzhou,0.08,0.01,0.01,0,0.19,0.1,0.15,0.01,0.1,0.16,CPM,BOE,0.03,0.14,0.12,0.13 \n' +
            ',Accepted,TRUE,12345,0.07,0.3,1.82,0.09,0.2,0.06,Jiangmen,Fuzhou,0.08,0.01,0.01,0,0.19,0.1,0.15,0.01,0.1,0.16,CPM,BOE,0.03,0.14,0.12,0.13 \n' +
            'SP-001530-XX,Accepted,TRUE,12345,0.07,0.3,1.82,0.09,0.2,0.06,Jiangmen,Fuzhou,0.08,0.01,0.01,0,0.19,0.1,0.15,0.01,0.1,0.16,CPM,BOE,0.03,0.14,0.12,0.13 \n';        

        finalstr = finalstr + recordString;
        
        Test.startTest();        
            ImportCostSpecificationDataController csv = new ImportCostSpecificationDataController();
            blob csvBlob = Blob.valueOf(finalstr);
            csv.csvFileBody = csvBlob;
            csv.hasNext = true;
            csv.hasPrevious = false;
                    
            csv.importCSVFile();
            csv.ExportCSVFile();
            csv.next();
            csv.previous();
            csv.redirectpage();
            
            MethodException me = new MethodException();
        Test.stopTest();
    }
    
    //Test Method for valid data   
    static testmethod void testImportCostSpecificationDataValid() { 
        
        TestUtilities tUtils = new TestUtilities();  
        String acctRT = '0121J000000U1cV';
        String oppRT = '0121J000000U1cZ';
        String specRT = '0121J000000U1cj';
        String profileId = '00e1J000000h0j3';
        
        Account a = tUtils.addTestAccount(acctRT);
        a.accountType__c = 'TPM';
        update a;
        
        Opportunity o = tUtils.addTestOppt(a.Id,oppRT);
        
        Specification__c testSpec = tUtils.createTestSpec(a.id, o.id, specRT);
        testSpec.tpm__c = a.id;
        testSpec.submitForApproval__c = true;
        testSpec.Status__c = 'New';
        testSpec.cncNeeded__c = 'No'; 
        testSpec.arEtcPvd__c = 'No';
        testSpec.screenPrint__c = 'No';
        testSpec.innovation_Type__c = 'ArtEng';
        insert testSpec;

        testSpec.Status__c = 'CM Cost Assessment';
        testSpec.RecordTypeId = '0121J000000U1cl';
        update testSpec;
        
        String specName = [SELECT Name FROM Specification__c where Id =: testSpec.id].Name;
                        
        string header = 'Name,Cost Approval,Cost Assessment Complete,Cost Assessment Comment,Source 1 Incremental GFO,Source 1 Incremental Glass Cost Roof 1YL,Source 1 Incremental Glass Cost Roof 2YL,Source 1 Incremental Glass Cost w/o YL,Source 1 Incremental Process Fee Roof 1,Source 1 Incremental Process Fee Roof 2,Source 1 Incremental Roof 1,Source 1 Incremental Roof 2,Source 1 Incremental TCO,Source 1 Incremental Transportation,Source 1 Incremental Yield Roof 1,Source 1 Incremental Yield Roof 2,Source 2 Incremental GFO,Source 2 Incremental Glass Cost Roof 1YL,Source 2 Incremental Glass Cost Roof 2YL,Source 2 Incremental Glass Cost w/o YL,Source 2 Incremental Process Fee Roof 1,Source 2 Incremental Process Fee Roof 2,Source 2 Incremental Roof 1,Source 2 Incremental Roof 2,Sour;ce 2 Incremental TCO,Source 2 Incremental Transportation,Source 2 Incremental Yield Roof 1,Source 2 Incremental Yield Roof 2 \n';
        string finalstr = header ;
        string recordString = specName + ',Accepted,TRUE,12345,0.07,0.3,1.82,0.09,0.2,0.06,Jiangmen,Fuzhou,0.08,0.01,0.01,0,0.19,0.1,0.15,0.01,0.1,0.16,CPM,BOE,0.03,0.14,0.12,0.13 \n';

        finalstr = finalstr + recordString;
        
        Test.startTest();
        
            ImportCostSpecificationDataController csv = new ImportCostSpecificationDataController();
            blob csvBlob = Blob.valueOf(finalstr);
            csv.csvFileBody = csvBlob;
                    
            csv.importCSVFile();
        
        Test.stopTest();
    }
 
}