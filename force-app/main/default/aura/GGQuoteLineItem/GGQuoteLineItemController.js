({
    setTooltip: function(component, event, helper){
        helper.setTooltip(component, event);
  	},
    
	//selection changed
    onSelCheck: function(component, event, helper){
        var checkCmp = component.find("selChk");
        var iIdx = component.get("v.cIndex");
		var isSelected = checkCmp.get("v.value");
        var compEvent = component.getEvent("GGQuoteLISelected");
		// Optional: set some data for the event (also known as event shape)
		// A parameter’s name must match the name attribute
		// of one of the event’s <aura:attribute> tags
        compEvent.setParams({"cIndex" : iIdx, "isSelected": isSelected});
		compEvent.fire();
    },
    
    calculateTotalPrice: function(component, event, helper){
    	
        helper.fixNegativePrice(component);
        
        helper.calculateTotalPrice(component);    
    },
    
    setPrice: function(component, event, helper){
        helper.fixDecimalNegativeQuantity(component);
        
        helper.setPrice(component);
        
    },
    
	doInit : function(component, event, helper) {
		helper.doInit(component);
	},
    itemsChange: function(component, event, helper) {
        console.log(component.get("v.quoteLI"));
        component.set("v.quoteLI.specification__c", component.get("v.setItem"));
        console.log(component.get("v.quoteLI"));
        console.log('check'); 
    }
})