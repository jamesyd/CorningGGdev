/**
 * @description       : 
 * @author            : Arquimidez Mora
 * @group             : 
 * @last modified on  : 07-07-2020
 * @last modified by  : Arquimidez Mora
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.1   07-07-2020   Arquimidez Mora   Adding Vietnamese Dong
**/
///*** Added for Gorilla Glass Implementation ***///
///*** Salesforce Cloud Services - 2/14/2017 ***///
///*** Class to help specification trigger ***///
public class SpecificationTriggerHelper{
    static Utilities Utils = new Utilities();
    public string message;
    
    // an 6/28/18
    public static void checkAndLoadRFI(List<Specification__c> specs) {
        
        // get the RFI configuration records
        List<rfiConfiguration__c> rfiList = [
            SELECT Id, Name, antiSplinterFilm__c, application__c, applicationOfGlass__c, arSolution__c, cncEdgeChamfer__c, cncNeeded__c,
            cncTolerance__c, currency__c, etc__c, glassComposition__c, inkAdhesionXHatch__c, inkjetNeeded__c, innovationComment__c,
            innovationType__c, ioxNeeded__c, isThisANonRectangularPart__c, ioxCs__c, ioxDol__c, numberOfClearAgHoles__c, screenPrintLayer__c,
            numberOfHoles__c, numberOfSlots__c, panelMaker__c, screenPrint__c, screenPrintColors__c, screenPrintComments__c,
            screenPrintDyne__c, screenPrintIRALS__c, screenPrintLogo__c, screenPrintOpticalDensity__c,  screenPrintOther__c,
            screenPrintThicknessOfInk__c, selectIoxDolCsValueTarget__c, specialShapes__c, TPM__c, tX850nm__c, screenPrintTolerance__c
            FROM rfiConfiguration__c];
        
        Map<string, rfiConfiguration__c> rfiMap = new Map<string, rfiConfiguration__c>();
        for (rfiConfiguration__c rc : rfiList) {
            rfiMap.put(rc.name, rc);
        }
        
        for (Specification__c s: specs) {
            system.debug('$$$ RFI: ' + s.RecordTypeId);
            if (s.RecordTypeId == '0121J000001DcdR' && s.submitForApproval__c == TRUE && s.rfiConfiguration__c != NULL) { // Parts - RFI
                system.debug('$$$ RFI Inside Loop: ' + s.id);
                s.antiSplinterFilm__c = rfiMap.get(s.rfiConfiguration__c).antiSplinterFilm__c;                
                s.application__c = rfiMap.get(s.rfiConfiguration__c).application__c;                
                s.applicationOfGlass__c = rfiMap.get(s.rfiConfiguration__c).applicationOfGlass__c;                
                //s.arSolution__c = rfiMap.get(s.rfiConfiguration__c).arSolution__c;                
                s.cncEdgeChamfer__c = rfiMap.get(s.rfiConfiguration__c).cncEdgeChamfer__c;                
                s.cncNeeded__c = rfiMap.get(s.rfiConfiguration__c).cncNeeded__c;                
                s.cncTolerance__c = rfiMap.get(s.rfiConfiguration__c).cncTolerance__c;                
                s.currency__c = rfiMap.get(s.rfiConfiguration__c).currency__c;                
                s.etc__c = rfiMap.get(s.rfiConfiguration__c).etc__c;                
                // s.glassComposition__c = rfiMap.get(s.rfiConfiguration__c).glassComposition__c;                
                s.inkAdhesionXHatch__c = rfiMap.get(s.rfiConfiguration__c).inkAdhesionXHatch__c;                
                s.inkjetNeeded__c = rfiMap.get(s.rfiConfiguration__c).inkjetNeeded__c;                
                // s.innovationComment__c = rfiMap.get(s.rfiConfiguration__c).innovationComment__c;                
                // s.innovation_Type__c = rfiMap.get(s.rfiConfiguration__c).innovationType__c;                
                s.ioxNeeded__c = rfiMap.get(s.rfiConfiguration__c).ioxNeeded__c;                
                s.isThisANonRectangularPart__c = rfiMap.get(s.rfiConfiguration__c).isThisANonRectangularPart__c;                
                s.ioxCs__c = rfiMap.get(s.rfiConfiguration__c).ioxCs__c;                
                s.ioxDol__c = rfiMap.get(s.rfiConfiguration__c).ioxDol__c;                
                //s.numberOfClearAgHoles__c = rfiMap.get(s.rfiConfiguration__c).numberOfClearAgHoles__c;                
                s.screenPrintLayer__c = rfiMap.get(s.rfiConfiguration__c).screenPrintLayer__c;                
                s.numberOfHoles__c = rfiMap.get(s.rfiConfiguration__c).numberOfHoles__c;                
                s.numberOfSlots__c = rfiMap.get(s.rfiConfiguration__c).numberOfSlots__c;                
                s.panelMaker__c = rfiMap.get(s.rfiConfiguration__c).panelMaker__c;                
                s.screenPrint__c = rfiMap.get(s.rfiConfiguration__c).screenPrint__c;                
                s.screenPrintColors__c = rfiMap.get(s.rfiConfiguration__c).screenPrintColors__c;                
                s.screenPrintComments__c = rfiMap.get(s.rfiConfiguration__c).screenPrintComments__c;                
                s.screenPrintDyne__c = rfiMap.get(s.rfiConfiguration__c).screenPrintDyne__c;                
                s.screenPrintIRALS__c = rfiMap.get(s.rfiConfiguration__c).screenPrintIRALS__c;               
                s.screenPrintLogo__c = rfiMap.get(s.rfiConfiguration__c).screenPrintLogo__c;                
                s.screenPrintOpticalDensity__c = rfiMap.get(s.rfiConfiguration__c).screenPrintOpticalDensity__c;                
                s.screenPrintOther__c = rfiMap.get(s.rfiConfiguration__c).screenPrintOther__c;               
                s.screenPrintThicknessOfInk__c = rfiMap.get(s.rfiConfiguration__c).screenPrintThicknessOfInk__c;                
                s.selectIoxDolCsValueTarget__c = rfiMap.get(s.rfiConfiguration__c).selectIoxDolCsValueTarget__c;                
                s.specialShapes__c = rfiMap.get(s.rfiConfiguration__c).specialShapes__c;                
                // s.TPM__c = rfiMap.get(s.rfiConfiguration__c).TPM__c;                
                s.tX850nm__c = rfiMap.get(s.rfiConfiguration__c).tX850nm__c;                
                s.screenPrintTolerance__c = rfiMap.get(s.rfiConfiguration__c).screenPrintTolerance__c;
                s.standard__c = 'Yes';
                s.capable__c = 'Yes';
                s.status__c = 'Missing Information Assessment';
                s.RecordTypeId = '0121J000001DcdT'; // Parts - RFI Submitted
            }
        }
    }
    
