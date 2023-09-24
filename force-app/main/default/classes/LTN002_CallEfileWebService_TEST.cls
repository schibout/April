/**
* @author Keshav - Comforth
* @date 2020-06-23
* @modified 2020-06-23
* @group  LTN002_CallEfileWebService_TEST
* @object Case
* @description 
*/
@isTest
public with sharing class LTN002_CallEfileWebService_TEST {
    static User adminUser = new TestFactory.UserFactory().createRunningUserAdministrator();
    
    @testSetup static void setup(){
        //Custom setting
        AprilSettings__c aprilSet= new AprilSettings__c();
        aprilSet.AuthEndpoint__c = 'www.google.com';
        aprilSet.EfilingEndpoint__c = 'www.google.com';
        insert aprilSet;

         //Create 1  case
         List<Case> listCase = new List<Case>();
         for(Integer i=0;i<1;i++){
             listCase.add(new TestFactory.CaseFactory().createCase('LOGCaseAsia', 'Email', 'New'));
         }
         insert listCase;
         
         //Create 1 EmailMessage
         List<EmailMessage> listEmailMessage = new List<EmailMessage>();
         for(Integer i=0;i<1;i++){
             listEmailMessage.add(new TestFactory.EmailMessageFactory().createEmail(listCase[i].Id));
         }
         insert listEmailMessage;

         ContentDocumentLink cdl = new TestFactory.ContentDocumentLinkFactory().createContentDocumentLink(listEmailMessage[0].Id);
         insert cdl;
  
    }

    @isTest static void testWebServiceLogin() { 
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new LTN002_CallEfileWebService_HttpMock());
        LTN002_CallEfileWebService.resultWrapper testWrapper = new LTN002_CallEfileWebService.resultWrapper();
        testWrapper = LTN002_CallEfileWebService.getAuthToken('test', 'test');
        //System.assertEquals(200, testWrapper.code());
        System.debug('testWrapper');
        Test.StopTest();
    }

    @isTest static void testWebServiceLoginFail() { 
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new LTN002_CallEfileWebService_HttpMockFail());
        LTN002_CallEfileWebService.resultWrapper testWrapper = new LTN002_CallEfileWebService.resultWrapper();
        testWrapper = LTN002_CallEfileWebService.getAuthToken('test', 'test');
        //System.assertEquals(200, testWrapper.code());
        System.debug('testWrapper');
        Test.StopTest();
    }

    @isTest static void testWebServiceSendResults() { 
        List<EmailMessage> em = [SELECT Id FROM EmailMessage];
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new LTN002_CallEfileWebService_HttpMock());
        LTN002_CallEfileWebService.resultWrapper testWrapper = new LTN002_CallEfileWebService.resultWrapper();
        testWrapper = LTN002_CallEfileWebService.sendResults('test', 'test', 'test', 'test', em[0].Id);
        //System.assertEquals(200, testWrapper.code());
        System.debug('testWrapper');
        Test.StopTest();
    }

    @isTest static void testWebServiceSendResultsFail() { 
        List<EmailMessage> em = [SELECT Id FROM EmailMessage];
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new LTN002_CallEfileWebService_HttpMockFail());
        LTN002_CallEfileWebService.resultWrapper testWrapper = new LTN002_CallEfileWebService.resultWrapper();
        testWrapper = LTN002_CallEfileWebService.sendResults('test', 'test', 'test', 'test', em[0].Id);
        //System.assertEquals(200, testWrapper.code());
        System.debug('testWrapper');
        Test.StopTest();
    }

    @isTest static void testConnectedUser() { 
        Test.StartTest();
        System.runAs(adminUser){
            LTN002_CallEfileWebService.onInit();
            //System.assertEquals(200 , polApli.size());
        }
        Test.StopTest();
    }

    
private class LTN002_CallEfileWebService_HttpMock implements HttpCalloutMock {
    /**
    * @author Keshav - Comforth
    * @date 2020-06-23
    * @modified 2020-06-23
    * @group  LTN002_CallEfileWebService_HttpMock
    * @object Case
    * @description 
    */
        public HTTPResponse respond(HTTPRequest req){
            System.assertEquals('POST', req.getMethod());
             HttpResponse res = new HttpResponse();
             res.setHeader('Content-Type', 'application/json');
             res.setBody('{"code": 200,"message": "Login success","token": "035b017c1b9a6c1d34bf3347b40b73fa"}');
             res.setStatusCode(200);
             return res;
        }
}

private class LTN002_CallEfileWebService_HttpMockFail implements HttpCalloutMock {
    /**
    * @author Keshav - Comforth
    * @date 2020-06-23
    * @modified 2020-06-23
    * @group  LTN002_CallEfileWebService_HttpMock
    * @object Case
    * @description 
    */
        public HTTPResponse respond(HTTPRequest req){
            System.assertEquals('POST', req.getMethod());
             HttpResponse res = new HttpResponse();
             res.setHeader('Content-Type', 'application/json');
             res.setBody('"code1": 400,"message1": "Fail","token": "035b017c1b9a6c1d34bf3347b40b73fa"');
             res.setStatusCode(400);
             return res;
        }
}
        
}