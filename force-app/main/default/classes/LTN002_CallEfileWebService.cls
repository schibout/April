/**
* @author Keshav - Comforth
* @date 2020-06-23
* @modified 2020-06-23
* @group Batch LTN002_CallEfileWebService
* @object Case
* @description Dynamic lookup based on user input parameter 
*/
public with sharing class LTN002_CallEfileWebService {

    @AuraEnabled
    public static Boolean onInit() {
        //Onload calculate the difference of the token so that the user will be able to skip the first screen(login screen)
        Id UserId = UserInfo.getUserId();
         // Get exp  From Custom setting AprilSettings__c
        AprilSettings__c aprilSetting = AprilSettings__c.getOrgDefaults();
        //get expiration set from user
        Decimal tokenExp = aprilSetting.TokenExpiration__c;

        user u = [SELECT Id, Name,MegaUserName__c,MegaToken__c,TECH_MegaTokenTime__c from User WHERE id=:UserId];
        Datetime systemDateTime = system.now();
        Datetime userTokenTime = u.TECH_MegaTokenTime__c;
        Boolean isValid = false;

        Integer elapsedDays = date.valueof(userTokenTime).daysBetween(date.Today());
        system.debug('elapsedDays' + elapsedDays);
        if(elapsedDays == 0){
            decimal elapsedTimeHours = decimal.valueof((systemDateTime.getTime() - userTokenTime.getTime())/(1000*60));
            system.debug('elapsedTimeHours' + elapsedTimeHours);
            if(elapsedTimeHours <= tokenExp){
                return isValid = true;
            }else{
                return isValid = false;
            }
        }else{
            return isValid = false;
        }
    }

    public class resultWrapper{
        @AuraEnabled public string code ;
        @AuraEnabled public string token ;
        @AuraEnabled public string message ;
    }


    @AuraEnabled
    public static resultWrapper getAuthToken(String username, String password) {
        try{
            resultWrapper rw = new resultWrapper();
            // Get Url From Custom setting AprilSettings__c
            AprilSettings__c aprilSetting = AprilSettings__c.getOrgDefaults();
            //Url to AUth
            String authUrl = aprilSetting.AuthEndpoint__c;
            //convert PWd to md5
            Blob requestBlob = Blob.valueOf(password);
            Blob hash = Crypto.generateDigest('MD5', requestBlob);
            //Need to convert into hex to generate the equivalent of md5(string) method of PHP.
            String requestSignature = EncodingUtil.convertToHex(hash);

            //Get Auth token 
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(authUrl);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setBody('{"username":"'+username+'","password": "'+requestSignature+'"}');
            HttpResponse response = http.send(request);
            //system.debug('response ' + response);
            //remove uppercase add mapAuth
            Map<String, Object> mapAuthresults = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            //System.debug('Authresults' + Authresults);
            rw.code =  String.valueof(mapAuthresults.get('code'));
            rw.message = String.valueof(mapAuthresults.get('message'));
            rw.token = (String.valueof(mapAuthresults.get('token'))) != ''?String.valueof(mapAuthresults.get('token')):'';
            system.debug('rw : ' + rw);
            return rw;
        }catch(Exception e){

            resultWrapper rw = new resultWrapper();
            rw.code = '800';
            rw.message = e.getMessage();
            rw.token = '';
            return rw;
        }
        
    }




    @AuraEnabled
    public static resultWrapper sendResults(String underWriter, String type, String refNumber,String token, Id recId) {
        try{
            type = (type == 'Log')?'Claim':type;
            resultWrapper rw = new resultWrapper();
            Set<id> setContentDocId = new Set<id> ();
            List<Id> listIdCdl = new List<Id>();
            String listString = '';

            for(ContentDocumentLink cdl:[SELECT LinkedEntityId, ContentDocumentId
                                         FROM ContentDocumentLink 
                                         WHERE LinkedEntityId =:recId]){
                setContentDocId.add(cdl.ContentDocumentId);
            }
            /* GDH 31/07/2020 - commented as set is used directly
            //listIdCdl.addAll(setContentDocId);

            //convert to required format 
            if(listIdCdl.size() == 1){
             listString = '["'+listIdCdl[0]+'"]';
            }else if(listIdCdl.size()>1){
             listString = '["'+String.join(listIdCdl, '","')+'"]';
            }*/
            // Get Url From Custom setting AprilSettings__c
            AprilSettings__c aprilSetting = AprilSettings__c.getOrgDefaults();
            //Url to Filling
            String fillingUrl = aprilSetting.EfilingEndpoint__c;
            //System.debug('Post efilling');
            Http httpFilling = new Http();
            HttpRequest requestFilling = new HttpRequest();
            requestFilling.setEndpoint(fillingUrl);
            requestFilling.setMethod('POST');
            requestFilling.setHeader('Content-Type', 'application/json');
            Map <String, Object> mapRequest = new Map <String, Object>{
                'token' 			=> token,
                'emailMessageId'	=> recId,
                'salesforceFileId'	=> setContentDocId,
                'objectRef'			=> refNumber,
                'objectType'		=> type
            };
            System.debug(JSON.serializePretty(mapRequest));
            requestFilling.setBody(JSON.serializePretty(mapRequest));
            // GDH requestFilling.setBody('{"token":"'+token+'","emailMessageId": "'+recId+'","salesforceFileId":'+listString+',"objectRef": "'+refNumber+'","objectType": "'+type+'"}');
            requestFilling.setTimeout(120000);
            HttpResponse responseFilling = httpFilling.send(requestFilling);
            System.debug('responseFilling' + responseFilling.getBody());
            Map<String, Object> mapConnection = (Map<String, Object>) JSON.deserializeUntyped(responseFilling.getBody());
            System.debug('mapConnection' + mapConnection);
            rw.code =  String.valueof(mapConnection.get('code'));
            rw.message = String.valueof(mapConnection.get('message'));

            return rw;
        }catch(Exception e){

            resultWrapper rw = new resultWrapper();
            rw.code = '800';
            rw.message = e.getMessage();
            rw.token = '';
            return rw;
        }
        
    }
}