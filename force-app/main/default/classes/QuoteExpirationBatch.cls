///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 3/24/2017 ***///
///*** Batch Apex class to flag expired Quotes ***///
///*** System.schedule('QuoteExpirationBatch', '0 0 2 * * ?', new QuoteExpirationBatch());
global class QuoteExpirationBatch implements Schedulable, Database.Batchable<sObject> {
	
	global void execute(SchedulableContext ctx){
		database.executebatch(new QuoteExpirationBatch(), 100);	
	}
	
	global Database.QueryLocator start(Database.BatchableContext bc) {
		string query;
		
		query = 'SELECT Id, ExpirationDate, Status, priceExpired__c,' +
		 		' (SELECT priceExpired__c FROM QuoteLineItems WHERE priceExpired__c = true)' +
		 		' FROM Quote' +
				' WHERE Status <> \'Customer Accepted\' ' +
		 		' AND Status <> \'Customer Rejected\' ' +
		 		' AND Status <> \'Expired\' ' +
		 		' AND ExpirationDate <> NULL';

    	return Database.getQueryLocator(query);
  	}
  
  	global void execute(Database.BatchableContext bc, list<Quote> scope) {
      	date testDate = system.Today().addDays(-1);
      	list<Quote> updateList = new list<Quote>();
      	
      	for(Quote q : scope){
      		system.debug(q);
      		if (q.ExpirationDate == testDate){
				q.Status = 'Expired';
				updateList.add(q);
				system.debug('A');
      		}
      		else if(q.QuoteLineItems.size() > 0){
      			q.Status = 'Expired';
      			updateList.add(q);
      			system.debug('B');
      		}
      	}
      	update updateList;
  	}
  	
  	global void finish(Database.BatchableContext bc) {
  	}
}