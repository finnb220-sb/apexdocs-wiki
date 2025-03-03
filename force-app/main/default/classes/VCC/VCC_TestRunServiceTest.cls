@IsTest
public with sharing class VCC_TestRunServiceTest {
    private static String username = 'testRunService';

    @TestSetup
    public static void makeData() {
        User testUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.assignPermissionSetByName(testUser, 'VCC_Integration_Test_Utility_Base');
        testUser.Username = username + testUser.Username;
        update testUser;
    }

    public static User getTestUser() {
        return [SELECT Id FROM User WHERE Username LIKE :username + '%' LIMIT 1];
    }

    @IsTest
    static void stubTest() {
        Test.startTest();
        VCC_Stub stub = VCC_TestRunService.stub();
        System.assert(VCC_TestRunService.instance === stub.instance, 'Expected privateInstance to be stub.');
        Test.stopTest();
    }

    @IsTest
    static void insertTestRunTestHappy() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Test_Run__c testRun = new VCC_Test_Run__c(
                RecordTypeId = VCC_Test_Run__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Default').getRecordTypeId()
            );
            VCC_TestRunService.instance.insertTestRun(testRun);
            System.assert(testRun.Id != null, 'Expected a non-null value from Id.');
        }
        Test.stopTest();
    }

    @IsTest
    static void updateTestRunTestHappy() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Test_Run__c testRun = new VCC_Test_Run__c(
                RecordTypeId = VCC_Test_Run__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Default').getRecordTypeId()
            );
            insert testRun;
            VCC_TestRunService.instance.updateTestRun(testRun);
        }
        Test.stopTest();
    }

    @IsTest
    static void validateVdifTestRunTestHappy() {
        Test.startTest();
        try {
            VCC_TestRunService.instance.validateVdifTestConfiguration(
                new VCC_Test_Configuration_Data__c(VCC_ICN__c = '13456', VCC_Note_Title_IEN__c = '12345', VCC_Location_IEN__c = '12345')
            );
        } catch (Exception e) {
            Assert.fail('Unexpected exception caught.');
        }
        Test.stopTest();
    }

    @IsTest
    static void validateVdifTestRunTestSad() {
        Test.startTest();
        try {
            VCC_TestRunService.instance.validateVdifTestConfiguration(new VCC_Test_Configuration_Data__c(VCC_ICN__c = '13456', VCC_Note_Title_IEN__c = '12345'));
            Assert.fail('Did not catch exception.');
        } catch (Exception e) {
            Assert.isNotNull(e.getMessage(), 'Expected an exception with a message.');
        }
        Test.stopTest();
    }
}
