/**
 * VCC_AppointmentSlotUtilLogicTest
 * @description class is used to test the logic of the VCC_AppointmentSlotUtilLogic class.
 * @author Booz Allen
 * @see VCC_AppointmentSlotUtilLogic
 */
@IsTest
private class VCC_AppointmentSlotUtilLogicTest {
    /**
     * @description method is used to test the isEmpty method of the VCC_AppointmentSlotUtilLogic class.
     * Positive test case where the list has 2 elements.
     */
    @IsTest
    static void unitTestIsEmptyPositive() {
        List<VCC_Appointment_Utilization__c> testUtilList = (List<VCC_Appointment_Utilization__c>) VATEST_SObjectFactory.createSObjects(
            new VCC_Appointment_Utilization__c(),
            2
        );
        Test.startTest();
        Boolean result = VCC_AppointmentSlotUtilLogic.isEmpty(testUtilList);
        Test.stopTest();
        Assert.isFalse(result, 'Expected isEmpty to return false as list has 2 elements.');
    }

    /**
     * @description method is used to test the isEmpty method of the VCC_AppointmentSlotUtilLogic class.
     * Negative test case where the list is null.
     */
    @IsTest
    static void unitTestIsEmptyNegative() {
        List<VCC_Appointment_Utilization__c> testUtilList = new List<VCC_Appointment_Utilization__c>();
        Test.startTest();
        Boolean result = VCC_AppointmentSlotUtilLogic.isEmpty(testUtilList);
        Boolean result2 = VCC_AppointmentSlotUtilLogic.isEmpty(null);
        Test.stopTest();
        Assert.isTrue(result, 'Expected the output of isEmpty method to return true for an empty list.');
        Assert.isTrue(result2, 'Expected the output of isEmpty method to return true for a null list passed as input.');
    }

    /**
     * @description method is used to test the getAggrScheduleRepo method for properly initialized.
     * Positive test case where the repo is initialized.
     */
    @IsTest
    static void unitTestGetAggrScheduleRepoPositive() {
        Test.startTest();
        VCR_AppointmentScheduleAggrRepo repo = VCC_AppointmentSlotUtilLogic.aggrScheduleRepo;
        Test.stopTest();
        Assert.isNotNull(repo, 'Test should have returned a non-null instance of the VCR_AppointmentScheduleAggrRepo.');
    }

    /**
     * @description Method to test that aggrSchedule Repo getter does not construct more than one instance.
     * Negative test case where the repo is not initialized.
     */
    @IsTest
    static void unitTestGetAggrScheduleRepoNegative() {
        VCR_AppointmentScheduleAggrRepo expectedRepo = new VCR_AppointmentScheduleAggrRepo();
        VCC_AppointmentSlotUtilLogic.aggrScheduleRepo = expectedRepo;
        Test.startTest();
        VCR_AppointmentScheduleAggrRepo actualRepo = VCC_AppointmentSlotUtilLogic.aggrScheduleRepo;
        Test.stopTest();
        Assert.areEqual(
            expectedRepo,
            actualRepo,
            'Expected this test to return the injected instance of the repo instead of constructing a new instance.'
        );
    }

    /**
     * @description method is used to test the getAppointmentAggrDate method.
     * Positive test case where the method returns the date of the AppointmentScheduleAggr record.
     */
    @IsTest
    static void unitTestGetAppointmentDateWithDateInstancePositive() {
        AppointmentScheduleAggr testAggr = new AppointmentScheduleAggr();
        Date testDate = Date.newInstance(2023, 1, 1);
        testAggr.AppointmentDate = testDate;
        Test.startTest();
        Date result = VCC_AppointmentSlotUtilLogic.getAppointmentAggrDate(testAggr);
        Test.stopTest();
        Assert.areEqual(
            testDate,
            result,
            'Expected to return the date of the testAggr record that was passed to getAppointmentAggrDate.'
        );
    }

    /**
     * @description method is used to test the getAppointmentAggrDate method.
     * Negative test case where the method returns null when the input is null.
     */
    @IsTest
    static void unitTestGetAppointmentDateWithInvalidInputNegative() {
        Test.startTest();
        Date result = VCC_AppointmentSlotUtilLogic.getAppointmentAggrDate(null);
        Test.stopTest();
        Assert.areEqual(null, result, 'The method should return null if null input is provided.');
    }

