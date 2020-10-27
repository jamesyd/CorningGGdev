({ 
    handleSelectedLI: function(component, event, helper){
        var cId = event.getParam("cIndex");
		var isSelected = event.getParam("isSelected");
        var qty = event.getParam("quantity");
        var scheduleDate = event.getParam("scheduleDate");
        var Product2Id = event.getParam("Product2Id"); 
        console.log("qty: " + qty + " scheduleDate:" + scheduleDate);
        
        helper.handleSelectedLI(component, cId, isSelected, qty, scheduleDate,Product2Id);
    },
    
  	//set the event for search result change
    handleApplicationEvent : function(component, event, helper) {
        
        console.log("in searchResultsController handleApplicationEvent");
        
		//alert("in the handleApplicationEvent!");
        //reset selected products
        component.set("v.selectedProducts", []);
        
        component.set("v.scheduleProducts", []);
        var params = event.getParam('arguments');
        /*
        var results = event.getParam("resultSet");
        var fields = event.getParam("fieldsToShow");
		var isSampleOpportunity = event.getParam("isSampleOpportunity");
        var isSampleQuote = event.getParam("isSampleQuote");
        var showZeroRecordMessage = event.getParam("showZeroRecordMessage"); 
        var recordId = event.getParam("recordId");*/
        var results = params.resultSet;
        var fields = params.fieldsToShow;
        var isSampleOpportunity = params.isSampleOpportunity;
        var isSampleQuote = params.isSampleQuote;
        var showZeroRecordMessage = params.showZeroRecordMessage; 
        var recordId = params.recordId;
        var isProgramOpty = params.isProgramOpty;
        
        // AN - 8/28/18 Always hide scheduling
        // component.set("v.canbeScheduled", isProgramOpty ? "" : "slds-hide");
        component.set("v.canbeScheduled", isProgramOpty ? "slds-hide" : "slds-hide");
        component.set("v.isProgramOpty", isProgramOpty);
        component.set("v.isPartsSearch", params.isPartsSearch);
        
        
        
        //if (params.prodType == "")
        component.set("v.recordId", recordId);
        //change header to say select single product for sample opportunity
        if (isSampleOpportunity) {
            component.set("v.searchHeaderMessage", "Select a sample product");
        }
        else{
            component.set("v.searchHeaderMessage", "Select products to add");
        }
        
        console.log("results.searchResults.length: " + results.searchResults.length);
        
        
		if (results.searchResults.length > 0) {
            // set the handler attributes based on event data
        	component.set("v.resultSet", results);
        	component.set("v.fieldsToShow", fields);
            
            component.set("v.isSampleOpportunity", isSampleOpportunity);
            component.set("v.isSampleQuote", isSampleQuote);
        	helper.loadRecords(component); 
        }
        else {
			helper.showRecordsMessage(component, 0, showZeroRecordMessage);
        }
    },
    
    addLineItems : function(cmp, event, helper){
		//alert('in addLineItems0');
        helper.addLineItems(cmp);        
    }
 
})