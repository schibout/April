/**
* @author Keshav - Comforth-Karoo 2020
* @date 2020-06-23
* @modified 2020-06-23
* @group Batch LTN001_CustomLookUP
* @object Case
* @description Dynamic lookup based on user input parameter 
*/

public with sharing class LTN001_CustomLookUP {


@AuraEnabled(cacheable=true)
public static List<SObJectResult> getResults(String ObjectName, String fieldName, String value, String recordtype, String underWriterCode,String totalRecords) {
List<SObJectResult> sObjectResultList = new List<SObJectResult>();
system.debug(fieldName+'-------------'+ObjectName+'---++----------'+value +'---++----------'+ underWriterCode);
system.debug('totalRecords' + totalRecords);

//Use to store the finale Query
String sQuery;
if(ObjectName == 'Account'){
    //Build Basic Query
    if(String.isEmpty(value)){
        sQuery = 'Select Id,UnderwriterCode__c, '+fieldName+' FROM '+ObjectName;
    }else{
        sQuery = 'Select Id,UnderwriterCode__c, '+fieldName+' FROM '+ObjectName+' WHERE '+fieldName+' LIKE \'%' + value + '%\'';
    }
    // If there is recordType then add the following line to the Query
    if(string.isNotBlank(recordtype)){
        if(!sQuery.contains('WHERE')) { 
            sQuery += ' WHERE ';
        } else {
            sQuery += ' AND ';
        }
        sQuery += ' recordtype.developername =: recordtype '; // rec added
    }
}else if(ObjectName == 'Application' || ObjectName == 'Quote'){
    System.debug('Application');
    sQuery = 'select Id,UnderwriterCode__c,  '+fieldName+' from Policy__c WHERE '+fieldName+' LIKE \'%' + value + '%\'';
    sQuery += ' AND Category__c = \'Application\' ';
    if(underWriterCode != null){
        sQuery += ' AND Name LIKE \'' + underWriterCode + '%\'';
    }
    if(string.isNotBlank(recordtype)){
        sQuery += ' AND recordtype.developername =: recordtype ';
    }   
}
else if(ObjectName == 'Policy'){
    System.debug('Policy');
    sQuery = 'select Id,UnderwriterCode__c,  '+fieldName+' from Policy__c WHERE '+fieldName+' LIKE \'%' + value + '%\'';
    sQuery += ' AND Category__c = \'Policy\' ';
    //removed on 6/24/2020 asked by RICART Diane
    /*if(underWriterCode != null){
        sQuery += ' AND Name LIKE \'' + underWriterCode + '%\'';
    }*/
    if(string.isNotBlank(recordtype)){
        sQuery += ' AND recordtype.developername =: recordtype ';

    }   
}
else if(ObjectName == 'Log'){
    System.debug('Log');
    sQuery = 'select Id, '+fieldName+' from LOG__c WHERE '+fieldName+' LIKE \'%' + value + '%\'';
    if(underWriterCode != null){
        sQuery += ' AND Name LIKE \'' + underWriterCode + '%\'';
    }

}else if(ObjectName == 'Claim'){
    System.debug('Claim');
    sQuery = 'select Id, '+fieldName+' from Claim__c WHERE '+fieldName+' LIKE \'%' + value + '%\'';
    if(underWriterCode != null){
        sQuery += ' AND Name LIKE \'' + underWriterCode + '%\'';
    } 
    if(string.isNotBlank(recordtype)){
        sQuery += ' AND recordtype.developername =: recordtype ';
    } 
}
else if(ObjectName == 'Corpclient'){
    System.debug('Account');
    sQuery = 'select Id,'+fieldName+' from Account WHERE '+fieldName+' LIKE \'%' + value + '%\'';
   // sQuery += 'AND (Id IN (SELECT PolicyHolder__c FROM Policy__c WHERE TypeOfContract__c = \'Group\'))'; 
    sQuery += ' AND TECHKEY_ID_MEGA_Account__c != \'\' ';
    if(underWriterCode != null){
        sQuery += ' AND Name LIKE \'' + underWriterCode + '%\'';
    } 
    if(string.isNotBlank(recordtype)){
        sQuery += ' AND recordtype.developername =: recordtype ';
    } 
    System.debug('sQuery' + sQuery);

}
if(String.isNotBlank(totalRecords)){
    sQuery += ' LIMIT ' + totalRecords ;
}

system.debug('sQuery' + sQuery);
List <sObject> lstOfRecords = Database.query(sQuery);

if(String.isNotEmpty(value))
    for(sObject obj :lstOfRecords) {
        String fieldvalue = (String)obj.get(fieldName);
        String recUnderWriter = (ObjectName == 'Account')?(String)obj.get('UnderwriterCode__c'):'';
        sObjectResultList.add(new SObjectResult(fieldvalue, obj.Id,recUnderWriter));
    }

return sObjectResultList;
}

public class SObJectResult {
@AuraEnabled
public String recName;

@AuraEnabled
public Id recId;

@AuraEnabled
public String recUnderWriter;

public SObJectResult(String recNameTemp, Id recIdTemp, String recUnderWriterTemp) {
    recName = recNameTemp;
    recId = recIdTemp;
    recUnderWriter = recUnderWriterTemp;
}
}



}