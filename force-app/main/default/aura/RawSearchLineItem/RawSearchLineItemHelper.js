({
	get2DecimalCurrencyVal: function(v){
        if (v != undefined && v){
        	return parseFloat(v).toFixed(2);
        }
        
        return '';
	},
    
    doInit : function(component) {
        console.log("canbeScheduled: " + component.get("v.canbeScheduled"));
        
        //set up schedule select
		console.log("in doInit - raw");
        var scheduleQty = component.find("scheduleQty");
        console.log("in doInit - raw scheduleQty:" + scheduleQty);
        var opts = new Array();
        for (var i = 1; i <= 24; i++ ){
            opts.push({ class: "optionClass", label: i, value: i});
        }
        
        var price = component.get("v.searchLI.priceUnit");
        component.set("v.searchLI.priceUnit", this.get2DecimalCurrencyVal(price));
        
		opts[0].selected = "true";
        scheduleQty.set("v.options", opts);
        var today = new Date();
        component.set("v.ServiceDate", today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate());
		
        if (component.get("v.canbeScheduled") == "slds-hide"){
            component.set("v.serviceDateLbl", "");
            component.set("v.quantityLbl", "");
        }
       
        //moq, moqunit visible for MP Quote raw glass
        if (component.get("v.isQuote")){
        	component.set("v.moqLbl", "MOQ");
        	component.set("v.moqUnitLbl", "MOQ Unit");
        	component.set("v.moqStyle", "");
        	component.set("v.moqUnitStyle", "");        
    	}
        
        
    },
    //selection changed
    onSelCheck: function(component, event, helper){
        var checkCmp = component.find("selChk");
        var iIdx = component.get("v.cIndex");
		var isSelected = checkCmp.get("v.value");
        var priceId = component.get("v.searchLI").priceId;
        var productId = component.get("v.searchLI").productId;
        var scheduleDate = component.find("serviceDate").get("v.value");
        var quantity = component.find("scheduleQty").get("v.value");
        
        var compEvent = component.getEvent("GGSearchLISelected");
        
		// Optional: set some data for the event (also known as event shape)
		// A parameter’s name must match the name attribute
		// of one of the event’s <aura:attribute> tags
        compEvent.setParams({"cIndex" : priceId, "isSelected": isSelected, "scheduleDate": scheduleDate,
                             "quantity": quantity, "Product2Id":productId});
		compEvent.fire();
    }
})