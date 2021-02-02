({
    fetchFilesDetailsHelper : function(cmp) {
        var self = this;
        var params = {specificationId : cmp.get("v.recordId")};
        self.makeHTTPRequest(cmp, "c.getFilesDetails", params, "fetchFilesDetailsHelper");
    },
    
    deleteFilesDetailsHelper : function(cmp) {
        var self = this;
        var selectedDocumentIds = new Array();
        var selDocs = cmp.get("v.selectedDocumentIds");
        
        for(var i=0; i<selDocs.length; i++){
            selectedDocumentIds.push(selDocs[i]);
        }
        var params = { documentIds : selectedDocumentIds, specId:  cmp.get("v.recordId")};
        self.makeHTTPRequest(cmp, "c.deleteSpecificationFiles", params, "deleteFilesDetailsHelper");
    },
    
    makeHTTPRequest: function(cmp, functionName, params, methodName) {
        cmp.set("v.showSpinner", true);
        var self = this;
        var action = cmp.get(functionName);
        action.setParams(params);
        action.setCallback(this, function(response) {
            cmp.set("v.showSpinner", false);
            var state = response.getState();
            if (state === "SUCCESS") {
                var results = response.getReturnValue();
                //console.log("From server: " , methodName, results);
                
                if(methodName == "fetchFilesDetailsHelper"){
                    if(!results.isSuccess || typeof results.filesList == 'undefined'){
                        //self.showToastHelper(cmp, 'Error!', 'No Files Found', 'pester', 'error');
                        cmp.set('v.data', []);
                        cmp.set('v.totalfiles', 0);
                        cmp.set("v.disableButton", true);
                        return;
                    }
                    cmp.set('v.data', results.filesList);
                    cmp.set('v.totalfiles', results.filesList.length);
                }else if(methodName == "deleteFilesDetailsHelper"){
                    if(!results.isSuccess){
                        self.showToastHelper(cmp, 'Error! Unable to delete file(s)', results.errorMessage, 
                                             'pester', 'error');
                        return;
                    
                    }else{
                        self.showToastHelper(cmp, 'Success!', 
                                             'File(s) deleted successfully.', 'pester', 'success');
                        
                        self.makeHTTPRequest(cmp, "c.getFilesDetails", 
                                             {specificationId : cmp.get("v.recordId")}, "fetchFilesDetailsHelper");
                        cmp.set("v.refresh", false);
                        cmp.set("v.refresh", true);
                    }
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
        $A.enqueueAction(action);
    },
    
    downloadFilesHelper: function(cmp){
        var selDocs = cmp.get("v.selectedDocumentIds");
        var contentVersionIds = new Array();
        for(var i=0; i<selDocs.length; i++){
            contentVersionIds.push(selDocs[i]);
        }
        var jd='/sfc/servlet.shepherd/document/download/'+ contentVersionIds.join('/') + '?operationContext=S1' + '&filename=foo.zip';
        console.log(jd);
        window.open(jd);
        
        //window.open('/sfc/servlet.shepherd/document/download/'+ contentVersionIds.join('/') + '?operationContext=S1' + '&filename=foo.zip');
        console.log("back from shepherd");
    },
    
    showToastHelper : function(cmp, title, message, mode, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "mode": mode,
            "type": type,
        });
        toastEvent.fire();
    },
    
    // Invokes the subscribe method on the empApi component
    subscribe : function(component, event) {
        // Get the empApi component
        const empApi = component.find('empApi');
        // Get the channel from the input box
        const channel = component.get('v.channel');
        // Replay option to get new events
        const replayId = -1;

        // Subscribe to an event
        empApi.subscribe(channel, replayId, $A.getCallback(eventReceived => {
            // Process event
            var eventData = JSON.parse(JSON.stringify(eventReceived));
            var currentRecordId = component.get("v.recordId");
            var eventRecordId = eventReceived.data.payload.LinkentityId__c;
            //console.log('Received event ', currentRecordId, eventRecordId, eventRecordId);
            if(currentRecordId == eventRecordId){
            	this.fetchFilesDetailsHelper(component);
        	}
        }))
        .then(subscription => {
            console.log('Subscribed to channel ', subscription.channel);
            component.set('v.subscription', subscription);
        });
    },
})