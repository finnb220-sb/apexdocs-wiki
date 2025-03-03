/**
 * @author Booz Allen Hamilton
 * @description Test class for VCC_FlagResponseWrp
 * @see `VCC_FlagResponseWrp`
 */
@IsTest
private with sharing class VCC_FlagResponseWrpTest {
    @IsTest
    static void unitFlagResponseWrpPropertiesPositive() {
        VCC_FlagModal flagModalString = new VCC_FlagModal();
        Boolean isShowFlagPopup = false;
        String womenHealthResponseBody = '';

        Test.startTest();
        System.runAs(new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(false)) {
            VCC_FlagResponseWrp flagResponseWrp = new VCC_FlagResponseWrp();
            flagResponseWrp.flagModal = flagModalString;
            flagResponseWrp.isShowFlagPopup = isShowFlagPopup;
            flagResponseWrp.womenHealthResponseBody = womenHealthResponseBody;
            Assert.areEqual(
                flagModalString,
                flagResponseWrp.flagModal,
                'Expected get/set property access on VCC_FlagResponseWrp.flagModal'
            );
            Assert.areEqual(
                isShowFlagPopup,
                flagResponseWrp.isShowFlagPopup,
                'Expected get/set property access on VCC_FlagResponseWrp.isShowFlagPopup'
            );
            Assert.areEqual(
                womenHealthResponseBody,
                flagResponseWrp.womenHealthResponseBody,
                'Expected get/set property access on VCC_FlagResponseWrp.womenHealthResponseBody'
            );
        }
        Test.stopTest();
    }
}
