({
	//don't allow decilmals or negative quantity
    fixDecimalNegativeQuantity: function(component){
    	//don't allow negative quantity or decimal quantity
        var origQty = component.get("v.opttyLI.Quantity");
        var qty = origQty;
        if (qty != null && qty.toString().indexOf('.') >= 0){
            qty = parseInt(qty);
        }
        if (qty < 0){
            qty = qty*(-1);
        }
        if (qty != origQty){
            component.set("v.opttyLI.Quantity", qty);
        }
    },
    
    fixNegativePrice: function(component){
    	//don't allow negative price
        var origPrice = component.get("v.opttyLI.UnitPrice");
        var price = origPrice;
        //price can't be negative
        if (price < 0){
            price = price*(-1);
        }
        if (price != origPrice){
            component.set("v.opttyLI.UnitPrice", price);
        }
    },
    
    get2DecimalCurrencyVal: function(v){
        if (v != undefined && v){
        	return parseFloat(v).toFixed(2);
        }
        
        return '';
	},
    
    setTooltip: function(component, event){
		//var toggleText = component.find("tooltip");
        var pFamily = component.get('v.opttyLI.Product2.Family');
        var opttyLI = component.get("v.opttyLI");
        //console.log("opttyLI :" + opttyLI + " price:" + opttyLI.price__r);
        var tipStr;
        if (pFamily == "Parts"){
          if (opttyLI.price__r.price1__c != undefined){
          	tipStr = "PLM Price: $" + /*opttyLI.price__r.price1__c.toFixed(2)*/this.get2DecimalCurrencyVal(opttyLI.price__r.price1__c) + " upto " + opttyLI.price__r.upperLimit1__c;
          }
          if (opttyLI.price__r.price2__c != undefined){
          	tipStr = tipStr + 
      				"; $" + /*opttyLI.price__r.price2__c.toFixed(2)*/this.get2DecimalCurrencyVal(opttyLI.price__r.price2__c) + " upto " + opttyLI.price__r.upperLimit2__c;
          }
          if (opttyLI.price__r.price3__c != undefined){
          	tipStr = tipStr 
                	+ "; $" + /*opttyLI.price__r.price3__c.toFixed(2)*/this.get2DecimalCurrencyVal(opttyLI.price__r.price3__c) + " upto " + opttyLI.price__r.upperLimit3__c;
          }
          if (opttyLI.price__r.price4__c != undefined){
          	tipStr = tipStr
          		+ "; $" + /*opttyLI.price__r.price4__c.toFixed(2)*/this.get2DecimalCurrencyVal(opttyLI.price__r.price4__c) + " upto " + opttyLI.price__r.upperLimit4__c;
          }
        } /*else {
          
          var priceU = this.get2DecimalCurrencyVal(opttyLI.price__r.priceUnit__c);
          console.log(' priceUnit: ' + priceU);
          if (priceU != undefined){
              
          	tipStr = "PLM Price: $" + priceU;//priceU.toFixed(2);
          }
        } */
        component.set("v.tooltip", tipStr);
        
        //component.set("v.tooltipStyle", bDisplay ? "slds-popover slds-popover--tooltip slds-nubbin--bottom slds-show" 
        //               : "slds-popover slds-popover--tooltip slds-nubbin--bottom slds-hide");
	},
    
    calculateTotalPrice: function(component){
      var isSampleOptty = component.get('v.isSampleOptty');
      var tp = component.get("v.opttyLI.UnitPrice");
      var pFamily = component.get('v.opttyLI.Product2.Family');
		
      console.log("pr family:" + pFamily);
      if (isSampleOptty){
          var partsStr = $A.get("$Label.c.GGProductTypeParts");
          var priceError = $A.get("$Label.c.GGQuoteRawConcorePLMPriceError");	 
          var plmPrice = component.get("v.opttyLI.price__r.priceUnit__c");
          var isMto = component.get("v.opttyLI.Product2.isMTO__c");
          if (pFamily != partsStr && tp < plmPrice && isMto){
			this.setErrorStatus(component, true, "MTO Price can't be below PLM price (" + plmPrice + ")");
          }
      }
      else{
          tp = (component.get("v.opttyLI.Quantity") * tp).toFixed(2);    
      }
      var forecast=component.get("v.opttyLI.forecastCategory__c");
      if (forecast == "Omitted" || forecast == "Lost"){
          tp = 0;
      }
        
      component.set("v.opttyLI.TotalPrice", tp);  
    },
    
    forecastChanged: function(component){
      	var selCmp = component.find("forecastSelect"); 
        component.set("v.opttyLI.forecastCategory__c", selCmp.get("v.value"));
        this.calculateTotalPrice(component);
    },
    
    //set error status icon
    setErrorStatus: function(component, showError, errorMessage){
        var errorIcon = component.find("errorIcon");

        if (showError){
            component.set("v.opttyLI.errorMessage", errorMessage);
            component.set("v.opttyLI.errorStyle", "slds-show");

        }else{          
            component.set("v.opttyLI.errorMessage", "");
            component.set("v.opttyLI.errorStyle", "slds-hide");
        }
    },
    
    setPriceRawConcore: function(component, qty, p){
        if (p > 0){
            return;
        }
        //alert('price record price: ' + component.get('v.opttyLI.price__r.priceUnit__c'));
        //Product2.MOQ__c
        component.set('v.opttyLI.UnitPrice', component.get('v.opttyLI.price__r.priceUnit__c'));
    },
    
    setPriceParts: function(component, qty, price){
        var highestLimit = component.get('v.opttyLI.price__r.upperLimit4__c');
        console.log("highestLimit:" + highestLimit + " qty:" + qty );
        console.log("price1:" + component.get('v.opttyLI.price__r.price1__c') 
                    + " price2:" + component.get('v.opttyLI.price__r.price2__c') 
                    + " price3:" + component.get('v.opttyLI.price__r.price3__c') + 
                    " price4:" + component.get('v.opttyLI.price__r.price4__c' ));
        console.log("limit1:" + component.get('v.opttyLI.price__r.upperLimit1__c') 
                    + " limit2:" + component.get('v.opttyLI.price__r.upperLimit2__c') 
                    + " limit3:" + component.get('v.opttyLI.price__r.upperLimit3__c') + 
                    " limit4:" + component.get('v.opttyLI.price__r.upperLimit4__c' ));
        var origPriceTier = component.get("v.partsPriceTier");
        var origPrice = price;
        var priceTier = origPriceTier;
		
        /*if (qty > highestLimit){
            var lbl = $A.get("$Label.c.GGOpptyQuantityHigh") + " (Max: " + highestLimit + ")";
            console.log("lbl: " + lbl);
            this.setErrorStatus(component, true, lbl);
            return;
        }else*/
        if (qty < component.get('v.opttyLI.price__r.upperLimit1__c')){
            //if (price < component.get('v.opttyLI.price__r.price1__c')){
           	price = component.get('v.opttyLI.price__r.price1__c'); 
            priceTier = component.get("v.opttyLI.price__r.upperLimit1__c");
            //}
        }else
        if (qty < component.get('v.opttyLI.price__r.upperLimit2__c')){
            //if (price < component.get('v.opttyLI.Price__r.price2__c')){
            price = component.get('v.opttyLI.price__r.price2__c');
            priceTier = component.get("v.opttyLI.price__r.upperLimit2__c");
            //}
        }else
        if (qty < component.get('v.opttyLI.price__r.upperLimit3__c')){
            //if (price < component.get('v.opttyLI.price__r.price3__c')){
            price = component.get('v.opttyLI.price__r.price3__c');
            priceTier = component.get("v.opttyLI.price__r.upperLimit3__c");
            //}
        }else{
        //if (qty < component.get('v.opttyLI.price__r.upperLimit4__c')){
            //if (price < component.get('v.opttyLI.price__r.price4__c')){
            if (component.get('v.opttyLI.price__r.price4__c') != undefined){
            	price = component.get('v.opttyLI.price__r.price4__c');
            	priceTier = component.get("v.opttyLI.price__r.upperLimit4__c");
            }else
                if (component.get('v.opttyLI.price__r.price3__c') != undefined){
            		price = component.get('v.opttyLI.price__r.price3__c');
            		priceTier = component.get("v.opttyLI.price__r.upperLimit3__c");
            	}else
                if (component.get('v.opttyLI.price__r.price2__c') != undefined){
            		price = component.get('v.opttyLI.price__r.price2__c');
            		priceTier = component.get("v.opttyLI.price__r.upperLimit2__c");
            	}else
            	if (component.get('v.opttyLI.price__r.price1__c') != undefined){
            		price = component.get('v.opttyLI.price__r.price1__c');
            		priceTier = component.get("v.opttyLI.price__r.upperLimit1__c");
            	}
            //}
        }
        this.setErrorStatus(component, false, "");
        console.log("origPrice: " + origPrice + " setting price to:" + price);
        if (priceTier != origPriceTier){
            component.set("v.partsPriceTier", priceTier);
        	component.set("v.opttyLI.UnitPrice", price);
        }
    },
    
    //set price for parts/raw
	setPrice : function(component) {
		var isSampleOptty = component.get('v.isSampleOptty');
          
        var qty = component.get('v.opttyLI.Quantity');
        var price = component.get('v.opttyLI.UnitPrice');
        var p = price;
        if (qty < 0){
            //alert("quantity < 0");
        	this.setErrorStatus(component, true, "Quantity can't be negative!");
            return;
        }
        if (isSampleOptty){
            return;
        }
        
        /*var moq = component.get('v.opttyLI.Product2.MOQ__c');
        if (qty < moq){
            var lbl = $A.get("$Label.c.GGOpttyQtyLessThanMOQ") + " (" + moq + ")";
            this.setErrorStatus(component, true, lbl);
            return;
        }else{*/
        this.setErrorStatus(component, false, "");
        //}
        
		var pFamily = component.get('v.opttyLI.Product2.Family');
		
        console.log("pr family:" + pFamily);
        
        if (pFamily == "Parts"){
    		this.setPriceParts(component, qty, p);
        }else{
            this.setPriceRawConcore(component, qty, p);
        }
        this.calculateTotalPrice(component);
	}
})