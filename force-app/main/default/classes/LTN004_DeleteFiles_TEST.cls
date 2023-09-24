@isTest
public class LTN004_DeleteFiles_TEST {
    static User adminUser = new TestFactory.UserFactory().createRunningUserAdministrator();
    @testSetup static void setup(){
      System.runAs(adminUser){
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

    @isTest   static void testLTN004_DeleteFiles(){ 
      List<Case> listP = [SELECT Id, RecordType.Name, CaseSubtypeFR__c, CaseSubtype__c, ClosedDate , Status   FROM case ];
      List<Id> ListCId = new List<Id>();
      Case c = new case();
      c.status ='Closed';
      c.CaseSubtype__c = 'SPAM';
      insert c ;
      ListCId.add(c.Id);

      List<Id> emId = new  List<Id>();
      EmailMessage em = new EmailMessage();
      em.parentid = c.Id;
      insert em;
      emId.add(em.Id);

      //Create Document
      ContentVersion cv = new ContentVersion();
      cv.Title = 'Test Document';
      cv.PathOnClient = 'TestDocument.pdf';
      cv.VersionData = Blob.valueOf('Test Content');
      cv.IsMajorVersion = true;
      Insert cv; 

     //Get Content Documents
     List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
   
     //create ContentDocumentLink  record 
     ContentDocumentLink cdl = New ContentDocumentLink();
     cdl.LinkedEntityId = emId[0];
     cdl.ContentDocumentId = cdList[0].Id;
     cdl.shareType = 'V';
     insert cdl;

     List<ContentDocument> result = new List<ContentDocument>();
      ContentDocumentLink cdls =[
      SELECT ContentDocument.Id, ContentDocument.Title, ContentDocument.CreatedDate, ContentDocument.ContentSize, ContentDocument.LastReferencedDate, ContentDocument.Owner.Name,  ContentDocument.OwnerId, ContentDocument.CREATEDBY.name
      FROM ContentDocumentLink 
      WHERE LinkedEntityId IN: emId 
      ];
      result.add(cdl.ContentDocument);
         
      Test.StartTest();
      System.runAs(adminUser){
       List<ContentDocument> resultss = new List<ContentDocument>();
       resultss = LTN004_DeleteFiles.retreiveCaseFilesInformation (ListCId[0]);
       LTN004_DeleteFiles.deleteContentDocument (cdList[0].Id);
       } 
        Test.stopTest();
   }
}