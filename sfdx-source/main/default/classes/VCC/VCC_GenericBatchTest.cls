/**
 * @description This is a test class for the VCC_GenericBatch class.
 * This is used to test the behavior of the class.
 * @see VCC_GenericBatch
 * @author BAH
 */
@IsTest
private class VCC_GenericBatchTest {
    private static Database.BatchableContext batchableContext;
    private static Database.QueryLocator queryLocator;
    private static VCC_BatchExecutionerTestImplementation batchExecutioner;
    private static final Id ADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
    private static final User ADMIN_USER = (User) VATEST_UserFactory.createTestUser(ADMIN_PROFILE_ID, true);

    /**
     * @description Setup method to create the necessary data for the test class
     */
    @TestSetup
    static void setup() {
        VATEST_PermissionSetRepo permissionSetRepo = new VATEST_PermissionSetRepo();
        Set<Id> permSetIds = new Set<Id>();
        String permSetGroupName = 'VCC_Medical_Provider';
        Id permSetGroupId = [
            SELECT Id
            FROM PermissionSetGroup
            WHERE DeveloperName = :permSetGroupName
            LIMIT 1
        ]
        .Id;
        try {
            List<PermissionSetGroupComponent> components = [
                SELECT PermissionSetId
                FROM PermissionSetGroupComponent
                WHERE PermissionSetGroupId = :permSetGroupId
            ];
            for (PermissionSetGroupComponent comp : components) {
                permSetIds.add(comp.PermissionSetId);
            }
        } catch (Exception genericException) {
            Logger.debug('The following exception has occurred: ' + genericException.getMessage());
            Logger.saveLog();
        }
        permissionSetRepo.assignPermSetsToUser(ADMIN_USER, permSetIds);
        permissionSetRepo.assignPermSetToUser(ADMIN_USER, 'HealthCloudFoundation');
    }
    /**
     * @description Test method to test the initialization of the VCC_GenericBatch class.
     * Positive test case.
     * Checks if the batch executioner is assigned when the batch executioner is not null.
     * @see VCC_GenericBatch
     */
    @IsTest
    static void unitTestGenericBatchConstructorPositive() {
        Boolean isExceptionThrown = false;
        VCC_GenericBatch batch;
        Test.startTest();
        System.runAs(ADMIN_USER) {
            try {
                batchExecutioner = new VCC_BatchExecutionerTestImplementation();
                batch = new VCC_GenericBatch(batchExecutioner);
            } catch (HandledException handledException) {
                isExceptionThrown = true;
            }
        }
        Test.stopTest();
        Assert.isFalse(
            isExceptionThrown,
            'Expected the VCC_GenericBatch constructor to not throw a HandledException when the batch executioner is not null'
        );
        Assert.areEqual(
            batchExecutioner,
            batch.batchExecutioner,
            'Expected the VCC_GenericBatch constructor to assign the batch executioner when the batch executioner is not null'
        );
    }
    /**
     * @description Test method to test the initialization of the VCC_GenericBatch class.
     * Positive test case.
     * Checks if the query is assigned when the batch executioner is not null.
     * @see VCC_GenericBatch
     */
    @IsTest
    static void unitTestGenericBatchConstructorPositiveQueryAssigned() {
        Boolean isExceptionThrown = false;
        VCC_GenericBatch batch;
        Test.startTest();
        System.runAs(ADMIN_USER) {
            try {
                batchExecutioner = new VCC_BatchExecutionerTestImplementation();
                batch = new VCC_GenericBatch(batchExecutioner);
            } catch (HandledException handledException) {
                isExceptionThrown = true;
            }
        }
        Test.stopTest();
        Assert.isFalse(
            isExceptionThrown,
            'Expected the VCC_GenericBatch constructor to not throw a HandledException when the batch executioner is not null'
        );
        Assert.areEqual(
            batchExecutioner.getQueryLocatorString(),
            batch?.query,
            'Expected the VCC_GenericBatch constructor to assign a query when the batch executioner is not null'
        );
    }
    /**
     * @description Test method to test the initialization of the VCC_GenericBatch class.
     * Positive test case.
     * Checks if the bind variables are assigned when the batch executioner is not null.
     * @see VCC_GenericBatch
     */
    @IsTest
    static void unitTestGenericBatchConstructorPositiveBindVariablesAssigned() {
        Boolean isExceptionThrown = false;
        VCC_GenericBatch batch;
        Test.startTest();
        System.runAs(ADMIN_USER) {
            try {
                batchExecutioner = new VCC_BatchExecutionerTestImplementation();
                batch = new VCC_GenericBatch(batchExecutioner);
            } catch (HandledException handledException) {
                isExceptionThrown = true;
            }
        }
        Test.stopTest();
        Assert.isFalse(
            isExceptionThrown,
            'Expected the VCC_GenericBatch constructor to not throw a HandledException when the batch executioner is not null'
        );
        Assert.areEqual(
            batchExecutioner.getBindVariables(),
            batch?.bindVariables,
            'Expected the VCC_GenericBatch constructor to assign bind variables when the batch executioner is not null'
        );
    }
    /**
     * @description Test method to test the initialization of the VCC_GenericBatch class.
     * Negative test case.
     * @see VCC_GenericBatch
     */
    @IsTest
    static void unitTestGenericBatchConstructorNegative() {
        VCC_GenericBatch batch;
        Boolean isExceptionThrown = false;
        Test.startTest();
        System.runAs(ADMIN_USER) {
            try {
                batch = new VCC_GenericBatch(batchExecutioner);
            } catch (HandledException handledException) {
                isExceptionThrown = true;
            }
        }
        Test.stopTest();
        Assert.isTrue(
            isExceptionThrown,
            'Expected the VCC_GenericBatch constructor to throw a HandledException when the batch executioner is null or the query is null'
        );
    }
    /**
     * @description Test method to test the start method of the VCC_GenericBatch class.
     * Positive test case.
     * @see VCC_GenericBatch.start
     */
    @IsTest
    static void unitTestGenericBatchStartPositive() {
        Test.startTest();
        System.runAs(ADMIN_USER) {
            batchExecutioner = new VCC_BatchExecutionerTestImplementation();
            VCC_GenericBatch batch = new VCC_GenericBatch(batchExecutioner);
            queryLocator = batch.start(batchableContext);
        }
        Test.stopTest();
        Assert.areEqual(
            batchExecutioner.getQueryLocator(batchExecutioner.getQueryLocatorString()).toString(),
            queryLocator.toString(),
            'Expected the VCC_GenericBatch start method to return a query locator when the batch executioner is not null'
        ); //made the comparison as strings to prevent comparison errors from different instances of the query locator.
    }
    /**
     * @description Test method to test the start method of the VCC_GenericBatch class.
     * Negative test case.
     * @see VCC_GenericBatch.start
     */
    @IsTest
    static void unitTestGenericBatchStartNegative() {
        Boolean isExceptionThrown = false;
        Test.startTest();
        System.runAs(ADMIN_USER) {
            try {
                VCC_GenericBatch batch = new VCC_GenericBatch(batchExecutioner);
                queryLocator = batch.start(batchableContext);
            } catch (HandledException handledException) {
                isExceptionThrown = true;
            }
        }
        Test.stopTest();
        Assert.isTrue(
            isExceptionThrown && queryLocator == null,
            'Expected the VCC_GenericBatch start method to return to thrown an error when the batch executioner is null & the query should be null'
        );
    }
    /**
     * @description Test method to test the execute method of the VCC_GenericBatch class.
     * Positive test case.
     * @see VCC_GenericBatch.execute
     */
    @IsTest
    static void unitTestGenericBatchExecutePositive() {
        Case testCase = (Case) VATEST_SObjectFactory.createSObject(new Case(), true);
        ServiceAppointment serviceAppointment = (ServiceAppointment) VATEST_SObjectFactory.createSObject(
            new ServiceAppointment(ParentRecordId = testCase.Id),
            false
        );
        Boolean isExceptionThrown = false;
        Test.startTest();
        System.runAs(ADMIN_USER) {
            try {
                batchExecutioner = new VCC_BatchExecutionerTestImplementation();
                VCC_GenericBatch batch = new VCC_GenericBatch(batchExecutioner);
                batch.execute(batchableContext, new List<ServiceAppointment>{ serviceAppointment });
            } catch (VCC_BatchExecutionerTestImplementation.RuntimeException runtimeException) {
                isExceptionThrown = true;
            }
        }
        Test.stopTest();
        Assert.isFalse(
            isExceptionThrown && VCC_BatchExecutionerTestImplementation.assertionHelper,
            'Expected the VCC_GenericBatch execute method to not throw a HandledException when the batch executioner is not null'
        );
    }
    /**
     * @description Test method to test the execute method of the VCC_GenericBatch class.
     * Negative test case.
     * @see VCC_GenericBatch.execute
     */
    @IsTest
    static void unitTestGenericBatchExecuteNegative() {
        Boolean isExceptionThrown = false;
        Test.startTest();
        System.runAs(ADMIN_USER) {
            try {
                batchExecutioner = new VCC_BatchExecutionerTestImplementation();
                VCC_GenericBatch batch = new VCC_GenericBatch(batchExecutioner);
                batch.execute(batchableContext, null);
            } catch (VCC_BatchExecutionerTestImplementation.RuntimeException runtimeException) {
                isExceptionThrown = true;
            }
        }
        Test.stopTest();
        Assert.isTrue(
            isExceptionThrown,
            'Expected the VCC_GenericBatch execute method to throw a RuntimException when the scope is null'
        );
    }
    /**
     * @description Test method to test the finish method of the VCC_GenericBatch class.
     * Positive test case.
     * @see VCC_GenericBatch.finish
     */
    @IsTest
    static void unitTestGenericBatchFinishPositive() {
        Boolean isExceptionThrown = false;
        VCC_GenericBatch batch;
        Test.startTest();
        System.runAs(ADMIN_USER) {
            try {
                batchExecutioner = new VCC_BatchExecutionerTestImplementation();
                batch = new VCC_GenericBatch(batchExecutioner);
                batch.finish(batchableContext);
            } catch (HandledException handledException) {
                //checking if the getJobId method creates a null pointer exception.
                isExceptionThrown = true;
            }
        }
        Test.stopTest();
        Assert.isFalse(
            !isExceptionThrown && !batch.isBatchDone,
            'Expected the VCC_GenericBatch finish method to not throw a HandledException when the batch executioner is not null'
        );
    }
    /**
     * @description Test method to test the finish method of the VCC_GenericBatch class.
     * Negative test case.
     * @see VCC_GenericBatch.finish
     */
    @IsTest
    static void unitTestGenericBatchFinishNegative() {
        Boolean isExceptionThrown = false;
        VCC_GenericBatch batch;
        Test.startTest();
        System.runAs(ADMIN_USER) {
            try {
                batchExecutioner = new VCC_BatchExecutionerTestImplementation();
                batch = new VCC_GenericBatch(batchExecutioner);
                batch.finish(null);
            } catch (HandledException handledException) {
                isExceptionThrown = true;
            }
        }
        Test.stopTest();
        Assert.isTrue(
            isExceptionThrown && !batch.isBatchDone,
            'Expected the VCC_GenericBatch finish method to throw a HandledException when the batch executioner is null'
        );
    }
}
