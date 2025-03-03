/**
 * @description Tests for VCC_ServiceAppointmentMetrics class
 * @author BAH
 * @see VCC_ServiceAppointmentMetrics
 * @see VCC_Service_Appointment_Metrics__c
 */
@IsTest
private class VCC_ServiceAppointmentMetricsTest {
    private static final User ADMIN_USER;
    static {
        ADMIN_USER = new VATEST_UserBuilder()
            .withUserProfile('System Administrator')
            .withPermissionSet('VAHC_Standard_VCC_User')
            .withStandardData()
            .build(true);
    }
    /**
     * @description Test to get the VCR_CaseMetricRepo instance
     * Positive test case
     * @see VCC_ServiceAppointmentMetrics.caseMetricRepo
     */
    @IsTest
    static void unitTestVCRCaseRepoInstancePositive() {
        System.runAs(ADMIN_USER) {
            VCR_CaseMetricRepo vcrCaseMetricRepo;
            Test.startTest();
            vcrCaseMetricRepo = VCC_ServiceAppointmentMetrics.caseMetricRepo;
            Test.stopTest();
            Assert.isTrue(vcrCaseMetricRepo != null, 'VCR_CaseMetricRepo instance is null');
        }
    }
    /**
     * @description Test to get the VCR_ServiceAppointmentMetricsRepo instance
     * Positive test case
     * @see VCC_ServiceAppointmentMetrics.serviceAppointmentMetricsRepo
     */
    @IsTest
    static void unitTestVCRServiceAppointmentMetricsRepoInstancePositive() {
        System.runAs(ADMIN_USER) {
            VCR_ServiceAppointmentMetricsRepo vcrServiceAppointmentMetricRepo;
            Test.startTest();
            vcrServiceAppointmentMetricRepo = VCC_ServiceAppointmentMetrics.serviceAppointmentMetricsRepo;
            Test.stopTest();
            Assert.isTrue(vcrServiceAppointmentMetricRepo != null, 'VCR_ServiceAppointmentMetricRepo instance is null');
        }
    }
    /**
     * @description Test to get the VCR_ServiceAppointmentRepo instance
     * Positive test case
     * @see VCC_ServiceAppointmentMetrics.serviceAppointmentRepo
     */
    @IsTest
    static void unitTestVCRServiceAppointmentRepoInstancePositive() {
        System.runAs(ADMIN_USER) {
            VCR_ServiceAppointmentRepo vcrServiceAppointmentRepo;
            Test.startTest();
            vcrServiceAppointmentRepo = VCC_ServiceAppointmentMetrics.serviceAppointmentRepo;
            Test.stopTest();
            Assert.isTrue(vcrServiceAppointmentRepo != null, 'VCR_ServiceAppointmentMetricRepo instance is null');
        }
    }

    /**
     * @description Test to get the bind variables
     * Positive test case
     * @see VCC_ServiceAppointmentMetrics.getBindVariables
     */
    @IsTest
    static void unitTestGetBindVariablesPositive() {
        System.runAs(ADMIN_USER) {
            Map<String, Object> result;
            Map<String, Object> expected = new Map<String, Object>{ 'recordTypeName' => 'VCC_Vitrual_Clinic_Visit' };
            Test.startTest();
            VCC_ServiceAppointmentMetrics vccServiceAppointmentMetrics = new VCC_ServiceAppointmentMetrics();
            result = vccServiceAppointmentMetrics.getBindVariables();
            Test.stopTest();
            Assert.areEqual(
                expected,
                result,
                'Expected bind variables not returned from the VCC_ServiceAppointmentMetrics.getBindVariables() method'
            );
        }
    }
    /**
     * @description Test to get the query locator
     * Positive test case
     * @see VCC_ServiceAppointmentMetrics.getQueryLocator
     */
    @IsTest
    static void funcTestGetQueryLocatorPositive() {
        System.runAs(ADMIN_USER) {
            Database.QueryLocator result;
            Test.startTest();
            VCC_ServiceAppointmentMetrics vccServiceAppointmentMetrics = new VCC_ServiceAppointmentMetrics();
            result = vccServiceAppointmentMetrics.getQueryLocator(vccServiceAppointmentMetrics.getQueryLocatorString());
            Test.stopTest();
            Assert.isTrue(result != null, 'VCC_ServiceAppointmentMetrics.getQueryLocator() returned null');
        }
    }