    //set specification version #
    public static void setVersionNumber(List<Specification__c> specs){
        for (Specification__c s: specs){
            if (s.version__c == null || s.version__c == 0){
                s.version__c = 1;
            }
        }
    }
    
    //Date of last status change
    public static void setFieldsFromStatusChanges(List<Specification__c> specs, Map<Id, Specification__c> beforeMap) {
        // AN 7/31/19 - may need to update fields on opportunity
        Set<Id> oppIds = new Set<Id>();
        List<Opportunity> oppList = new List<Opportunity>();
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        List<Opportunity> oppUpdateList = new List<Opportunity>();
        
        for (Specification__c spec : specs) {  
            
            /** 
Check if Finace Review Complete is checked then Status is changed to "Commercial/Ops Review"
**/  
            if(spec.Finance_Review_Complete__c
               && beforeMap.get(spec.ID).Finance_Review_Complete__c != spec.Finance_Review_Complete__c){
                   spec.status__c = 'Commercial/Ops Review';
               }
            
            if (spec.productLine__c == 'Parts') {
                if (beforeMap.get(spec.Id).Status__c == 'Pricing Assignment' && spec.Status__c == 'Pricing Approved') {
                    oppIds.add(spec.Opportunity__c);
                }                        
            }
        }               
        
        oppList = [
            SELECT Id, mpExchangeRateLockDate__c, mPExchangeLockReason__c, 
            mpQuoteCurrency__c, mpJpyExchangeRate__c, GG_VNDExchangeRate__c, 
            mpRmbExchangeRate__c 
            FROM Opportunity 
            WHERE Id IN :oppIds
        ];
        for (Opportunity o : oppList) {
            oppMap.put(o.id,o);        
        }
        // AN 7/31/19 END
        
        
        for (Specification__c spec : specs) {            
            // all specs
            if (beforeMap.get(spec.Id).Status__c <> spec.Status__c) {
                spec.statusChangeDate__c = Date.today();
                spec.reminderCompleted__c = False;   
                spec.plmPricedLocations__c = spec.location__c;                             
            }
            
            // Parts only
            if (spec.productLine__c == 'Parts') {   
                
                // dual source
                if (beforeMap.get(spec.Id).dsStatus__c <> spec.dsStatus__c) {
                    spec.dsStatusChangeDate__c = Date.today();
                    spec.dsReminderCompleted__c = False;                             
                } // end dual source       
                
                String specFunction = '';  
                String layer = '';   
                
                // only set QA Review Date once
                if (beforeMap.get(spec.Id).qualityEngineerApproval__c <> spec.qualityEngineerApproval__c && beforeMap.get(spec.Id).qualityEngineerApproval__c == Null) {
                    spec.qualityEngineerReviewDate__c = datetime.now();                       
                }
                
                // dual source
                if (beforeMap.get(spec.Id).dsQualityEngineerApproval__c <> spec.dsQualityEngineerApproval__c && beforeMap.get(spec.Id).dsQualityEngineerApproval__c == Null) {
                    spec.dsQualityEngineerReviewDate__c = datetime.now();                       
                } // dual source
                
                // an 7/3/19 - set riskOwnerApprovalChangeDate__c when QA Approval picklist changes
                // updates each time picklist changes
                if (beforeMap.get(spec.Id).qualityEngineerApproval__c <> spec.qualityEngineerApproval__c) {
                    spec.riskOwnerApprovalChangeDate__c = datetime.now();                       
                }
                
                // dual source
                if (beforeMap.get(spec.Id).dsQualityEngineerApproval__c <> spec.dsQualityEngineerApproval__c) {
                    spec.dsRiskOwnerApprovalChangeDate__c = datetime.now();                       
                } // dual source
                
                // an - 2/20/18 - update function field
                if (spec.cncNeeded__c == 'Yes') {
                    specFunction = 'CNC + ';
                }
                if (spec.ioxNeeded__c == 'Yes') {
                    specFunction = specFunction + 'IOX + ';
                }
                
                if (spec.screenPrintLayer__c == Null) {
                    layer = ''; // an 4/30/19 change 0 to blank ''
                } else {
                    layer = spec.screenPrintLayer__c;
                }
                
                if (spec.screenPrint__c == 'Yes') {
                    specFunction = specFunction + layer + 'SP' + spec.screenPrintColors__c + ' + ';
                }
                if (spec.numberOfSlots__c == 1) {
                    specFunction = specFunction + spec.numberOfSlots__c + ' Slot' + ' + ';
                }
                if (spec.numberOfSlots__c >= 2) {
                    specFunction = specFunction + spec.numberOfSlots__c + ' Slots' + ' + ';
                }
                if (spec.numberOfHoles__c == 1) {
                    specFunction = specFunction + spec.numberOfHoles__c + ' Hole' + ' + ';
                }  
                if (spec.numberOfHoles__c >= 2) {
                    specFunction = specFunction + spec.numberOfHoles__c + ' Holes' + ' + ';
                }                
                if (spec.specialRequirements__c != Null) {
                    specFunction = specFunction + spec.specialRequirements__c;
                }
                
                specFunction = specFunction.trim();               
                spec.function__c = specFunction.removeEnd('+');
            }
            
            // MTO only - set MOQ for Pricing
            if (spec.productLine__c != 'Parts') {        
                if (spec.status__c == 'Pricing Assignment') {
                    // use 6 creats unless 10 crates qty is available
                    if (spec.moqWith6Crates__c != null) {
                        spec.moq__c = spec.moqWith6Crates__c;
                    }
                    if (spec.moqWith10Crates__c != null) {
                        spec.moq__c = spec.moqWith10Crates__c;
                    }                                           
                }
            }
            
            // AN 4/16 - set new final cost approved by field
            if ((beforeMap.get(spec.Id).Status__c == 'Pricing Approved' && spec.Status__c == 'Pricing Approved') && 
                (beforeMap.get(spec.Id).plmAcknowledgement__c == FALSE && spec.plmAcknowledgement__c == TRUE)) {
                    spec.finalCMCostAssessmentApprovedBy__c = UserInfo.getUserId();
                }
            
            // dual source
            if ((beforeMap.get(spec.Id).dsStatus__c == 'Pricing Approved' && spec.dsStatus__c == 'Pricing Approved') && 
                (beforeMap.get(spec.Id).dsPlmAcknowledgement__c == FALSE && spec.dsPlmAcknowledgement__c == TRUE)) {
                    spec.dsFinalCMCostAssessmentApprovedB__c = UserInfo.getUserId();
                } // dual source
            
            
            // AN 5/21 - set new approved by field
            if (beforeMap.get(spec.Id).Status__c == 'Pricing Assignment' && spec.Status__c == 'Pricing Approved') {
                if (spec.Currency__c == 'RMB' || spec.Currency__c == 'VND') {
                    // AN 7/31/19 - if this an RMB spec and opportunity lock currency is null, lock in the exchange rates
                    // previously this was done when the MP quote was accepted
                    // MP quotes can also lock in the exchange rate on opportunity if in RMB
                    
                    if (spec.mPQuoteLockCurrency__c == Null) {
                        spec.mpRmbExchangeRate__c = GG_Currency_Display_Settings__c.getValues('Chinese Yuan').exchangeValue__c;
                        oppMap.get(spec.opportunity__c).mpExchangeRateLockDate__c = Date.Today();
                        oppMap.get(spec.opportunity__c).mpExchangeLockReason__c = 'First Approved '+ spec.Currency__c +' Specification';
                        oppMap.get(spec.opportunity__c).mpQuoteCurrency__c = (spec.Currency__c == 'RMB') ? 'Yuan' : 'Dong'; 
                        oppMap.get(spec.opportunity__c).mpJpyExchangeRate__c = GG_Currency_Display_Settings__c.getValues('Japanese Yen').exchangeValue__c;
                        oppMap.get(spec.opportunity__c).mpRmbExchangeRate__c = GG_Currency_Display_Settings__c.getValues('Chinese Yuan').exchangeValue__c;
                        oppMap.get(spec.opportunity__c).GG_VNDExchangeRate__c = GG_Currency_Display_Settings__c.getValues('Vietnamese Dong').exchangeValue__c;
                        oppUpdateList.add(oppMap.get(spec.opportunity__c));
                    } else { 
                        spec.mpRmbExchangeRate__c = spec.mpRmbLockedRate__c; // existing locked rate from opportunity
                    }
                    // AN 7/31/19 END         
                }
                spec.approvedBy__c = UserInfo.getUserId();                    
                spec.finalIncrementalGFO__c = spec.incrementalGFO__c;
                spec.finalIncrementalGlassCostRoof1__c = spec.incrementalGlassCostRoof1__c;
                spec.finalIncrementalGlassCostRoof2__c = spec.incrementalGlassCostRoof2__c;
                spec.finalIncrementalGlassCostNoYL__c = spec.incrementalGlassCostNoYL__c;
                spec.finalIncrementalProcessFeeRoofOne__c = spec.incrementalProcessFeeRoofOne__c;
                spec.finalIncrementalProcessFeeRoofTwo__c = spec.incrementalProcessFeeRoofTwo__c;
                spec.finalIncrementalRoofOne__c = spec.incrementalRoofOne__c;
                spec.finalIncrementalRoofTwo__c = spec.incrementalRoofTwo__c;
                spec.finalIncrementalTCO__c = spec.incrementalTCO__c;
                spec.finalIncrementalTransportation__c = spec.incrementalTransportation__c;
                spec.finalIncrementalYieldRoofOne__c = spec.incrementalYieldRoofOne__c;
                spec.finalIncrementalYieldRoofTwo__c = spec.incrementalYieldRoofTwo__c;
                
                // copy twice?
                // spec.final2IncrementalGFO__c = spec.incrementalGFOS2__c;
                // spec.final2IncrementalGlassCostRoof1__c = spec.incrementalGlassCostRoof1S2__c;
                // spec.final2IncrementalGlassCostRoof2__c = spec.incrementalGlassCostRoof2S2__c;
                // spec.final2IncrementalGlassCostNoYL__c = spec.incrementalGlassCostNoYLS2__c;
                // spec.final2IncrementalProcessFeeRoofOne__c = spec.incrementalProcessFeeRoofOneS2__c;
                // spec.final2IncrementalProcessFeeRoofTwo__c = spec.incrementalProcessFeeRoofTwoS2__c;
                // spec.final2IncrementalRoofOne__c = spec.incrementalRoofOneS2__c;
                // spec.final2IncrementalRoofTwo__c = spec.incrementalRoofTwoS2__c;
                // spec.final2IncrementalTCO__c = spec.incrementalTCOS2__c;
                // spec.final2IncrementalTransportation__c = spec.finalincrementalTransportationS2__c;
                // spec.final2IncrementalYieldRoofOne__c = spec.finalincrementalYieldRoofOneS2__c;
                // spec.final2IncrementalYieldRoofTwo__c = spec.finalincrementalYieldRoofTwoS2__c;
                
            }
            
            // dual source
            if (beforeMap.get(spec.Id).dsStatus__c == 'CM Cost Assessment' && spec.dsStatus__c == 'Cost Assessment Completed') {
                spec.final2IncrementalGFO__c = spec.incrementalGFOS2__c;
                spec.final2IncrementalGlassCostRoof1__c = spec.incrementalGlassCostRoof1S2__c;
                spec.final2IncrementalGlassCostRoof2__c = spec.incrementalGlassCostRoof2S2__c;
                spec.final2IncrementalGlassCostNoYL__c = spec.incrementalGlassCostNoYLS2__c;
                spec.final2IncrementalProcessFeeRoofOne__c = spec.incrementalProcessFeeRoofOneS2__c;
                spec.final2IncrementalProcessFeeRoofTwo__c = spec.incrementalProcessFeeRoofTwoS2__c;
                spec.final2IncrementalRoofOne__c = spec.incrementalRoofOneS2__c;
                spec.final2IncrementalRoofTwo__c = spec.incrementalRoofTwoS2__c;
                spec.final2IncrementalTCO__c = spec.incrementalTCOS2__c;
                spec.final2IncrementalTransportation__c = spec.finalincrementalTransportationS2__c;
                spec.final2IncrementalYieldRoofOne__c = spec.finalincrementalYieldRoofOneS2__c;
                spec.final2IncrementalYieldRoofTwo__c = spec.finalincrementalYieldRoofTwoS2__c;                
            } // dual source
        }  
        
        // AN 7/31/19
        if (oppUpdateList.size() > 0) {
            update oppUpdateList; 
        }
    }
    
