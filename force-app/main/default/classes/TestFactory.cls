/**
* @author Keshav - Comforth
* @date 2020-20-05
* @group UTIL
* @description Classe utilitaire de test gérant la création de données
*/
public with sharing class TestFactory {
    private static String SYSTEM_ADMINISTRATOR_PROFILE_NAME = 'System Administrator';
    private static String SYSTEM_ADMINISTRATOR_PROFILE_NAME_FR = 'Administrateur système';

    public class UserFactory {
        public User createRunningUserAdministrator() {
            /**
            * @description Crée un utilisateur de type admin
            */
            
            User administratorUser = new User(
                alias = 'Test',
                email = 'test.magellan-admin@example.com',
                emailencodingkey = 'UTF-8',
                lastname = 'testAdmin',
                languagelocalekey = 'fr',
                localesidkey = 'fr_FR',
                TECH_MegaTokenTime__c = system.now(),
                profileid = [
                    SELECT Id
                    FROM Profile
                    WHERE Name = :SYSTEM_ADMINISTRATOR_PROFILE_NAME
                    OR Name = :SYSTEM_ADMINISTRATOR_PROFILE_NAME_FR
                    LIMIT 1
                ][0].Id,
                timezonesidkey = 'Europe/Paris',
                username = 'test.magellan-admin' + System.now().millisecond()
                + UserInfo.getOrganizationId() + '@example.com'
            );
            return administratorUser;
        }

    }

    public class AccountFactory {
        /**
            * @description Création d'un compte
        */
        public Account createAccount(String RecordType){
            Account acc = new Account();
            acc.recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(RecordType).getRecordTypeId();
            acc.Name = 'test Comforth ' + RecordType + System.now().millisecond();
            acc.BillingCountry='France';
            return acc;
        }   
    }

    public class PolicyFactory {
        /**
            * @description Création d'un policy
        */
        public Policy__c createPolicy(String RecordType , String category, String underWriterCode){
            Policy__c po = new Policy__c();
            po.recordtypeid = Schema.SObjectType.Policy__c.getRecordTypeInfosByDeveloperName().get(RecordType).getRecordTypeId();
            po.Name = underWriterCode + RecordType + System.now().millisecond();
            po.Category__c = category;
            po.UnderwriterCode__c = underWriterCode;

            return po;
        }   
    }

    public class ClaimFactory {
        /**
            * @description Création d'un policy
        */
        public Claim__c createClaim(String RecordType ,  String underWriterCode){
            Claim__c cl = new Claim__c();
            cl.recordtypeid = Schema.SObjectType.Claim__c.getRecordTypeInfosByDeveloperName().get(RecordType).getRecordTypeId();
            cl.Name = underWriterCode + RecordType + System.now().millisecond();

            return cl;
        }   
    }


    public class LogFactory {
        /**
            * @description Création d'un policy
        */
        public LOG__c createLog(String RecordType ,  String underWriterCode){
            LOG__c lg = new LOG__c();
            lg.recordtypeid = Schema.SObjectType.LOG__c.getRecordTypeInfosByDeveloperName().get(RecordType).getRecordTypeId();
            lg.Name = underWriterCode + RecordType + System.now().millisecond();

            return lg;
        }   
    }


    public class ContactFactory {
        /**
            * @description Création d'un contact
        */
        public Contact createContact(Id accountId) {
            Contact c = new Contact();
            c.LastName = 'LName';
            c.FirstName = 'FName';
            c.email = 'lname@email.com';
            c.AccountId = accountId;         
            return c;
        }
    }

    public class CaseFactory {
        /**
            * @description Création d'un case
        */
        public Case createCase(String RecordType, String Origin, String Status) {
            //Origin can be : Email, Phone, Web, Internal, Chat,Reception desk, Mail, Other
            // Status can be : New, Processing, Closed
            Case c = new Case();
            c.recordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RecordType).getRecordTypeId();      
            c.Origin = Origin;
            c.Status = Status;
            return c;
        }
    }

    public class EmailMessageFactory {
        /**
            * @description Création d'un Email Message 
        */
        public EmailMessage createEmail(Id caseId) {
            EmailMessage em = new EmailMessage();
            em.FromAddress = 'test@abc.org';
            em.Incoming = false; 
            em.ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com';
            em.Subject = 'Test email';
            em.TextBody = '23456 '; 
            em.ParentId = caseId;
            return em;
        }
    }

    public class ContentDocumentLinkFactory {
        /**
            * @description Création d'un ContentDocumentLink
        */
        public ContentDocumentLink createContentDocumentLink(Id EmailMessage) {


            //Create Document
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document';
            cv.PathOnClient = 'TestDocument.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            Insert cv; 


            //Get Content Documents
            List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
             
              
              //create ContentDocumentLink  record 
              ContentDocumentLink cdl = New ContentDocumentLink();
              cdl.LinkedEntityId = EmailMessage;
              cdl.ContentDocumentId = cdList[0].Id;
              cdl.shareType = 'V';
              return cdl;
        }


        /*public List<ContentDocumentLink> createContentDocumentLinkBulk(List<Id> EmailMessages) {

            List<ContentDocumentLink> listCDL = new  List<ContentDocumentLink>();

            
            //Create Document
            List<ContentVersion> cvlist = new  List<ContentVersion>();
            for(Integer i=0;i<EmailMessages.size();i++){
                ContentVersion cv = new ContentVersion();
                cv.Title = 'Test Document' + i;
                cv.PathOnClient = 'TestDocument.pdf';
                cv.VersionData = Blob.valueOf('Test Content');
                cv.IsMajorVersion = true;
                cvlist.add(cv);
            }
            insert cvlist;


            //Get Content Documents
            List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
             
              
             //create ContentDocumentLink  record 
             for(Integer i; i<EmailMessages.size();i++){
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.LinkedEntityId = EmailMessages[i];
                cdl.ContentDocumentId = cdList[i].Id;
                cdl.shareType = 'V';
                listCDL.add(cdl);
              }
              
              return listCDL;
        }*/
    }


 }