@IsTest
public with sharing class VCC_TestRunCalloutServiceTest {
    private static String username = 'trcs';

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
        System.runAs(getTestUser()) {
            VCC_Stub testRunCalloutServiceStub = VCC_TestRunCalloutService.stub();
            System.assert(testRunCalloutServiceStub.instance === VCC_TestRunCalloutService.instance, 'Expected to receive stub from instance.');
        }
        Test.stopTest();
    }

    @IsTest
    static void insertNewTestRunCalloutTestHappy() {
        Test.startTest();

        System.runAs(getTestUser()) {
            VCC_Test_Run__c testRun = new VCC_Test_Run__c();
            insert testRun;
            VCC_Callout_Data__c calloutData = new VCC_Callout_Data__c();
            insert calloutData;

            VCC_Test_Run_Callout__c trcd = VCC_TestRunCalloutService.instance.insertNewTestRunCallout(testRun, calloutData);
            System.assert(trcd.Id != null, 'Expected record to be inserted.');
        }
        Test.stopTest();
    }

    @IsTest
    static void insertNewTestRunCalloutTestSad() {
        System.DmlException expectedException;
        VCC_Test_Run_Callout__c trcd;

        Test.startTest();
        System.runAs(getTestUser()) {
            try {
                trcd = VCC_TestRunCalloutService.instance.insertNewTestRunCallout(null, null);
            } catch (System.DmlException e) {
                expectedException = e;
            }

            System.assert(trcd == null, 'Expected null.');
            System.assert(expectedException != null, 'Expected an exception.');
        }
        Test.stopTest();
    }
}
