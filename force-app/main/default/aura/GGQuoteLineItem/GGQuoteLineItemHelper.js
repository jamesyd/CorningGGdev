({
	fixDecimalNegativeQuantity: function(component){
		var origQty = component.get("v.quoteLI.Quantity");
        var qty = origQty;
        if (qty != null && qty.toString().indexOf('.') >= 0){
            qty = parseInt(qty);
        }
        if (qty < 0){
            qty = qty*(-1);
        }
        if (qty != origQty){
            component.set("v.quoteLI.Quantity", qty);
        }
	},

	//remove - from price and freight 
    fixNegativePrice: function(component){
    	var origPrice = component.get("v.quoteLI.UnitPrice");
        var price = origPrice;
        //price can't be negative
        if (price < 0){
            price = price*(-1);
        }
        if (price != origPrice){
            console.log("setting price: " + price);
            component.set("v.quoteLI.UnitPrice", price);
        }
        
        var origFreight = component.get("v.quoteLI.freight__c");
        var freight = origFreight;
        //freight can't be negative
        if (freight < 0){
            freight = freight*(-1);
        }
        if (freight != origFreight){
            component.set("v.quoteLI.freight__c", freight);
        }
    },
    
    updatePriceStatusMessage: function(component){
        var statusMessage = "";
        var priceError = (component.get('v.quoteLI.priceBelowFloor__c') && (component.get("v.performFloorPriceCheck")));
        statusMessage = priceError ?"Price < Approved Price":"";
        if (component.get("v.quoteLI.priceExpired__c")){
            if (statusMessage.length > 0){
                statusMessage += "; ";
            }
            statusMessage += "Price Expired";
        }
        
        
        component.set("v.priceMessage", statusMessage);
    },
    
    /*updateQuantityStatusMessage: function(component){
        var statusMessage = "";
        var qty = component.get("v.quoteLI.Quantity");
        var moq = component.get('v.quoteLI.Product2.MOQ__c');
        var isSampleQuote = component.get('v.isSampleQuote');
        
        //MOQ check disabled. Per Adam 4/4/17 - no more MOQ check since parts quotes are by tier
        //and raw can be ordered less than MOQ with repacking fee.
        
        var qtyLessThanMOQ = false;//(qty < moq && !isSampleQuote);
        component.set('v.quoteLI.qtyLessThanMOQ__c', qtyLessThanMOQ);
        
        if (qtyLessThanMOQ){
			
            statusMessage = $A.get("$Label.c.GGQuoteQtyLessThanMOQ") + " (" + moq + ")";;
        }
        component.set("v.quantityMessage", statusMessage);
    },*/
    
    get2DecimalCurrencyVal: function(v){
        if (v != undefined && v){
        	return parseFloat(v).toFixed(2);
        }
        
        return '';
	},
    
	setTooltip: function(component, event){
		//var toggleText = component.find("tooltip");
		var isPartsLI = component.get("v.isPartsLI");
        var quoteLI = component.get("v.quoteLI");
        console.log("quoteLI :" + quoteLI + " price:" + quoteLI.price__r);
        var tipStr;
        
        if (isPartsLI){
            if (component.get("v.quoteLI.plmFloorPrice__c") != undefined){
                // AN 5/2 look up from price__c
                if (component.get("v.quoteLI.partsTierMap__c") == "1") {
              	
                    tipStr = "PLM Price: $" + this.get2DecimalCurrencyVal(component.get("v.quoteLI.price__r.price1__c"));
          		} else if (component.get("v.quoteLI.partsTierMap__c") == "2") {
       
                    tipStr = "PLM Price: $" + this.get2DecimalCurrencyVal(component.get("v.quoteLI.price__r.price2__c"));
          		} else if (component.get("v.quoteLI.partsTierMap__c") == "3") {
         
                    tipStr = "PLM Price: $" + this.get2DecimalCurrencyVal(component.get("v.quoteLI.price__r.price3__c"));
          		} else if (component.get("v.quoteLI.partsTierMap__c") == "4") {
              	
                    tipStr = "PLM Price: $" + this.get2DecimalCurrencyVal(component.get("v.quoteLI.price__r.price4__c"));
          		}
          		//tipStr = "PLM Price: $" + this.get2DecimalCurrencyVal(component.get("v.quoteLI.plmFloorPrice__c"));
            }
          /*tipStr = "PLM Price: $" + quoteLI.price__r.price1__c.toFixed(2) + " upto " + quoteLI.price__r.upperLimit1__c
                			+ "; $" + quoteLI.price__r.price2__c.toFixed(2) + " upto " + quoteLI.price__r.upperLimit2__c
                			+ "; $" + quoteLI.price__r.price3__c.toFixed(2) + " upto " + quoteLI.price__r.upperLimit3__c
                			+ "; $" + quoteLI.price__r.price4__c.toFixed(2) + " upto " + quoteLI.price__r.upperLimit4__c;
        	*/
		}else{
          // AN 4/27 added word Original
          tipStr = "Original PLM Price: $" + this.get2DecimalCurrencyVal(component.get("v.quoteLI.price__r.priceUnit__c")); 
          //component.get("v.quoteLI.price__r.priceUnit__c").toFixed(2);
        }
        component.set("v.tooltip", tipStr);
        
        //component.set("v.tooltipStyle", bDisplay ? "slds-popover slds-popover--tooltip slds-nubbin--bottom slds-show" 
        //               : "slds-popover slds-popover--tooltip slds-nubbin--bottom slds-hide");
	},
    
    calculateTotalPrice: function(component){
      console.log("in calculateTotalPrice");
      var isPartsLI = component.get("v.isPartsLI");
      var qty = component.get("v.quoteLI.Quantity");
      var cPrice = component.get("v.quoteLI.UnitPrice");
      console.log("cPrice: " + cPrice);
      var isBlueQuote = component.get("v.isBlueQuote");
      var freight = component.get("v.quoteLI.freight__c");
      if (isBlueQuote){    
          if (freight && freight != undefined){
              cPrice = cPrice + freight;
          }   
          
          this.setErrorStatus(component, false, "");
          
          component.set("v.quoteLI.TotalPrice", cPrice);
          return;
      }
        
      var isSampleQuote = component.get('v.isSampleQuote');
      if (isSampleQuote){
    	  component.set("v.quoteLI.TotalPrice", this.get2DecimalCurrencyVal(cPrice));//cPrice.toFixed(2));
    	  this.setErrorStatus(component, false, "");
          return;
      }
      
      var tp = (qty * cPrice).toFixed(2);
      component.set("v.quoteLI.TotalPrice", tp);
      console.log("set total Price: cPrice:" + cPrice + " qty: " + qty);
	  
	  
      var plmPrice = 0;
      
      if (!isPartsLI){
          // AN 4/27 get floor price from QLI like parts
          // plmPrice = component.get('v.quoteLI.price__r.priceUnit__c');
          plmPrice = component.get("v.quoteLI.plmFloorPrice__c");
      }
      else{
          // AN 5/2/18 get price from price record, not QLI. The price may have changed since and approved
          // on antoher quote. How do I get the quote out of PLM Review for this scenerio
          console.log("Price Tier Map :" + component.get("v.quoteLI.partsTierMap__c"));
          if (component.get("v.quoteLI.partsTierMap__c") == "1") {
              plmPrice = component.get('v.quoteLI.price__r.price1__c');
          } else if (component.get("v.quoteLI.partsTierMap__c") == "2") {
              plmPrice = component.get('v.quoteLI.price__r.price2__c');
          } else if (component.get("v.quoteLI.partsTierMap__c") == "3") {
              plmPrice = component.get('v.quoteLI.price__r.price3__c');
          } else if (component.get("v.quoteLI.partsTierMap__c") == "4") {
              plmPrice = component.get('v.quoteLI.price__r.price4__c');
          }
          
      }
      console.log("checking cPrice < plmPrice - cPrice: " + cPrice + " plm price: " + plmPrice);
      var plmPriceStr = this.get2DecimalCurrencyVal(plmPrice);
      if (!isBlueQuote){
	      if (cPrice < plmPrice && component.get("v.performFloorPriceCheck")){
	        console.log("cPrice: " + cPrice + " plmPrice: " + plmPrice);
	        if (component.get("v.isPartsLI")){
	        	//this.setErrorStatus(component, true, $A.get("$Label.c.GGQuoteLIPricingApproval") + " ($" + plmPrice.toFixed(2) + ")" );
	            
	            component.set("v.priceMessage", $A.get("$Label.c.GGQuoteLIPricingApproval") + " ($" + /*plmPrice.toFixed(2)*/plmPriceStr + ")");
	            component.set('v.quoteLI.priceBelowFloor__c', true);
	            component.set("v.priceFloorIconStyle", "slds-text-body--small");
                this.setErrorStatus(component, true, $A.get("$Label.c.GGQuoteLIPricingApproval") + " ($" + /*plmPrice.toFixed(2)*/plmPriceStr + ")" );
	        }else{
                //price check only for MTO raw/concore
                var isMto = component.get('v.quoteLI.Product2.isMTO__c');
                // AN 4/25 - all raw glass should be approved if dropped below floor. Not just MTO.
                //if (isMto){
	            	this.setErrorStatus(component, true, $A.get("$Label.c.GGQuoteRawConcorePLMPriceError") + " ($" + /*plmPrice.toFixed(2)*/plmPriceStr + ")" );
                //}
	        }
	      }else{
	        if (component.get("v.quoteLI.priceExpired__c")){
	        	this.setErrorStatus(component, true, "Price expired");
	        }else{ //price was update via another quote
	        	component.set('v.quoteLI.priceBelowFloor__c', false);
                // AN 5/2/18 need to figure out how to get the priceBelowFloor__C set
                console.log("Price updated in backend. Price below floor: " + component.get('v.quoteLI.priceBelowFloor__c'));
	        	if (component.get("v.quoteLI.partsTierMap__c") == "1") {
              		
                    component.set('v.quoteLI.plmFloorPrice__c', component.get('v.quoteLI.price__r.price1__c'));
          		} else if (component.get("v.quoteLI.partsTierMap__c") == "2") {
              		
                    component.set('v.quoteLI.plmFloorPrice__c', component.get('v.quoteLI.price__r.price2__c'));
          		} else if (component.get("v.quoteLI.partsTierMap__c") == "3") {
              	
                    component.set('v.quoteLI.plmFloorPrice__c', component.get('v.quoteLI.price__r.price3__c'));
          		} else if (component.get("v.quoteLI.partsTierMap__c") == "4") {
              		
                    component.set('v.quoteLI.plmFloorPrice__c', component.get('v.quoteLI.price__r.price4__c'));
          		}
                
                
                component.set("v.priceFloorIconStyle", "slds-hide");
	        	this.setErrorStatus(component, false, "");
	        }              
	      }
	      
      }
    },
    
    setPriceRawConcore: function(component, qty, p){
        if (p > 0){
            return;
        }
        //alert('price record price: ' + component.get('v.quoteLI.price__r.priceUnit__c'));
        //Product2.MOQ__c
        // AN 4/27
        // component.set('v.quoteLI.UnitPrice', component.get('v.quoteLI.price__r.priceUnit__c'));
        component.set('v.quoteLI.UnitPrice', component.get('v.quoteLI.plmFloorPrice__c'));
    },
    
    setPriceParts: function(component, qty, price){
    	component.set("v.quoteLI.UnitPrice", component.get("v.quoteLI.plmFloorPrice__c"));
        /*var highestLimit = component.get('v.quoteLI.price__r.upperLimit4__c');
        console.log("highestLimit:" + highestLimit + " qty:" + qty );
        console.log("price1:" + component.get('v.quoteLI.price__r.price1__c') 
                    + " price2:" + component.get('v.quoteLI.price__r.price2__c') 
                    + " price3:" + component.get('v.quoteLI.price__r.price3__c') + 
                    " price4:" + component.get('v.quoteLI.price__r.price4__c' ));
        console.log("limit1:" + component.get('v.quoteLI.price__r.upperLimit1__c') 
                    + " limit2:" + component.get('v.quoteLI.price__r.upperLimit2__c') 
                    + " limit3:" + component.get('v.quoteLI.price__r.upperLimit3__c') + 
                    " limit4:" + component.get('v.quoteLI.price__r.upperLimit4__c' ));
        var origPriceTier = component.get("v.partsPriceTier");
        var origPrice = price;
        var priceTier = origPriceTier;
        
		//* Removed the quantity highest level check for quantity.
		// * Per Adam Nicholson - 4/4/2017
        //if (qty > highestLimit){
        //    var lbl = $A.get("$Label.c.GGOpptyQuantityHigh") + " (Max: " + highestLimit + ")";
        //    console.log("lbl: " + lbl);
        //    this.setErrorStatus(component, true, lbl);
        //    return;
        //}else
        
        if (qty < component.get('v.quoteLI.price__r.upperLimit1__c')){
            //if (price < component.get('v.quoteLI.price__r.price1__c')){
           	price = component.get('v.quoteLI.price__r.price1__c'); 
            priceTier = component.get("v.quoteLI.price__r.upperLimit1__c");
            //}
        }else
        if (qty < component.get('v.quoteLI.price__r.upperLimit2__c')){
            //if (price < component.get('v.quoteLI.Price__r.price2__c')){
            price = component.get('v.quoteLI.price__r.price2__c');
            priceTier = component.get("v.quoteLI.price__r.upperLimit2__c");
            //}
        }else
        if (qty < component.get('v.quoteLI.price__r.upperLimit3__c')){
            //if (price < component.get('v.quoteLI.price__r.price3__c')){
            price = component.get('v.quoteLI.price__r.price3__c');
            priceTier = component.get("v.quoteLI.price__r.upperLimit3__c");
            //}
        }else
        if (qty < component.get('v.quoteLI.price__r.upperLimit4__c')){
            //if (price < component.get('v.quoteLI.price__r.price4__c')){
            price = component.get('v.quoteLI.price__r.price4__c');
            priceTier = component.get("v.quoteLI.price__r.upperLimit4__c");
            //}
        }
        this.setErrorStatus(component, false, "");
        console.log("origPrice: " + origPrice + " setting price to:" + price);
        if (priceTier != origPriceTier){
            component.set("v.partsPriceTier", priceTier);
        	component.set("v.quoteLI.UnitPrice", price);
        }*/
        
    },
    
    //set price for parts/raw
	setPrice : function(component) {
		var isSampleQuote = component.get('v.isSampleQuote');
          
        var qty = component.get('v.quoteLI.Quantity');
        var price = component.get('v.quoteLI.UnitPrice');
        var p = price;
        if (qty < 0){
            //alert("quantity < 0");
        	this.setErrorStatus(component, true, "Quantity can't be negative!");
            return;
        }
        
        
        /*
         * No more MOQ check for any product line. For parts quotes are generated
         * by tier pricing and for raw/concore, the customer can order less than 
         * MOQ as long as they pay the repacking fee.
         * Per Adam - 4/4/2017
         * var moq = component.get('v.quoteLI.Product2.MOQ__c'); 
         * if (qty < moq && !isSampleQuote){
            	component.set('v.quoteLI.qtyLessThanMOQ__c', true);
            	this.setErrorStatus(component, false, "");
           
            //return;
        }else{
            component.set('v.quoteLI.qtyLessThanMOQ__c', false);
            this.setErrorStatus(component, false, "");
        }*/
        
		var pFamily = component.get('v.quoteLI.Product2.Family');
        var isPartsLI = component.get('v.isPartsLI');
        if (isPartsLI){
    		if (isSampleQuote){
            	return;//price for parts sample determined by PLM
        	}
            //this.setPriceParts(component, qty, p);
        }else{
            if (pFamily == "Concore" && isSampleQuote){
                return;//price for concore sample determined by PLM
            }
            this.setPriceRawConcore(component, qty, p);
        }
        this.calculateTotalPrice(component);
	},
    
    //set error status icon
    setErrorStatus: function(component, showError, errorMessage){
        var errorIcon = component.find("errorIcon");

        if (showError){
            component.set("v.quoteLI.errorMessage", errorMessage);
            component.set("v.quoteLI.errorStyle", "slds-show");

        }else{          
            component.set("v.quoteLI.errorMessage", "");
            component.set("v.quoteLI.errorStyle", "slds-hide");
        }
        
        this.updatePriceStatusMessage(component);
        //this.updateQuantityStatusMessage(component);
        //this.updateStatusMessage(component);
    },
    
    doInit: function(component){
		var partsStr = $A.get("$Label.c.GGProductTypeParts");
        var pFamily = component.get('v.quoteLI.Product2.Family');
        var isBlueQuote = component.get("v.isBlueQuote");
		var isSampleQuote = component.get("v.isSampleQuote");
        
        console.log("pr family:" + pFamily);
        var isPartsLI = (pFamily==partsStr);
        component.set("v.isPartsLI", isPartsLI);
        
        if (!isPartsLI && !isSampleQuote){
           	//for program raw/concore quotes, show moq and moq unit
           	
            component.set("v.moqStyle", "");
            var moq = component.get("v.quoteLI.Product2.MOQ__c");
            if (moq == undefined){
                moq= '-';
            }
            var moqUnit = component.get("v.quoteLI.Product2.moqUnits__c");
            if (moqUnit == undefined){
                moqUnit= '-';
            }
            component.set("v.moq", moq);
            component.set("v.moqUnit", moqUnit);
        }else{
            //set the style to hide - this will ensure the label doesn't show up in Salesforce1
            component.set("v.moqStyle", "slds-hide");
            component.set("v.moq", "-");
            component.set("v.moqUnit", "-");
        }
        
        /*if (component.get('v.isSampleQuote')){
        	component.set('v.displayUnit', '-');
        }else{*/
        	component.set('v.displayUnit', component.get('v.quoteLI.price__r.Unit__c'));
        //}
        
        this.calculateTotalPrice(component);           
        
        //when displaying partLI
        console.log("setting qty style");
        var qty = component.get("v.quoteLI.Quantity");
        //for program parts quote li, show price tier
        if (!component.get("v.isSampleQuote") && isPartsLI){
            qty = component.get("v.quoteLI.partsPricingTier__c");
        }
        
        component.set("v.quantity", qty);   
        if (component.get("v.runningInSF1")){
            component.set("v.statusStyle","slds-show");
        }else{
            component.set("v.statusStyle", "slds-hide");
        }
        
        if (component.get("v.isSampleQuote")){
            component.set("v.priceLbl", "");
            component.set("v.priceInputStyle", "slds-hide");
            component.set("v.totalPriceStyle", "");
            if (isPartsLI){
            	component.set("v.totalPriceLbl", "Total Price");
            }else{
                component.set("v.totalPriceLbl", "Price");
            }
        }else{
            component.set("v.priceLbl", "Price");
            component.set("v.priceInputStyle", "slds-show");
            if (!isBlueQuote){
            	component.set("v.totalPriceStyle", "slds-hide");
            }
        }
        
        if (isBlueQuote){
            component.set("v.qtyLabelStyle", "slds-hide");
            component.set("v.qtyInputStyle", "slds-hide");
            component.set("v.qtyStyle", "slds-hide");
        }else{
        	component.set("v.qtyLbl", "Quantity");
        
        	//for raw glass/concore program quotes quantity is editable
        	if (!component.get("v.isSampleQuote") && !component.get("v.isPartsProgramQuote")){
            	component.set("v.qtyLabelStyle", "slds-hide");
            	component.set("v.qtyInputStyle", "slds-show");
        	}else{
            	component.set("v.qtyLabelStyle", "slds-show");
            	component.set("v.qtyInputStyle", "slds-hide");
        	}
    	}	
        
        
        
        if (isBlueQuote){
        	component.set("v.freightLbl", "Freight");
            component.set("v.totalPriceLbl", "Total");
        }
        
        if (!component.get("v.isSampleQuote") && isPartsLI && !isBlueQuote){
            // AN 5/2 Reflect the floor price from the price record 
			component.set("v.floorPrice", component.get("v.quoteLI.plmFloorPrice__c"));             
            component.set("v.floorPriceLbl", "Floor Price");
			console.log("Price Tier Map for Floor Price :" + component.get("v.quoteLI.partsTierMap__c"));            
            if (component.get("v.quoteLI.partsTierMap__c") == "1") {
              component.set("v.floorPrice", component.get('v.quoteLI.price__r.price1__c'));
              console.log("Floor Price 1 :" + component.get("v.quoteLI.price__r.price1__c"));
          	} else if (component.get("v.quoteLI.partsTierMap__c") == "2") {
              component.set("v.floorPrice", component.get('v.quoteLI.price__r.price2__c'));
              console.log("Floor Price 2 :" + component.get("v.quoteLI.price__r.price2__c"));
          	} else if (component.get("v.quoteLI.partsTierMap__c") == "3") {
              component.set("v.floorPrice", component.get('v.quoteLI.price__r.price3__c'));
              console.log("Floor Price 3 :" + component.get("v.quoteLI.price__r.price3__c"));  
          	} else if (component.get("v.quoteLI.partsTierMap__c") == "4") {
              component.set("v.floorPrice", component.get('v.quoteLI.price__r.price4__c'));
              console.log("Floor Price 4 :" + component.get("v.quoteLI.price__r.price4__c"));
          	}
            
        }else{
            component.set("v.floorPriceStyle", "slds-hide");
        }
		
        //this.updateQuantityStatusMessage(component);
    }
})