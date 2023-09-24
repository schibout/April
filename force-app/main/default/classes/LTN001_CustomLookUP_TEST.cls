/**
* @author Keshav - Comforth
* @date 2020-25-06
* @group UTIL
* @description Classe de test pour LTN001_CustomLookUP
*/
@isTest
public with sharing class LTN001_CustomLookUP_TEST {

    static User adminUser = new TestFactory.UserFactory().createRunningUserAdministrator();
    @testSetup static void setup(){
        System.runAs(adminUser){

            //Create 200 Accounts
            List<Account> listAccounts = new List<Account>();
            for(Integer i=0;i<200;i++){
                Account   acc0 = new TestFactory.AccountFactory().createAccount('Underwriter');    
                acc0.Name = 'TestAcc0';
                listAccounts.add(acc0);
            }
            insert listAccounts;

            //Create 200 Accounts 
            List<Account> listAccounts1 = new List<Account>();
            List<Policy__c> listPolicyApp1 = new List<Policy__c>();

            for(Integer i=0;i<200;i++){
                Account   acc1 = new TestFactory.AccountFactory().createAccount('PolicyHolder');    
                // TechkeyId is unique case insensitive  
                          acc1.TECHKEY_ID_MEGA_Account__c =  'kjn' + i;
                          acc1.Name = 'TestCorpclient'; // let's : FieldName = Name and Value = 'Tes' 
                          listAccounts1.add(acc1);
            }
                          insert listAccounts1;
            for (Account acp : listAccounts1)
                          {        
                          Policy__c pl1 = new TestFactory.PolicyFactory().createPolicy('PolicyFranceRT' , 'Application' , 'GrpPoly');
                          pl1.PolicyHolder__c = acp.Id;
                          pl1.TypeOfContract__c = 'Group';
                          listPolicyApp1.add(pl1);           
            }
            insert listPolicyApp1; 

            //Create 200 Policy
            List<Policy__c> listPolicyApp = new List<Policy__c>();
            for(Integer i=0;i<200;i++){
                listPolicyApp.add(new TestFactory.PolicyFactory().createPolicy('PolicyAsiaRT' , 'Application' , 'LIHK-' + i));
            }
            insert listPolicyApp;


            //Create 200 Policy
            List<Policy__c> listPolicyPo = new List<Policy__c>();
            for(Integer i=0;i<200;i++){
                listPolicyPo.add(new TestFactory.PolicyFactory().createPolicy('PolicyFranceRT' , 'Policy' , 'LIHK'));
            }
            insert listPolicyPo;

            //Create 200 claim
            List<Claim__c> listClaim = new List<Claim__c>();
            for(Integer i=0;i<200;i++){
                listClaim.add(new TestFactory.ClaimFactory().createClaim('ClaimAsiaRT' , 'LIHK-' + i));
            }
            insert listClaim; 

            //Create 200 Log
            /* List<LOG__c> listLog = new List<LOG__c>();
            for(Integer i=0;i<200;i++){
                listLog.add(new TestFactory.LogFactory().createLog('LOGAsiaRT' , 'LIHK'));
            }
            insert listLog; */


        }
    }

    
    @isTest static void testAccLookup() { 
        Test.StartTest();
        System.runAs(adminUser){
        List<LTN001_CustomLookUP.SObJectResult> result0 = LTN001_CustomLookUP.getResults('Account', 'Name', 'TestAcc0' , 'Underwriter', 'TestAcc0' , '200');
            System.assertEquals(200 , result0.size() );
        }
        Test.StopTest();
    }

    @isTest static void testCorpclientLookup() { 
        Test.StartTest();
        System.runAs(adminUser){
        List<LTN001_CustomLookUP.SObJectResult> result2 = LTN001_CustomLookUP.getResults('Corpclient', 'Name', 'TestCorpclient' , 'PolicyHolder', 'TestCorpclient' , '200');
        System.assertEquals(200, result2.size() );
    }
        Test.StopTest();
    }

    @isTest static void testQuoteLookup() { 
        Test.StartTest();
        System.runAs(adminUser){
            List<LTN001_CustomLookUP.SObJectResult> result = LTN001_CustomLookUP.getResults('Quote', 'Name', 'LIHK' , null, 'LIHK','200');
            System.assertEquals(200 , result.size());
        }
        Test.StopTest();
    }

    @isTest static void testPolicyLookup() { 
        List<Policy__c> pol =[SELECT Id from Policy__c where Category__c ='Policy'];
        System.debug('pol' + pol.size());
        Test.StartTest();
        System.runAs(adminUser){
            LTN001_CustomLookUP.getResults('Policy', 'Name', 'LIHK' , 'Underwriter','LIHK','200');
            System.assertEquals(200 , pol.size());
        }
        Test.StopTest();
    }

    @isTest static void testClaimLookup() { 
        Test.StartTest();
        System.runAs(adminUser){
            List<LTN001_CustomLookUP.SObJectResult> result = LTN001_CustomLookUP.getResults('Claim', 'Name', 'LIHK' , null, 'LIHK','200');
            System.assertEquals(200 , result.size());
        }
        Test.StopTest();
    }

    /* @isTest static void testLogLookup() { 
        List<LOG__c> log =[SELECT Id from LOG__c ];
        System.debug('LOG__c' + log.size());
        Test.StartTest();
        System.runAs(adminUser){
            LTN001_CustomLookUP.getResults('Log', 'Name', 'LIHK' , 'Underwriter','LIHK','200');
            System.assertEquals(200 , log.size());
        }
        Test.StopTest();
    } */

    
}