/**
* @author NABIL - Comforth
* @date 2020 12-28
* @group UTIL
* @description Classe de test pour BA003_AutomationOfPolicyrenewalss_TEST
*/
@isTest
public class BA003_AutomationOfPolicyrenewalss_TEST {
    
    static User adminUser = new TestFactory.UserFactory().createRunningUserAdministrator();
    
    @testSetup static void setup(){
      System.runAs(adminUser){ 
      }    
    }
    
    @isTest   static void testBA003_AutomationOfPolicyrenewalss(){ 
      
        NberOfDays__c Nberdys= new NberOfDays__c();
      Nberdys.NbrOfDays__c = 60;
      insert Nberdys;
        
      Account acc = new Account(Name = 'Test1');
      insert acc;
        
      Contract contract = new Contract(AccountId = acc.Id);
      insert contract;
        
      List<Policy__c> listP = [SELECT Id, Contract_No__c, PolicyEndDate__c, TypeOfContract__c,PolicyHolder__r.Name, Name, RecordType.developerName, Category__c, Policy_Is_Auto_Renewed__c  FROM Policy__c ];
      Date myDate = date.today();
      
      Policy__c pol = new Policy__c();
      pol.TypeOfContract__c = 'Individual';
      Pol.Name = 'PGH1000';
      pol.Category__c ='Policy';
      pol.PolicyEndDate__c = myDate.addDays (60);
      insert pol;
      
      Policy__c po = new Policy__c();
      po.TypeOfContract__c = 'Individual';
      po.Name = 'H1000';
      po.Category__c ='Policy';
      po.PolicyEndDate__c = myDate.addDays (60);
      po.Contract_No__c = pol.Id;
      insert po;
        
      Policy__c po2 = new Policy__c();
      po2.TypeOfContract__c = 'Individual';
      po2.Name = 'PGH';
      po2.Category__c ='Policy';
      po2.PolicyEndDate__c = myDate.addDays (60);
      po2.Contract_No__c = pol.Id;
      insert po2;
     
      Test.StartTest();
        System.runAs(adminUser){
            Database.executeBatch(new BA003_AutomationOfPolicyrenewalss());
            List<Case> listC = [SELECT id from Case];
            system.assertEquals(0, listC.size());
            
            BA003_AutomationOfPolicyrenewalss batchCreatCase = new BA003_AutomationOfPolicyrenewalss();
            String sch = '0 0 23 * * ?'; 
           // system.schedule( sch, batchCreatCase); 
        } 
        Test.stopTest();
    }
    
}