    //Product and price book entry created after spec is pricing approved
    public static void createProductAndPricebookEntry(List<Specification__c> specs, Map<Id, Specification__c> beforeMap){
        list<Specification__c> specsToCreateProductsFor = new List<Specification__c>();
        
        //get status for pricing approved specs from custom setting if one exists
        GGCustomSettings__c CS = GGCustomSettings__c.getOrgDefaults();
        String pricingStatus = 'Pricing Approved';
        if (CS != null){
            pricingStatus = CS.ProductCreationStatus__c;
        }
        
        //only create products when spec status changes to Pricing Approved
        for (Specification__c spec : specs){
            if (beforeMap.get(spec.Id).Status__c <> spec.Status__c && spec.Status__c == pricingStatus){
                specsToCreateProductsFor.add(spec);
            }
        }
        
        if (specsToCreateProductsFor.size() > 0){
            SpecToProductUtility.CreateProductAndPricebookEntry(specsToCreateProductsFor);
        }
    }
    
    //If the specification is not submitted nor final (record type label does not include "submitted" or "final"), only opportunity owner
    //or opportunity team members can edit the spec.    
    public static void validateEditAccessToSpecifications(List<Specification__c> specs){    
        
        Id userId = UserInfo.getUserId();
        Id profileId = UserInfo.getProfileId();
        string profileName = Utils.getProfileName(profileId);
        system.debug('specs=:'+specs);
        //system admins can always edit any specs
        if (profileName == 'System Administrator' || profileName == 'System Administrator Plus'){
            return;
        }
        
        List<Id> optyIds = new List<Id>();
        list<Id> actIds = new List<Id>();
        
        //get record type ids of submitted specification record types
        Map<Id, Id> submittedRTs = new Map<Id, Id>();
        //for (RecordType rt: [SELECT Id, Name FROM RECORDTYPE WHERE Name like '%submitted' AND SObjectType='Specification__c']){
        for (RecordType rt: [SELECT Id, Name FROM RECORDTYPE WHERE (Name like '%submitted' OR Name like '%final') AND SObjectType='Specification__c']){
            submittedRTs.put(rt.Id, rt.Id);
            system.debug('$$$$$ ' + rt.Id); // AN 4/26
        } 
        
        List<Specification__c> specsToCheck = new List<Specification__c>();
        
        //create a list of specs that are not submitted and need to be checked for access
        for (Specification__c s: specs){
            //IF spec is Not Submitted AND user is not owner of the record 
            //we will need to check if current user is part of opty team
            if (!submittedRTs.containsKey(s.RecordTypeId) && s.ownerId__c != userId)
            {
                specsToCheck.add(s);
                system.debug('$$$$$ specsToCheck=:'+s);
                optyIds.add(s.Opportunity__c);
                actIds.add(s.opportunityAccountId__c);
                system.debug('$$$: ' + s.opportunityAccountId__c);
            }
        }
        
        //user can only edit unsubmitted specifications if the user is on opportunity team
        Map<Id, Id> optyTeamMembers = new Map<Id, Id>();
        for (OpportunityTeamMember om: [SELECT Id, OpportunityId, UserId 
                                        FROM OpportunityTeamMember 
                                        WHERE OpportunityId in :optyIds 
                                        AND UserId = :userId 
                                        AND IsDeleted = FALSE 
                                        AND OpportunityAccessLevel = 'Edit']){
                                            optyTeamMembers.put(om.OpportunityId,om.OpportunityId);
                                        }
        
        // AN - 8/6/18 - extend opportunity team check to include account team
        set <id> actTeamMembers = new set<id>();
        for (AccountTeamMember am: [SELECT Id, AccountId, OpportunityAccessLevel, UserId 
                                    FROM AccountTeamMember 
                                    WHERE AccountId in :actIds 
                                    AND UserId = :userId 
                                    AND IsDeleted = FALSE 
                                    AND OpportunityAccessLevel = 'Edit']){
                                        actTeamMembers.add(am.AccountId);
                                    }                
        
        
        string specError = Label.SpecificationEditError;
        for (Specification__c stc: specsToCheck){
            
            if ((optyTeamMembers.containsKey(stc.Opportunity__c) == false) && (actTeamMembers.contains(stc.opportunityAccountId__c) == false)){
                stc.addError(specError);
            }
        }
    }
    
