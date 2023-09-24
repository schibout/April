trigger CaseTrigger on Case (before insert, before update) {
    new TH_Case().run();
}