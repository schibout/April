/**
* @author Keshav - Comforth
* @date 2020-05-18
* @modified 2020-05-18
* @group Batch BA001_MassDeleteAttachments
* @object Case
* @description The files to be erased are those that are attached to emails older than X days,
*              Files/attachments that are attached to a case directly (not email attachments) should not be erased.
*/

Global class BA001_MassDeleteAttachments Implements Database.batchable<sobject>, Schedulable{
     global string query;
    
     global Database.QueryLocator start(Database.BatchableContext BC){

          // Get EmailAttachmentDelay__c From Custom setting AprilSettings__c
          AprilSettings__c aprilSetting = AprilSettings__c.getOrgDefaults();
          Integer emailAtt = aprilSetting.EmailAttachmentDelay__c.intValue();

          Date xDate = Date.today().addDays(emailAtt);
          //System.debug('xDate ' + xDate );


          //query = 'SELECT Id FROM Case '; 
          query = 'select id,createddate,HasAttachment, ParentId, TECH_ParentId__c from EmailMessage where TECH_ParentId__c like \'500%\' AND createddate <: xDate' ;  

          //system.debug('query ' + query);

          return Database.getQueryLocator(query);
     }
     global  void execute(Database.BatchableContext BC,List<EmailMessage> scope){

         Set<Id> setEmailMsg = new Set<Id>();
         Set<Id> setContentDocId = new Set<Id>();
         List<ContentDocument> listContentDoc= new List<ContentDocument>();

         for(EmailMessage email :scope){
               setEmailMsg.add(email.Id);
          }

          for(ContentDocumentLink cdl:[SELECT LinkedEntityId,ContentDocumentId FROM ContentDocumentLink where LinkedEntityId IN:setEmailMsg]){ 
               setContentDocId.add(cdl.ContentDocumentId);
          }

          for(ContentAsset ca:[SELECT ContentDocumentId from ContentAsset  where ContentDocumentId IN:setContentDocId]){
               setContentDocId.remove(ca.ContentDocumentId);
          }
         
         for(Id contenDoc:setContentDocId){
             ContentDocument cdDelete = new ContentDocument(Id = contenDoc);
             listContentDoc.add(cdDelete);
         }
          //system.debug('listContentDoc' + listContentDoc);

          if(!listContentDoc.isEmpty()){
               Database.delete(listContentDoc); 
          }

    
    }
    global void finish(Database.BatchableContext BC){
    }
    
    global void execute(SchedulableContext sc){
        Database.executeBatch(new BA001_MassDeleteAttachments());
    }

 }