    // an - 6/29/18 add Parts RFI
    @TestVisible
    private static void validatePartsRFIRequiredFieldsForSubmit(Specification__c stc, list<string> fNameList){
        List<Schema.FieldSetMember> lMandatoryfields = Schema.SObjectType.Specification__c.FieldSets.Required_for_Submit_RFI.getFields();
        for (FieldSetMember fSetMember : lMandatoryfields){
            if (stc.get(fSetMember.getFieldPath()) == null){
                fNameList.add(fSetMember.getLabel());
            }
        }
    }
    
    @TestVisible
    private static void validateRawMTORequiredFieldsForSubmit(Specification__c stc, list<string> fNameList){
        List<Schema.FieldSetMember> lMandatoryfields = Schema.SObjectType.Specification__c.FieldSets.Required_for_Submit_Raw_Glass.getFields();
        for (FieldSetMember fSetMember : lMandatoryfields){
            if (stc.get(fSetMember.getFieldPath()) == null){
                fNameList.add(fSetMember.getLabel());
            }
        }
    }
    
    @TestVisible
    private static void validateConcoreMTORequiredFieldsForSubmit(Specification__c stc, list<string> fNameList){
        List<Schema.FieldSetMember> lMandatoryfields = Schema.SObjectType.Specification__c.FieldSets.Required_for_Submit_Concore.getFields();
        for (FieldSetMember fSetMember : lMandatoryfields){
            if (stc.get(fSetMember.getFieldPath()) == null){
                fNameList.add(fSetMember.getLabel());
            }
        }
    }
    
