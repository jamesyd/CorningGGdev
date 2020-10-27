({
    //update the records message after search
    showRecordsMessage: function(component, recordCount, showZeroRecordMessage){

        var blockToShow;
        var blockToHide = component.find("searchMsg");
        if (recordCount == 0){
            blockToHide = component.find("resultsBlock");
            blockToShow = component.find("searchMsg");
            if (showZeroRecordMessage){
				component.set("v.searchMessage", "No records to display");
            }else{
                component.set("v.searchMessage", "");
            }
        }else{
            blockToShow = component.find("resultsBlock");
            blockToHide = component.find("searchMsg");
            component.set("v.searchMessage", "");
        }
        
        var searchBlock = component.find("searchResultsCard");
        $A.util.addClass(searchBlock, "slds-show");
        
        
        $A.util.removeClass(blockToHide, "slds-show");
        $A.util.addClass(blockToHide, "slds-hide");
        	
        $A.util.removeClass(blockToShow, "slds-hide");
        $A.util.addClass(blockToShow, "slds-show");
    },
    
    //load records into the grid
    loadRecords : function(component) { 
        
        var fields = component.get("v.fieldsToShow"); 
        var results = component.get("v.resultSet");
        
        if (component.get("v.isPartsSearch")){
           component.set("v.partsSearchResults", results.searchResults);
           component.set("v.rawSearchResults", []);
        }else{
           component.set("v.rawSearchResults", results.searchResults); 
           component.set("v.partsSearchResults", []);
        }
       	this.resetSaveMessage(component);

        component.set("v.pageNumber", results.requestedPageNumber + 1);
        component.set("v.totalResults", results.totalRecordCount);
        component.set("v.pageCount", Math.ceil(results.totalRecordCount/component.get("v.resultsPerPage")));
        
        this.showRecordsMessage(component, results.totalRecordCount);
        
    },
    
    //close the component
    closeAndGotoRecord : function(cmp){
    	var recordId = cmp.get("v.recordId");
        
        var navEvt = $A.get("e.force:navigateToSObject");
    	navEvt.setParams({
      		"recordId": recordId,
      		"slideDevName": "detail"
    	});
    	navEvt.fire();
	},
    
    //fires event to indicate product is added to sample
    productAddedToSample: function(cmp){
        var compEvent = cmp.getEvent("SampleProductAdded");
		// Optional: set some data for the event (also known as event shape)
		// A parameter’s name must match the name attribute
		// of one of the event’s <aura:attribute> tags
        //compEvent.setParams({"cIndex" : iIdx, "isSelected": isSelected});
		compEvent.fire();
    },
    
    scheduleLineItems: function(cmp){
        var recordId = cmp.get("v.recordId");
        var scheduleProducts = cmp.get("v.scheduleProducts");
        
        if (scheduleProducts.length == 0 || recordId == null){
            return;
        }
        
        // create a one-time use instance of the search action
        // in the server-side controller
        var action = cmp.get("c.scheduleOptyLineItems"); 
        
        //alert('in addLineItems recordid:' + recordId + ' priceIds: ' + pIdStr);
        
        //set search params
        action.setParams({ recordId : recordId,
                          strOptyLineItems: JSON.stringify(scheduleProducts)
                         });

        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                var resultSet = response.getReturnValue();
                
                var pIds = cmp.get("v.selectedProducts");
                //reset selected checkboxes
                var cB;
                for (var i = 0; i < pIds.length; i++) {
            		cB = document.getElementById(pIds[i]);
            		if (cB){
                  		cB.checked = false;
                	}
        		}
                cmp.set("v.saveMessage", resultSet.message);
				cmp.set("v.selectedProducts", []);
                cmp.set("v.scheduleProducts", []);
    		}
            else if (cmp.isValid() && state === "INCOMPLETE") {
				alert('Unable to get results');
            }
            else if (cmp.isValid() && state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        alert('Error: ' + errors[0].message);
                    }
                    alert('Error :-(');
                } 
                else {
                    console.log("Unknown error");
                    alert('Unknown Error');
                }
            }
        });
                           
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action); 
    },
    
    //call controller action to add selected line items to the opportunity or quote
    addLineItems: function(cmp){
		
        var recordId = cmp.get("v.recordId");
        var pIds = cmp.get("v.selectedProducts");
        
        if (pIds.length == 0 || recordId == null){
            return;
        }
        
        if (pIds.length > 1 && cmp.get("v.isSampleOpportunity")){
            cmp.set("v.saveMessage", 'Error: only one product can be added to a sample request');
        	return;
    	}
        
 		var isProgramOpty = cmp.get("v.isProgramOpty");
		if (isProgramOpty){
            this.scheduleLineItems(cmp);
    		return;
		}
 
        var pIdStr = '';
        
        for (var i = 0; i < pIds.length; i++) {
            if (i > 0){
                pIdStr += ',';
            }
            pIdStr += pIds[i]; 
        }
        // create a one-time use instance of the search action
        // in the server-side controller
        var action = cmp.get("c.addProducts"); 
        
        //alert('in addLineItems recordid:' + recordId + ' priceIds: ' + pIdStr);
        
        //set search params
        action.setParams({ recordId : recordId,
                          priceIds : pIdStr
                         });

        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                var resultSet = response.getReturnValue();
                
                var pIds = cmp.get("v.selectedProducts");
                //reset selected checkboxes
                var cB;
                for (var i = 0; i < pIds.length; i++) {
            		cB = document.getElementById(pIds[i]);
            		if (cB){
                  		cB.checked = false;
                	}
        		}
                cmp.set("v.saveMessage", resultSet.message);
				cmp.set("v.selectedProducts", []);
                var isSampleOpty = cmp.get("v.isSampleOpportunity");
                var isSampleQuote = cmp.get("v.isSampleQuote");
                if (isSampleOpty || isSampleQuote){
                	//this.closeAndGotoRecord(cmp);
                	this.productAddedToSample(cmp);
                }
    		}
            else if (cmp.isValid() && state === "INCOMPLETE") {
				alert('Unable to get results');
            }
            else if (cmp.isValid() && state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        alert('Error: ' + errors[0].message);
                    }
                    alert('Error :-(');
                } 
                else {
                    console.log("Unknown error");
                    alert('Unknown Error');
                }
            }
        });
                           
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action); 
    },
    
    resetSaveMessage: function(component){
      component.set("v.saveMessage", "");  
    },
    
    handleSelectedLI: function(component, cId, isSelected, qty, scheduleDate,Product2Id){
		this.resetSaveMessage(component);
        var scheduleProducts = component.get("v.scheduleProducts");
        var ids = component.get("v.selectedProducts");
        var progOpty = component.get("v.isProgramOpty");
        //var qtys = component.get("v.selectedQtys");
        //var dates = component.get("v.scheduleDates");
        var scheduleItem;
        if (qty && scheduleDate){
            scheduleItem = {"price__c":cId, "quantity":qty, "ServiceDate": scheduleDate, "Product2Id":Product2Id};
        }
        
        console.log("1. ids.length: " + ids.length + " scheduleProducts.length: " + scheduleProducts.length);
        
        if (isSelected){
            for (var i = 0; i < ids.length; i++){
                if (ids[i] == cId){
                    ids.splice(i, 1);
                    
                    if (progOpty && scheduleProducts.length > i && scheduleProducts[i].price__c == cId ){
                        scheduleProducts.splice(i,1);
                    }
                    
                    console.log("2. ids.length: " + ids.length + " scheduleProducts.length: " + scheduleProducts.length);
                    break;
                }
            }
            
            ids.push(cId);
            if (progOpty){
                console.log("scheduleItem added:" + scheduleItem);
                for (var key in scheduleItem) {
  					if (scheduleItem.hasOwnProperty(key)) {
    					console.log(key + " -> " + scheduleItem[key]);
  					}
				}
                scheduleProducts.push(scheduleItem);
            }
        }else{
            var iLen = ids.length;
            for (var i=0; i < iLen; i++){
                if (ids[i] == cId){
                    ids.splice(i, 1);
                    if (scheduleProducts.length > i && scheduleProducts[i].price__c == cId){
                        console.log("scheduleItem removed:" + scheduleProducts[i]);
                        scheduleProducts.splice(i, 1);
                    }
                    
                    break;
                }
            }
        }
    	component.set("v.selectedProducts", ids);
        component.set("v.scheduleProducts",scheduleProducts);
        
        console.log('scheduleProducts count:' + scheduleProducts.length);
        console.log('ids count:' + ids.length);
    }
    
    
})