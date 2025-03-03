/**
 * @description Test class for VCC_AppointmentDataBatchDelete
 * @author Booz Allen Hamilton
 * @see VCC_AppointmentDataBatchDelete
 */
@IsTest
private class VCC_AppointmentDataBatchDeleteTest {
    final static User ADMIN = new VATEST_UserBuilder()
        .withUserProfile('System Administrator')
        .withStandardData()
        .build(true);

    final static User MSA_USER = new VATEST_UserBuilder()
        .withPermissionSet('VCC_Advanced_Medical_Support_Assistant')
        .withPermissionSet('VAHC_Scheduling_User')
        .withUserProfile('VAVET Base Profile')
        .withStandardData()
        .build(true);

    final static STRING PROVIDER_IEN = '2000';

    final static Id PERSON_RECORD_TYPE_ID = new VCR_AccountRepo()
        .recordTypeConstant.fromDeveloperName('PersonAccount')
        .Id;

    final static string CLINIC_NAME = 'DAYTSHR';
    final static String PROVIDER_NAME = 'PROVIDER';

    private static Account testPatient1;

    /**
     * @description Insert records that are used for lookup fields on Appointments and Appointment Requests.
     */
    @TestSetup
    static void insertTestData() {
        System.runAs(ADMIN) {
            testPatient1 = (Account) VATEST_SObjectFactory.createSObject(
                new Account(FirstName = 'Test', LastName = 'Patient1', RecordTypeId = PERSON_RECORD_TYPE_ID),
                true
            );
        }
    }

    /**
     * @description Method that populates field values for an AppointmentRequest record.
     * Since the batch class looks for records older than a certain time,
     * this method allows for the creation of old records the meet the criteria,
     * and new records that would not meet the criteria.
     * JSON.deserialize is used to create test records with backdated system fields.
     * @param type - Old(backdated) or New record for logic to distiguish between based on LastModifiedDate.
     * @param i - For loop counter for the number of records to create.
     * @return `VCC_AppointmentRequest__c` Returns a VCC_AppointmentRequest__c record with field values populated.
     */
    private static VCC_AppointmentRequest__c apptReqBuilder(String type, Integer i) {
        VCC_AppointmentRequest__c apptReq;
        String idPrefix;
        switch on type {
            when 'new' {
                apptReq = new VCC_AppointmentRequest__c();
                idPrefix = 'R0';
            }
            when 'old' {
                // use JSON.deserialize to set system fields like LastModifiedDate
                String backdatedJSON =
                    '{"CreatedDate"						:"2023-01-01T15:00:00.000+0000",' +
                    '"LastModifiedDate"					:"2023-01-02T15:00:00.000+0000"}';
                apptReq = (VCC_AppointmentRequest__c) JSON.deserialize(backdatedJSON, VCC_AppointmentRequest__c.class);
                idPrefix = 'R1';
            }
        }
        apptReq.VCC_AppointmentRequestType__c = 'APPT';
        apptReq.VCC_AppointmentType__c = 'REGULAR';
        apptReq.VCC_Current_Status__c = 'Open';
        apptReq.OwnerId = MSA_USER.Id;
        apptReq.VCC_Clinic_Name__c = CLINIC_NAME;
        apptReq.VCC_Facility_Name__c = 'DAYTSHR TEST LAB';
        apptReq.VCC_Facility_Station_Id__c = '984';
        apptReq.VCC_Patient__c = testPatient1.Id;
        apptReq.VCC_Provider_IEN__c = PROVIDER_IEN;
        apptReq.VCC_Provider_Name__c = PROVIDER_NAME;
        apptReq.VCC_Request_Id__c = idPrefix + generateUniqueId(i);
        apptReq.VCC_RequestedBy__c = 'Patient';
        return apptReq;
    }

    /**
     * @description Appointment Request has a field that requires a unique Id.
     * This method creates a unique ID when multiple records are being created.
     * @param i - For loop counter for the number of records to create.
     * @return `String` Unique number for the VCC_Request_Id__c field.
     */
    private static String generateUniqueId(Integer i) {
        Integer sixDigits = 100000;
        Integer sum = sixDigits + i;
        return String.valueOf(sum);
    }

