({
    search : function(cmp, helper, recordId, prodType, fName, fThick, fWidth, fLength, fComp, fSupply) {
		// create a one-time use instance of the cloneSpec action
        // in the server-side controller
        alert('recordId:' + recordId);
        var action = cmp.get("c.searchProducts"); 
        action.setParams({ recordId : recordId,
                          productType : prodType,
                          filterProdName : fName,
                          filterThkness : fThick,
                          filterLength : fLength,
                          filterWidth : fWidth,
                          filterComposition : fComp,
                          zeroIndexPageNumber : '0',
                          restrictToSupplyChain : fSupply
                         });

        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                var rV = response.getReturnValue();
                alert('results len: ' + rV.length + ' results:' + rV);
                if (rV.length > 0){
                    var evt = $A.get("e.c:ShowSearchResults");
                    alert("evt:"+ evt);
   					evt.setParams({ "resultSet": response.getReturnValue()});
   					alert("FIRE");
                    evt.fire();
                //}
                	//this.gotoResultsTable(rV);
                }
			}
            else if (cmp.isValid() && state === "INCOMPLETE") {
                // do something
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
    
	gotoResultsTable : function(results) {
		var evt = $A.get("e.force:navigateToComponent");
		evt.setParams({
            componentDef : "c:LightningTable",
            componentAttributes: {
                fields : "ProductId, ProductName",
                latestRecords : results,
                page : "1",
                pages : "10",
                total : "200",
                pageSize : "10"
            }
        });
        alert("FIRE");
        evt.fire();
    }
})