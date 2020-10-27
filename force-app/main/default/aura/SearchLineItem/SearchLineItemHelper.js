({
    //selection changed
    onSelCheck: function(component, event, helper){
        var checkCmp = component.find("selChk");
        var iIdx = component.get("v.cIndex");
        var priceId = component.get("v.searchLI").priceId;
        var productId = component.get("v.searchLI").productId;
		var isSelected = checkCmp.get("v.value");
        var compEvent = component.getEvent("GGSearchLISelected");
        
        var scheduleDate = component.find("serviceDate").get("v.value");
        var quantity = component.find("scheduleQty").get("v.value");
        
		// Optional: set some data for the event (also known as event shape)
		// A parameter’s name must match the name attribute
		// of one of the event’s <aura:attribute> tags
        compEvent.setParams({"cIndex" : priceId, "isSelected": isSelected, "scheduleDate": scheduleDate,
                             "quantity": quantity, "Product2Id": productId});
		compEvent.fire();
    },
    
	doInit: function(component){
        console.log("canbeScheduled: " + component.get("v.canbeScheduled"));
        //set up schedule select
        var scheduleQty = component.find("scheduleQty");
        var opts = new Array();
        for (var i = 1; i <= 24; i++ ){
            opts.push({ class: "optionClass", label: i, value: i});
        }
        
		opts[0].selected = "true";
        scheduleQty.set("v.options", opts);
        var today = new Date();
        component.set("v.ServiceDate", today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate());
        
        if (component.get("v.canbeScheduled") == "slds-hide"){
            component.set("v.serviceDateLbl", "");
            component.set("v.quantityLbl", "");
        }
        var tiers = new Array();
        var tieredPricing = component.get("v.searchLI.tieredPricing");
        if (tieredPricing != undefined){
        	tiers = tieredPricing.split("<br/>");
        }
        
        component.set("v.tiers", tiers);
    }
})