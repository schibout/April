/**
 * @author Comforth dev team
 * @date 17/12/2020
 * @group
 * @description EmailMessage Management Class
 * 
 */
public with sharing class SM002_EmailMessage{

    /**
     * @author Comforth dev team
     * @date 17/12/2020
     * 
     * Changelog: 
     *  - MTK 29/11/2021: code refactoring : bulkification + improve code quality
     *  - MTK 30/11/2021: add Incoming Email Message Rules
     */
    public static void copyClosedCase(List<EmailMessage> listEmailMessage) { // todo: method name should be changed, the method is doing more than 'copyClosedCase'

        // filtering incoming messages related to cases
        final List<EmailMessage> relatedToCaseIncomingEmailMessages = new List<EmailMessage>();
       // if(listEmailMessage != null && !listEmailMessage.isEmpty()) {
            for (EmailMessage emailMessageSo : listEmailMessage) { 
                System.Debug('emailMessageSo.ParentId: ' + emailMessageSo.ParentId);
                if ( emailMessageSo.ParentId != null && 
                    emailMessageSo.ParentId.getSObjectType() == Case.sObjectType 
                    && emailMessageSo.Incoming
                ) {
                    relatedToCaseIncomingEmailMessages.add(emailMessageSo);
                } 
        	}
      //  }

        if (!relatedToCaseIncomingEmailMessages.isEmpty()) { // if there is incoming messages related to cases

            // select queues by developerName
            final Map<String, Id> queueIdByDeveloperName = new Map<String, Id>();
            for (Group queue : [
                SELECT id, DeveloperName
                FROM GROUP
                WHERE Type = 'Queue'
            ]){
                queueIdByDeveloperName.put(queue.DeveloperName, queue.Id);
            }
    
            final Set<Id> caseParentIds = new Set<Id>();
            final Set<String> fromAddresses = new Set<String>();
            for (EmailMessage emailMessageSo : relatedToCaseIncomingEmailMessages) {
                if (emailMessageSo.ParentId != null) caseParentIds.add(emailMessageSo.ParentId);
                if (emailMessageSo.FromAddress != null) fromAddresses.add(emailMessageSo.FromAddress);
            }

            // select parent cases
            final Map<Id, Case> caseById = new Map<Id,Case>([
                SELECT id, Origin, NewMailInMailBox__c, subject, NewTaskCompleted__c, Policy__c, Type, status, description, 
                    parentid, RecordTypeId, OwnerId, Owner.Name, ContactID, AccountID, ContactEmail, Country__c,  
                    TECH_Qualification_Determinant__c, RecordType.Name, MemberUniqueID__c, Member__c, SenderEmail__c
                FROM Case
                WHERE id IN :caseParentIds
            ]);          

            
            // select outComming email messages senders
            final Map<Id, String> lastOutcomingEmailSnderByParentCaseId = new Map<Id, String>();
            for (EmailMessage outcomingEmailMessage : [
                SELECT Id, FromAddress, Incoming, RelatedToId
                FROM EmailMessage
                WHERE RelatedToId IN: caseParentIds
                    AND Incoming = false
                ORDER BY CreatedDate DESC
            ]) {
                if (!lastOutcomingEmailSnderByParentCaseId.containsKey(outcomingEmailMessage.RelatedToId)) {
                    lastOutcomingEmailSnderByParentCaseId.put(outcomingEmailMessage.RelatedToId, outcomingEmailMessage.FromAddress);
                }
            }

            // select case qualification settings 
            final Set<String> vipFromAdresses = new Set<String>();
            final Map<String, Case_Qualification_Setting__c> caseQualificationSettingByMailbox = new Map<String, Case_Qualification_Setting__c>();
            final Set<String> lastOutcomingEmailSndersSet = new Set<String>(lastOutcomingEmailSnderByParentCaseId.values());
            for (Case_Qualification_Setting__c caseQualificationSetting: [
                SELECT id, Sender__c, Mailbox__c, Name, OwnerId, Case_Record_Type__c, Case_Queue__c
                FROM Case_Qualification_Setting__c
                WHERE Sender__c IN :fromAddresses
                    OR Mailbox__c IN :lastOutcomingEmailSndersSet
            ]) {
                if (fromAddresses.contains(caseQualificationSetting.Sender__c)) {
                    vipFromAdresses.add(caseQualificationSetting.Sender__c);
                }
                if (!caseQualificationSettingByMailbox.containsKey(caseQualificationSetting.Mailbox__c)) {
                    caseQualificationSettingByMailbox.put(caseQualificationSetting.Mailbox__c, caseQualificationSetting);
                }
            }

            final List<IncomingEmailMessageRule__mdt> incomingEmailMessageRules = IncomingEmailMessageRule__mdt.getAll().values(); // replace by SOQL and select only needed lines if number of lines become big
            final List<Case> casesToUpsert = new List<Case>();
            
            for (EmailMessage emailMessageSo : relatedToCaseIncomingEmailMessages) {
                
                final Case initialCase = caseById.get(emailMessageSo.ParentId);
    
                Case caseToUpsert = null;
                Boolean doNotSetVipRecordType = false;
                if (initialCase.Status == 'Closed') {
                    caseToUpsert = initialCase.clone();
                    caseToUpsert.parentid = initialCase.id;
                    caseToUpsert.Origin = 'Email';
                    caseToUpsert.Priority = 'TBC';
                    caseToUpsert.NewTaskCompleted__c = false;
                    caseToUpsert.Status = 'New';
                    if (String.isNotBlank(initialCase.Country__c)) {
                        caseToUpsert.Country__c = initialCase.Country__c;
                    }
                    if (emailMessageSo.TextBody.length() > 32000){
                        caseToUpsert.Description= emailMessageSo.TextBody.substring(0, 32000);
                    } else {
                        caseToUpsert.Description= emailMessageSo.TextBody;
                    }
                    final Case_Qualification_Setting__c caseQualificationSetting = caseQualificationSettingByMailbox.get(
                        lastOutcomingEmailSnderByParentCaseId.get(initialCase.id)
                    );
                    
                    System.debug('### LLC caseToUpsert.TECH_Qualification_Determinant__c = initialCase.SenderEmail__c: ' + initialCase.SenderEmail__c);
                        
                    if(caseToUpsert.TECH_Qualification_Determinant__c != '') {
                        caseToUpsert.TECH_Qualification_Determinant__c = initialCase.SenderEmail__c;
                    }
                    
                    System.debug('### LLC caseToUpsert.TECH_Qualification_Determinant__c = initialCase.TECH_Qualification_Determinant__c: ' + initialCase.TECH_Qualification_Determinant__c);
                    
                    if(caseToUpsert.TECH_Qualification_Determinant__c != '') {
                        caseToUpsert.TECH_Qualification_Determinant__c = initialCase.TECH_Qualification_Determinant__c;
                    }
                    
                    System.debug('### LLC caseToUpsert.TECH_Qualification_Determinant__c = emailMessageSo.ToAddress: ' + emailMessageSo.ToAddress);
                    
                    if(caseToUpsert.TECH_Qualification_Determinant__c != '') {
                        caseToUpsert.TECH_Qualification_Determinant__c = emailMessageSo.ToAddress;
                    }
                    
                    if (caseQualificationSetting != null) { // (caseQualificationSetting != null) => is Determinant Valid
                        final String newOwnerId = queueIdByDeveloperName.get(caseQualificationSetting.Case_Queue__c);
                        if (newOwnerId != null){
                            caseToUpsert.OwnerId = newOwnerId;
                        }
                        final String newrecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
                            .get(caseQualificationSetting.Case_Record_Type__c)?.getRecordTypeId();
                        if (newrecordtypeId != null) {
                            caseToUpsert.RecordTypeId = newrecordtypeId;
                            doNotSetVipRecordType = true; // todo : regle de gestion à vérifier ? 
                        }
                        
                        System.debug('### LLC caseToUpsert.TECH_Qualification_Determinant__c = caseQualificationSetting.Mailbox__c: ' + caseQualificationSetting.Mailbox__c);
                        
                        if(caseQualificationSetting.Mailbox__c != '') {
                            caseToUpsert.TECH_Qualification_Determinant__c = caseQualificationSetting.Mailbox__c;
                        }
                      
                        caseToUpsert.LastMailEntry__c = DateTime.now(); // todo : à vérifier : pourquoi pas alimenté quand caseQualificationSetting == null ?
                        caseToUpsert.SuppliedEmail = emailMessageSo.FromAddress; // todo : à vérifier : pourquoi pas alimenté quand caseQualificationSetting == null ?
                    
                    }
                } else { // case is not closed
                    caseToUpsert = initialCase;
                    caseToUpsert.LastMailEntry__c = DateTime.now();
                }

                casesToUpsert.add(caseToUpsert);
				caseToUpsert.LastMailEntry__c = DateTime.now();//TKN-10/06/2022
                caseToUpsert.NewMailInMailBox__c = true;

                // apply vip rules
                final boolean isVip = vipFromAdresses.contains(emailMessageSo.FromAddress);
                if (isVip) {
                    final Id gestionDedieeQueueId = queueIdByDeveloperName.get('GestionDediee');
                    if (initialCase.OwnerId == gestionDedieeQueueId && !doNotSetVipRecordType) {
                        caseToUpsert.RecordTypeId = Schema.SObjectType.Case
                            .getRecordTypeInfosByDeveloperName().get('ClaimCase').getRecordTypeId();
                    }

                    caseToUpsert.CaseSubtypeFR__c = 'VIP'; // todo : can generate INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST in case insert
                }

                // provide origin , priority , Case Type, Case Sub-typeFR, ComplaintLevel__c
                final List<IncomingEmailMessageRule__mdt> matchedIncomingEmailMessageRules = matchIncomingEmailMessageRules(incomingEmailMessageRules, initialCase, emailMessageSo);
                
                for(IncomingEmailMessageRule__mdt matchedRule: matchedIncomingEmailMessageRules) {
                    if (String.isNotBlank(matchedRule.CaseOriginToBeDefined__c)) {
                        caseToUpsert.Origin = matchedRule.CaseOriginToBeDefined__c;
                    }
                    if (String.isNotBlank(matchedRule.CasePriorityToBeDefined__c)) {
                        caseToUpsert.Priority = matchedRule.CasePriorityToBeDefined__c;
                    }
					//	TKN-17/02/2022
                    if (String.isNotBlank(matchedRule.Type__c)){
                      caseToUpsert.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(matchedRule.Type__c).getRecordTypeId(); 
                    }
                    if (String.isNotBlank(matchedRule.Subtype__c)){
                       caseToUpsert.CaseSubtypeFR__c = matchedRule.Subtype__c;
                    }
                    //TKN-18/02/2022
                    if(String.isNotBlank(matchedRule.CaseOwner__c)){
                        final String newOwnerId = queueIdByDeveloperName.get(matchedRule.CaseOwner__c);
                        if (newOwnerId != null){
                            caseToUpsert.OwnerId = newOwnerId;
                        }
                    }
                    //LLC-23/02/2023
                    if (String.isNotBlank(matchedRule.Country__c)) {
                        caseToUpsert.Country__c = matchedRule.Country__c;
                    }
                    
 					caseToUpsert.ComplaintLevel__c = matchedRule.Level__c;
                }
            } // for each email message
   			System.debug('casesToUpsert '+ casesToUpsert);
            if (!casesToUpsert.isEmpty()) {
                try {
                    upsert casesToUpsert;
                } catch (DMLException e){
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }
            }
        }
    }

    /**
     * @author MTK
     * @date 30/11/2021
     */
    private static List<IncomingEmailMessageRule__mdt> matchIncomingEmailMessageRules(List<IncomingEmailMessageRule__mdt> rules, Case initialCase, EmailMessage em) {
        final List<IncomingEmailMessageRule__mdt> matchedIncomingEmailMessageRules = new List<IncomingEmailMessageRule__mdt>();

        for (IncomingEmailMessageRule__mdt rule: rules) {
            if (
                (String.isBlank(rule.EmailFromAddress__c) || em.FromAddress == rule.EmailFromAddress__c)
                && (String.isBlank(rule.EmailToAddress__c) || (String.isNotBlank(em.ToAddress) && em.ToAddress.contains(rule.EmailToAddress__c)))
                && (String.isBlank(rule.CaseSubjectContains__c) || (String.isNotBlank(initialCase.Subject) && initialCase.Subject.contains(rule.CaseSubjectContains__c)))
                && !(rule.ExcludeClonedCasesFromClosedCases__c && initialCase.Status == 'Closed')
            ) {
                matchedIncomingEmailMessageRules.add(rule);
            }
        }
        return matchedIncomingEmailMessageRules;
    }
}