    public static void validateReadyForSubmit(List<Specification__c> specs){    
        List<Specification__c> specsToCheck = new List<Specification__c>();
        
        Id partsSpecRT = '0121J000000U1cj'; //utils.getRecordTypeID('Specification__c', 'Parts').Id;
        Id partsRFIRT = '0121J000001DcdR';
        Id concoreSpecRT = '0121J000000U1cg'; //utils.getRecordTypeID('Specification__c', 'Concore').Id;
        Id rawSpecRT = '0121J000000U1cm';
        
        for (Specification__c s: specs){
            if (s.Status__c == 'New' && s.submitForApproval__c == true) {
                specsToCheck.add(s); 
            }
            else {
                //Not being Submitted, so nothing to do
            }
        }
        
        //all of the fields for Spec in the Config Workbook marked as 'Required for Submit' = 1 are checked
        List<Schema.FieldSetMember> lMandatoryfields = Schema.SObjectType.Specification__c.FieldSets.Required_for_Submit.getFields();
        string specError = Label.GGSpecSubmitError;         
        list<string> fNameList = new list<string>();
        
        for (Specification__c stc: specsToCheck){
            if (stc.recordTypeId != partsSpecRT){
                if (stc.recordTypeId == concoreSpecRT){
                    validateConcoreMTORequiredFieldsForSubmit(stc, fNameList);
                }
                if (stc.recordTypeId == rawSpecRT){
                    validateRawMTORequiredFieldsForSubmit(stc, fNameList);
                }                
                if (stc.recordTypeId == partsRFIRT){
                    validatePartsRFIRequiredFieldsForSubmit(stc, fNameList);
                }                
            }
            else{
                for (FieldSetMember fSetMember : lMandatoryfields){
                    if (stc.get(fSetMember.getFieldPath()) == null){
                        fNameList.add(fSetMember.getLabel());
                    }
                    else {
                        //all of the fields for Spec in the Config Workbook marked as 'Required for Submit' = 1D are checked
                        List<Schema.FieldSetMember> lConditionalfields = new list<Schema.FieldSetMember>();
                        if (fSetMember.getFieldPath() == 'cncNeeded__c') {
                            if (stc.get(fSetMember.getFieldPath()) == 'Yes') {
                                lConditionalfields = Schema.SObjectType.Specification__c.FieldSets.Conditional_Required_for_Submit_CNC.getFields();
                                for (FieldSetMember fCondSetMember : lConditionalFields){
                                    if (stc.get(fCondSetMember.getFieldPath()) == null){
                                        fNameList.add(fCondSetMember.getLabel());
                                    }
                                }   
                            }
                        }
                        else if (fSetMember.getFieldPath() == 'ioxNeeded__c') {
                            if (stc.get(fSetMember.getFieldPath()) == 'Yes') 
                                /*if (fSetMember.getFieldPath() == 'selectIoxDolCsValueTarget__c') {
if (stc.get(fSetMember.getFieldPath()) == 'Customized')*/{
    lConditionalfields = Schema.SObjectType.Specification__c.FieldSets.Conditional_Required_for_Submit_IOX.getFields();
    for (FieldSetMember fCondSetMember : lConditionalFields){
        if (stc.get(fCondSetMember.getFieldPath()) == null){
            fNameList.add(fCondSetMember.getLabel());
        }
    }   
}   
                        }
                        else if (fSetMember.getFieldPath() == 'screenPrint__c') {
                            if (stc.get(fSetMember.getFieldPath()) == 'Yes'){
                                lConditionalfields = Schema.SObjectType.Specification__c.FieldSets.Conditional_Required_for_Submit_ScreenPr.getFields();
                                for (FieldSetMember fCondSetMember : lConditionalFields){
                                    if (stc.get(fCondSetMember.getFieldPath()) == null){
                                        fNameList.add(fCondSetMember.getLabel());
                                    }
                                }   
                            } 
                            else
                                if (stc.get(fSetMember.getFieldPath()) == 'Special Request'){
                                    lConditionalfields = Schema.SObjectType.Specification__c.FieldSets.Conditional_Required_for_Submit_Customiz.getFields();
                                    for (FieldSetMember fCondSetMember : lConditionalFields){
                                        if (stc.get(fCondSetMember.getFieldPath()) == null){
                                            fNameList.add(fCondSetMember.getLabel());
                                        }
                                    } 
                                }  
                        }
                    }
                }
            }
            if (fNameList.size() > 0) {
                string message = specError + ' ';
                for (string fName : fNameList) {
                    message += fName + ', ';
                }
                message = message.trim();
                message = message.substring(0,message.length()-1);
                //system.debug(message);
                stc.addError(message);
            }
        }
    }
    