    /**
     * @description Method that populates field values for an Appointment record.
     * Since the batch class looks for records older than a certain time,
     * this method allows for the creation of old records the meet the criteria,
     * and new records that would not meet the criteria.
     * JSON.deserialize is used to create test records with backdated system fields.
     * @param type - Backdated 'old' or 'new' record for logic to distiguish between based on LastModifiedDate.
     * @return `VCC_Appointment__c` Returns a VCC_Appointment__c record with field values populated.
     */
    private static VCC_Appointment__c apptBuilder(String type) {
        VCC_Appointment__c appt;
        switch on type {
            when 'new' {
                appt = new VCC_Appointment__c();
            }
            when 'old' {
                // use JSON.deserialize to set system fields like LastModifiedDate
                String backdatedJSON =
                    '{"CreatedDate"						:"2023-01-01T15:00:00.000+0000",' +
                    '"LastModifiedDate"					:"2023-01-02T15:00:00.000+0000"}';
                appt = (VCC_Appointment__c) JSON.deserialize(backdatedJSON, VCC_Appointment__c.class);
            }
        }
        appt.VCC_Clinic_Name__c = CLINIC_NAME;
        appt.VCC_Patient__c = testPatient1.Id;
        appt.VCC_Time_Zone__c = 'EASTERN';
        appt.VCC_Status__c = 'booked';
        return appt;
    }

    /**
     * @description Method that inserts the Appointment Request records.
     * @param oldRecords - The number of backdated records to create.
     * @param newRecords - The number of new records to create.
     */
    private static void createApptRequests(Integer oldRecords, Integer newRecords) {
        List<VCC_AppointmentRequest__c> apptReqList = new List<VCC_AppointmentRequest__c>();
        for (Integer recordCount = 0; recordCount < oldRecords; recordCount++) {
            apptReqList.add(apptReqBuilder('old', recordCount));
        }
        for (Integer recordCount = 0; recordCount < newRecords; recordCount++) {
            apptReqList.add(apptReqBuilder('new', recordCount));
        }
        insert apptReqList;
    }

    /**
     * @description Method that inserts the Appointment records.
     * @param oldRecords - The number of backdated records to create.
     * @param newRecords - The number of new records to create.
     */
    private static void createAppointments(Integer oldRecords, Integer newRecords) {
        List<VCC_Appointment__c> apptList = new List<VCC_Appointment__c>();
        for (Integer recordCount = 0; recordCount < oldRecords; recordCount++) {
            apptList.add(apptBuilder('old'));
        }
        for (Integer recordCount = 0; recordCount < newRecords; recordCount++) {
            apptList.add(apptBuilder('new'));
        }
        insert apptList;
    }

