/**
 * @description Test class for VCR_ExternalDataSourceRepo.
 * @author Booz Allen
 * @see VCR_ExternalDataSourceRepo
 **/

@IsTest
public class VCR_ExternalDataSourceRepoTest {
    @IsTest
    static void unitRepoConstructorPositive() {
        User vaVetUser = createTestUser();
        VCR_ExternalDataSourceRepo repo;

        Test.startTest();
        System.runAs(vaVetUser) {
            repo = new VCR_ExternalDataSourceRepo();
        }
        Test.stopTest();

        Assert.areEqual(
            ExternalDataSource.sObjectType,
            repo.SObjectType,
            'Expected arg-less constructor for VCR_ExternamDataSourceRepo to set the internal SObjectType to ExternalDataSource'
        );
    }

    @IsTest
    static void funcFetchExternalDataSourceWithRepoNegative() {
        //Cannot insert ExternalDataSource object.
        //Test that query returns exception when no records are present.
        User vaVetUser = createTestUser();
        Boolean catchException = false;
        Test.startTest();

        System.runAs(vaVetUser) {
            try {
                VCR_ExternalDataSourceRepo repo = new VCR_ExternalDataSourceRepo();
                repo.fetchExternalDataSourceUsingSystemMode('Test_Data_Source');
                Assert.fail('Expected System List Exception to be thrown');
            } catch (System.ListException expectedException) {
                catchException = true;
            }
        }
        Test.stopTest();

        Assert.isTrue(catchException, 'Expected to catch System List Exception when no records are present');
    }

    private static User createTestUser() {
        return new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSet('VAHC_RN_User')
            .withStandardData()
            .build(true);
    }
}
