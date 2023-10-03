global class BA003_AutomationOfPolicyrenewalssV2 implements Database.Batchable<sObject> , Schedulable {
    static Id ownerId = getOwnerId() ;
    static Date limitDate ;
    private List<Id> successes = new List<Id>();
    private List<Id> failures = new List<Id>();
    private static String result = '';
    private static Date lastRunDateWithSuccess = Date.today();
    static {
         NberOfDays__c nbrDays = NberOfDays__c.getOrgDefaults();
         Integer nbday = nbrDays.NbrOfDays__c.intValue();
         if (nbday ==null) nbday = 60 ;
        List<AsyncApexJob> previousJobList = [SELECT Id, CompletedDate  FROM AsyncApexJob 
                                              WHERE ApexClass.Name ='BA003_AutomationOfPolicyrenewalssV2' 
                                              AND CompletedDate != null ORDER BY CompletedDate desc];
        Integer  nbJour = 0 ;
        if (previousJobList.size()> 0)   { 
            Date lastRunDateWithSuccess = previousJobList[0].CompletedDate.date(); // Convert DateTime to Date
            Integer daysSinceLastRun = lastRunDateWithSuccess.daysBetween(Date.today()); // Calculate days between
            nbday = nbday + daysSinceLastRun - 1 ; // Update nbday batch run everyDay
        }
        limitDate = date.today().addDays (nbday);
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        System.debug('entering start Mathode');
        return Database.getQueryLocator([SELECT Id, Contract_No__c, PolicyEndDate__c, TypeOfContract__c
                                               ,PolicyHolder__r.Name, Name, RecordType.developerName
                                               , Category__c, Policy_Is_Auto_Renewed__c
                                                FROM Policy__c WHERE PolicyRenewed__c <> True 
                                                 AND RecordType.DeveloperName = 'PolicyAsiaRT'
                                                 AND  Category__c = 'Policy' 
                                                 AND Contract_No__c = NULL
                                                 AND PolicyEndDate__c >= :lastRunDateWithSuccess
                                                 AND PolicyEndDate__c <= :limitDate ]);
        
    } 
    
    global void execute ( Database.BatchableContext bc, List<Policy__c> listPlicy){
        System.debug('entering execute Mathode');
        List<Id> insertedCaseIds = new List<Id>();
        List<case> lstNwCases = new List<case>(); 
        //
        Map<Id, Case> mapPolicyToCase = new Map<Id, Case>();
        for(Case c : [SELECT Id, policy__c FROM Case 
                      WHERE policy__c IN :listPlicy
                      AND CaseSubtype__c = 'Renewal' ]) {
            mapPolicyToCase.put(c.policy__c, c);
        }
                                                                                    
        for(Policy__c  po: listPlicy ){
                if (mapPolicyToCase.get(po.Id) != null) continue ;
                String potype =  po.TypeOfContract__c;
                lstNwCases.add(createCase(po));
        }
        
        Database.SaveResult[] srList = Database.insert(lstNwCases, false);
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                System.debug('Successfully inserted Case ID: ' + sr.getId());
                insertedCaseIds.add(sr.getId());
            }
            else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage()); 
                }
            }
        }
        updateRenewedPolycies(insertedCaseIds);
    }
   
    private static Id getOwnerId () {
        Map<String,Group> mapQueues = new Map<String,Group>();
        for(Group queue : [SELECT id,NAme,DeveloperName  FROM GROUP WHERE Type = 'Queue' ]){
            mapQueues.put(queue.DeveloperName,queue);
        }
        Id ownerId =  mapQueues.get('PolicyTeam').Id ;
        if ( ownerId ==null )  { 
            throw new BA003_AutomationOfPolicyrenewalsException('The Queue must be defined');
        }
        return ownerId ;
    }
    /**Methode to create a new Case */
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
        List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
        saveResults = Database.update(policyRenewed, false);
        for (Database.SaveResult sr : saveResults) {
            if (sr.isSuccess()) {
                successes.add(sr.id);
            } else {
                failures.add(sr.id);
            }
        }
        
    }
    global void finish(Database.BatchableContext bc){
        result =
            'Successes: ' +
            successes.size() +
            ' Failures: ' +
            failures.size();
    }
    
    global void execute(SchedulableContext sc){
        Database.executeBatch(new BA003_AutomationOfPolicyrenewalssV2());
    }
    
    global static void run(){
        Database.executeBatch(new BA003_AutomationOfPolicyrenewalssV2());
    }
    private class BA003_AutomationOfPolicyrenewalsException extends Exception {
        
    }
}