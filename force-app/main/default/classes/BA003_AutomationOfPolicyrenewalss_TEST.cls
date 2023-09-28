@isTest
public class BA003_AutomationOfPolicyrenewalss_TEST {
    
    @testSetup 
    static void setup() {
        NberOfDays__c nbrDaysSetting = new NberOfDays__c();
        nbrDaysSetting.NbrOfDays__c = 60;
        insert nbrDaysSetting;
        
        Account acc = new Account(Name = 'Test1');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Policy__c.getRecordTypeInfosByDeveloperName().get('PolicyAsiaRT').getRecordTypeId(); 
        
        Date expirationDate = Date.today().addDays(60);
        
        List<Policy__c> policiesToInsert = new List<Policy__c>();
        
        for(Integer i = 1; i <= 3; i++) {
            Policy__c newPolicy = new Policy__c();
            newPolicy.TypeOfContract__c = 'Individual';
            newPolicy.Name = 'Policy' + i;
            newPolicy.Category__c = 'Policy';
            newPolicy.PolicyEndDate__c = expirationDate;
            newPolicy.RecordTypeId = recordTypeId;
            policiesToInsert.add(newPolicy);
        }
        
        insert policiesToInsert;
    }
    
    @isTest 
    static void testBA003_AutomationOfPolicyrenewalssV2() {
        Test.StartTest();
        Database.executeBatch(new BA003_AutomationOfPolicyrenewalssV2(), 200);
        Test.StopTest();
        
        List<Policy__c> updatedPolicies = [SELECT Id, PolicyRenewed__c FROM Policy__c WHERE PolicyRenewed__c = TRUE];
        System.assertEquals(3, updatedPolicies.size(), '3 Policies should be marked as renewed');
        
        List<Case> createdCases = [SELECT Id FROM Case];
        System.assertEquals(3, createdCases.size(), '3 Cases should be created');
    }
}
