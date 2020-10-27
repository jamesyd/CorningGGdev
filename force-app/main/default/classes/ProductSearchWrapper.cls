///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 2/21/2017 ***///
///*** Product and price search wrapper class used in the search products custom Lightning component. ***///
    public class ProductSearchWrapper{
        @AuraEnabled public Integer totalRecordCount { get; set;}
        @AuraEnabled public List<SearchResult> searchResults { get; set;}
        @AuraEnabled public Integer requestedPageNumber {get; set;}
    }