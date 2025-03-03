@IsTest
public with sharing class VCC_TestRunDomainTest {
    private static String username = 'trd';

    @TestSetup
    public static void makeData() {
        User testUser = VCC_TestDataFactory.insertUser('Standard User');
        VCC_TestDataFactory.assignPermissionSetByName(testUser, 'VCC_Integration_Test_Utility_Base');
        testUser.Username = username + testUser.Username;
        update testUser;
    }

    public static User getTestUser() {
        return [SELECT Id FROM User WHERE Username LIKE :username + '%' LIMIT 1];
    }

    @IsTest
    static void initializeVdifTestRunTestEncounter() {
        VCC_Test_Run__c testRun = new VCC_Test_Run__c();
        VCC_Test_Configuration_Data__c testConfigurationData = new VCC_Test_Configuration_Data__c(
            VCC_Site_Code__c = '983',
            VCC_Note_Title_IEN__c = null,
            VCC_Note_Title_IEN_For_Encounter__c = '1234567'
        );

        Test.startTest();
        System.runAs(getTestUser()) {
            (new VCC_TestRunDomain()).initializeVdifTestRun(testRun, testConfigurationData);
            System.assert(testRun.VCC_Site_Code__c == testConfigurationData.VCC_Site_Code__c, 'Expected matching site codes');
            System.assert(testRun.VCC_Category__c == 'Vdif', 'Expected category to be "Vdif"');
            System.assert(
                testRun.RecordTypeId == VCC_Test_Run__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Vdif_Test_Run').getRecordTypeId(),
                'Expected correct record type.'
            );
            System.assert(testRun.VCC_Sub_Category__c == 'Create encounter, note, and sign', 'Expected sub category to be "Create encounter, note, and sign"');
        }
        Test.stopTest();
    }

    @IsTest
    static void initializeVdifTestRunTestEncounterNeither() {
        VCC_Test_Run__c testRun = new VCC_Test_Run__c();
        VCC_Test_Configuration_Data__c testConfigurationData = new VCC_Test_Configuration_Data__c(VCC_Site_Code__c = '983');

        Test.startTest();
        System.runAs(getTestUser()) {
            (new VCC_TestRunDomain()).initializeVdifTestRun(testRun, testConfigurationData);
            System.assert(testRun.VCC_Site_Code__c == testConfigurationData.VCC_Site_Code__c, 'Expected matching site codes');
            System.assert(testRun.VCC_Category__c == 'Vdif', 'Expected category to be "Vdif"');
            System.assert(
                testRun.RecordTypeId == VCC_Test_Run__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Vdif_Test_Run').getRecordTypeId(),
                'Expected correct record type.'
            );
            System.assert(testRun.VCC_Sub_Category__c == null, 'Expected sub category to be null');
        }
        Test.stopTest();
    }

    @IsTest
    static void initializeVdifTestRunTestNote() {
        VCC_Test_Run__c testRun = new VCC_Test_Run__c();
        VCC_Test_Configuration_Data__c testConfigurationData = new VCC_Test_Configuration_Data__c(
            VCC_Site_Code__c = '983',
            VCC_Note_Title_IEN__c = '12345',
            VCC_Note_Title_IEN_For_Encounter__c = null
        );

        Test.startTest();
        System.runAs(getTestUser()) {
            (new VCC_TestRunDomain()).initializeVdifTestRun(testRun, testConfigurationData);
            System.assert(testRun.VCC_Site_Code__c == testConfigurationData.VCC_Site_Code__c, 'Expected matching site codes');
            System.assert(testRun.VCC_Category__c == 'Vdif', 'Expected category to be "Vdif"');
            System.assert(
                testRun.RecordTypeId == VCC_Test_Run__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Vdif_Test_Run').getRecordTypeId(),
                'Expected correct record type.'
            );
            System.assert(testRun.VCC_Sub_Category__c == 'Create note, addendum, and sign', 'Expected sub category to be "Create note, addendum, and sign"');
        }
        Test.stopTest();
    }

    @IsTest
    static void initializeTestRunTest() {
        VCC_Test_Run__c testRun = new VCC_Test_Run__c();
        VCC_Test_Configuration_Data__c testConfigurationData = new VCC_Test_Configuration_Data__c(
            RecordTypeId = VCC_Test_Configuration_Data__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Vdif_Test_Patient').getRecordTypeId(),
            VCC_Site_Code__c = '983',
            VCC_Note_Title_IEN__c = null,
            VCC_Note_Title_IEN_For_Encounter__c = '1234567',
            VCC_ICN__c = 'test'
        );
        insert testConfigurationData;

        Test.startTest();
        System.runAs(getTestUser()) {
            (new VCC_TestRunDomain()).initializeTestRun(testRun, testConfigurationData);
            System.assert(testRun.VCC_Test_Configuration_Data__c == testConfigurationData.Id, 'Expected id on test run record to match id of test config data.');
            System.assert(testRun.VCC_Site_Code__c == testConfigurationData.VCC_Site_Code__c, 'Expected matching site codes');
            System.assert(testRun.VCC_Category__c == 'Vdif', 'Expected category to be "Vdif"');
            System.assert(testRun.VCC_Sub_Category__c == 'Create encounter, note, and sign', 'Expected sub category to be "Create encounter, note, and sign"');
            System.assert(
                testRun.RecordTypeId == VCC_Test_Run__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Vdif_Test_Run').getRecordTypeId(),
                'Expected correct record type.'
            );
        }
        Test.stopTest();
    }
}