    /**
     * @description test case for upsertAppointmentUtilization method.
     * Negative test case where the input is null.
     */
    @IsTest
    static void unitTestUpsertAppointmentUtilizationNegative() {
        Test.startTest();
        VCC_AppointmentSlotUtilLogic myClassInstance = new VCC_AppointmentSlotUtilLogic();
        myClassInstance.upsertAppointmentUtilization(null);
        Test.stopTest();
        Assert.areEqual(
            0,
            Limits.getDmlStatements(),
            'Expected No DML to be committed when passing null into upsertAppointmentUtilization method.'
        );
    }

    /**
     * @description test case for LogFailedRecords method.
     * Negative test case where the input is an empty list.
     */
    @IsTest
    static void unitTestLogFailedRecordsNegative() {
        List<VCC_Appointment_Utilization__c> emptyList = new List<VCC_Appointment_Utilization__c>();
        Test.startTest();
        VCC_AppointmentSlotUtilLogic myClassInstance = new VCC_AppointmentSlotUtilLogic();
        myClassInstance.logFailedRecords(emptyList);
        Test.stopTest();
        Assert.areEqual(
            0,
            Limits.getDmlStatements(),
            'No DML statements should have been executed when passing an empty list to logFailedRecords.'
        );
    }

    /**
     * @description test case for CreateUtilization method.
     * Positive test case where the input is valid.
     */
    @IsTest
    static void unitTestCreateUtilizationPositive() {
        List<AppointmentScheduleAggr> testAggrList = (List<AppointmentScheduleAggr>) VATEST_SObjectFactory.createSObjects(
            new AppointmentScheduleAggr(),
            1
        );
        List<VCC_Appointment_Utilization__c> testUtilList = (List<VCC_Appointment_Utilization__c>) VATEST_SObjectFactory.createSObjects(
            new VCC_Appointment_Utilization__c(),
            10
        );

        Test.startTest();
        VCC_AppointmentSlotUtilLogic myClassInstance = new VCC_AppointmentSlotUtilLogic();
        myClassInstance.createUtilization(testAggrList.get(0), testUtilList);
        Test.stopTest();
        Assert.areEqual(
            11,
            testUtilList.size(),
            'This method should have added a new record to the list which indicates a successful creation.'
        );
    }

    /**
     * @description test case for updateUtilization method.
     * Positive test case where the input is valid.
     */
    @IsTest
    static void unitTestUpdateUtilizationPositive() {
        Integer originalResourceUtilCount = 5;
        List<AppointmentScheduleAggr> testAggrList = (List<AppointmentScheduleAggr>) VATEST_SObjectFactory.createSObjects(
            new AppointmentScheduleAggr(),
            1
        );
        List<VCC_Appointment_Utilization__c> testUtilList = (List<VCC_Appointment_Utilization__c>) VATEST_SObjectFactory.createSObjects(
            new VCC_Appointment_Utilization__c(VCC_Count_of_Used_Appointment_Slots__c = originalResourceUtilCount),
            1
        );
        Test.startTest();
        VCC_AppointmentSlotUtilLogic myClassInstance = new VCC_AppointmentSlotUtilLogic();
        myClassInstance.updateUtilization(testAggrList.get(0), testUtilList.get(0), testUtilList);
        Test.stopTest();
        Assert.isNull(
            testUtilList.get(0).VCC_Count_of_Used_Appointment_Slots__c,
            'Expected updateUtilization method to update VCC_Count_of_User_Appointment_Slots_c on utilization record.'
        );
    }

    /**
     * @description test case for updateUtilization method.
     * Negative test case where the input aggr record is null.
     */
    @IsTest
    static void unitTestUpdateUtilizationNegative() {
        Integer originalResourceUtilCount = 5;
        List<AppointmentScheduleAggr> testAggrList = (List<AppointmentScheduleAggr>) VATEST_SObjectFactory.createSObjects(
            new AppointmentScheduleAggr(),
            1
        );
        List<VCC_Appointment_Utilization__c> testUtilList = (List<VCC_Appointment_Utilization__c>) VATEST_SObjectFactory.createSObjects(
            new VCC_Appointment_Utilization__c(VCC_Count_of_Used_Appointment_Slots__c = originalResourceUtilCount),
            1
        );
        Test.startTest();
        VCC_AppointmentSlotUtilLogic myClassInstance = new VCC_AppointmentSlotUtilLogic();
        myClassInstance.updateUtilization(null, testUtilList.get(0), testUtilList);
        Test.stopTest();
        Assert.areNotEqual(
            testAggrList.get(0).ResourceUtilizationCount,
            testUtilList.get(0).VCC_Count_of_Used_Appointment_Slots__c,
            'No updates should have been done in this test when passing a null aggr record, since the method should return on null values.'
        );
    }

