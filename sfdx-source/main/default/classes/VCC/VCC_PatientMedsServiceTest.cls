@isTest
public with sharing class VCC_PatientMedsServiceTest {
    // TODO: retrofit with actuall remote calls whenever they're ready 11/15/2022

    @testSetup
    static void makeData() {
        VCC_TestDataFactory.insertUser('System Administrator');
    }
    /**
     * @description create a test user for running tests
     * @return A test user
     */
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
    }

    @isTest
    public static void getActivityLogTest() {
        Boolean isInternalEx;

        Test.startTest();
        System.runAs(getTestUser()) {
            Map<String, Object> activityLog = (Map<String, Object>) JSON.deserializeUntyped(VCC_PatientMedsService.getActivityLog('VCC_ActivityLogMock', null));

            try {
                VCC_PatientMedsService.getActivityLog(null, null);
            } catch (Exception ex) {
                isInternalEx = ex.getTypeName() == 'VCC_InternalException';
            }

            system.assertEquals(true, isInternalEx, 'Expected an internal exception to be thrown');
            system.assert(activityLog.containsKey('data'), 'Expected activity log JSON to contain a property called "data"');
        }
        Test.stopTest();
    }
}
