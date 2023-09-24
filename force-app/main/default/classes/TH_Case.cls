/**
  * @author Comforth Dev Team
 * @date 23.05.2019
 * @group Trigger Handler
 * @description Trigger Handler for Case Object
 */
public without sharing class TH_Case extends TH_TriggerHandler {

    //@IMPORTANT: SOBJ_NAME must always be declared first
    private static final String SOBJ_NAME = Constants.OBJ_API_CASE;
    public static Set<String> setBypassMethods = (TH_TriggerHandler.bypassMethodsMap != null && TH_TriggerHandler.bypassMethodsMap.containsKey(SOBJ_NAME)) 
        ? TH_TriggerHandler.bypassMethodsMap.get(SOBJ_NAME) :new Set<String>();

    public TH_Case() {
    }
    

    /**
     * @author MTK
     * @date 30/11/2021
     *
     *  Changelog:
     *   - MTK 30/11/2021: add provideCasesPriorityOnCaseCreation method
     *   - MTK 22/12/2021: rename method provideCasesPriorityOnCaseCreation to provideCasesPriority method
     */
    public override void beforeInsert() {
        system.debug('BEFORE INSERT');

        if (!setBypassMethods.contains('provideCasesPriority')) {
            SM004_Case.provideCasesPriority(null, (List<Case>) Trigger.new);
        }
    }

    /**
     * @author  Comforth dev team
     * @date 
     * @description Handler Method for Before Insert Event
     *  Changelog:
     *   - MTK 30/11/2021: code refactoring
     *   - MTK 22/12/2021: add provideCasesPriority method
     */
    public override void beforeUpdate() {
        system.debug('BEFORE UPDATE');
        
        if (!setBypassMethods.contains('alignmentRecordtypeSubtype')) {
            SM004_Case.alignmentRecordtypeSubtypes((Map<Id, Case>) Trigger.oldMap, (Map<Id, Case>) Trigger.newMap);
        }

        if (!setBypassMethods.contains('provideCasesPriority')) {
            SM004_Case.provideCasesPriority((Map<Id, Case>) Trigger.oldMap, (List<Case>) Trigger.new);
        }
    }

}