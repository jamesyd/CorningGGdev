/**
 * @description       : 
 * @author            : Edgar Santillana
 * @group             : 
 * @last modified on  : 11-04-2020
 * @last modified by  : Jim Dickerson
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   09-08-2020   Edgar Santillana   Remove -TQ from GIS-TQ, XC-TQ and XX DG-TQ values on partsRiskNotification Method
 * 1.1   09-24-2020   Edgar Santillana   New value added JNTC-TQ-QA on partsRiskNotification Method 
 * 1.2   09-24-2020   Edgar Santillana   New value added Liangcheng-LR on partsRiskNotification Method 
 * 1.3   10-27-2020   Jim Dickerson      New value added HLF-LR on partsRiskNotification Method
 * 1.4   11-04-2020   Jim Dickerson      Implement changes for Corning Bendable Glass (CSMSF-23)
 * 1.5   12-01-2020   Jim Dickerson      HLF-LR is now HLF (Jira CSMSF-48)
 * 1.6   21Jan2021    Jim Dickerson      Add in Jingzhuo, Econy, and Phoenix CMS (Jira CSMSF-54)
 * 1.7   25Jan2021    Jim Dickerson      Change QE/PE approval sequence (Jira CSMSF-34)
**/
public without sharing class ChatterHelper {
    
    public Static List<Specification__c> specificationReminder( List<Specification__c> speclist ) {
        Utilities Utils = new Utilities();
        
        String partPath;
        String finalMessage;
        String rfiOrRfq;
        String baseRecipients;
        ID aeRecipient;
        ID submitRecipient;
        String combinedRecipients;
        String finalRecipients;
        String location;        
        List<Specification__c> specsToUpdate = new List<Specification__c>();
        
        Boolean addSpec;
        
        for(Specification__c spec : specList) {
            
            if (spec.statusChangeDate__c != Null) { // wait until existing spec have a value in this date field
                
                // ***** PARTS REMINDER LOGIC *****
                if (spec.productLine__c == 'Parts' && spec.reminderCompleted__c == false && spec.statusChangeDate__c.daysBetween(Date.Today()) > 2 && (spec.status__c == 'Missing Information Assessment' || spec.status__c == 'Manufacturer Assignment' || spec.status__c == 'Risk Assessment' || spec.status__c == 'CM Cost Assessment' || spec.status__c == 'Pricing Assignment')) {
                    
                    system.debug('*** IN REPOST');
                    // Clear variables
                    partPath = '';
                    finalMessage = '';
                    rfiOrRfq = '';
                    baseRecipients = '';
                    combinedRecipients = '';
                    finalRecipients = '';
                    location = '';        
                    
                    spec.reminderCompleted__c = true; // apex clears this field on status change   
                    if (addSpec == false) {
                        specsToUpdate.add(spec); // list of specs to update to not continuously repost
                        addSpec = True;
                    }    
                    // ********************
                    
                    // WWPE reminder logic
                    If (spec.status__c == 'Missing Information Assessment') {
                        
                        // parts or omega
                        partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'N~MIA' : 'OM~N~MIA'; 
                        
                        finalMessage = Utils.getMessageInnovationOnly(partPath,spec);
                        
                        // recipients - includes innovation PLMs
                        baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
                        if (String.isEmpty(spec.innovation_type__c) == False) {
                            combinedRecipients = baseRecipients + Utils.getInnovationRecipients(spec);
/*
                            partPath =  location(spec); // CSMSF-23 Is this Corning Bendable Glass (CBG) ?
                            if (String.isEmpty(partPath) == False) {
                                // We are doing CBG, so add in AE as well ...
                                aeRecipient = spec.accountAEId__c;
                                combinedRecipients = combinedRecipients +',{' + aeRecipient + '}';
                            }
*/
                        } else {
                            combinedRecipients = baseRecipients;
                        }
                        
                        // clean/remove duplicate recipients
                        finalRecipients = Utils.cleanRecipients(combinedRecipients);
                        
                        // rfi configuration
                        rfiOrRfq = spec.rfiConfiguration__c <> Null ? '- RFI Configuration: ' + spec.rfiConfiguration__c + ' ' : '';  
                        
                        // second parameter = Id of a group or user or record or 'me'
                        ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                                 spec.id, spec.opportunityName__c + ' ' + rfiOrRfq + finalRecipients + ' ***** REMINDER ' + finalMessage);
                    }
                    
                    // Master Planner reminder logic
                    If (spec.status__c == 'Manufacturer Assignment') {
                        
                        // parts or omega
                        partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'SA~MA' : 'OM~SA~MA'; 
                        
                        finalMessage = Utils.getMessageInnovationOnly(partPath,spec);
                        
                        // recipients - do not include innovation PLMs
                        baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
                        combinedRecipients = baseRecipients;
                        
                        // clean/remove duplicate recipients
                        finalRecipients = Utils.cleanRecipients(combinedRecipients);
                        
                        // rfi configuration
                        rfiOrRfq = spec.rfiConfiguration__c <> Null ? '- RFI Configuration: ' + spec.rfiConfiguration__c + ' ' : '';  
                        
                        // second parameter = Id of a group or user or record or 'me'
                        ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                                 spec.id, spec.opportunityName__c + ' ' + rfiOrRfq + finalRecipients + ' ***** REMINDER ' + finalMessage);
                    }
                    
                    // QE & PE reminder logic
                    If (spec.status__c == 'Risk Assessment') {
                        
                        // parts or omega
                        partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'Parts' : 'Omega'; 
                        
                        If (partPath == 'Parts') {
                            partsRiskNotification(spec, 1, False, '', False, ' ***** REMINDER ');                        
                        }
                        
                        If (partPath == 'Omega') {                        
                            omegaRiskNotification(spec, ' ***** REMINDER ');
                        }          
                    }
                    
                    // Planner & Finance reminder logic
                    If (spec.status__c == 'CM Cost Assessment') {
                        
                        // parts or omega
                        partPath = getCBGlocation(spec); // CSMSF-23
                        if (String.isEmpty(partPath) == true)
                            partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'RA~CA' : 'OM~RA~CA'; 
                        else partPath = 'CBG-RA~CA';                        
                        finalMessage = Utils.getMessageInnovationAndLocation(partPath,spec);
                        
                        // recipients - do not include innovation PLMs
                        baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
                        combinedRecipients = baseRecipients;
                        
                        // clean/remove duplicate recipients
                        finalRecipients = Utils.cleanRecipients(combinedRecipients);
                        
                        // rfi configuration
                        rfiOrRfq = spec.rfiConfiguration__c <> Null ? '- RFI Configuration: ' + spec.rfiConfiguration__c + ' ' : '';  
                        
                        // second parameter = Id of a group or user or record or 'me'
                        ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                                 spec.id, spec.opportunityName__c + ' ' + rfiOrRfq + finalRecipients + ' ***** REMINDER ' + finalMessage);                         
                    }
                    
                    // PLM reminder logic
                    If (spec.status__c == 'Pricing Assignment') {
                        
                        // parts or omega
                        //partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'CA~PA' : 'OM~CA~PA';                     
                        partPath = getCBGlocation(spec); // CSMSF-23
                        if (String.isEmpty(partPath) == true)
                             partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'CA~PA' : 'OM~CA~PA'; 
                        else partPath = 'CBG-CA~PA';                       
                        finalMessage = Utils.getMessageInnovationAndLocation(partPath,spec);
                        
                        // recipients - includes innovation PLMs
                        baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
                        if (String.isEmpty(spec.innovation_type__c) == False) {
                            combinedRecipients = baseRecipients + Utils.getInnovationRecipients(spec);
                        } else {
                            combinedRecipients = baseRecipients;
                        }
                        
                        // clean/remove duplicate recipients
                        finalRecipients = Utils.cleanRecipients(combinedRecipients);
                        
                        // rfi configuration
                        rfiOrRfq = spec.rfiConfiguration__c <> Null ? '- RFI Configuration: ' + spec.rfiConfiguration__c + ' ' : '';  
                        
                        // second parameter = Id of a group or user or record or 'me'
                        ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                                 spec.id, spec.opportunityName__c + ' ' + rfiOrRfq + finalRecipients + ' ***** REMINDER ' + finalMessage);                      
                    }
                    
                }  
                
                // ***** RAW GLASS REMINDER LOGIC *****
                if (spec.productLine__c == 'Raw Glass' && spec.reminderCompleted__c == false && spec.statusChangeDate__c.daysBetween(Date.Today()) > 2 && (spec.status__c == 'Supply, Allocation, and Inventory Review' || spec.status__c == 'Product Engineering Input' || spec.status__c == 'Plant Engineering Input' || spec.status__c == 'Supply Chain Input' || spec.status__c == 'Pricing Assignment' || spec.status__c == 'Business Case Finalization' || spec.status__c == 'Finance Review' || spec.status__c == 'Commercial/Ops Review')) {
                    
                    spec.reminderCompleted__c = true; // apex clears this field on status change
                    if (addSpec == false) {
                        specsToUpdate.add(spec); // list of specs to update to not continuously repost
                        addSpec = True;
                    }
                    
                    // Demand Ops reminder logic
                    If (spec.status__c == 'Supply, Allocation, and Inventory Review') {
                        If (spec.mtoNotificationPath__c == 'Path 1') {
                            finalMessage = GGMTOSpecAutoNotifications__c.getValues('P1~N~SAIR').message__c;
                            finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P1~N~SAIR').userIdList__c;
                        } else if (spec.mtoNotificationPath__c == 'Path 2') {
                            finalMessage = GGMTOSpecAutoNotifications__c.getValues('P2~N~SAIR').message__c;
                            finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P2~N~SAIR').userIdList__c;                        
                        }
                        
                        // second parameter = Id of a group or user or record or 'me'
                        ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                                 spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ***** REMINDER ' + finalMessage);
                    }
                    
                    // Product Engineering reminder logic
                    If (spec.status__c == 'Product Engineering Input') {
                        If (spec.mtoNotificationPath__c == 'Path 1') {
                            finalMessage = GGMTOSpecAutoNotifications__c.getValues('P1~SAIR~PREI').message__c;
                            finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P1~SAIR~PREI').userIdList__c;
                        } else if (spec.mtoNotificationPath__c == 'Path 2') {
                            finalMessage = GGMTOSpecAutoNotifications__c.getValues('P2~SAIR~PREI').message__c;
                            finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P2~SAIR~PREI').userIdList__c;                       
                        }
                        
                        // second parameter = Id of a group or user or record or 'me'
                        ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                                 spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ***** REMINDER ' + finalMessage);
                    }
                    
                    // Plant Engineering reminder logic
                    If (spec.status__c == 'Plant Engineering Input') {
                        If (spec.mtoNotificationPath__c == 'Path 1') {
                            finalMessage = GGMTOSpecAutoNotifications__c.getValues('P1~PREI~PLEI').message__c;
                            finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P1~PREI~PLEI').userIdList__c;
                        } else if (spec.mtoNotificationPath__c == 'Path 2') {
                            finalMessage = GGMTOSpecAutoNotifications__c.getValues('P2~PREI~PLEI').message__c;
                            finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P2~PREI~PLEI').userIdList__c;                        
                        }
                        
                        // second parameter = Id of a group or user or record or 'me'
                        ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                                 spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ***** REMINDER ' + finalMessage);                   
                    }
                    
                    // Supply Chain notification logic
                    If (spec.status__c == 'Supply Chain Input') {
                        If (spec.mtoNotificationPath__c == 'Path 1') {        
                            finalMessage = GGMTOSpecAutoNotifications__c.getValues('P1~PLEI~SCI').message__c;
                            finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P1~PLEI~SCI').userIdList__c;
                        } else if (spec.mtoNotificationPath__c == 'Path 2') {
                            finalMessage = GGMTOSpecAutoNotifications__c.getValues('P2~PLEI~SCI').message__c;
                            finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P2~PLEI~SCI').userIdList__c;                        
                        }
                        
                        // second parameter = Id of a group or user or record or 'me'
                        ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                                 spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ***** REMINDER ' + finalMessage);                        
                    }                
                    
                    // PLM Pricing reminder logic
                    If (spec.status__c == 'Pricing Assignment') {
                        If (spec.mtoNotificationPath__c == 'Path 1') {    
                            finalMessage = GGMTOSpecAutoNotifications__c.getValues('P1~SCI~PA').message__c;
                            finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P1~SCI~PA').userIdList__c;
                        } else if (spec.mtoNotificationPath__c == 'Path 2') {
                            finalMessage = GGMTOSpecAutoNotifications__c.getValues('P2~SCI~PA').message__c;
                            finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P2~SCI~PA').userIdList__c;                        
                        }
                        
                        // second parameter = Id of a group or user or record or 'me'
                        ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                                 spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ***** REMINDER ' + finalMessage);                         
                    }
                    
                    // PLM reminder logic
                    If (spec.status__c == 'Business Case Finalization') {
                        If (spec.mtoNotificationPath__c == 'Path 1') {
                            finalMessage = GGMTOSpecAutoNotifications__c.getValues('P1~PA~BCF').message__c;
                            finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P1~PA~BCF').userIdList__c;
                        } else if (spec.mtoNotificationPath__c == 'Path 2') {
                            finalMessage = GGMTOSpecAutoNotifications__c.getValues('P2~PA~BCF').message__c;
                            finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P2~PA~BCF').userIdList__c;                        
                        }
                        
                        // second parameter = Id of a group or user or record or 'me'
                        ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                                 spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ***** REMINDER ' + finalMessage);                      
                    }
                    
                    // Finance reminder logic
                    If (spec.status__c == 'Finance Review') {
                        If (spec.mtoNotificationPath__c == 'Path 1') {
                            finalMessage = GGMTOSpecAutoNotifications__c.getValues('P1~BCF~FR').message__c;
                            finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P1~BCF~FR').userIdList__c;
                        } else if (spec.mtoNotificationPath__c == 'Path 2') {
                            finalMessage = GGMTOSpecAutoNotifications__c.getValues('P2~BCF~FR').message__c;
                            finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P2~BCF~FR').userIdList__c;                        
                        }
                        
                        // second parameter = Id of a group or user or record or 'me'
                        ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                                 spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ***** REMINDER ' + finalMessage);                      
                    } 
                    
                    // Commercial/Ops Review reminder logic
                    If (spec.status__c == 'Commercial/Ops Review') {
                        // different path based on record type - inventory vs MTO
                        if (spec.RecordTypeId == '0121J000000U1co') { // Raw Glass - Submitted
                            If (spec.mtoNotificationPath__c == 'Path 1') {
                                finalMessage = GGMTOSpecAutoNotifications__c.getValues('P1~BCF~COR').message__c;
                                finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P1~BCF~COR').userIdList__c;
                            } else if (spec.mtoNotificationPath__c == 'Path 2') {
                                finalMessage = GGMTOSpecAutoNotifications__c.getValues('P2~BCF~COR').message__c;
                                finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P2~BCF~COR').userIdList__c;                        
                            }
                        }
                        if (spec.RecordTypeId == '0121J000001MNl7') { // Raw Glass - Inventory Submitted                          
                            finalMessage = GGMTOSpecAutoNotifications__c.getValues('INV~BCF~COR').message__c;
                            finalRecipients = GGMTOSpecAutoNotifications__c.getValues('INV~BCF~COR').userIdList__c;
                        }
                        
                        // second parameter = Id of a group or user or record or 'me'
                        ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                                 spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ***** REMINDER ' + finalMessage);                   
                    }              
                    
                }          
            }
            
            if (spec.productLine__c == 'Parts' && spec.dsStatusChangeDate__c != Null) {
                
                // ***** PARTS DUAL SOURCE REMINDER LOGIC *****
                if (spec.productLine__c == 'Parts' && spec.dsReminderCompleted__c == false && spec.dsStatusChangeDate__c.daysBetween(Date.Today()) > 2 && (spec.dsStatus__c == 'Manufacturer Assignment' || spec.dsStatus__c == 'Risk Assessment' || spec.status__c == 'CM Cost Assessment')) {
                    
                    system.debug('*** IN REPOST');
                    // Clear variables
                    finalMessage = '';
                    rfiOrRfq = '';
                    baseRecipients = '';
                    combinedRecipients = '';
                    finalRecipients = '';
                    location = '';        
                    
                    spec.dsReminderCompleted__c = true; // apex clears this field on status change
                    if (addSpec == false) {
                        specsToUpdate.add(spec); // list of specs to update to not continuously repost
                        addSpec = True;
                    }
                    
                    // ********************  
                    
                    // Dual Source - Master Planner reminder logic
                    If (spec.dsStatus__c == 'Manufacturer Assignment') {
                        
                        // parts or omega
                        partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'SA~MA' : 'OM~SA~MA'; 
                        
                        finalMessage = Utils.getMessageInnovationOnly(partPath,spec);
                        
                        // recipients - do not include innovation PLMs
                        baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
                        combinedRecipients = baseRecipients;
                        
                        // clean/remove duplicate recipients
                        finalRecipients = Utils.cleanRecipients(combinedRecipients);
                        
                        // second parameter = Id of a group or user or record or 'me'
                        ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                                 spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ***** DUAL SOURCE REMINDER ' + finalMessage);
                    }
                    
                    // Dual Source - QE & PE reminder logic
                    If (spec.dsStatus__c == 'Risk Assessment') {
                        
                        // parts or omega
                        partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'Parts' : 'Omega'; 
                        
                        If (partPath == 'Parts') {
                            partsRiskNotification(spec, 2, False, '', False, ' ***** DUAL SOURCE REMINDER ');                        
                        }
                        
                        If (partPath == 'Omega') {                        
                            omegaRiskNotification(spec, ' ***** DUAL SOURCE REMINDER ');
                        }      
                        
                    }
                    
                    // Dual Source - Planner & Finance reminder logic
                    If (spec.dsStatus__c == 'CM Cost Assessment') {
                        
                        // parts or omega
                        partPath = getCBGlocation(spec); // CSMSF-23 Is this Corning Bendable Glass (CBG) ?
                        if (String.isEmpty(partPath) == true)
                            partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'RA~CA' : 'OM~RA~CA';
                        else {
                            partPath = 'CBG-RA~CA'; // CSMSF-23
                        }                                              
                        finalMessage = Utils.getMessageInnovationAndLocationDS(partPath,spec);
                        
                        // recipients - do not include innovation PLMs
                        baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
                        combinedRecipients = baseRecipients;
                        
                        // clean/remove duplicate recipients
                        finalRecipients = Utils.cleanRecipients(combinedRecipients);
                        
                        // second parameter = Id of a group or user or record or 'me'
                        ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                                 spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ***** DUAL SOURCE REMINDER ' + finalMessage);                         
                    }                    
                }
            }  
            
            // reset addSpec;
            addSpec = False;
            
        }        
        return specsToUpdate;
    }
    
    public Static Void specificationNotification( List<Specification__c> speclist, Map<ID, Specification__c> oldmap ) {
        Utilities Utils = new Utilities();
        String partPath;    
        String finalMessage;
        String rfiOrRfq;
        String declineMessage;
        String qaMessage;
        String baseRecipients;
        String combinedRecipients;
        String finalRecipients;
        String location;        
 
        for(specification__c spec : speclist) {  
            // ***** PARTS LOGIC *****

            // clear variables
            partPath = '';
            finalMessage = '';
            rfiOrRfq = '';
            declineMessage = '';
            qaMessage = '';
            baseRecipients = '';
            ID aeRecipient;
            ID submitRecipient;
            combinedRecipients = '';
            finalRecipients = '';
            location = '';   
            
            if (spec.productLine__c == 'Parts') { 
                
                // WWPE notification logic
                If (oldMap.get(spec.ID).status__c == 'New' && spec.status__c == 'Missing Information Assessment') {
                    
                    // parts or omega
                    partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'N~MIA' : 'OM~N~MIA';
                    
                    finalMessage = Utils.getMessageInnovationOnly(partPath,spec);
                    
                    // recipients - includes innovation PLMs
                    baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
                    if (String.isEmpty(spec.innovation_type__c) == False) {
                        combinedRecipients = baseRecipients + Utils.getInnovationRecipients(spec);
/* removed per customer request
                        partPath = getCBGlocation(spec); // CSMSF-23 Is this Corning Bendable Glass (CBG) ?
                        if (String.isEmpty(partPath) == false) {
                            // We are doing CBG, so add in AE as well ...
                            aeRecipient = spec.accountAEId__c;
                            combinedRecipients = combinedRecipients +',{' + aeRecipient + '}';
                        }  
*/                 
                    } else {
                        combinedRecipients = baseRecipients;
                    }
    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);   
                                 
                    // rfi configuration
                    rfiOrRfq = spec.rfiConfiguration__c <> Null ? '- RFI Configuration: ' + spec.rfiConfiguration__c + ' ' : '';  
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + rfiOrRfq + finalRecipients + ' ' + finalMessage);
                }
                
                // Master Planner notification logic - Path 1
                If (oldMap.get(spec.ID).status__c == 'Standard Assessment' && spec.status__c == 'Manufacturer Assignment') {
                    
                    // parts or omega
                    partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'SA~MA' : 'OM~SA~MA';
                    
                    finalMessage = Utils.getMessageInnovationOnly(partPath,spec);
                    
                    // recipients - do not include innovation PLMs
                    baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
                    combinedRecipients = baseRecipients;
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // rfi configuration
                    rfiOrRfq = spec.rfiConfiguration__c <> Null ? '- RFI Configuration: ' + spec.rfiConfiguration__c + ' ' : '';  
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + rfiOrRfq + finalRecipients + ' ' + finalMessage);
                }
                
                // Master Planner notification logic - Path 2
                If (oldMap.get(spec.ID).status__c == 'Risk Assessment' && spec.status__c == 'Manufacturer Assignment') {
                    
                    // parts or omega
                    partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'RA~MA' : 'OM~RA~MA';
                    
                    finalMessage = Utils.getMessageInnovationOnly(partPath,spec);
                    
                    // recipients - do not include innovation PLMs
                    baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
                    combinedRecipients = baseRecipients;
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // rfi configuration
                    rfiOrRfq = spec.rfiConfiguration__c <> Null ? '- RFI Configuration: ' + spec.rfiConfiguration__c + ' ' : '';  
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + rfiOrRfq + finalRecipients + ' ' + finalMessage);                   
                }
                
                // Master Planner notification logic - Path 3
                If (oldMap.get(spec.ID).status__c == 'CM Cost Assessment' && spec.status__c == 'Manufacturer Assignment') {
                    
                    // parts or omega
                    partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'CA~MA' : 'OM~CA~MA';
                    
                    finalMessage = Utils.getMessageInnovationOnly(partPath,spec);
                    
                    // recipients - do not include innovation PLMs
                    baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
                    combinedRecipients = baseRecipients;
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // rfi configuration
                    rfiOrRfq = spec.rfiConfiguration__c <> Null ? '- RFI Configuration: ' + spec.rfiConfiguration__c + ' ' : '';  
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + rfiOrRfq + finalRecipients + ' ' + finalMessage);                        
                }
                
                // Master Planner notification logic - Path 4
                If (oldMap.get(spec.ID).status__c == 'Pricing Assignment' && spec.status__c == 'Manufacturer Assignment') {
                    
                    // parts or omega
                    partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'PA~MA' : 'OM~PA~MA';
                    
                    finalMessage = Utils.getMessageInnovationOnly(partPath,spec);
                    
                    // recipients - do not include innovation PLMs
                    baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
                    combinedRecipients = baseRecipients;
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // rfi configuration
                    rfiOrRfq = spec.rfiConfiguration__c <> Null ? '- RFI Configuration: ' + spec.rfiConfiguration__c + ' ' : '';  
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + rfiOrRfq + finalRecipients + ' ' + finalMessage);                        
                }
                
                // Master Planner notification logic - Path 5
                // an - 7/3/18 - RFI
                If (oldMap.get(spec.ID).status__c == 'Missing Information Assessment' && spec.status__c == 'Manufacturer Assignment') {
                    
                    // parts or omega
                    partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'MIA~MA' : 'OM~MIA~MA';
                    
                    finalMessage = Utils.getMessageInnovationOnly(partPath,spec);
                    
                    // recipients - do not include innovation PLMs
                    baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
                    combinedRecipients = baseRecipients;
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // rfi configuration
                    rfiOrRfq = spec.rfiConfiguration__c <> Null ? '- RFI Configuration: ' + spec.rfiConfiguration__c + ' ' : '';  
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + rfiOrRfq + finalRecipients + ' ' + finalMessage);                        
                }
                // Master Planner notification logic - Path 6 for Corning Bendable Glass specification 11/3/20
                // added for CSMSF-23
                if (oldMap.get(spec.ID).status__c == 'Capable Assessment' && spec.status__c == 'Manufacturer Assignment') {
                    
                    // parts or omega
                    partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'CBG-CA~MA' : 'OM~MIA~MA';
                    
                    finalMessage = Utils.getMessageInnovationOnly(partPath,spec);
                    
                    // recipients - do not include innovation PLMs
                    baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
                    combinedRecipients = baseRecipients;
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + rfiOrRfq + finalRecipients + ' ' + finalMessage);                        
                }           
                // QE notification logic - Path 2
                If (oldMap.get(spec.ID).status__c == 'CM Cost Assessment' && spec.status__c == 'Risk Assessment') {
                    
                    // parts or omega
                    partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'Parts' : 'Omega'; 
                    
                    If (partPath == 'Parts') {
                        partsRiskNotification(spec, 1, False, '', False, '');                        
                    }
                    
                    If (partPath == 'Omega') {                        
                        omegaRiskNotification(spec, '');
                    }                   
                }
                
                // QE notification logic - Normal path
                // CSMSF-34 - QE notification now comes after PE approval ... (unless PE approval already 'Approved' via WF)
                If (((oldMap.get(spec.ID).status__c == 'Risk Assessment' && spec.status__c == 'Risk Assessment') && 
                    (oldmap.get(spec.ID).plantEngineerApproval__c != 'Approved' && spec.plantEngineerApproval__c == 'Approved') ) ||
                    (oldMap.get(spec.ID).status__c == 'Manufacturer Assignment' && spec.status__c == 'Risk Assessment' && spec.plantEngineerApproval__c == 'Approved')) {
                //If (oldMap.get(spec.ID).status__c == 'Manufacturer Assignment' && spec.status__c == 'Risk Assessment') {
                    
                    // parts or omega
                    partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'Parts' : 'Omega';                   
                    If (partPath == 'Parts') {
                        partsRiskNotification(spec, 1, False, '', False, '');                        
                    }
                    
                    If (partPath == 'Omega') {                        
                        omegaRiskNotification(spec, '');
                    }                   
                }
                
                // AE notification logic if required
                If ((oldMap.get(spec.ID).status__c == 'Risk Assessment' && spec.status__c == 'Risk Assessment') && ( (oldMap.get(spec.ID).qualityEngineerApproval__c != 'Reviewed - More Information Required' && spec.qualityEngineerApproval__c == 'Reviewed - More Information Required') )) {
                    
                    finalMessage = '***** Reviewed - More Information Required *****';
                    
                    // recipients - do not include innovation PLMs
                    aeRecipient = spec.accountAEId__c;
                    submitRecipient = spec.CreatedById;
                    combinedRecipients = '{' + aeRecipient + '},{' + submitRecipient + '}';
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // rfi configuration
                    rfiOrRfq = spec.rfiConfiguration__c <> Null ? '- RFI Configuration: ' + spec.rfiConfiguration__c + ' ' : '';  
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + rfiOrRfq + finalRecipients + ' ' + finalMessage);                                                                        
                    
                }
                
                // QE notification logic if required
                If ((oldMap.get(spec.ID).status__c == 'Risk Assessment' && spec.status__c == 'Risk Assessment') && ( (oldMap.get(spec.ID).qualityEngineerApproval__c != 'Customer Responded - QA to Confirm' && spec.qualityEngineerApproval__c == 'Customer Responded - QA to Confirm') )) {
                    
                    // parts or omega
                    partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'Parts' : 'Omega'; 
                    
                    If (partPath == 'Parts') {
                        partsRiskNotification(spec, 1, False, '', True, '');                        
                    }
                    
                    If (partPath == 'Omega') {                        
                        omegaRiskNotification(spec, '');
                    }                   
                }
                
                // PE notification logic if required by QE - normal path
                // CSMSF-34 PE approval now comes first, before QE approval ... (unless already approved)
                if (oldMap.get(spec.ID).status__c == 'Manufacturer Assignment' && spec.status__c == 'Risk Assessment' && spec.plantEngineerApproval__c != 'Approved') {
                //If ((oldMap.get(spec.ID).status__c == 'Risk Assessment' && spec.status__c == 'Risk Assessment') && ( (oldMap.get(spec.ID).qualityEngineerApproval__c == null && spec.qualityEngineerApproval__c == 'Approved - Requires Plant Eng Approval') || (oldMap.get(spec.ID).qualityEngineerApproval__c == 'Reviewed - More Information Required' && spec.qualityEngineerApproval__c == 'Approved - Requires Plant Eng Approval') )) {
                    
                    // Loop through location list and post to selected locations
                    location = '';
                    List<String> lstLocations = new List<String>();            
                    lstLocations.clear();
                    if (spec.location__c != null)
                         lstLocations = spec.location__c.split(';');

                    for (String l : lstLocations) {
                        
                        // parts or omega
                        partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? l : 'OM~PE'; 
                    
                        finalMessage = Utils.getMessageInnovationAndLocation(partPath,spec);
                        
                        // recipients - do not include innovation PLMs
                        baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
                        aeRecipient = spec.accountAEId__c;
                        submitRecipient = spec.CreatedById;
                        combinedRecipients = baseRecipients + ',{' + aeRecipient + '},{' + submitRecipient + '}';
                        
                        // clean/remove duplicate recipients
                        finalRecipients = Utils.cleanRecipients(combinedRecipients);
                        
                        // rfi configuration
                        rfiOrRfq = spec.rfiConfiguration__c <> Null ? '- RFI Configuration: ' + spec.rfiConfiguration__c + ' ' : '';  
                        
                        // second parameter = Id of a group or user or record or 'me'
                        ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                                 spec.id, spec.opportunityName__c + ' ' + rfiOrRfq + finalRecipients + ' ' + finalMessage);                                                                        
                    }                                   
                    
                }
                
                // AN - 8/9/18 - @mention QE & PE on thickness change during risk assessment
                // QE notification logic - Thckness change during Risk Assessment
                If ((oldMap.get(spec.ID).status__c == 'Risk Assessment' && spec.status__c == 'Risk Assessment') && (oldMap.get(spec.ID).thickness__c <> spec.thickness__c)) {
                    
                    // parts or omega
                    partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'Parts' : 'Omega'; 
                    
                    If (partPath == 'Parts') {
                        String x = String.valueOf(oldMap.get(spec.ID).thickness__c);
                        partsRiskNotification(spec, 1, True, x, False, '');                        
                    }
                    
                    If (partPath == 'Omega') {                        
                        omegaRiskNotification(spec, '');
                    }   
                    
                }
                
                // Planner & Finance notification logic - Path 1
                If (oldMap.get(spec.ID).status__c == 'Risk Assessment' && spec.status__c == 'CM Cost Assessment') {
                    
                    // parts or omega
                    partPath = getCBGlocation(spec); // CSMSF-23 Is this Corning Bendable Glass (CBG) ?
                    if (String.isEmpty(partPath) == true)
                        partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'RA~CA' : 'OM~RA~CA';
                    else {
                        partPath = 'CBG-RA~CA'; // CSMSF-23
                    }
                    
                    finalMessage = Utils.getMessageInnovationAndLocation(partPath,spec);
                    
                    // recipients - do not include innovation PLMs
                    baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
                    combinedRecipients = baseRecipients;
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // rfi configuration
                    rfiOrRfq = spec.rfiConfiguration__c <> Null ? '- RFI Configuration: ' + spec.rfiConfiguration__c + ' ' : '';  
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + rfiOrRfq + finalRecipients + ' ' + finalMessage);                         
                }
                
                // Planner & Finance notification logic - Path 2
                If (oldMap.get(spec.ID).status__c == 'Pricing Assignment' && spec.status__c == 'CM Cost Assessment') {
                    
                    // parts or omega
                    partPath = getCBGlocation(spec); // CSMSF-23 Is this Corning Bendable Glass (CBG) ?
                    if (String.isEmpty(partPath) == true)
                        partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'RA~CA' : 'OM~RA~CA';
                    else {
                        partPath = 'CBG-RA~CA'; // CSMSF-23
                    }
                    //partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'PA~CA' : 'OM~PA~CA';
                    
                    finalMessage = Utils.getMessageInnovationAndLocation(partPath,spec);
                    
                    // recipients - do not include innovation PLMs
                    baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
                    combinedRecipients = baseRecipients;
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // rfi configuration
                    rfiOrRfq = spec.rfiConfiguration__c <> Null ? '- RFI Configuration: ' + spec.rfiConfiguration__c + ' ' : '';  
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + rfiOrRfq + finalRecipients + ' ' + finalMessage);                         
                }
                
                // Planner & Finance notification logic - Path 4
                // an - 7/3/18 - RFI
                If (oldMap.get(spec.ID).status__c == 'Manufacturer Assignment' && spec.status__c == 'CM Cost Assessment') {
                    
                    // parts or omega
                    partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'MA~CA' : 'OM~MA~CA';
                    
                    finalMessage = Utils.getMessageInnovationAndLocation(partPath,spec);
                    
                    // recipients - do not include innovation PLMs
                    baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
                    combinedRecipients = baseRecipients;
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // rfi configuration
                    rfiOrRfq = spec.rfiConfiguration__c <> Null ? '- RFI Configuration: ' + spec.rfiConfiguration__c + ' ' : '';  
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + rfiOrRfq + finalRecipients + ' ' + finalMessage);                         
                }
                
                // PLM notification logic - Path 1 - include location in message
                If (oldMap.get(spec.ID).status__c == 'CM Cost Assessment' && spec.status__c == 'Pricing Assignment') {
                    
                    // parts or omega
                    partPath = getCBGlocation(spec); // CSMSF-23
                    if (String.isEmpty(partPath) == true)
                         partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'CA~PA' : 'OM~CA~PA'; 
                    else partPath = 'CBG-CA~PA';
                    
                    finalMessage = Utils.getMessageInnovationAndLocation(partPath,spec);
                    
                    // recipients - includes innovation PLMs
                    baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
                    if (String.isEmpty(spec.innovation_type__c) == False && partPath != 'CBG-CA~PA') { // CSMSF-23 don't send innovation owner if CBG
                        combinedRecipients = baseRecipients + Utils.getInnovationRecipients(spec);
                    } else {
                        combinedRecipients = baseRecipients;
                    }
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // rfi configuration
                    rfiOrRfq = spec.rfiConfiguration__c <> Null ? '- RFI Configuration: ' + spec.rfiConfiguration__c + ' ' : '';  
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + rfiOrRfq + finalRecipients + ' ' + finalMessage);                      
                }
                
                /* // Depricated - All Parts go through CM Cost Assessment
// PLM notification logic - Path 2 - include location in message
If (oldMap.get(spec.ID).status__c == 'Risk Assessment' && spec.status__c == 'Pricing Assignment') {
finalMessage = Utils.getMessageInnovationAndLocation('RA~PA',spec);

// recipients - includes innovation PLMs
baseRecipients = GGPartsSpecAutoNotifications__c.getValues('RA~PA').userIdList__c;
if (String.isEmpty(spec.innovation_type__c) == False) {
combinedRecipients = baseRecipients + Utils.getInnovationRecipients(spec);
} else {
combinedRecipients = baseRecipients;
}

// clean/remove duplicate recipients
finalRecipients = Utils.cleanRecipients(combinedRecipients);

// rfi configuration
rfiOrRfq = spec.rfiConfiguration__c <> Null ? '- RFI Configuration: ' + spec.rfiConfiguration__c + ' ' : '';  

// second parameter = Id of a group or user or record or 'me'
ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
spec.id, spec.opportunityName__c + ' ' + rfiOrRfq + finalRecipients + ' ' + finalMessage);                   
} */
                
                // PLM notification logic for Mass Production Check
                If ((oldMap.get(spec.ID).status__c == 'Pricing Approved' && spec.status__c == 'Pricing Approved') && (oldMap.get(spec.ID).massProduction__c == FALSE && spec.massProduction__c == TRUE)) {
                    
                    // parts or omega
                    partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'PA~MASS~TRUE' : 'OM~PA~MASS~TRUE';
                    
                    finalMessage = Utils.getMessageInnovationAndLocation(partPath,spec);
                    
                    // recipients - includes innovation PLMs
                    baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
                    if (String.isEmpty(spec.innovation_type__c) == False) {
                        combinedRecipients = baseRecipients + Utils.getInnovationRecipients(spec);
                    } else {
                        combinedRecipients = baseRecipients;
                    }
                    
                    // clean/remove duplicate recipients
                    system.debug('@@@ ' + combinedRecipients);
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // rfi configuration
                    rfiOrRfq = spec.rfiConfiguration__c <> Null ? '- RFI Configuration: ' + spec.rfiConfiguration__c + ' ' : '';  
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + rfiOrRfq + finalRecipients + ' ' + finalMessage);                      
                }
                
                // FINANCE notification logic for plm Acknowledgement
                If ((oldMap.get(spec.ID).status__c == 'Pricing Approved' && spec.status__c == 'Pricing Approved') && (oldMap.get(spec.ID).plmAcknowledgement__c == FALSE && spec.plmAcknowledgement__c == TRUE)) {
                    
                    // parts or omega
                    partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'PA~PLM~TRUE' : 'OM~PA~PLM~TRUE';
                    
                    finalMessage = Utils.getMessageInnovationAndLocation(partPath,spec);
                    
                    // recipients - includes innovation PLMs
                    baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
                    if (String.isEmpty(spec.innovation_type__c) == False) {
                        combinedRecipients = baseRecipients + Utils.getInnovationRecipients(spec);
                    } else {
                        combinedRecipients = baseRecipients;
                    }
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // rfi configuration
                    rfiOrRfq = spec.rfiConfiguration__c <> Null ? '- RFI Configuration: ' + spec.rfiConfiguration__c + ' ' : '';  
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + rfiOrRfq + finalRecipients + ' ' + finalMessage);                      
                }
                
                // DECLINE notification logic - include location in message
                If (oldMap.get(spec.ID).status__c != 'Declined' && spec.status__c == 'Declined') {
                    
                    // parts or omega
                    partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'Declined' : 'OM~Declined';
                    
                    finalMessage = Utils.getMessageInnovationAndLocation(partPath,spec);
                    
                    // recipients - includes innovation PLMs
                    baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c + ',{' + (Id)spec.ownerId__c + '},{' + (id)spec.accountOwnerId__c + '}';
                    if (String.isEmpty(spec.innovation_type__c) == False) {
                        combinedRecipients = baseRecipients + Utils.getInnovationRecipients(spec);
                    } else {
                        combinedRecipients = baseRecipients;
                    }
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // rfi configuration
                    rfiOrRfq = spec.rfiConfiguration__c <> Null ? '- RFI Configuration: ' + spec.rfiConfiguration__c + ' ' : '';  
                    
                    // build decline string
                    if (spec.declineReasonOther__c == Null) {
                        declineMessage = ' DECLINE REASON: ' + spec.declineReason__c;
                    } else {
                        declineMessage = ' DECLINE REASON: ' + spec.declineReason__c + ': ' + spec.declineReasonOther__c;
                    }
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + rfiOrRfq + finalRecipients + ' ' + finalMessage + declineMessage);                   
                }           
                
                // ***** DUAL SOURCE NOTIFICATIONS *****
                
                // Dual Source - AE Source Change Reason notification logic if required
                If (oldMap.get(spec.ID).dsSourceChangedReason__c != spec.dsSourceChangedReason__c) {
                    
                    finalMessage = '***** Source Change Reason Field has changed from ' + oldMap.get(spec.ID).dsSourceChangedReason__c + ' to ' + spec.dsSourceChangedReason__c + ' *****';
                    
                    // recipients - do not include innovation PLMs
                    aeRecipient = spec.accountAEId__c;
                    submitRecipient = spec.CreatedById;
                    combinedRecipients = '{' + aeRecipient + '},{' + submitRecipient + '}';
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ***** DUAL SOURCE ' + finalMessage); 
                }
                
                /** Dual Source - Master Planner notification logic - Path 1
If (oldMap.get(spec.ID).dsStatus__c == 'New' && spec.dsStatus__c == 'Manufacturer Assignment') {

// parts or omega
partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'SA~MA' : 'OM~SA~MA';

finalMessage = Utils.getMessageInnovationOnly(partPath,spec);

// recipients - do not include innovation PLMs
baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
combinedRecipients = baseRecipients;

// clean/remove duplicate recipients
finalRecipients = Utils.cleanRecipients(combinedRecipients);

// second parameter = Id of a group or user or record or 'me'
ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ***** DUAL SOURCE ' + finalMessage);
}
**/
                
                // Dual Source - Master Planner notification logic - Path 2
                If (oldMap.get(spec.ID).dsStatus__c == 'Risk Assessment' && spec.dsStatus__c == 'Manufacturer Assignment') {
                    
                    // parts or omega
                    partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'RA~MA' : 'OM~RA~MA';
                    
                    finalMessage = Utils.getMessageInnovationOnly(partPath,spec);
                    
                    // recipients - do not include innovation PLMs
                    baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
                    combinedRecipients = baseRecipients;
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ***** DUAL SOURCE ' + finalMessage);                   
                }
                
                // Dual Source - Master Planner notification logic - Path 3
                If (oldMap.get(spec.ID).dsStatus__c == 'CM Cost Assessment' && spec.dsStatus__c == 'Manufacturer Assignment') {
                    
                    // parts or omega
                    partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'CA~MA' : 'OM~CA~MA';
                    
                    finalMessage = Utils.getMessageInnovationOnly(partPath,spec);
                    
                    // recipients - do not include innovation PLMs
                    baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
                    combinedRecipients = baseRecipients;
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ***** DUAL SOURCE ' + finalMessage);                        
                }
                
                // Dual Source - QE notification logic - Normal path
                // CSMSF-34 - QE notification now comes after PE approval ... (unless PE already set to approved via WF)
                If (((oldMap.get(spec.ID).dsStatus__c == 'Risk Assessment' && spec.dsStatus__c == 'Risk Assessment') && 
                    (oldmap.get(spec.ID).dsPlantEngineerApproval__c != 'Approved' && spec.dsPlantEngineerApproval__c == 'Approved')) ||
                    (oldMap.get(spec.ID).dsStatus__c == 'Manufacturer Assignment' && spec.dsStatus__c == 'Risk Assessment' && spec.dsPlantEngineerApproval__c == 'Approved')) { 
                //If (oldMap.get(spec.ID).dsStatus__c == 'Manufacturer Assignment' && spec.dsStatus__c == 'Risk Assessment') {
                    
                    // parts or omega
                    partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'Parts' : 'Omega'; 
                    
                    If (partPath == 'Parts') {
                        // Object, 1 = single 2 = dual, tickness change?, old thickness, include QA message?, message
                        partsRiskNotification(spec, 2, False, '', False, ' ***** DUAL SOURCE ');                        
                    }
                    
                    If (partPath == 'Omega') {                        
                        omegaRiskNotification(spec, ' ***** DUAL SOURCE ');
                    }   
                    
                }
                
                // Dual Source - QE notification logic - Path 2
                If (oldMap.get(spec.ID).dsStatus__c == 'CM Cost Assessment' && spec.dsStatus__c == 'Risk Assessment') {
                    
                    // parts or omega
                    partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'Parts' : 'Omega'; 
                    
                    If (partPath == 'Parts') {
                        // Object, 1 = single 2 = dual, tickness change?, old thickness, include QA message?, message
                        partsRiskNotification(spec, 2, False, '', False, ' ***** DUAL SOURCE ');                        
                    }
                    
                    If (partPath == 'Omega') {                        
                        omegaRiskNotification(spec, ' ***** DUAL SOURCE ');
                    }   
                    
                }
                
                // Dual Source - AE notification logic if required
                If ((oldMap.get(spec.ID).dsStatus__c == 'Risk Assessment' && spec.dsStatus__c == 'Risk Assessment') && ( (oldMap.get(spec.ID).dsQualityEngineerApproval__c != 'Reviewed - More Information Required' && spec.dsQualityEngineerApproval__c == 'Reviewed - More Information Required') )) {
                    
                    finalMessage = '***** Reviewed - More Information Required *****';
                    
                    // recipients - do not include innovation PLMs
                    aeRecipient = spec.accountAEId__c;
                    submitRecipient = spec.CreatedById;
                    combinedRecipients = '{' + aeRecipient + '},{' + submitRecipient + '}';
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ***** DUAL SOURCE ' + finalMessage);                                                                                                          
                }
                
                // Dual Source - QE notification logic if required
                If ((oldMap.get(spec.ID).dsStatus__c == 'Risk Assessment' && spec.dsStatus__c == 'Risk Assessment') && ( (oldMap.get(spec.ID).dsQualityEngineerApproval__c != 'Customer Responded - QA to Confirm' && spec.dsQualityEngineerApproval__c == 'Customer Responded - QA to Confirm') )) {
                    
                    // parts or omega
                    partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'Parts' : 'Omega'; 
                    
                    If (partPath == 'Parts') {
                        // Object, 1 = single 2 = dual, tickness change?, old thickness, include QA message?, message
                        partsRiskNotification(spec, 2, False, '', True, ' ***** DUAL SOURCE ');                        
                    }
                    
                    If (partPath == 'Omega') {                        
                        omegaRiskNotification(spec, ' ***** DUAL SOURCE ');
                    }   
                }
                
                // Dual Source - PE notification logic if required by QE - normal path
                // CSMSF-34 PE approval now comes first, before QE approval ... (unless already approved)
                if (oldMap.get(spec.ID).dsStatus__c == 'Manufacturer Assignment' && spec.dsStatus__c == 'Risk Assessment' && spec.dsPlantEngineerApproval__c != 'Approved') {
                //If ((oldMap.get(spec.ID).dsStatus__c == 'Risk Assessment' && spec.dsStatus__c == 'Risk Assessment') && ( (oldMap.get(spec.ID).dsQualityEngineerApproval__c == null && spec.dsQualityEngineerApproval__c == 'Approved - Requires Plant Eng Approval') || (oldMap.get(spec.ID).dsQualityEngineerApproval__c == 'Reviewed - More Information Required' && spec.dsQualityEngineerApproval__c == 'Approved - Requires Plant Eng Approval') )) {
                    
                    // Loop through location list and post to selected loactions
                    location = '';
                    List<String> lstLocations = new List<String>();            
                    lstLocations.clear();
                    if (spec.dslocation__c != null)
                        lstLocations = spec.dsLocation__c.split(';');
                    
                    for (String l : lstLocations) {
                        
                        // parts or omega
                        partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? l : 'OM~PE'; 
                        
                        finalMessage = Utils.getMessageInnovationAndLocationDS(partPath,spec);
                        
                        // recipients - do not include innovation PLMs
                        baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
                        aeRecipient = spec.accountAEId__c;
                        submitRecipient = spec.CreatedById;
                        combinedRecipients = baseRecipients + ',{' + aeRecipient + '},{' + submitRecipient + '}';
                        
                        // clean/remove duplicate recipients
                        finalRecipients = Utils.cleanRecipients(combinedRecipients);
                        
                        // rfi configuration
                        rfiOrRfq = spec.rfiConfiguration__c <> Null ? '- RFI Configuration: ' + spec.rfiConfiguration__c + ' ' : '';  
                        
                        // second parameter = Id of a group or user or record or 'me'
                        ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                                 spec.id, spec.opportunityName__c + ' ' + rfiOrRfq + finalRecipients + ' ***** DUAL SOURCE ' + finalMessage);                                                                        
                    }                                   
                }
                
                // Planner & Finance notification logic - Path 1
                If (oldMap.get(spec.ID).dsStatus__c == 'Risk Assessment' && spec.dsStatus__c == 'CM Cost Assessment') {
                    
                    // parts or omega
                    partPath = getCBGlocation(spec); // CSMSF-23 Is this Corning Bendable Glass (CBG) ?
                    if (String.isEmpty(partPath) == true)
                        partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'RA~CA' : 'OM~RA~CA';
                    else {
                        partPath = 'CBG-RA~CA'; // CSMSF-23
                    }                    
                    finalMessage = Utils.getMessageInnovationAndLocationDS(partPath,spec);
                    
                    // recipients - do not include innovation PLMs
                    baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
                    combinedRecipients = baseRecipients;
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ***** DUAL SOURCE ' + finalMessage);                         
                }
                
                // PLM notification logic - Path 1 - Source 2 TCO
                If (oldMap.get(spec.ID).incrementalTCOS2__c != spec.incrementalTCOS2__c) {
                    
                    // parts or omega
                    partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'CA~PA' : 'OM~CA~PA';
                    
                    finalMessage = '***** Source 2 TCO Field has changed.  *****'; // from ' 
                    //+ oldMap.get(spec.ID).incrementalTCOS2__c 
                    //+ ' to ' 
                    //+ spec.incrementalTCOS2__c 
                    //+ ' *****';
                    
                    // recipients - includes innovation PLMs
                    baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
                    if (String.isEmpty(spec.innovation_type__c) == False) {
                        combinedRecipients = baseRecipients + Utils.getInnovationRecipients(spec);
                    } else {
                        combinedRecipients = baseRecipients;
                    }
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ***** DUAL SOURCE ' + finalMessage);                      
                }
                
                // PLM notification logic - Path 2
                If (oldMap.get(spec.ID).dsStatus__c == 'CM Cost Assessment' && spec.dsStatus__c == 'Cost Assessment Completed') {
                    
                    // parts or omega
                    partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'CA~PA' : 'OM~CA~PA';
                    
                    finalMessage = Utils.getMessageInnovationAndLocationDS(partPath,spec);
                    
                    // recipients - includes innovation PLMs
                    baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
                    if (String.isEmpty(spec.innovation_type__c) == False) {
                        combinedRecipients = baseRecipients + Utils.getInnovationRecipients(spec);
                    } else {
                        combinedRecipients = baseRecipients;
                    }
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ***** DUAL SOURCE ' + finalMessage);                      
                }
                
                // Dual Source - PLM notification logic for Mass Production Check
                If (oldMap.get(spec.ID).dsMassProduction__c == FALSE && spec.dsMassProduction__c == TRUE) {
                    
                    // parts or omega
                    partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'PA~MASS~TRUE' : 'OM~PA~MASS~TRUE'; 
                    
                    finalMessage = Utils.getMessageInnovationAndLocationDS(partPath,spec);
                    
                    // recipients - includes innovation PLMs
                    baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
                    if (String.isEmpty(spec.innovation_type__c) == False) {
                        combinedRecipients = baseRecipients + Utils.getInnovationRecipients(spec);
                    } else {
                        combinedRecipients = baseRecipients;
                    }
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ***** DUAL SOURCE ' + finalMessage);                      
                }
                
                // Dual Source - FINANCE notification logic for plm Acknowledgement
                If (oldMap.get(spec.ID).dsPlmAcknowledgement__c == FALSE && spec.dsPlmAcknowledgement__c == TRUE) {
                    
                    // parts or omega
                    partPath = spec.productLine__c == 'Parts' && spec.isOmega__c == False ? 'PA~PLM~TRUE' : 'OM~PA~PLM~TRUE'; 
                    
                    finalMessage = Utils.getMessageInnovationAndLocationDS(partPath,spec);
                    
                    // recipients - includes innovation PLMs
                    baseRecipients = GGPartsSpecAutoNotifications__c.getValues(partPath).userIdList__c;
                    if (String.isEmpty(spec.innovation_type__c) == False) {
                        combinedRecipients = baseRecipients + Utils.getInnovationRecipients(spec);
                    } else {
                        combinedRecipients = baseRecipients;
                    }
                    
                    // clean/remove duplicate recipients
                    finalRecipients = Utils.cleanRecipients(combinedRecipients);
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ***** DUAL SOURCE ' + finalMessage);                      
                }
                
                // ***** END DUAL SOURCE NOTIFICATIONS *****
                
            }
            
            
            // ***** RAW GLASS LOGIC *****
            if (spec.productLine__c == 'Raw Glass') { 
                
                // Demand Ops notification logic
                If (oldMap.get(spec.ID).status__c == 'New' && spec.status__c == 'Supply, Allocation, and Inventory Review') {
                    If (spec.mtoNotificationPath__c == 'Path 1') {
                        finalMessage = GGMTOSpecAutoNotifications__c.getValues('P1~N~SAIR').message__c;
                        finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P1~N~SAIR').userIdList__c;
                    } else if (spec.mtoNotificationPath__c == 'Path 2') {
                        finalMessage = GGMTOSpecAutoNotifications__c.getValues('P2~N~SAIR').message__c;
                        finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P2~N~SAIR').userIdList__c;                    
                    } 
                    
                    //Check Apprication Engineer
                    if(spec.Application_Engineer__c != NULL){
                        finalRecipients += ',{' + spec.Application_Engineer__c + '}';
                    }                                                                              
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ' + finalMessage);
                }
                
                // Product Engineering notification logic
                If (oldMap.get(spec.ID).status__c == 'Supply, Allocation, and Inventory Review' && spec.status__c == 'Product Engineering Input') {
                    If (spec.mtoNotificationPath__c == 'Path 1') {
                        finalMessage = GGMTOSpecAutoNotifications__c.getValues('P1~SAIR~PREI').message__c;
                        finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P1~SAIR~PREI').userIdList__c;
                    } else if (spec.mtoNotificationPath__c == 'Path 2') {
                        finalMessage = GGMTOSpecAutoNotifications__c.getValues('P2~SAIR~PREI').message__c;
                        finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P2~SAIR~PREI').userIdList__c;                    
                    }
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ' + finalMessage);
                }
                
                // Plant Engineering notification logic
                If (oldMap.get(spec.ID).status__c == 'Product Engineering Input' && spec.status__c == 'Plant Engineering Input') {
                    If (spec.mtoNotificationPath__c == 'Path 1') {
                        finalMessage = GGMTOSpecAutoNotifications__c.getValues('P1~PREI~PLEI').message__c;
                        finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P1~PREI~PLEI').userIdList__c;
                    } else if (spec.mtoNotificationPath__c == 'Path 2') {
                        finalMessage = GGMTOSpecAutoNotifications__c.getValues('P2~PREI~PLEI').message__c;
                        finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P2~PREI~PLEI').userIdList__c;                    
                    }
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ' + finalMessage);                   
                }
                
                // Supply Chain notification logic
                If (oldMap.get(spec.ID).status__c == 'Plant Engineering Input' && spec.status__c == 'Supply Chain Input') {
                    If (spec.mtoNotificationPath__c == 'Path 1') {
                        finalMessage = GGMTOSpecAutoNotifications__c.getValues('P1~PLEI~SCI').message__c;
                        finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P1~PLEI~SCI').userIdList__c;
                    } else if (spec.mtoNotificationPath__c == 'Path 2') {
                        finalMessage = GGMTOSpecAutoNotifications__c.getValues('P2~PLEI~SCI').message__c;
                        finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P2~PLEI~SCI').userIdList__c;                    
                    }
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ' + finalMessage);                        
                }                
                
                // PLM Pricing notification logic
                If (oldMap.get(spec.ID).status__c == 'Supply Chain Input' && spec.status__c == 'Pricing Assignment') {
                    If (spec.mtoNotificationPath__c == 'Path 1') {    
                        finalMessage = GGMTOSpecAutoNotifications__c.getValues('P1~SCI~PA').message__c;
                        finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P1~SCI~PA').userIdList__c;
                    } else if (spec.mtoNotificationPath__c == 'Path 2') {
                        finalMessage = GGMTOSpecAutoNotifications__c.getValues('P2~SCI~PA').message__c;
                        finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P2~SCI~PA').userIdList__c;                    
                    }
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ' + finalMessage);                         
                }
                
                // PLM Pricing notification logic - alt path - inventory
                If (oldMap.get(spec.ID).status__c == 'Supply, Allocation, and Inventory Review' && spec.status__c == 'Pricing Assignment') {
                    If (spec.mtoNotificationPath__c == 'Path 1') {    
                        finalMessage = GGMTOSpecAutoNotifications__c.getValues('P1~SAIR~PA').message__c;
                        finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P1~SAIR~PA').userIdList__c;
                    } else if (spec.mtoNotificationPath__c == 'Path 2') {
                        finalMessage = GGMTOSpecAutoNotifications__c.getValues('P2~SAIR~PA').message__c;
                        finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P2~SAIR~PA').userIdList__c;                    
                    }
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ' + finalMessage);                         
                }
                
                // PLM notification logic
                If (oldMap.get(spec.ID).status__c == 'Pricing Assignment' && spec.status__c == 'Business Case Finalization') {
                    If (spec.mtoNotificationPath__c == 'Path 1') {
                        finalMessage = GGMTOSpecAutoNotifications__c.getValues('P1~PA~BCF').message__c;
                        finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P1~PA~BCF').userIdList__c;
                    } else if (spec.mtoNotificationPath__c == 'Path 2') {
                        finalMessage = GGMTOSpecAutoNotifications__c.getValues('P2~PA~BCF').message__c;
                        finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P2~PA~BCF').userIdList__c;                    
                    }
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ' + finalMessage);                      
                }
                
                
                
                if (spec.RecordTypeId == '0121J000001MNl7' || spec.RecordTypeId == '0121J000001MNl6') {// Raw Glass - Inventory 
                    If (oldMap.get(spec.ID).status__c == 'Business Case Finalization' && spec.status__c == 'Commercial/Ops Review') {
                        finalMessage = GGMTOSpecAutoNotifications__c.getValues('INV~BCF~COR').message__c;
                        finalRecipients = GGMTOSpecAutoNotifications__c.getValues('INV~BCF~COR').userIdList__c;
                        
                        // second parameter = Id of a group or user or record or 'me'
                        ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                                 spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ' + finalMessage);                   
                    }
                    
                    //Add the Process that chack when the Status is Changed form 'Business Case Finalization' To 'Finance Review'.
                    //This only runs for the Raw Glass 
                }else {
                    If (oldMap.get(spec.ID).status__c == 'Business Case Finalization' && spec.status__c == 'Finance Review') {
                        If (spec.mtoNotificationPath__c == 'Path 1') {
                            finalMessage = GGMTOSpecAutoNotifications__c.getValues('P1~BCF~FR').message__c;
                            finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P1~BCF~FR').userIdList__c;
                        } else if (spec.mtoNotificationPath__c == 'Path 2') {
                            finalMessage = GGMTOSpecAutoNotifications__c.getValues('P2~BCF~FR').message__c;
                            finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P2~BCF~FR').userIdList__c;                        
                        }
                        
                        // second parameter = Id of a group or user or record or 'me'
                        ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                                 spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ' + finalMessage);                   
                    } 
                    
                    //Add the Process that chack when the Status is Changed form 'Finance Review' To 'Commercial/Ops Review'.
                    If (oldMap.get(spec.ID).status__c == 'Finance Review' && spec.status__c == 'Commercial/Ops Review') {
                        If (spec.mtoNotificationPath__c == 'Path 1') {
                            finalMessage = GGMTOSpecAutoNotifications__c.getValues('P1~FR~COR').message__c;
                            finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P1~FR~COR').userIdList__c;
                        } else if (spec.mtoNotificationPath__c == 'Path 2') {
                            finalMessage = GGMTOSpecAutoNotifications__c.getValues('P2~FR~COR').message__c;
                            finalRecipients = GGMTOSpecAutoNotifications__c.getValues('P2~FR~COR').userIdList__c;                        
                        }
                        
                        // second parameter = Id of a group or user or record or 'me'
                        ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                                 spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ' + finalMessage);                   
                    }
                }
                
                // Commercial/Ops Approval notification logic
                // Single notification if inventory, otherwise handle as designed
                // spec.RecordTypeId == '0121J000000U1co' is the normal MTO path
                boolean isStatusChange = spec.status__c != oldMap.get(spec.ID).status__c;
                
                If (isStatusChange && (((spec.status__c == 'Commercial/Ops Review' && (spec.RecordTypeId == '0121J000000U1co' || spec.RecordTypeId == '0121J000001MNl6'))) 
                                       || spec.status__c == 'Pricing Approved')) {
                                           
                                           Set<String> finalRecepientsSet = new Set<String>();
                                           finalRecepientsSet = getPreviouslyOwnerUserSet(spec);
                                           Boolean isApproved = false;
                                           
                                           If (oldMap.get(spec.ID).commercialApproval__c == False && spec.commercialApproval__c == True) {
                                               finalRecepientsSet.addAll(getUserIds('FINAL~CA'));
                                               isApproved = true;
                                           } 
                                           
                                           If (oldMap.get(spec.ID).operationalApproval__c == False && spec.operationalApproval__c == True) {
                                               finalRecepientsSet.addAll(getUserIds('FINAL~OA'));
                                               isApproved = true;
                                               
                                           } 
                                           
                                           If (oldMap.get(spec.ID).mtoReview__c == null && spec.mtoReview__c == 'Approved') {
                                               finalRecepientsSet.addAll(getUserIds('FINAL~DA'));
                                               isApproved = true;                            
                                               
                                           } 
                                           
                                           if(isApproved){
                                               finalMessage = GGMTOSpecAutoNotifications__c.getValues('FINAL~DA').message__c;
                                               //Relace Spec Id.
                                               finalMessage = finalMessage.replaceAll('XXXX', spec.Name);
                                               
                                               finalRecipients = getAllPreviousStageUserList(finalRecepientsSet);
                                               
                                               // second parameter = Id of a group or user or record or 'me'
                                               ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                                                        spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ' + finalMessage);
                                           }                                                        
                                       }    
                
                // DECLINE notification logic
                If (oldMap.get(spec.ID).status__c != 'Declined' && spec.status__c == 'Declined') {
                    finalMessage = GGMTOSpecAutoNotifications__c.getValues('Declined').message__c;
                    finalRecipients = GGMTOSpecAutoNotifications__c.getValues('Declined').userIdList__c + ',{' + (Id)spec.ownerId__c + '},{' + (id)spec.accountOwnerId__c + '}';
                    
                    // build decline string
                    if (spec.declineReasonOther__c == Null) {
                        declineMessage = ' DECLINE REASON: ' + spec.declineReason__c;
                    } else {
                        declineMessage = ' DECLINE REASON: ' + spec.declineReason__c + ': ' + spec.declineReasonOther__c;
                    }
                    
                    // second parameter = Id of a group or user or record or 'me'
                    ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                             spec.id, spec.opportunityName__c + ' ' + finalRecipients + ' ' + finalMessage + declineMessage);                   
                }
                
            }
        } 
    }
    
    //Function to get the all notification user list from the Custom Setting
    private static String getAllPreviousStageUserList(Set<String> finalRecepientsSet){
        
        String finalRecipients = '';
        
        List<String> finalRecepientsList = new List<String>(finalRecepientsSet);
        finalRecipients = String.join(finalRecepientsList, ',');
        return finalRecipients;
    }
    
    //Function to get the set of user list that are prevoiusly Owed stages.
    private static Set<String> getPreviouslyOwnerUserSet(specification__c spec){
        Set<String> finalRecepientsSet = new Set<String>();
        
        finalRecepientsSet.add('{' + spec.ownerId__c + '}');
        if(spec.Application_Engineer__c != NULL)
            finalRecepientsSet.add('{' + spec.Application_Engineer__c + '}');
        
        If (spec.mtoNotificationPath__c == 'Path 1') {
            //'New' to 'Supply, Allocation, and Inventory Review'
            finalRecepientsSet.addAll(getUserIds('P1~N~SAIR'));
            
            //'Supply, Allocation, and Inventory Review' to 'Product Engineering Input'
            finalRecepientsSet.addAll(getUserIds('P1~SAIR~PREI'));
            
            //'Product Engineering Input' To 'Plant Engineering Input'
            finalRecepientsSet.addAll(getUserIds('P1~PREI~PLEI'));
            
            //'Plant Engineering Input' To 'Supply Chain Input'
            finalRecepientsSet.addAll(getUserIds('P1~PLEI~SCI'));
            
            //'Supply Chain Input' To 'Pricing Assignment'
            finalRecepientsSet.addAll(getUserIds('P1~SCI~PA'));
            
            //'Supply, Allocation, and Inventory Review' To 'Pricing Assignment'
            finalRecepientsSet.addAll(getUserIds('P1~SAIR~PA'));
            
            //'Pricing Assignment' To 'Business Case Finalization'
            finalRecepientsSet.addAll(getUserIds('P1~PA~BCF'));
            
        } else if (spec.mtoNotificationPath__c == 'Path 2') {
            finalRecepientsSet.addAll(getUserIds('P2~N~SAIR'));  
            
            //'Supply, Allocation, and Inventory Review' to 'Product Engineering Input'
            finalRecepientsSet.addAll(getUserIds('P2~SAIR~PREI'));          
            
            //'Product Engineering Input' To 'Plant Engineering Input'   
            finalRecepientsSet.addAll(getUserIds('P2~PREI~PLEI')); 
            
            //'Plant Engineering Input' To 'Supply Chain Input'     
            finalRecepientsSet.addAll(getUserIds('P2~PLEI~SCI'));
            
            //'Supply Chain Input' To 'Pricing Assignment'
            finalRecepientsSet.addAll(getUserIds('P2~SCI~PA'));  
            
            //'Supply, Allocation, and Inventory Review' To 'Pricing Assignment'  
            finalRecepientsSet.addAll(getUserIds('P2~SAIR~PA')); 
            
            //'Pricing Assignment' To 'Business Case Finalization'
            finalRecepientsSet.addAll(getUserIds('P2~PA~BCF')); 
        }
        
        //'Business Case Finalization' To 'Commercial/Ops Review'
        if (spec.RecordTypeId == '0121J000001MNl7' || spec.RecordTypeId == '0121J000001MNl6') {// Raw Glass - Inventory      
            finalRecepientsSet.addAll(getUserIds('INV~BCF~COR'));
        }else{
            If (spec.mtoNotificationPath__c == 'Path 1') {
                //'Business Case Finalization' To 'Finance Review'
                finalRecepientsSet.addAll(getUserIds('P1~BCF~FR'));
                
                //'Finance Review' To 'Commercial/Ops Review'
                finalRecepientsSet.addAll(getUserIds('P1~FR-COR'));
                
            } else if (spec.mtoNotificationPath__c == 'Path 2') {
                //'Business Case Finalization' To 'Finance Review'
                finalRecepientsSet.addAll(getUserIds('P2~BCF~FR'));
                
                //'Finance Review' To 'Commercial/Ops Review'  
                finalRecepientsSet.addAll(getUserIds('P2~FR-COR'));                      
            }
        }
        
        return finalRecepientsSet;
    }
    
    private static List<String> getUserIds(String customSettingName){
        try{
            if(GGMTOSpecAutoNotifications__c.getValues(customSettingName) != NULL){
                if(GGMTOSpecAutoNotifications__c.getValues(customSettingName).userIdList__c != NULL){
                    return GGMTOSpecAutoNotifications__c.getValues(customSettingName).userIdList__c.split(',');
                }
            }
        }catch(Exception e){}
        return new List<String>();
    }
    
    private static void partsRiskNotification(specification__c spec, Integer source, Boolean thickChange, String oldThickness, Boolean qaComm, String message) {
        Utilities Utils = new Utilities();
        String finalMessage = '';
        String qaMessage = '';
        String rfiOrRfq = '';
        String baseRecipients = '';
        ID aeRecipient;
        ID submitRecipient;
        String combinedRecipients = '';
        String finalRecipients = '';
        String location = '';        
        
        List<String> lstLocations = new List<String>();            
        lstLocations.clear();
        if(spec.location__c != null || spec.dsLocation__c != null){
            if (source == 2) {
                lstLocations = spec.dsLocation__c.split(';');
            } else {
                lstLocations = spec.location__c.split(';');
            }    
        }     

        // Loop through location list and post to selected locations
        for (String l : lstLocations) {
            location = 'MA~RA~Default'; // set default - location added to list but not this code
            if (l == 'Fuzhou') { location = 'MA~RA~Fuzhou';}
            if (l == 'Jiangmen') { location = 'MA~RA~Jiangmen';}
            if (l == 'Biel') { location = 'MA~RA~Biel';}
            if (l == 'BOE') { location = 'MA~RA~BOE';}
            if (l == 'Crystal') { location = 'MA~RA~Crystal';}
            if (l == 'GTOC') { location = 'MA~RA~GTOC';}
            if (l == 'HDC') { location = 'MA~RA~HDC';}
            if (l == 'Hony') { location = 'MA~RA~Hony';}
            if (l == 'Huaqing') { location = 'MA~RA~Huaqing';}
            if (l == 'Kaymao') { location = 'MA~RA~Kaymao';}
            if (l == 'LOT') { location = 'MA~RA~LOT';}
            if (l == 'NVD') { location = 'MA~RA~NVD';}
            if (l == 'Opton') { location = 'MA~RA~Opton';}
            if (l == 'RLD') { location = 'MA~RA~RLD';}
            if (l == 'Victory') { location = 'MA~RA~Victory';}
            if (l == 'WTL') { location = 'MA~RA~WTL';}
            if (l == 'Xingxing') { location = 'MA~RA~Xingxing';}
            if (l == 'YTF') { location = 'MA~RA~YTF';}
            if (l == 'J3D') { location = 'MA~RA~J3D';}
            if (l == 'HTF') { location = 'MA~RA~HTF';}
            if (l == 'Shinwu') { location = 'MA~RA~Shinwu';}
            if (l == 'CPM') { location = 'MA~RA~CPM';}
            if (l == 'CGK-TQ') { location = 'MA~RA~CGK-TQ';}
            if (l == 'BYD-TQ') { location = 'MA~RA~BYD-TQ';}
            if (l == 'TPK-TQ') { location = 'MA~RA~TPK-TQ';}
            if (l == 'GO') { location = 'MA~RA~GO';}
            if (l == 'RKL-TQ') { location = 'MA~RA~RKL-TQ';}
            if (l == 'TG-NT') { location = 'MA~RA~TG-NT';}
            if (l == 'Truly') { location = 'MA~RA~Truly';}
            if (l == 'DSBJ') { location = 'MA~RA~DSBJ';}
            if (l == 'NGS-TQ') { location = 'MA~RA~NGS-TQ';}
            if (l == 'MFD-TQ') { location = 'MA~RA~MFD-TQ';}
            if (l == 'LENS-TQ') { location = 'MA~RA~LENS-TQ';}
            if (l == 'YX-TQ') { location = 'MA~RA~YX-TQ';}
            if (l == 'KLOT-TQ') { location = 'MA~RA~KLOT-TQ';} 
            if (l == 'KOTL-TQ') { location = 'MA~RA~KOTL-TQ';}                        
            if (l == 'XX 3D') { location = 'MA~RA~XX DG-TQ';}
            if (l == 'XX TZ') { location = 'MA~RA~XX TZ';}
            if (l == 'ROE-TQ') { location = 'MA~RA~ROE-TQ';}            
            if (l == 'HH-LowR') { location = 'MA~RA~HH-LowR';}
            if (l == 'SK-TQ') { location = 'MA~RA~SK-TQ';}
            if (l == 'CGK') { location = 'MA~RA~CGK';}
            if (l == 'NGS') { location = 'MA~RA~NGS';}            
            if (l == 'RKL') { location = 'MA~RA~RKL';}
            if (l == 'TG') { location = 'MA~RA~TG';}
            if (l == 'GIS') { location = 'MA~RA~GIS-TQ';}
            if (l == 'XC') { location = 'MA~RA~XC-TQ';}
            if (l == 'LCE-LR') { location = 'MA~RA~LCE-LR';}
            if (l == 'JNTC-TQ') { location = 'JNTC-TQ-QA';}
            if (l == 'Liangcheng-LR') { location = 'Liangcheng-QA';}
            if (l == 'HLF-LR') { location = 'HLF-QA';}  // next line replaces this, but let's keep backwards compatibility
            if (l == 'HLF') { location = 'HLF-QA';}
            if (l == 'Ample') { location = 'Ample-QA';}
            if (l == 'Jingzhuo') { location = 'Jingzhuo-QA';}
            if (l == 'Econy') { location = 'Econy-QA';}
            if (l == 'Phoenix') { location = 'Phoenix-QA';}
           
            
            if (source == 2) {
                finalMessage = Utils.getMessageInnovationAndLocationDS(location,spec);
            } else {
                finalMessage = Utils.getMessageInnovationAndLocation(location,spec);
            }
            
            if (qaComm == TRUE) {
                qaMessage = ' ' + spec.qualityEngineerApproval__c;
            }
            
            // recipients - do not include innovation PLMs
            baseRecipients = GGPartsSpecAutoNotifications__c.getValues(location).userIdList__c;
            aeRecipient = spec.accountAEId__c;
            submitRecipient = spec.CreatedById;
            combinedRecipients = baseRecipients + ',{' + aeRecipient + '},{' + submitRecipient + '}';
            
            // an - 2/20/18 - add additional users when spec contains innovation
            if (spec.isInnovation__c == TRUE) {
                combinedRecipients = combinedRecipients + ',' + GGPartsSpecAutoNotifications__c.getValues('RA~With~Innovation').userIdList__c;
            }
            
            if (thickChange == TRUE) {
                finalMessage = '***** Thickness change from ' + oldThickness + ' to ' + spec.thickness__c + ' *****';
                combinedRecipients = combinedRecipients + ',' + GGPartsSpecAutoNotifications__c.getValues('RA~Thickness~Change').userIdList__c;           
            }
            
            // clean/remove duplicate recipients
            finalRecipients = Utils.cleanRecipients(combinedRecipients);    
            // rfi configuration
            rfiOrRfq = spec.rfiConfiguration__c <> Null ? '- RFI Configuration: ' + spec.rfiConfiguration__c + ' ' : '';  
            
            // second parameter = Id of a group or user or record or 'me'
            ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                     spec.id, spec.opportunityName__c + ' ' + rfiOrRfq + finalRecipients + message + finalMessage + qaMessage);                                                                             
        }
        
    }
    
    private static void omegaRiskNotification(specification__c spec, String message) {
        Utilities Utils = new Utilities();
        
        String finalMessage;
        String baseRecipients;
        String combinedRecipients;
        String finalRecipients;      
        
        finalMessage = Utils.getMessageInnovationAndLocation('OM~MA~RA',spec);
        
        // recipients - do not include innovation PLMs
        baseRecipients = GGPartsSpecAutoNotifications__c.getValues('OM~MA~RA').userIdList__c;
        combinedRecipients = baseRecipients;
        
        // clean/remove duplicate recipients
        finalRecipients = Utils.cleanRecipients(combinedRecipients);
        
        // second parameter = Id of a group or user or record or 'me'
        ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithMentions(Network.getNetworkId(), 
                                                                                                 spec.id, spec.opportunityName__c + ' ' + finalRecipients + message + finalMessage);                         
        
    }
    
    public Static Void unFollowSpecification(List<Specification__c> speclist) {
        
        Set<Id> unfollowSet = new Set<Id>();
        
        // pricing approved is always the final value for all approved specs - all product lines
        for(specification__c spec : speclist) {   
            if (spec.status__c == 'Declined' || spec.status__c == 'Pricing Approved') {
                unfollowSet.add(spec.Id);
            }
        }
        
        if(unfollowSet.size() > 0) {
            try {
                List<EntitySubscription> removals = new List<EntitySubscription>();
                removals = [SELECT Id FROM EntitySubscription WHERE ParentId IN : unfollowSet];
                if(!removals.isEmpty()){
                    delete removals ;
                }
            } catch( Exception ex ) {
                system.debug('Exception: ' + ex.getMessage());
            }
        }
    }
    
    public Static Void followSpecification( List<Specification__c> speclist ) {
        
        // list for EntitySubscriptions to insert
        List<EntitySubscription> subscriptionList = new List <EntitySubscription>();
        
        for (specification__c s:speclist) {
            
            if (s.productLine__c == 'Parts' && s.status__c == 'Missing Information Assessment' || s.productLine__c == 'Raw Glass' && s.status__c == 'Supply, Allocation, and Inventory Review') {
                
                // always add the opportunity owner
                subscriptionList.add(New EntitySubscription(ParentId = s.Id, SubscriberId = String.valueOf(s.ownerId__c).substring(0, 15)));
                
                // add the user that created the specification (if not opportunity owner)
                if (String.valueOf(s.ownerId__c).substring(0, 15) != String.valueOf(s.createdById).substring(0, 15)) {
                    subscriptionList.add(New EntitySubscription(ParentId = s.Id, SubscriberId = String.valueOf(s.createdById).substring(0, 15)));
                }
                
                // add the AE from the opportunity account mapping if not already added to Subscription List
                if (s.accountAEId__c != NULL) {
                    if (String.valueOf(s.accountAEId__c).substring(0, 15) != String.valueOf(s.ownerId__c).substring(0, 15) && String.valueOf(s.accountAEId__c).substring(0, 15) != String.valueOf(s.createdById).substring(0, 15)) {
                        subscriptionList.add(New EntitySubscription(ParentId = s.Id, SubscriberId = String.valueOf(s.accountAEId__c).substring(0, 15)));
                    }
                }              
            }    
        }
        
        Database.SaveResult[] srList = Database.insert(subscriptionList, false);
        
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted EntitySubscription. EntitySubscription ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('EntitySubscription fields that affected this error: ' + err.getFields());
                }
            }
        }
        
    }
    // CSMSF-23 - See if Corning Bendable Glass is set as a innovation type.  If so, return the custom setting location
    //            for the Risk Mangement PE owner ...
    private Static String getCBGlocation(specification__c spec) {
        if (spec.Innovation_Type__c != null) {
            for (String s : spec.Innovation_Type__c.split(';')) {
                if ( s == 'Corning Bendable Glass') {
                    return 'Ample';
                }
            }
        }
        return '';
    }  
}