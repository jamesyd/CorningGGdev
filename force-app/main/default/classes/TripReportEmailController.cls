///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 2/24/2017 ***///
///*** Controller class used for sending Trip Report Emails

public class TripReportEmailController {
    @testVisible private static string corningAttendees {get;set;}
    @testVisible private static string nonCorningAttendees {get;set;}
    @testVisible private static list<string> sendTo {get;set;}
    
    //creates a list of attachments to be sent with the trip report
    private static string createAttachments(Id tripId, List<Messaging.EmailFileAttachment> attachments){
        
        //get all documents linked with the trip report
        Set<Id> cIds = new Set<Id>();
        for (ContentDocumentLink cl: [select id, contentdocumentid, linkedentityid, sharetype, visibility from contentdocumentlink where linkedentityid = :tripId]){
            cIds.add(cl.contentdocumentid);
        }
        
        Integer maxSizeMB = 10;
        GGCustomSettings__c CS = GGCustomSettings__c.getOrgDefaults();
        String pricingStatus = 'MaxEmailAttachmentSizeMB';
        if (CS != null && CS.MaxEmailAttachmentSizeMB__c != null){
            maxSizeMB = (Integer)CS.MaxEmailAttachmentSizeMB__c;
        }
        //convert from MB to bytes
        Long maxSize = maxSizeMB * 1024*1024;
        
        Long totalContentSize = 0;
        Messaging.EMailFileAttachment efa;
        Blob blobData;
        for (ContentVersion cv: [select id, isDeleted, fileextension, title, filetype, versionnumber, contenturl, islatest, contentsize, versiondata from contentversion where contentdocumentid in : cIds and isLatest=true]){
            totalContentSize += cv.contentsize;
            if (totalContentSize > maxSize){
                break;
            }
            efa = new Messaging.EMailFileAttachment();
            // Create the email attachment
            efa.setFileName(cv.title + '.' + cv.fileExtension);
            efa.setBody(cv.versionData);
            efa.setContentType('application/' + cv.filetype);
            efa.setInline(false);
            attachments.add(efa);
        }
        
        //can't send attachments if the total content size exceed email attachment max
        if (totalContentSize > maxSize){
            attachments.clear();
            return 'No files attached - (exceeds attachment limit of ' + maxSizeMB + 'MB)'; 
        }
        
        return '';
    }
    
    public static Boolean isValidEmail(String email) {
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: <a href="http://www.regular-expressions.info/email.html" target="_blank" rel="nofollow">http://www.regular-expressions.info/email.html</a>
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);

