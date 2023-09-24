/**
* @author Keshav - Comforth
* @date 2020-02-04
* @group UTIL
* @description Classe utilitaire de test gérant la création de données
*/
@isTest
public class TestFactory_TEST {
	static User adminUser = new TestFactory.UserFactory().createRunningUserAdministrator();
        public static TestMethod void testAllMethod(){
            System.runAs(adminUser){
               Test.startTest();  
                Account Acc = new TestFactory.AccountFactory().createAccount('Underwriter');
                Policy__c policy = new TestFactory.PolicyFactory().createPolicy('PolicyAsiaRT' , 'Application' , 'LIHK');
                Claim__c claim = new TestFactory.ClaimFactory().createClaim('ClaimAsiaRT' , 'LIHK');
                LOG__c log = new TestFactory.LogFactory().createLog('LOGAsiaRT' , 'LIHK');
                Contact Con =   new TestFactory.ContactFactory().createContact(Acc.id);
                Case ca = new TestFactory.CaseFactory().createCase('LOGCaseAsia', 'Email', 'New');
                EmailMessage EM = new TestFactory.EmailMessageFactory().createEmail(ca.Id);
                ContentDocumentLink cv = new TestFactory.ContentDocumentLinkFactory().createContentDocumentLink(EM.Id);
               Test.stopTest();
            }
        }
}