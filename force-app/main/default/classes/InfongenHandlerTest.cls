@isTest
private class InfongenHandlerTest {
   
    static testMethod void TestinBoundEmail() {
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
       
        // setup the data for the email
        email.subject = 'Test';
        email.fromAddress = 'someaddress@email.com';
        email.htmlBody = '<a href="http://portal.infongen.com/Newsletters/Article/Show?nid=NL_705422958&sid=SC_705423493&aid=AR_892833811&ui=XPNux0si8KDcWONpbyhChjxNWHqT7SuMAnMfcp443LI%3D&h=3EnpJJUzSKt%2Bqe1fJFJR0gAZQtI%3D" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size:13px;color:#116BA0;font-weight:normal;font-style:normal;text-decoration:none;"><font class="h5" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size:15px;color:#116BA0;font-weight:normal;font-style:normal;text-decoration:none;"><b>Maxwell Unveils Engine Start Module For Industrial Equipment</b></font></a><table cellpadding=0 cellspacing=0><tr><td style="padding-bottom: 5px;"><font class="source" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size:11px;color:#515151;font-weight:normal;font-style:italic;text-decoration:none;"><b>04/22/15 10:29 AM | Diesel Progress | Latest News</b></font></td></tr></table><font class="synopsis" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size:12px;color:#515151;font-weight:normal;font-style:normal;text-decoration:none;"><b>Maxwell Technologies, Inc., the California-based manufacturer of ultracapacitors and other energy storage technologies, has announced the availability of an ultracapacitor-based Engine Start Module (ESM) for industrial applications. The 24 V ESM is designed to enable diesel engines to start and operate reliably in the face of cold weather and infrequent starting. Maxwell offers ultracapacitor cells ranging in capacitance from one to 3400 farads and multi-cell modules ranging from 12 to 160 V. “Maxwell’s 24 V ESM enables our 6.7 L diesel-equipped machines to successfully start at arctic temperatures, even with batteries that have been intentionally drained,” said Charles Hedrick III, ...</b></font><table cellpadding=0 cellspacing=0><tr><td style="padding-top: 5px;"></td></tr></table></td></tr><tr><td>';
    
        // call the email service class
        InfongenHandler testInbound = new InfongenHandler();
        testInbound.handleInboundEmail(email, env);   
    }
}