    /**
     * @description Functional test that creates both old and new records for
     * the Appointment and Appointment Request objects.  This method verifies
     * that the batch class ran and the correct records of both objects
     * were deleted, and the new records that should not meet the criteria
     * were not deleted.
     */
    @IsTest
    private static void funcBatchDeletePositive() {
        Integer numberOfOldRecords = 10;
        Integer numberOfNewRecords = 5;
        Integer totalRecords = numberOfOldRecords + numberOfNewRecords;
        Integer batchSize = 2000;

        testPatient1 = [SELECT Id FROM Account WHERE FirstName = 'Test' LIMIT 1];

        Integer apptReqBeforeCount;
        Integer apptBeforeCount;
        Integer apptReqAfterCount;
        Integer apptAfterCount;

        System.runAs(ADMIN) {
            createApptRequests(numberOfOldRecords, numberOfNewRecords);
            createAppointments(numberOfOldRecords, numberOfNewRecords);

            apptReqBeforeCount = [SELECT COUNT() FROM VCC_AppointmentRequest__c];
            apptBeforeCount = [SELECT COUNT() FROM VCC_Appointment__c];

            Test.startTest();
            List<String> objNames = new List<String>{ 'VCC_AppointmentRequest__c', 'VCC_Appointment__c' };
            VCC_AppointmentDataBatchDelete apptDataBatch = new VCC_AppointmentDataBatchDelete(
                objNames,
                24,
                7,
                batchSize
            );
            Database.executeBatch(apptDataBatch, batchSize);
            Test.stopTest();

            apptReqAfterCount = [SELECT COUNT() FROM VCC_AppointmentRequest__c];
            apptAfterCount = [SELECT COUNT() FROM VCC_Appointment__c];
        }

        Assert.areEqual(
            totalRecords,
            apptReqBeforeCount,
            'Expected VCC_AppointmentRequest__c BEFORE batch to equal total created but observed a difference with the data setup before batch ran.'
        );
        Assert.areEqual(
            numberOfNewRecords,
            apptReqAfterCount,
            'Expected old VCC_AppointmentRequest__c records to be deleted and only new records remain after batch class, but observed a different record count.'
        );
        Assert.areEqual(
            totalRecords,
            apptBeforeCount,
            'Expected VCC_Appointment__c BEFORE batch to equal total created but observed a difference with the data setup before batch ran.'
        );
        Assert.areEqual(
            numberOfNewRecords,
            apptAfterCount,
            'Expected old VCC_Appointment__c records to be deleted and only new records remain after batch class, but observed a different record count.'
        );
        Assert.areNotEqual(
            apptReqBeforeCount,
            apptReqAfterCount,
            'Expected batch class to delete old VCC_AppointmentRequest__c records but observed the same record count before and after the batch class ran.'
        );
        Assert.areNotEqual(
            apptBeforeCount,
            apptAfterCount,
            'Expected batch class to delete old VCC_Appointment__c records but observed the same record count before and after the batch class ran.'
        );
    }

    /**
     * @description The batch class should only process and delete records
     * for the Appointment and Appointment Request objects, which are passed
     * in as a String.  This test verifies that an exception is thrown
     * when something other than the two expected object names is passed in.
     */
    @IsTest
    private static void unitUnsupportedSObjectNameNegative() {
        Integer accountCountBefore = [SELECT COUNT() FROM Account];
        Boolean exceptionThrown = false;
        Integer batchSize = 2000;

        System.runAs(ADMIN) {
            Test.startTest();
            try {
                List<String> objNames = new List<String>{ 'Account' };
                VCC_AppointmentDataBatchDelete errorBatch = new VCC_AppointmentDataBatchDelete(
                    objNames,
                    24,
                    7,
                    batchSize
                );
                Database.executeBatch(errorBatch, batchSize);
                Test.stopTest();
            } catch (VCC_AppointmentDataBatchDelete.AppointmentDataBatchDeleteException e) {
                exceptionThrown = true;
            }
        }

        Integer accountCountAfter = [SELECT COUNT() FROM Account];

        Assert.isTrue(
            exceptionThrown,
            'Expected custom exception to be thrown for unknown object but did not observe a custom exception.'
        );
        Assert.areEqual(
            accountCountBefore,
            accountCountAfter,
            'Expected batch class to throw an exception and for no records to be deleted but observed a difference in record count before and after executeBatch.'
        );
    }

    /**
     * @description Test to confirm a batch job is started when expected parameters are passed in.
     */
    @IsTest
    private static void unitCallablePositive() {
        Map<String, Object> batchParameters = new Map<String, Object>{
            'objectNames' => new List<String>{ 'VCC_Appointment__c', 'VCC_AppointmentRequest__c' },
            'numberOfHours' => 24,
            'numberOfDays' => 7,
            'batchSize' => 2000
        };
        Object responseObj;
        String executeBatchResponse;

        System.runAs(ADMIN) {
            Test.startTest();
            Callable automationJob = (Callable) Type.forName('VCC_AppointmentDataBatchDelete').newInstance();
            responseObj = automationJob.call('executeNewBatchJob', batchParameters);
            executeBatchResponse = (String) responseObj;
            Test.stopTest();
        }

        Assert.areEqual(
            18,
            executeBatchResponse.length(),
            'Expected a batch job to be executed and return the 18 digit batch job Id but observed a different string returned.'
        );
        Assert.isFalse(
            executeBatchResponse.contains('Error'),
            'Expected a batch job to be executed and return the 18 digit batch job Id but observed an error returned.'
        );
    }