        if (!MyMatcher.matches()) {
            return false;
        }
        return true;
    }
    
    @AuraEnabled
    public static string sendEmail(id tripId) {                         
        sendTo = new list<string>();
        List<string> alwaysSendTo = new list<string>(); // an 2/14 - adding logic so email addresses in the distribution list are always emailed 
        set <string> idSet = new set<string>();
        
        //Query Trip_Visit_Report__c
        Trip_Visit_Report__c trip = new Trip_Visit_Report__c();
        trip = [SELECT Id, createdBy.id, Account__c, Account__r.Name, Account__r.Owner.Name, Location_Event__c, 
                        Date_of_Meeting__c, Location__c, Owner.Name, Key_Highlights__c, private__c,
                        Purpose_Objective__c, Competative_Information_Shared__c, otherDistributionGroup__c, 
                        ignoreStandardDistribution__c, otherEmailRecipients__c
                        ,businessUnit__c
                        ,contractStatus__c
                        ,venue__c
                        ,tripReportTitle__c
                        ,topicsDiscussed__c
                        ,technolgiesDiscussed__c
                        ,actualOrImplied__c
                        ,competitor__c
                        ,fit__c 
                        ,Source__c
                        ,sourceCompanyName__c
                        ,sourceDepartmentName__c 
                        ,Product__c
                        ,thickness__c
                        ,glassUSPer_Sqft__c
                        ,quoteInWhatCurrency__c
                        ,rebateOfferToOEM__c
                        ,rebateUsPerSqFt__c
                        ,corningSource__c
                        ,corningSource__r.Name
                        ,sheetSize__c
                        ,executiveSummary__c
                        ,followUpActions__c        
                        ,topicsDiscussedOther__c
                        ,comments__c 
                        ,technologiesDiscussedOther__c
                        ,oemInnovationTechnologyComments__c
                        ,specificActionToImproveInfoExchange__c 
                        ,challengesCorningShouldAddress__c
                        ,processImprovements__c
                        ,Distribution_Group_Names__c
                    FROM Trip_Visit_Report__c
                    WHERE Id = :tripId LIMIT 1];
                                         
        //Code Commented to allow private reports to be emailed on Dec 18th, 2019
        /*if (trip.Private__c == true) { 
            throw new AuraHandledException('Trip Report is Private. No email will be sent.'); 
        }*/
        
        // validate user sending email is the person that created the email
        if (trip.createdBy.Id != UserInfo.getUserId()) {
            throw new AuraHandledException('Trip Reports can only be sent by the user that created the Trip Report. No email will be sent.'); 
        }
        
                        
        //ATTENDEES
        //Query Attendees_c                
        list<Attendees__c> attendeeList = new list<Attendees__c>();
        list<string> nonContactAttendeeList = new list<string>();
        set<Id> contactAttendeeSet = new set<Id>();
        
        attendeeList = [SELECT Id, ContactContact__c, Non_Contact_Attendee__c
                        FROM Attendees__c 
                        WHERE Trip_Visit_Report__c = :tripId];
        
        for (Attendees__c a : attendeeList) {
            if (a.ContactContact__c <> NULL) {
                contactAttendeeSet.add(a.ContactContact__c);
            }
            else if (a.Non_Contact_Attendee__c <> ''){
                nonContactAttendeeList.add(a.Non_Contact_Attendee__c);
            }
        }
        
        //Query Contacts for Attendee info
        list<Contact> contactList = new list<Contact>();        
        contactList = [SELECT Id, FirstName, LastName, Title, Account.Name, AccountId
                        FROM Contact
                        WHERE Id IN :contactAttendeeSet];
        
        //STANDARD DISTRIBUTION
        if (trip.ignoreStandardDistribution__c == false) {
            //Need to query tripreportdistribution__c.emailAddress__c to get individual emails
            //Need to query tripreportdistribution__c.distributiongroup__c to get Id's
            list<TripReportDistribution__c> trdList = new list<TripReportDistribution__c>();
            trdList = [SELECT Id, Account__c, emailAddress__c, distributiongroup__c 
                        FROM TripReportDistribution__c 
                        WHERE Account__c = :trip.Account__c];
            
            // building 'idSet' (distibution group id) and adding individual email addresses to 'sendTo'            
            if (trdList.size() > 0) {
                for (TripReportDistribution__c trd : trdList){
                    if (trd.distributiongroup__c <> NULL){
                        idSet.add(trd.distributiongroup__c);
                    }
                    
                    if (!string.isBlank(trd.emailAddress__c)){
                        alwaysSendTo.add(trd.emailAddress__c);
                        sendTo.add(trd.emailAddress__c);
                    }
                }
            }
        }
        
        //OPTIONAL DISTRIBUTION
        // Add otherDistributionGroup__c to idSet
       
        List<String> selectedDistributionGroup = new List<String>();
        if(trip.Distribution_Group_Names__c != null){
            for(String distributionGroup : trip.Distribution_Group_Names__c.split(';')){
                selectedDistributionGroup.add(distributionGroup);
            }
        }
        if(selectedDistributionGroup.size() > 0){
            for(DistributionGroup__c distGroup : [SELECT Id,Name
                                                  FROM DistributionGroup__c
                                                  WHERE NAME IN :selectedDistributionGroup]){
                                                    idSet.add(distGroup.Id);            
                                              }
        }
        //Add otherDistributionGroup__c to idSet
        /*if (trip.otherDistributionGroup__c <> NULL) { 
            idSet.add(trip.otherDistributionGroup__c);
        }*/
        
        //Add additional email addresses to sendTo
        if (!string.isBlank(trip.otherEmailRecipients__c)){ 
            trip.otherEmailRecipients__c = trip.otherEmailRecipients__c.replaceAll( '\\s+', ''); // remove all spaces
            string[] emailAddrList = trip.otherEmailRecipients__c.split(',');
            for (string addr : emailAddrList) {
                //split on semi-colons
                string [] adrs = addr.split(';');
                for (string a: adrs){
                    if (isValidEmail(a)){
                        sendTo.add(a);
                    }
                }
            }
        }   
        
        // have a complete list of disribution group ids 'idSet'
        // have a complete list of email addresses 'sendTo'
        // havr a complete list of email addresses 'alwaysSendTo'
        
        if (idSet.size() > 0) {
        //GET EMAIL ADDRESSES RELATED TO DISTRIBUTION GROUP, ADD TO SEND TO
            list<EmailAddress__c> eaList = new list<EmailAddress__c>();
            eaList = [SELECT Id, emailAddress__c 
                        FROM EmailAddress__c 
                        WHERE distributiongroup__c IN :idSet];
                
            for (EmailAddress__c ea : eaList){
                if (!string.isBlank(ea.emailAddress__c)){
                    sendTo.add(ea.emailAddress__c);
                }
            }   
        }
        
        // get a list of chatter group names associated with the distribution groups
        list<distributiongroup__c> dgList = new list<distributiongroup__c>();
        list<String> cgNameList = new list<String>();
        list<CollaborationGroup> cgList = new list<CollaborationGroup>();
        
        dgList = [SELECT id, chatterGroup__c FROM distributiongroup__c WHERE id IN :idSet];
        for (distributiongroup__c dg : dgList) {
                if (!string.isBlank(dg.chatterGroup__c)) {
                    cgNameList.add(dg.chatterGroup__c);
                }
        }   
        
        cgList = [SELECT id from CollaborationGroup where name IN :cgNameList];
        
        system.debug('$$$: # of Disribution Groups-' + dgList.size());
        system.debug('$$$: # of Chatter Groups-' + cgList.size());
        system.debug('$$$: # of non-unique Email Recipients-' + sendTo.size());
        system.debug('$$$: # of non-unique Always Email Recipients-' + alwaysSendTo.size());
        
        // convert sendTo lists to a set (removing duplicates) and make all email addresses lowercase
        Set<String> sendToSet = new Set<String>();
        for (String s2 : sendTo) {
            sendToSet.add(s2.toLowerCase());            
        }
        
        // convert alwaysSendTo lists to a set (removing duplicates) and make all email addresses lowercase
        Set<String> alwaysSendToSet = new Set<String>();
        for (String as2 : alwaysSendTo) {
            alwaysSendToSet.add(as2.toLowerCase());            
        }
         
        system.debug('$$$: # of unique Email Recipients-' + sendToSet.size());
        system.debug('$$$: # of unique Always Email Recipients-' + alwaysSendToSet.size());   
        
        // convert always Sent To set back to a list
        List<String> alwaysEmailList = new List<String>(alwaysSendToSet);
              
        // remove internal users from sendTo and add to userList (5000 external recipient limit)
        List<String> emailList = new List<String>(sendToSet);
        List<String> internalSFDCemailList = new List<String>();
        list<User> uList = new list<User>();
        uList = [SELECT id, email from User where (emailTripReport__c = FALSE and isActive = TRUE) and email IN :emailList];
        for (User u : uList) {
            sendToSet.remove(u.email);
            internalSFDCemailList.add(u.email);    
        }
        
        // possible issue when all internal listed in DG & email trip report = False for all users
        system.debug('$$$: # of unique external Email Recipients-' + emailList.size());
        system.debug('$$$: # of unique internal Email Recipients-' + internalSFDCemailList.size());
        system.debug('$$$: # of unique always Email Recipients-' + alwaysEmailList.size());       
        
        // join sendTo and alwaysSentTo lists
        List<string> combinedSendTo = new List<string>();
        combinedSendTo.addAll(alwaysEmailList);
        combinedSendTo.addAll(emailList);
        
        // remove duplicates
        Set<String> combinedSendToSet = new Set<String>();
        for (String cs2 : combinedSendTo) {
            combinedSendToSet.add(cs2.toLowerCase());            
        }
              
        // check sendTo size and split to send in batches of 100
        Decimal n = combinedSendToSet.size();
        Decimal d = n/100;
        Long l = d.round(System.RoundingMode.CEILING);
        Integer numberOfListsNeeded = l.intValue();  
        
        system.debug('$$$: # of lists needed to send to externel Email Recipients-' + numberOfListsNeeded);  
        
        // convert set into final list
        List<String> finalEmailList = new List<String>(combinedSendToSet); 
        
        // email lists MAX 10 with 100 members; implementing 2 with 100 members (200 external emails) = 50 trip reports a day
        List<String> finalEmailList1 = new List<String>();
        List<String> finalEmailList2 = new List<String>();
         
        Integer count = 1;
        Integer z1 = (finalEmailList.size() < 100) ? finalEmailList.size() : 100;
        Integer z2 = (finalEmailList.size() > 100 && finalEmailList.size() < 200) ? finalEmailList.size() : 200;
     
        do {
            // build lists - why no case statement yet in API40???
            if (count == 1) { 
                for (Integer y1 = 0; y1 < z1; y1++) {
                    finalEmailList1.add(finalEmailList.get(y1));
                }       
            }
            if (count == 2) { 
                for (Integer y2 = 100; y2 < z2; y2++) {
                    finalEmailList2.add(finalEmailList.get(y2));
                }                
            }
            count++;
         } while (count < numberOfListsNeeded);

        // loop through chatter groups and post link
        for (CollaborationGroup chatterGroup : cgList) {
            FeedItem post = new FeedItem();
            post.Title = 'A new trip report has been added for ' + trip.Account__r.Name;
            post.LinkUrl = 'https://corning-innovations.lightning.force.com/one/one.app?source=aloha#/sObject/' + trip.Id + '/view';
            post.ParentId = chatterGroup.id;
            insert post;
        }
        
        String[] toCC = new String[] {UserInfo.getUserEmail()}; // AN 11/2 CC the user sending the email
            
        if (numberOfListsNeeded > 0) {
                
            // Email to External Users 1 - 100    
            List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                
            mail.setToAddresses(finalEmailList1);
            mail.setCcAddresses(toCC);
            mail.setSubject('A new trip report has been added for ' + trip.Account__r.Name);   
            mail.setHtmlBody(buildEmailBody(trip, nonContactAttendeeList, contactList));
                                                
            //added to include attachments to trip reports
            String successMsg = 'Trip report sent by email...';
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            String attachmentMsg = createAttachments(tripId, attachments);
            if (attachmentMsg == ''){
              if (attachments.size() > 0){
                  // Attach files to email instance
                  mail.setFileAttachments(attachments);
                  successMsg += ' (Includes ' + attachments.size() + ' attachments)';
              }
            }else{
               successMsg += ' ' + attachmentMsg;
            }
                 
            emailMessages.add(mail);

            if (numberOfListsNeeded == 2) {
    
                // Email to External Users 101 - 200    
                Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage();                
                mail2.setToAddresses(finalEmailList2);
                mail2.setCcAddresses(toCC);
                mail2.setSubject('A new trip report has been added for ' + trip.Account__r.Name);   
                mail2.setHtmlBody(buildEmailBody(trip, nonContactAttendeeList, contactList));
                                                    
                //added to include attachments to trip reports
                List<Messaging.EmailFileAttachment> attachments2 = new List<Messaging.EmailFileAttachment>();
                String attachmentMsg2 = createAttachments(tripId, attachments2);
                if (attachmentMsg2 == '') {
                  if (attachments2.size() > 0) {
                      // Attach files to email instance
                      mail.setFileAttachments(attachments2);
                  }
                }
                     
                emailMessages.add(mail2);
            
            }
            
 
            
            if(!emailMessages.isEmpty()){ 
                Messaging.SendEmailResult[] serList = Messaging.sendEmail(emailMessages);
                if (serList[0].isSuccess()) {
                    return successMsg;
                    //return 'SUCCESS';
                } 
                else {
                     Messaging.SendEmailError[] errors = serList[0].getErrors();
                     throw new AuraHandledException('Send Email Failed: ' + errors[0].getMessage());
                }
            }
            else {
                throw new AuraHandledException('No message to send');
            }
        }
        else {
            if (trip.ignoreStandardDistribution__c){
                throw new AuraHandledException(label.GGTripReportNoEmailAddress);
            }else{
                throw new AuraHandledException(label.GGTripReportNoDistList);            
            }
        }
    }
    
    @testVisible
    private static string buildEmailBody (Trip_Visit_Report__c theTrip, list<string> aList, list<Contact> cList) {
        corningAttendees = '';
        nonCorningAttendees = '';
        
        for (string a : aList) {
            nonCorningAttendees += (a + '~');
        }
        
        for (Contact c : cList) {
            string nameCheck = c.Account.Name;

            if (nameCheck.contains('Corning')) {
                if (c.Title <> Null) {
                    corningAttendees += (c.FirstName + ' ' + c.LastName + ' - ' + c.Title + '~');
                }
                else {
                    corningAttendees += (c.FirstName + ' ' + c.LastName + '~');
                }
            }
            else {
                if (c.Title <> Null) {
                    nonCorningAttendees += (c.FirstName + ' ' + c.LastName + ' - ' + c.Title + '~');
                }
                else {
                    nonCorningAttendees += (c.FirstName + ' ' + c.LastName + '~');
                }
            }
        }
        
        if (corningAttendees.length() > 1) {
            corningAttendees = corningAttendees.left(corningAttendees.length()-1).replaceAll('~', '<BR/>');
        } else {
            corningAttendees = 'null'; 
        }
            
        if (nonCorningAttendees.length() > 1) {
            nonCorningAttendees = nonCorningAttendees.left(nonCorningAttendees.length()-1).replaceAll('~', '<BR/>');
        } else {
            nonCorningAttendees = ' null';
        }

        String body = theTrip.Account__r.Name + ' @ ' + theTrip.Location_Event__c + '<BR/><BR/>';
        body += '<U>Company:</U><BR/>' +  theTrip.Account__r.Name + '<BR/><BR/>';        
        body += '<U>Business Unit:</U><BR/>' +  theTrip.businessUnit__c + '<BR/><BR/>';
        body += '<U>Contract Status:</U><BR/>' +  theTrip.contractStatus__c.replaceAll(';', '<BR/>') + '<BR/><BR/>'; 
        body += '<U>Venue:</U><BR/>' + theTrip.venue__c + '<BR/><BR/>';
        body += '<U>Title:</U><BR/>' + theTrip.tripReportTitle__c + '<BR/><BR/>';
        body += '<U>Meeting Date:</U><BR/>' + theTrip.Date_of_Meeting__c.format() + '<BR/><BR/>';
        body += '<U>Meeting Location:</U><BR/>' + theTrip.Location_Event__c + '<BR/><BR/>';
        body += '<U>Corning Attendees:</U><BR/>' + corningAttendees + '<BR/><BR/>'; 
 
        body += '<U>Customer Attendees and Titles:</U><BR/>' + nonCorningAttendees + '<BR/><BR/>';
        body += '<U>Account Manager:</U><BR/>' + theTrip.Account__r.Owner.Name + '<BR/><BR/>';
        body += '<U>Submitted By:</U><BR/>' + theTrip.Owner.Name + '<BR/><BR/>';
        body += '<U>Topics Discussed:</U><BR/>' + theTrip.topicsDiscussed__c.replaceAll(';', '<BR/>') + '<BR/><BR/>';

        if (theTrip.topicsDiscussedOther__c != null){
            body += '<U>Topics Discussed Other:</U><BR/>' + theTrip.topicsDiscussedOther__c.replaceAll('[><]','*') + '<BR/><BR/>';
        } 
        
        body += '<U>Technolgies Discussed:</U><BR/>' + theTrip.technolgiesDiscussed__c.replaceAll(';', '<BR/>') + '<BR/><BR/>';
        
        if (theTrip.technologiesDiscussedOther__c != null){
            body += '<U>Technolgies Discussed Other:</U><BR/>' + theTrip.technologiesDiscussedOther__c.replaceAll('[><]','*') + '<BR/><BR/>';
        }
        
        body += '<U>Executive Summary:</U><BR/>' + theTrip.executiveSummary__c.replaceAll('[><]','*') + '<BR/><BR/>';
        body += '<U>Follow-up Actions:</U><BR/>' + theTrip.followUpActions__c.replaceAll('[><]','*') + '<BR/><BR/>';        

        if (theTrip.oemInnovationTechnologyComments__c != null){
            body += '<U>OEM Innovation Technology Comments:</U><BR/>' + theTrip.oemInnovationTechnologyComments__c.replaceAll('[><]','*') + '<BR/><BR/>';
        } else {
            body += '<U>OEM Innovation Technology Comments:</U><BR/>' + theTrip.oemInnovationTechnologyComments__c + '<BR/><BR/>';             
        }

        if (theTrip.specificActionToImproveInfoExchange__c != null){
            body += '<U>Specific Action to Improve Info Exchange:</U><BR/>' + theTrip.specificActionToImproveInfoExchange__c.replaceAll('[><]','*') + '<BR/><BR/>';
        } else {
            body += '<U>Specific Action to Improve Info Exchange:</U><BR/>' + theTrip.specificActionToImproveInfoExchange__c + '<BR/><BR/>';             
        }

        if (theTrip.challengesCorningShouldAddress__c != null){
            body += '<U>Challenges Corning Should Address:</U><BR/>' + theTrip.challengesCorningShouldAddress__c.replaceAll('[><]','*') + '<BR/><BR/>';
        } else {
            body += '<U>Challenges Corning Should Address:</U><BR/>' + theTrip.challengesCorningShouldAddress__c + '<BR/><BR/>';             
        }

        if (theTrip.processImprovements__c != null){
            body += '<U>Process Improvements:</U><BR/>' + theTrip.processImprovements__c.replaceAll('[><]','*') + '<BR/><BR/>';        
        } else {
            body += '<U>Process Improvements:</U><BR/>' + theTrip.processImprovements__c + '<BR/><BR/>';             
        }

        body += '<U>Competitive Intel:</U><BR/>' + theTrip.actualOrImplied__c + '<BR/><BR/>';
        body += '<U>Competitor:</U><BR/>' + theTrip.competitor__c + '<BR/><BR/>';
        String fitString = (theTrip.fit__c) ? 'Yes' : 'No';
        body += '<U>FIT:</U><BR/>' + fitString + '<BR/><BR/>';
        body += '<U>Source:</U><BR/>' + theTrip.Source__c + '<BR/><BR/>';
        body += '<U>Source Company Name:</U><BR/>' + theTrip.sourceCompanyName__c + '<BR/><BR/>';
        body += '<U>Source Department Name:</U><BR/>' + theTrip.sourceDepartmentName__c + '<BR/><BR/>';
        body += '<U>Product:</U><BR/>' + theTrip.Product__c + '<BR/><BR/>';
        body += '<U>Thickness:</U><BR/>' + theTrip.thickness__c + '<BR/><BR/>';
        body += '<U>Glass US$ per sqft:</U><BR/>' + theTrip.glassUSPer_Sqft__c + '<BR/><BR/>';
        body += '<U>Quote in what Currency:</U><BR/>' + theTrip.quoteInWhatCurrency__c + '<BR/><BR/>';
        String rebateString = (theTrip.rebateOfferToOEM__c) ? 'Yes' : 'No';
        body += '<U>Rebate offer to OEM:</U><BR/>' + rebateString + '<BR/><BR/>';
        body += '<U>Rebate US$ per SqFt:</U><BR/>' + theTrip.rebateUsPerSqFt__c + '<BR/><BR/>';

        if (theTrip.corningSource__c != null){
            body += '<U>Corning Source:</U><BR/>' + theTrip.corningSource__r.Name + '<BR/><BR/>';
        } else {
            body += '<U>Corning Source:</U><BR/>' + '* Not Provided *' + '<BR/><BR/>';        
        }

        body += '<U>Sheet Size:</U><BR/>' + theTrip.sheetSize__c + '<BR/><BR/>';
        
        if (theTrip.comments__c != null){        
            body += '<U>Comments:</U><BR/>' + theTrip.comments__c.replaceAll('[><]','*') + '<BR/><BR/>';
        } else {
            body += '<U>Comments:</U><BR/>' + theTrip.comments__c + '<BR/><BR/>';             
        }
                
        body = body.replaceAll('\\n', '<BR/>');
        body = body.replaceAll('null', '* Not Provided *');
        
        return body;    
    }
}