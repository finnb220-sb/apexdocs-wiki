@IsTest
/**
 * @description
 * @author
 * @since
 * @group Test Classes
 * @see VCC_MainMenuController
 */
private class VCC_MainMenuControllerTest {
    @IsTest
    private static void testVCC_MainMenuController() {
        Test.startTest();
        VCC_MainMenuWrp mainMenuWrp = VCC_MainMenuController.initData();
        System.assertEquals(true, mainMenuWrp.status);
        Test.stopTest();
    }
}
