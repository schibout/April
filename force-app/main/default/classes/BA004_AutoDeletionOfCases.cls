/**
* @author NABIL - Comforth Karoo
* @date 2021-02-01
* @group 
* @description Classe de test pour BA004_AutoDeletionOfCases_TEST
*/


global class BA004_AutoDeletionOfCases implements Database.Batchable<sObject> , Schedulable{
    
  global Database.QueryLocator start(Database.BatchableContext bc){
      
   String query = 'SELECT Id, RecordType.Name,CaseSubtypeFR__c, CaseSubtype__c, ClosedDate , Status  from case where status =\'Closed\'  or status =\'duplicate\' or status =\'Merged\'';
      
    return Database.getQueryLocator(query);  
   }

    global void execute (Database.BatchableContext bc, List<Case> listCase){
      System.debug('listCase'+listCase);
      Date mDate = date.today(); 
      System.debug('mDate'+ mDate);
      System.debug('mDate.addDays(1)'+ mDate.addDays(-1));
      NbrDaysClosedCase__c  NDaysClosedCase = NbrDaysClosedCase__c.getOrgDefaults();
      Integer nday = NDaysClosedCase.NumbrDaysClosedCase__c.intValue();
     
      List<Id> caseIds = new List<Id>();
      List<Id> ListEmId = new List<Id>();
      Set<Id> setContentDocId = new Set<Id>();
      List<ContentDocument> listContentDoc= new List<ContentDocument>();
      List<Case> listeCase= new List<Case>();
      System.debug('listCase'+listCase);
      for ( Case  c: listCase ){
        DateTime dt = c.ClosedDate;
        System.debug('dt'+ dt);
        date D = Date.newInstance(dt.year(), dt.month(), dt.day());
        System.debug('D'+ D);
        // System.debug('d'+ d);
        system.debug('mDate.addDays - nday' );
        if ( c.status == 'Closed'){
         if( c.CaseSubtype__c == 'SPAM' || c.CaseSubtype__c == 'Duplicates'  ||  c.CaseSubtypeFR__c == 'SPAM/NON APPLICABLE/ PUB' ){
           if (mDate >= D.addDays(nday)){
             caseIds.add(c.Id);
             System.debug('caseIds'+caseIds);
            }
          }
        }
    
        if( c.Status == 'Merged' || c.Status ==  'Duplicate'){
         if (mDate >= D.addDays(nday)){
          caseIds.add(c.Id);
          System.debug('caseIds'+caseIds);
          }
         }
        }
          for (EmailMessage  em : [SELECT Id , ParentId FROM EmailMessage WHERE ParentId IN: caseIds ]){
            ListEmId.add(em.Id);
            System.debug('ListEmId'+ ListEmId);
          }

          if(!ListEmId.isEmpty()){
          for( ContentDocumentLink cdl : [SELECT LinkedEntityId,ContentDocumentId FROM ContentDocumentLink where LinkedEntityId IN:ListEmId]){ 
           setContentDocId.add(cdl.ContentDocumentId);
           System.debug('setContentDocId'+ setContentDocId);
          }
        }
          
          for(Id contenDoc:setContentDocId){
           ContentDocument cdDelete = new ContentDocument(Id = contenDoc);
           listContentDoc.add(cdDelete);
            System.debug('listContentDoc'+ listContentDoc);
          

          }
          for (Id lstcaseId :caseIds){
           case caseDelete = new case (Id = lstcaseId );
           listeCase.add(caseDelete); 
           System.debug('listeCase'+ listeCase);
          }
         if(!listContentDoc.isEmpty()){
          Database.delete(listContentDoc); 
         }
         if(!listeCase.isEmpty()){
          Database.delete(listeCase); 
         }
    }
    global void finish(Database.BatchableContext bc){
    }
    global void execute(SchedulableContext sc){
     Database.executeBatch(new BA004_AutoDeletionOfCases());
    }  
    

}