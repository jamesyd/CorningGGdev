({
	myAction : function(component, event, helper) {
		var action = component.get("c.getOpportunityRecords");
        action.setCallback(this, function(response){
            if(response.getState()==="SUCCESS" && component.isValid()){
                component.set("v.opps",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    
    editRecord : function(component, event, helper) {
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
             "recordId": event.target.id
       });
       editRecordEvent.fire();
	},
    
    viewRecord : function (component, event, helper) {
    	var navEvt = $A.get("e.force:navigateToSObject");
    	navEvt.setParams({
      		"recordId": event.target.id,
      		"slideDevName": "detail"
    	});
    	navEvt.fire();
	}
})