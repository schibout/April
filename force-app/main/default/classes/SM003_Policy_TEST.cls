/**
 * @author Comforth dev team
 * @date 17/12/2020
 * @group
 * @description Policy Management Class
 */


@isTest
public class SM003_Policy_TEST {
    
    static User adminUser = new TestFactory.UserFactory().createRunningUserAdministrator();
    
    @testSetup static void setup(){
      //  System.runAs(adminUser){ 
            
         
            
            
            //Create 200  case
          /*  List<Case> listCase = new List<Case>();
            for(Integer i=0;i<200;i++){
                listCase.add(new TestFactory.CaseFactory().createCase('LOGCaseAsia', 'Email', 'New'));
            }
            insert listCase;

            List<Policy__c> listPolicyApp = new List<Policy__c>();
            for(Integer i=0;i<2;i++){
                listPolicyApp.add(new TestFactory.PolicyFactory().createPolicy('PolicyAsiaRT' , 'Application' , 'LIHK'));
            }
            insert listPolicyApp;*/

           
      //  }    
          
    }
 
    
  @isTest

 static void testSM003_Policy(){ 


  User adminUser2 = new TestFactory.UserFactory().createRunningUserAdministrator();
        
  System.runAs(adminUser2){  
   
    Test.StartTest();
        List<Policy__c> listP = [SELECT Id, PolicyEndDate__c, TypeOfContract__c, Name  FROM Policy__c];
     
        Map<String,Policy_Settings__mdt> plstgMap = new Map<String,Policy_Settings__mdt>();
      
       // plstgMap.Application_Status__c = 'Received';
        //plstgMap.Case_Status__c = 'New';
          
        Map<Id,Policy__c> mpPo = new Map<Id,Policy__c>();

        Policy__c pol = new Policy__c();

        //pol.RecordType.DeveloperName ='PolicyAsiaRT';
        pol.Category__c ='Application';
        Pol.ApplicationStatus__c = 'Received';
        
       insert pol;
       mpPo.put(pol.id , pol );




      Case c = new case();
      c.Policy__c = pol.Id;
      //c1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NewBusiness').getRecordTypeId();
      c.Status = 'New';
       insert c;
      

       List<Policy__c> listPoWhitAss = new  List<Policy__c>();
       listPoWhitAss = [SELECT Id, ApplicationStatus__c , (SELECT Id,Status FROM Cases__r WHERE RecordType.developerName = 'NewBusiness') FROM Policy__c WHERE Id IN:mpPo.values() ];



  SM003_Policy.synchCaseStatus(mpPo);



       Test.stopTest();
   
      }
         
      



        /*System.runAs(adminUser2){


          Test.StartTest();







          List<Case> listCs = [SELECT id, Status from Case];

         
          SM003_Policy  M  = new SM003_Policy();
       

        
            system.assertEquals('New', listCs[0].Status);
            
            Test.stopTest();
        } 
        */
    }
    

}