({
    doInit : function(component,event,helper){
        //console.log(component.get("v.SearchKeyWord"));
        console.log('**- selectedLookUpRecord INSIDE Lookup component: ', JSON.stringify(component.get("v.selectedRecord"), null, 4));
        if(component.get("v.selectedSpecRecordId") != null && component.get("v.selectedSpecRecordId") != undefined){
            component.set("v.selectedRecord.Id", component.get("v.selectedSpecRecordId"));
            component.set("v.selectedRecord.Name", component.get("v.SearchKeyWord"));
        }
        var selectedRecord = component.get("v.selectedRecord");
        //console.log(typeof selectedRecord);
        //console.log(selectedRecord.Id);
        if(typeof selectedRecord == 'undefined'){
           //console.log('check underfined');
           return; 
        }
           
        if(selectedRecord.Id){
            //this.handleComponentEvent(component,event,helper);
            var pillTarget = component.find("lookup-pill");
            var lookUpTarget = component.find("lookupField"); 
            
            $A.util.addClass(pillTarget, 'slds-show');
            $A.util.removeClass(pillTarget, 'slds-hide');
            
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');
        }        
    },
    onfocus : function(component,event,helper){
        
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
        var getInputkeyWord = '';
        helper.searchHelper(component,event,getInputkeyWord);
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    
    // function for clear the Record Selaction 
    clear :function(component,event,helper){
        console.log('clear');
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField");
        console.log('***- pillTarget: ', pillTarget);
        console.log('***- lookUpTarget: ', lookUpTarget);
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        component.set("v.selectedSpecRecordId", null);
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {});
        var vx = component.get("v.methodVar");
        console.log('***- vx: ', vx);
        if(vx != null){
            //fire event from child and capture in parent
            $A.enqueueAction(vx);
        }
    },
    
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
        // get the selected Account record from the COMPONETN event 	 
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.selectedRecord" , selectedAccountGetFromEvent);
        component.set("v.setItem",component.get("v.selectedRecord.Id"));
        console.log('Id ====>' + component.get("v.selectedRecord.Id"));
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');  
        
    },
})