/**
 * @File Name          : TestUtilities.cls
 * @Description        : 
 * @Author             : Adam Nicholson?
 * @Group              : 
 * @Last Modified By   : Arquimidez Mora
 * @Last Modified On   : 2/7/2020 14:02:45
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/7/2020   Arquimidez Mora            Fixing test class
**/
public class TestUtilities {

    public void SetAutoNotificationSettingsForTesting(){
        // ConnectApi methods are not supported in data siloed tests. Please use @IsTest(SeeAllData=true). Class.ConnectApi.ChatterFeeds.postFeedElement
        insert new GGPartsSpecAutoNotifications__c(name='N~MIA', message__c = 'test', userIdList__c='{000000000000000000}');
    }
    
    public void SetTriggersOnForTesting(){
        // ConnectApi methods are not supported in data siloed tests. Please use @IsTest(SeeAllData=true). Class.ConnectApi.ChatterFeeds.postFeedElement
        insert new TriggerSettings__c(account__c = true, opportunity__c=true, opportunitylineitem__c = true, 
                                       quote__c=true, quotelineitem__c = true, specification__c = true, sampleFulfillment__c = true);
    }
    
    public void SetTriggersOnForTesting(boolean acct, boolean opp, boolean oli, boolean quote, boolean qli, boolean spec){
        // ConnectApi methods are not supported in data siloed tests. Please use @IsTest(SeeAllData=true). Class.ConnectApi.ChatterFeeds.postFeedElement
        insert new TriggerSettings__c(account__c = acct, opportunity__c=opp, opportunitylineitem__c = oli, 
                                        quote__c=quote, quotelineitem__c = qli, specification__c = spec);
    }

    public string getRecordTypeId(String objectType, String recTypeName) {
        for (RecordType rt: [SELECT Id, Name FROM RecordType WHERE Name = :recTypeName AND sObjectType = :objectType]){
            return rt.Id;
        }
        return null;
    }
    
