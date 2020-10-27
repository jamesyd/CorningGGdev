///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 4/14/2017 ***///
///*** Controller class to display user Permissions on Quote, Specification, and Opportunity ***///
public class PermissionsDisplayController {
    public string recordId {get;set;}
    public string message {get; set;}
    public boolean isEditable {get; set;}
    public boolean showMessage {get; set;}
   
    @testVisible private Utilities.RecordAccessWrapper theWrapper {get; set;}
    
    public PermissionsDisplayController (ApexPages.StandardController controller) {
        recordId = controller.getRecord().Id;
        if(recordId == NULL){   
            showMessage = false;
        }else{
            showMessage = true;
        }
    }
    
    public void getPermissions() {
        if(showMessage){
            Utilities utils = new Utilities();
            theWrapper = new Utilities.RecordAccessWrapper(); 
            theWrapper = utils.getUserRecordAccess(recordId, UserInfo.getUserId()); 
            
            if (theWrapper.RecordEditable) {
                isEditable = true;
                //Ajay - changed to simply say 'you have edit access to this record - per Adam - 4/19/2017
                message = Label.GGRecordEditable + ' record';// + theWrapper.sObjectType;
            }
            else if(theWrapper.RecordViewable) {
                isEditable = false;
                message = Label.GGRecordViewable + ' record';// + theWrapper.sObjectType;
            }
            else {
                isEditable = false;
                message = Label.GGRecordNoAccess + ' record';// + theWrapper.sObjectType;
            }
        }
        
    }
}