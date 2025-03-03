/**
 * @description Test class for VCR_ServiceChannelRepo.
 * @author      Booz Allen
 * @since       2024
 * @see         VCR_ServiceChannelRepo
 */
@IsTest
private class VCR_ServiceChannelRepoTest {
    private final static User FLP_USER;
    static {
        //mixed DML error workaround
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            FLP_USER = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .withPermissionSet('PrC_FLP_Users')
                .build(true);
        }
    }

    @IsTest
    static void unitTestConstructorPositive() {
        Test.startTest();
        VCR_ServiceChannelRepo repo;
        System.runAs(FLP_USER) {
            repo = new VCR_ServiceChannelRepo();
        }
        Test.stopTest();

        Assert.isNotNull(repo, 'Expected constructor to properly instantiate a VCR_ServiceChannelRepo class object');
        Assert.isTrue(
            String.valueOf(repo).containsIgnoreCase('VTC_BaseRepo.sObjectType=ServiceChannel'),
            'Expected the SObject type to be Service Channel'
        );
    }

    /**
     * @description positive test for fetchByDeveloperName to ensure the PC_Chat_Service Service Channel is returned when provided its Developer Name
     */
    @IsTest
    static void funcTestFetchByDeveloperNamePositive() {
        // Test data setup
        VCR_ServiceChannelRepo repo = new VCR_ServiceChannelRepo();

        //create FLP user to test retrieving Provider Connect's Service Channel
        User runAsUser = FLP_USER;

        // Actual test
        Test.startTest();

        List<ServiceChannel> results;
        System.runAs(runAsUser) {
            results = repo.fetchByDeveloperName('PC_Chat_Service');
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(results.size() > 0, 'Expected to find a Service Channel record');
        Assert.areEqual(
            'PC_Chat_Service',
            results[0].DeveloperName,
            'Expected to find the PC_Chat_Service Service Channel record'
        );
    }
}
