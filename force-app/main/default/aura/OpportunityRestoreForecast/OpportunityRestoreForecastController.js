({
    doInit : function(component, event, helper) {
        // Get a reference to the restoreForecast() function defined in the Apex controller
		var action = component.get("c.restoreForecast");
        action.setParams({
            "oppId": component.get("v.recordId")
        });
        // Register the callback function
        action.setCallback(this, function(response) {
            
            var state =  response.getState();
            if(state == "SUCCESS") {
                // close and refresh page
            	$A.get("e.force:closeQuickAction").fire();
            	$A.get('e.force:refreshView').fire();
            } else if (state=="ERROR") {
				var errorMsg = action.getError()[0].message;
                // alert('Error: ' + errorMsg);   
                component.set('v.errorMessage', errorMsg);
                // $A.get("e.force:closeQuickAction").fire();
            }            
        });
        // Invoke the service
        $A.enqueueAction(action);
        
    }
    
})