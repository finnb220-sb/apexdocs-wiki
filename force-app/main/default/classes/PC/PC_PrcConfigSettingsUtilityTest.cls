/**
 * @description test class for PC_PrcConfigSettingsUtility
 * @author Booz Allen
 * @since 2024
 * @see PC_PrcConfigSettingsUtility
 */
@IsTest
private class PC_PrcConfigSettingsUtilityTest {
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
     * @description method to positively test getting the default value of a PrC_Config_Settings__mdt value from PC_PrcConfigSettingsUtility
     */
    @IsTest
    private static void unitGetConfigSettingPositive() {
        Test.startTest();

        System.runAs(FLP_User) {
            Boolean defaultSettingValue = PC_PrcConfigSettingsUtility.ndthRoutingEnabled;
            Assert.areEqual(
                PrC_Config_Settings__mdt.getInstance('Routing_Config').ndth_Routing_Enabled__c,
                defaultSettingValue,
                'Expected default value of ndthRoutingEnabled to be equal to the PrC_Config_Settings__mdt "Routing_Config" record\'s ndth_Routing_Enabled__c value.'
            );
        }

        Test.stopTest();
    }

    /**
     * @description method to positively test setting a new value for PC_PrcConfigSettingsUtility's ndthRoutingEnabled property that overrides the default from PrC_Config_Settings__mdt
     */
    @IsTest
    private static void unitSetConfigSettingPositive() {
        Test.startTest();

        System.runAs(FLP_User) {
            Boolean defaultSettingValue = PC_PrcConfigSettingsUtility.visnRoutingEnabled;
            PC_PrcConfigSettingsUtility.visnRoutingEnabled = !defaultSettingValue;
            Boolean updatedSettingValue = PC_PrcConfigSettingsUtility.visnRoutingEnabled;
            Assert.areNotEqual(
                PrC_Config_Settings__mdt.getInstance('Routing_Config').VISN_Routing_Enabled__c,
                updatedSettingValue,
                'Expected the updated value of visnRoutingEnabled to be different from the default value pulled from the PrC_Config_Settings__mdt "Routing_Config" record\'s VISN_Routing_Enabled__c value'
            );
        }

        Test.stopTest();
    }

    /**
     * @description method to positively test the getNdthRoutingSetting method
     */
    @IsTest
    private static void unitGetNdthRoutingSettingPositive() {
        Test.startTest();

        List<PC_PrcConfigSettingsUtility.FlowOutput> results;
        System.runAs(FLP_User) {
            results = PC_PrcConfigSettingsUtility.getNdthRoutingSetting();
        }

        Test.stopTest();

        Assert.isTrue(results.size() > 0, 'Expected getNdthRoutingSetting to return a FlowOutput list.');
        Assert.areEqual(
            PrC_Config_Settings__mdt.getInstance('Routing_Config').ndth_Routing_Enabled__c,
            results[0].ndthRoutingEnabledValue,
            'Expected getNdthRoutingSetting to return a FlowOuput with the ndthRoutingEnabledValue property equal to the PrC_Config_Settings__mdt "Routing_Config" record\'s ndth_Routing_Enabled__c field value.'
        );
    }
}