    //If all selected risk assessment have been set to Approved or Not Approved, then Risk Assessment is Complete
    public static void setRiskAssessment(Map<Id, Specification__c> newSpecMap) {
        //For each map entry/Specification
        for (Specification__c specToCheck : newSpecMap.values()) {
            
            if ((specToCheck.qualityEngineerApproval__c == 'Approved - Requires Plant Eng Approval' && specToCheck.plantEngineerApproval__c == 'Approved')
                || specToCheck.qualityEngineerApproval__c =='Approved - Includes Plant Eng Approval'
                || specToCheck.qualityEngineerApproval__c =='Not Required') {    
                    specToCheck.riskAssessmentComplete__c = true;
                }
            // dual source
            if ((specToCheck.dsQualityEngineerApproval__c == 'Approved - Requires Plant Eng Approval' && specToCheck.dsPlantEngineerApproval__c == 'Approved')
                || specToCheck.dsQualityEngineerApproval__c =='Approved - Includes Plant Eng Approval'
                || specToCheck.dsQualityEngineerApproval__c =='Not Required') {    
                    specToCheck.dsRiskAssessmentComplete__c = true;
                }
        }
    }
    
    //method on before trigger event on specification
    public static void onBeforeInsert(List<Specification__c> newSpecs){
        
        //If the new Specification has PreBuildApproved__c field is true then updating it to false
        for(Specification__c spec : newSpecs){
            if(spec.PreBuildApproved__c){
                spec.PreBuildApproved__c = false;
            }
        }
        
    }
    
