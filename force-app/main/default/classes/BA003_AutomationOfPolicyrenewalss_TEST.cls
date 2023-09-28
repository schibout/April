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
      Id recordTypeId = Schema.SObjectType.Policy__c.getRecordTypeInfosByDeveloperName().get('PolicyAsiaRT').getRecordTypeId(); 
  
      Account acc = new Account(Name = 'Test1');
      insert acc;
        
      Contract contract = new Contract(AccountId = acc.Id);
      insert contract;
        
      List<Policy__c> listP = [SELECT Id, Contract_No__c, PolicyEndDate__c
      , TypeOfContract__c,PolicyHolder__r.Name, Name, RecordType.developerName, Category__c
      , Policy_Is_Auto_Renewed__c  FROM Policy__c ];
      Date limitDate = date.today().addDays (60);
      
      Policy__c polycie1 = new Policy__c();
      polycie1.TypeOfContract__c = 'Individual';
      polycie1.Name = 'PGH1000';
      polycie1.Category__c ='Policy';
      polycie1.PolicyEndDate__c = limitDate;
      polycie1.RecordTypeId = recordTypeId;
      insert polycie1;
      
      Policy__c polycie2 = new Policy__c();
      polycie2.TypeOfContract__c = 'Individual';
      polycie2.Name = 'H1000';
      polycie2.Category__c ='Policy';
      polycie2.PolicyEndDate__c = limitDate;
      polycie2.RecordTypeId = recordTypeId;
      insert polycie2;
        
      Policy__c polycie3 = new Policy__c();
      polycie3.TypeOfContract__c = 'Individual';
      polycie3.Name = 'PGH';
      polycie3.Category__c ='Policy';
      polycie3.PolicyEndDate__c = limitDate;
      polycie3.Contract_No__c = polycie1.Id;
      polycie3.RecordTypeId = recordTypeId;
      insert polycie3;
     
      Test.StartTest();
        System.runAs(adminUser){
            List<Policy__c> listBeforeRun = [SELECT  Id  FROM Policy__c  ];
            system.assertEquals(3, listBeforeRun.size(),'3 Polycies must be selected');
            BA003_AutomationOfPolicyrenewalssV2.run ();
            List<Case> listCAfterRun = [SELECT id from Case];
            system.assertEquals(2, listCAfterRun.size(),'Case must create 3');
        } 
        Test.stopTest();
    }
    
}