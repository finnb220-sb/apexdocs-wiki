/**
 * @description Test for VCC_AllergyListController class.
 * @author Booz Allen
 *
 * @see VCC_AllergyListController
 */
@isTest
public with sharing class VCC_AllergyListControllerTest {
    @IsTest
    private static void ensureCorrectDefaultInitialization() {
        Test.startTest();
        VCC_AllergyListController allergyController = new VCC_AllergyListController();
        Test.stopTest();

        Assert.isTrue(allergyController != null, 'Expected class to be initialized.');
        Assert.isTrue(VCC_AllergyListController.allergyRepo != null, 'Expected allergyRepo to be initialized.');
    }

    @IsTest
    private static void unitFetchAllergies() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCC_AllergyListController.allergyRepo = createAllergyRepo(args, new VTC_DataModel());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VTC_DataModel allergyDataModel = (VTC_DataModel) VCC_AllergyListController.fetchAllergies(args);
            Assert.isTrue(allergyDataModel != null, 'Expected valid non-null model to be returned.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitFetchAllergiesVTCExceptionNoRetry() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCC_AllergyListController.allergyRepo = createAllergyRepo(args, new VTC_InternalException());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            try {
                VCC_AllergyListController.fetchAllergies(args);
                Assert.fail('Expected exception to be thrown.');
            } catch (Exception caughtException) {
                Assert.areEqual(
                    VCC_AllergyListController.NO_RETRY_CMD,
                    caughtException.getMessage(),
                    'Expected NO_RETRY_CMD but got back: ' + caughtException.getMessage()
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitFetchAllergiesVTCExceptionRetry() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCC_AllergyListController.allergyRepo = createAllergyRepo(args, new VTC_LimitException());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            try {
                VCC_AllergyListController.fetchAllergies(args);
                Assert.fail('Expected exception to be thrown.');
            } catch (Exception caughtException) {
                Assert.areEqual(
                    VCC_AllergyListController.RETRY_CMD,
                    caughtException.getMessage(),
                    'Expected RETRY_CMD but got back: ' + caughtException.getMessage()
                );
            }
        }
        Test.stopTest();
    }

    private static VCR_AllergyRepo createAllergyRepo(Map<String, Object> args, Object returnValue) {
        return (VCR_AllergyRepo) new VATEST_StubBuilder(VCR_AllergyRepo.class)
            .mockingMethodCall('fetchAllergies')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .returning(returnValue)
            .defineStub();
    }

    private static VCR_AllergyRepo createAllergyRepo(Map<String, Object> args, Exception returnException) {
        return (VCR_AllergyRepo) new VATEST_StubBuilder(VCR_AllergyRepo.class)
            .mockingMethodCall('fetchAllergies')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .throwingException(returnException)
            .defineStub();
    }

    private static User createTestUser() {
        return new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
    }
}