    /**
     * @description test case for isUtilizationExists method.
     * Positive test case where the same record is passed in.
     */
    @IsTest
    static void unitTestIsUtilizationExistsPositive() {
        List<AppointmentScheduleAggr> testAggrList = (List<AppointmentScheduleAggr>) VATEST_SObjectFactory.createSObjects(
            new AppointmentScheduleAggr(),
            1
        );
        List<VCC_Appointment_Utilization__c> testUtilList = (List<VCC_Appointment_Utilization__c>) VATEST_SObjectFactory.createSObjects(
            new VCC_Appointment_Utilization__c(),
            1
        );

        Test.startTest();
        VCC_AppointmentSlotUtilLogic myClassInstance = new VCC_AppointmentSlotUtilLogic();
        Boolean isSameRecord = myClassInstance.isUtilizationExists(testAggrList.get(0), testUtilList.get(0));
        Test.stopTest();
        Assert.isTrue(isSameRecord, 'isUtilizationExists should return true when the same record is passed in.');
    }

    /**
     * @description test case for isUtilizationExists method.
     * Negative test case where the aggr record is null.
     */
    @IsTest
    static void unitTestIsUtilizationExistsNegative() {
        List<VCC_Appointment_Utilization__c> testUtilList = (List<VCC_Appointment_Utilization__c>) VATEST_SObjectFactory.createSObjects(
            new VCC_Appointment_Utilization__c(),
            1
        );

        Test.startTest();
        VCC_AppointmentSlotUtilLogic myClassInstance = new VCC_AppointmentSlotUtilLogic();
        Boolean isSameRecord = myClassInstance.isUtilizationExists(null, testUtilList.get(0));
        Test.stopTest();
        Assert.isFalse(
            isSameRecord,
            'isUtilizationExists should have returned false when passing in a null aggr record.'
        );
    }

    /**
     * @description unit test for test compareAndUpdateRecords method.
     * Positive test case where the records are compared and updated.
     */
    @IsTest
    static void unitTestCompareAndUpdateRecordsPositive() {
        List<VCC_Appointment_Utilization__c> failedRecords = new List<VCC_Appointment_Utilization__c>();
        List<VCC_Appointment_Utilization__c> testUtilList = (List<VCC_Appointment_Utilization__c>) VATEST_SObjectFactory.createSObjects(
            new VCC_Appointment_Utilization__c(VCC_Count_of_Used_Appointment_Slots__c = 1),
            1,
            false
        );
        List<AppointmentScheduleAggr> testAggrList = (List<AppointmentScheduleAggr>) VATEST_SObjectFactory.createSObjects(
            new AppointmentScheduleAggr(),
            1,
            false
        );
        VCR_AppointmentUtilizationRepo stubUtilRepo = (VCR_AppointmentUtilizationRepo) new VATEST_StubBuilder(
                VCR_AppointmentUtilizationRepo.class
            )
            .mockingMethodCall('upsertAppointmentUtilizationRecords', List<VCC_Appointment_Utilization__c>.class)
            .withParameterValues(testUtilList)
            .returning(failedRecords)
            .defineStub();
        VCC_AppointmentSlotUtilLogic.utilizationRepo = stubUtilRepo;

        Test.startTest();
        VCC_AppointmentSlotUtilLogic myClassInstance = new VCC_AppointmentSlotUtilLogic();
        myClassInstance.aggrSchedules = testAggrList;
        myClassInstance.appUtilizations = testUtilList;
        myClassInstance.compareAndUpdateRecords();
        Test.stopTest();
        Assert.areEqual(
            testUtilList.get(0).VCC_Count_of_Used_Appointment_Slots__c,
            testAggrList.get(0).ResourceUtilizationCount,
            'Expected the utilization record field VCC_Count_of_Used_Appointment_Slots__c to be updated to the value of the aggr record ResourceUtilizationCount.'
        );
    }

    /**
     * @description test case for compareAndUpdate method.
     * Negative test case where the input is null.
     */
    @IsTest
    static void unitTestCompareAndUpdateRecordsNegative() {
        Boolean exceptionThrown = false;
        Test.startTest();
        VCC_AppointmentSlotUtilLogic myClassInstance = new VCC_AppointmentSlotUtilLogic();
        myClassInstance.aggrSchedules = null;
        myClassInstance.appUtilizations = null;
        try {
            myClassInstance.compareAndUpdateRecords();
        } catch (Exception genericException) {
            exceptionThrown = true;
        }
        Test.stopTest();
        Assert.isFalse(exceptionThrown, 'Expected compareAndUpdateRecords to return when passed null input.');
    }

