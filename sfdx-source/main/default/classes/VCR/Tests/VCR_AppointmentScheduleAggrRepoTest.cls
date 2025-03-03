/**
 * @description Tests for VCR_AppointmentScheduleAggrRepo class
 * @author      Booz Allen Hamilton
 * @see VCR_AppointmentScheduleAggrRepo
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest
public with sharing class VCR_AppointmentScheduleAggrRepoTest {
    /**
     * @description Test the VCR_AppointmentScheduleAggrRepo constructor.
     * Positive test case, checking if the constructor initializes the class.
     */
    @IsTest
    static void funcTestVCRAppointmentScheduleAggrRepoPositive() {
        VCR_AppointmentScheduleAggrRepo repository;
        Test.startTest();
        repository = new VCR_AppointmentScheduleAggrRepo();
        Test.stopTest();
        Assert.isNotNull(repository, 'VCR_AppointmentScheduleAggrRepo should have been initialized');
    }

    /**
     * @description Test the getAppointmentScheduleAggrAll method.
     * Positive test case.
     */
    @IsTest
    static void funcTestGetAppointmentScheduleAggrAllPositive() {
        VCR_AppointmentScheduleAggrRepo repository;
        List<AppointmentScheduleAggr> appointmentScheduleAggrList;
        Test.startTest();
        repository = new VCR_AppointmentScheduleAggrRepo();
        appointmentScheduleAggrList = repository.getAppointmentScheduleAggrAll();
        Test.stopTest();
        Assert.isTrue(
            appointmentScheduleAggrList != null,
            'getAppointmentScheduleAggrAll should not have returned null'
        );
    }

    /**
     * @description Test the getAppointmentScheduleAggrAll method.
     * Positive test case, checking if the method returns a list of records that contains the service resource id for the newly inserted service resource.
     */
    @IsTest
    static void funcTestGetAppointmentScheduleAggrAllWithRecordsPositive() {
        User provider = (User) VATEST_UserFactory.create(VATEST_UserPersonaEnum.MinimumAccess, true);
        User msa = (User) VATEST_UserFactory.create(VATEST_UserPersonaEnum.MinimumAccess, true);
        ServiceResource serviceResource = (ServiceResource) VATEST_SObjectFactory.createSObject(
            new ServiceResource(
                RelatedRecordId = provider.Id,
                Name = provider.LastName,
                RecordTypeId = ServiceResource.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                    .getRecordTypeInfosByDeveloperName()
                    .get('PC_Resource')
                    .getRecordTypeId(),
                IsActive = true,
                ResourceType = 'A',
                OwnerId = msa.Id
            ),
            true
        );
        VATEST_SObjectFactory.createSObject(new AppointmentScheduleAggr(ServiceResourceId = serviceResource.Id), true);
        VCR_AppointmentScheduleAggrRepo repository;
        List<AppointmentScheduleAggr> appointmentScheduleAggrList;
        Test.startTest();
        repository = new VCR_AppointmentScheduleAggrRepo();
        appointmentScheduleAggrList = repository.getAppointmentScheduleAggrAll();
        Test.stopTest();
        Assert.areEqual(
            provider.Id,
            appointmentScheduleAggrList.get(0).ServiceResource.RelatedRecordId,
            'getAppointmentScheduleAggrAll should have returned an appointment schedule aggr record with the correct service resource id'
        );
    }

    /**
     * @description test the getAppointmentScheduleAggrAllQueryString method.
     * Positive test case, checking if the method returns a query string.
     */
    @IsTest
    static void funcTestGetAppointmentScheduleAggrAllQueryStringPositive() {
        VCR_AppointmentScheduleAggrRepo repository;
        String appointmentScheduleAggrQuery;
        Test.startTest();
        repository = new VCR_AppointmentScheduleAggrRepo();
        appointmentScheduleAggrQuery = repository.getAppointmentScheduleAggrAllQueryString();
        Test.stopTest();
        Assert.isNotNull(
            appointmentScheduleAggrQuery,
            'getAppointmentScheduleAggrAllQueryString should have returned a query string'
        );
    }
}
