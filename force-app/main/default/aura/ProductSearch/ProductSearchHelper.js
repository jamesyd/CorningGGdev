({    
    updateSearchComponent: function(cmp, resultSet, fieldsToShow, recordId, isSampleOpportunity, isSampleQuote, showZeroRecordMessage, isPartsSearch){
        var searchCmp = cmp.find("searchResults");
        var isProgramOpty = cmp.get("v.isProgramOpty");
        console.log("searchCmp: " + searchCmp);
        if (searchCmp){
        	searchCmp.updateSearchResults(resultSet, fieldsToShow, recordId, isSampleOpportunity, isSampleQuote, showZeroRecordMessage, isPartsSearch, isProgramOpty);
        }
	},
    
    //handle search - calls the Apex controller
    search : function(cmp){
        
        var tabId = cmp.get("v.selectedTab");
        
        var prodType = cmp.get("v.prodType");
        var recordId = cmp.get("v.recordId");
        var isProgramOpty = cmp.get("v.isProgramOpty"); // AN - 7/11
        
        console.log(isProgramOpty); // AN - 7/11
        
        cmp.set("v.searchType", cmp.get("v.userSearch"));
        
        console.log("search tabId:" + tabId);
        
        //get the search text
        var tabObjs = cmp.get("v.tabs");
        var searchStr = "";//cmp.get("v.filterStr");
        var obj;
        for (var i = 0; i < tabObjs.length; i++){
            obj = tabObjs[i];
            
            if (obj.name == tabId){
                searchStr = obj.filterStr;
                break;
            }
        }
        
        
        console.log("searchStr:" + searchStr);
       
        //for raw/concore - limit results to supply chain?
        var fSupply = false;
        var chkBoxId = tabId;
        if (tabId=="raw glass"){
        	chkBoxId = "raw";
        }
        chkBoxId = chkBoxId + "-supply";
         
		var chkBox = document.getElementById(chkBoxId);
		
		console.log("chkBox id: " + tabId + "-supply");
		
        if (chkBox){
        	fSupply = chkBox.checked;
        }
               
        var fPageNumber = cmp.get("v.currentPageNumber");
        var fMaxRecordsPerPage = cmp.get("v.maxRecordsPerPage"); 
        
        // create a one-time use instance of the search action
        // in the server-side controller
        var action = cmp.get("c.searchProducts"); 

 		// AN - new variable to pass to apex controller
 		var fIsQuote = cmp.get("v.isQuote"); // AN
        var fIsSample = cmp.get("v.isSample"); // AN
        var fIsProgramOpty = cmp.get("v.isProgramOpty"); // AN
        
        //set search params
        // AN - add additional parameters to pass to controller to prevent inventory
        console.log("search button setPArams: " + recordId); //AN
        console.log("search button setPArams: " + prodType); //AN 
        console.log("search button setPArams: " + searchStr); //AN 
        console.log("search button setPArams: " + fPageNumber); //AN
        console.log("search button setPArams: " + fSupply); //AN
        console.log("search button setPArams: " + fMaxRecordsPerPage); //AN
        console.log("search button setPArams: " + fIsQuote); //AN
        console.log("search button setPArams: " + fIsSample); //AN
        console.log("search button setPArams: " + fIsProgramOpty); //AN
        
        action.setParams({ recordId : recordId,
                          productType : prodType,
                          filterStr : searchStr,
                          zeroIndexPageNumber : fPageNumber,
                          restrictToSupplyChain : fSupply,
                          maxRecordsPerPage : fMaxRecordsPerPage,
                          isQuote : fIsQuote,
                          isSample : fIsSample,
                          isProgramOpty : fIsProgramOpty
                         });
        
        //set search params
        //action.setParams({ recordId : recordId,
        //                  productType : prodType,
        //                  filterStr : searchStr,
        //                  zeroIndexPageNumber : fPageNumber,
         //                 restrictToSupplyChain : fSupply,
         //                 maxRecordsPerPage : fMaxRecordsPerPage
         //                });

        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            cmp.set("v.waitSpinnerStyle", "slds-hide");
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                var resultSet = response.getReturnValue();
                
                    cmp.set("v.resultSet", resultSet);

                    
                	var recordId = cmp.get("v.recordId");
                    var fieldsToShow;
                	var isPartsSearch = (prodType == cmp.get("v.ctrl.partsProductType"));
                    /*if (prodType == cmp.get("v.ctrl.partsProductType")){
                        fieldsToShow = cmp.get("v.fieldsToShowParts");
                        isPartsSearch = true;
                    }else{
                        fieldsToShow = cmp.get("v.fieldsToShowRaw");
                    }*/
                    this.setFieldsToShow(cmp, isPartsSearch);
        
                    var fieldsToShow = cmp.get("v.fieldsToShow");
                    
                    var isSampleOpportunity = cmp.get("v.ctrl.isSampleOpportunity");
                    var isSampleQuote = cmp.get("v.ctrl.isSampleQuote");
                	/*var evt = $A.get("e.c:ShowSearchResults");
                	  evt.setParams({ "resultSet": resultSet, 
                               "fieldsToShow" : fieldsToShow, 
                                "recordId" : recordId,
                                "showZeroRecordMessage": true,
                                "isSampleQuote":isSampleQuote,
                               "isSampleOpportunity" : isSampleOpportunity});
                    evt.fire();*/
                
                	this.updateSearchComponent(cmp, resultSet, fieldsToShow, recordId, isSampleOpportunity, isSampleQuote, true, isPartsSearch);
                	//cmp.find("searchResults").updateSearchResults(resultSet, fieldsToShow, recordId, isSampleOpportunity, isSampleQuote, true, isPartsSearch);
                
			}
            else if (cmp.isValid() && state === "INCOMPLETE") {
				alert('Unable to get results');
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
        
        cmp.set("v.waitSpinnerStyle", "slds-show");
       // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
    },
    
    //helper function to add a single tab
    addTabFor: function(component, tabFor, showSupplyChain){
        
        var tabs = component.get("v.tabs");
        var tabIdS = tabFor;// + "Tab";
        var tabLabel = tabFor;
        if (tabFor == "Raw"){
            tabLabel = "Raw Glass";
        }

        var formIdS = tabFor + "Form";
        var inputTextIdS = tabFor + "-name";
        var submitButtonIdS = tabFor + "-submit";
        var supplyChainIdS = tabFor + "-supply";
        var SCVisibilityClassS = "";
        if (showSupplyChain){
             SCVisibilityClassS = "slds-show";//hide supplychain checkbox for parts
        }else{
            SCVisibilityClassS = "slds-hide";
        }
        var newTab = {name: tabLabel, tabId: tabIdS, formId: formIdS, inputTextId: inputTextIdS,
                      submitButtonId: submitButtonIdS, supplyChainId: supplyChainIdS, 
                      SCVisibilityClass: SCVisibilityClassS, filterStr: ""};
        tabs.push(newTab);
        component.set("v.tabs", tabs);
    },
    
    //set the tabs to be displayed for sample opportunity
    setTabs: function(component, rV){
        var tabs = new Array();
        component.set("v.tabs", tabs);     
        if (rV.isSampleOpportunity){
        	//show or hide tabs when selecting products for sample opportunity
            var lowerRecordType = rV.recordTypeName.toLowerCase();
            
            console.log("lowerRecordType =" + lowerRecordType);
          	
        	//for raw/concore sample, hide parts tab
            //alert("lowerRecordType:" + lowerRecordType);
        	if (lowerRecordType.includes("raw")){

                this.addTabFor(component,"Raw", true);
                this.addTabFor(component,"Concore",  true);
            }else{
                this.addTabFor(component,"Parts",  false);
            }
        }else 
        if (rV.isQuote && rV.isSampleQuote == false){
            //show or hide tabs when selecting products for sample opportunity
            var lowerRecordType = rV.recordTypeName.toLowerCase();
            
            console.log("lowerRecordType =" + lowerRecordType);
        	if (lowerRecordType.includes("raw")){
                this.addTabFor(component,"Raw",  true);
            }else
                if (lowerRecordType.includes("concore")){
                    this.addTabFor(component,"Concore",  true);
                }else{
                    this.addTabFor(component,"Parts",  false);
                }
        }
        else{
            this.addTabFor(component,"Parts",  false);
           	this.addTabFor(component,"Raw",  true);
           	this.addTabFor(component,"Concore",  true);
        }
        
    },
    
    setFieldsToShow: function(cmp, isPartsSearch){
    	//var prodType = cmp.get("v.prodType");
        var fieldsToShow;
        var recordInfo = cmp.get("v.ctrl");
        var isProgramOpty =  !recordInfo.isQuote && !recordInfo.isSampleOpportunity;
        
        //fields to show in search results table
        if (isPartsSearch){

            //(1) Quantity (2) Date (3) Product name (4) special requirements (5) tiers/pricing (6) specification id
            //fieldsToShow = isProgramOpty ? ["","Quantity", "Schedule Date  .", "product", "special Requirements","Pricing", "spec"] : ["","product","special Requirements","Pricing","spec"];
            // AN 8/28/18 - fieldsToShow = isProgramOpty ? ["","Months", "Start Date     .", "product", "special Requirements","Pricing", "spec"] : ["","product","special Requirements","Pricing","spec"];
            fieldsToShow = isProgramOpty ? ["", "product","TPM","special Requirements","Pricing", "spec"] : ["","product","TPM","special Requirements","Pricing","spec"];
           
            //fieldsToShow = isProgramOpty ? ["","Quantity", "Schedule", "productName","spec"] : ["","productName","spec"];
            
            //fieldsToShow = cmp.get("v.fieldsToShowParts");//show parts columns
        }else{
            if (recordInfo.isQuote){
                //fieldsToShow = ["","product", "Price/Unit", "moq", "moq unit", "mto"];
                fieldsToShow = ["","product", "Account", "Price/Unit",  /*"moq", "moq unit",*/ "mto"];
            }else{
        		/*if (isProgramOpty){
        			fieldsToShow = ["","Quantity", "Schedule Date  .","product", "Price/Unit", "mto"];
                }else{
                    fieldsToShow = ["","product", "Price/Unit", "mto"];
                }*/
                if (isProgramOpty){
        			//fieldsToShow = ["","Quantity", "Schedule Date  .","product", "Account", "Price/Unit", "mto"];
                	// AN 8/28/18 - fieldsToShow = ["","Months", "Start Date     .","product", "Account", "Price/Unit", "mto"];
                    fieldsToShow = ["","product", "Account", "Price/Unit", "mto"];
                }else{
                    fieldsToShow = ["","product", "Account", "Price/Unit", "mto"];
                }
                //fieldsToShow = isProgramOpty ? ["","Quantity", "Schedule Date  .","product","Account", "mto"]:["","product","Account", "mto"];
            }
        	
            //fieldsToShow = cmp.get("v.fieldsToShowRaw");//show raw columns
        }
        
        cmp.set("v.fieldsToShow", fieldsToShow);
        
    },
    
    emptySearchResults: function(cmp){
    	var prodType = cmp.get("v.prodType");
        var isPartsSearch = (prodType == cmp.get("v.ctrl.partsProductType"));
        this.setFieldsToShow(cmp, isPartsSearch);
        
        var fieldsToShow=cmp.get("v.fieldsToShow");
        
        var isSampleOpportunity = cmp.get("v.ctrl.isSampleOpportunity");
        var rS = {searchResults : [], totalRecordCount : 0, requestedPageNumber : 0};
        //empty old search results
        /*var evt = $A.get("e.c:ShowSearchResults");
        
        evt.setParams({ "resultSet": rS, 
                        "fieldsToShow" : fieldsToShow, 
                       "showZeroRecordMessage" : false,
                        "isSampleOpportunity" : isSampleOpportunity});
        evt.fire(); */
        this.updateSearchComponent(cmp, rS, fieldsToShow, cmp.get("v.recordId"), isSampleOpportunity, false, false, false);
        
	},
    
    sampleHasOneLineItem: function(component, hasOneLI){
        if (hasOneLI){
    		var sampleMsg = $A.get("$Label.c.GGSampleRequestProductMsg");//"This sample request already has a sample product added. Only one product can be added to a sample request.";
        	component.set("v.sampleRequestMessage", sampleMsg);
        	$A.util.removeClass(component.find("searchTabs"), "slds-show");
            $A.util.addClass(component.find("searchTabs"), "slds-hide");
        
        }else{
            component.set("v.sampleRequestMessage", "");
        	$A.util.removeClass(component.find("searchTabs"), "slds-hide");
            $A.util.addClass(component.find("searchTabs"), "slds-show");
        }
        
        this.emptySearchResults(component);
    },
    
    //on initialization, call the controller action to get current record's information
    initialize: function(component){
        var action = component.get('c.getRecordInfo');
        var recordId = component.get("v.recordId");
        
        action.setParams({ recordId : recordId});
        action.setCallback(this,function(response){
   			var state = response.getState();
       		if (state === "SUCCESS") {
                var rV = response.getReturnValue();
                console.log("rV =" + rV);
     			component.set('v.ctrl', rV);
                component.set('v.isQuote', rV.isQuote); // AN
                component.set('v.isSample', rV.isSampleOpportunity); // AN
                component.set("v.isProgramOpty", !rV.isQuote && !rV.isSampleOpportunity);

                console.log("initialize isQuote:" + component.get("v.isQuote")); // AN
                console.log("initialize isSample:" + component.get("v.isSample")); // AN
                console.log("initialize isProgramOpty:" + component.get("v.isProgramOpty")); // AN
                
                //if additional products can't be added because samples can only have one line item
                if (rV.canAddProducts){
                	component.set("v.canAddLineItems", true);
                    /*var sampleMsg = $A.get("$Label.c.GGSampleRequestProductMsg");//"This sample request already has a sample product added. Only one product can be added to a sample request.";
                    component.set("v.sampleRequestMessage", sampleMsg);
                    $A.util.toggleClass(component.find("searchTabs"), "slds-hide");*/
                    this.sampleHasOneLineItem(component, false);
                }else{
                	component.set("v.canAddLineItems", false);
                    this.sampleHasOneLineItem(component, true);
                }
                this.setTabs(component, rV);
                
       		}
   		});
        
      	$A.enqueueAction(action);
    },
    
    //when selected tab is changed, adjust the fields
   /* handleTabChange: function(cmp){
        
        
        //empty old search results
        
        
        cmp.set("v.filterStr", "");
        this.emptySearchResults(cmp);
        
        
        
        
        
    },*/
    
    //when selected tab is changed, show MTO Raw/Concore or Spec to product parts by default
    handleTabActive: function(cmp){
        
        //don't show default products if sample already has product added
        if (!cmp.get("v.canAddLineItems")){
        	return;
        }
        
        //get spec to product parts or mto raw/concore
        cmp.set("v.waitSpinnerStyle", "slds-show");
        
        cmp.set("v.searchType", cmp.get("v.autoLoadMTO"));
        
        var tabId = cmp.get("v.selectedTab");
        
        var prodType = cmp.get("v.prodType");
        var recordId = cmp.get("v.recordId");
        
        
        console.log("handleTabActive tabId: " + tabId); //AN
        console.log("handleTabActive isQuote: " + cmp.get("v.isQuote")); // AN
        console.log("handleTabActive isSample: " + cmp.get("v.isSample")); // AN
        console.log("handleTabActive isProgramOpty: " + cmp.get("v.isProgramOpty")); // AN      
        
       
        //for raw/concore - limit results to supply chain?
        var fSupply = false;
 
		var chkBox = document.getElementById(tabId + "-supply");
        if (chkBox){
        	fSupply = chkBox.checked;
        }
        
        
        var fPageNumber = cmp.get("v.currentPageNumber");

        var fMaxRecordsPerPage = cmp.get("v.maxRecordsPerPage"); 
        
        
        // create a one-time use instance of the search action
        // in the server-side controller
        var action = cmp.get("c.getMTOSpecProducts");
        
 		// AN - new variable to pass to apex controller
 		var fIsQuote = cmp.get("v.isQuote"); // AN
        var fIsSample = cmp.get("v.isSample"); // AN
        var fIsProgramOpty = cmp.get("v.isProgramOpty"); // AN
        
        //set search params
        // AN - add additional parameters to pass to controller to prevent inventory
        console.log("setPArams: " + recordId); //AN
        console.log("setPArams: " + prodType); //AN 
        console.log("setPArams: " + fPageNumber); //AN
        console.log("setPArams: " + fSupply); //AN
        console.log("setPArams: " + fMaxRecordsPerPage); //AN
        console.log("setPArams: " + fIsQuote); //AN
        console.log("setPArams: " + fIsSample); //AN
        console.log("setPArams: " + fIsProgramOpty); //AN
        
        action.setParams({ recordId : recordId,
                          productType : prodType,
                          zeroIndexPageNumber : fPageNumber,
                          restrictToSupplyChain : fSupply,
                          maxRecordsPerPage : fMaxRecordsPerPage,
                          isQuote : fIsQuote,
                          isSample : fIsSample,
                          isProgramOpty : fIsProgramOpty
                         });

        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            //hide the spinner
            cmp.set("v.waitSpinnerStyle", "slds-hide");
            
            if (cmp.isValid() && state === "SUCCESS") {
                var resultSet = response.getReturnValue();
                
                    cmp.set("v.resultSet", resultSet);


                    var isPartsSearch = (prodType == cmp.get("v.ctrl.partsProductType"));
                	var recordId = cmp.get("v.recordId");
                	
                	this.setFieldsToShow(cmp, isPartsSearch);
        
                    var fieldsToShow = cmp.get("v.fieldsToShow");
                	
                    /*if (prodType == cmp.get("v.ctrl.partsProductType")){
                        fieldsToShow = cmp.get("v.fieldsToShowParts");
                        isPartsSearch = true;
                    }else{
                        fieldsToShow = cmp.get("v.fieldsToShowRaw");
                    }*/
                    
                    var isSampleOpportunity = cmp.get("v.ctrl.isSampleOpportunity");
                    var isSampleQuote = cmp.get("v.ctrl.isSampleQuote");
                	
                
                	this.updateSearchComponent(cmp, resultSet, fieldsToShow, recordId, isSampleOpportunity, isSampleQuote, true, isPartsSearch);
                	//cmp.find("searchResults").updateSearchResults(resultSet, fieldsToShow, recordId, isSampleOpportunity, isSampleQuote, true, isPartsSearch);
                
			}
            else if (cmp.isValid() && state === "INCOMPLETE") {
				alert('Unable to get results');
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
    
    supplyChainSelected: function(cmp){
        console.log('insupplyChainSelected');
    	//get the search text
    	var tabId = cmp.get("v.selectedTab");
        var tabObjs = cmp.get("v.tabs");
        var searchStr = "";//cmp.get("v.filterStr");
        var obj;
        for (var i = 0; i < tabObjs.length; i++){
            obj = tabObjs[i];
            if (obj.name == tabId){
                searchStr = obj.filterStr;
                break;
            }
        }
        var fSupply = false;
        var chkBox = document.getElementById(tabId + "-supply");
        
        console.log("chkBox :" + chkBox + " tabId: " + tabId);
        
        if (chkBox){
        	fSupply = chkBox.checked;
        }
        
        console.log("searchStr -- :" + searchStr + " fSupply: " + fSupply);
        if (searchStr.length > 0 || fSupply){
            console.log('going to search');
            this.search(cmp);
        }else{
		 	console.log('going to handleTabActive');
            this.handleTabActive(cmp);            
        }
    
    }
    
    /*,
    
    setTabsVisibility: function(component){
	}*/
})