    //method to perform various action on before update event for specification 
    public static void onBeforeUpdate(List<Specification__c> newSpecs, Map<Id, Specification__c> oldSpecsMap){
        
        Map<Id, Opportunity> opportunityById = new Map<Id, Opportunity>();
        
        for(Specification__c spec : newSpecs){
            opportunityById.put(spec.opportunity__c, null);	
        }
        
        //getting specifications opportunity type details and adding them into Map
        for(Opportunity opp : [SELECT Id, type FROM Opportunity WHERE Id IN :opportunityById.keySet()]){
            opportunityById.put(opp.Id, opp);
        }
        //getting record type Id by describing the specification object and record type
        Id specRecordTypeId = Schema.SObjectType.Specification__c.getRecordTypeInfosByName().get('Parts - Submitted').getRecordTypeId();
        
        //checking if the status of specification is change from Risk Assessment to CM Cosr Assessment then updating PreBuildApproved to true
        for(Specification__c spec : newSpecs){
            if(spec.status__c != oldSpecsMap.get(spec.Id).status__c && oldSpecsMap.get(spec.Id).status__c == 'Risk Assessment' 
               && opportunityById.get(spec.opportunity__c).Type == 'Parts'
               && spec.status__c == 'CM Cost Assessment'
               && spec.RecordTypeId == specRecordTypeId){
                   spec.PreBuildApproved__c = true;
               }
        }
    }
    
