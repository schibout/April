/**
 * @author Comforth dev team
 * @date 17/12/2020
 * @group
 * @description Policy Management Class
 */
public with sharing class SM003_Policy {

  /**
  * @author Comforth dev team
  * @date 21/12/2020
  * @description
  * @param 
  * @return
  */
  public static void synchCaseStatus(Map<Id,Policy__c> mapPolicies){

    //Set<String> appStatus = new Set<String>(); 
    //Set<ID> appstatusSet = new Set<ID>();
  
    //Map<ID, Policy__c> policyBodyMap = new Map<ID, Policy__c>();
    //List<ID> idPolicies = new List<ID>();
    //List<Case> cases = new List<Case>();

    Id idRTCaseNewBusiness = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NewBusiness').getRecordTypeId();
    List<case> caseList = new List<case>();
    //Récupérer les Policy_Settings__mdt dans une map, avec ApplicationStatus__c comme clef de la map.
    Map<String,Policy_Settings__mdt> plstgMappings = new Map<String,Policy_Settings__mdt>();
    for(Policy_Settings__mdt poSetting : [SELECT Application_Status__c, Case_Status__c FROM Policy_Settings__mdt] ){
      plstgMappings.put(poSetting.Application_Status__c,poSetting);

      system.debug('plstgMappings'+ plstgMappings);
    }

    List<Policy__c> listPoliciesWithAssociatedCases = new List<Policy__c>();
    listPoliciesWithAssociatedCases = [SELECT Id, ApplicationStatus__c , (SELECT Id,Status FROM Cases__r WHERE RecordTypeId =: idRTCaseNewBusiness) FROM Policy__c WHERE Id IN:mapPolicies.values() AND ApplicationStatus__c IN:plstgMappings.keySet() ];
    
    system.debug('listPoliciesWithAssociatedCases'+listPoliciesWithAssociatedCases);

    for(Policy__c po : listPoliciesWithAssociatedCases){
      for(Case c : po.Cases__r){
        
        c.status = plstgMappings.get(po.ApplicationStatus__c).Case_Status__c;
        caseList.add(c);
        system.debug('caseList' + caseList);
      }
     
    }
    update caseList;

   

  }

}