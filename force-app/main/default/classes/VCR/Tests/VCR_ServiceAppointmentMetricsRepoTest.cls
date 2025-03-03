/**
 * @description : To test the service appointment metrics repository
 * @author BAH
 * @see VCR_ServiceAppointmentMetricsRepo
 */
@IsTest
public with sharing class VCR_ServiceAppointmentMetricsRepoTest {
    private static final String STRING_QUERY =
        'SELECT Case__c, Case_Metrics__c, CreatedById, CreatedDate, Id, IsDeleted, LastModifiedById, ' +
        'LastModifiedDate, Name, Service_Appointment__c';

    private static final User ADMIN_USER;
    static {
        ADMIN_USER = new VATEST_UserBuilder()
            .withUserProfile('System Administrator')
            .withPermissionSet('VAHC_Standard_VCC_User')
            .withStandardData()
            .build(true);
    }
    /**
     * @description : To test the constructor
     * Positive test case
     * @see VCR_ServiceAppointmentMetricsRepo
     */
    @IsTest
    static void unitTestConstructorPositive() {
        System.runAs(ADMIN_USER) {
            VCR_ServiceAppointmentMetricsRepo repo;
            Test.startTest();

            repo = new VCR_ServiceAppointmentMetricsRepo();

            Test.stopTest();
            Assert.isTrue(repo != null, 'VCR_ServiceAppointmentMetricsRepo instance is not created');
        }
    }
    /**
     * @description : To test the constructor
     * Negative test case
     * @see VCR_ServiceAppointmentMetricsRepo
     */
    @IsTest
    static void unitTestConstructorNegative() {
        System.runAs(ADMIN_USER) {
            VCR_ServiceAppointmentMetricsRepo repo;
            Test.startTest();

            repo = null;
            Test.stopTest();
            Assert.isNull(repo, 'VCR_ServiceAppointmentMetricsRepo instance is not null');
        }
    }
    /**
     * @description : To test the calculate select clause
     * Positive test case
     * @see VCR_ServiceAppointmentMetricsRepo.calculateSelectClause
     */
    @IsTest
    static void unitTestCalculateSelectClausePositive() {
        System.runAs(ADMIN_USER) {
            String selectClause;
            Test.startTest();

            selectClause = VCR_ServiceAppointmentMetricsRepo.calculateSelectClause();

            Test.stopTest();
            Assert.areEqual(
                selectClause,
                STRING_QUERY,
                'Expected calculateSelectClause to return a string representing the select clause'
            );
        }
    }

    /**
     * @description : To test the fetch service appointment metrics by id
     * Positive test case
     * @see VCR_ServiceAppointmentMetricsRepo.getServiceAppointmentMetricsByServiceAppointmentId
     */
    @IsTest
    static void funcTestingFetchServiceAppointmentMetricsByIdPositive() {
        System.runAs(ADMIN_USER) {
            VCC_Service_Appointment_Metrics__c result;
            String appointmentMetricsId;
            Case testCase = (Case) VATEST_SObjectFactory.createSObject(new Case(), true);
            ServiceAppointment serviceAppointment = (ServiceAppointment) VATEST_SObjectFactory.createSObject(
                new ServiceAppointment(ParentRecordId = testCase.Id),
                true
            );
            VCC_Service_Appointment_Metrics__c serviceAppointmentMetrics = (VCC_Service_Appointment_Metrics__c) VATEST_SObjectFactory.createSObject(
                new VCC_Service_Appointment_Metrics__c(Service_Appointment__c = serviceAppointment.Id),
                true
            );
            Test.startTest();

            VCR_ServiceAppointmentMetricsRepo repo = new VCR_ServiceAppointmentMetricsRepo();
            appointmentMetricsId = serviceAppointmentMetrics.Service_Appointment__c;
            result = repo.getServiceAppointmentMetricsByServiceAppointmentId(appointmentMetricsId);
            Test.stopTest();
            Assert.areEqual(
                result.Service_Appointment__c,
                appointmentMetricsId,
                'Expected getServiceAppointmentMetriccById to return a record with the given id'
            );
        }
    }

    /**
     * @description test the upsert service appointment metrics method
     * Positive test case
     * @see VCR_ServiceAppointmentMetricsRepo.upsertServiceAppointmentMetrics
     */
    @IsTest
    static void funcTestUpsertServiceAppointmentMetricsPositive() {
        System.runAs(ADMIN_USER) {
            VCC_Service_Appointment_Metrics__c result;
            String appointmentMetricsId;
            Case testCase = (Case) VATEST_SObjectFactory.createSObject(new Case(), true);
            ServiceAppointment serviceAppointment = (ServiceAppointment) VATEST_SObjectFactory.createSObject(
                new ServiceAppointment(ParentRecordId = testCase.Id),
                true
            );
            VCC_Service_Appointment_Metrics__c serviceAppointmentMetrics = new VCC_Service_Appointment_Metrics__c(
                Service_Appointment__c = serviceAppointment.Id
            );
            appointmentMetricsId = serviceAppointmentMetrics.Service_Appointment__c;
            List<VCC_Service_Appointment_Metrics__c> upsertList = new List<VCC_Service_Appointment_Metrics__c>();
            upsertList.add(serviceAppointmentMetrics);
            Test.startTest();

            VCR_ServiceAppointmentMetricsRepo repo = new VCR_ServiceAppointmentMetricsRepo();
            repo.upsertServiceAppointmentMetrics(upsertList);
            result = repo.getServiceAppointmentMetricsByServiceAppointmentId(appointmentMetricsId);

            Test.stopTest();
            Assert.areEqual(
                result.Service_Appointment__c,
                appointmentMetricsId,
                'Expected upsertServiceAppointmentMetrics to upsert a record'
            );
        }
    }
}
