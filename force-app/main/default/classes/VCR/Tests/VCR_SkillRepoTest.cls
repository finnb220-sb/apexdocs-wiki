/**
 * @description test class for VCR_SkillRepo.
 * @author      Booz Allen
 * @since       2024
 * @see         VCR_SkillRepo
 */
@IsTest
private class VCR_SkillRepoTest {
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

    /**
     * @description positive test of getSkillByLabel to ensure that the correct skill record is returned when provided its label
     */
    @IsTest
    private static void funcGetSkillByLabelTestPositive() {
        // Test data setup
        Skill testSkill = [SELECT Id, MasterLabel FROM Skill LIMIT 1]; //must use pre-existing skills as they cannot be created in test methods

        VCR_SkillRepo repo = new VCR_SkillRepo();

        // Actual test
        Test.startTest();

        Skill result;
        System.runAs(FLP_USER) {
            result = repo.getSkillByLabel(testSkill.MasterLabel);
        }

        Test.stopTest();

        // Asserts
        Assert.areEqual(
            testSkill.Id,
            result.Id,
            'Expected getSkillByLabel to return the same skill record as the one queried in the setup.'
        );
    }
}
