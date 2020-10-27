({
    setTooltip: function(component, event, helper){
        helper.setTooltip(component, event);
  	},
    
    //selection changed
    onSelCheck: function(component, event, helper){
        var checkCmp = component.find("selChk");
        var iIdx = component.get("v.cIndex");
		var isSelected = checkCmp.get("v.value");
        var compEvent = component.getEvent("GGLineItemSelected");
		// Optional: set some data for the event (also known as event shape)
		// A parameter’s name must match the name attribute
		// of one of the event’s <aura:attribute> tags
        compEvent.setParams({"cIndex" : iIdx, "isSelected": isSelected});
		compEvent.fire();
    },
    
    onlyAllowInteger: function(component, event, helper){
        var keyCode = event.getParams().keyCode;
        var inp = String(component.get('v.opttyLI.Quantity'));
        if (keyCode < 48 || keyCode > 57){//non numeric
            //component.set('v.opttyLI.Quantity', inp.substring(0, inp.length - 1));
            event.preventDefault();
        }
    },
    
    
    calculateTotalPrice: function(component, event, helper){
    	helper.fixNegativePrice(component);
        
        helper.calculateTotalPrice(component);    
    },
    
    setPrice: function(component, event, helper){
        
        helper.fixDecimalNegativeQuantity(component);
        
        helper.setPrice(component);
        
    },
    
    forecastChanged: function(component, event, helper){
        helper.forecastChanged(component);
    },
    
	doInit : function(component, event, helper) {

        //set up forecast select
        var forecastSelect = component.find("forecastSelect");
        var opttyLI = component.get("v.opttyLI");
        var opts = [
            { class: "optionClass", label: "Pipeline", value: "Pipeline"},
            { class: "optionClass", label: "Omitted", value: "Omitted" },
            { class: "optionClass", label: "Won", value: "Won" },
            // { class: "optionClass", label: "Scheduled", value: "Scheduled" }, 
            { class: "optionClass", label: "Lost", value: "Lost" }
        ];

        for (var i = 0; i < opts.length; i++){
            if (opts[i].value == opttyLI.forecastCategory__c ){
            	opts[i].selected = "true";
                break;
            }
        }
        
        forecastSelect.set("v.options", opts);
        console.log("runningInSF1: " + component.get("v.runningInSF1"));
        if (component.get("v.runningInSF1")){
            component.set("v.statusStyle","slds-show");
        }else{
            component.set("v.statusStyle", "slds-hide");
        }
        component.set("v.sampleStyle", component.get("v.isSampleOptty")?"":"slds-hide");
        component.set("v.forecastStyle", component.get("v.isSampleOptty")?"slds-hide":"");
        component.set("v.serviceLbl", component.get("v.isSampleOptty")?"":"Service Date");
		component.set("v.forecastLbl", component.get("v.isSampleOptty")?"":"Forecast Category");
        component.set("v.totalPriceLbl", component.get("v.isSampleOptty")?"":"Total Price");
        component.set("v.priceLbl", component.get("v.isSampleOptty")?"Total Price":"Price");
        component.set("v.opttyLI.errorStyle", "slds-hide");
        helper.calculateTotalPrice(component);
        //console.log('check console' + component.get("v.opttyLI.specification__c"));
        //component.set("v.selectedSpecRecord.Id", component.get("v.opttyLI.specification__c"));
    },
    itemsChange: function(component, event, helper) {
        console.log(component.get("v.opttyLI"));
        component.set("v.opttyLI.specification__c", component.get("v.setItem"));
        console.log(component.get("v.opttyLI"));
        console.log('check'); 
    },
    removeSpecification : function(cmp, event, helper) {
        component.set("v.opttyLI.specification__c", null);
    }
 
})