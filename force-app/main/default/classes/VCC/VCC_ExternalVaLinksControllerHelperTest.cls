/**
 * @description Test class for VCC_ExternalVaLinksControllerHelper
 * @author Booz Allen Hamilton
 * @since 05/2024
 * @see VCC_ExternalVaLinksControllerHelper
 *
 */
@IsTest
private class VCC_ExternalVaLinksControllerHelperTest {
    /**
     * @description Test for createUserUIEventRecord method
     */
    @isTest
    public static void unitcreateUserUIEventRecord() {
        //Building Test User
        VATEST_UserBuilder testUserBuilder = new VATEST_UserBuilder();
        User testUser = testUserBuilder.withUserProfile('VAVET Base Profile')
            .withStandardData()
            .setFields(User.Division, 'VISN 1')
            .withPermissionSet('TED_Medical_Provider_Group')
            .build(true);

        User_UI_Event__c result = new User_UI_Event__c();
        VCC_ExternalVaLinksControllerHelper linksHelper = new VCC_ExternalVaLinksControllerHelper();
        Test.startTest();
        System.runAs(testUser) {
            result = linksHelper.createUserUIEventRecord();
        }
        Test.stopTest();

        Assert.isNotNull(result, 'Expected record to be created');
    }
}
