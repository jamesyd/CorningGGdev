({
	showHideSpinner: function(cmp, show){
        var spinner = cmp.find('waitSpinner');
        $A.util.removeClass(spinner, show ? "slds-hide" :"slds-show");
        $A.util.addClass(spinner, show ? "slds-show" :"slds-hide");    
    },
    
    showHideBadge: function(cmp, show){
        var badge = cmp.find('completed');
        $A.util.removeClass(badge, show ? "slds-hide" :"slds-show");
        $A.util.addClass(badge, show ? "slds-show" :"slds-hide");    
    }
})