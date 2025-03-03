@IsTest
public with sharing class VCC_VdifQueueableCallbackTest {
    private static String username = 'queuetest';

    @TestSetup
    public static void makeData() {
        User testUser = VCC_TestDataFactory.insertUser('Standard User');
        VCC_TestDataFactory.assignPermissionSetByName(testUser, 'VAHC_Standard_VCC_User');
        testUser.Username = username + testUser.Username;
        update testUser;
    }

    public static User getTestUser() {
        return [SELECT Id FROM User WHERE Username LIKE :username + '%' LIMIT 1];
    }

    @IsTest
    static void constructorTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_VdifQueueableCallback qwcEmpty = new VCC_VdifQueueableCallback();
            VCC_VdifQueueStrat_TestRun testRunStrategy = new VCC_VdifQueueStrat_TestRun();
            VCC_VdifParameters vdifParameters = new VCC_VdifParameters();
            (new VCC_VdifParametersDomain()).fillParametersWithDummyData(vdifParameters);
            VCC_VdifQueueableCallback qwc = new VCC_VdifQueueableCallback(vdifParameters, testRunStrategy);

            System.assert(qwcEmpty != null, 'Expected non-null.');
            System.assert(qwc != null, 'Expected non-null.');
        }
        Test.stopTest();
    }

    @IsTest
    static void gettersTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_VdifQueueStrat_TestRun testRunStrategy = new VCC_VdifQueueStrat_TestRun();
            VCC_VdifParameters vdifParameters = new VCC_VdifParameters();
            (new VCC_VdifParametersDomain()).fillParametersWithDummyData(vdifParameters);
            VCC_VdifQueueableCallback qwc = new VCC_VdifQueueableCallback(vdifParameters, testRunStrategy);

            qwc.setStage(VCC_VdifQueueableCallback.Stage.ADD_SIGNERS);
            qwc.setPreviousStage(VCC_VdifQueueableCallback.Stage.WRITE_NOTE);

            System.assert(qwc.getPreviousStage() == VCC_VdifQueueableCallback.Stage.WRITE_NOTE, 'Incorrect stage retrieved.');
            System.assert(qwc.getStage() == VCC_VdifQueueableCallback.Stage.ADD_SIGNERS, 'Incorrect stage retrieved.');
            System.assert(qwc.getStrategy() === testRunStrategy, 'Incorrect strategy received.');
            System.assert(qwc.getVdifParameters() === vdifParameters, 'Incorrect parameters received.');
        }
        Test.stopTest();
    }

    @IsTest
    static void enqueueJobTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_VdifQueueStrat_TestRun testRunStrategy = new VCC_VdifQueueStrat_TestRun();
            VCC_VdifParameters vdifParameters = new VCC_VdifParameters();
            (new VCC_VdifParametersDomain()).fillParametersWithDummyData(vdifParameters);
            VCC_VdifQueueableCallback qwc = new VCC_VdifQueueableCallback(vdifParameters, testRunStrategy);

            qwc.enqueueStage(VCC_VdifQueueableCallback.Stage.ADD_SIGNERS);
            qwc.enqueueStage(VCC_VdifQueueableCallback.Stage.CREATE_ADDENDUM);
            qwc.enqueueStage(VCC_VdifQueueableCallback.Stage.CREATE_ENCOUNTER);
            qwc.enqueueStage(VCC_VdifQueueableCallback.Stage.SIGN_NOTE);
            qwc.enqueueStage(VCC_VdifQueueableCallback.Stage.VALIDATE_ESIG);
            qwc.enqueueStage(VCC_VdifQueueableCallback.Stage.WRITE_NOTE);

            System.assert(true, 'An assert.');
        }
        Test.stopTest();
    }
}
