/**
 * @description Test for CancelServiceAppointment
 *              The class chooses a flow by the recordtype
 * @author      Booz Allen Hamilton
 * @since       8/5/2024
 */
@IsTest
private class CancelServiceAppointmentTest {
    final static User MSA_USER;
    static {
        MSA_USER = new VATEST_UserBuilder()
            .withPermissionSet('VCC_Advanced_Medical_Support_Assistant')
            .withPermissionSet('VCC_VCV_Appointment_Viewer_MSA')
            .withPermissionSet(' VCC_Integration_Test_Utility_User')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
    }

    @IsTest
    static void testVirtualClinicVisitNullServiceAppointmentRepo() {
        String targetRecordId = VATEST_IdFactory.get('ServiceAppointment');
        VCR_ServiceAppointmentRepo results;

        Test.startTest();
        System.runAs(MSA_USER) {
            ApexPages.StandardController stdController = new ApexPages.StandardController(
                new ServiceAppointment(Id = targetRecordId)
            );
            CancelServiceAppointment cancelSA = new CancelServiceAppointment(stdController);
            results = cancelSA.serviceAppointmentRepo;
        }
        Test.stopTest();

        Assert.areNotEqual(
            new VCR_ServiceAppointmentRepo(),
            results,
            'Expected a VCR_ServiceAppointmentRepo not to be empty.'
        );
    }

    @IsTest
    static void testVirtualClinicVisitFlowValidParameters() {
        String targetRecordId = VATEST_IdFactory.get('ServiceAppointment');
        VCR_ServiceAppointmentRepo mockServiceAppointmentRepo = (VCR_ServiceAppointmentRepo) new VATEST_StubBuilder(
                VCR_ServiceAppointmentRepo.class
            )
            .mockingMethodCall('fetchById')
            .withParameterTypes(Id.class)
            .withParameterValues(targetRecordId)
            .returning(
                new ServiceAppointment(Id = targetRecordId, RecordType = new RecordType(Name = 'Virtual Clinic Visit'))
            )
            .defineStub();
        String results = '';

        Test.startTest();
        System.runAs(MSA_USER) {
            ApexPages.StandardController stdController = new ApexPages.StandardController(
                new ServiceAppointment(Id = targetRecordId)
            );
            CancelServiceAppointment cancelSA = new CancelServiceAppointment(stdController);
            cancelSA.serviceAppointmentRepo = mockServiceAppointmentRepo;
            results = cancelSA.startCancelServiceAppointmentFlow();
        }
        Test.stopTest();

        Assert.areEqual(
            '/flow/VCC_Cancel_Service_Appointment?recordId=' + targetRecordId + '&varFromListView=true',
            results,
            'The URL does not match the expected format.'
        );
    }
    @IsTest
    static void testVirtualClinicVisitFlowWithOtherValidRecordType() {
        String targetRecordId = VATEST_IdFactory.get('ServiceAppointment');
        VCR_ServiceAppointmentRepo mockServiceAppointmentRepo = (VCR_ServiceAppointmentRepo) new VATEST_StubBuilder(
                VCR_ServiceAppointmentRepo.class
            )
            .mockingMethodCall('fetchById')
            .withParameterTypes(Id.class)
            .withParameterValues(targetRecordId)
            .returning(
                new ServiceAppointment(
                    Id = targetRecordId,
                    RecordType = new RecordType(Name = 'Not Virtual Clinic Visit')
                )
            )
            .defineStub();
        String results = '';

        Test.startTest();
        System.runAs(MSA_USER) {
            ApexPages.StandardController stdController = new ApexPages.StandardController(
                new ServiceAppointment(Id = targetRecordId)
            );
            CancelServiceAppointment cancelSA = new CancelServiceAppointment(stdController);
            cancelSA.serviceAppointmentRepo = mockServiceAppointmentRepo;
            results = cancelSA.startCancelServiceAppointmentFlow();
        }
        Test.stopTest();

        Assert.areEqual(
            '/flow/Inbound_Cancel_Appointment_Flow?recordId=' + targetRecordId + '&varPageRedirect=true',
            results,
            'The URL does not match the expected format.'
        );
    }
    @IsTest
    static void testVirtualClinicVisitFlowWithnullRecordId() {
        String targetRecordId = null;
        VCR_ServiceAppointmentRepo mockServiceAppointmentRepo = (VCR_ServiceAppointmentRepo) new VATEST_StubBuilder(
                VCR_ServiceAppointmentRepo.class
            )
            .mockingMethodCall('fetchById')
            .withParameterTypes(Id.class)
            .returning(
                new ServiceAppointment(Id = targetRecordId, RecordType = new RecordType(Name = 'Virtual Clinic Visit'))
            )
            .defineStub();
        String results = '';

        Test.startTest();
        System.runAs(MSA_USER) {
            ApexPages.StandardController stdController = new ApexPages.StandardController(
                new ServiceAppointment(Id = targetRecordId)
            );
            CancelServiceAppointment cancelSA = new CancelServiceAppointment(stdController);
            cancelSA.serviceAppointmentRepo = mockServiceAppointmentRepo;
            results = cancelSA.startCancelServiceAppointmentFlow();
        }
        Test.stopTest();

        Assert.areEqual(null, results, 'The null was expected.');
    }

