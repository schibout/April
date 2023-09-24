@isTest
    public with sharing class LTN003_PreviewFiles_TEST {

    static User adminUser = new TestFactory.UserFactory().createRunningUserAdministrator();
    
    @testSetup static void setup(){
        
         System.runAs(adminUser){
        
        
        //List<String> listContentDocumentIdsTest = new List<String>();
        
            
        
         //Create 1  case
         List<Case> listCase = new List<Case>();
         for(Integer i=0;i<1;i++){
             listCase.add(new TestFactory.CaseFactory().createCase('LOGCaseAsia', 'Email', 'New'));
         }
         insert listCase;
         
		 // Create 5 ContentDocumentLink
		 List<ContentDocumentLink> listCdl = new List<ContentDocumentLink>();
		 for(Integer i=0;i<1;i++){
			listCdl.add(new TestFactory.ContentDocumentLinkFactory().createContentDocumentLink(listCase[0].Id));
             
		 }
         
         insert listCdl;
        
        
         }
    }

    @isTest static void testRetreiveFiles() { 
        
        
	
        System.runAs(adminUser){
            // récuparation des cases ids
           List<Case> caseIds =[SELECT Id from Case];
            system.debug('caseIds ' + caseIds.size());
            
            System.debug('caseId : ' + caseIds[0]);
            
            // Récuperer tous les contentDocumentLink
             ContentDocumentLink cdl =[SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: caseIds[0].Id];
             //System.assertEquals(1, cdlIds.size() );
            
            //List<ContentDocumentLink> cdlIds =[SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: caseId Order BY  ContentDocument.CreatedDate desc, ContentDocument.ContentSize desc];
            //listContentDocumentIds.add(cdlIds.ContentDocumentId);
            //String listIdContentDocumentStringTest = String.join(cdlIds, ',');
            
            Test.StartTest();
            
            // Appel de la méthode à tester
            // 
            
            LTN003_PreviewFiles.PreviewFileResult resultat = LTN003_PreviewFiles.retrieveContentDocumentsIdsFromCase(caseIds[0].Id);
            
            // Vérification des résultats
            //System.assertEquals(listIdContentDocumentStringTest, resultat.recordIds);
            System.assertEquals(cdl.ContentDocumentId, resultat.selectedRecordId);
            
            Test.StopTest();

        }
    }

}