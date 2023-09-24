/**
 * @author MTK (based on Keshav code)
 * @date 06/12/2021
 *
 * Class test for the class LTN005_EmailMsg_CallEfileNISWebService
 */

 @isTest
public with sharing class LTN005_EmailMsg_CallEfileNISWS_TEST {

    @testSetup 
    static void setup(){
        insert new AprilSettings__c(
            EfilingToNisEndpoint__c = 'https://url.api/efiling',
            EfilingToNisStaticToken__c = 'token'
        );

        final Case c = new TestFactory.CaseFactory().createCase('LOGCaseAsia', 'Email', 'New');
        insert c;
        
        final EmailMessage em = new TestFactory.EmailMessageFactory().createEmail(c.Id);
        insert em;

        ContentDocumentLink cdl = new TestFactory.ContentDocumentLinkFactory().createContentDocumentLink(em.Id);
        insert cdl;
    }

    @isTest 
    static void testCallingEfilingWS_ok() { 
        List<EmailMessage> em = [SELECT Id FROM EmailMessage];

        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new EfilingWsMock(true)); // true for succes

        LTN005_EmailMsg_CallEfileNISWebService.resultWrapper result = LTN005_EmailMsg_CallEfileNISWebService.callEfilingApi(
            'Quote', 'test quote', em[0].Id
        );

        Test.StopTest();

        System.assertEquals('200', result.code);
        System.assertEquals('ok', result.message);
    }

    @isTest 
    static void testCallingEfilingWS_fail() { 
        List<EmailMessage> em = [SELECT Id FROM EmailMessage];

        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new EfilingWsMock(false)); // false for 401 error

        LTN005_EmailMsg_CallEfileNISWebService.resultWrapper result = LTN005_EmailMsg_CallEfileNISWebService.callEfilingApi(
            'Quote', 'test quote', em[0].Id
        );

        Test.StopTest();

        System.assertEquals('401', result.code);
        System.assertEquals('Unauthorized', result.message);
    }

    @isTest 
    static void testCallingEfilingWS_crash() { 
        List<EmailMessage> em = [SELECT Id FROM EmailMessage];

        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new EfilingWsMock(null)); // null for crash

        LTN005_EmailMsg_CallEfileNISWebService.resultWrapper result = LTN005_EmailMsg_CallEfileNISWebService.callEfilingApi(
            'Quote', 'test quote', em[0].Id
        );

        Test.StopTest();

        System.assertEquals('800', result.code);
    }



    private class EfilingWsMock implements HttpCalloutMock {

        private final Boolean isOk;
        private EfilingWsMock(Boolean isOk) {
            this.isOk = isOk;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();

            res.setHeader('Content-Type', 'application/json');
            if (isOk == null) {
                throw new CalloutException();
            } else if (isOk) {
                res.setBody('{"code": 200,"message": "ok"}');
                res.setStatusCode(200);
            } else {
                res.setBody('Unauthorized');
                res.setStatusCode(401);
            }

            return res;
        }
    }

}