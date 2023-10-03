global class BA003_AutomationOfPolicyrenewalssV4 implements Database.Batchable<sObject>, Schedulable {
    static Id ownerId = getOwnerId();
    static Integer nbday = NberOfDays__c.getOrgDefaults().NbrOfDays__c.intValue();
    static Date limitDate = date.today().addDays(nbday);
    
    private List<Id> successes = new List<Id>();
    private List<Id> failures = new List<Id>();
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([
            SELECT Id, Contract_No__c, PolicyEndDate__c, TypeOfContract__c,
            PolicyHolder__r.Name, Name, RecordType.DeveloperName, Category__c, Policy_Is_Auto_Renewed__c
            FROM Policy__c 
            WHERE PolicyRenewed__c <> True 
            AND RecordType.DeveloperName = 'PolicyAsiaRT'
            AND Category__c = 'Policy' 
            AND Contract_No__c = NULL
            AND PolicyEndDate__c <= :limitDate
        ]);
    } 
    
    global void execute(Database.BatchableContext bc, List<Policy__c> listPlicy){
        List<Case> lstNwCases = new List<Case>(); 
        for(Policy__c po : listPlicy) {
            lstNwCases.add(createCase(po));
        }
        
        List<Id> successfulCaseIds = handleSaveResults(Database.insert(lstNwCases, false));
        
        updateRenewedPolycies(successfulCaseIds);
    }
   
    private static Id getOwnerId() {
        Group queue = [SELECT id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'PolicyTeam' LIMIT 1];
        if (queue == null) { 
            throw new BA003_AutomationOfPolicyrenewalsException('The Queue must be defined');
        }
        return queue.Id;
    }
    
    private Case createCase(Policy__c po) {
        Case newCase = new Case();
        newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
        newCase.Subject = 'Renewal of' + ' ' + po.Name + ',' + ' ' + po.PolicyHolder__r.Name;
        newCase.Status = (po.Policy_Is_Auto_Renewed__c == true) ? 'Policy to be issued' : 'Policy to be renewed';
        newCase.BusinessOutcome__c = 'Open';
        newCase.Policy__c = po.Id;
        newCase.Origin = 'Other';
        newCase.PolicyType__c = po.TypeOfContract__c;
        newCase.RenewalEffectiveDate__c = po.PolicyEndDate__c.addDays(1);
        newCase.Priority = 'TBC';
        newCase.OwnerId = ownerId;
        newCase.CaseSubtype__c = 'Renewal';
        return newCase;
    }
    /**
     * update polycies to exclude them next run
     */
    private void updateRenewedPolycies(List<Id> caseIds) {
        if (caseIds.isEmpty()) {
            System.debug('No Thing to Update');
        }
         List<Id> polycIds = new List<Id>();
         for (Case cs : [SELECT Policy__c FROM Case WHERE Id IN :caseIds]) {
            polycIds.add(cs.Policy__c);
         } 
         List< Policy__c> policyRenewed = [SELECT id,PolicyRenewed__c FROM Policy__c
                                           WHERE Id IN :polycIds ];
            
        for (Policy__c p : policyRenewed) {
            p.PolicyRenewed__c = true;
        }
        handleSaveResults(Database.update(policyRenewed, false));
    }

    global void finish(Database.BatchableContext bc){
        String result = 'Successes: ' +
            successes.size() +
            ' Failures: ' +
            failures.size();
    }
    
    private List<Id> handleSaveResults(List<Database.SaveResult> saveResults) {
        List<Id> successfulIds = new List<Id>();
        for (Database.SaveResult sr : saveResults) {
            if (sr.isSuccess()) {
                successes.add(sr.getId());
                successfulIds.add(sr.getId());
            } else {
                failures.add(sr.getId());
            }
        }
        return successfulIds;
    }
    global void execute(SchedulableContext sc){
        Database.executeBatch(new BA003_AutomationOfPolicyrenewalssV4());
    }
    
    private class BA003_AutomationOfPolicyrenewalsException extends Exception {}
}

