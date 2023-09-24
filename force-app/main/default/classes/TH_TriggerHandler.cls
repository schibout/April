/**
 * @author Comforth Dev Team
 * @date 19.04.2019
 * @group Trigger Handler
 * @description Trigger Handler – Framework template
 */
public without sharing virtual class TH_TriggerHandler {
		
    // static map of handlername, times run() was invoked
    private static Map<String, LoopCount> loopCountMap;
    private static Map<String, Map<TriggerContext, Boolean>> bypassTriggerEventsMap;
    public static Map<String, Set<String>> bypassMethodsMap;
    
    // the current context of the trigger, overridable in tests
    @TestVisible
    private TriggerContext context;
    
    // the current context of the trigger, overridable in tests
    @TestVisible
    private Boolean isTriggerExecuting;
    
    // static initialization
    static {
        loopCountMap = new Map<String, LoopCount>();
        bypassTriggerEventsMap = new Map<String, Map<TriggerContext, Boolean>>();
        bypassMethodsMap = new Map<String, Set<String>>();
    }
    
    // constructor
    public TH_TriggerHandler() {
        this.setTriggerContext();
    }
    
    /***************************************
    * public instance methods
    ***************************************/
    
    public static void resetBypass() {
            
    }
    
    // main method that will be called during execution
    public void run() {
            
        if (!validateRun()) return;
        
        addToLoopCount();
        
        // dispatch to the correct handler method
        if (this.context == TriggerContext.BEFORE_INSERT) {
            this.beforeInsert();
        }
        else if (this.context == TriggerContext.BEFORE_UPDATE) {
            this.beforeUpdate();
        }
        else if (this.context == TriggerContext.BEFORE_DELETE) {
            this.beforeDelete();
        }
        else if (this.context == TriggerContext.AFTER_INSERT) {
            this.afterInsert();
        }
        else if (this.context == TriggerContext.AFTER_UPDATE) {
            this.afterUpdate();
        }
        else if (this.context == TriggerContext.AFTER_DELETE) {
            this.afterDelete();
        }
        else if (this.context == TriggerContext.AFTER_UNDELETE) {
            this.afterUndelete();
        }
    
    }
    
    public void setMaxLoopCount(Integer max) {
        String objName = getObjectName();
        
        if (!TH_TriggerHandler.loopCountMap.containsKey(objName)) {
            TH_TriggerHandler.loopCountMap.put(objName, new LoopCount(max));
        }
        else {
            TH_TriggerHandler.loopCountMap.get(objName).setMax(max);
        }
    }
    
    public void clearMaxLoopCount() {
        this.setMaxLoopCount(-1);
    }
    
    /***************************************
    * public static methods
    ***************************************/
    
    public static void bypass(String handlerName) {
        //TH_TriggerHandler.bypassedHandlers.add(handlerName);
    }
    
    public static void clearBypass(String handlerName) {
        //TH_TriggerHandler.bypassedHandlers.remove(handlerName);
    }
    
    public static Boolean isBypassed(String handlerName) {
        return false;//TH_TriggerHandler.bypassedHandlers.contains(handlerName);
    }
    
    public static void clearAllBypasses() {
        //TH_TriggerHandler.bypassedHandlers.clear();
    }
    
    /***************************************
    * private instancemethods
    ***************************************/
    
    @TestVisible
    private void setTriggerContext() {
        this.setTriggerContext(null, false);
    }
    
    @TestVisible
    private void setTriggerContext(String ctx, Boolean testMode) {
        if (!Trigger.isExecuting && !testMode) {
            this.isTriggerExecuting = false;
            return;
        }
        else {
            this.isTriggerExecuting = true;
        }
        
        if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
            (ctx != null && ctx == 'before insert')) {
            this.context = TriggerContext.BEFORE_INSERT;
        }
        else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
            (ctx != null && ctx == 'before update')) {
            this.context = TriggerContext.BEFORE_UPDATE;
        }
        else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
            (ctx != null && ctx == 'before delete')) {
            this.context = TriggerContext.BEFORE_DELETE;
        }
        else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
            (ctx != null && ctx == 'after insert')) {
            this.context = TriggerContext.AFTER_INSERT;
        }
        else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
            (ctx != null && ctx == 'after update')) {
            this.context = TriggerContext.AFTER_UPDATE;
        }
        else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
            (ctx != null && ctx == 'after delete')) {
            this.context = TriggerContext.AFTER_DELETE;
        }
        else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
            (ctx != null && ctx == 'after undelete')) {
            this.context = TriggerContext.AFTER_UNDELETE;
        }
    }
    
    // increment the loop count
    @TestVisible
    private void addToLoopCount() {
        String objName = getObjectName();

        if (TH_TriggerHandler.loopCountMap.containsKey(objName)) {
            Boolean exceeded = TH_TriggerHandler.loopCountMap.get(objName).increment();
            if (exceeded) {
                    Integer max = TH_TriggerHandler.loopCountMap.get(objName).max;
                    throw new TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + objName);
            }
        }
    }
    
    // make sure this trigger should continue to run
    @TestVisible
    private Boolean validateRun() {
        if (!this.isTriggerExecuting || this.context == null) {
            throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
        }
        
        String objName = getObjectName();
        //system.debug('objName: ' + objName);
        //system.debug('this.context: ' + this.context);

        //Get bypass Apex from Custom MetaData
        bypassTriggerEventsMap = (bypassTriggerEventsMap != null 
                                  && bypassTriggerEventsMap.containsKey(objName)) 
                                  ? null 
                                  : null;
        
        if(bypassTriggerEventsMap == null){
            getBypassOnObject(objName);
        }

        if(bypassTriggerEventsMap.containsKey(objName)
           && bypassTriggerEventsMap.get(objName).get(this.context)) {
            //system.debug('@BYPASS_TRIGGER FOR Object: ' + objName + ' => Handler: ' + this.context + '? => YES!!!');
            return false;
        } 

        //system.debug('@BYPASS_TRIGGER FOR Object: ' + objName + ' => Handler: ' + this.context + '? => NO!!!');
        return true;
    }
     
    /*@TestVisible
    private String getHandlerName() {
        return String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
    } */

    @TestVisible
    private String getObjectName() {
        //system.debug('THIS: ' + String.valueOf(this));
        return String.valueOf(this).substring(String.valueOf(this).indexOf('=') + 1, String.valueOf(this).indexOf(','));
    } 
    
    /***************************************
    * context methods
    ***************************************/

    // context-specific methods for override
    @TestVisible
    protected virtual void beforeInsert() {
    }
    @TestVisible
    protected virtual void beforeUpdate() {
    }
    @TestVisible
    protected virtual void beforeDelete() {
    }
    @TestVisible
    protected virtual void afterInsert() {
    }
    @TestVisible
    protected virtual void afterUpdate() {
    }
    @TestVisible
    protected virtual void afterDelete() {
    }
    @TestVisible
    protected virtual void afterUndelete() {
    }
    
    /***************************************
    * inner classes
    ***************************************/
    
    // inner class for managing the loop count per handler
    @TestVisible
    private class LoopCount {
        private Integer max;
        private Integer count;
        
        public LoopCount() {
            this.max = 5;
            this.count = 0;
        }
        
        public LoopCount(Integer max) {
            this.max = max;
            this.count = 0;
        }
        
        public Boolean increment() {
            this.count++;
            return this.exceeded();
        }
        
        public Boolean exceeded() {
            if (this.max < 0) return false;
            if (this.count > this.max) {
                    return true;
            }
            return false;
        }
        
        public Integer getMax() {
            return this.max;
        }
        
        public Integer getCount() {
            return this.count;
        }
        
        public void setMax(Integer max) {
                this.max = max;
        }
    }
    
    // possible trigger contexts
    @TestVisible
    private enum TriggerContext {
        BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
        AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
        AFTER_UNDELETE
    }
    
    // exception class
    public class TriggerHandlerException extends Exception {
    }

    @TestVisible
    private void getBypassOnObject(String objName){
		bypassTriggerEventsMap = (bypassTriggerEventsMap == null) ? new Map<String, Map<TriggerContext, Boolean>>() :bypassTriggerEventsMap;
    	
    	if(!bypassTriggerEventsMap.containsKey(objName)){
    		CS_Bypass__c bypass = CS_Bypass__c.getValues(userinfo.getUserId());
    		
    		if(bypass == null){
    			bypass = CS_Bypass__c.getValues(userinfo.getProfileId());
    			
    			/*if(bypass == null){
    				bypass = CS_Bypass__c.getOrgDefaults();
    			}*/
    		}
    		
    		if(bypass != null){
    			if(bypass.BypassAllTriggers__c){
    				bypassTriggerEventsMap.put(objName, getBypassedEvents(null, true));
    			}
    			else{

    				if(bypass.BypassSpecificTriggers__c != null){
                        Set<String> methodsSet = null;

    					for(BypassTriggers__mdt bpt : [SELECT Id, AfterDelete__c, AfterInsert__c, AfterUndelete__c, AfterUpdate__c, 
    					                               BeforeDelete__c, BeforeInsert__c, BeforeUpdate__c, BypassApex__c, ObjectName__c,
                                                       MethodsToBypass__c
    					                               FROM BypassTriggers__mdt
    					                               WHERE Active__c = TRUE
    					                               AND BypassApex__r.DeveloperName = :bypass.BypassSpecificTriggers__c]){
    						
    						bypassTriggerEventsMap.put(bpt.ObjectName__c, getBypassedEvents(bpt, false));

                            if(bpt.MethodsToBypass__c != null){
                                methodsSet = new Set<String>();
                                methodsSet.addAll(bpt.MethodsToBypass__c.replaceAll(' ', '').split(';'));
                                bypassMethodsMap.put(bpt.ObjectName__c, methodsSet);
                            }
    					}
    				}
    			}
    		}
    	}
    	
    	//system.debug('bypassTriggerEventsMap: ' + bypassTriggerEventsMap);
	}

    public Map<TriggerContext, Boolean> getBypassedEvents(BypassTriggers__mdt bypassTrg, Boolean bypassAll){
    	
    	return new Map<TriggerContext, Boolean> {
    		TriggerContext.BEFORE_INSERT => (bypassTrg != null) ? bypassTrg.BeforeInsert__c :bypassAll,
    		TriggerContext.AFTER_INSERT => (bypassTrg != null) ? bypassTrg.AfterInsert__c :bypassAll,
    		TriggerContext.BEFORE_UPDATE => (bypassTrg != null) ? bypassTrg.BeforeUpdate__c :bypassAll,
    		TriggerContext.AFTER_UPDATE => (bypassTrg != null) ? bypassTrg.AfterUpdate__c :bypassAll,
    		TriggerContext.BEFORE_DELETE => (bypassTrg != null) ? bypassTrg.BeforeDelete__c :bypassAll,
    		TriggerContext.AFTER_DELETE => (bypassTrg != null) ? bypassTrg.AfterDelete__c :bypassAll,
    		TriggerContext.AFTER_UNDELETE => (bypassTrg != null) ? bypassTrg.AfterUndelete__c :bypassAll
    	};
    }
}