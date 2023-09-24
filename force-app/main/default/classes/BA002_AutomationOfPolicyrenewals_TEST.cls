/**
* @author NABIL - Comforth
* @date 2020 12-28
* @group UTIL
* @description Classe de test pour BA002_AutomationOfPolicyrenewals_TEST
*/
@isTest
public class BA002_AutomationOfPolicyrenewals_TEST {
    
    static User adminUser = new TestFactory.UserFactory().createRunningUserAdministrator();
    
    @testSetup static void setup(){
        System.runAs(adminUser){ 
            
         
            
            
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

           
        }    
          
    }
    
    @isTest   static void testBA002_AutomationOfPolicyrenewals(){ 
      
        List<Policy__c> listP = [SELECT Id, PolicyEndDate__c, TypeOfContract__c, Name  FROM Policy__c];
      Date myDate = date.today();
       
        Policy__c pol = new Policy__c();

        //pol.RecordType.DeveloperName ='PolicyAsiaRT';
        pol.Category__c ='Policy';
        pol.PolicyEndDate__c = myDate.addDays (60);
       insert pol;
         
        Test.StartTest();
        System.runAs(adminUser){
            Database.executeBatch(new BA002_AutomationOfPolicyrenewals());
            List<Case> listC = [SELECT id from Case];
            system.assertEquals(0, listC.size());
            
            BA002_AutomationOfPolicyrenewals batchCreatCase = new BA002_AutomationOfPolicyrenewals();
            String sch = '0 0 23 * * ?'; 
           // system.schedule( sch, batchCreatCase); 
        } 
        Test.stopTest();
    }
    

}