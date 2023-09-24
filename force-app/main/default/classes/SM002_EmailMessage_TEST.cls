/**
 * @author Comforth dev team
 * @date 17/12/2020
 * @group
 * @description EmailMessage Management Class TEST
 */
@isTest
public class SM002_EmailMessage_TEST{
    static User adminUser = new TestFactory.UserFactory().createRunningUserAdministrator();
    final private static String aRandomCaseRecordTypeDeveloperName = 'LOGCaseFR';
    @testSetup
    static void setup(){

        System.runAs(adminUser){

            //Create 1  case Status closed
            Case aCase = new TestFactory.CaseFactory().createCase('LOGCaseAsia', 'Email', 'Closed');
            aCase.OwnerId = [SELECT id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'GestionDediee'].Id;
            insert aCase;

            insert new Case_Qualification_Setting__c (
                Sender__c = 'sender@test.fr',
                Mailbox__c = 'mailbox@test.fr',
                Case_Record_Type__c = aRandomCaseRecordTypeDeveloperName
            );
        }
    }

    @isTest
    static void testCopyClosedCaseDeterminantValid(){
        User adminUser2 = new TestFactory.UserFactory().createRunningUserAdministrator();

        System.runAs(adminUser2){
            test.startTest();
            Case aCase = [SELECT Id, Status
                FROM Case
                Limit 1];

            EmailMessage em = new EmailMessage();
            em.FromAddress = 'mailbox@test.fr';
            em.Incoming = false;
            em.ToAddress = 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com';
            em.Subject = 'Test email';
            em.TextBody = '23456 ';

            em.ParentId = aCase.Id;
            insert em;

            em = new EmailMessage();
            em.FromAddress = 'test@abc.org';
            em.Incoming = true;
            em.ToAddress = 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com';
            em.Subject = 'Test email 2';
            em.TextBody = '23456 ';

            em.ParentId = aCase.Id;
            
            insert em;

            // Récuperer tous les case parent ids
            list<Case> cdl = [SELECT id FROM Case];
            System.assertEquals(2, cdl.size(), 'Case  size should be 2');

            Case clonedCase = [SELECT id, RecordType.DeveloperName FROM Case WHERE id != :aCase.Id];
            System.assertEquals(aRandomCaseRecordTypeDeveloperName, clonedCase.RecordType.DeveloperName, 'The record type should be ' + aRandomCaseRecordTypeDeveloperName);

            test.stopTest();
        }
    }

    @isTest
    static void testCopyClosedCaseVIP(){
        User adminUser2 = new TestFactory.UserFactory().createRunningUserAdministrator();

        System.runAs(adminUser2){

            Case aCase = [SELECT Id
                          FROM Case
                          Limit 1];

            test.startTest();
            
            EmailMessage em = new EmailMessage();
            em.FromAddress = 'sender@test.fr';
            em.Incoming = true;
            em.ToAddress = 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com';
            em.Subject = 'Test email';
            em.TextBody = '23456 ';
            
            em.ParentId = aCase.Id;
            insert em;

            // Récuperer tous les case parent ids
            list<Case> cdl = [SELECT id FROM Case];
            System.assertEquals(2, cdl.size(), 'Case  size should be 2');

            Case clonedCase = [SELECT id, RecordType.DeveloperName, CaseSubtypeFR__c, OwnerId FROM Case WHERE id != :aCase.Id];
            System.assertEquals('ClaimCase', clonedCase.RecordType.DeveloperName, 'The record type should be claim');
            System.assertEquals('VIP', clonedCase.CaseSubtypeFR__c, 'The sub type should be VIP');
            

            test.stopTest();
        }
    }
    
    //LLC 23/02/2023
    @isTest
    static void testCopyClosedCaseDeterminantValidWithMDTCountryTest(){
        
        User adminUser2 = new TestFactory.UserFactory().createRunningUserAdministrator();

        System.runAs(adminUser2){

            Case aCase = [SELECT Id, Subject
                          FROM Case
                          Limit 1];
            aCase.Subject = 'CAMPUS/FT';
            update aCase;
            
            test.startTest();

            EmailMessage em = new EmailMessage();
            em.FromAddress = 'sender@test.fr';
            em.Incoming = true;
            em.ToAddress = 'baiebi@april.com';
            em.Subject = 'CAMPUS/FT';
            em.TextBody = '23456 ';
            
            em.ParentId = aCase.Id;
            insert em;

            List<Case> caseWithCountry = [SELECT Id, Country__c FROM Case WHERE id != :aCase.Id];
            System.assertEquals('Asie', caseWithCountry[0].Country__c);
            
            test.stopTest();

        }
    }
}