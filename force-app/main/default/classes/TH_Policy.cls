/**
 * @author Comforth Dev Team
 * @date 17/12/2020
 * @group Trigger Handler
 * @description Trigger Handler for Policy Object
 */
public without sharing class TH_Policy extends TH_TriggerHandler {

    //@IMPORTANT: SOBJ_NAME must always be declared first
    private static final String SOBJ_NAME = Constants.OBJ_API_POLICY;
    public static Set<String> setBypassMethods = new Set<String>();

    /**
    * @author 
    * @date 
    * @description Constructor
    * @return void
    */
    public TH_Policy() {
    }
    
    
    /**
    * @author  Comforth dev team
    * @date 
    * @description Handler Method for Before Insert Event
    * @return void
    */
   //public override void beforeInsert(){
    public override void afterUpdate() {
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
        //Get Bypassed Methods from Custom MetaData
        setBypassMethods = (TH_TriggerHandler.bypassMethodsMap != null && TH_TriggerHandler.bypassMethodsMap.containsKey(SOBJ_NAME)) 
                           ? TH_TriggerHandler.bypassMethodsMap.get(SOBJ_NAME) :new Set<String>();

        //system.debug('@BEFORE_INSERT - METHODS TO BE BYPASSED: ' + setBypassMethods);
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
        
        Map<Id,Policy__c> mapPoUpdateCaseStatus = new Map<Id,Policy__c>();
        Id idRTPolicyAsia = Schema.SObjectType.Policy__c.getRecordTypeInfosByDeveloperName().get('PolicyAsiaRT').getRecordTypeId();
        
        system.debug(idRTPolicyAsia);
        
        // Loop
        for(Policy__c newPolicy : (List<Policy__c>) Trigger.new){ 
            if( !setBypassMethods.contains('synchCaseStatus') && 
            newPolicy.ApplicationStatus__c != null && 
            newPolicy.ApplicationStatus__c != ((Map<Id, policy__c>) Trigger.oldMap).get(newPolicy.Id).ApplicationStatus__c && 
            newPolicy.Category__c == 'Application'   && 
           newPolicy.RecordTypeId == Schema.SObjectType.Policy__c.getRecordTypeInfosByDeveloperName().get('PolicyAsiaRT').getRecordTypeId())
            {
                mapPoUpdateCaseStatus.put(newPolicy.Id,newPolicy);

                system.debug('mapPoUpdateCaseStatus'+mapPoUpdateCaseStatus );
            }
        }		
        

        if(!mapPoUpdateCaseStatus.isEmpty()) {
			SM003_Policy.synchCaseStatus(mapPoUpdateCaseStatus);
		}
                
    }

    /**
    * @author  Comforth dev team
    * @date 
    * @description Handler Method for Before Insert Event
    * @return void
    */
    public override void beforeUpdate() {
        
        //system.debug('BEFORE UPDATE');
                
   }

}