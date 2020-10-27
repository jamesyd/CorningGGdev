({
    myAction: function(component, event, helper) {
        helper.onLoad(component, event);
    },
    
    openModelEditSchedule: function(component, event, helper) {
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;
        var action = component.get("c.getForecastRecordDetail");
        component.set("v.showSpinner", true);
        action.setParams({
            "recordId": id_str
        });
        action.setCallback(this, function(response){
            if(response.getState()==="SUCCESS" && component.isValid()){
                // alert(JSON.stringify(response.getReturnValue()));
                component.set("v.showSpinner", false);
                var rV = response.getReturnValue();
                console.log('rv getForecastRecordDetail', rV);
                if(rV[0].productLine__c == 'Concore' || rV[0].productLine__c == 'Raw Glass'){
                    component.set("v.isRaworConcore", true);
                }
                component.set("v.isOpenEditSchedule", true);
                component.set("v.mID", rV[0].Id);
                component.set("v.comment", rV[0].comments__c);
                //Set Quanity.
                component.set("v.m1q", rV[0].m1Qty__c);
                component.set("v.m2q", rV[0].m2Qty__c);
                component.set("v.m3q", rV[0].m3Qty__c);
                component.set("v.m4q", rV[0].m4Qty__c);
                component.set("v.m5q", rV[0].m5Qty__c);
                component.set("v.m6q", rV[0].m6Qty__c);
                component.set("v.m7q", rV[0].m7Qty__c);
                component.set("v.m8q", rV[0].m8Qty__c);
                component.set("v.m9q", rV[0].m9Qty__c);
                component.set("v.m10q", rV[0].m10Qty__c);
                component.set("v.m11q", rV[0].m11Qty__c);
                component.set("v.m12q", rV[0].m12Qty__c);
                component.set("v.m13q", rV[0].m13Qty__c);
                component.set("v.m14q", rV[0].m14Qty__c);
                if(rV[0].m15Qty__c){
                    component.set("v.m15q", rV[0].m15Qty__c);
                    component.set("v.m16q", rV[0].m16Qty__c);
                    component.set("v.m17q", rV[0].m17Qty__c);
                    component.set("v.m18q", rV[0].m18Qty__c);
                }else{
                    component.set("v.m15q", 0);
                    component.set("v.m16q", 0);
                    component.set("v.m17q", 0);
                    component.set("v.m18q", 0);
                }
                
                //Set Unit Price.
                component.set("v.m1p", rV[0].m1UnitPrice__c);
                component.set("v.m2p", rV[0].m2UnitPrice__c);
                component.set("v.m3p", rV[0].m3UnitPrice__c);
                component.set("v.m4p", rV[0].m4UnitPrice__c);
                component.set("v.m5p", rV[0].m5UnitPrice__c);
                component.set("v.m6p", rV[0].m6UnitPrice__c);
                component.set("v.m7p", rV[0].m7UnitPrice__c);
                component.set("v.m8p", rV[0].m8UnitPrice__c);
                component.set("v.m9p", rV[0].m9UnitPrice__c);
                component.set("v.m10p", rV[0].m10UnitPrice__c);
                component.set("v.m11p", rV[0].m11UnitPrice__c);
                component.set("v.m12p", rV[0].m12UnitPrice__c);
                component.set("v.m13p", rV[0].m13UnitPrice__c);
                component.set("v.m14p", rV[0].m14UnitPrice__c);
                
                if(rV[0].m15UnitPrice__c){
                    component.set("v.m15p", rV[0].m15UnitPrice__c);
                    component.set("v.m16p", rV[0].m16UnitPrice__c);
                    component.set("v.m17p", rV[0].m17UnitPrice__c);
                    component.set("v.m18p", rV[0].m18UnitPrice__c);
                }else{
                    component.set("v.m15p", 0);
                    component.set("v.m16p", 0);
                    component.set("v.m17p", 0);
                    component.set("v.m18p", 0);
                }
                
                //Set Month Label.
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
                    helper.setNextFourMonths(component, rV[0].m14Date__c);
                }
                
            }
        });  
        $A.enqueueAction(action); 
    },
    
    closeModelEditSchedule: function(component, event, helper) {
        // No Update
        component.set("v.mpsDate", null);
        component.set("v.isOpenEditSchedule", false);
    },
    
    updateSchedule: function(component, event, helper) {
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;
        var action = component.get("c.updateForecastSchedule");
        var params = {
            "recordId": id_str,
            "m1qUpdate": component.get("v.m1q"),
            "m2qUpdate": component.get("v.m2q"),
            "m3qUpdate": component.get("v.m3q"),
            "m4qUpdate": component.get("v.m4q"),
            "m5qUpdate": component.get("v.m5q"),
            "m6qUpdate": component.get("v.m6q"),
            "m7qUpdate": component.get("v.m7q"),
            "m8qUpdate": component.get("v.m8q"),
            "m9qUpdate": component.get("v.m9q"),
            "m10qUpdate": component.get("v.m10q"),
            "m11qUpdate": component.get("v.m11q"),
            "m12qUpdate": component.get("v.m12q"),
            "m13qUpdate": component.get("v.m13q"),
            "m14qUpdate": component.get("v.m14q"),
            "m15qUpdate": component.get("v.m15q"),
            "m16qUpdate": component.get("v.m16q"),
            "m17qUpdate": component.get("v.m17q"),
            "m18qUpdate": component.get("v.m18q"),
            
            "m1pUpdate": component.get("v.m1p"),
            "m2pUpdate": component.get("v.m2p"),
            "m3pUpdate": component.get("v.m3p"),
            "m4pUpdate": component.get("v.m4p"),
            "m5pUpdate": component.get("v.m5p"),
            "m6pUpdate": component.get("v.m6p"),
            "m7pUpdate": component.get("v.m7p"),
            "m8pUpdate": component.get("v.m8p"),
            "m9pUpdate": component.get("v.m9p"),
            "m10pUpdate": component.get("v.m10p"),
            "m11pUpdate": component.get("v.m11p"),
            "m12pUpdate": component.get("v.m12p"),
            "m13pUpdate": component.get("v.m13p"),
            "m14pUpdate": component.get("v.m14p"),
            "m15pUpdate": component.get("v.m15p"),
            "m16pUpdate": component.get("v.m16p"),
            "m17pUpdate": component.get("v.m17p"),
            "m18pUpdate": component.get("v.m18p"),
            "comment": component.get("v.comment"),
        }
        console.log('params', JSON.stringify(params));
        action.setParams({"data": JSON.stringify(params)});
        action.setCallback(this, function(response){
            if(response.getState()==="SUCCESS" && component.isValid()){
                // do nothing
            }
        });  
        $A.enqueueAction(action); 
        
        // refresh the screen
        var a = component.get('c.myAction');
        $A.enqueueAction(a);
        component.set("v.isOpenEditSchedule", false);
        
    },
    
    // *** FROM MANAGE FORECAST COMPONENT
    checkboxSelect: function(component, event, helper) {
        var selectedRec = event.getSource().get("v.value");
        var getSelectedNumber = component.get("v.selectedCount");
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
        } 
        component.set("v.selectedCount", getSelectedNumber);
    },
    
    checkboxSelectTarget: function(component, event, helper) {
        var selectedRecTarget = event.getSource().get("v.value");
        var getSelectedNumberTarget = component.get("v.selectedCountTarget");
        if (selectedRecTarget == true) {
            getSelectedNumberTarget++;
        } else {
            getSelectedNumberTarget--;
        } 
        component.set("v.selectedCountTarget", getSelectedNumberTarget);
    },
    
    transferSelected: function(component, event, helper) {  
        var tsList = component.get('v.ListOfOLIs');
        var ttList = component.get('v.TargetListOfOLIs');
        
        var transId = [];
        if (tsList.length > 0) {             
            var getAllId = component.find("boxPack");
            if (! Array.isArray(getAllId)) {
                if (getAllId.get("v.value") == true) {
                    transId.push(getAllId.get("v.text"));
                }
            } else {
                for (var i = 0; i < getAllId.length; i++) {
                    if (getAllId[i].get("v.value") == true) {
                        transId.push(getAllId[i].get("v.text"));
                    }
                }
            } 
        }
        
        var transIdTarget = [];
        if (ttList.length > 0) { 
            var getAllIdTarget = component.find("boxPackTarget");
            if (! Array.isArray(getAllIdTarget)) {
                if (getAllIdTarget.get("v.value") == true) {
                    transIdTarget.push(getAllIdTarget.get("v.text"));
                }
            } else {
                for (var i = 0; i < getAllIdTarget.length; i++) {
                    if (getAllIdTarget[i].get("v.value") == true) {
                        transIdTarget.push(getAllIdTarget[i].get("v.text"));
                    }
                }
            }
        }
        
        if (component.get('v.selectedCount') == '1' && component.get('v.selectedCountTarget') == '1') {
            helper.transferSelectedHelper(component, event, transId, transIdTarget);
        } else {
            if (component.get('v.selectedCount') != '1') {
                component.set('v.errorMessage', 'No Source Record Available, Selected or Multiple Selected. Please Select 1 Source Record.');
            }
            if (component.get('v.selectedCountTarget') != '1') {
                component.set('v.errorMessageTarget', 'No Target Record Available, Selected or Multiple Selected. Please Select 1 Source Record.');
            }
        }      	
    },
    
    copySelected: function(component, event, helper) {  
        var csList = component.get('v.ListOfOLIs');
        var ctList = component.get('v.TargetListOfOLIs');        
        
        var copyId = []; 
        if (csList.length > 0) { 
            var getAllId = component.find("boxPack");
            if (! Array.isArray(getAllId)) {
                if (getAllId.get("v.value") == true) {
                    copyId.push(getAllId.get("v.text"));
                }
            } else {
                for (var i = 0; i < getAllId.length; i++) {
                    if (getAllId[i].get("v.value") == true) {
                        copyId.push(getAllId[i].get("v.text"));
                    }
                }
            } 
        }
        
        var copyIdTarget = []; 
        if (ctList.length > 0) { 
            var getAllIdTarget = component.find("boxPackTarget");
            if (! Array.isArray(getAllIdTarget)) {
                if (getAllIdTarget.get("v.value") == true) {
                    copyIdTarget.push(getAllIdTarget.get("v.text"));
                }
            } else {
                for (var i = 0; i < getAllIdTarget.length; i++) {
                    if (getAllIdTarget[i].get("v.value") == true) {
                        copyIdTarget.push(getAllIdTarget[i].get("v.text"));
                    }
                }
            } 
        }
        
        if (component.get('v.selectedCount') == '1' && component.get('v.selectedCountTarget') == '1') {
            helper.copySelectedHelper(component, event, copyId, copyIdTarget);
        } else {
            if (component.get('v.selectedCount') != '1') {
                component.set('v.errorMessage', 
                              'No Source Record Available, Selected or Multiple Selected. Please Select 1 Source Record.');
            }
            if (component.get('v.selectedCountTarget') != '1') {
                component.set('v.errorMessageTarget', 
                              'No Target Record Available, Selected or Multiple Selected. Please Select 1 Target Record.');
            }
        }      	
    },
    
    deleteSelected: function(component, event, helper) {
        var dsList = component.get('v.ListOfOLIs');
        
        var delId = [];
        if (dsList.length > 0) { 
            var getAllId = component.find("boxPack");
            if (! Array.isArray(getAllId)) {
                if (getAllId.get("v.value") == true) {
                    delId.push(getAllId.get("v.text"));
                }
            } else {
                for (var i = 0; i < getAllId.length; i++) {
                    if (getAllId[i].get("v.value") == true) {
                        delId.push(getAllId[i].get("v.text"));
                    }
                }
            } 
        }
        
        if (component.get('v.selectedCount') == '1' && dsList.length > 1) {
            helper.deleteSelectedHelper(component, event, delId);
        } else {
            if (dsList.length === 1) {
                component.set('v.errorMessage', 
                              'The Last Forecast Cannot be Deleted.');
            }  
            if (component.get('v.selectedCount') != '1') {
                component.set('v.errorMessage', 
                              'No Source Record Selected or Multiple Selected. Please Select 1 Source Record.');
            }            
        }
    },
    
    // *** NEW CODE MANAGE FORECAST COMPONENT
    openModelManage: function(component, event, helper) {
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;
        component.set("v.opportunityId", id_str);
        helper.openModelManageHelper(component);
        
    },
    
    closeModelManage: function(component, event, helper) {
        component.set("v.isOpenManage", false);
    },
    
    // *** NEW CODE EDIT TPM, START DATE, END PROGRAM
    openModelEdit: function(component, event, helper) {
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;
        var action = component.get("c.getForecastRecordDetail");
        action.setParams({
            "recordId": id_str
        });
        action.setCallback(this, function(response){
            if(response.getState()==="SUCCESS" && component.isValid()) {
                var rV = response.getReturnValue();
                console.log('response', rV);
                console.log('Ship To Customer', rV[0].shipToCustomer__c);
                console.log('Account', rV[0].tpmAccount__r);
                console.log('Finisher Yield', rV[0].finisherYield__c);
                console.log('Finisher Mix', rV[0].finisherMix__c);
                console.log('MP Start Date', rV[0].massProductionStartDate__c);
                component.set("v.mID", rV[0].Id);

                //Reset Values
                component.set("v.selectedLookUpRecord","");
                component.set("v.mpsDate","");
                component.set("v.finisherMix",0);
                component.set("v.finisherYeild",0);
                
                //PARTS
                if(rV[0].tpmAccount__r){
                    component.set("v.selectedLookUpRecord", rV[0].tpmAccount__r);
                //RAW AND CONCORE
                }else if(rV[0].finisherAccount__r){
                    component.set("v.selectedLookUpRecord", rV[0].finisherAccount__r);
                }               
                
                if(rV[0].massProductionStartDate__c){
                    component.set("v.mpsDate", rV[0].massProductionStartDate__c);
                }
                
                if(rV[0].finisherMix__c){
                    component.set("v.finisherMix", rV[0].finisherMix__c);
                }
                if(rV[0].finisherYield__c){
                    component.set("v.finisherYeild", rV[0].finisherYield__c);
                }
                component.set("v.isOpenEdit", true);
            }
        });  
        $A.enqueueAction(action);
        
    },
    
    closeModelEdit: function(component, event, helper) {
        component.set("v.errorMessageCheckbox", "");
        component.set("v.isOpenEdit", false);
    },
    
    // the JS method and Apex method cannot be named the same
    // the setParams name value cannot be named the same
    updateEditDetails: function(component, event, helper) {
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;
        var action = component.get("c.updateForecastDetails");
        console.log('@@##' + JSON.stringify(component.get("v.selectedLookUpRecord")));
        var selectedLookup = component.get("v.selectedLookUpRecord");
        if(typeof selectedLookup == 'undefined'){
            helper.showMyToast("pester", "Something Went Wrong", 
                               "Please check values are populated properly",
                               "error");
            return;
        }else{
            if(typeof selectedLookup.Id == 'undefined'){
                helper.showMyToast("pester", "Something Went Wrong", 
                                   "Please check values are populated properly",
                                   "error");
                return;
            }
        }
        
        var params = {
            "recordId": id_str,
            "accountId": component.get("v.selectedLookUpRecord").Id,
            "accountOwnerId": component.get("v.selectedLookUpRecord").OwnerId,
            "accountName" : component.get("v.selectedLookUpRecord").Name,
            "mpStartDate": component.get("v.mpsDate"),
            "finisherMix": parseFloat(component.get("v.finisherMix")),
            "finisherYeild": parseFloat(component.get("v.finisherYeild")),
        }
        action.setParams(params);
        action.setCallback(this, function(response){
            if(response.getState()==="SUCCESS" && component.isValid()){
                component.set("v.selectedLookUpRecord","{}");
                component.set("v.mpsDate", null);
                component.set("v.finisherMix", 0);
                component.set("v.finisherYeild", 0);
            }
        });  
        $A.enqueueAction(action); 
        
        // refresh the screen
        var a = component.get('c.myAction');
        $A.enqueueAction(a);
        component.set("v.isOpenEdit", false);
        
    },
    
    onCheckEnd: function(component, event, helper) {
        var isSelected = event.getSource().get("v.value");
        component.set("v.endProgramConfirm", isSelected);
    },
    
    endProgram: function(component, event, helper) {
        var checkConfirm = component.get("v.endProgramConfirm");
        if (checkConfirm == true) {
            var ctarget = event.currentTarget;
            var id_str = ctarget.dataset.value;
            
            var action = component.get("c.completeProgram");
            action.setParams({
                "recordId": id_str,
            });
            action.setCallback(this, function(response){
                if(response.getState()==="SUCCESS" && component.isValid()){
                    // do nothing
                    component.set("v.mpsDate", null);
                }
            });  
            $A.enqueueAction(action);        
            // refresh the screen
            var a = component.get('c.myAction');
            $A.enqueueAction(a);
            component.set("v.endProgramConfirm",false);
            component.set("v.isOpenEdit", false);
        } else {
            component.set('v.errorMessageCheckbox', 'Please confirm by selecting the checkbox.');
        }
    },
    handleSearchInput: function(component, event, helper) {
        var isEnterKey = event.keyCode === 13;
        if (isEnterKey) {
            console.log("Search Called", component.get("v.searchStr"));
            helper.onLoad(component, event);
        }
    },
    handleSearchButton: function(component, event, helper) {
        console.log("Search Called", component.get("v.searchStr"));
        helper.onLoad(component, event);
    },
    
    handleTabActive: function(component, event, helper) {
        var tab = event.getSource();
        //helper.waitSpinner(component, true);
        let searchStr = component.get("v.searchStr");
        if(searchStr != ''){
            component.set("v.searchStr", "");
            helper.onLoad(component, event);
        }
        switch (tab.get('v.id')) {
            case 'part' :
                helper.onLoad(component, event);
                component.set("v.productLine", "Parts");
                component.set("v.isRaworConcoreActive", false);
                component.set("v.isRaworConcore", false);
                //component.set("v.showSpinner", false);
                break;
            case 'rawglass' :
                helper.onLoad(component, event);
                component.set("v.productLine", "Raw Glass");
                component.set("v.isRaworConcoreActive", true);
                component.set("v.isRaworConcore", true);
                //component.set("v.showSpinner", false);
                break;
            case 'concore' :
                helper.onLoad(component, event);
                component.set("v.productLine", "Concore");
                component.set("v.isRaworConcoreActive", true);
                component.set("v.isRaworConcore", true);
                //component.set("v.showSpinner", false);
                break;
        }
    },
    
    addNewProductController: function(component, event, helper) {
        helper.addNewProductHelper(component);
    }
    
    
})