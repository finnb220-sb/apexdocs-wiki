@isTest
public with sharing class VCC_RefreshUI_InvocableTest {
    @IsTest
    private static void refreshUITest() {
        Test.startTest();
        // below tests for coverage
        VCC_RefreshUI_Invocable.refreshUI();

        // below tests functionality
        Database.SaveResult sr = EventBus.publish(new VCC_Update_UI__e());

        System.assertEquals(true, sr.isSuccess());
        Test.stopTest();
    }
}
