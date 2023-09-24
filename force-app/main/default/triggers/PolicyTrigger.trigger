trigger PolicyTrigger on Policy__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new TH_Policy().run();
}