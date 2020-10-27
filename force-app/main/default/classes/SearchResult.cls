///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 2/21/2017 ***///
///*** Product and price search wrapper class used in the add products custom Lightning component. ***///
public class SearchResult{
    static Utilities Utils = new Utilities();
     
    @AuraEnabled public string      Account         {get; set;}
    @AuraEnabled public string      TPM             {get; set;}
    @AuraEnabled public String      productName     {get; set;}
    @AuraEnabled public Id          priceId         {get; set;}
    @AuraEnabled public Id          productId       {get; set;}
    @AuraEnabled public String      spec            {get; set;}
    @AuraEnabled public String      mto             {get; set;}
    @AuraEnabled public Double      priceUnit       {get; set;}
    @AuraEnabled public Double      price1          {get; set;}
    @AuraEnabled public Double      price2          {get; set;}
    @AuraEnabled public Double      price3          {get; set;}
    @AuraEnabled public Double      price4          {get; set;}     
    @AuraEnabled public Integer     limit1          {get; set;}
    @AuraEnabled public Integer     limit2          {get; set;}
    @AuraEnabled public Integer     limit3          {get; set;}
    @AuraEnabled public Integer     limit4          {get; set;}
    @AuraEnabled public String      unitOfMeasure   {get; set;}
    @AuraEnabled public Integer     moq             {get; set;} 
    @AuraEnabled public String specialRequirements {get; set;}
    @AuraEnabled public Boolean isMTO {get; set;}
    @AuraEnabled public String tieredPricing { get; set;}
}