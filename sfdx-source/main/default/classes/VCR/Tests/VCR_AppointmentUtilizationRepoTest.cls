/**
 * @description Tests for VCR_AppointmentUtilizationRepo class
 * @author      Booz Allen Hamilton
 * @see        VCR_AppointmentUtilizationRepo class
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest
private with sharing class VCR_AppointmentUtilizationRepoTest {
    private static VCR_AppointmentUtilizationRepo appointmentRepository;
    private static VCC_Appointment_Utilization__c appointmentUtilizationTestRecord = new VCC_Appointment_Utilization__c();
    private static final DateTime JAN_FIRST_2024;
    private static final VCR_AppointmentUtilizationRepo SYSTEM_UNDER_TEST;

    static {
        SYSTEM_UNDER_TEST = new VCR_AppointmentUtilizationRepo();
        JAN_FIRST_2024 = DateTime.newInstanceGmt(2024, 1, 1);
    }

    /**
     * @description Setup test data for testing.
     */
    @TestSetup
    static void funcSetup() {
        User testUser = new VATEST_UserBuilder()
            .withUserProfile('System Administrator')
            .withStandardData()
            .setFields(User.TimeZoneSidKey, UserInfo.getTimeZone().getID())
            .withPermissionSet('VCC_VCV_Appointment_Viewer_Administrator')
            .withPermissionSet('VAHC_View_Appointment_Utilization')
            .build(true);
        //Avoid mixed dml and error when the running user doesn't have a scheduler license.
        System.runAs(testUser) {
            ServiceResource personWhoIsWorking = (ServiceResource) VATEST_SObjectFactory.createSObject(
                new ServiceResource(Name = 'TestPerson', RelatedRecordId = testUser.Id, IsActive = true),
                true
            );
            ServiceTerritory placeInWhichTheyWork = (ServiceTerritory) VATEST_SObjectFactory.createSObject(
                new ServiceTerritory(
                    Name = 'TestTerritory',
                    IsActive = true,
                    OperatingHoursId = VATEST_SObjectFactory.createSObject(
                            new OperatingHours(Name = 'Fake Operating hours'),
                            true
                        )
                        .Id
                ),
                true
            );
            VATEST_SObjectFactory.createSObject(
                new ServiceTerritoryMember(
                    EffectiveStartDate = JAN_FIRST_2024,
                    EffectiveEndDate = JAN_FIRST_2024.addDays(180),
                    ServiceTerritoryId = placeInWhichTheyWork.Id,
                    ServiceResourceId = personWhoIsWorking.Id
                ),
                true
            );
            appointmentRepository = new VCR_AppointmentUtilizationRepo();
            VCC_Appointment_Utilization__c appointmentUtilization = new VCC_Appointment_Utilization__c();
            appointmentUtilization.VCC_Date__c = JAN_FIRST_2024.date();
            appointmentUtilization.VCC_Provider__c = testUser.Id;
            appointmentUtilization.VCC_VISN__c = 'Test';
            appointmentUtilization.VCC_Count_of_Used_Appointment_Slots__c = 1;
            appointmentUtilization.VCC_Service_Resource__c = personWhoIsWorking.Id;
            appointmentUtilization.VCC_Service_Territory__c = placeInWhichTheyWork.Id;

            appointmentUtilizationTestRecord = appointmentRepository.createAppointmentUtilizationRecord(
                appointmentUtilization
            );
        }
    }

    /**
     * @description functional test for the VCR_AppointmentUtilizationRepo constructor
     *             to ensure that the class can be instantiated.
     *             Positive test case.
     */
    @IsTest
    static void funcTestVCRAppointmentUtilizationRepository() {
        Test.startTest();
        appointmentRepository = new VCR_AppointmentUtilizationRepo();
        Test.stopTest();
        Assert.isNotNull(appointmentRepository, 'VCR_AppointmentUtilizationRepo should have been instantiated');
    }

    /**
     * @description functional test for getAppointmentUtilizationRecords method.
     *            Positive test case.
     */
    @IsTest
    static void funcTestGetAppointmentUtilizationPositive() {
        List<VCC_Appointment_Utilization__c> appointmentUtilizations;
        Test.startTest();
        System.runAs(generateSydney()) {
            appointmentRepository = new VCR_AppointmentUtilizationRepo();
            appointmentUtilizations = appointmentRepository.getAppointmentUtilizationRecords();
        }
        Test.stopTest();
        Assert.isTrue(
            appointmentUtilizations.size() > 0,
            'getAppointmentUtilizationRecords should have returned records'
        );
    }

    /**
     * @description functional test for getAppointmentUtilizationWithinRange method.
     *           Positive test case.
     */
    @IsTest
    static void funcTestGetAppointmentUtilizationWithinRangePositive() {
        VCR_AppointmentUtilizationRepo repository;
        List<VCC_Appointment_Utilization__c> appointmentUtilizations;
        Test.startTest();
        System.runAs(generateSydney()) {
            repository = new VCR_AppointmentUtilizationRepo();
            appointmentUtilizations = repository.getAppointmentUtilizationWithinRange(
                JAN_FIRST_2024.date(),
                JAN_FIRST_2024.date()
            );
        }
        Test.stopTest();
        Assert.isTrue(
            appointmentUtilizations.size() > 0,
            'getAppointmentUtilizationWithinRange should have returned records'
        );
    }

    /**
     * @description functional test for UpsertAppointmentUtilization method.
     *           Positive test case.
     */
    @IsTest
    static void funcTestUpsertAppointmentUtilizationPositive() {
        List<VCC_Appointment_Utilization__c> upsertAppointmentList = new List<VCC_Appointment_Utilization__c>();
        List<VCC_Appointment_Utilization__c> appointmentUtilizations = new List<VCC_Appointment_Utilization__c>();
        Test.startTest();
        System.runAs(generateSydney()) {
            appointmentRepository = new VCR_AppointmentUtilizationRepo();
            appointmentUtilizationTestRecord.VCC_Count_of_Used_Appointment_Slots__c = 2;
            upsertAppointmentList.add(appointmentUtilizationTestRecord);
            appointmentRepository.upsertAppointmentUtilizationRecords(upsertAppointmentList);
            appointmentUtilizations = appointmentRepository.getAppointmentUtilizationRecords();
        }
        Test.stopTest();
        Assert.areEqual(2, appointmentUtilizations.size(), 'There should be two appointment utilizations records');
        for (VCC_Appointment_Utilization__c appointmentUtilization : appointmentUtilizations) {
            if (appointmentUtilization.VCC_Provider__c == appointmentUtilizationTestRecord.VCC_Provider__c) {
                appointmentUtilizations.clear();
                appointmentUtilizations.add(appointmentUtilization);
                break;
            }
        }
        Assert.areEqual(
            appointmentUtilizationTestRecord.VCC_Count_of_Used_Appointment_Slots__c,
            appointmentUtilizations.get(0).VCC_Count_of_Used_Appointment_Slots__c,
            'VCC_Appointment_Utilization record should have been updated by upsertAppointmentUtilizationRecords'
        );
    }

    /**
     * @description functional getQueryString method.
     *          Positive test case.
     */
    @IsTest
    static void funcTestGetQueryStringPositive() {
        String queryString;
        Test.startTest();
        appointmentRepository = new VCR_AppointmentUtilizationRepo();
        queryString = appointmentRepository.getQueryString();
        Test.stopTest();
        Assert.areEqual(queryString, getTestString(), 'Query string should match the expected string');
    }

    /**
     * @description functional test for UpdateAppointmentUtilizationRecord method.
     *          Positive test case.
     */
    @IsTest
    static void funcTestUpdateAppointmentUtilizationRecordPositive() {
        User sydneySysAdmin = generateSydney();
        VCC_Appointment_Utilization__c testUpdateRecord;
        System.runAs(sydneySysAdmin) {
            testUpdateRecord = (VCC_Appointment_Utilization__c) VATEST_SObjectFactory.createSObject(
                new VCC_Appointment_Utilization__c(),
                true
            );
        }

        testUpdateRecord.VCC_Date__c = Date.today();
        testUpdateRecord.VCC_Provider__c = UserInfo.getUserId();
        testUpdateRecord.VCC_VISN__c = 'Test';
        testUpdateRecord.VCC_Count_of_Used_Appointment_Slots__c = 1;
        VCC_Appointment_Utilization__c result;
        Test.startTest();
        System.runAs(sydneySysAdmin) {
            appointmentRepository = new VCR_AppointmentUtilizationRepo();
            result = appointmentRepository.updateAppointmentUtilizationRecord(testUpdateRecord);
        }
        Test.stopTest();
        Assert.areEqual(result, testUpdateRecord, 'The returned record should be the same as the input record');
    }
    /**
     * @description private helper for testing purposes.
     * @return String - query string.
     */
    private static String getTestString() {
        return 'SELECT CreatedById,\n' +
            '        CreatedDate,\n' +
            '        Id,\n' +
            '        IsDeleted,\n' +
            '        LastActivityDate,\n' +
            '        LastModifiedById,\n' +
            '        LastModifiedDate,\n' +
            '        Name,\n' +
            '        OwnerId,\n' +
            '        SystemModstamp,\n' +
            '        VCC_Count_of_Available_Appointment_Slots__c,\n' +
            '        VCC_Count_of_Used_Appointment_Slots__c,\n' +
            '        VCC_Date__c,\n' +
            '        VCC_Provider__c,\n' +
            '        VCC_VISN__c';
    }

    @IsTest
    private static void funcItReturnsExpectedRecordInRangeAndRelatedToResourceAndTerritoryPositive() {
        List<ServiceTerritoryMember> members = [
            SELECT ServiceResourceId, ServiceTerritoryId
            FROM ServiceTerritoryMember
        ];
        Set<Id> relatedResourceIds = new Set<Id>();
        Set<Id> relatedTerritoryIds = new Set<Id>();
        for (ServiceTerritoryMember member : members) {
            relatedResourceIds.add(member.ServiceResourceId);
            relatedTerritoryIds.add(member.ServiceTerritoryId);
        }
        VCC_DateRange range = new VCC_DateRange(JAN_FIRST_2024, JAN_FIRST_2024.addDays(1));
        List<VCC_Appointment_Utilization__c> result = new List<VCC_Appointment_Utilization__c>();
        User sydneySysAdmin = generateSydney();
        Test.startTest();
        {
            System.runAs(sydneySysAdmin) {
                result = SYSTEM_UNDER_TEST.getAppointmentUtilizationRecordsWithinRangeRelatedToTerritoryMembers(
                    relatedResourceIds,
                    relatedTerritoryIds,
                    range
                );
            }
        }
        Test.stopTest();
        Assert.areEqual(1, result.size(), 'Expected exactly one record to be returned.');
    }
    @IsTest
    private static void funcQueryReturnsNothingWhenOutOfRangeNegative() {
        List<ServiceTerritoryMember> members = [
            SELECT ServiceResourceId, ServiceTerritoryId
            FROM ServiceTerritoryMember
        ];
        Set<Id> relatedResourceIds = new Set<Id>();
        Set<Id> relatedTerritoryIds = new Set<Id>();
        for (ServiceTerritoryMember member : members) {
            relatedResourceIds.add(member.ServiceResourceId);
            relatedTerritoryIds.add(member.ServiceTerritoryId);
        }
        VCC_DateRange range = new VCC_DateRange(JAN_FIRST_2024.addYears(2), JAN_FIRST_2024.addYears(2).addDays(1));
        List<VCC_Appointment_Utilization__c> result = new List<VCC_Appointment_Utilization__c>();
        User sydneySysAdmin = generateSydney();
        Test.startTest();
        {
            System.runAs(sydneySysAdmin) {
                result = SYSTEM_UNDER_TEST.getAppointmentUtilizationRecordsWithinRangeRelatedToTerritoryMembers(
                    relatedResourceIds,
                    relatedTerritoryIds,
                    range
                );
            }
        }
        Test.stopTest();
        Assert.areEqual(0, result.size(), 'Expected exactly zero records to be returned.');
    }

    private static User generateSydney() {
        return new VATEST_UserBuilder()
            .withUserProfile('System Administrator')
            .withStandardData()
            .setFields(User.TimeZoneSidKey, UserInfo.getTimeZone().getID())
            .withPermissionSet('VCC_VCV_Appointment_Viewer_Administrator')
            .withPermissionSet('VAHC_View_Appointment_Utilization')
            .build(true);
    }
}
