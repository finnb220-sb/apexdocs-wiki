@IsTest
public with sharing class VCC_DASServiceMetadataTest {
    @IsTest
    static void getConfigurationTest() {
        String recordTypeApiName;
        try {
            List<VCC_Progress_Note_Configuration__mdt> configList = VCC_Progress_Note_Configuration__mdt.getAll()
                .values();
            recordTypeApiName = configList[0].VCC_Record_Type_API_Name__c;
        } catch (Exception e) {
            //NOPMD
            //do nothing
        }
        Test.startTest();
        try {
            VCC_Progress_Note_Configuration__mdt resultingConfig = VCC_DAS.SERVICES.METADATA.getConfiguration(
                recordTypeApiName
            );
            if (recordTypeApiName == null) {
                Assert.isNull(resultingConfig, 'Expected null return value.');
            } else {
                Assert.isNotNull(resultingConfig, 'Expected non-null return value.');
            }
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void getCustomSectionsTest() {
        VCC_Progress_Note_Custom_Section__mdt customSection;
        try {
            customSection = [
                SELECT Id, VCC_Progress_Note_Configuration__c
                FROM VCC_Progress_Note_Custom_Section__mdt
                LIMIT 1
            ][0];
        } catch (Exception e) {
            //NOPMD
            //do nothing
        }

        Test.startTest();
        try {
            List<VCC_Progress_Note_Custom_Section__mdt> customSectionList = VCC_DAS.SERVICES.METADATA.getCustomSections(
                new VCC_Progress_Note_Configuration__mdt(Id = customSection?.VCC_Progress_Note_Configuration__c)
            );
            Assert.isNotNull(customSectionList, 'Expected non-null return value.');
            if (customSectionList.size() > 0) {
                Boolean hasSection = false;
                for (VCC_Progress_Note_Custom_Section__mdt cs : customSectionList) {
                    if (cs.Id == customSection.Id) {
                        hasSection = true;
                    }
                }
                Assert.isTrue(hasSection, 'Expected to find the custom section.');
            }
        } catch (Exception e) {
            if (customSection?.VCC_Progress_Note_Configuration__c != null) {
                Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void getOrgSettingsTest() {
        Test.startTest();
        try {
            VCC_Org_Settings__mdt orgSettings = VCC_DAS.SERVICES.METADATA.getOrgSettings();
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void getSiteSpecificConfigurationTest() {
        Map<String, VCC_Site_Specific_Configuration__mdt> siteConfigMap = VCC_Site_Specific_Configuration__mdt.getAll();

        Test.startTest();
        try {
            if (siteConfigMap != null && !siteConfigMap.isEmpty()) {
                VCC_Site_Specific_Configuration__mdt testSiteConfig = siteConfigMap.values()[0];
                VCC_Site_Specific_Configuration__mdt actualSiteConfig = VCC_DAS.SERVICES.METADATA.getSiteSpecificConfiguration(
                    Integer.valueOf(testSiteConfig.VCC_SiteID__c),
                    testSiteConfig.VCC_VistA_Environment__c
                );
                Assert.isNotNull(actualSiteConfig, 'Expected a value.');
            }
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }
}
