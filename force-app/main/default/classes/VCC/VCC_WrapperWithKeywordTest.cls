@isTest
private class VCC_WrapperWithKeywordTest {
    @isTest
    static void unitGetKeywordTranslationMapTest() {
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');

        Test.startTest();
        System.runAs(runAsUser) {
            VCC_WrapperWithKeyword wrapperInstance = new VCC_WrapperWithKeyword();
            Assert.areEqual(new Map<String, String>(), wrapperInstance.getKeywordTranslationMap(), 'The method returned an unexpected data type.');
        }
        Test.stopTest();
    }
}
