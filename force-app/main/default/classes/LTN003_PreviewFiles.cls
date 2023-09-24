public with sharing class LTN003_PreviewFiles {

        @AuraEnabled(cacheable=true)
        public static PreviewFileResult retrieveContentDocumentsIdsFromCase(Id caseId){

            NumberOfFiles__c cs = NumberOfFiles__c.getOrgDefaults();
            if(Test.isRunningTest()){
                cs.Number__c = 100;
            }

            List<String> listContentDocumentIds = new List<String>();
            Map<Id,EmailMessage> listEmail = new Map<Id,EmailMessage>([SELECT Id FROM EmailMessage WHERE ParentId =: caseId]);
            PreviewFileResult resultat = new PreviewFileResult();
            System.debug('cs.Number : ' + cs.Number__c);

            if(cs != null  && cs.Number__c != null){
                Integer nbFiles = Integer.valueof(cs.Number__c);
                if(listEmail != null && listEmail.size() > 0){
                    for(ContentDocumentLink cdl : [SELECT Id,ContentDocumentId,ContentDocument.CreatedDate, ContentDocument.ContentSize FROM ContentDocumentLink WHERE LinkedEntityId IN: listEmail.keyset() OR LinkedEntityId =: caseId Order BY  ContentDocument.CreatedDate desc, ContentDocument.ContentSize desc LIMIT: nbFiles]){
                        listContentDocumentIds.add(cdl.ContentDocumentId);
                    }
                }else{
                    for(ContentDocumentLink cdl : [SELECT Id,ContentDocumentId,ContentDocument.CreatedDate, ContentDocument.ContentSize FROM ContentDocumentLink WHERE LinkedEntityId =: caseId Order BY  ContentDocument.CreatedDate desc, ContentDocument.ContentSize desc ]){
                        listContentDocumentIds.add(cdl.ContentDocumentId);
                    }
                }  
            }
            

            if(listContentDocumentIds.size() > 0) {
                String listIdContentDocumentString = String.join(listContentDocumentIds , ',');
                System.debug(listContentDocumentIds.get(0));
                //resultat = new PreviewFileResult(listIdContentDocumentString, listContentDocumentIds.get(0));
                resultat.recordIds = listIdContentDocumentString;
                resultat.selectedRecordId = listContentDocumentIds.get(0);
            }
            // else {
              //  resultat.recordIds = null;
              //  resultat.selectedRecordId = null;


            // }

            System.debug(resultat);
            return resultat;
        }

        public class PreviewFileResult {
            @AuraEnabled
            public String recordIds;

            @AuraEnabled
            public String selectedRecordId;
            
        }

    }