trigger StandardProductInventoryLoaderTrigger on StandardProductInventoryLoader__c (after insert, after update) {
    StandardProductDataToProductUtility.createProductAndPricebookEntry(trigger.new);
}