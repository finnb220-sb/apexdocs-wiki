public with sharing class VCC_TestRunDomain {
    public void initializeTestRun(VCC_Test_Run__c testRun, VCC_Test_Configuration_Data__C testConfigurationData) {
        if (String.isBlank((String) testConfigurationData.RecordTypeId)) {
            return;
        }

        testRun.VCC_Test_Configuration_Data__c = testConfigurationData.Id;

        switch on VCC_Test_Configuration_Data__c.getSObjectType().getDescribe().getRecordTypeInfosById().get(testConfigurationData.RecordTypeId).getDeveloperName() {
            when 'VCC_Vdif_Test_Patient' {
                this.initializeVdifTestRun(testRun, testConfigurationData);
            }
        }
    }

    @TestVisible
    private void initializeVdifTestRun(VCC_Test_Run__c testRun, VCC_Test_Configuration_Data__C testConfigurationData) {
        testRun.VCC_Category__c = 'Vdif';
        testRun.VCC_Site_Code__c = testConfigurationData.VCC_Site_Code__c;
        testRun.RecordTypeId = VCC_Test_Run__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Vdif_Test_Run').getRecordTypeId();

        if (!String.isBlank(testConfigurationData.VCC_Note_Title_IEN__c) && !String.isBlank(testConfigurationData.VCC_Note_Title_IEN_For_Encounter__c)) {
            return;
        }

        if (!String.isBlank(testConfigurationData.VCC_Note_Title_IEN__c)) {
            testRun.VCC_Sub_Category__c = 'Create note, addendum, and sign';
        }

        if (!String.isBlank(testConfigurationData.VCC_Note_Title_IEN_For_Encounter__c)) {
            testRun.VCC_Sub_Category__c = 'Create encounter, note, and sign';
        }
    }
}
