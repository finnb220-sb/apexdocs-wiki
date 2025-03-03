/**
 * @description Test class for VCR_ClinicRepo
 * @author Booz Allen Hamilton
 *
 * @see VCR_ClinicRepo for class being tested
 */
@IsTest
public with sharing class VCR_ClinicRepoTest {
    final static User MSA_USER;
    static {
        MSA_USER = new VATEST_UserBuilder()
            .withPermissionSet('VCC_Advanced_Medical_Support_Assistant')
            .withPermissionSet('VAHC_Scheduling_User')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
    }

    /**
     * @description Test method that confirms the VCR_ClinicRepo Instantiates successfully.
     */
    @IsTest
    static void unitConstructorPositive() {
        Test.startTest();
        VCR_ClinicRepo repo;
        System.runAs(MSA_USER) {
            repo = new VCR_ClinicRepo();
        }
        Test.stopTest();
        Assert.isNotNull(repo, 'Expected constructor to properly instantiate a VCR_ClinicRepo');
        Assert.isNotNull(
            VCR_ClinicRepo.patientService,
            'Expected dataService property to instantiate a VTC_DataService'
        );
    }

    /**
     * @description Test method that confirms that the getClinicByIEN method returns an expected Clinic.
     */
    @IsTest
    static void funcGetClinicByIENWithSiteIdPositive() {
        VTC_RecordModel stubModel = new VTC_RecordModel();
        VTC_Clinic clinic = new VTC_Clinic();
        stubModel.records.add(clinic);
        System.runAs(MSA_USER) {
            Map<String, Object> args = new Map<String, Object>{
                'application' => 'VAHC',
                'siteId' => '984',
                'clinicIEN' => '2281'
            };
            Test.startTest();
            VCR_ClinicRepo repo = new VCR_ClinicRepo();
            VCR_ClinicRepo.patientService = createPatientService('get_clinic_by_ien', args, stubModel);
            clinic = (VTC_Clinic) repo.getClinicByIEN(args);
            Test.stopTest();
        }
        Assert.isNotNull(clinic, 'Assertion failed; expected a valid VTC_Record to be returned');
    }

    /**
     * @description Test method that confirms that the getClinicByName method returns an expected Clinic.
     */
    @IsTest
    static void funcGetClinicByNameWithSiteIdPositive() {
        VTC_RecordModel stubModel = new VTC_RecordModel();
        VTC_Clinic clinic = new VTC_Clinic();
        stubModel.records.add(clinic);
        List<VTC_Record> clinicRecordLst;
        System.runAs(MSA_USER) {
            Map<String, Object> args = new Map<String, Object>{
                'application' => 'VAHC',
                'vistaSiteId' => '984',
                'name' => '2281'
            };
            Test.startTest();
            VCR_ClinicRepo repo = new VCR_ClinicRepo();
            VCR_ClinicRepo.patientService = createPatientService('get_clinic_by_name', args, stubModel);
            clinicRecordLst = repo.getClinicsByName(args);
            Test.stopTest();
        }
        Assert.isNotNull(clinicRecordLst, 'Assertion failed; expected a valid VTC_Record to be returned');
    }

    /**
     * @description Test method that confirms that the getClinicByName method returns an expected Clinic.
     */
    @IsTest
    static void funcGetClinicsByProviderPositive() {
        VTC_RecordModel stubModel = new VTC_RecordModel();
        VTC_Clinic clinic = new VTC_Clinic();
        stubModel.records.add(clinic);
        List<VTC_Record> clinicRecordLst;
        System.runAs(MSA_USER) {
            Map<String, Object> args = new Map<String, Object>{
                'application' => 'VAHC',
                'vistaSiteId' => '984',
                'queryIen' => '32383'
            };
            Test.startTest();
            VCR_ClinicRepo repo = new VCR_ClinicRepo();
            VCR_ClinicRepo.patientService = createPatientService('get_clinics_by_provider', args, stubModel);
            clinicRecordLst = repo.getClinicsByProvider(args);
            Test.stopTest();
        }
        Assert.isNotNull(clinicRecordLst, 'Assertion failed; expected a valid VTC_Record to be returned');
    }

    /**
     * @description       This method is used to stub the VTC_DataService
     * @param action    The vtc endpoint to target
     * @param args        The arguments for the call
     * @param returnValue The model to return
     * @return            `VTC_PatientService`
     */
    private static VTC_PatientService createPatientService(
        String action,
        Map<String, Object> args,
        Object returnValue
    ) {
        return (VTC_PatientService) new VATEST_StubBuilder(VTC_PatientService.class)
            .mockingMethodCall('call')
            .withParameterTypes(String.class, Map<String, Object>.class)
            .withParameterValues(action, args)
            .returning(returnValue)
            .defineStub();
    }
}
