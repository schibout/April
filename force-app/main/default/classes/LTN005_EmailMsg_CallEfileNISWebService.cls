/**
 * @author MTK (based on Keshav code)
 * @date 06/12/2021
 * 
 * Controller for the lwc lwc_EmailMessage_CallEfileNISWebService
 */

public with sharing class LTN005_EmailMsg_CallEfileNISWebService {

    @AuraEnabled
    public static resultWrapper callEfilingApi(String type, String refNumber, Id recordId) {
        final resultWrapper result = new resultWrapper();

        try{           
            final Set<id> contentDocumentIds = new Set<id> ();
            for(ContentDocumentLink cdl:[
                SELECT LinkedEntityId, ContentDocumentId
                FROM ContentDocumentLink 
                WHERE LinkedEntityId =: recordId            
            ]){
                contentDocumentIds.add(cdl.ContentDocumentId);
            }

            // Get Url From Custom setting AprilSettings__c
            final AprilSettings__c aprilSetting = AprilSettings__c.getOrgDefaults();
            final String efilingEndpoint = aprilSetting.EfilingToNisEndpoint__c;
            final String staticToken = aprilSetting.EfilingToNisStaticToken__c;

            final HttpRequest request = new HttpRequest();
            request.setEndpoint(efilingEndpoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-ApiKey', staticToken);
            system.debug('efilingEndpoint' + efilingEndpoint);
            system.debug('staticToken' + staticToken);

// la requette a envoyer via la requette en Postman (ce qui est en body dans postman)
            final Map <String, Object> mapRequest = new Map <String, Object>{
                'EmailMessageId'	=> recordId,
                'SalesForceFileIds'	=> contentDocumentIds,
                'ObjectRef'			=> refNumber,
// si Type dans la picklist est de valeur Log donc ObjectType = Claim, sinon ObjectType = Type 
                'ObjectType'		=> (type == 'log') ? 'claim' : type
            };
			system.debug('recordId' + recordId);
            system.debug('contentDocumentIds' + contentDocumentIds);
            system.debug('refNumber' + refNumber);
            system.debug('type' + type);
// On converty la Map Request (qui estd de type Object) en JSON
            request.setBody(JSON.serializePretty(mapRequest));
			system.debug('Hoho=' + JSON.serializePretty(mapRequest));
// On determine le temps de reponse (quand on clique sur Send Postman, on attends 2 minutes, si la requette ne rep pas au bout de 2 minute donc c est un erreur)
            request.setTimeout(120000);

// On envoit la requette via send 
            final Http http = new Http();

// 
            final HttpResponse response = http.send(request);
            system.debug('response=' + response);
            
// quand on envoit la requete on a deux param, le code et le message
            try {
                final Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());


                result.code =  String.valueof(responseBodyMap.get('code'));
                result.message = String.valueof(responseBodyMap.get('message'));

            } catch(Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
                System.debug(LoggingLevel.ERROR, e.getStackTraceString());
                System.debug(LoggingLevel.ERROR, response.getStatusCode());
				System.debug(LoggingLevel.ERROR, response.getBody());

                result.code = String.valueOf(response.getStatusCode());
                result.message = response.getBody();
            }
        }catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());

            result.code = '800';
            result.message = e.getMessage();
        }
        
        return result;
    }

    public class resultWrapper{
        @AuraEnabled public string code ;
        @AuraEnabled public string message ;
    }
}