    public Id getProfileId(string profileName) {
        Id profileId = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1].Id;
        return (profileId != null) ? profileId : null;
    }
    
    public Id getRoleId(string roleName) {
        Id roleId = [SELECT Id FROM UserRole WHERE Name = :roleName LIMIT 1].Id;
        return (roleId != null) ? roleId : null;
    }
    
    public Account addTestAccount(String recTypeId)
    {
        Account acct = new Account();
        acct = createTestAccount(recTypeId);
        insert acct;
        
        return acct;
    }
    
    public Account addTestAccount(String recTypeId, String type)
    {
        Account acct = new Account();
        acct = createTestAccount(recTypeId);
        acct.accountType__c = type;
        insert acct;
        
        return acct;
    }
    
    public Account createTestAccount(String recTypeId)
    { 
        Account a = new Account();
        a.Name = 'Test Account';
        a.RecordTypeId = recTypeId; 
        
        return a;
    }
    
    public Contact addTestContact(Id acctId, String recTypeId )
    {
        Contact c = new Contact();
        c = createTestContact(acctId, recTypeId);
        insert c;
        
        return c;
    }
    
    public Contact createTestContact(Id acctId, String recTypeId)
    { 
        Contact con = new Contact();
        con.AccountId = acctId;
        con.LastName = 'LastName';
        con.Title = 'Manager';
        con.MailingCountry = 'United States';
        con.MailingCountryCode = 'US';
        con.MailingStateCode = 'IL';
        con.MailingState = 'Illinois';
        con.RecordTypeId = recTypeId;
        return con;
    }
    
    public Quote addTestQuote(Id quoteRequestingAccountId, Id OpportunityId, String recTypeId)
    { 
        Quote q = new Quote();
        q = createTestQuote(quoteRequestingAccountId, OpportunityId, recTypeId);
        insert q;
        
        return q;
    }

    public Quote addTestQuote(Id quoteRequestingAccountId, Id OpportunityId, Id specId, String recTypeId)
    { 
        Quote q = new Quote();
        q = createTestQuote(quoteRequestingAccountId, OpportunityId, specId, recTypeId);
        insert q;
        
        return q;
    }
    
    public Quote createTestQuote(Id quoteRequestingAccountId, Id OpportunityId, String recTypeId)
    { 
        Quote q = new Quote();
        q.recordTypeId = recTypeId;
        q.Name = 'Test quote';
        q.OpportunityId = OpportunityId;
        q.effectiveDate__c = system.today();
        q.expirationDate = system.today().addDays(30);
        q.requestingAccount__c = quoteRequestingAccountId;
        q.corningSellingEntity__c = 'CCMS';
        q.Language__c = 'Chinese and English';
        q.Currency__c = 'Dollar';
        q.Pricebook2Id = '01so0000004gBaQAAU';
        q.sampleRequest__c =OpportunityId;
        return q;
    }

    public Quote createTestQuote(Id quoteRequestingAccountId, Id OpportunityId, Id specId, String recTypeId)
    { 
        Quote q = new Quote();
        q.recordTypeId = recTypeId;
        q.Name = 'Test quote';
        q.OpportunityId = OpportunityId;
        q.effectiveDate__c = system.today();
        q.expirationDate = system.today().addDays(30);
        q.requestingAccount__c = quoteRequestingAccountId;
        q.corningSellingEntity__c = 'CCMS';
        q.Language__c = 'Chinese and English';
        q.Currency__c = 'Dollar';
        q.Pricebook2Id = '01so0000004gBaQAAU';
        q.sampleRequest__c =specId;
        return q;
    }
    public Quote createTestQuote2(Id quoteRequestingAccountId, Id OpportunityId, String recTypeId)
    { 
        Quote q = new Quote();
        q.recordTypeId = recTypeId;
        q.Name = 'Test quote';
        q.OpportunityId = OpportunityId;
        q.effectiveDate__c = system.today();
        q.expirationDate = system.today().addDays(30);
        q.requestingAccount__c = quoteRequestingAccountId;
        q.corningSellingEntity__c = 'CCMS';
        q.Language__c = 'Chinese and English';
        q.Currency__c = 'Dollar';
        q.Pricebook2Id = Test.getStandardPricebookId();
        q.sampleRequest__c =OpportunityId;
        return q;
    }
    public Opportunity addTestOppt(Id acctId, String recTypeId)
    { 
        Opportunity opp = new Opportunity();
        opp = createTestOppt(acctId, recTypeId);
        insert opp;
        
        return opp;
    }
      public Opportunity addTestOppt(Id acctId, String recTypeId,Boolean doInsert)
    { 
        Opportunity opp = new Opportunity();
        opp = createTestOppt(acctId, recTypeId);
        if(doInsert)
        {
            insert opp;
        }
        
        
        return opp;
    }
    
    public Opportunity createTestOppt(Id acctId, String recTypeId)
    { 
        //create opportunity
        Opportunity opp = new Opportunity();
        opp.AccountId = acctId;
        opp.Name = 'Test Opportunity';
        opp.recordTypeId = recTypeId;
        opp.Type = 'New';     
        opp.CloseDate = System.today();
        opp.StageName = 'New';//'Quoting';
        opp.internalChargeNumber__c = '2324';
        system.debug('^^^ ' + recTypeId);
        
        if (recTypeId == '0121J000000U1cZQAS' || recTypeId == '0121J000000U1cZ') { // GG Program 0121J000000U1cZQAS
            opp.Type = 'Parts';
            opp.estimatedTotalVolume__c = 1000;
            opp.estimatedUnitPrice__c = 10;
            opp.Start_of_Production__c = date.today();
            opp.estimatedMonthsInProduction__c = '6';
            opp.region__c = 'CHN';
            opp.marketSegment__c = 'Handheld (Phone)';
            opp.marketSubSegment__c = 'Feature Phone';
            opp.application__c = 'Front Cover';
            opp.specialShapes__c = '2D';
            opp.treatment__c = 'AG';
            opp.primaryGlassComposition__c = '2320';
            opp.createForecast__c = FALSE;
        }
        
        return opp; 
    }
    
    public Opportunity addTestOppt2(Id acctId, String recTypeId,Boolean doInsert)
    { 
        //create opportunity
        Opportunity opp = new Opportunity();
        opp.AccountId = acctId;
        opp.Name = 'GG Parts Sample Request';
        opp.recordTypeId = recTypeId;
        opp.Type = 'New';     
        opp.CloseDate = System.today();
        opp.StageName = 'New';//'Quoting';
        opp.isPrebuild__c = true;
        opp.IsPhyllo__c = true;
        opp.internalChargeNumber__c = '2324';
        
        system.debug('^^^ ' + recTypeId);
        
        if (recTypeId == '0121J000000U1cZQAS' || recTypeId == '0121J000000U1cZ') { // GG Program 0121J000000U1cZQAS
            opp.Type = 'Parts';
            opp.estimatedTotalVolume__c = 1000;
            opp.estimatedUnitPrice__c = 10;
            opp.Start_of_Production__c = date.today();
            opp.estimatedMonthsInProduction__c = '6';
            opp.region__c = 'CHN';
            opp.marketSegment__c = 'Handheld (Phone)';
            opp.marketSubSegment__c = 'Feature Phone';
            opp.application__c = 'Front Cover';
            opp.specialShapes__c = '2D';
            opp.treatment__c = 'AG';
            opp.primaryGlassComposition__c = '2320';
            opp.createForecast__c = FALSE;
        }
        if(doInsert)
        {
            insert opp;
        }
         
        
        return opp;
    }
    
    public SampleFulfillment__c addSampleFulfillment(Id OppId){
        SampleFulfillment__c s = createSampleFulfillment(oppId);
        insert s;
        return s;
    }
    
    public SampleFulfillment__c createSampleFulfillment(Id oppId){
        SampleFulfillment__c s= new SampleFulfillment__c();
        s.Opportunity__c = oppId;
        return s;
    }

    public SupplyChain__c addSupplychain(Id OppId, Id tpm, Id finisher){
        SupplyChain__c s = createSupplyChain(oppId, tpm, finisher);
        insert s;
        return s;
    }
    
    public SupplyChain__c createSupplyChain(Id oppId, Id tpm, Id finisher){
        SupplyChain__c s= new Supplychain__c(Opportunity__c = oppId, tpm__c = tpm, finisher__c = finisher);
        return s;
    }
    
    public OpportunityTeamMember addTestOppTeamMember(Id oppId, Id userid, string role) {
        OpportunityTeamMember tm = new OpportunityTeamMember();
        tm = createTestOppTeamMember(oppId, userid, role);
        insert tm;
        
        return tm;
    }
    
    public OpportunityTeamMember createTestOppTeamMember(Id oppId, Id userid, string role) {
        OpportunityTeamMember tm = new OpportunityTeamMember();
        tm.opportunityId = oppId;
        tm.userId = userid;
        tm.TeamMemberRole = role;
        tm.OpportunityAccessLevel = 'Edit';
        return tm;
    }
    
    public Product2 createDefaultForecastProduct() {
        Product2 tp = new Product2();
        tp.isForecasting__c = TRUE;
        tp.Name = 'Default Part Forecast';
        tp.CanUseQuantitySchedule = True;
        tp.CanUseRevenueSchedule = True;  
        return tp;
    }

    public Product2 addDefaultForecastProduct() {
        Product2 tp = new Product2();
        tp = createDefaultForecastProduct();
        insert tp;
        
        return tp;
    }

    public Product2 createTestProduct(Id oppId, String pName) {
        Product2 tp = new Product2();
        tp.opportunity__c = oppId;
        tp.Name = pName;
        return tp;
    }
    
    public Product2 addTestProduct(Id oppId, String pName) {
        Product2 tp = new Product2();
        tp = createTestProduct (oppId, pName);
        insert tp;
        
        return tp;
    }
     public Product2 addTestProductSecond(Id oppId, String pName) {
        Product2 tp = new Product2();
        tp.opportunity__c = oppId;
        tp.Name = pName;
        tp.isPrebuild__c = true;
        tp.IsPhyllo__c = true; 
        tp.isForecasting__c = true; 
        insert tp;
        
        return tp;
    }
    
    public Product2 addTestProductSecond(Id oppId, String pName,Boolean doInsert) {
        Product2 tp = new Product2();
        tp.opportunity__c = oppId;
        tp.Name = pName;
        tp.isPrebuild__c = true;
        tp.IsPhyllo__c = true; 
        tp.isForecasting__c = true; 
        if(doInsert)
        insert tp;
        
        return tp;
    }

    public rfiConfiguration__c addTestRFI(String name)
    { 
        rfiConfiguration__c r = new rfiConfiguration__c();
        r = createTestRFI(name);
        insert r;
        
        return r;
    }
    
    public rfiConfiguration__c createTestRFI(String name)
    { 
        rfiConfiguration__c r = new rfiConfiguration__c();
        r.Name = name;
        r.antiSplinterFilm__c = 'No';
        r.application__c = 'Front Cover';
        r.applicationOfGlass__c = 'Cover Glass';
        r.cncNeeded__c = 'No';
        r.currency__c = 'USD';
        r.etc__c = 'No';
        r.glassComposition__c = '2320';
        r.ioxNeeded__c = 'No';
        r.isThisANonRectangularPart__c = 'No';
        r.numberOfHoles__c = 1;
        r.numberOfSlots__c = 1;
        r.screenPrint__c = 'No';
        r.specialShapes__c = '2D';

        return r;
    }

    
    public Specification__c addTestSpec(Id acctId, Id oppId, String recTypeId){ 
        Specification__c spec = new Specification__c();
        System.debug('***- Opp Id: '+oppId);
        spec = createTestSpec(acctId, oppId, recTypeId);
        insert spec;
        
        return spec;
    }
    
    public Specification__c addTestSpec(Id acctId, Id oppId, String recTypeId, Boolean doInsert){ 
        Specification__c spec = new Specification__c();
        spec = createTestSpec(acctId, oppId, recTypeId);
        if(doInsert)
        insert spec;
        
        return spec;
    }
    
    public Specification__c createTestSpec(Id acctId, Id oppId, String recTypeId){ 
        //create Spec
        Specification__c s = new Specification__c();
        s.Account__c = acctId;
        
        if (recTypeId == '0121J000000U1cjQAC' || recTypeId == '0121J000000U1cj') { // Parts
            s.tpm__c = acctId;
        }
        
        s.Opportunity__c = oppId;
        s.recordTypeId = recTypeId;
        s.length__c = 100;
        s.numberOfHoles__c = 2; 
        s.numberOfSlots__c = 2;
        s.productionVolume__c = 1000;
        s.width__c = 45;
        s.thickness__c = .05;
        s.antiReflectionFilm__c = 'No'; 
        s.antiSplinterFilm__c = 'No'; 
        s.application__c = 'Front Cover'; 
        s.applicationOfGlass__c = 'Substrate';         
        s.aREtcPvd__c = 'No'; 
        s.cncNeeded__c = 'No'; 
        s.ioxNeeded__c = 'No';
        s.etc__c = 'No'; 
        s.Urgency_of_Case__c = 'Low';
        s.glassComposition__c = '2320'; 
        s.isThisANonRectangularPart__c = 'No'; 
        s.productionVolumeType__c = 'Parts/Month';
        s.screenPrint__c = 'No'; 
        s.specialShapes__c = '2D'; 
        s.CustomerDrawingNumber__c = '1234TEST';
        s.marketSegment__c = 'Tablet';
        s.marketSubSegment__c = 'Slate';
        s.New_Thickness_or_Size__c = 'Both';
        s.Why_ask_for_MOQ_exception__c = 'No';
        s.requestedSampleVolume__c = 123;
        s.yieldAssumptionUsed__c = 20;
        s.potential12MOYieldAssumption__c = 20;
        s.potential12MOVolume__c = 2000;
        s.ctLevel__c = '24';
        s.Name = 'xyz123';
        s.Finance_Review_Complete__c = false;
        return s; 
    }
    
    public PricebookEntry createTestPBEntry(id pricebookId, id productId, integer x) {
        PricebookEntry pbe = new PriceBookEntry();
        pbe.Pricebook2Id = pricebookId;
        pbe.Product2Id = productId;
        pbe.UnitPrice = x*10; 
        pbe.IsActive = true;
        
        return pbe;
    }
    
    public PricebookEntry addTestPBEntry(id pricebookId, id productId, integer x) {
        PricebookEntry pbe = new PriceBookEntry();
        pbe = createTestPBEntry(pricebookId, productId, x);
        insert pbe;
        return pbe;
    }
    
    // AN 1/29/18 - added method for Standard & GG Price Book
    public PricebookEntry addTestPBEntryGG(id sPricebookId, id pricebookId, id productId, integer x) {
        PricebookEntry standardPbe = new PricebookEntry();
        standardPbe = createTestPBEntry(sPricebookId, productId, x);
        insert standardPbe;
            
        PricebookEntry pbe = new PriceBookEntry();
        pbe = createTestPBEntry(pricebookId, productId, x);
        insert pbe;
        
        return pbe;
    }

    public OpportunityLineItem createTestOLI(Id oppId, integer quantity, id PBEntryId) {
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = oppId;
        oli.Quantity = quantity;
        oli.PricebookEntryId = PBEntryId;
        oli.TotalPrice = quantity * 10;
        oli.SampleQuantity__c = quantity;
        
        return oli;
    }
    
    public OpportunityLineItem createTestOLISecond(Id oppId, integer quantity, id PBEntryId) {
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = oppId;
        oli.Quantity = quantity;
        oli.PricebookEntryId = PBEntryId;
        oli.TotalPrice = quantity * 10;
        //oli.isSampleProduct__c = true;
        
        return oli;
    }
    
    public OpportunityLineItem addTestOLI(Id oppId, integer quantity, id PBEntryId) {
        OpportunityLineItem oli = new OpportunityLineItem();
        oli = createTestOLI(oppId, quantity, PBEntryId);
        
        insert oli;
        return oli;
    }

    public QuoteLineItem createTestQLI(Id qId, integer quantity, id PBEntryId) {
        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = qId;
        qli.Quantity = quantity;
        qli.PricebookEntryId = PBEntryId;
        qli.UnitPrice = 10;
        
        return qli;
    }
    
    public QuoteLineItem addTestQLI(Id qId, integer quantity, id PBEntryId) {
        QuoteLineItem qli = new QuoteLineItem();
        qli = createTestQLI(qId, quantity, PBEntryId);
        
        insert qli;
        return qli;
    }

    
    public void AddTestGGProductAndPriceBookEntry(Opportunity opty, Account tpm, Account finisher){
        // First, set up test price book entries.
        // Insert a test product.
        List<Product2> prods = new List<Product2>();
        List<PricebookEntry> priceentries = new List<PricebookEntry>();
        
        if (opty != null){
            prods.add(new Product2(Name = 'Test part ' + opty.Id, Family = Label.GGProductTypeParts, Opportunity__c = opty.Id, isActive=true,
                                specification__c = addTestSpec(tpm.id, opty.Id, '0121J000000U1cjQAC').Id));   
        }
        prods.add(new Product2(Name = 'Test raw glass', Family = Label.GGProductTypeRaw, Opportunity__c = opty.Id, isStandard__c = true, isActive=true));   
        prods.add(new Product2(Name = 'Test concore', Family = Label.GGProductTypeConcore, Opportunity__c = opty.Id, isStandard__c = false, isActive=true)); 
        insert prods;
        
        List<Price__c> prices = new List<Price__C>();
        Price__c pr;
        integer i = 1;
        for (Product2 p: prods){
            if (p.Family == Label.GGProductTypeParts){
                pr = new Price__c(Product__c = p.Id, Price1__c = 1*i,Price2__c = 2*i,
                                        price3__c = 3*i,price4__c=4*i, 
                                  upperlimit1__c=10*i, upperlimit2__c=20*i, 
                                  upperlimit3__c=30*i, upperlimit4__c=40*i);    
                prices.add(pr);
            }
            else if (p.Family == Label.GGProductTypeRaw){
                pr = new Price__c(Product__c = p.Id, PriceUnit__c = 5*i);
                pr.Account__c = finisher.Id;
                prices.add(pr);
                
                pr = new Price__c(Product__c = p.Id, PriceUnit__c = 6*i);
                pr.Account__c = tpm.Id;
                prices.add(pr);
            }
            else{ //Concore
                pr = new Price__c(Product__c = p.Id, PriceUnit__c = 5*i);
                pr.Account__c = tpm.Id;
                prices.add(pr);
            }
            i++;
        }
        insert prices;
        
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();
                // Create a custom price book
        //Pricebook2 customPB = new Pricebook2(Name='GG Price Book', isActive=true);
        //insert customPB;
        
        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        integer iInt = 1;
        for (Product2 p: prods){
            priceentries.add(new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = p.Id,
                UnitPrice = iInt*10, IsActive = true));
        }
        
        // 2. Insert a price book entry with a custom price.
        iInt = 10;
        for (Product2 p: prods){
            //priceentries.add(new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = p.Id, UnitPrice = iInt*10, IsActive = true)); // AN 1/31/18 wrong pricebook than opp error
            priceentries.add(new PricebookEntry(Pricebook2Id = '01so0000004gBaQAAU', Product2Id = p.Id, UnitPrice = iInt*10, IsActive = true));
        }
        insert priceentries;
    }
    
    public List<PricebookEntry> AddTestGGProductAndPriceBookEntry2(Opportunity opty, Account tpm, Account finisher){
        // First, set up test price book entries.
        // Insert a test product.
        List<Product2> prods = new List<Product2>();
        List<PricebookEntry> priceentries = new List<PricebookEntry>();
        
        if (opty != null){
            prods.add(new Product2(Name = 'Test part ' + opty.Id, Family = Label.GGProductTypeParts, Opportunity__c = opty.Id, isActive=true));   
        }
        prods.add(new Product2(Name = 'Test raw glass', Family = Label.GGProductTypeRaw, isStandard__c = true, isActive=true));   
        prods.add(new Product2(Name = 'Test concore', Family = Label.GGProductTypeConcore, Opportunity__c = opty.Id, isStandard__c = false, isActive=true)); 
        insert prods;
        
        List<Price__c> prices = new List<Price__C>();
        Price__c pr;
        integer i = 1;
        for (Product2 p: prods){
            if (p.Family == Label.GGProductTypeParts){
                pr = new Price__c(Product__c = p.Id, Price1__c = 1*i,Price2__c = 2*i,
                                        price3__c = 3*i,price4__c=4*i, upperlimit1__c=10*i, upperlimit2__c=20*i, upperlimit3__c=30*i, upperlimit4__c=40*i);    
                prices.add(pr);
            }
            else if (p.Family == Label.GGProductTypeRaw){
                pr = new Price__c(Product__c = p.Id, PriceUnit__c = 5*i);
                pr.Account__c = finisher.Id;
                prices.add(pr);
                
                pr = new Price__c(Product__c = p.Id, PriceUnit__c = 6*i);
                pr.Account__c = tpm.Id;
                prices.add(pr);
            }
            else{ //Concore
                pr = new Price__c(Product__c = p.Id, PriceUnit__c = 5*i);
                pr.Account__c = tpm.Id;
                prices.add(pr);
            }
            i++;
        }
        insert prices;
        
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();
                // Create a custom price book
        //Pricebook2 customPB = new Pricebook2(Name='GG Price Book', isActive=true);
        //insert customPB;
        
        // 1. Insert a price book entry for the standard price book.
        // Standard price book entries require the standard price book ID we got earlier.
        integer iInt = 1;
        for (Product2 p: prods){
            priceentries.add(new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = p.Id,
                UnitPrice = iInt*10, IsActive = true));
        }
        
        // 2. Insert a price book entry with a custom price.
        iInt = 10;
        for (Product2 p: prods){
             //priceentries.add(new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = p.Id, UnitPrice = iInt*10, IsActive = true)); // AN 1/31/18 wrong pricebook than opp error
             priceentries.add(new PricebookEntry(Pricebook2Id = '01so0000004gBaQAAU', Product2Id = p.Id, UnitPrice = iInt*10, IsActive = true));
        }
        insert priceentries;
        
        return priceentries;
    }
    
    public Trip_Visit_Report__c addTestTVR(Id acctId, boolean priv) {
        Trip_Visit_Report__c r = new Trip_Visit_Report__c();
        r = createTestTVR(acctId, priv);
        insert r;
        return r;
    }

    public Trip_Visit_Report__c createTestTVR(Id acctId, boolean priv) {
        Trip_Visit_Report__c tvr = new Trip_Visit_Report__c();
        tvr.Account__c = acctId;
        tvr.Location_Event__c = 'Quarterly Meeting'; 
        tvr.Date_of_Meeting__c = date.today(); 
        tvr.Key_Highlights__c ='Lots of stuff Discussed'; 
        tvr.private__c = priv;
        tvr.contractStatus__c = 'CAA; Non-CAA';
        tvr.topicsDiscussed__c = 'Market Info; Pricing';
        tvr.technolgiesDiscussed__c = 'Corning Laser Technology (CLT)';
        // an 2/9/18 add field that are being stripped of < >
        tvr.executiveSummary__c = 'Summary';
        tvr.followUpActions__c = 'Follow-up';        
        return tvr;
    }
    
    public Attendees__c addTestAttendees(id contactId, string name, Id visitReport) {
        Attendees__c a = new Attendees__c();
        a = createTestAttendees(contactId, name, visitReport);
        insert a;
        return a;
    }

    public Attendees__c createTestAttendees(id contactId, string name, Id visitReport) {
        Attendees__c a = new Attendees__c();
        a.ContactContact__c = contactId;
        a.Non_Contact_Attendee__c = name;
        a.Trip_Visit_Report__c = visitReport;
        return a;
    }
        
    public distributiongroup__c addTestDistributionGroup () {
        distributiongroup__c dg = new distributiongroup__c();
        dg = createTestDistributionGroup();
        insert dg;
        return dg;
    }
    
    public distributiongroup__c createTestDistributionGroup () {
        distributiongroup__c dg = new distributiongroup__c();
        dg.description__c = 'TEST DISTRIBUTION GROUP';
        return dg;
    }
    
    public TripReportDistribution__c addTestTripReportDistribution (Id acctId, string email, Id distGroup) {
        TripReportDistribution__c trd = new TripReportDistribution__c();
        trd = createTestTripReportDistribution (acctId, email, distGroup);
        insert trd;
        return trd;
    }
    
   public TripReportDistribution__c createTestTripReportDistribution (Id acctId, string email, Id distGroup) {
        TripReportDistribution__c trd = new TripReportDistribution__c();
        trd.Account__c = acctId;
        trd.emailAddress__c = email;
        trd.distributiongroup__c = distGroup;
        return trd;
    }
 
    public EmailAddress__c addTestEmailAddress (Id distGroup, string emailName) {
        EmailAddress__c em = new EmailAddress__c();
        em = createTestEmailAddress (distGroup, emailName);
        insert em;
        return em;
    }
    
    public EmailAddress__c createTestEmailAddress (Id distGroup, string emailName) {
        EmailAddress__c ea = new EmailAddress__c();
        ea.DistributionGroup__c = distGroup;
        ea.EmailAddress__c = emailName + '@test.com';
        return ea;
    }
    
    //Instantiates User, inserts them, and returns them.
    public list<User> addTestUsers(string profileId, integer quantity){
        list <User> uList = new list<User>();
        uList = createTestUsers(profileId, quantity, null);
        insert uList;
        return uList;
    }
    
   //Instantiates User, inserts them, and returns them.
    public list<User> addTestUsers(string profileId, integer quantity, Id roleId){
        list <User> uList = new list<User>();
        uList = createTestUsers(profileId, quantity, roleId);
        insert uList;
        return uList;
    }

    //Instantiates Users with no special parameters and returns them
    public list<User> createTestUsers(string profileId, integer quantity, id roleId){
        list <User> uList = new list<User>();
        
        for (integer i=0;i<quantity; i++) {
            string uniquekey = 'TST' + string.valueOf(math.round(math.random()*10000));
            User use = new User();
            use.Alias = uniqueKey;
            use.Email = uniqueKey + '@testorg.com';
            use.EmailEncodingKey = 'UTF-8';
            use.LastName = 'Test' + uniqueKey;
            use.LanguageLocaleKey = 'en_US';
            use.LocaleSidKey = 'en_US';
            use.ProfileId = profileId;
            use.TimeZoneSidKey = 'America/Chicago';
            use.Username = uniqueKey + '@testorg.com';
            use.EmployeeNumber = 'DO NOT USE';
            if (roleId <> null) {
                use.UserRoleId = roleId;
            }
            uList.add(use);
        }
        return uList;
    }
    
     public StandardProductInventoryMatrix__c createTestMatrixRecord() { 
        //create product matrix record
        StandardProductInventoryMatrix__c m = new StandardProductInventoryMatrix__c();
        m.glassComposition__c = '2320';
        m.thickness__c = '0.40';
        m.width__c = '1520';
        m.length__c = '1460';
        m.productLine__c = 'Raw Glass';
        m.isActive__c = TRUE;
        m.estimatedCrateSheetCount__c = 450;
        m.maximumCrateDimensions__c = '1690 x 1910 x 900';
        m.moq__c = 450;
        m.moqUnits__c = 'Each';
        
        return m; 
    }
    
}