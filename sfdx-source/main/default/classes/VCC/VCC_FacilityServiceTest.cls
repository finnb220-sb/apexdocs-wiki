@IsTest
public with sharing class VCC_FacilityServiceTest {
    /**
     * @description Creates progress note record
     * @return      `Id` record Id
     */
    private static Id createProgressNoteId() {
        VCC_Progress_Note__c testProgressNote = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
            new VCC_Progress_Note__c(
                RecordTypeId = VCC_Progress_Note__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                    .getRecordTypeInfosByDeveloperName()
                    .get('VCC_Clinical_Triage_Note_Progress_Note')
                    .getRecordTypeId()
            )
        );
        return testProgressNote.Id;
    }

    /**
     * @description Creates an admin test user
     * @return      `User`
     */
    private static User createTestAdminUser() {
        return (new VATEST_UserBuilder())
            .withStandardData()
            .withUserProfile('System Administrator')
            .withPermissionSets(
                new Set<String>(
                    new List<String>{
                        'VAHC_RN_User',
                        'VAHC_Write_Clinical_Triage_Progress_Note',
                        'VAHC_Read_Progress_Notes',
                        'VAHC_Write_Virtual_Clinic_Visit_Progress_Note',
                        'VAHC_MP_User'
                    }
                )
            )
            .build(true);
    }

    @IsTest
    public static void unitSearchProvidersLocationPositive() {
        System.runAs(createTestAdminUser()) {
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_vdifGetProvidersBySiteMockReponse');
            Test.setMock(HttpCalloutMock.class, mock);

            Schema.Location facility = new Schema.Location(Name = 'test', VAF_Facility_ID__c = 'vha_983');
            List<VCC_VdifGetProvidersBySiteRS.ProviderTO> providerList;
            Test.startTest();
            providerList = VCC_FacilityService.searchProviders(facility, 'test', 'test', createProgressNoteId());
            Test.stopTest();
            Assert.isTrue(providerList != null, 'Expected list of providers from static resource.');
        }
    }

    @IsTest
    public static void unitSearchProvidersHealthcareFacilityPositive() {
        System.runAs(createTestAdminUser()) {
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_vdifGetProvidersBySiteMockReponse');
            Test.setMock(HttpCalloutMock.class, mock);

            Account testAccount = (Account) VATEST_SObjectFactory.createSObject(new Account(Name = 'Test Account'));
            HealthcareFacility testFacility = (HealthcareFacility) VATEST_SObjectFactory.createSObject(
                new HealthcareFacility(Name = 'test', AccountId = testAccount.Id, VCC_Site_Id__c = 983)
            );

            List<VCC_VdifGetProvidersBySiteRS.ProviderTO> providerList;
            Test.startTest();
            providerList = VCC_FacilityService.searchProviders(testFacility, 'test', 'test', createProgressNoteId());
            Test.stopTest();

            Assert.isTrue(providerList != null, 'Expected list of providers from static resource.');
        }
    }

    @IsTest
    static void stubTest() {
        Test.startTest();
        VCC_Stub facilityServiceStub = VCC_FacilityService.stub();
        System.assert(facilityServiceStub.instance === VCC_FacilityService.instance, 'Expected stub.');
        Test.stopTest();
    }

    @IsTest
    static void parseFacilityIdTestFail() {
        Test.startTest();
        System.assert(
            VCC_FacilityService.instance.parseFacilityId('vha_88EF').toString() == '',
            'Expected empty string due to invalid facility id.'
        );
        System.assert(
            VCC_FacilityService.instance.parseFacilityId(null).toString() == '',
            'Expected empty string due to invalid facility id.'
        );
        Test.stopTest();
    }

    @IsTest
    static void parseFacilityIdTestHappy1() {
        Test.startTest();
        VCC_FacilityService.FacilityId parsedId = VCC_FacilityService.instance.parseFacilityId('vha_984GG');
        System.assert(parsedId.toString() == 'vha_984GG', 'Expected "vha_984GG".');
        System.assert(parsedId.facilityNumber == '984', 'Expected facility number to be "984".');
        System.assert(parsedId.prefix == 'vha', 'Expected prefix to be "vha".');
        System.assert(parsedId.postfix == 'GG', 'Expected postfix to be "GG".');
        Test.stopTest();
    }

    @IsTest
    static void parseFacilityIdTestHappy2() {
        Test.startTest();
        VCC_FacilityService.FacilityId parsedId = VCC_FacilityService.instance.parseFacilityId('984GG');
        System.assert(parsedId.toString() == '984GG', 'Expected "984GG".');
        System.assert(parsedId.facilityNumber == '984', 'Expected facility number to be "984".');
        System.assert(parsedId.prefix == null, 'Expected prefix to be null.');
        System.assert(parsedId.postfix == 'GG', 'Expected postfix to be "GG".');
        Test.stopTest();
    }

    @IsTest
    static void parseFacilityIdTestHappy3() {
        Test.startTest();
        VCC_FacilityService.FacilityId parsedId = VCC_FacilityService.instance.parseFacilityId('984');
        System.assert(parsedId.toString() == '984', 'Expected "984".');
        System.assert(parsedId.prefix == null, 'Expected prefix to be null.');
        System.assert(parsedId.facilityNumber == '984', 'Expected facility number to be "984".');
        System.assert(parsedId.postfix == null, 'Expected postfix to be null.');
        Test.stopTest();
    }

    @IsTest
    static void facilityIdHashEqualsTest() {
        Test.startTest();
        Set<VCC_FacilityService.FacilityId> fidset = new Set<VCC_FacilityService.FacilityId>();
        fidset.add(VCC_FacilityService.instance.parseFacilityId('984FF'));
        fidset.add(VCC_FacilityService.instance.parseFacilityId('984FF'));
        fidset.add(VCC_FacilityService.instance.parseFacilityId('984F'));
        fidset.add(VCC_FacilityService.instance.parseFacilityId('vha_984FF'));
        System.assert(fidset.size() == 3, 'Expected size of 3.');
        System.assert(
            VCC_FacilityService.instance.parseFacilityId('984FF').hashCode() ==
            VCC_FacilityService.instance.parseFacilityId('984FF').hashCode(),
            'Expected equivalent hashcodes.'
        );
        Test.stopTest();
    }
}
