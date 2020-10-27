global class ImportCostSpecificationDataWrapper {
    public integer row {get;set;}
    public Specification__c sid {get; set;}
    public string errorMessage {get; set;}
    
    global ImportCostSpecificationDataWrapper(integer row, Specification__c sid, string errorMessage) {
        this.row = row;
        this.sid = sid;
        this.errorMessage = errorMessage;
    }
}