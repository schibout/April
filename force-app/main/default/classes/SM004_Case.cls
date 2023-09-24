/**
 * @author Comforth dev team
 * @date 17/12/2020
 */
public with sharing class SM004_Case{
    /**
     * @author Comforth dev team
     * @date 21/12/2020
     * 
     *  Changelog:
     *   - MTK 30/11/2021: code refactoring
     */
    public static void alignmentRecordtypeSubtypes(Map<Id, case> oldCases, Map<Id, case> newCases) {

        for (Id caseId : newCases.keySet()) {
            final Case newCase = newCases.get(caseId);
            final Case oldCase = oldCases.get(caseId);

            if (newCase.RecordTypeId != oldCase.RecordTypeId) {
                if (newCase.CaseSubtype__c == oldCase.CaseSubtype__c) {
                    newCase.CaseSubtype__c = null;
                }

                if (
                    newCase.CaseSubtypeFR__c != 'VIP' 
                    && newCase.CaseSubtypeFR__c == oldCase.CaseSubtypeFR__c
                ) {
                    newCase.CaseSubtypeFR__c = null;
                }
            }
        }
    }

    /**
     * @author MTK
     * @date 30/11/2021
     */
    public static void provideCasesPriority(Map<Id, Case> oldCaseById, List<Case> newCases) {

        final Set<Id> caseOwnerIds = new Set<Id>();
        final Set<Id> casePolicyIds = new Set<Id>();
        final Set<Id> caseMemberIds = new Set<Id>();

        final List<Case> casesToEdit = new List<Case>();
        for (Case newCase: newCases) {
            final Case oldCase = oldCaseById?.get(newCase.Id);

            if (
                newCase.Priority == 'High'
                || (
                    oldCase != null
                    && oldCase.OwnerId == newCase.OwnerId
                    && oldCase.Policy__c == newCase.Policy__c
                    && oldCase.MemberUniqueID__c == newCase.MemberUniqueID__c
                )
            ) {
                continue;
            }

            casesToEdit.add(newCase);

            if (newCase.OwnerId != null && newCase.OwnerId.getSObjectType() == User.sObjectType) {
                caseOwnerIds.add(newCase.OwnerId);
            }
            if (newCase.Policy__c != null) {
                casePolicyIds.add(newCase.Policy__c);
            }
            if (newCase.MemberUniqueID__c != null) {
                caseMemberIds.add(newCase.MemberUniqueID__c);
            }
        }

        if (!casesToEdit.isEmpty()) {
            final Map<Id, Group> logTeamById = new Map<Id, Group>([
                SELECT Id
                FROM Group
                WHERE DeveloperName IN ('ParisLOGTeam', 'MexicoLOGTeam', 'BangkokLOGTeam') 
                    AND Type = 'Queue'
            ]);
    
            final Map<Id, String> policyNameById = new Map<Id, String>();
            if (!casePolicyIds.isEmpty()) {
                for (Policy__c policy: [
                    SELECT Id, Name
                    FROM Policy__c
                    WHERE Id IN: casePolicyIds
                ]) {
                    policyNameById.put(policy.Id, policy.Name);
                }
            }
    
            final Map<Id, String> memberNameById = new Map<Id, String>();
            if (!caseMemberIds.isEmpty()) {
                for (Member__c member: [
                    SELECT Id, Name
                    FROM Member__c
                    WHERE Id IN: caseMemberIds
                ]) {
                    memberNameById.put(member.Id, member.Name);
                }
            }
    
            final Set<Id> francePublicGroupMemberIds = new Set<Id>();
            if (!caseOwnerIds.isEmpty()) {
                for (GroupMember gm: [
                    SELECT Id, UserOrGroupId
                    FROM GroupMember
                    WHERE Group.DeveloperName IN ('Paris_LOG_team', 'Mexico_LOG_team', 'Bangkok_LOG_team')
                        AND UserOrGroupId IN: caseOwnerIds
                ]) {
                    francePublicGroupMemberIds.add(gm.UserOrGroupId);
                }
            }
    
            for (Case c: casesToEdit) {
                if (
                    (
                        logTeamById.keySet().contains(c.OwnerId) 
                        || francePublicGroupMemberIds.contains(c.OwnerId)
                    ) && (
                        isStringContainsHighPriorityContractName(policyNameById.get(c.Policy__c))
                        || isStringContainsHighPriorityContractName(memberNameById.get(c.MemberUniqueID__c))
                    )
                ) {
                    c.Priority = 'High';
                }
            }
        }
    }

    private static Boolean isStringContainsHighPriorityContractName(String s) {
        Boolean result = false;
        final Set<String> highPriorityContracts = getHighPriorityContracts();
        if (String.isNotBlank(s)) {
            for (String contractName: highPriorityContracts) {
                if (s.contains(contractName)) {
                    result = true;
                    break;
                }
            }
        }

        return result;
    }

    private static Set<String> highPriorityContracts = null;
    private static Set<String> getHighPriorityContracts() {
        if (SM004_Case.highPriorityContracts == null) {
            final List<HighPriorityContract__mdt> highPriorityContracts = HighPriorityContract__mdt.getAll().values();
            SM004_Case.highPriorityContracts = new Set<String>();
            for (HighPriorityContract__mdt highPriorityContract: highPriorityContracts) {
                SM004_Case.highPriorityContracts.add(highPriorityContract.contractName__c);
            }
        }

        return SM004_Case.highPriorityContracts;
    }
}