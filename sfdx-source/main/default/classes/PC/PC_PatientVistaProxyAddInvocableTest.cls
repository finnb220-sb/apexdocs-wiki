/**
 * @description test class for PC_PatientVistaProxyAddInvocable
 * @author      Booz Allen
 * @see         PC_PatientVistaProxyAddInvocable
 */
@IsTest
private class PC_PatientVistaProxyAddInvocableTest {
    private static User testUser;
    static {
        testUser = new VATEST_UserBuilder()
            .withPermissionSet('PrC_Specialist_Users')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
    }

    /**
     * @description positive test of getPatientInfoFromFlow that returns the expected proxy add success result message
     */
    @IsTest
    private static void unitGetPatientInfoFromFlowPositive() {
        Id patientAcctId = VATEST_IdFactory.get(Account.class);
        String mockReturnValue = 'Correlation Proxy Added to VistA';

        PC_PatientVistaProxyAddInvocable.ProxyAddFlowInput info = new PC_PatientVistaProxyAddInvocable.ProxyAddFlowInput();
        info.patientAccountId = patientAcctId;
        info.stationId = '695';

        List<PC_PatientVistaProxyAddInvocable.ProxyAddFlowOutput> resultInfo = new List<PC_PatientVistaProxyAddInvocable.ProxyAddFlowOutput>();

        // Actual test
        Test.startTest();
        System.runAs(testUser) {
            PC_VistaProxyAddHelper proxyAddHelperStubbed = (PC_VistaProxyAddHelper) new VATEST_StubBuilder(
                    PC_VistaProxyAddHelper.class
                )
                .mockingMethodCall('vistaProxyAddCallout')
                .withParameterTypes(Id.class, String.class)
                .withParameterValues(patientAcctId, '695')
                .returning(mockReturnValue)
                .defineStub();

            PC_PatientVistaProxyAddInvocable.vistaProxyAdd = proxyAddHelperStubbed;

            resultInfo = PC_PatientVistaProxyAddInvocable.getPatientInfoFromFlow(
                new List<PC_PatientVistaProxyAddInvocable.ProxyAddFlowInput>{ info }
            );
            Test.stopTest();
        }

        //Asserts
        Assert.areEqual(
            mockReturnValue,
            resultInfo[0].calloutResult,
            'Expected result to be the Success message for Proxy Add to VistA when invoking getPatientInfoFromFlow, but observed the callout returning \'Error\' message'
        );
    }

    /**
     * @description negative test of getPatientInfoFromFlow with an expected 'Error'
     */
    @IsTest
    private static void unitGetPatientInfoFromFlowNegative() {
        // Test data setup
        List<PC_PatientVistaProxyAddInvocable.ProxyAddFlowOutput> flowOutput = new List<PC_PatientVistaProxyAddInvocable.ProxyAddFlowOutput>();
        VCR_AccountRepo acctRepo = new VCR_AccountRepo();

        Account testAccountWithoutDate = (Account) VATEST_SObjectFactory.createSObject(
            new Account(
                RecordTypeId = acctRepo.recordTypeConstant.fromDeveloperName('PersonAccount').Id,
                FirstName = 'Gohan',
                LastName = 'Son',
                VCC_MVI_External_Id__pc = '1012666986V102801',
                HealthCloudGA__Gender__pc = 'M'
            ),
            false
        );

        VCR_AccountRepo accountRepoStubbed = (VCR_AccountRepo) new VATEST_StubBuilder(VCR_AccountRepo.class)
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(
                testAccountWithoutDate.Id,
                new Set<String>{
                    'FirstName',
                    'LastName',
                    'VCC_MVI_External_Id__pc',
                    'HealthCloudGA__Gender__pc',
                    'PersonBirthdate'
                }
            )
            .returning(testAccountWithoutDate)
            .defineStub();

        PC_VistaProxyAddHelper.vcrAccountRepo = accountRepoStubbed;

        PC_PatientVistaProxyAddInvocable.ProxyAddFlowInput flowInput = new PC_PatientVistaProxyAddInvocable.ProxyAddFlowInput();
        flowInput.patientAccountId = testAccountWithoutDate.Id;

        System.runAs(testUser) {
            // Actual test
            Test.startTest();

            flowOutput = PC_PatientVistaProxyAddInvocable.getPatientInfoFromFlow(
                new List<PC_PatientVistaProxyAddInvocable.ProxyAddFlowInput>{ flowInput }
            );

            Test.stopTest();
        }

        // Asserts
        Assert.isTrue(
            flowOutput[0].calloutResult.contains('Error'),
            'Expected return result to be an \'Error\' message when invoking getPatientInfoFromFlow, but no error was observed.'
        );
    }
}
