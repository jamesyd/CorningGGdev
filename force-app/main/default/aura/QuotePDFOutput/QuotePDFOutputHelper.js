({
    showPDFErrorMessage: function(component, canCreatePdf, errorMsg){
        if (!canCreatePdf){
           component.set("v.pdfMessageStyle", "slds-show");
           component.set("v.pdfStyle", "slds-hide");
           component.set("v.pdfMessage", errorMsg);
           component.set("v.waitSpinnerStyle", "slds-hide");
           var lis = component.get("v.errorLineItems");
           if (lis.length > 0){
           	component.set("v.errorLIStyle", "slds-show");
           }
        }
		else {
			this.save (component);
            //for Android don't try to show the PDF - Ajay 5/19
            //if ($A.get("$Browser.isAndroid")){
            //  component.set("v.pdfStyle", "slds-hide");  
            //}
            
			component.set("v.waitSpinnerStyle", "slds-hide");
		}
    },
    
    initialize: function(component){
        var recId = component.get("v.recordId");
        var action = component.get('c.getPDFInfo');
        action.setParams({ recordId : recId});
        
        action.setCallback(this,function(response){
   			var state = response.getState();
       		if (component.isValid() && state === "SUCCESS") {
                var rV = response.getReturnValue();
                console.log('rV', rV);
                if(rV.isPricingExpired){
                    component.set("v.showPDF", false);
                    component.set("v.expiredPrices", rV.expiredPrices);
                    component.set("v.waitSpinnerStyle", "slds-hide");
                    return;
                }
                component.set("v.language", rV.language);
                                
                var qli;
                var errorMessage;
                for (var i = 0; i < rV.errorLineItems.length; i++) {
                	qli = rV.errorLineItems[i];
                	errorMessage = "";
                	if (qli.Product2.isActive == false){
                		errorMessage = "Inactive";
                	}
                	
                    // if (qli.price__r.priceExpired__c){ // an 6/28 - field on wrong obect
                	if (qli.priceExpired__c){
        				if (errorMessage.length > 0){
        					errorMessage += ", ";
        				}
                		errorMessage += " Price Expired";
                	}

                    if (qli.plmRequiredToQuote__c)
                	{
        				if (errorMessage.length > 0){
        					errorMessage += ", ";
        				}
                		errorMessage += "PLM Import Duty/Logistic Adder Required";
                	}
 
                    if (qli.plmRequiredToQuoteInco__c)
                	{
        				if (errorMessage.length > 0){
        					errorMessage += ", ";
        				}
                		errorMessage += "PLM Incoterms Adder Required";
                	}
                    
        			if (qli.priceBelowFloor__c)
                	{
        				if (errorMessage.length > 0){
        					errorMessage += ", ";
        				}
                		errorMessage += "Price < PLM Price";
                	}
                	if (qli.quantityLessThanMOQ__c){
                		if (errorMessage.length > 0){
        					errorMessage += ", ";
        				}
                		errorMessage += "Quantity < MOQ";
                	}
                	qli.errorMessage = errorMessage;
                }
                
                component.set("v.errorLineItems", rV.errorLineItems);
                
                if (rV.errorLineItems){
                	console.log("error line items count: " + rV.errorLineItems.length);
                }
                
                console.log("SUCCESS :" + rV);
                this.showPDFErrorMessage(component, rV.canCreatePDF, rV.pdfCreationError);
       		}
       		else if (component.isValid() && state === "INCOMPLETE") {
                // do something
                console.log("INCOMPLETE");
                this.showPDFErrorMessage(component, false, "Error - status: " + state);
            }
            else if (component.isValid() && state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors.length > 0) {
                        console.log("Error message: " + 
                                 errors[0]);
                        var p = errors[0];
                        if (p.hasOwnProperty("pageErrors") && p["pageErrors"].length > 0){
                            console.log("Error: " + p["pageErrors"][0].message);
                        }
                        for (var key in p) {
  							if (p.hasOwnProperty(key)) {
    							console.log(key + " -> " + p[key]);
                                var p1 = p[key];

                                console.log('p1: ' + p1);
  							}
						}
                        //alert('Error: ' + errors[0].message);
                        this.showPDFErrorMessage(component, false, errors[0].message);
                    }
                    else{
                    	//alert('Unknown Error :-(');
                    	this.showPDFErrorMessage(component, false, "Unknown Error!");
                    }
                } 
                else {
                    this.showPDFErrorMessage(component, false, "Unknown Error!");
                    console.log("Unknown error");
                    //alert('Unknown Error');
                    
                }  
            }
        });
   		$A.enqueueAction(action);
   	},
    
    save : function(component) {
        var recId = component.get("v.recordId");
        var language = component.get("v.language");
        var action = component.get('c.savePDFtoQuote');
        action.setParams({ recordId : recId,
        					language : language});
        
        action.setCallback(this,function(response){
   			var state = response.getState();
       		if (component.isValid() && state === "SUCCESS") {
       			var rV = response.getReturnValue();
                console.log("SUCCESS :" + rV);
       		}
       		else if (component.isValid() && state === "INCOMPLETE") {
                // do something
                console.log("INCOMPLETE");
            }
            else if (component.isValid() && state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors.length > 0) {
                        console.log("Error message: " + 
                                 errors[0]);
                        var p = errors[0];
                        if (p.hasOwnProperty("pageErrors") && p["pageErrors"].length > 0){
                            console.log("Error: " + p["pageErrors"][0].message);
                        }
                        for (var key in p) {
  							if (p.hasOwnProperty(key)) {
    							console.log(key + " -> " + p[key]);
                                var p1 = p[key];

                                console.log('p1: ' + p1);
  							}
						}
                        alert('Error: ' + errors[0].message);
                    }
                    else{
                    	alert('Unknown Error :-(');
                    }
                } 
                else {
                    console.log("Unknown error");
                    alert('Unknown Error');
                }  
            }
        });
   		$A.enqueueAction(action);
    },
    
    cancel : function(component) {
		var recId = component.get("v.recordId");
		var navEvt = $A.get("e.force:navigateToSObject");
    	navEvt.setParams({
      		"recordId": recId,
    	});
    	navEvt.fire();
    }
})