    /**
     * @description Test to confirm a batch job is NOT started when unexpected parameters are passed in.
     */
    @IsTest
    private static void unitCallableNegative() {
        Boolean exceptionThrown = false;
        Map<String, Object> batchParameters = new Map<String, Object>{
            'objectNames' => new List<String>{ 'VCC_Appointment__c', 'VCC_AppointmentRequest__c' },
            'numberOfHours' => 24,
            'numberOfDays' => 7,
            'batchSize' => 2000
        };

        System.runAs(ADMIN) {
            Test.startTest();
            try {
                Callable automationJob = (Callable) Type.forName('VCC_AppointmentDataBatchDelete').newInstance();
                automationJob.call('DifferentAction', batchParameters);
            } catch (VCC_AppointmentDataBatchDelete.AppointmentDataBatchDeleteException e) {
                exceptionThrown = true;
            }
            Test.stopTest();
        }

        Assert.isTrue(
            exceptionThrown,
            'Expected a custom exception to be thrown for unknown action but did not observe the custom exception.'
        );
    }

    /**
     * @description The repo classes return an array of DeleteResult for the doDelete operation.
     * This is a test of the method that handles the results and should increment a counter
     * for each successful result.
     */
    @IsTest
    private static void unitProcessResultsPositive() {
        List<Database.DeleteResult> deleteResults = new List<Database.DeleteResult>();
        String simulatedSuccessJSON = '{"id":"a00000000000000000","success":true}';
        Database.DeleteResult simulatedSuccess = (Database.DeleteResult) JSON.deserialize(
            simulatedSuccessJSON,
            Database.DeleteResult.class
        );
        deleteResults.add(simulatedSuccess);

        Integer successCount;
        List<LogEntry__c> errorLogs;

        System.runAs(ADMIN) {
            Test.startTest();
            VCC_AppointmentDataBatchDelete batchWithErrors = new VCC_AppointmentDataBatchDelete();
            batchWithErrors.processResults(deleteResults);
            successCount = batchWithErrors.recordCount;
            Test.stopTest();
            errorLogs = [SELECT Id, Message__c FROM LogEntry__c WHERE LoggingLevel__c = 'ERROR'];
        }

        Assert.areEqual(
            1,
            successCount,
            'Expected success count to be incremented by 1 with a successful result but observed a different value.'
        );
        Assert.areEqual(
            0,
            errorLogs.size(),
            'Expected no error logs from successful result but observed a Log Entry with Log Level as ERROR.'
        );
    }

    /**
     * @description The repo classes return an array of DeleteResult for the doDelete operation.
     * This is a test of the method that handles the results and should log any errors
     * when DeleteResult was unsuccessful.
     */
    @IsTest
    private static void unitProcessResultsNegative() {
        List<Database.DeleteResult> deleteResults = new List<Database.DeleteResult>();
        String simulatedErrorJSON =
            '{"id":"a00000000000000001",' +
            '"success":false,' +
            '"errors":[{' +
            '"statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION",' +
            '"message":"Deletion of this record is not allowed.","fields":[]' +
            '}]}';
        Database.DeleteResult simulatedError = (Database.DeleteResult) JSON.deserialize(
            simulatedErrorJSON,
            Database.DeleteResult.class
        );
        deleteResults.add(simulatedError);

        Integer successCount;
        List<LogEntry__c> errorLogs;

        System.runAs(ADMIN) {
            Test.startTest();
            VCC_AppointmentDataBatchDelete batchWithErrors = new VCC_AppointmentDataBatchDelete();
            try {
                batchWithErrors.processResults(deleteResults);
            } finally {
                Logger.saveLog();
            }
            successCount = batchWithErrors.recordCount;
            Test.stopTest();
            errorLogs = [SELECT Id, Message__c FROM LogEntry__c WHERE LoggingLevel__c = 'ERROR'];
        }

        Assert.areEqual(
            0,
            successCount,
            'Expected success count to be 0 with a simulated error result but observed a different value.'
        );
        Assert.areEqual(
            1,
            errorLogs.size(),
            'Expected an error logs from simulated error result but observed a different result.'
        );
    }
}
