({  
	handleClone : function(cmp, event, helper) {
		var recordId = cmp.get("v.recordId");
		var parentOpty = cmp.get("v.Specification.opportunity__c");
        var checkCmp = cmp.find("cbAttachments");
        var copyAttachments = checkCmp.get("v.value");
        var cloneReason = cmp.get("v.Specification.cloneReason__c");
        //call helper's clone function
        helper.clone(cmp, recordId, copyAttachments, parentOpty, cloneReason);
	},
    handleCancel : function(cmp, event, helper) {
        //just close the form
        $A.get("e.force:closeQuickAction").fire();
    }
})