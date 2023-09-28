    global class BA003_AutomationOfPolicyrenewalssV3 implements Database.Batchable<sObject> , Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        NberOfDays__c nbrDays = NberOfDays__c.getOrgDefaults();
        //String query = 'SELECT Id, Contract_No__c, PolicyEndDate__c, TypeOfContract__c,PolicyHolder__r.Name, Name, RecordType.developerName, Category__c, Policy_Is_Auto_Renewed__c  FROM Policy__c WHERE PolicyRenewed__c <> True AND RecordType.DeveloperName = \'PolicyAsiaRT\' AND  Category__c = \'Policy\' AND Contract_No__c = \'\'';
        Date maxLimitDate = Date.today().addDays(nbrDays);
        return Database.getQueryLocator([SELECT Id, Contract_No__c, PolicyEndDate__c, TypeOfContract__c,PolicyHolder__r.Name, Name, RecordType.developerName, Category__c, Policy_Is_Auto_Renewed__c  
                                        FROM Policy__c 
                                        WHERE RecordType.DeveloperName = 'PolicyAsiaRT' 
                                        AND  Category__c = 'Policy' 
                                        AND  PolicyEndDate__c >= :maxLimitDate 
                                        AND  Contract_No__c = null ]);
        
    } 
    //Script a exécuter pour lancer le batch : id batchjobid = Database.executeBatch(new BA003_AutomationOfPolicyrenewalssV3());
    global void execute ( Database.BatchableContext bc, List<Policy__c> listPlicy){
        //Integer d = 60;
        System.debug('@@@@@@@@@@@@@@@@');
        List<Id> policyRenewedIds = new List<Id>();
        List<Id> insertedCaseIds = new List<Id>();
        List<Policy__c> policyRenewed = new List<Policy__c>();
        List<Policy__c> policyToUpdate = new List<Policy__c>();
        List<Case> insertedCase = new List<Case>();
        Date myDate = date.today();
        List<case> lstNwCases = new List<case>(); 
        Map<String,Group> mapQueues = new Map<String,Group>();
        for(Group queue : [SELECT id,NAme,DeveloperName  FROM GROUP WHERE Type = 'Queue' ]){
            mapQueues.put(queue.DeveloperName,queue);
        }
        Map<id,String> mappoTyp = new Map<id,String>();
        NberOfDays__c nbrDays = NberOfDays__c.getOrgDefaults();
        
        Integer nbday = nbrDays.NbrOfDays__c.intValue();
        
        for(Policy__c  po: listPlicy ){
            
            If (po.RecordType.DeveloperName =='PolicyAsiaRT' &&  po.Category__c == 'Policy' && po.Contract_No__c == null){
                
                if(po.PolicyEndDate__c <= myDate.addDays (nbday)){
                    
                    
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
                        lstNwCases.add(createCase(po, potype, mapQueues));
                        
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
        
        //INSERT lstNwCases ;
        Database.SaveResult[] srList = Database.insert(lstNwCases, false);
        
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted Case ID: ' + sr.getId());
                insertedCaseIds.add(sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage()); 
                }
            }
        }
        
        if (!insertedCaseIds.isEmpty()) {
            insertedCase  = [select Id, Policy__c from Case WHERE Id in:insertedCaseIds];
            if (!insertedCase.isEmpty()) {
                for (Case c : insertedCase) {
                    policyRenewedIds.add(c.Policy__c);
                }
                if (!policyRenewedIds.isEmpty()) {
                    policyRenewed = [Select id, PolicyRenewed__c from Policy__c where id in:policyRenewedIds];
                    for (Policy__c p : policyRenewed) {
                        p.PolicyRenewed__c = true;
                        policyToUpdate.add(p);
                    }
                    update policyToUpdate;
                }
            }
        }
        
        
        
        
        
        
    }
    /**Methode to create a new Case */
    private Case createCase(Policy__c po, String potype, Map<String, Group> mapQueues) {
        Case newCase = new Case();
        newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
        newCase.Subject = 'Renewal of' + ' ' + po.Name + ',' + ' ' + po.PolicyHolder__r.Name;
        newCase.Status = (po.Policy_Is_Auto_Renewed__c == true) ? 'Policy to be issued' : 'Policy to be renewed';
        newCase.BusinessOutcome__c = 'Open';
        newCase.Policy__c = po.Id;
        newCase.Origin = 'Other';
        newCase.PolicyType__c = potype;
        newCase.RenewalEffectiveDate__c = po.PolicyEndDate__c.addDays(1);
        newCase.Priority = 'TBC';
        newCase.OwnerId = mapQueues.get('PolicyTeam').Id;
        newCase.CaseSubtype__c = 'Renewal';
        return newCase;
    }
    global void finish(Database.BatchableContext bc){
        
    }
    
    global void execute(SchedulableContext sc){
        Database.executeBatch(new BA003_AutomationOfPolicyrenewalss());
    }
    
}