/**
 * @description Test class for VCC_ClinicSearchControllerTest
 * @author Booz Allen Hamilton
 * @since  3/20/2024
 */
@isTest
private class VCC_ClinicSearchControllerTest {
    final static String NAME = 'ClinicName';
    final static String FACILITY_CODE = '984';
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
     * @description Test method that confirms that the clinicRepo property injects successfully.
     */
    @isTest
    static void unitDidRepoInitializeTest() {
        Test.startTest();
        System.runAs(MSA_USER) {
            VCC_ClinicSearchController.clinicRepo = null;
        }
        Test.stopTest();
        Assert.isNotNull(
            VCC_ClinicSearchController.clinicRepo,
            'Assertion failed; Expected a non-null value for VCC_ClinicSearchController.clinicRepo'
        );
    }

    /**
     * @description Test method that confirms that a List of VTC_Clinic records are returned
     * when a Facility Code and Name is passed to searchClinicsByNameExternal
     */
    @IsTest
    static void unitGetClinicByNamePositive() {
        List<VTC_Record> recordList = new List<VTC_Record>();
        VTC_Clinic stubClinicRecord = new VTC_Clinic();
        stubClinicRecord.vtcId = '1';
        recordList.add(stubClinicRecord);

        Map<String, Object> requestBodyArgs = new Map<String, Object>{
            'application' => 'VAHC',
            'vistaSiteId' => FACILITY_CODE,
            'name' => NAME
        };

        VCR_ClinicRepo stubClinicRepo = (VCR_ClinicRepo) new VATEST_StubBuilder(VCR_ClinicRepo.class)
            .mockingMethodCall('getClinicsByName', Map<String, Object>.class)
            .withParameterValues(requestBodyArgs)
            .returning((List<VTC_Record>) recordList)
            .defineStub();

        Test.startTest();
        List<VTC_Record> clinicRecordList;
        System.runAs(MSA_USER) {
            VCC_ClinicSearchController.clinicRepo = stubClinicRepo;
            clinicRecordList = (List<VTC_Record>) VCC_ClinicSearchController.getClinicsByName(NAME, FACILITY_CODE);
        }
        Test.stopTest();

        Assert.isNotNull(clinicRecordList, 'Assertion failed; expected clinicRecordList to not be null');
        Assert.isNotNull(clinicRecordList[0].vtcId, 'Assertion failed; expected vtcId to not be null');
        Assert.areEqual(
            clinicRecordList[0].vtcId,
            recordList[0].vtcId,
            'Assertion failed; expected clinicRecordList and recordList vtcIds to match'
        );
    }
    /**
     * @description Test method that confirms that an exception is thrown when empty properties are passed as the request argument
     */
    @IsTest
    static void unitGetClinicByNameEmptyPropertiesNegative() {
        Test.startTest();
        List<VTC_Clinic> clinicRecordList;
        System.runAs(MSA_USER) {
            try {
                clinicRecordList = (List<VTC_Clinic>) VCC_ClinicSearchController.getClinicsByName('', '');
                Assert.isTrue(false, 'Test failed; expected an exception to be thrown.');
            } catch (AuraHandledException auraError) {
                Assert.areEqual(
                    'Invalid Request. Null/Empty request properties detected.',
                    auraError.getMessage(),
                    'Assertion failed; expected error message to be Invalid Request. Null/Empty request properties detected.'
                );
            }
        }
        Test.stopTest();
    }

    /**
     * @description Test method that confirms that an exception is thrown when null properties are passed as the request argument
     */
    @IsTest
    static void unitGetClinicByNameNullPropertiesNegative() {
        Test.startTest();
        List<VTC_Record> clinicRecordList;
        System.runAs(MSA_USER) {
            try {
                clinicRecordList = (List<VTC_Clinic>) VCC_ClinicSearchController.getClinicsByName(null, null);
                Assert.isTrue(false, 'Test failed; expected an exception to be thrown.');
            } catch (AuraHandledException auraError) {
                Assert.areEqual(
                    'Invalid Request. Null/Empty request properties detected.',
                    auraError.getMessage(),
                    'Assertion failed; expected error message to be Invalid Request. Null/Empty request properties detected.'
                );
            }
        }
        Test.stopTest();
    }

    /**
     * @description Test method that confirms that a VTC_LimitException is caught
     */
    @IsTest
    static void unitGetClinicByNameLimitExceptionNegative() {
        VTC_LimitException stubLimitException = new VTC_LimitException();
        stubLimitException.setMessage('Timeout Exception');
        Map<String, Object> requestBodyArgs = new Map<String, Object>{
            'application' => 'VAHC',
            'vistaSiteId' => FACILITY_CODE,
            'name' => NAME
        };
        VCR_ClinicRepo stubClinicRepo = (VCR_ClinicRepo) new VATEST_StubBuilder(VCR_ClinicRepo.class)
            .mockingMethodCall('getClinicsByName', Map<String, Object>.class)
            .withParameterValues(requestBodyArgs)
            .throwingException(stubLimitException)
            .defineStub();

        Test.startTest();
        List<VTC_Record> clinicRecordList;
        System.runAs(MSA_USER) {
            VCC_ClinicSearchController.clinicRepo = stubClinicRepo;
            try {
                clinicRecordList = (List<VTC_Clinic>) VCC_ClinicSearchController.getClinicsByName(NAME, FACILITY_CODE);
                Assert.isTrue(false, 'Test failed; expected an exception to be thrown.');
            } catch (AuraHandledException auraError) {
                Assert.areEqual(
                    'Timeout Exception',
                    auraError.getMessage(),
                    'Assertion failed; expected error message to be Timeout Exception'
                );
            }
        }
        Test.stopTest();
    }
}
