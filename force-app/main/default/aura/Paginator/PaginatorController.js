({
    //handles the previous page button
	previousPage : function(component, event, helper) {
        var myEvent = $A.get("e.c:PageChange");
        myEvent.setParams({ "direction": "previous"});
        myEvent.fire();
	},
    //handles the next page button
    nextPage : function(component, event, helper) {
       var myEvent = $A.get("e.c:PageChange");
        myEvent.setParams({ "direction": "next"});
        myEvent.fire(); 
	},
    //handles the add selected button
    addSelected : function(component, event, helper) {
       var myEvent = $A.get("e.c:AddSelected");
       myEvent.fire(); 
	},
    //handles the add selected button
    close : function(component, event, helper) {
       var myEvent = $A.get("e.c:CloseProductSearch");
       myEvent.fire(); 
	}
})