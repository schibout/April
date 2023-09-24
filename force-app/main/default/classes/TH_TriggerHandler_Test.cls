@isTest
private class TH_TriggerHandler_Test {
	
	@testSetup static void createData(){
        User user = new TestFactory.UserFactory().createRunningUserAdministrator();
        user.Email = 'mytest@test.com';
        database.insert(user, true);
    }
    
    @isTest
    static void increase_coverage_TEST1(){ 
        User usr = [SELECT Id FROM User WHERE Email = 'mytest@test.com' LIMIT 1];
        System.runAs(usr){
            Test.startTest();
            	TH_TriggerHandler th = new TH_TriggerHandler();
				th.beforeDelete();
            	th.beforeDelete();
            	th.afterUndelete();
            	th.setMaxLoopCount(2);
            	th.clearMaxLoopCount();
            	
            TH_TriggerHandler.bypass('');
            	TH_TriggerHandler.clearBypass('');
            	TH_TriggerHandler.isBypassed('');
            	TH_TriggerHandler.clearAllBypasses();
            Test.stopTest();
        }
    }
    
    @isTest
    static void increase_coverage_TEST2(){ 
        User usr = [SELECT Id FROM User WHERE Email = 'mytest@test.com' LIMIT 1];
        System.runAs(usr){
            Test.startTest();
            	TH_TriggerHandler.LoopCount lpC = new TH_TriggerHandler.LoopCount();
				TH_TriggerHandler.LoopCount lpC2 = new TH_TriggerHandler.LoopCount(2);
            	lpC2.increment();
            	lpC2.getMax();
            	lpC2.getCount();
            	lpC2.setMax(2);
            Test.stopTest();
        }
    }
    
    @isTest
    static void increase_coverage_TEST3(){ 
        User usr = [SELECT Id FROM User WHERE Email = 'mytest@test.com' LIMIT 1]; 
        System.runAs(usr){
            Test.startTest();
            	TH_TriggerHandler lpC = new TH_TriggerHandler();
            lpC.getBypassedEvents(null, true);
            Test.stopTest();
        } 
    }
}