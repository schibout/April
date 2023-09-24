/**
* @author Keshav - Comforth
* @date 2020-20-05
* @group UTIL
* @description Classe de test pour BA001_MassDeleteAttachments
*/
@isTest
public class BA001_MassDeleteAttachments_TEST {
    
    static User adminUser = new TestFactory.UserFactory().createRunningUserAdministrator();
    
    @testSetup static void setup(){
        System.runAs(adminUser){ 
            
            //Custom setting
            AprilSettings__c aprilSet= new AprilSettings__c();
            aprilSet.EmailAttachmentDelay__c = 1;
            insert aprilSet;
            
            
            //Create 200  case
            List<Case> listCase = new List<Case>();
            for(Integer i=0;i<200;i++){
                listCase.add(new TestFactory.CaseFactory().createCase('LOGCaseAsia', 'Email', 'New'));
            }
            insert listCase;
            
            //Create 200 EmailMessage
            List<EmailMessage> listEmailMessage = new List<EmailMessage>();
            for(Integer i=0;i<200;i++){
                listEmailMessage.add(new TestFactory.EmailMessageFactory().createEmail(listCase[i].Id));
            }
            insert listEmailMessage;
            
            /*list<Id> emailMessageIds = new list<Id>();
            for(EmailMessage em:listEmailMessage){
            emailMessageIds.add(em.Id);
            }
            system.debug('emailMessageIds ' + emailMessageIds);
            
            List<ContentDocumentLink> listCDL = new TestFactory.ContentDocumentLinkFactory().createContentDocumentLink(emailMessageIds);
            insert listCDL;*/
            
            ContentDocumentLink cdl = new TestFactory.ContentDocumentLinkFactory().createContentDocumentLink(listEmailMessage[0].Id);
            insert cdl;
        }
    }
    
    @isTest static void testBA001_MassDeleteAttachments() { 
        List<case> listC = [SELECT id FROM case];
        Integer randomNumber = Integer.valueof((Math.random() * 100));
        system.debug('listC ' + listC.size());
        Test.StartTest();
        System.runAs(adminUser){
            Database.executeBatch(new BA001_MassDeleteAttachments());
            List<ContentDocument> listCD = [SELECT id from ContentDocument];
            system.assertEquals(0, listCD.size());
            
            BA001_MassDeleteAttachments batchDelete = new BA001_MassDeleteAttachments();
            String sch = '0 0 23 * * ?'; 
            system.schedule('BA001_MassDeleteAttachments' + ' ' + randomNumber ,sch, batchDelete); 
        } 
        Test.stopTest();
    }
    
}