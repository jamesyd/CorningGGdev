({
    
    doInit : function(component, event, helper) {
		helper.doInit(component);
	},
    
    //selection changed
    onSelCheck: function(component, event, helper){
        helper.onSelCheck(component, event, helper);
    },
    
    //if user changes quantity or schedule date after selecting the checkbox, send the 
    //checkbox message again so the parent can update quantity and schedule date
    scheduleQtyDateChange: function(component, event, helper){
      console.log("in scheduleQtyDateChange");
      var checkCmp = component.find("selChk");
      if (checkCmp.get("v.value")){
        helper.onSelCheck(component, event, helper);
      	//this.onSelCheck(component, event, helper);  
      }
        
    }
})