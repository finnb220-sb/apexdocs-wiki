/**
 * @description Workstream Settings Selector Test
 */

@SuppressWarnings('PMD.ApexDoc')
@IsTest
private with sharing class VCC_WorkstreamSettingsSelectorTest {
    @IsTest
    private static void workstreamMSA() {
        Test.startTest();
        VCC_WorkstreamSettingsSelector workstreamSettingsSelector = new VCC_WorkstreamSettingsSelector(VCC_Enum.VCC_WorkstreamSettingsTypeEnum.MSA);
        Test.stopTest();

        System.assertEquals('MSA', workstreamSettingsSelector.settings.DeveloperName, 'DeveloperName should be MSA.');
    }

    @IsTest
    private static void workstreamRN() {
        Test.startTest();
        VCC_WorkstreamSettingsSelector workstreamSettingsSelector = new VCC_WorkstreamSettingsSelector(VCC_Enum.VCC_WorkstreamSettingsTypeEnum.RN);
        Test.stopTest();

        System.assertEquals('RN', workstreamSettingsSelector.settings.DeveloperName, 'DeveloperName should be RN.');
    }

    @IsTest
    private static void workstreamPharmacy() {
        Test.startTest();
        VCC_WorkstreamSettingsSelector workstreamSettingsSelector = new VCC_WorkstreamSettingsSelector(VCC_Enum.VCC_WorkstreamSettingsTypeEnum.Pharmacy);
        Test.stopTest();

        System.assertEquals('Pharmacy', workstreamSettingsSelector.settings.DeveloperName, 'DeveloperName should be Pharmacy.');
    }

    @IsTest
    private static void workstreamVCV() {
        Test.startTest();
        VCC_WorkstreamSettingsSelector workstreamSettingsSelector = new VCC_WorkstreamSettingsSelector(VCC_Enum.VCC_WorkstreamSettingsTypeEnum.VCV);
        Test.stopTest();

        System.assertEquals('VCV', workstreamSettingsSelector.settings.DeveloperName, 'DeveloperName should be VCV.');
    }

    @IsTest
    private static void workstreamNullCheck() {
        Test.startTest();
        VCC_WorkstreamSettingsSelector selector = new VCC_WorkstreamSettingsSelector(null);
        Test.stopTest();

        System.assertEquals('Default', selector.settings.DeveloperName, 'DeveloperName should be Default.');
    }
}
