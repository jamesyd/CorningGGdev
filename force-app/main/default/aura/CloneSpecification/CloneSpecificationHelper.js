({
    showHideSpinner: function(cmp, show){
        var spinner = cmp.find('waitSpinner');
        $A.util.removeClass(spinner, show ? "slds-hide" :"slds-show");
        $A.util.addClass(spinner, show ? "slds-show" :"slds-hide");    
    },
    
    gotoNewSpecification: function(clonedRecId){
        var navEvt = $A.get("e.force:navigateToSObject");
    	navEvt.setParams({
      		"recordId": clonedRecId,
      		"slideDevName": "detail"
    	});
    	navEvt.fire();
    },
    
	clone : function(cmp, recordId, withAttachments, parentOptyId, cloneReason) {
		// create a one-time use instance of the cloneSpec action
        // in the server-side controller
        var action = cmp.get("c.cloneSpec");
        action.setParams({ origSpecId : recordId,
                          copyAttachments : withAttachments,
                          parentOptyId : parentOptyId,
                          cloneReason : cloneReason
                         });

        this.showHideSpinner(cmp, true);
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            this.showHideSpinner(cmp, false);
            
            var state = response.getState();
            
            if (cmp.isValid() && state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                
                var res = response.getReturnValue();
                if (res.success == false){
                   // alert('Error: ' + res.errorMessage);
                   cmp.set('v.errorMessage', 'Error: ' + res.errorMessage);
                }
                else{                
                	//navigate to the cloned record
                	this.gotoNewSpecification(res.clonedSpecId);
                }
            }
            else if (cmp.isValid() && state === "INCOMPLETE") {
                // do something
            }
            else if (cmp.isValid() && state === "ERROR") {
                
                var errors = response.getError();
                console.log(errors);
                if (errors) {
                    if (errors.length > 0) {
                        console.log("Error message: " + 
                                 errors[0]);
                        var p = errors[0];
                        if (p.hasOwnProperty("pageErrors") && p["pageErrors"].length > 0){
                            console.log("Error: " + p["pageErrors"][0].message);
                        }
                        for (var key in p) {
  							if (p.hasOwnProperty(key)) {
    							console.log(key + " -> " + p[key]);
                                var p1 = p[key];

                                console.log('p1: ' + p1);
  							}
						}
                        alert('Error: ' + JSON.stringify(errors));
                    }
                    else{
                    	alert('Unknown Error :-(');
                    }
                } 
                else {
                    console.log("Unknown error");
                    alert('Unknown Error');
                }
                
            }
        });

        // optionally set storable, abortable, background flag here

        // A client-side action could cause multiple events, 
        // which could trigger other events and 
        // other server-side action calls.
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
	}
})