/**
 * @author Comforth - Karoo  Nabil
 * @date 17/02/2021
 * @group
 * @description Policy Management Class
 */
@isTest
public class SM004_Case_TEST{
	static User adminUser = new TestFactory.UserFactory().createRunningUserAdministrator();
	@isTest
	static void testEmptyingCaseSubtype01(){
		User adminUser2 = new TestFactory.UserFactory().createRunningUserAdministrator();
		System.runAs(adminUser2){

			Case ca = new Case();
			ca.CaseSubtypeFR__c = 'VIP';
			ca.CaseSubtype__c = 'Clean';
			ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NewBusiness').getRecordTypeId();
			insert ca;

			Test.StartTest();
			ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Generic').getRecordTypeId();
			update ca;

			Test.stopTest();
			ca = [SELECT CaseSubtypeFR__c, CaseSubtype__c
			      FROM Case
			      WHERE Id = :ca.Id];
			System.assertEquals('VIP', ca.CaseSubtypeFR__c);
			System.assertEquals(null, ca.CaseSubtype__c);
		}
	}

	@isTest
	static void testEmptyingCaseSubtype02(){
		User adminUser2 = new TestFactory.UserFactory().createRunningUserAdministrator();
		System.runAs(adminUser2){

			Case ca = new Case();
			ca.CaseSubtypeFR__c = 'VIP';
			ca.CaseSubtype__c = 'Clean';
			ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NewBusiness').getRecordTypeId();
			insert ca;

			Test.StartTest();
			ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Generic').getRecordTypeId();
			ca.CaseSubtypeFR__c = 'garanties';
			update ca;

			Test.stopTest();
			ca = [SELECT CaseSubtypeFR__c, CaseSubtype__c
			      FROM Case
			      WHERE Id = :ca.Id];
			System.assertEquals('garanties', ca.CaseSubtypeFR__c);
			System.assertEquals(null, ca.CaseSubtype__c);
		}
	}

	@isTest
	static void testEmptyingCaseSubtype03(){
		User adminUser2 = new TestFactory.UserFactory().createRunningUserAdministrator();
		System.runAs(adminUser2){

			Case ca = new Case();
			ca.CaseSubtypeFR__c = 'Adweb';
			ca.CaseSubtype__c = 'Clean';
			ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NewBusiness').getRecordTypeId();
			insert ca;

			Test.StartTest();
			ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Adjustment').getRecordTypeId();
			ca.CaseSubtype__c = 'SPAM';
			update ca;

			Test.stopTest();
			ca = [SELECT CaseSubtypeFR__c, CaseSubtype__c
			      FROM Case
			      WHERE Id = :ca.Id];
			System.assertEquals(null, ca.CaseSubtypeFR__c);
			System.assertEquals('SPAM', ca.CaseSubtype__c);
		}
	}

	@isTest
	static void testProvidingCasePriorityToHigh1(){
		User adminUser2 = new TestFactory.UserFactory().createRunningUserAdministrator();
		System.runAs(adminUser2){

			Policy__c policy = new Policy__c(
				Name = 'Test/' + HighPriorityContract__mdt.getAll().values()[0].contractName__c + '/test'
			);
			insert policy;

			Test.startTest();
			Case c = new Case(
				CaseSubtypeFR__c = 'Adweb', 
				CaseSubtype__c = 'Clean',
				Policy__c = policy.Id,
				OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'ParisLOGTeam' LIMIT 1].Id,
				RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NewBusiness').getRecordTypeId()
			);
			insert c;
			Test.stopTest();

			c = [
				SELECT Priority
			    FROM Case
			    WHERE Id = :c.Id
			];
			System.assertEquals('High', c.Priority);
		}
	}

	@isTest
	static void testProvidingCasePriorityToHigh2(){
		User adminUser2 = new TestFactory.UserFactory().createRunningUserAdministrator();
		System.runAs(adminUser2){

			Policy__c policy = new Policy__c(
				Name = 'Test/' + HighPriorityContract__mdt.getAll().values()[0].contractName__c + '/test'
			);
			insert policy;

			Test.startTest();
			Case c = new Case(
				CaseSubtypeFR__c = 'Adweb', 
				CaseSubtype__c = 'Clean',
				Policy__c = policy.Id,
				OwnerId = [SELECT Id, UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'Paris_LOG_team' LIMIT 1].UserOrGroupId,
				RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NewBusiness').getRecordTypeId()
			);
			insert c;
			Test.stopTest();

			c = [
				SELECT Priority
			    FROM Case
			    WHERE Id = :c.Id
			];
			System.assertEquals('High', c.Priority);
		}
	}

	@isTest
	static void testNotProvidingCasePriorityToHigh() {
		User adminUser2 = new TestFactory.UserFactory().createRunningUserAdministrator();
		System.runAs(adminUser2){

			Policy__c policy = new Policy__c(
				Name = 'Test/' + HighPriorityContract__mdt.getAll().values()[0].contractName__c + '/test'
			);
			insert policy;

			Test.startTest();
			Case c = new Case(
				CaseSubtypeFR__c = 'Adweb', 
				CaseSubtype__c = 'Clean',
				Policy__c = policy.Id,
				OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName NOT IN ('ParisLOGTeam', 'MexicoLOGTeam', 'BangkokLOGTeam') LIMIT 1].Id,
				RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NewBusiness').getRecordTypeId()
			);
			insert c;
			Test.stopTest();
			
			c = [
				SELECT Priority
			    FROM Case
			    WHERE Id = :c.Id
			];
			System.assertNotEquals('High', c.Priority);
		}
	}
}