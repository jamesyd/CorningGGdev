({  
    
    
    Refresh: function(component, event, helper){
      	//alert('in refresh!');
        helper.initialize(component);  
    },
    
    handleSampleProductAdded: function(component, event, helper){
        helper.sampleHasOneLineItem(component, true);
    },
    
    //initialization, set basic details such as sample opportunity or quote, etc.
    doInit : function(component, event, helper) {
        helper.initialize(component);
 	},

	//handles the page change event in the paginator for search results
    pageChange: function(cmp, event, helper) {
         var pageNumber = cmp.get("v.currentPageNumber") || 0;
         var direction = event.getParam("direction");
         pageNumber = direction === "previous" ? (pageNumber - 1) : (pageNumber + 1);
         if (pageNumber < 0){
         	pageNumber = 0;   
         }
         cmp.set("v.currentPageNumber", pageNumber);
        
         var searchType = cmp.get("v.searchType");
        //if the user initiated search, move page and call search
        if (searchType == cmp.get("v.userSearch") ){
		 	helper.search(cmp);
        }else{
            //if MTO products were loaded
            helper.handleTabActive(cmp);
        }
    },
    
    
    //supply chain checkbox clicked
    supplyChainSelected: function(component, event, helper){
    	//call helper's search function
    	console.log('in controller.supplyChainSelected');
    	helper.supplyChainSelected(component);
        //helper.search(component);
    },
    
    //handle search
    handleSearch : function(cmp, event, helper) {
        var tabId;
        var prodType;
        var tab = event.getSource();
        var tabId = tab.get("v.name");
        //which tab is selected?
        switch (tabId) {
            case 'Parts' :
                prodType = cmp.get("v.ctrl.partsProductType");
                break;
            case 'Raw Glass' :
                prodType = cmp.get("v.ctrl.rawProductType");                  
                break;
            case 'Concore' :
                prodType = cmp.get("v.ctrl.concoreProductType");
                break;
        };
        
        console.log("handleSearch: prodType " + prodType);
        
        cmp.set("v.prodType", prodType);
        cmp.set("v.selectedTab", tabId);
        cmp.set("v.currentPageNumber", 0);//reset page number
   
        console.log("handleSearch isQuote:" + cmp.get("v.isQuote")); // AN
        console.log("handleSearch isSample:" + cmp.get("v.isSample")); // AN
        console.log("handleSearch isProgramOpty:" + cmp.get("v.isProgramOpty")); // AN
        
        //call helper's search function
        helper.search(cmp);
        
	}, 
    
    handleEnterKey: function(component, event, helper){
      	console.log('in handleEnterKey');
        console.log(event.getParams().keyCode);
        
      	if(event.getParams().keyCode == 13){
            console.log('handling enter key');
            
            var prodType;

            var tabId = event.getSource().getLocalId();
            //which tab is selected?
            switch (tabId) {
                case 'Parts' :
                    prodType = component.get("v.ctrl.partsProductType");
                    break;
                case 'Raw Glass' :
                    prodType = component.get("v.ctrl.rawProductType");                  
                    break;
                case 'Concore' :
                    prodType = component.get("v.ctrl.concoreProductType");
                    break;
            };
            
            console.log("handleSearch: prodType " + prodType);
            
           // component.set("v.prodType", prodType);
           // component.set("v.selectedTab", tabId);
           // component.set("v.currentPageNumber", 0);//reset page number
            
        	//console.log("handleEnterKey isQuote:" + component.get("v.isQuote")); // AN
        	//console.log("handleEnterKey isSample:" + component.get("v.isSample")); // AN
        	//console.log("handleEnterKey isProgramOpty:" + component.get("v.isProgramOpty")); // AN 
            
            //call helper's search function
            helper.search(component);
            
            event.preventDefault();
            
            //this.handleSearch(component, event, helper);
      	} 
        
    },
    
    updateSearchText: function(cmp, event, helper){
        var txt = event.getSource();
        var str = txt.get("v.value");
        console.log("filterstr:" + str);
        cmp.set("v.filterStr", str);
    },
    
    //when tab is changed, change the parameters for search and clean out the prior search results
    /*searchTabChanged : function(cmp, event, helper){
        helper.handleTabChange(cmp);   
    },*/
    
    //when tab is changed, change the parameters for search and clean out the prior search results
    handleTabActive : function(cmp, event, helper){
    	var tab = event.getSource();
        var tabId = tab.get('v.id');
        
        var prodType;
        console.log("tabId" + tabId);
        //which tab is selected?
        switch (tabId) {
            case 'Parts' :
                prodType = cmp.get("v.ctrl.partsProductType");
                break;
            case 'Raw' :
                prodType = cmp.get("v.ctrl.rawProductType");                  
                break;
            case 'Concore' :
                prodType = cmp.get("v.ctrl.concoreProductType");
                break;
        };
        
        console.log("handleTabActive prodType " + prodType);
        
        cmp.set("v.prodType", prodType);
        cmp.set("v.selectedTab", tabId);
        cmp.set("v.currentPageNumber", 0);//reset page number
        
        helper.handleTabActive(cmp);   
    },
    
    handleClose: function(cmp, event, helper){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:GorillaGlassProducts",
            componentAttributes: {
                recordId : cmp.get("v.recordId")
            }
        });
        evt.fire();
    },
    
 	handleCancel : function(cmp, event, helper) {   
        
        //just close the form
        $A.get("e.force:closeQuickAction").fire();
        
    }/*,
    
    //set default tab for sample opportunity
    setDefaultTabforSample: function(component){
        var rV = component.get("v.ctrl");
        
        if (rV == undefined){
            return;
        }
        var cTab = component.get("v.selectedTab");
        if (rV.isSampleOpportunity){
        	//show or hide tabs when selecting products for sample opportunity
            var lowerRecordType = "raw";//rV.recordTypeName.toLowerCase();
            
            console.log("lowerRecordType =" + lowerRecordType);
        	var sTab = "parts";
          	
        	//for raw/concore sample, hide parts tab
            //alert("lowerRecordType:" + lowerRecordType);
        	if (lowerRecordType.includes("raw")){
          		sTab = "raw";
            }			
            if (cTab != sTab){
                component.set("v.selectedTab", sTab);
            }
            //alert('sampleOpty!');
      	}
    }*/
})