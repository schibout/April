/**
* @author Nabil - Comforth-Karoo
* @date 2020-12-28
* @modified 2020-12-28
* @group Batch BA002_AutomationOfPolicyrenewals
* @object Case
* @description T For each policy, 60 days before the expiry date, automatically create a case set with fields fulfilled.
*/

global class BA002_AutomationOfPolicyrenewals implements Database.Batchable<sObject>, Schedulable {
    
      
  global Database.QueryLocator start(Database.BatchableContext bc){
      
   String query = 'SELECT Id, PolicyEndDate__c, TypeOfContract__c, Name, RecordType.developerName, Category__c  FROM Policy__c WHERE RecordType.DeveloperName = \'PolicyAsiaRT\' AND  Category__c = \'Policy\'';
      
      
   return Database.getQueryLocator(query);

  } 


global void execute ( Database.BatchableContext bc, List<Policy__c> listPlicy){
  //Integer d = 60;
    System.debug('@@@@@@@@@@@@@@@@');
  Date myDate = date.today();
List<case> lstNwCases = new List<case>(); 
  Map<String,Group> mapQueues = new Map<String,Group>();
   for(Group queue : [SELECT id,NAme,DeveloperName  FROM GROUP WHERE Type = 'Queue']){
                       mapQueues.put(queue.DeveloperName,queue);
           }
 Map<id,String> mappoTyp = new Map<id,String>();
     
  for(Policy__c  po: listPlicy ){

    If (po.RecordType.DeveloperName =='PolicyAsiaRT' &&  po.Category__c == 'Policy' ){
      
      if(po.PolicyEndDate__c == myDate.addDays (60)){
          
        // String TypContact =  po.TypeOfContract__c;
          
     String potype =  po.TypeOfContract__c;   
    //      mappoTyp.put(potype.DeveloperName, potype);
          
      case newcases = new   case();   
       newcases.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
       newcases.Subject = 'Renewal of'+' '+ po.Name;
       newcases.Status   = 'Policy to be renewed';
       newcases.BusinessOutcome__c = 'Open';
       newcases.Policy__c = po.Id;
       newcases.Origin = 'Other';
       newcases.PolicyType__c = potype;
       newcases.RenewalEffectiveDate__c = po.PolicyEndDate__c;
       newcases.Priority = 'TBC';
       newcases.OwnerId = mapQueues.get('PolicyTeam').Id;
       lstNwCases.add(newcases);
          
         
          
      }
      else{
          
      }
      // insert lstNwCases;
     
      
  }
}
  INSERT lstNwCases ;
}


global void finish(Database.BatchableContext bc){
  
  
}

global void execute(SchedulableContext sc){
  Database.executeBatch(new BA002_AutomationOfPolicyrenewals());
}

}