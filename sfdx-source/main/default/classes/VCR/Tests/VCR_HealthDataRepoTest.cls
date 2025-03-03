/**
 * @description Tests the Health Data Repo Class
 * @author Booz Allen
 * @since 10/17/2024
 * @see VCR_HealthDataRepo for class being tested
 * @modified October 17, 2024
 */
@IsTest
private with sharing class VCR_HealthDataRepoTest {
    private static final String FAKE_ICN = 'fakeICN';

    @IsTest
    private static void unitFetchHealthDataConfig() {
        Test.startTest();
        User vaVetUser = new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);

        System.runAs(vaVetUser) {
            VCR_HealthDataRepo healthDataRepo = new VCR_HealthDataRepo('labs');
            healthDataRepo.patientAccount = new Account(name = 'testAccount', Date_of_Birth__pc = '11/12/1993');
            VCR_HealthDataRepo.Model healthDataRepoModel = healthDataRepo.fetchHealthDataConfig();
            Assert.isTrue(
                healthDataRepoModel.patientBirthYear == '1993',
                'Expected birth year be 1993 actual: ' + healthDataRepoModel.patientBirthYear
            );
        }
        Test.stopTest();
    }

    /**
     * @description Given a valid ICN, and a patient that corresponds to the ICN passed into the setPatientByICNMethod,
     * Assert that the internal property `patientAccount` is set to the corresponding account.
     */
    @IsTest
    private static void unitSetPatientByICNPositive() {
        User vaVetUser = new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
        VCR_HealthDataRepo healthDataRepo = new VCR_HealthDataRepo('labs');
        Account expectedAccount = (Account) VATEST_SObjectFactory.createSObject(
            new Account(VCC_MVI_External_Id__pc = FAKE_ICN)
        );
        VCR_HealthDataRepo.accountRepo = (VCR_AccountRepo) new VATEST_StubBuilder(VCR_AccountRepo.class)
            .mockingMethodCall('fetchPersonAccountsViaICN')
            .withParameterTypes(Set<String>.class)
            .withParameterValues(new Set<String>{ FAKE_ICN })
            .returning(new List<Account>{ expectedAccount })
            .defineStub();

        Test.startTest();
        System.runAs(vaVetUser) {
            healthDataRepo.setPatientByICN(FAKE_ICN);
        }
        Test.stopTest();
        Assert.areEqual(
            healthDataRepo.patientAccount,
            expectedAccount,
            'Expected  the internal property \'patientAccount\' to be set to the patient record that was returned from our query.'
        );
    }

    /**
     * @description Given a blank ICN is passed to the setPatientByICN method,
     * Assert that an exception is thrown.
     * Assert that the exception has a descriptive error message, set by the classes internal constant.
     */
    @IsTest
    private static void unitSetPatientByICNWithEmptyICNNegative() {
        User vaVetUser = new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
        String errorMessage;
        Test.startTest();
        System.runAs(vaVetUser) {
            VCR_HealthDataRepo healthDataRepo = new VCR_HealthDataRepo('labs');

            try {
                healthDataRepo.setPatientByICN('');
                Assert.fail(
                    'Expected an exception to be thrown when trying to set a patient by ICN with an empty ICN.'
                );
            } catch (VCC_InvalidArgumentException invalidArgException) {
                errorMessage = invalidArgException.getMessage();
            }
        }
        Test.stopTest();
        Assert.areEqual(
            errorMessage,
            VCR_HealthDataRepo.NULL_OR_EMPTY_ICN_ERROR_MSG,
            'Expected exception message to be set by static final constant \'NULL_OR_EMPTY_ICN_ERROR_MSG\'.'
        );
    }

    /**
     * @description Given we call setPatientByICN with a valid icn and nothing is returned from our query on personAccounts.
     * Assert that an exception is thrown.
     * Assert that the exception has a descriptive error message, set by the classes internal constant.
     */
    @IsTest
    private static void unitSetPatientByICNWithNoPatientReturnedFromQueryNegative() {
        User vaVetUser = new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
        VCR_HealthDataRepo healthDataRepo = new VCR_HealthDataRepo('labs');
        VCR_HealthDataRepo.accountRepo = (VCR_AccountRepo) new VATEST_StubBuilder(VCR_AccountRepo.class)
            .mockingMethodCall('fetchPersonAccountsViaICN')
            .withParameterTypes(Set<String>.class)
            .withParameterValues(new Set<String>{ FAKE_ICN })
            .returning(new List<Account>())
            .defineStub();

        String errorMessage;
        Test.startTest();
        System.runAs(vaVetUser) {
            try {
                healthDataRepo.setPatientByICN(FAKE_ICN);
                Assert.fail(
                    'Expected an exception to be thrown when trying to set a patient by ICN when no patient record is returned from our query.'
                );
            } catch (VCC_InvalidArgumentException invalidArgException) {
                errorMessage = invalidArgException.getMessage();
            }
        }
        Test.stopTest();
        Assert.isTrue(
            errorMessage.contains(VCR_HealthDataRepo.WRONG_NUMBER_OF_PATIENTS_RETURNED_FROM_ICN_MSG),
            'Expected exception message to be set by static final constant \'WRONG_NUMBER_OF_PATIENTS_RETURNED_FROM_ICN_MSG\'.'
        );
    }
}
