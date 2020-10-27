({
	//initialization
    doInit : function(component, event, helper) {
    	var action = component.get('c.sendEmail');
        var recordId = component.get("v.recordId");
        
        component.set("v.message", "");
       	action.setParams({ tripId : recordId});
        
        helper.showHideSpinner(component, true);
        
        action.setCallback(this,function(response){
   			helper.showHideSpinner(component, false);
            var state = response.getState(); 
       		if (component.isValid() && state === "SUCCESS") {
                helper.showHideBadge(component, true);
                var msg = response.returnValue;
                component.set("v.message", msg);//"Trip Report sent via emails...");
       		}
            else if (component.isValid() && state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                    	console.log(errors[0].message);
                    	component.set("v.stdExceptionMsg",errors[0].message);
                    }
                    else {
                    	console.log('Unknown Error');
                    	component.set("v.stdExceptionMsg",'Unknown Error'); 
                    }
                } 
                else {
                   console.log('Unknown Error');
                   component.set("v.stdExceptionMsg",'Unknown Error'); 
                }
            }     
   		});
      	$A.enqueueAction(action);
 	}
})