/**
 * @description Test class for VCC_ClearTriageWrapperController.
 * @author Booz Allen
 * @see VCC_ClearTriageWrapperController
 */

@isTest
private class VCC_ClearTriageWrapperControllerTest {
    private static final String DATA_SOURCE = 'CT_Access_Security_VISN_0';
    private static final String VISN = 'VISN 0';

    @IsTest
    private static void unitCTAccessSecurityPositive() {
        String jsonData = '{"Endpoint" : "test.com", "Repository" : "testRepoKey"}';
        VCC_ClearTriageWrapperController.externalDataSourceRepo = createExternalDataSourceRepo(
            (ExternalDataSource) JSON.deserialize(jsonData, ExternalDataSource.class)
        );
        VCC_ClearTriageWrapperController.CTAccessSecurity ctas;
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            ctas = VCC_ClearTriageWrapperController.getCTAccessSecurity(VISN);
        }
        Test.stopTest();

        Assert.areEqual(ctas.ctAccessUrl, 'test.com', 'Expected ctAccessUrl to be set to mocked value.');
        Assert.areEqual(ctas.ctAccessKey, 'testRepoKey', 'Expected ctAccessKey to be set to mocked value.');
    }

    @IsTest
    private static void unitGetCTAccessSecurityException() {
        VCC_ClearTriageWrapperController.externalDataSourceRepo = createExternalDataSourceRepo(
            new VTC_InternalException('Script-thrown exception')
        );
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            try {
                VCC_ClearTriageWrapperController.getCTAccessSecurity(VISN);
                Assert.fail('Expected exception to be thrown.');
            } catch (Exception expectedException) {
                Assert.areEqual(
                    'Script-thrown exception',
                    expectedException.getMessage(),
                    'Exception message should match.'
                );
            }
        }
        Test.stopTest();
    }

    private static VCR_ExternalDataSourceRepo createExternalDataSourceRepo(Exception returnException) {
        return (VCR_ExternalDataSourceRepo) new VATEST_StubBuilder(VCR_ExternalDataSourceRepo.class)
            .mockingMethodCall('fetchExternalDataSourceUsingSystemMode')
            .withParameterTypes(String.class)
            .withParameterValues(DATA_SOURCE)
            .throwingException(returnException)
            .defineStub();
    }

    private static VCR_ExternalDataSourceRepo createExternalDataSourceRepo(ExternalDataSource desiredData) {
        return (VCR_ExternalDataSourceRepo) new VATEST_StubBuilder(VCR_ExternalDataSourceRepo.class)
            .mockingMethodCall('fetchExternalDataSourceUsingSystemMode')
            .withParameterTypes(String.class)
            .withParameterValues(DATA_SOURCE)
            .returning(desiredData)
            .defineStub();
    }

    private static User createTestUser() {
        return new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSet('VAHC_RN_User')
            .withStandardData()
            .build(true);
    }
}