    @IsTest
    static void testVirtualClinicVisitFlowWithnullRecordTypeName() {
        String targetRecordId = VATEST_IdFactory.get('ServiceAppointment');
        VCR_ServiceAppointmentRepo mockServiceAppointmentRepo = (VCR_ServiceAppointmentRepo) new VATEST_StubBuilder(
                VCR_ServiceAppointmentRepo.class
            )
            .mockingMethodCall('fetchById')
            .withParameterTypes(Id.class)
            .withParameterValues(targetRecordId)
            .returning(new ServiceAppointment(Id = targetRecordId, RecordType = new RecordType(Name = null)))
            .defineStub();
        String results = '';

        Test.startTest();
        System.runAs(MSA_USER) {
            ApexPages.StandardController stdController = new ApexPages.StandardController(
                new ServiceAppointment(Id = targetRecordId)
            );
            CancelServiceAppointment cancelSA = new CancelServiceAppointment(stdController);
            cancelSA.serviceAppointmentRepo = mockServiceAppointmentRepo;
            results = cancelSA.startCancelServiceAppointmentFlow();
        }
        Test.stopTest();

        Assert.areEqual(null, results, 'The null was expected.');
    }

    @IsTest
    static void testVirtualClinicVisitFlowWithEmptyRecordTypeName() {
        String targetRecordId = VATEST_IdFactory.get('ServiceAppointment');
        VCR_ServiceAppointmentRepo mockServiceAppointmentRepo = (VCR_ServiceAppointmentRepo) new VATEST_StubBuilder(
                VCR_ServiceAppointmentRepo.class
            )
            .mockingMethodCall('fetchById')
            .withParameterTypes(Id.class)
            .withParameterValues(targetRecordId)
            .returning(new ServiceAppointment(Id = targetRecordId, RecordType = new RecordType(Name = '')))
            .defineStub();
        String results = '';

        Test.startTest();
        System.runAs(MSA_USER) {
            ApexPages.StandardController stdController = new ApexPages.StandardController(
                new ServiceAppointment(Id = targetRecordId)
            );
            CancelServiceAppointment cancelSA = new CancelServiceAppointment(stdController);
            cancelSA.serviceAppointmentRepo = mockServiceAppointmentRepo;
            results = cancelSA.startCancelServiceAppointmentFlow();
        }
        Test.stopTest();

        Assert.areEqual(null, results, 'Expected a null result.');
    }

    @IsTest
    static void testVirtualClinicVisitFlowWithEmptyRecordID() {
        String targetRecordId = VATEST_IdFactory.get('ServiceAppointment');
        VCR_ServiceAppointmentRepo mockServiceAppointmentRepo = (VCR_ServiceAppointmentRepo) new VATEST_StubBuilder(
                VCR_ServiceAppointmentRepo.class
            )
            .mockingMethodCall('fetchById')
            .withParameterTypes(Id.class)
            .withParameterValues(targetRecordId)
            .throwingException(new StringException('Invalid id'))
            .defineStub();
        String results = '';

        Boolean didThrow = false;

        try {
            Test.startTest();
            System.runAs(MSA_USER) {
                ApexPages.StandardController stdController = new ApexPages.StandardController(
                    new ServiceAppointment(Id = targetRecordId)
                );
                CancelServiceAppointment cancelSA = new CancelServiceAppointment(stdController);
                cancelSA.serviceAppointmentRepo = mockServiceAppointmentRepo;
                results = cancelSA.startCancelServiceAppointmentFlow();
            }
            Test.stopTest();
        } catch (StringException e) {
            System.assert(e.getMessage().contains('Invalid id'), 'The exception message was not as expected.');
            didThrow = true;
        }

        System.assert(didThrow, 'Expected a StringException to be thrown.');

        Assert.areEqual('', results, 'The URL should be an empty string.');
    }
}