    /**
     * @description Test to execute the VCC_ServiceAppointmentMetrics class
     * Positive test case
     * Scenario that has records with linkage between the (Scheduling case)parent case and the
     * (VCV Case) child case this is automatically created from the service appointment.
     * Realistic scenario that covers the expected state of prod when this batch is run.
     * This scenario mimics the expected state of prod containing historical records with and without the linkage.
     * @see VCC_ServiceAppointmentMetrics.execute
     */
    @IsTest
    static void funcTestExecutePositiveMixedRecords() {
        System.runAs(ADMIN_USER) {
            Set<Id> caseIds = new Set<Id>();
            Set<Id> serviceAppointmentIds = new Set<Id>();
            Set<Id> caseMetricIds = new Set<Id>();
            Account account = (Account) VATEST_SObjectFactory.createSObject(new Account(), true);
            List<ServiceAppointment> inputServiceAppointments = new List<ServiceAppointment>();
            User provider = (User) VATEST_UserFactory.createTestUser('VAVET Base Profile', true);
            String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
                .get('VCC_Vitrual_Clinic_Visit')
                .getRecordTypeId();
            List<Case> parentCases = (List<Case>) VATEST_SObjectFactory.createSObjects(
                new Case(OwnerId = provider.Id),
                5,
                true
            );
            List<Case> cases = new List<Case>();
            for (Case parentCase : parentCases) {
                cases.add(
                    (Case) VATEST_SObjectFactory.createSObject(
                        new Case(OwnerId = provider.Id, RecordTypeId = recordTypeId, ParentId = parentCase.Id),
                        true
                    )
                );
            }
            //create case metrics for the parent cases, but only for the first 3 to replicate production data
            for (Integer count = 0; count < 3; count++) {
                caseMetricIds.add(
                    VATEST_SObjectFactory.createSObject(
                            new VCC_Case_Metrics__c(
                                VCC_Case__c = parentCases[count].Id,
                                VCC_Child_Case__c = cases[count].Id
                            ),
                            true
                        )
                        .Id
                );
            }
            for (Integer count = 0; count < cases.size(); count++) {
                ServiceAppointment serviceAppointment = (ServiceAppointment) VATEST_SObjectFactory.createSObject(
                    new ServiceAppointment(
                        ParentRecordId = account.Id,
                        OwnerId = provider.Id,
                        Status = 'Scheduled',
                        Case__c = cases[count].Id
                    ),
                    true
                );
                inputServiceAppointments.add(serviceAppointment);
                serviceAppointmentIds.add(serviceAppointment.Id);
                caseIds.add(cases[count].Id);
            }
            List<ServiceAppointment> scopeServiceAppointments = [
                SELECT
                    Id,
                    Case__c,
                    CreatedDate,
                    (
                        SELECT Id, ParentId, Case_Record_Type_Name__c
                        FROM Cases__r
                        WHERE Case_Record_Type_Name__c = 'VCC_Vitrual_Clinic_Visit'
                    ),
                    (
                        SELECT Id, Case_Metrics__c, Case__c, Service_Appointment__c
                        FROM Service_Appointment_Metrics__r
                        LIMIT 1
                    )
                FROM ServiceAppointment
                ORDER BY CreatedDate ASC
                LIMIT 5
            ]; //this is the equivalent of the query locator in service appointment repo except it's modified to return the necessary fields.
            Test.startTest();
            System.runAs(ADMIN_USER) {
                VCC_ServiceAppointmentMetrics vccServiceAppointmentMetrics = new VCC_ServiceAppointmentMetrics();
                vccServiceAppointmentMetrics.execute(scopeServiceAppointments);
            }
            Test.stopTest();
            List<VCC_Service_Appointment_Metrics__c> serviceAppointmentMetrics = [
                SELECT Id, Case__c, Case_Metrics__c, Service_Appointment__c
                FROM VCC_Service_Appointment_Metrics__c
                WHERE Service_Appointment__c IN :inputServiceAppointments
            ];
            Assert.isTrue(
                serviceAppointmentMetrics.size() == inputServiceAppointments.size(),
                'Service Appointment Metrics not created'
            );
            for (VCC_Service_Appointment_Metrics__c serviceAppointmentMetric : serviceAppointmentMetrics) {
                if (serviceAppointmentMetric.Case_Metrics__c != null) {
                    Assert.isTrue(
                        caseMetricIds.contains(serviceAppointmentMetric.Case_Metrics__c),
                        'Case Metrics not found in caseMetricIds list'
                    );
                } else {
                    Assert.isNull(serviceAppointmentMetric.Case_Metrics__c, 'Case Metrics should be null');
                }
            }
            //check the records for the 3 fields that have to be set up
            //Case__c, Case_Metrics__c, Service_Appointment__c
            for (VCC_Service_Appointment_Metrics__c serviceAppointmentMetric : serviceAppointmentMetrics) {
                Assert.isTrue(caseIds.contains(serviceAppointmentMetric.Case__c), 'Case not found in cases list');
            }
            for (VCC_Service_Appointment_Metrics__c serviceAppointmentMetric : serviceAppointmentMetrics) {
                Assert.isTrue(
                    serviceAppointmentIds.contains(serviceAppointmentMetric.Service_Appointment__c),
                    'Service Appointment not found in inputServiceAppointments list'
                );
            }
        }
    }
    /**
     * @description Test to execute the VCC_ServiceAppointmentMetrics class
     * Positive test case
     * Scenario that has records with no linkage between the (Scheduling case)parent case and the
     * (VCV Case) child case this is automatically created from the service appointment.
     * Possible scenario that covers the expected state of prod when this batch is run.
     * This is a scenario from a story that was created to create a link between the scheduling case
     * and the VCV case, prior to that the records were created without the linkage.
     * In prod the majority of the historical records will not have the linkage.
     * @see VCC_ServiceAppointmentMetrics.execute
     */
    @IsTest
    static void funcTestExecutePositiveNoLinkageBetweenRecords() {
        System.runAs(ADMIN_USER) {
            Set<Id> caseIds = new Set<Id>();
            Set<Id> serviceAppointmentIds = new Set<Id>();
            Account account = (Account) VATEST_SObjectFactory.createSObject(new Account(), true);
            List<ServiceAppointment> inputServiceAppointments = new List<ServiceAppointment>();
            User provider = (User) VATEST_UserFactory.createTestUser('VAVET Base Profile', true);
            String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
                .get('VCC_Vitrual_Clinic_Visit')
                .getRecordTypeId();
            List<Case> cases = new List<Case>();
            cases = (List<Case>) VATEST_SObjectFactory.createSObjects(
                new Case(OwnerId = provider.Id, RecordTypeId = recordTypeId),
                5,
                true
            );
            for (Integer count = 0; count < cases.size(); count++) {
                ServiceAppointment serviceAppointment = (ServiceAppointment) VATEST_SObjectFactory.createSObject(
                    new ServiceAppointment(
                        ParentRecordId = account.Id,
                        OwnerId = provider.Id,
                        Status = 'Scheduled',
                        Case__c = cases[count].Id
                    ),
                    true
                );
                inputServiceAppointments.add(serviceAppointment);
                serviceAppointmentIds.add(serviceAppointment.Id);
                caseIds.add(cases[count].Id);
            }
            List<ServiceAppointment> scopeServiceAppointments = [
                SELECT
                    Id,
                    Case__c,
                    CreatedDate,
                    (
                        SELECT Id, ParentId, Case_Record_Type_Name__c
                        FROM Cases__r
                        WHERE Case_Record_Type_Name__c = 'VCC_Vitrual_Clinic_Visit'
                    ),
                    (
                        SELECT Id, Case_Metrics__c, Case__c, Service_Appointment__c
                        FROM Service_Appointment_Metrics__r
                        LIMIT 1
                    )
                FROM ServiceAppointment
                ORDER BY CreatedDate ASC
                LIMIT 5
            ]; //this is the equivalent of the query locator in service appointment repo except it's modified to return the necessary fields.
            Test.startTest();
            VCC_ServiceAppointmentMetrics vccServiceAppointmentMetrics = new VCC_ServiceAppointmentMetrics();
            vccServiceAppointmentMetrics.execute(scopeServiceAppointments);
            Test.stopTest();
            List<VCC_Service_Appointment_Metrics__c> serviceAppointmentMetrics = [
                SELECT Id, Case__c, Case_Metrics__c, Service_Appointment__c
                FROM VCC_Service_Appointment_Metrics__c
                WHERE Service_Appointment__c IN :inputServiceAppointments
            ];
            Assert.isTrue(
                serviceAppointmentMetrics.size() == inputServiceAppointments.size(),
                'Service Appointment Metrics not created'
            );
            for (VCC_Service_Appointment_Metrics__c serviceAppointmentMetric : serviceAppointmentMetrics) {
                Assert.isNull(serviceAppointmentMetric.Case_Metrics__c, 'Case Metrics should be null');
            }
            //check the records for the 3 fields that have to be set up
            //Case__c, Case_Metrics__c, Service_Appointment__c
            for (VCC_Service_Appointment_Metrics__c serviceAppointmentMetric : serviceAppointmentMetrics) {
                Assert.isTrue(caseIds.contains(serviceAppointmentMetric.Case__c), 'Case not found in cases list');
            }
            for (VCC_Service_Appointment_Metrics__c serviceAppointmentMetric : serviceAppointmentMetrics) {
                Assert.isTrue(
                    serviceAppointmentIds.contains(serviceAppointmentMetric.Service_Appointment__c),
                    'Service Appointment not found in inputServiceAppointments list'
                );
            }
        }
    }
}