    //method with action for After Update event on Specification trigger 
    public static void onAfterUpdate(List<Specification__c> newSpecs, Map<Id, Specification__c> oldSpecsMap){
        Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();
        Set<Id> specIds = new Set<Id>();
        Map<Id, Specification__c> newSpecsMap = new Map<Id, Specification__c>();
        //System.debug('check for update');
        //adding Ids of those specification which have change in their product code and product code is not null to specIds Set
        for(Specification__c spec : newSpecs){
            if(spec.productCode__c != oldSpecsMap.get(spec.Id).productCode__c){
                newSpecsMap.put(spec.Id, spec);
                specIds.add(spec.Id);
            }
        }
        System.debug('newSpecsMap====>' + newSpecsMap);
        //getting opportunity(SR) on which the updated specification is already attached
        for(Opportunity opp: [SELECT id, name, ProductCode__c
                              ,(SELECT Id,specification__c FROM OpportunityLineItems 
                                WHERE specification__r.productCode__c != null
                                AND specification__c != null
                                AND isSampleProduct__c = TRUE)
                              FROM Opportunity 
                              where ID IN (SELECT OpportunityId 
                                           FROM OpportunityLineItem
                                           where specification__c IN :specIds)]){
                                               for(OpportunityLineItem oli : opp.OpportunityLineItems){
                                                   if(newSpecsMap.containsKey(oli.specification__c)){
                                                       System.debug('opp.OpportunityLineItems[0].specification__c==>' + newSpecsMap.get(opp.OpportunityLineItems[0].specification__c).productCode__c);
                                                       opp.ProductCode__c = newSpecsMap.get(opp.OpportunityLineItems[0].specification__c).productCode__c;
                                                       opportunityMap.put(opp.Id,opp);  
                                                   }
                                               }
                                           }
        
        
        //Updating opportunities by checking the List Size
        if(opportunityMap.size() > 0){
            UPDATE opportunityMap.values(); 
        }
    }
    
}