/**
 * @description Test class for VCR_ServicePresenceStatusRepo
 * @author      Booz Allen Hamilton
 * @see         VCR_ServicePresenceStatusRepo
 */
@IsTest
private with sharing class VCR_ServicePresenceStatusRepoTest {
    private final static User SPECIALIST_USER;
    private final static VCR_ServicePresenceStatusRepo REPO_BEING_TESTED;
    static {
        //mixed DML error workaround
        System.runAs(new User(Id = UserInfo.getUserId())) {
            SPECIALIST_USER = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .withPermissionSet('PrC_Specialist_Users')
                .build(true);
        }

        REPO_BEING_TESTED = new VCR_ServicePresenceStatusRepo();
    }

    /**
     * @description positive test for fetchByDeveloperName to ensure a specific Service Presence Statys is returned when provided its Developer Name
     */
    @IsTest
    static void funcFetchByDeveloperNamePositive() {
        // Test data setup
        User runAsUser = SPECIALIST_USER;

        ServicePresenceStatus existingServicePresenceStatus;

        // Actual test
        Test.startTest();

        ServicePresenceStatus result;
        System.runAs(runAsUser) {
            existingServicePresenceStatus = [SELECT DeveloperName FROM ServicePresenceStatus LIMIT 1];

            result = REPO_BEING_TESTED.fetchByDeveloperName(existingServicePresenceStatus?.DeveloperName);
        }

        Test.stopTest();

        // Asserts
        Assert.isNotNull(result, 'Expected to find a ServicePresenceStatus record');
        Assert.areEqual(
            existingServicePresenceStatus?.DeveloperName,
            result?.DeveloperName,
            'Expected to fetch the same ServicePresenceStatus record, but found ' + result
        );
    }
}
