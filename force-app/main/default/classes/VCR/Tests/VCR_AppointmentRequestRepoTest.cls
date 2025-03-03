/**
 * @description Test class for VCR_AppointmentRequestRepo
 * @author Booz Allen Hamilton
 */
@IsTest
private class VCR_AppointmentRequestRepoTest {
    final static User MSA_USER = new VATEST_UserBuilder()
        .withPermissionSet('VCC_Advanced_Medical_Support_Assistant')
        .withPermissionSet('VAHC_Scheduling_User')
        .withUserProfile('VAVET Base Profile')
        .withStandardData()
        .build(true);
    final static User ADMIN = new VATEST_UserBuilder()
        .withUserProfile('System Administrator')
        .withStandardData()
        .build(true);
    final static Id PERSON_RECORD_TYPE_ID = new VCR_AccountRepo()
        .recordTypeConstant.fromDeveloperName('PersonAccount')
        .Id;

    final static String PROVIDER_IEN = '2000';
    final static String CLINIC_NAME = 'DAYTSHR';
    final static String PROVIDER_NAME = 'PROVIDER';

    private static Account testPatient1;
    private static final String QUERY_STRING =
        'SELECT Id FROM VCC_AppointmentRequest__c  WHERE ' +
        '(VCC_Current_Status__c != \'Closed\' AND LastModifiedDate < :dateTimeHoursAgo ) OR ' +
        '(VCC_Current_Status__c = \'Closed\' AND LastModifiedDate < :dateDaysAgo )';

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
     * @description Test method that confrims the VCR_AppointmentRequestRepo instantiates successfully.
     */
    @IsTest
    static void unitTestConstructorPositive() {
        Test.startTest();
        VCR_AppointmentRequestRepo repo;
        System.runAs(MSA_USER) {
            repo = new VCR_AppointmentRequestRepo();
        }
        Test.stopTest();
        Assert.isNotNull(repo, 'Expected constructor to properly instantiate a VCR_AppointmentRepo');
    }

    /**
     * @description Method that returns VCC_AppointmentRequest__c with field values populated.
     * @param apptReq - VCC_AppointmentRequest__c record which can be a new record or backdated record to test LastModifiedDate.
     * @param requestId - Unique Id to use for VCC_Request_Id__c field value when building the test record.
     * @return `VCC_AppointmentRequest__c` VCC_AppointmentRequest__c with field values populated.
     */
    private static VCC_AppointmentRequest__c buildAppointmentRequest(
        VCC_AppointmentRequest__c apptReq,
        String requestId
    ) {
        testPatient1 = [SELECT Id FROM Account WHERE FirstName = 'Test' LIMIT 1];

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
        apptReq.VCC_Request_Id__c = requestId;
        apptReq.VCC_RequestedBy__c = 'Patient';
        return apptReq;
    }

    /**
     * @description Positive test case for getStaleApptReqQueryString().
     * @see VCR_AppointmentRequestRepo.getStaleApptReqQueryString()
     */
    @IsTest
    static void unitGetStaleApptQueryStringPositive() {
        DateTime dateTimeTwentyFourHoursAgo = Datetime.now().addHours(-24);
        Date dateSevenDaysAgo = Datetime.now().date().addDays(-7);

        System.runAs(ADMIN) {
            VCR_AppointmentRequestRepo repo;
            String queryString;
            Test.startTest();
            repo = new VCR_AppointmentRequestRepo();
            queryString = repo.getStaleApptReqQueryString(dateTimeTwentyFourHoursAgo, dateSevenDaysAgo);
            Test.stopTest();
            Assert.areEqual(
                QUERY_STRING,
                queryString,
                'Expected the getStaleApptReqQueryString() method to return the correct query string for VCC_AppointmentRequest__c including a WHERE clause for LastModifiedDate'
            );
        }
    }

    /**
     * @description Negative test case for getQueryLocator() that covers null query scenario.
     * @see VCR_AppointmentRequestRepo.getQueryLocator
     */
    @IsTest
    static void unitGetQueryLocatorNullQueryNegative() {
        DateTime dateTimeTwentyFourHoursAgo = Datetime.now().addHours(-24);
        Date dateSevenDaysAgo = Datetime.now().date().addDays(-7);
        Map<String, Object> bindParams = new Map<String, Object>{
            'dateTimeHoursAgo' => dateTimeTwentyFourHoursAgo,
            'dateDaysAgo' => dateSevenDaysAgo
        };
        System.runAs(ADMIN) {
            VCR_AppointmentRequestRepo repo;
            Database.QueryLocator queryLocator;
            Test.startTest();
            repo = new VCR_AppointmentRequestRepo();
            queryLocator = repo.getQueryLocator(null, bindParams);
            Test.stopTest();
            Assert.isNull(
                queryLocator,
                'Expected the getQueryLocator() method to return null when queryString parameter is null but observed a different value for queryLocator.'
            );
        }
    }

