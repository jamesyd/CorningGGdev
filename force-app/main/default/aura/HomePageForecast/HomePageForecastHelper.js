({
    
    onLoad: function(component, event) {
  		component.set("v.showSpinner", true);
        var action = component.get("c.getForecastRecords");
        var param = {
            "forecastStr": component.get("v.searchStr")
        }
        action.setParams(param);
        action.setCallback(this, function(response){
            component.set("v.showSpinner", false);
            if(response.getState()==="SUCCESS" && component.isValid()){
                component.set("v.f52s", response.getReturnValue());                
                var rV = response.getReturnValue();
                console.log('rv', rV);
                
                // check if the variable has a truthy value
                if (rV.length > 0) {
                    component.set("v.m1l", rV[0].m1Label__c);
                    component.set("v.m2l", rV[0].m2Label__c);
                    component.set("v.m3l", rV[0].m3Label__c);
                    component.set("v.m4l", rV[0].m4Label__c);
                    component.set("v.m5l", rV[0].m5Label__c);
                    component.set("v.m6l", rV[0].m6Label__c);
                    component.set("v.m7l", rV[0].m7Label__c);
                    component.set("v.m8l", rV[0].m8Label__c);
                    component.set("v.m9l", rV[0].m9Label__c);
                    component.set("v.m10l", rV[0].m10Label__c);
                    component.set("v.m11l", rV[0].m11Label__c);
                    component.set("v.m12l", rV[0].m12Label__c);
                    component.set("v.m13l", rV[0].m13Label__c);
                    component.set("v.m14l", rV[0].m14Label__c);
                    
                    if(rV[0].m15Label__c){
                        component.set("v.m15l", rV[0].m15Label__c);
                        component.set("v.m16l", rV[0].m16Label__c);
                        component.set("v.m17l", rV[0].m17Label__c);
                        component.set("v.m18l", rV[0].m18Label__c);
                    }else{
                        this.setNextFourMonths(component, rV[0].m14Date__c);
                    }
                }
        	}
        });
        $A.enqueueAction(action);
        
 	},
    
    setNextFourMonths: function(component, fourteenthMonthDate){
        var d = new Date(fourteenthMonthDate);
        var month = new Array();
        month[0] = "January";
        month[1] = "February";
        month[2] = "March";
        month[3] = "April";
        month[4] = "May";
        month[5] = "June";
        month[6] = "July";
        month[7] = "August";
        month[8] = "September";
        month[9] = "October";
        month[10] = "November";
        month[11] = "December";
        
        component.set("v.m15l", month[d.getMonth()+1]);
        component.set("v.m16l", month[d.getMonth()+2]);
        component.set("v.m17l", month[d.getMonth()+3]);
        component.set("v.m18l", month[d.getMonth()+4]);
    },
    
    // *** FROM MANAGE FORECAST COMPONENT 
    transferSelectedHelper: function(component, event, transferRecordsIds, transferRecordsIdsTarget) {
        this.waitSpinner(component, true);
                    
  		var action = component.get('c.copyRecords');
  		action.setParams({"lstRecordId": transferRecordsIds,
                          "lstRecordIdTarget": transferRecordsIdsTarget                         
                         });
  		action.setCallback(this, function(response) {
   			var state = response.getState();
   			if (state === "SUCCESS") {
    			if (response.getReturnValue() != '') {
     				alert('The following error has occurred. while Copying record-->' + response.getReturnValue());
   				}
   			}else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
  		});
        
        var action2 = component.get('c.deleteRecords');
  		action2.setParams({"lstRecordId": transferRecordsIds});
  		action2.setCallback(this, function(response) {
   			var state = response.getState();
   			if (state === "SUCCESS") {
    			if (response.getReturnValue() != '') {
     				alert('The following error has occurred. while Delete record-->' + response.getReturnValue());
   				}
    			this.onLoad(component, event);
                this.waitSpinner(component, false);
                component.set("v.isOpenManage", false);
   			}else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
  		});
        
  		$A.enqueueAction(action);
        $A.enqueueAction(action2);
        
 	},
    
    copySelectedHelper: function(component, event, copyRecordsIds, copyRecordsIdsTarget) {
        this.waitSpinner(component, true);                    
  		var action = component.get('c.copyRecords');
  		action.setParams({"lstRecordId": copyRecordsIds,
                           "lstRecordIdTarget": copyRecordsIdsTarget     
                         });
  		action.setCallback(this, function(response) {
   			var state = response.getState();
            console.log(state);
            this.waitSpinner(component, false);
   			if (state === "SUCCESS") {
    			if (response.getReturnValue() != '') {
     				alert('The following error has occurred. while Copy record-->' + response.getReturnValue());
   				}
    			this.onLoad(component, event);
                
                component.set("v.isOpenManage", false);
   			}else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
  		});
  		$A.enqueueAction(action);
     
 	},
    
 	deleteSelectedHelper: function(component, event, deleteRecordsIds) {
        this.waitSpinner(component, true);
                    
  		var action = component.get('c.deleteRecords');
  		action.setParams({"lstRecordId": deleteRecordsIds});
  		action.setCallback(this, function(response) {
   			var state = response.getState();
   			if (state === "SUCCESS") {
    			if (response.getReturnValue() != '') {
     				alert('The following error has occurred. while Delete record-->' + response.getReturnValue());
   				}
    			this.onLoad(component, event);
                this.waitSpinner(component, false);
                component.set("v.isOpenManage", false);
   			}
  		});
  		$A.enqueueAction(action);
     
 	},
    
    addNewProductHelper: function(component) {
        this.waitSpinner(component, true);
        
        var actionNew = component.get("c.addNewProduct");
        actionNew.setParams({ opportunityId : component.get("v.opportunityId") });
        actionNew.setCallback(this, function(response) {
            var state = response.getState();
            this.waitSpinner(component, false);
            if (state === "SUCCESS") {
                //component.set("v.isOpenManage", false);
                this.openModelManageHelper(component);
                let responseVar = response.getReturnValue();
                if(!responseVar.isuccess){
                    alert('Error'+responseVar.errormessage);
                }
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(actionNew);
 	},
    
    openModelManageHelper: function(component){
        var action = component.get("c.getOLIsWithSchedules");
        // Opportunity ID passed
        action.setParams({
            "recordId": component.get("v.opportunityId")
        });
        action.setCallback(this, function(response){
            console.log('response', response.getReturnValue());
            if(response.getState()==="SUCCESS" && component.isValid()){
                component.set("v.isOpenManage", true);
                component.set('v.ListOfOLIs', response.getReturnValue());
                console.log(response.getReturnValue());
                component.set('v.errorMessage', '');
                component.set('v.errorMessageTarget', '');
                component.set('v.selectedCount', 0);
                component.set('v.selectedCountTarget', 0);
            }
        });  
        
        var action2 = component.get("c.getOLIsWithoutSchedules");
        action2.setParams({ recordId : component.get("v.opportunityId") });
        action2.setCallback(this, function(response) {
            var state2 = response.getState();
            if (state2 === "SUCCESS") {
                console.log('response', response.getReturnValue());
                component.set('v.TargetListOfOLIs', response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action); 
        $A.enqueueAction(action2);
    },
    
    waitSpinner: function(component, showSpinner){
        if (showSpinner) {
            component.set("v.waitSpinnerStyle", "slds-show");    
        } else {
            component.set("v.waitSpinnerStyle", "slds-hide");
        }
    }, 
    showMyToast : function(mode, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "mode":mode,
            "type":type
        });
        toastEvent.fire();
    }

})