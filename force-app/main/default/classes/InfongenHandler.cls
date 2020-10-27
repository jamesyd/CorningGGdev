global class InfongenHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        // Add the entire news article asis
        String originalContent = email.htmlBody;
        String content = email.htmlBody;
        
        content = content.replaceall('(?i)\n', ''); // strip line breaks
        content = content.replaceall('(?i)<head>(.+?)</head>', '');  // strip head               
        content = content.replaceall('(?i)<a name=section(.+?)</a>', ''); // strip section anchors
        content = content.replaceall('(?i)<a name=article(.+?)</a>', ''); // strip article anchors
        content = content.replaceall('(?i)<a target="_self" href="#top"(.+?)</a>', ''); // strip back to top
        content = content.replaceall('(?i)<font class="h3"(.+?)</font><br>', ''); // strip section headers
        content = content.replaceall('(?i)<font class="description"(.+?)</font>', ''); // strip description  
        content = content.replaceall('(?i)<tr><td>&nbsp;</td></tr>', ''); // strip spacing row
        content = content.replaceall('(?i)<tr><td style="padding-bottom: 30px;"></td></tr>', ''); // strip extra padding                
        content = content.replaceall('(?i)<tr><td></td></tr>', ''); // strip leftover code
        content = content.replaceall('(?i)<div id="social_networks_bottom"(.+?)</html>', ''); // strip bottom
        content = content.replaceall('(?i)<html(.+?)<a href="http://portal.infongen.com/Newsletters/Article/Show?', ''); // strip top
        content = '<a href="http://portal.infongen.com/Newsletters/Article/Show' + content; // add first article link back
               
        InfongenNews__c[] newRecord = new InfongenNews__c[0];
        try {
            newRecord.add(new InfongenNews__c(
            Body__c = originalContent,
            BodyText__c = content,
            Subject__c = email.subject));
            insert newRecord;
        } catch (System.DmlException e) {
            System.debug('ERROR: Not able to create record: ' + e);
        }
        
        try {
            // Add the individual articles
            List<InfoNgenArticle__c> iaList = new List<InfoNgenArticle__c>();
            List<String> articles = content.split('<a href="http://portal.infongen.com/Newsletters/Article/Show?');
            for (String a : articles) {
                if (a.length() > 0) {
                    String title = a.substringBetween('<b>','</b>');
                    if (String.isEmpty(title)) { // some title are not bold
                        title = a.substringBetween('<font class="h5" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size:15px;color:#116BA0;font-weight:normal;font-style:normal;text-decoration:none;">','</font></a>');
                    }        
                    InfoNgenArticle__c ia = new InfoNgenArticle__c();
                    ia.Body__c = '<tr><td><a href="http://portal.infongen.com/Newsletters/Article/Show' + a + '</tr></td>';
                    ia.InfongenNews__c = newRecord[0].id;
                    ia.Subject__c = title.unescapeHtml4();
                    ia.BodyText__c = '<tr><td><a href="http://portal.infongen.com/Newsletters/Article/Show' + a + '</tr></td>';
                    iaList.add(ia);
                }
            }
            
            // Inserting new contacts
            insert iaList;
            } catch (System.Exception e) {
                System.debug('ERROR: ' + e);
            }
        
        result.success = true;
        return result;
    }
}