    /**
     * @description Negative test case for getQueryLocator() that covers null bindParams scenario.
     * @see VCR_AppointmentRequestRepo.getQueryLocator
     */
    @IsTest
    static void unitGetQueryLocatorNullBindParamsNegative() {
        DateTime dateTimeTwentyFourHoursAgo = Datetime.now().addHours(-24);
        Date dateSevenDaysAgo = Datetime.now().date().addDays(-7);
        System.runAs(ADMIN) {
            VCR_AppointmentRequestRepo repo;
            Database.QueryLocator queryLocator;
            Test.startTest();
            repo = new VCR_AppointmentRequestRepo();
            queryLocator = repo.getQueryLocator(
                repo.getStaleApptReqQueryString(dateTimeTwentyFourHoursAgo, dateSevenDaysAgo),
                null
            );
            Test.stopTest();
            Assert.isNull(
                queryLocator,
                'Expected the getQueryLocator() method to return null when bind parameters are null but observed a different value for queryLocator.'
            );
        }
    }

    /**
     * @description Negative test case for getQueryLocator() that covers scenario if user is not admin.
     * @see VCR_AppointmentRequestRepo.getQueryLocator
     */
    @IsTest
    static void unitGetQueryLocatorUserIsNotAdminNegative() {
        DateTime dateTimeTwentyFourHoursAgo = Datetime.now().addHours(-24);
        Date dateSevenDaysAgo = Datetime.now().date().addDays(-7);
        Map<String, Object> bindParams = new Map<String, Object>{
            'dateTimeHoursAgo' => dateTimeTwentyFourHoursAgo,
            'dateDaysAgo' => dateSevenDaysAgo
        };
        System.runAs(MSA_USER) {
            VCR_AppointmentRequestRepo repo;
            Boolean isExceptionThrown = false;
            Database.QueryLocator queryLocator;
            Test.startTest();
            try {
                repo = new VCR_AppointmentRequestRepo();
                queryLocator = repo.getQueryLocator(
                    repo.getStaleApptReqQueryString(dateTimeTwentyFourHoursAgo, dateSevenDaysAgo),
                    bindParams
                );
            } catch (HandledException handledException) {
                isExceptionThrown = true;
            }
            Test.stopTest();
            Assert.isNull(queryLocator, 'Expected the getQueryLocator() method to return null');
            Assert.isTrue(
                isExceptionThrown,
                'Expected the getQueryLocator() method to throw a HandledException when user is not an Admin but did not observe an exception.'
            );
        }
    }

    /**
     * @description Test method that confirms correct stale VCC_AppointmentRequest__c record is returned
     * and a new record is not returned.
     */
    @IsTest
    static void funcGetStaleAppointmentRequestsPositive() {
        List<VCC_AppointmentRequest__c> apptReqList = new List<VCC_AppointmentRequest__c>();
        Database.queryLocator locator;
        DateTime dateTimeTwentyFourHoursAgo = Datetime.now().addHours(-24);
        Date dateSevenDaysAgo = Datetime.now().date().addDays(-7);
        Set<Id> appointmentReqRecordIds = new Set<Id>();
        List<VCC_AppointmentRequest__c> apptReqsWithCreatedDate;

        System.runAs(ADMIN) {
            String backdatedJSON = '{"CreatedDate":"2023-01-01T15:00:00.000+0000","LastModifiedDate":"2023-01-02T15:00:00.000+0000"}';

            VCC_AppointmentRequest__c staleApptReq = (VCC_AppointmentRequest__c) JSON.deserialize(
                backdatedJSON,
                VCC_AppointmentRequest__c.class
            );
            apptReqList.add(buildAppointmentRequest(staleApptReq, 'R1111111'));

            VCC_AppointmentRequest__c newApptReq = new VCC_AppointmentRequest__c();
            apptReqList.add(buildAppointmentRequest(newApptReq, 'R2222222'));
            insert apptReqList;

            Test.startTest();
            VCR_AppointmentRequestRepo repo = new VCR_AppointmentRequestRepo();
            locator = repo.getQueryLocator(
                repo.getStaleApptReqQueryString(dateTimeTwentyFourHoursAgo, dateSevenDaysAgo),
                new Map<String, Object>{
                    'dateTimeHoursAgo' => dateTimeTwentyFourHoursAgo,
                    'dateDaysAgo' => dateSevenDaysAgo
                }
            );
            Test.stopTest();

            if (locator != null) {
                Database.QueryLocatorIterator iterator = locator.iterator();
                while (iterator.hasNext()) {
                    VCC_AppointmentRequest__c apptReq = (VCC_AppointmentRequest__c) iterator.next();
                    appointmentReqRecordIds.add(apptReq.Id);
                }
                apptReqsWithCreatedDate = [
                    SELECT Id, CreatedDate
                    FROM VCC_AppointmentRequest__c
                    WHERE Id IN :appointmentReqRecordIds
                ];
            }
        }
        Assert.areEqual(
            1,
            apptReqsWithCreatedDate.size(),
            'Expected 1 record to be returned based on LastModifiedDate but observed a different record count.'
        );
        VCC_AppointmentRequest__c backdatedApptReq = apptReqsWithCreatedDate[0];
        Assert.isTrue(
            backdatedApptReq.CreatedDate < dateTimeTwentyFourHoursAgo,
            'Expected the backdatedAppt record to be the one returned based on LastModifiedDate but observed returned record with a newer CreatedDate.'
        );
    }
}