    /**
     * @description test case for fetchAppointmentUtilizationRecords method.
     * Positive test case where the method returns a list of records.
     */
    @IsTest
    static void unitTestFetchAppointmentUtilizationRecordsPositive() {
        Date myStartDate;
        Date myEndDate;
        List<VCC_Appointment_Utilization__c> testUtilList = (List<VCC_Appointment_Utilization__c>) VATEST_SObjectFactory.createSObjects(
            new VCC_Appointment_Utilization__c(),
            10
        );
        List<AppointmentScheduleAggr> testAggrList = (List<AppointmentScheduleAggr>) VATEST_SObjectFactory.createSObjects(
            new AppointmentScheduleAggr(),
            10
        );
        VCR_AppointmentUtilizationRepo stubUtilRepo = (VCR_AppointmentUtilizationRepo) new VATEST_StubBuilder(
                VCR_AppointmentUtilizationRepo.class
            )
            .mockingMethodCall('getAppointmentUtilizationWithinRange', Date.class, Date.class)
            .withParameterValues(myStartDate, myEndDate)
            .returning(testUtilList)
            .defineStub();
        VCC_AppointmentSlotUtilLogic.utilizationRepo = stubUtilRepo;

        Test.startTest();
        VCC_AppointmentSlotUtilLogic myClassInstance = new VCC_AppointmentSlotUtilLogic();
        myClassInstance.aggrSchedules = testAggrList;
        List<VCC_Appointment_Utilization__c> outputList = myClassInstance.fetchAppointmentUtilizationRecords();
        Test.stopTest();
        Assert.areEqual(
            testUtilList,
            outputList,
            'Expected fetchAppointmentUtilizationRecords to return the mocked VCC_Appointment_Utilization__c records.'
        );
    }

    /**
     * @description test case for fetchAppointmentUtilizationRecords method.
     * Negative test case where the method returns a null list.
     */
    @IsTest
    static void unitTestFetchAppointmentUtilizationRecordsNegative() {
        Test.startTest();
        VCC_AppointmentSlotUtilLogic myClassInstance = new VCC_AppointmentSlotUtilLogic();
        myClassInstance.aggrSchedules = null;
        List<VCC_Appointment_Utilization__c> outputList = myClassInstance.fetchAppointmentUtilizationRecords();
        Test.stopTest();
        Assert.isNull(
            outputList,
            'fetchAppointmentUtilizationRecords should have returned a null list when aggrSchedules is set to null.'
        );
    }

    /**
     * @description test case for runAppointmentSlotUtilizationCalculation method.
     * Negative test case where the improper input is passed.
     * This test case is used to test the exception handling of the method.
     */
    @IsTest
    static void unitTestCalculateSlotUtilizationNegative() {
        Boolean isExceptionThrown = false;
        Test.startTest();
        VCC_AppointmentSlotUtilLogic myClassInstance = new VCC_AppointmentSlotUtilLogic();
        try {
            myClassInstance.calculateSlotUtilization(null);
        } catch (Exception genericException) {
            isExceptionThrown = true;
        }
        Test.stopTest();
        Assert.isFalse(
            isExceptionThrown,
            'Expected isExceptionThrown to be false when passing a null list to calculateSlotUtilization.'
        );
    }

    /**
     * @description test case for createAndUpdateUtilizationObjects method.
     * Positive test case where the method returns a list of records.
     */
    @IsTest
    static void unitTestCreateAndUpdateUtilizationObjectsPositive() {
        Boolean isExceptionThrown = false;
        List<VCC_Appointment_Utilization__c> testUtilList = (List<VCC_Appointment_Utilization__c>) VATEST_SObjectFactory.createSObjects(
            new VCC_Appointment_Utilization__c(),
            10
        );
        List<AppointmentScheduleAggr> testAggrList = (List<AppointmentScheduleAggr>) VATEST_SObjectFactory.createSObjects(
            new AppointmentScheduleAggr(),
            10
        );
        List<VCC_Appointment_Utilization__c> result = new List<VCC_Appointment_Utilization__c>();
        Test.startTest();
        VCC_AppointmentSlotUtilLogic myClassInstance = new VCC_AppointmentSlotUtilLogic();
        myClassInstance.aggrSchedules = testAggrList;
        myClassInstance.appUtilizations = testUtilList;
        try {
            result = myClassInstance.createAndUpdateUtilizationObjects();
        } catch (Exception genericException) {
            isExceptionThrown = true;
        }
        Test.stopTest();
        Assert.isFalse(
            isExceptionThrown,
            'isExceptionThrown should be false when passing valid input to createAndUpdateUtilizationObjects.'
        );
        Assert.areEqual(10, result.size(), 'Expected result of createAndUpdateUtilizationObjects to have 10 records.');
    }

