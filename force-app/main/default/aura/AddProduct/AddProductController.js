({    
    doInit : function(component, event, helper) {
		//call apex class method
    	var action = component.get('c.getTypes');
        action.setCallback(this,function(response){
    		//store state of response
   			var state = response.getState();
       		if (state === "SUCCESS") {
    			//set response value in ctrl attribute on component
     			component.set('v.ctrl', response.getReturnValue());
       		}
   		});
      	$A.enqueueAction(action);
 	},

    handleSearch : function(cmp, event, helper) {
		var tabId;
        var prodType;
        var fSupply = false;
        var tab = event.getSource();

        switch (tab.getLocalId()) {
            case 'parts-submit' :
                prodType = cmp.get("v.ctrl.partsProductType");
                tabId = 'parts';
                break;
            case 'raw-submit' :
                prodType = cmp.get("v.ctrl.rawProductType");
                tabId = 'raw';
                var supFld = cmp.find("raw-supply");
                fSupply = supFld.get("v.checked");                      
                break;
            case 'concore-submit' :
                prodType = cmp.get("v.ctrl.concoreProductType");
                tabId = 'concore';
                break;
        };

        var recordId = cmp.get("v.recordId");
        //alert('recordId:'+recordId);
        if (recordId == null){
        	recordId = '00663000005giAkAAI';
        }
        var field1 = cmp.find(tabId + "-name");
        var fName = field1.get("v.value");
        
        var field2 = cmp.find(tabId + "-comp");
        var fComp = field2.get("v.value");
        
        var field3 = cmp.find(tabId + "-thick");
        var fThick = field3.get("v.value");
        
        var field4 = cmp.find(tabId + "-length");
        var fLength = field4.get("v.value");
        
        var field5 = cmp.find(tabId + "-width");
        var fWidth = field5.get("v.value");

        //call helper's search function
        helper.search(cmp, helper, recordId, prodType, fName, fThick, fWidth, fLength, fComp, fSupply);
	},
    
 	handleCancel : function(cmp, event, helper) {
        //just close the form
        $A.get("e.force:closeQuickAction").fire();
    }
})