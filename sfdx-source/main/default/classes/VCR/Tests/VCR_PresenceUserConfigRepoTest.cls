/**
 * @description test class for VCR_PresenceUserConfigRepo
 * @author      Booz Allen Hamiltom
 * @see         VCR_PresenceUserConfig
 */
@IsTest
private with sharing class VCR_PresenceUserConfigRepoTest {
    private final static String SPECIALIST_PRESENCE_CONFIG_NAME = 'PC_Specialists';
    private final static User FLP_USER;
    private final static VCR_PresenceUserConfigRepo REPO_BEING_TESTED;
    static {
        //mixed DML error workaround
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            FLP_USER = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .withPermissionSet('PrC_FLP_Users')
                .build(true);

            REPO_BEING_TESTED = new VCR_PresenceUserConfigRepo();
        }
    }

    /**
     * @description test fetchPresenceUserConfigByDeveloperName method positively
     */
    @IsTest
    private static void funcFetchPresenceUserConfigByDeveloperNamePositive() {
        Integer maxCapacitySpecialists = [
                SELECT Capacity
                FROM PresenceUserConfig
                WHERE DeveloperName = :SPECIALIST_PRESENCE_CONFIG_NAME
            ]
            ?.get(0)
            ?.Capacity;

        Test.startTest();

        PresenceUserConfig result;
        System.runAs(FLP_USER) {
            result = REPO_BEING_TESTED.fetchPresenceUserConfigByDeveloperName(SPECIALIST_PRESENCE_CONFIG_NAME);
        }

        Test.stopTest();

        // Asserts
        Assert.isNotNull(result, 'Expected a PresenceUserConfig record to be returned, but the return was null.');
        Assert.areEqual(
            maxCapacitySpecialists,
            result?.Capacity,
            'Expected the returned Presence Configuration Capacity to be equal to the Specialist Presence Configuration max Capacity, but it was not.'
        );
    }
}
