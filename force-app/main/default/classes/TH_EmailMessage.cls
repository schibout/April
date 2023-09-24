/**
 * @author Comforth Dev Team
 * @date 17/12/2020
 * @group Trigger Handler
 * @description Trigger Handler for EmailMessage Object
 *
 *  Changelog:
 *   - MTK 29/11/2021: execute 'copyClosedCase' in after insert instead of before insert
 */
public without sharing class TH_EmailMessage extends TH_TriggerHandler{
    //@IMPORTANT: SOBJ_NAME must always be declared first
    private static final String SOBJ_NAME = Constants.OBJ_API_EMAILMESSAGE;
    public static Set<String> setBypassMethods = (TH_TriggerHandler.bypassMethodsMap != null && TH_TriggerHandler.bypassMethodsMap.containsKey(SOBJ_NAME)) 
        ? TH_TriggerHandler.bypassMethodsMap.get(SOBJ_NAME) 
        : new Set<String>();

    public TH_EmailMessage() {
    }

    public override void afterInsert() {
        if (!setBypassMethods.contains('copyClosedCase')){
            SM002_EmailMessage.copyClosedCase((List<EmailMessage>)Trigger.new );
        }
    }
}