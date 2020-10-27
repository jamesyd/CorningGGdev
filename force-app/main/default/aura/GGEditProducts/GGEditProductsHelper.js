({
	
	//launches the same component in full page when not using SF1
    launchInFullPage: function(component){  
    	var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
        	componentDef : "c:GGEditProducts",
        	componentAttributes: {
        		recordId : component.get("v.recordId"),
         		navigateToFullPage: false
        	}
        });
        evt.fire();
    },
    
    initialize: function(component){
    	
        var action = component.get('c.runningInSF1');
        
        action.setCallback(this,function(response){
   			var state = response.getState();
       		if (state === "SUCCESS") {
       			var rV = response.getReturnValue();
       			if (rV == false && component.get("v.navigateToFullPage")){
       				this.launchInFullPage(component);
       			}
       		}
       	});
       	
       	$A.enqueueAction(action);  
    }
})