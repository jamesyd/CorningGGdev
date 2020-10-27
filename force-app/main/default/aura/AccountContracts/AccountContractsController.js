({
	myAction : function(component, event, helper) {
		var action = component.get("c.getContractRecords");
        action.setParams({ accId : component.get("v.recordId")});
        action.setCallback(this, function(response){
            if(response.getState()==="SUCCESS" && component.isValid()){
                component.set("v.contracts",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	}
})