    /**
     * @description test case for upsertAppointmentUtilization method.
     * Positive test case where the method upserts the record passed in.
     */
    @IsTest
    static void funcTestUpsertAppointmentUtilizationPositive() {
        Integer expectedCount = 1;
        Integer actualCount = 0;
        VCC_Appointment_Utilization__c testUtilRecord = (VCC_Appointment_Utilization__c) VATEST_SObjectFactory.createSObject(
            new VCC_Appointment_Utilization__c(
                VCC_Date__c = Date.today(),
                VCC_Count_of_Available_Appointment_Slots__c = 1,
                VCC_Count_of_Used_Appointment_Slots__c = 1
            )
        );
        List<VCC_Appointment_Utilization__c> testUtilList = new List<VCC_Appointment_Utilization__c>();
        testUtilList.add(testUtilRecord);
        Test.startTest();
        VCC_AppointmentSlotUtilLogic myClassInstance = new VCC_AppointmentSlotUtilLogic();
        myClassInstance.upsertAppointmentUtilization(testUtilList);
        actualCount = Limits.getDmlStatements();
        Test.stopTest();

        Assert.areEqual(
            expectedCount,
            actualCount,
            'upsertAppointmentUtilization should have upserted the record passed in'
        );
    }

    /**
     * @description test case for logFailedRecords method.
     * Positive test case where the method logs the failed records.
     */
    @IsTest
    static void funcTestLogFailedRecordsPositive() {
        List<VCC_Appointment_Utilization__c> testUtilList = (List<VCC_Appointment_Utilization__c>) VATEST_SObjectFactory.createSObjects(
            new VCC_Appointment_Utilization__c(),
            10
        );

        Test.startTest();
        VCC_AppointmentSlotUtilLogic myClassInstance = new VCC_AppointmentSlotUtilLogic();
        myClassInstance.logFailedRecords(testUtilList);
        Test.stopTest();
        List<LogEntry__c> logResult = [
            SELECT Id, ExceptionMessage__c, ExceptionStackTrace__c, Message__c, ApexMethodName__c
            FROM LogEntry__c
            WHERE ApexMethodName__c LIKE 'logFailedRecords'
        ];
        Assert.isTrue(
            logResult.size() > 0,
            'Expected log to be saved when passing in a list of records to logFailedRecords.'
        );
    }

    /**
     * @description test case for createUtilization method.
     * Negative test case where the input is null.
     */
    @IsTest
    static void funcTestCreateUtilizationNegative() {
        List<VCC_Appointment_Utilization__c> testUtilList = (List<VCC_Appointment_Utilization__c>) VATEST_SObjectFactory.createSObjects(
            new VCC_Appointment_Utilization__c(),
            10
        );
        Test.startTest();
        VCC_AppointmentSlotUtilLogic myClassInstance = new VCC_AppointmentSlotUtilLogic();
        myClassInstance.createUtilization(null, testUtilList);
        Test.stopTest();
        List<LogEntry__c> logResult = [
            SELECT Id, ExceptionMessage__c, ExceptionStackTrace__c, Message__c, ApexMethodName__c
            FROM LogEntry__c
            WHERE ApexMethodName__c LIKE 'createUtilization'
        ];
        Assert.isTrue(
            logResult.size() > 0,
            'Expected log to be saved when passing in a null record to createUtilization.'
        );
    }

    /**
     * @description test case for compareAndUpdateRecords method.
     * Positive test case where the records are compared and updated.
     */
    @IsTest
    static void funcTestCompareAndUpdateRecordsPositive() {
        Integer expectedCount = 1;
        Integer resultCount = 0;
        List<VCC_Appointment_Utilization__c> testUtilList = (List<VCC_Appointment_Utilization__c>) VATEST_SObjectFactory.createSObjects(
            new VCC_Appointment_Utilization__c(),
            1,
            true
        );
        List<AppointmentScheduleAggr> testAggrList = (List<AppointmentScheduleAggr>) VATEST_SObjectFactory.createSObjects(
            new AppointmentScheduleAggr(),
            1,
            true
        );
        Test.startTest();
        VCC_AppointmentSlotUtilLogic myClassInstance = new VCC_AppointmentSlotUtilLogic();
        myClassInstance.aggrSchedules = testAggrList;
        myClassInstance.appUtilizations = testUtilList;
        myClassInstance.compareAndUpdateRecords();
        resultCount = Limits.getDmlStatements();
        Test.stopTest();
        Assert.areEqual(
            expectedCount,
            resultCount,
            'Expected DML to be committed when passing valid input into compareAndUpdateRecords method.'
        );
    }
}
