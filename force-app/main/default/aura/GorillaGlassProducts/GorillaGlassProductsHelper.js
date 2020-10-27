({
    approveSamplePrice: function(component){
        var action = component.get("c.processPLMApprovalSample");
        var recordId = component.get("v.recordId");
        var isSampleQuote = component.get("v.isSampleQuote");
        var lineItems = component.get('v.optyLineItems');
        var sIds = component.get("v.selectedIds");
        if (sIds == undefined || sIds.length == 0){
            component.set('v.saveMessage', "Nothing to approveSamplePrice.");
            return;
        }
        
        this.waitSpinner(component, true);
        
        console.log("going to approveSamplePrice");
        
        var len = sIds.length;
        console.log("going to approve: len:" + len);
        var selectedLIs = new Array();
        var li;
        for (var i = 0; i < len; i++){
            li = lineItems[sIds[i]];
            console.log("going to approve: id" + li.Id);
            delete li.errorMessage;
            delete li.errorStyle;
            selectedLIs.push(li);
        }
        
        action.setParams({ strOptyLineItems : JSON.stringify(selectedLIs),
                          opttyId : recordId});
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var rV = response.getReturnValue();
                if (rV.success == true){
                    sIds = new Array();
                    component.set("v.selectedIds", sIds);
                    
                    //this.loadOptyLIs(component, false);
                    
                    //close component and go back to the sample - Ajay 5/4/2017
                    this.waitSpinner(component, false);
                    this.closeComponent(component);
                    
                }else{
                    component.set("v.saveMessage", "Request failed! (" + rV.saveMessage + ")");
                    //message
                    var arrayLength = rV.liSaveMessages.length;
                    var msg;
                    for (var i = 0; i < arrayLength; i++) {
                        msg = rV.liSaveMessages[i];
                        lineItems[sIds[i]].errorMessage = msg.message;
                        lineItems[sIds[i]].errorStyle = "slds-show";
                    }
                    this.waitSpinner(component, false);
                }
                
            }else{
                component.set("v.saveMessage", "Request failed! (" + rV.saveMessage + ")");
                //message
                var arrayLength = rV.liSaveMessages.length;
                var msg;
                for (var i = 0; i < arrayLength; i++) {
                    msg = rV.liSaveMessages[i];
                    lineItems[sIds[i]].errorMessage = msg.message;
                    lineItems[sIds[i]].errorStyle = "slds-show";
                }
                this.waitSpinner(component, false);
            }
            
        });
        $A.enqueueAction(action);    
    },
    
    approveQuoteLines: function(component, approvePrice, extendExpiry){
        var action = component.get("c.processPLMApprovalQuote");
        var recordId = component.get("v.recordId");
        var isSampleQuote = component.get("v.isSampleQuote");
        var lineItems = component.get('v.quoteLineItems');
        var sIds = component.get("v.selectedIds");
        if (sIds == undefined || sIds.length == 0){
            component.set('v.saveMessage', "Nothing to delete.");
            return;
        }
        
        this.waitSpinner(component, true);
        
        console.log("going to delete");
        
        var len = sIds.length;
        console.log("going to approve: len:" + len);
        var selectedLIs = new Array();
        var li;
        for (var i = 0; i < len; i++){
            li = lineItems[sIds[i]];
            console.log("going to approve: id" + li.Id);
            delete li.errorMessage;
            delete li.errorStyle;
            selectedLIs.push(li);
        }
        
        action.setParams({ strQuoteLineItems : JSON.stringify(selectedLIs),
                          approvePrice: approvePrice,
                          extendExpiry: extendExpiry,
                          quoteId: recordId,
                          isSampleQuote: isSampleQuote});
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var rV = response.getReturnValue();
                if (rV.success == true){
                    sIds = new Array();
                    component.set("v.selectedIds", sIds);
                    this.loadQuoteLIs(component, false);
                    //this.loadQuoteLIs(component, false);
                    //this.waitSpinner(component, false);
                }else{
                    component.set("v.saveMessage", "Request failed! (" + rV.saveMessage + ")");
                    //message
                    var arrayLength = rV.liSaveMessages.length;
                    var msg;
                    for (var i = 0; i < arrayLength; i++) {
                        msg = rV.liSaveMessages[i];
                        lineItems[sIds[i]].errorMessage = msg.message;
                        lineItems[sIds[i]].errorStyle = "slds-show";
                    }
                    this.waitSpinner(component, false);
                }
            }else{
                component.set("v.saveMessage", "Request failed! (" + rV.saveMessage + ")");
                //message
                var arrayLength = rV.liSaveMessages.length;
                var msg;
                for (var i = 0; i < arrayLength; i++) {
                    msg = rV.liSaveMessages[i];
                    lineItems[sIds[i]].errorMessage = msg.message;
                    lineItems[sIds[i]].errorStyle = "slds-show";
                }
                this.waitSpinner(component, false);
            }
            
        });
        $A.enqueueAction(action);
    },
    
    handleApprovePrice: function(component){
        if (component.get("v.editingQuote")){
            this.approveQuoteLines(component, true, true);
        }else{
            if (component.get("v.isSampleOptty")){
                this.approveSamplePrice(component);
            }
        }
    },
    
    handleExtendExpiry: function(component){
        if (component.get("v.editingQuote")){
            this.approveQuoteLines(component, false, true);
        }
        //alert("coming soon!");
    },
    
    showScheduleButton: function(component){
        return;
        /*var btn = component.find("ScheduleBtn");
		console.log("btn: " + btn);
		$A.util.removeClass(btn, "slds-show");
		$A.util.addClass(btn, "slds-hide");*/
        component.set("v.scheduleBtnStyle", "slds-button slds-button--neutral");
    },
    
    refreshAddProducts: function(component, event, helper){
        var refresh = component.get("v.refreshSearchOnTabChange");
        if (refresh){
            //alert('firing event');
            var compEvent = $A.get("e.c:RefreshSearchTab");//component.getEvent("RefreshSearchTab");
            compEvent.fire();
        }else{
            component.set("v.refreshSearchOnTabChange", true);
        }
    },
    
    setLineItemstab: function(component){
        component.set("v.selectedTab", "editProducts");
    },
    
    setRecordEditMessage: function(component){
        
        var recordEditable = component.get("v.recordAccess.RecordEditable");
        if(typeof recordEditable != 'undefined'){
            var recordAccessMessageClass = recordEditable ? "slds-hide":"slds-text-title slds-show";
            component.set("v.recordAccessMessageClass", recordAccessMessageClass);
            if (!recordEditable){
                component.set("v.recordAccessMessage", 
                              component.get("v.editingQuote") 
                              ? "You don't have access to edit this quote."
                              : "You don't have access to edit this opportunity.");
            }
        }
        
    },
    
    waitSpinner: function(component, showSpinner){
        if (showSpinner){
            component.set("v.waitSpinnerStyle", "slds-show");    
        }else{
            component.set("v.waitSpinnerStyle", "slds-hide");
        }
    },
    
    handleSelectedLI: function(component, cId, isSelected){
        var ids = component.get("v.selectedIds");
        if (isSelected){
            console.log('selected id:' + cId);
            ids.push(cId);
        }else{
            var iLen = ids.length;
            for (var i=0; i < iLen; i++){
                if (ids[i] == cId){
                    ids.splice(i, 1);
                    break;
                }
            }
        }
        component.set("v.selectedIds", ids);
        var optyLineItems = component.get("v.optyLineItems");
        
        //enable schedule line items button only for program opportunities when at least one line item is selected
        if (!component.get("v.isSampleOptty") && optyLineItems != undefined && optyLineItems.length > 0){
            component.set("v.scheduleBtnDisabled", ids.length == 0); 
        }
        //don't allow user to delete line items from sample quote
        if (!component.get("v.isSampleQuote")){
            component.set("v.deleteBtnDisabled", ids.length == 0);
        } 
    },
    
    handleScheduleLineItems: function(component){
        alert('coming soon...');
    },
    
    handleDeleteSelected: function(component){
        if (component.get("v.editingQuote")){
            this.handleDeleteQuoteLIs(component);            
        }else{
            this.handleDeleteOpttyLIs(component);
        }
    },
    
    handleDeleteOpttyLIs: function(component){
        
        var recordId = component.get("v.recordId");
        var action = component.get("c.deleteOptyLineItems");
        var recordId = component.get("v.recordId");
        var lineItems = component.get('v.optyLineItems');
        var sIds = component.get("v.selectedIds");
        if (sIds == undefined || sIds.length == 0){
            component.set('v.saveMessage', "Nothing to delete.");
            return;
        }
        
        this.waitSpinner(component, true);
        
        console.log("going to delete");
        
        var len = sIds.length;
        console.log("going to delete: len:" + len);
        var deleteLIs = new Array();
        var li;
        for (var i = 0; i < len; i++){
            li = lineItems[sIds[i]];
            console.log("going to delete: id" + li.Id);
            delete li.errorMessage;
            delete li.errorStyle;
            deleteLIs.push(li);
        }
        
        action.setParams({ strOptyLineItems: JSON.stringify(deleteLIs)});
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var rV = response.getReturnValue();
                if (rV.success == true){
                    
                    console.log("rV =", rV);
                    var len = sIds.length;
                    
                    //remove deleted items from the component display line items
                    var deleteI;
                    for (var i=len-1; i >=0; i--){
                        deleteI = -1;
                        for (var j = 0; j < lineItems.length; j++){
                            if (lineItems[j].Id == deleteLIs[i].Id){
                                deleteI = j;
                                break;
                            }
                        }
                        if (deleteI >= 0){
                            lineItems.splice(deleteI, 1);
                        }
                    }
                    
                    sIds = new Array();
                    component.set("v.selectedIds", sIds);
                    
                }else{
                    //message
                    var arrayLength = rV.liSaveMessages.length;
                    var msg;
                    for (var i = 0; i < arrayLength; i++) {
                        msg = rV.liSaveMessages[i];
                        lineItems[sIds[i]].errorMessage = msg.message;
                        lineItems[sIds[i]].errorStyle = "slds-show";
                    }
                    component.set("v.saveMessage", "Delete request failed!");
                }
            }else{
                component.set("v.saveMessage", "Delete request failed! (status: " + state + ")");
                var arrayLength = sIds.length;
                for (var i = 0; i < arrayLength; i++) {
                    lineItems[sIds[i]].errorMessage = "";
                    lineItems[sIds[i]].errorStyle = "slds-show";
                }
            }
            console.log("lineItems.length:" + lineItems.length);
            component.set("v.optyLineItems", lineItems); 
            console.log("step 2" + lineItems.length);
            this.waitSpinner(component, false);
        });
        $A.enqueueAction(action);
    },
    
    handleDeleteQuoteLIs: function(component){
        
        var recordId = component.get("v.recordId");
        var action = component.get("c.deleteQuoteLineItems");
        var recordId = component.get("v.recordId");
        var lineItems = component.get('v.quoteLineItems');
        var sIds = component.get("v.selectedIds");
        if (sIds == undefined || sIds.length == 0){
            component.set('v.saveMessage', "Nothing to delete.");
            return;
        }
        
        this.waitSpinner(component, true);
        
        console.log("going to delete");
        
        var deleteLIs = new Array();
        sIds.forEach(function(sId, index){
            var li = {};
            var quoteLineItem = Object.assign(li, lineItems[sId]);
            delete quoteLineItem.errorMessage;
            delete quoteLineItem.errorStyle;
            deleteLIs.push(quoteLineItem);
        });
        
        action.setParams({ strQuoteLineItems : JSON.stringify(deleteLIs)});
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var rV = response.getReturnValue();
                if (rV.success == true){
                    console.log("rV deleted result line 366=", rV);
                    
                    var finalArray = [];
                    lineItems.forEach(function(lineItem, index){
                        if(!sIds.includes(index)){
                            finalArray.push(lineItem);
                        }
                    });

                    sIds = new Array();
                    component.set("v.selectedIds", sIds);
                    
                    lineItems = finalArray;
                    component.set("v.quoteLineItems", finalArray);
                    
                    //if this is a parts program quote, refresh the view since
                    //multiple QLIs will be deleted for part tiers
                    if (component.get("v.isPartsProgramQuote")){
                        this.loadQuoteLIs(component, false);
                        return;
                    }
                }else{
                    //message
                    var arrayLength = rV.liSaveMessages.length;
                    var msg;
                    for (var i = 0; i < arrayLength; i++) {
                        msg = rV.liSaveMessages[i];
                        lineItems[sIds[i]].errorMessage = msg.message;
                        lineItems[sIds[i]].errorStyle = "slds-show";
                    }
                    component.set("v.saveMessage", "Delete request failed!");
                }
            }else{
                component.set("v.saveMessage", "Delete request failed! (status: " + state + ")");
                var arrayLength = sIds.length;
                for (var i = 0; i < arrayLength; i++) {
                    lineItems[sIds[i]].errorMessage = "";
                    lineItems[sIds[i]].errorStyle = "slds-show";
                }
            }
            console.log("lineItems.length:" + lineItems.length);
            component.set("v.quoteLineItems", lineItems); 
            console.log("step 2" + lineItems.length);
            this.waitSpinner(component, false);
        });
        $A.enqueueAction(action);
    },
    
    showSearchComponent: function(cmp){
        cmp.set("v.editItemsStyle", "slds-hide");
        cmp.set("v.productSearchStyle", "slds-show");
    },
    
    hideSearchComponent: function(cmp){
        cmp.set("v.editItemsStyle", "slds-show");
        cmp.set("v.productSearchStyle", "slds-hide");        
    },
    
    //launches the same component in full page when not using SF1
    launchInFullPage: function(component){  
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:GorillaGlassProducts",
            componentAttributes: {
                recordId : component.get("v.recordId"),
                optyLineItems: component.get("v.optyLineItems"),
                productSearchStyle: component.get("v.productSearchStyle"),
                navigateToFullPage: false
            }
        });
        evt.fire();
    },
    
    setQuoteColumns: function(component){
        var cols = new Array();
        
        var blueQuote = component.get("v.isBlueQuote");
        console.log("adding Freight column...");
        cols.push("");
        cols.push("");
        cols.push("Product");
        
        cols.push("Specification");
        var lis = component.get("v.quoteLineItems");
        if (lis != undefined && lis.length > 0 && lis[0].Product2.Family != 'Parts'
            && !component.get("v.isSampleQuote")
           ){
            cols.push('MOQ');
            cols.push('Unit');
            cols.push('PLM Price');
        }
        if (!blueQuote){
            cols.push("Quantity");
            
        }
        
        
        
        if (component.get("v.isPartsProgramQuote") && !blueQuote){
            cols.push('PLM Floor Price');   
        }
        if (!component.get("v.isSampleQuote")){
            cols.push("Formal Quote Price - Must Be Issued By OEM AM.  May Be Higher Than Floor");
        }
        
        
        
        if (blueQuote){
            console.log("addingFreight column...");
            cols.push("Freight");
            component.set("v.freightStyle", "");
            cols.push("Total");
        }
        else
            //cols.push("UOM");
            if (component.get("v.isSampleQuote")){
                var quoteLIs = component.get("v.quoteLineItems");
                var partStr = $A.get("$Label.c.GGProductTypeParts");
                if (quoteLIs.length > 0 && quoteLIs[0].Product2.Family == partStr){
                    cols.push("Total Price");
                }else{
                    cols.push("Price");
                }
            }
        cols.push("Description");
        
        //Status column only added when running in SF1
        if (component.get("v.runningInSF1")){
            cols.push("Status");
        }
        
        //cols.push("Status");
        component.set("v.columns", cols);
        console.log('Items: ',component.get("v.quoteLineItems"));
    },
    
    setOpttyColumns: function(component){
        var cols = new Array();
        cols.push("");
        cols.push("");
        cols.push("Product");
        var optyLIs = component.get("v.optyLineItems");
        var isSampleOptty = component.get("v.isSampleOptty");
       // console.log('check:' + component.get("v.totalNumberOfOLIs"));
        if(component.get("v.totalNumberOfOLIs") != 0 && isSampleOptty){
            if(optyLIs[0].Opportunity.isPreBuild__c == true){  
                cols.push("Specification"); 
            }
        }
        cols.push("Quantity");
        //cols.push(component.get("v.PriceColumnHeader"));
        //cols.push("UOM");
        
        // if (isSampleOptty && optyLIs.length > 0){ // AN - 5/17
        if (isSampleOptty && optyLIs.length > 0 && optyLIs[0].Product2.Family=="Parts"){
            cols.push("Total Price");
            cols.push("Description"); // AN - 9/14
        }else{
            cols.push("Price/Pc");
            if (isSampleOptty && optyLIs.length > 0) {
                cols.push("Description"); // AN - 5/17
            }
        }
        
        if (!component.get("v.isSampleOptty"))
        {
            
            cols.push("Total Price");
            cols.push("Service Date");
            cols.push("Forecast Category");
        }
        //cols.push("PLM Pricing");
        
        //Status column only added when running in SF1
        if (component.get("v.isSampleOptty") && component.get("v.runningInSF1")){
            cols.push("Status");
        }
        
        component.set("v.columns", cols);
    },
    
    loadOptyLIs: function(component, setSelectedTab){
        this.waitSpinner(component, true);
        var recordId = component.get("v.recordId");
        var action = component.get('c.getOptyLineItems');
        action.setParams({ oId : recordId});
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var rV = response.getReturnValue();
                console.log("rV =", rV);
                var lineItems = rV.lineItems;
                var arrayLength = lineItems.length;
                for (var i = 0; i < arrayLength; i++) {
                    lineItems[i].errorMessage = "-       ----";
                    lineItems[i].errorStyle = "slds-hide";
                }
               	component.set("v.totalNumberOfOLIs", rV.totalNumberOfOLIs);
                component.set("v.recordAccess", rV.Access);
                component.set("v.isSampleOptty", rV.isSampleOptty);
                if (!rV.isSampleOptty){
                    
                    this.showScheduleButton(component);
                    //component.set("v.scheduleBtnStyle", "slds-show");
                }
                
                //show price approval button for PLM on sample requests
                if (rV.showPLMButtons){
                    if (rV.isSampleOptty){
                        component.set("v.plmApprovalBtnStyle", "slds-button slds-button--neutral");
                    }
                }
                
                /*if (rV.isSampleOptty){
                   component.set("v.PriceColumnHeader", "Price ($)");
                }*/
                component.set('v.optyLineItems', lineItems);
                component.set('v.productSearchStyle', 'slds-is-collapsed');
                component.set("v.runningInSF1", rV.runningInSF1);
                if (rV.runningInSF1 == false && component.get("v.navigateToFullPage")){
                    this.launchInFullPage(component);
                }
                this.setOpttyColumns(component);
                this.waitSpinner(component, false);
                this.setRecordEditMessage(component);
                
                //open add products tab if no existing line items
                if (setSelectedTab){
                    if (arrayLength == 0){
                        component.set("v.selectedTab", "addProducts");
                    }else{
                        component.set("v.selectedTab", "editProducts");
                    }
                }
                
            }
        });
        $A.enqueueAction(action);    
    },
    
    loadQuoteLIs: function(component, setSelectedTab){
        this.waitSpinner(component, true);
        var recordId = component.get("v.recordId");
        var action = component.get('c.getQuoteLineItems');
        action.setParams({ qId : recordId});
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var rV = response.getReturnValue();
                console.log("rV loadQuoteLIs line 612 =", rV);
                var lineItems = rV.lineItems;
                var arrayLength = lineItems.length;
                for (var i = 0; i < arrayLength; i++) {
                    lineItems[i].errorMessage = "";
                    lineItems[i].errorStyle = "slds-hide";
                }
                
                component.set("v.recordAccess", rV.Access);
                component.set("v.isSampleQuote", rV.isSampleQuote);
                /*if (rV.isSampleQuote){
                   component.set("v.PriceColumnHeader", "Price");
                }*/
                component.set("v.isBlueQuote",rV.isBlueQuote);
                component.set("v.isPartsProgramQuote", rV.isPartsProgramQuote);
                component.set("v.performFloorPriceCheck", rV.performFloorPriceCheck);
                
                component.set('v.quoteLineItems', lineItems);
                component.set('v.productSearchStyle', 'slds-is-collapsed');
                component.set("v.runningInSF1", rV.runningInSF1);
                
                //show PLM buttons on program quotes
                if (rV.showPLMButtons && !rV.isSampleQuote){
                    component.set("v.expiryBtnStyle", "slds-button slds-button--neutral");
                    component.set("v.plmApprovalBtnStyle", "slds-button slds-button--neutral");
                }
                
                if (rV.runningInSF1 == false && component.get("v.navigateToFullPage")){
                    this.launchInFullPage(component);
                }
                this.setQuoteColumns(component);
                //for sample quotes, line items can't be added or deleted
                if (rV.isSampleQuote){
                    var deleteBtn = component.find("DeleteBtn");
                    $A.util.addClass(deleteBtn, 'slds-hide');
                    var addTab = component.find("addProductsTab");
                    $A.util.addClass(addTab, 'slds-hide');
                }
                
                this.waitSpinner(component, false);
                this.setRecordEditMessage(component);
                //open add products tab if no existing line items
                if (setSelectedTab){
                    if (arrayLength == 0){
                        component.set("v.selectedTab", "addProducts");
                    }else{
                        component.set("v.selectedTab", "editProducts");
                    }
                }
                
            }
        });
        $A.enqueueAction(action);    
    },
    
    
    
    initialize : function(component) {
        
        var recordId = component.get("v.recordId");
        var currentTab = component.get("v.selectedTab");//, "addProducts");
        
        var cols = new Array();
        console.log("initializing ...")
        
        if (component.get("v.navigateToFullPage") == false){
            if (recordId.startsWith("0Q0")){
                component.set("v.editingQuote", true);
                this.loadQuoteLIs(component, currentTab != "addProducts");
            }else{
                component.set("v.expiryBtnStyle", "slds-hide");
                component.set("v.plmApprovalBtnStyle", "slds-hide");
                component.set("v.editingQuote", false);
                //component.set("v.recordAccessMessage", "You don't have access to edit this opportunity.");
                this.loadOptyLIs(component, currentTab != "addProducts"); 
                
            }
            return;
        }
        
        //if addProducts is the initial tab
        component.set("v.columns", cols);
        
        var action = component.get('c.runningInSF1');
        
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var rV = response.getReturnValue();
                if (rV == false && component.get("v.navigateToFullPage")){
                    this.launchInFullPage(component);
                }
            }
        });
        
        $A.enqueueAction(action); 
        
        /*
        if (recordId.startsWith("0Q0")){
            component.set("v.editingQuote", true);
            if (currentTab != "addProducts"){
            	this.loadQuoteLIs(component, true);
            }
            
        }else{
        	component.set("v.editingQuote", false);
            if (currentTab != "addProducts"){
            
            	this.loadOptyLIs(component, true);  
            }
                 
            //component.set("v.recordAccessMessage", "You don't have access to edit this opportunity.");
        }
        component.set("v.columns", cols);*/
    },
    
    saveRecords: function(component, saveAndClose){
        var editingQuote = component.get("v.editingQuote");
        var recordId = component.get("v.recordId");
        if (editingQuote){
            this.saveQuoteLIs(component, recordId,saveAndClose);
        }else{
            this.saveOpttyLIs(component, recordId,saveAndClose);
        }
    },
    
    closeComponent: function(component){
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    
    saveOpttyLIs: function(component, recordId, saveAndClose){
        
        var lineItems = component.get('v.optyLineItems');
        var isSampleOptty = component.get("v.isSampleOptty");
        for (var i = 0; i < lineItems.length; i++){
            delete lineItems[i].errorMessage;
            delete lineItems[i].errorStyle;
        }
        var action = component.get('c.saveOptyLineItems');
        action.setParams({ optyId : recordId, isSampleOptty: isSampleOptty, strOptyLineItems: JSON.stringify(lineItems) });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var rV = response.getReturnValue();
                //console.log("rV =" + rV);
                var optyLIs = component.get('v.optyLineItems'); 
                component.set('v.saveMessage', rV.saveMessage);
                if (rV.success != true){
                    
                    var arrayLength = rV.liSaveMessages.length;
                    var msg;
                    for (var i = 0; i < arrayLength; i++) {
                        msg = rV.liSaveMessages[i];
                        optyLIs[i].errorMessage = msg.message;
                        if (msg.success == false){
                            optyLIs[i].errorStyle = "slds-show";
                        }else{
                            optyLIs[i].errorStyle = "slds-hide";
                        }
                    }
                    
                }else{
                    var arrayLength = optyLIs.length;
                    for (var i = 0; i < arrayLength; i++) {
                        optyLIs[i].errorMessage = "";
                        optyLIs[i].errorStyle = "slds-hide";
                    }
                    
                    
                }
                if (saveAndClose){
                    this.closeComponent(component);
                }
                component.set("v.optyLineItems", optyLIs); 
            }else{
                component.set("v.saveMessage", "Save request failed! (status: " + state + ")");
            }
        });
        $A.enqueueAction(action);
    },
    
    saveQuoteLIs: function(component, recordId, saveAndClose){
        
        var lineItems = component.get('v.quoteLineItems');
        var isSampleQuote = component.get("v.isSampleQuote");
        for (var i = 0; i < lineItems.length; i++){
            delete lineItems[i].errorMessage;
            delete lineItems[i].errorStyle;
        }
        var action = component.get('c.saveQuoteLineItems');
        action.setParams({ quoteId : recordId, isSampleQuote: isSampleQuote, strQuoteLineItems: JSON.stringify(lineItems) });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var rV = response.getReturnValue();
                //console.log("rV =" + rV);
                var quoteLIs = component.get('v.quoteLineItems'); 
                component.set('v.saveMessage', rV.saveMessage);
                if (rV.success != true){
                    
                    var arrayLength = rV.liSaveMessages.length;
                    var msg;
                    for (var i = 0; i < arrayLength; i++) {
                        msg = rV.liSaveMessages[i];
                        quoteLIs[i].errorMessage = msg.message;
                        if (msg.success == false){
                            quoteLIs[i].errorStyle = "slds-show";
                        }else{
                            quoteLIs[i].errorStyle = "slds-hide";
                        }
                    }
                    component.set('v.saveMessage', "Error: " + rV.saveMessage);                                   
                }else{
                    var arrayLength = quoteLIs.length;
                    for (var i = 0; i < arrayLength; i++) {
                        if (!quoteLIs[i].priceBelowFloor__c){
                            quoteLIs[i].errorMessage = "";
                            quoteLIs[i].errorStyle = "slds-hide";
                        }
                    }
                    
                }
                if (saveAndClose){
                    this.closeComponent(component);
                }
                component.set("v.quoteLineItems", quoteLIs); 
            }else{
                component.set("v.saveMessage", "Save request failed! (status: " + state + ")");
            }
        });
        $A.enqueueAction(action);
    }
})