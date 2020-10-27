({
 	doInit : function(component, event, helper) {
		var page = component.get("v.page") || 1;
        alert("DO INIT");
       //var results = event.getParam("resultSet");
       //alert('ResultValue:'+ResultValue);
       // set the handler attributes based on event data
       
       helper.loadRecords(component, page);  
   	},
    
    pageChange: function(component, event, helper) {
         var page = component.get("v.page") || 1;
         var direction = event.getParam("direction");
         page = direction === "previous" ? (page - 1) : (page + 1);
         helper.getsObjectRecords(component,page); 
    },   

    handleApplicationEvent : function(component, event) {
        alert("handleApplicationEvent");
        var results = event.getParam("resultSet");
        // set the handler attributes based on event data
        cmp.set("v.latestRecords", results);
    }
})