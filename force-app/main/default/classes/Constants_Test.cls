@IsTest
private class Constants_Test {
    
    @isTest
    static void increaseCoverage_Test(){
        
        //Trigger Events
        string BEFORE_INSERT = Constants.BEFORE_INSERT;
        string AFTER_INSERT = Constants.AFTER_INSERT;
        string BEFORE_UPDATE = Constants.BEFORE_UPDATE;
        string AFTER_UPDATE = Constants.AFTER_UPDATE;
        string BEFORE_DELETE = Constants.BEFORE_DELETE;
        string AFTER_DELETE = Constants.AFTER_DELETE;
        string AFTER_UNDELETE = Constants.AFTER_UNDELETE;
        
        
        //Object API Name
        string OBJ_API_USER = Constants.OBJ_API_USER;
        string OBJ_API_PORTALUSER = Constants.OBJ_API_PORTALUSER;
        string OBJ_API_ACCOUNT = Constants.OBJ_API_ACCOUNT;
        string OBJ_API_CASE = Constants.OBJ_API_CASE;
        
        String objAPIAccount = 'Account';

        System.assertEquals(objAPIAccount, Constants.OBJ_API_ACCOUNT, 'Account object API Name');
    }
}