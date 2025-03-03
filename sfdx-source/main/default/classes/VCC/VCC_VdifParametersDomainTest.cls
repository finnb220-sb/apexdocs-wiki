@IsTest
public with sharing class VCC_VdifParametersDomainTest {
    private static String username = 'vpd';

    /**
     * @description creating test user to run test as
     */
    @TestSetup
    public static void makeData() {
        User testUser = VCC_TestDataFactory.insertUser('Standard User');
        VCC_TestDataFactory.assignPermissionSetByName(testUser, 'VCC_Integration_Test_Utility_Base');
        testUser.Username = username + testUser.Username;
        update testUser;
    }

    /**
     * @description retrieves the test user from setup
     * @return  `User`
     */
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE Username LIKE :username + '%' LIMIT 1];
    }

    @IsTest
    static void populateVdifNoteNoAdditionalSigner() {
        VCC_Test_Configuration_Data__c testConfigurationData = new VCC_Test_Configuration_Data__c();
        VCC_VdifNote vdifNote = new VCC_VdifNote();
        testConfigurationData.VCC_Note_Title_IEN__c = '111111111';
        testConfigurationData.VCC_Note_Text__c = 'Note text.';

        Test.startTest();
        System.runAs(getTestUser()) {
            (new VCC_VdifParametersDomain()).populateVdifNote(vdifNote, testConfigurationData);
            System.assert(vdifNote.additionalSigners.size() == 0, 'Expected zero additional signers.');
            System.assert(vdifNote.noteTitleIen == testConfigurationData.VCC_Note_Title_IEN__c, 'Expected values to match');
            System.assert(vdifNote.text == testConfigurationData.VCC_Note_Text__c, 'Expected values to match');
        }
        Test.stopTest();
    }

    @IsTest
    static void populateVdifNoteWithAdditionalSigner() {
        VCC_Test_Configuration_Data__c testConfigurationData = new VCC_Test_Configuration_Data__c();
        VCC_VdifNote vdifNote = new VCC_VdifNote();
        testConfigurationData.VCC_Note_Title_IEN__c = '111111111';
        testConfigurationData.VCC_Note_Text__c = 'Note text.';
        testConfigurationData.VCC_Additional_Signer_IEN__c = '987654321';

        Test.startTest();
        System.runAs(getTestUser()) {
            (new VCC_VdifParametersDomain()).populateVdifNote(vdifNote, testConfigurationData);
            System.assert((vdifNote.additionalSigners != null) && (vdifNote.additionalSigners.size() == 1), 'Expected one additional signer.');
            System.assert(vdifNote.noteTitleIen == testConfigurationData.VCC_Note_Title_IEN__c, 'Expected values to match');
            System.assert(vdifNote.text == testConfigurationData.VCC_Note_Text__c, 'Expected values to match');
        }
        Test.stopTest();
    }

    @IsTest
    static void populateVdifPatientIcn() {
        VCC_Stub patientServiceStub = VCC_PatientServiceV2.stub();
        String testPid = '123456';
        patientServiceStub.setReturnValue('getLocalPidForSite', testPid);

        VCC_VdifPatient vdifPatient = new VCC_VdifPatient();
        VCC_Test_Configuration_Data__c testConfigurationData = new VCC_Test_Configuration_Data__c();
        testConfigurationData.VCC_Site_Code__c = '984';
        testConfigurationData.VCC_ICN__c = '3333333';

        Test.startTest();

        System.runAs(getTestUser()) {
            (new VCC_VdifParametersDomain()).populateVdifPatient(vdifPatient, testConfigurationData);
            patientServiceStub.assertInvoked('getLocalPidForSite');
            System.assert(vdifPatient.siteCode == testConfigurationData.VCC_Site_Code__c, 'Expected site code.');
            System.assert(vdifPatient.pid == testPid, 'Expected pid.');
            System.assert(vdifPatient.name == testConfigurationData.VCC_Site_Code__c + ' Patient', 'Expected name.');
        }

        Test.stopTest();
    }

    @IsTest
    static void populateVdifPatientAccountId() {
        VCC_Stub patientServiceStub = VCC_PatientServiceV2.stub();
        String testPid = '123456';
        patientServiceStub.setReturnValue('getLocalPidForSite', testPid);

        VCC_VdifPatient vdifPatient = new VCC_VdifPatient();
        VCC_Test_Configuration_Data__c testConfigurationData = new VCC_Test_Configuration_Data__c();
        testConfigurationData.VCC_Site_Code__c = '984';
        testConfigurationData.VCC_Account_Id__c = '3333333';

        Test.startTest();

        System.runAs(getTestUser()) {
            new VCC_VdifParametersDomain().populateVdifPatient(vdifPatient, testConfigurationData);
            patientServiceStub.assertInvoked('getLocalPidForSite');
            System.assert(vdifPatient.siteCode == testConfigurationData.VCC_Site_Code__c, 'Expected site code.');
            System.assert(vdifPatient.pid == testPid, 'Expected pid.');
            System.assert(vdifPatient.name == testConfigurationData.VCC_Site_Code__c + ' Patient', 'Expected name.');
        }

        Test.stopTest();
    }

    @IsTest
    static void populateVidfParametersTest() {
        VCC_Stub patientServiceStub = VCC_PatientServiceV2.stub();
        String testPid = '123456';
        patientServiceStub.setReturnValue('getLocalPidForSite', testPid);

        VCC_VdifParameters vdifParameters = new VCC_VdifParameters();
        VCC_Test_Configuration_Data__c testConfigurationData = new VCC_Test_Configuration_Data__c();
        testConfigurationData.VCC_Site_Code__c = '984';
        testConfigurationData.VCC_Account_Id__c = '3333333';
        testConfigurationData.VCC_Note_Title_IEN__c = '111111111';
        testConfigurationData.VCC_Note_Text__c = 'Note text.';
        testConfigurationData.VCC_Additional_Signer_IEN__c = '987654321';

        Test.startTest();
        System.runAs(getTestUser()) {
            (new VCC_VdifParametersDomain()).addDataFromTestConfig(vdifParameters, testConfigurationData);
            patientServiceStub.assertInvoked('getLocalPidForSite');
            System.assert(vdifParameters.vdifPatient.siteCode == testConfigurationData.VCC_Site_Code__c, 'Expected site code.');
            System.assert(vdifParameters.vdifPatient.pid == testPid, 'Expected pid.');
            System.assert(vdifParameters.vdifPatient.name == testConfigurationData.VCC_Site_Code__c + ' Patient', 'Expected name.');
            System.assert((vdifParameters.vdifNote.additionalSigners != null) && (vdifParameters.vdifNote.additionalSigners.size() == 1), 'Expected one additional signer.');
            System.assert(vdifParameters.vdifNote.noteTitleIen == testConfigurationData.VCC_Note_Title_IEN__c, 'Expected values to match');
            System.assert(vdifParameters.vdifNote.text == testConfigurationData.VCC_Note_Text__c, 'Expected values to match');
        }
        Test.stopTest();
    }

    @IsTest
    static void fillParametersWithDummyDataTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_VdifParameters vdifParameters = new VCC_VdifParameters();
            (new VCC_VdifParametersDomain()).fillParametersWithDummyData(vdifParameters);

            System.assert(vdifParameters.vdifNote.additionalSigners == new List<String>{ 'test' }, 'Expected value to be "test".');
            System.assert(vdifParameters.vdifNote.itemId == 'test', 'Expected value to be "test".');
            System.assert(vdifParameters.vdifNote.encounterString == 'test', 'Expected value to be "test".');
            System.assert(vdifParameters.vdifNote.noteTitleIen == 'test', 'Expected value to be "test".');
            System.assert(vdifParameters.vdifNote.text == 'test', 'Expected value to be "test".');
            System.assert(vdifParameters.vdifNote.consultIen == 'test', 'Expected value to be "test".');
            System.assert(vdifParameters.vdifNote.prfIen == 'test', 'Expected value to be "test".');
            System.assert(vdifParameters.vdifEncounter.noteTitleIen == 'test', 'Expected value to be "test".');
            System.assert(vdifParameters.vdifEncounter.locationIen == 'test', 'Expected value to be "test".');
            System.assert(vdifParameters.vdifEncounter.consultIen == 'test', 'Expected value to be "test".');
            System.assert(vdifParameters.vdifEncounter.serviceCategory == 'test', 'Expected value to be "test".');
            System.assert(vdifParameters.vdifEncounter.providers == 'test', 'Expected value to be "test".');
            System.assert(vdifParameters.vdifEncounter.procedures == 'test', 'Expected value to be "test".');
            System.assert(vdifParameters.vdifEncounter.diagnoses == 'test', 'Expected value to be "test".');
            System.assert(vdifParameters.vdifEncounter.immunizations == 'test', 'Expected value to be "test".');
            System.assert(vdifParameters.vdifEncounter.healthFactors == 'test', 'Expected value to be "test".');
            System.assert(vdifParameters.vdifEncounter.visitRelatedTos == 'test', 'Expected value to be "test".');
            System.assert(vdifParameters.vdifEncounter.comments == 'test', 'Expected value to be "test".');
            System.assert(vdifParameters.vdifPatient.pid == 'test', 'Expected value to be "test".');
            System.assert(vdifParameters.vdifPatient.siteCode == 'test', 'Expected value to be "test".');
            System.assert(vdifParameters.vdifPatient.name == 'test', 'Expected value to be "test".');
            System.assert(vdifParameters.vdifProvider.duz == 'test', 'Expected value to be "test".');
            System.assert(vdifParameters.vdifProvider.cosignerDuz == 'test', 'Expected value to be "test".');
            System.assert(vdifParameters.vdifProvider.token == 'test', 'Expected value to be "test".');
            System.assert(vdifParameters.vdifProvider.esig == 'test', 'Expected value to be "test".');
            System.assert(vdifParameters.vdifProvider.siteCode == 'test', 'Expected value to be "test".');
            System.assert(vdifParameters.vdifProvider.name == 'test', 'Expected value to be "test".');
        }
        Test.stopTest();
    }

    @IsTest
    static void populateProviderInfoTestNoDuz() {
        VCC_Stub providerServiceStub = VCC_ProviderServiceV2.stub();
        providerServiceStub.setReturnValue('getProviderDuz', '123456');
        VCC_VdifParameters vdifParameters = new VCC_VdifParameters();

        Test.startTest();
        System.runAs(getTestUser()) {
            (new VCC_VdifParametersDomain()).populateProviderInfo(vdifParameters, 'esig', 'siteCode', null, 'token');
            System.assert(vdifParameters.vdifProvider.name == UserInfo.getLastName() + ', ' + UserInfo.getFirstName(), 'Expected correct provider name.');
            System.assert(vdifParameters.vdifProvider.duz == '123456', 'Expected value returned from stub.');
            System.assert(vdifParameters.vdifProvider.esig == 'esig', 'Expected values to match.');
            System.assert(vdifParameters.vdifProvider.siteCode == 'siteCode', 'Expected values to match.');
            System.assert(vdifParameters.vdifProvider.token == 'token', 'Expected values to match.');
            providerServiceStub.assertInvoked('getProviderDuz');
        }
        Test.stopTest();
    }

    @IsTest
    static void populateProviderInfoTest() {
        VCC_Stub providerServiceStub = VCC_ProviderServiceV2.stub();
        VCC_VdifParameters vdifParameters = new VCC_VdifParameters();

        Test.startTest();
        System.runAs(getTestUser()) {
            (new VCC_VdifParametersDomain()).populateProviderInfo(vdifParameters, 'esig', 'siteCode', 'duz', 'token');
            System.assert(vdifParameters.vdifProvider.name == UserInfo.getLastName() + ', ' + UserInfo.getFirstName(), 'Expected correct provider name.');
            System.assert(vdifParameters.vdifProvider.duz == 'duz', 'Expected value returned from stub.');
            System.assert(vdifParameters.vdifProvider.esig == 'esig', 'Expected values to match.');
            System.assert(vdifParameters.vdifProvider.siteCode == 'siteCode', 'Expected values to match.');
            System.assert(vdifParameters.vdifProvider.token == 'token', 'Expected values to match.');
            providerServiceStub.assertNotInvoked('getProviderDuz');
        }
        Test.stopTest();
    }
}
