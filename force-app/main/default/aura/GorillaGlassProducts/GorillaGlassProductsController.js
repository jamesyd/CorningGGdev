({
    handleApprovePrice: function(component, event, helper){
    	helper.handleApprovePrice(component);
    },
    
    handleExtendExpiry: function(component, event, helper){
    	helper.handleExtendExpiry(component);
    },
    
    handleScheduleLineItems: function(component, event, helper){
    	helper.scheduleLineItems(component);
    },
    
    handleSampleProductAdded: function(component, event, helper){
      helper.setLineItemstab(component);  
    },
    
    handleSelectedLI: function(component, event, helper){
        var cId = event.getParam("cIndex");
		var isSelected = event.getParam("isSelected");
        helper.handleSelectedLI(component, cId, isSelected);
    },
    
    doInit : function(component, event, helper) {
        helper.initialize(component);
    },
    
    handleAdd: function(component, event, helper){
        helper.showSearchComponent(component);
    },
    handleDeleteSelected: function(component, event, helper){
        helper.handleDeleteSelected(component);
    },
    handleSave: function(component, event, helper){
        helper.saveRecords(component, false);
    },
    handleClose: function(component, event, helper){
        /*var navEvt = $A.get("e.force:navigateToSObject");
    	navEvt.setParams({
      		"recordId": component.get("v.recordId"),
      		"slideDevName": "detail"
    	});
    	navEvt.fire();*/
        if (component.get("v.selectedTab") == "addProducts"){
        	helper.closeComponent(component);
        }else{
            //if user clicks close while on edit products tab, save data and then close
            helper.saveRecords(component, true);
        }
    },
    
    editLineItems: function(component, event, helper){
        var refreshLIs = component.get("v.refreshLIOnTabChange");
        if (refreshLIs){
            var rId = component.get("v.recordId");
            if (rId.startsWith("0Q0")){
        		helper.loadQuoteLIs(component, false);  
            }else{
        		helper.loadOptyLIs(component, false);                  
            }
        }else{
            component.set("v.refreshLIOnTabChange", true);
        }
    },
    
    refreshAddProducts: function(component, event, helper){
        helper.saveRecords(component);
        helper.refreshAddProducts(component, event, helper);
    }
})