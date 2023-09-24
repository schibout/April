global class BA003_AutomationOfPolicyrenewalss implements Database.Batchable<sObject> , Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        String query = 'SELECT Id, Contract_No__c, PolicyEndDate__c, TypeOfContract__c,PolicyHolder__r.Name, Name, RecordType.developerName, Category__c, Policy_Is_Auto_Renewed__c  FROM Policy__c WHERE RecordType.DeveloperName = \'PolicyAsiaRT\' AND  Category__c = \'Policy\' AND Contract_No__c != \'\'';
        
        return Database.getQueryLocator(query);
        
    } 
    
    global void execute ( Database.BatchableContext bc, List<Policy__c> listPlicy){
        //Integer d = 60;
        System.debug('@@@@@@@@@@@@@@@@');
        Date myDate = date.today();
        List<case> lstNwCases = new List<case>(); 
        Map<String,Group> mapQueues = new Map<String,Group>();
        for(Group queue : [SELECT id,NAme,DeveloperName  FROM GROUP WHERE Type = 'Queue' ]){
            mapQueues.put(queue.DeveloperName,queue);
        }
        Map<id,String> mappoTyp = new Map<id,String>();
        NberOfDays__c NbrDays = NberOfDays__c.getOrgDefaults();
        
        Integer nbday = NbrDays.NbrOfDays__c.intValue();
        
        for(Policy__c  po: listPlicy ){
            
            If (po.RecordType.DeveloperName =='PolicyAsiaRT' &&  po.Category__c == 'Policy' && po.Contract_No__c != null){
                
                if(po.PolicyEndDate__c == myDate.addDays (nbday)){
                    
                    
                    if( po.Policy_Is_Auto_Renewed__c == true ){
                        
                        // String TypContact =  po.TypeOfContract__c;
                        
                        String potype =  po.TypeOfContract__c;   
                        //      mappoTyp.put(potype.DeveloperName, potype);
                        
                        case newcases = new   case();   
                        newcases.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
                        newcases.Subject = 'Renewal of'+' '+ po.Name + ',' + ' '+ po.PolicyHolder__r.Name;
                        newcases.Status   = 'Policy to be issued';
                        newcases.BusinessOutcome__c = 'Open';
                        newcases.Policy__c = po.Id;
                        newcases.Origin = 'Other';
                        newcases.PolicyType__c = potype;
                        newcases.RenewalEffectiveDate__c = po.PolicyEndDate__c.addDays(1);
                        newcases.Priority = 'TBC';
                        newcases.OwnerId = mapQueues.get('PolicyTeam').Id;
                        newcases.CaseSubtype__c = 'Renewal';
                        lstNwCases.add(newcases);
                        
                    }
                    else{
                        
                        // String TypContact =  po.TypeOfContract__c;
                        
                        String potype =  po.TypeOfContract__c;
                        //      mappoTyp.put(potype.DeveloperName, potype);
                        
                        case newcases = new   case();   
                        newcases.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
                        newcases.Subject = 'Renewal of'+' '+ po.Name + ',' + ' '+ po.PolicyHolder__r.Name;
                        newcases.Status   = 'Policy to be renewed';
                        newcases.BusinessOutcome__c = 'Open';
                        newcases.Policy__c = po.Id;
                        newcases.Origin = 'Other';
                        newcases.PolicyType__c = potype;
                        newcases.RenewalEffectiveDate__c = po.PolicyEndDate__c.addDays(1);
                        newcases.Priority = 'TBC';
                        newcases.OwnerId = mapQueues.get('PolicyTeam').Id;
                        newcases.CaseSubtype__c = 'Renewal';
                        lstNwCases.add(newcases);
                        
                        
                    }
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
        Database.executeBatch(new BA003_AutomationOfPolicyrenewalss());
    }
    
}