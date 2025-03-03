/**
 * @description Tests the VCC_LookupControllerTest class
 * @author Booz Allen Hamilton
 *
 * @see VCC_LookupController for class being tested
 */
@IsTest
private with sharing class VCC_LookupControllerTest {
    private static final String SITE_ID = '983';
    private static final String PERSONA = 'VCC_Virtual_Visit_Progress_Note';
    private static final List<HealthcareFacility> HEALTHCARE_FACILITIES = new List<HealthcareFacility>{
        new HealthcareFacility(Name = 'Facility 1', VCC_Personas__c = 'MD', VCC_Site_Id__c = Integer.valueOf(SITE_ID)),
        new HealthcareFacility(Name = 'Facility 2', VCC_Personas__c = 'MD', VCC_Site_Id__c = Integer.valueOf(SITE_ID))
    };

    @IsTest
    private static void findRecordTestNoStub() {
        System.runAs(createTestUser()) {
            List<SObject> sObjectList;
            Test.startTest();
            sObjectList = VCC_LookupController.findRecords('', '', '');
            Test.stopTest();
            Assert.isNotNull(sObjectList, 'Expected an empty list.');
            Assert.areEqual(0, sObjectList.size(), 'Expected an empty list.');
        }
    }

    @IsTest
    private static void findRecordTestHappyStubbed() {
        System.runAs(createTestUser()) {
            VCC_Stub configSelectorStub = new VCC_Stub(VCC_ProgressNoteConfigSelector.class);
            configSelectorStub.setReturnValue(
                'selectByRecordTypeAPIName',
                new VCC_Progress_Note_Configuration__mdt(VCC_Record_Type_API_Name__c = PERSONA, VCC_Personas__c = 'MD')
            );

            VCC_Stub hcFacilitySelectorStub = new VCC_Stub(VCC_HealthcareFacilitySelector.class);
            hcFacilitySelectorStub.setReturnValue('selectBySiteIdAndPersona', HEALTHCARE_FACILITIES);

            List<SObject> sObjectList;
            Test.startTest();
            VCC_LookupController.healthcareFacilitySelector = (VCC_HealthcareFacilitySelector) hcFacilitySelectorStub.instance;
            VCC_LookupController.progressNoteConfigurationSelector = (VCC_ProgressNoteConfigSelector) configSelectorStub.instance;
            sObjectList = VCC_LookupController.findRecords(SITE_ID, 'Day', PERSONA);
            Test.stopTest();

            configSelectorStub.assertInvoked('selectByRecordTypeAPIName');
            hcFacilitySelectorStub.assertInvoked('selectBySiteIdAndPersona');
            Assert.areEqual(2, sObjectList.size(), 'Expected two SObjects.');
        }
    }

    @IsTest
    private static void findRecordTestNoConfigStubbed() {
        VCC_Stub configSelectorStub = new VCC_Stub(VCC_ProgressNoteConfigSelector.class);
        configSelectorStub.setReturnValue('selectByRecordTypeAPIName', null);

        VCC_Stub hcFacilitySelectorStub = new VCC_Stub(VCC_HealthcareFacilitySelector.class);
        hcFacilitySelectorStub.setReturnValue('selectBySiteIdAndPersona', HEALTHCARE_FACILITIES);

        List<SObject> sObjectList;
        System.runAs(createTestUser()) {
            Test.startTest();
            VCC_LookupController.healthcareFacilitySelector = (VCC_HealthcareFacilitySelector) hcFacilitySelectorStub.instance;
            VCC_LookupController.progressNoteConfigurationSelector = (VCC_ProgressNoteConfigSelector) configSelectorStub.instance;
            sObjectList = VCC_LookupController.findRecords(SITE_ID, 'Day', PERSONA);
            Test.stopTest();
        }

        configSelectorStub.assertInvoked('selectByRecordTypeAPIName');
        hcFacilitySelectorStub.assertNotInvoked('selectBySiteIdAndPersona');
        Assert.areEqual(0, sObjectList.size(), 'Expected zero SObjects.');
    }

    @IsTest
    private static void findRecordTestNoHealthcareFacilityStubbed() {
        VCC_Stub configSelectorStub = new VCC_Stub(VCC_ProgressNoteConfigSelector.class);
        configSelectorStub.setReturnValue(
            'selectByRecordTypeAPIName',
            new VCC_Progress_Note_Configuration__mdt(VCC_Record_Type_API_Name__c = PERSONA, VCC_Personas__c = 'MD')
        );

        VCC_Stub hcFacilitySelectorStub = new VCC_Stub(VCC_HealthcareFacilitySelector.class);
        hcFacilitySelectorStub.setReturnValue('selectBySiteIdAndPersona', new List<HealthcareFacility>());

        List<SObject> sObjectList;
        System.runAs(createTestUser()) {
            Test.startTest();
            VCC_LookupController.healthcareFacilitySelector = (VCC_HealthcareFacilitySelector) hcFacilitySelectorStub.instance;
            VCC_LookupController.progressNoteConfigurationSelector = (VCC_ProgressNoteConfigSelector) configSelectorStub.instance;
            sObjectList = VCC_LookupController.findRecords(SITE_ID, 'Day', PERSONA);
            Test.stopTest();
        }

        configSelectorStub.assertInvoked('selectByRecordTypeAPIName');
        hcFacilitySelectorStub.assertInvoked('selectBySiteIdAndPersona');
        Assert.areEqual(0, sObjectList.size(), 'Expected zero SObjects.');
    }

    @IsTest
    private static void findRecordIntegrationTest() {
        VCC_Stub configSelectorStub = new VCC_Stub(VCC_ProgressNoteConfigSelector.class);
        configSelectorStub.setReturnValue(
            'selectByRecordTypeAPIName',
            new VCC_Progress_Note_Configuration__mdt(VCC_Record_Type_API_Name__c = PERSONA, VCC_Personas__c = 'MD,RN')
        );

        Account account = new Account(Name = 'Fake Account');
        insert account;

        List<SObject> sObjectList;
        VCC_Stub hcFacilitySelectorStub = new VCC_Stub(VCC_HealthcareFacilitySelector.class);
        hcFacilitySelectorStub.setReturnValue(
            'selectBySiteIdAndPersona',
            new List<HealthcareFacility>{
                new HealthcareFacility(
                    Name = 'Facility 1',
                    VCC_Personas__c = 'MD',
                    VCC_Site_Id__c = Integer.valueOf(SITE_ID),
                    AccountId = account.Id
                ),
                new HealthcareFacility(
                    Name = 'Facility 2',
                    VCC_Personas__c = 'MD',
                    VCC_Site_Id__c = Integer.valueOf(SITE_ID),
                    AccountId = account.Id
                ),
                new HealthcareFacility(
                    Name = 'Facility 3',
                    VCC_Personas__c = 'RN',
                    VCC_Site_Id__c = Integer.valueOf(SITE_ID),
                    AccountId = account.Id
                )
            }
        );

        // Special case to use runAs() to create the test user.  This avoids mixed DML errors.
        System.runAs(createTestUserOnNewThread()) {
            Test.startTest();
            VCC_LookupController.healthcareFacilitySelector = (VCC_HealthcareFacilitySelector) hcFacilitySelectorStub.instance;
            VCC_LookupController.progressNoteConfigurationSelector = (VCC_ProgressNoteConfigSelector) configSelectorStub.instance;
            sObjectList = VCC_LookupController.findRecords(SITE_ID, '', PERSONA);
            Test.stopTest();
        }

        configSelectorStub.assertInvoked('selectByRecordTypeAPIName');
        Assert.areEqual(3, sObjectList.size(), 'Expected three facilities.');
    }

    private static User createTestUser() {
        return new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSet('VCC_Pharmacy_I')
            .withStandardData()
            .build(true);
    }

    private static User createAdminUser() {
        return new VATEST_UserBuilder().withUserProfile('System Administrator').withStandardData().build(false);
    }

    private static User createTestUserOnNewThread() {
        System.runAs(createAdminUser()) {
            return createTestUser();
        }
        return null;
    }
}
