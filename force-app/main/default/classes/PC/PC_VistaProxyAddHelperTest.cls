/**
 * @description test class for PC_VistaProxyAddHelper
 * @author      Booz Allen
 * @since       2024
 * @see         PC_VistaProxyAddHelper
 */
@IsTest
private class PC_VistaProxyAddHelperTest {
    private static User testUser;
    static {
        testUser = new VATEST_UserBuilder()
            .withPermissionSet('PrC_Specialist_Users')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
    }

    /**
     * @description positive test of PC_VistaProxyAddHelper
     */
    @IsTest
    private static void unitAddPatientToVistaPositive() {
        // Test data setup

        VCR_AccountRepo acctRepo = new VCR_AccountRepo();
        PC_VistaProxyAddHelper proxyHelper = new PC_VistaProxyAddHelper();

        Account testAccountWithDate = (Account) VATEST_SObjectFactory.createSObject(
            new Account(
                RecordTypeId = acctRepo.recordTypeConstant.fromDeveloperName('PersonAccount').Id,
                FirstName = 'Goku',
                LastName = 'Son',
                VCC_MVI_External_Id__pc = '1012666986V102800',
                PersonBirthdate = Date.newInstance(1985, 12, 9),
                HealthCloudGA__Gender__pc = 'M'
            ),
            false
        );

        VCR_AccountRepo accountRepoStubbed = (VCR_AccountRepo) new VATEST_StubBuilder(VCR_AccountRepo.class)
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(
                testAccountWithDate.Id,
                new Set<String>{
                    'FirstName',
                    'LastName',
                    'VCC_MVI_External_Id__pc',
                    'HealthCloudGA__Gender__pc',
                    'PersonBirthdate'
                }
            )
            .returning(testAccountWithDate)
            .defineStub();

        PC_VistaProxyAddHelper.vcrAccountRepo = accountRepoStubbed;

        String result;
        System.runAs(testUser) {
            Test.setMock(HttpCalloutMock.class, new MPISingleRequestMock('addVista'));

            // Actual test
            Test.startTest();

            result = proxyHelper.vistaProxyAddCallout(testAccountWithDate.Id, '695');

            Test.stopTest();
        }

        // Asserts
        Assert.areNotEqual(
            'Error',
            result,
            'Expected Patient to be added to Vista instance, but callout returned \'Error\''
        );
    }

    /**
     * @description test PC_VistaProxyAddHelper with an expected 'Error'
     */
    @IsTest
    private static void unitAddPatientToVistaNegative() {
        // Test data setup
        VCR_AccountRepo acctRepo = new VCR_AccountRepo();
        PC_VistaProxyAddHelper proxyHelper = new PC_VistaProxyAddHelper();

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

        String result;
        System.runAs(testUser) {
            // Actual test
            Test.startTest();

            result = proxyHelper.vistaProxyAddCallout(testAccountWithoutDate.Id, '695');

            Test.stopTest();
        }

        // Asserts
        Assert.isTrue(
            result.contains('Error'),
            'Expected vistaProxyAddCallout() to return an \'Error\' result for AddProxy Callout.'
        );
    }
}
