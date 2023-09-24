/**
* @author NABIL - Comforth Karoo
* @date 2021-02-01
* @group 
* @description Classe de test pour BA004_AutoDeletionOfCases_TEST
*/
@isTest
public class BA004_AutoDeletionOfCases_TEST {
    
    static User adminUser = new TestFactory.UserFactory().createRunningUserAdministrator();
     @testSetup static void setup(){
     System.runAs(adminUser){ 
     }    
    }
    
    @isTest   static void testBA004_AutoDeletionOfCases(){ 
     NbrDaysClosedCase__c Nberdys = new NbrDaysClosedCase__c();
     Nberdys.NumbrDaysClosedCase__c = 0;
     insert Nberdys;
     List<Case> listP = [SELECT Id, RecordType.Name, CaseSubtypeFR__c, CaseSubtype__c, ClosedDate , Status   FROM case ];
     date mDate = date.today();
     List<Id> ListCId = new List<Id>();
     Case c = new case();
     c.status ='Closed';
     c.CaseSubtype__c = 'SPAM';
     insert c ;
     ListCId.add(c.Id);
     EmailMessage em = new EmailMessage();
     em.parentid = c.Id;
     insert em;
     ContentDocumentLink ctlink = new ContentDocumentLink ();
     ctlink.LinkedEntityId = em.Id;
     List<Id> caseidss = new List<Id> ();
     for (Case litP : [SELECT Id, RecordType.Name, CaseSubtypeFR__c, CaseSubtype__c, ClosedDate , Status  FROM case where status ='Closed' OR  status ='Merged' OR status ='duplicate' ]){
     caseidss.add(litP.Id);
    }
      Test.StartTest();
       System.runAs(adminUser){
        Database.executeBatch(new BA004_AutoDeletionOfCases());
        List<Case> lstC = [SELECT id from Case];
        BA004_AutoDeletionOfCases batchCreatCase = new BA004_AutoDeletionOfCases();
        String sch = '0 0 23 * * ?'; 
        } 
        Test.stopTest();
    }
}