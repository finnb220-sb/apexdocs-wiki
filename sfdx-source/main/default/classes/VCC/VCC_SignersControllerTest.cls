/**
 * @description Test class for VCC_SignersController
 * @author      Booz Allen
 * @see         VCC_SignersController
 */
@IsTest
public class VCC_SignersControllerTest {
    private static String recordId;

    /*@TestSetup
    private static void makeData() {
        Case c = new Case();
        insert c;
        VCC_Progress_Note__c progressNote = new VCC_Progress_Note__c(
            VCC_Case__c = c.Id
        );
        // make data
        insert progressNote;
        recordId = progressNote.Id;
    }*/

    // This is a whitespace change made to ensure this test is run by ci system.

    private static String username = 'sigCont';

    /**
     * @description Creates test users
     */
    @TestSetup
    public static void makeData() {
        User rnTestUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        rnTestUser.Username = username + rnTestUser.Username;
        VCC_TestDataFactory.addPermSetGroupToUser('VCC_Registered_Nurse', rnTestUser);

        User msaTestUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        msaTestUser.Username = username + msaTestUser.Username;
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_MSA_Administrative_Officer', msaTestUser);

        User amsaTestUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        amsaTestUser.Username = username + amsaTestUser.Username;
        VCC_TestDataFactory.addPermSetGroupToUser('VCC_Advanced_Medical_Support_Assistant', amsaTestUser);

        update new List<User>{ rnTestUser, msaTestUser, amsaTestUser };
    }

    /**
     * @description Retrieves test users
     * @return      `List<User>`
     */
    public static List<User> getTestUsers() {
        return [SELECT Id FROM User WHERE Username LIKE :username + '%'];
    }

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
    static void unitGetSignersForRecordPositive() {
        VCC_Stub signersServiceStub = VCC_SignersService.stub();
        signersServiceStub.setReturnValue(
            'getSignersForRecord',
            new List<VCC_Signers__c>{ new VCC_Signers__c(VCC_DUZ__c = 'test') }
        );

        Test.startTest();
        System.runAs(createTestAdminUser()) {
            List<VCC_Signers__c> signersList = VCC_SignersController.getSignersForRecord((Id) '000000000000000000');
            System.assert(signersList[0].VCC_DUZ__c == 'test', 'Expected signer duz to match mocked value');
            System.assert(signersList.size() == 1, 'Expected one signer');
        }
    }

    @IsTest
    static void testSearchProviders() {
        List<VCC_Vista_User__c> vistaUserList = new List<VCC_Vista_User__c>{
            new VCC_Vista_User__c(
                VCC_StaffName__c = 'VCC_StaffName__c',
                VCC_NPI__c = 'VCC_NPI__c',
                VCC_PositionTitle__c = 'VCC_PositionTitle__c',
                VCC_FirstName__c = 'VCC_FirstName__c',
                VCC_LastName__c = 'VCC_LastName__c',
                VCC_StaffIEN__c = 'VCC_StaffIEN__c',
                VCC_Station__c = 'VCC'
            )
        };
        insert vistaUserList;

        Test.startTest();
        Boolean useSosl = VCC_Named_Toggle__mdt.getInstance('New_Signers_Search_Enable_SOSL').VCC_State__c;
        if (useSosl == true) {
            Test.setFixedSearchResults(new List<Id>{ vistaUserList[0].Id });
        }
        System.assert(
            (VCC_SignersController.searchProviders('VCC_StaffName__c', 'VCC_Station__c'))[0].Id == vistaUserList[0].Id,
            'Expected returned provider to match.'
        );
        Test.stopTest();
    }

    @IsTest
    static void testAddSigners() {
        Case testCase = new Case(
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
                .get('VCC_Clinical_Triage')
                .getRecordTypeId()
        );
        insert testCase;
        VCC_Progress_Note__c vccProgressNote = new VCC_Progress_Note__c(VCC_Case__c = testCase.Id);
        insert vccProgressNote;
        VCC_Addendum__c vccAddendum = new VCC_Addendum__c(
            VCC_Related_Note__c = vccProgressNote.Id,
            VCC_Addendum__c = 'test'
        );
        insert vccAddendum;

        List<VCC_Vista_User__c> vistaUserList = new List<VCC_Vista_User__c>{
            new VCC_Vista_User__c(
                VCC_StaffName__c = 'VCC_StaffName__c',
                VCC_NPI__c = 'VCC_NPI__c',
                VCC_PositionTitle__c = 'VCC_PositionTitle__c',
                VCC_FirstName__c = 'VCC_FirstName__c',
                VCC_LastName__c = 'VCC_LastName__c',
                VCC_StaffIEN__c = 'VCC_StaffIEN__c',
                VCC_Station__c = 'VCC_Station__c'
            )
        };
        insert vistaUserList;

        Test.startTest();
        VCC_SignersController.addSignersToRecord(vistaUserList, vccProgressNote.Id);
        VCC_SignersController.addSignersToRecord(vistaUserList, vccAddendum.Id);

        System.assert(
            [SELECT Id FROM VCC_Signers__c WHERE VCC_Addendum__c = :vccAddendum.Id].size() == 1,
            'Expected one signer added.'
        );
        System.assert(
            [SELECT Id FROM VCC_Signers__c WHERE VCC_Progress_Note__c = :vccProgressNote.Id].size() == 1,
            'Expected one signer added.'
        );
        Test.stopTest();
    }

    @IsTest
    static void testDeleteSigners() {
        Case testCase = new Case(
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
                .get('VCC_Clinical_Triage')
                .getRecordTypeId()
        );
        insert testCase;
        VCC_Progress_Note__c vccProgressNote = new VCC_Progress_Note__c(VCC_Case__c = testCase.Id);
        insert vccProgressNote;
        VCC_Addendum__c vccAddendum = new VCC_Addendum__c(
            VCC_Related_Note__c = vccProgressNote.Id,
            VCC_Addendum__c = 'test'
        );
        insert vccAddendum;

        List<VCC_Signers__c> pnSignersList = new List<VCC_Signers__c>{
            new VCC_Signers__c(VCC_Progress_Note__c = vccProgressNote.Id)
        };

        List<VCC_Signers__c> adSignersList = new List<VCC_Signers__c>{
            new VCC_Signers__c(VCC_Addendum__c = vccAddendum.Id)
        };

        insert adSignersList;
        insert pnSignersList;

        Test.startTest();

        VCC_SignersController.deleteSigners(adSignersList);
        VCC_SignersController.deleteSigners(pnSignersList);

        System.assert(
            [SELECT Id FROM VCC_Signers__c WHERE VCC_Addendum__c = :vccAddendum.Id].size() == 0,
            'Expected zero signers.'
        );
        System.assert(
            [SELECT Id FROM VCC_Signers__c WHERE VCC_Progress_Note__c = :vccProgressNote.Id].size() == 0,
            'Expected zero signers.'
        );

        Test.stopTest();
    }

    @IsTest
    public static void unitGetProvidersBySitePositive() {
        System.runAs(createTestAdminUser()) {
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_vdifGetProvidersBySiteMockReponse');
            Test.setMock(HTTPCalloutMock.class, mock);
            String providers;

            Test.startTest();
            providers = VCC_SignersController.getProvidersBySite('test', 'test', 'test', createProgressNoteId());
            Test.stopTest();

            Assert.isTrue(
                providers != null && providers.contains('520648375'),
                'Results do not match static resource.'
            );
        }
    }
    @IsTest
    private static void unitDeleteSignersNegative() {
        System.runAs(createTestAdminUser()) {
            List<VCC_Signers__c> emptySignersList = new List<VCC_Signers__c>();
            Test.startTest();
            Assert.isFalse(
                VCC_SignersController.deleteSigners(emptySignersList),
                'Expected deleteSigners to return false.'
            );
            Test.stopTest();
        }
    }

    @IsTest
    private static void unitAddSignersToRecordFirstParamEmptyNegative() {
        System.runAs(createTestAdminUser()) {
            Test.startTest();
            List<VCC_Vista_User__c> vistaUserList = new List<VCC_Vista_User__c>();
            Assert.isFalse(
                VCC_SignersController.addSignersToRecord(vistaUserList, createProgressNoteId()),
                'Expected result to be false when vistaUserList is empty.'
            );
            Test.stopTest();
        }
    }

    @IsTest
    private static void unitAddSignersToRecordSecondParamEmptyNegative() {
        System.runAs(createTestAdminUser()) {
            Test.startTest();
            List<VCC_Vista_User__c> vistaUserList = new List<VCC_Vista_User__c>{
                new VCC_Vista_User__c(
                    VCC_StaffName__c = 'VCC_StaffName__c',
                    VCC_NPI__c = 'VCC_NPI__c',
                    VCC_PositionTitle__c = 'VCC_PositionTitle__c',
                    VCC_FirstName__c = 'VCC_FirstName__c',
                    VCC_LastName__c = 'VCC_LastName__c',
                    VCC_StaffIEN__c = 'VCC_StaffIEN__c',
                    VCC_Station__c = 'VCC_Station__c'
                )
            };
            Id emptyId;
            Assert.isFalse(
                VCC_SignersController.addSignersToRecord(vistaUserList, emptyId),
                'Expected result to be false when ID is blank.'
            );
            Test.stopTest();
        }
    }

    @IsTest
    private static void unitSearchProvidersFirstParamEmptyNegative() {
        System.runAs(createTestAdminUser()) {
            Test.startTest();
            List<VCC_Vista_User__c> result = VCC_SignersController.searchProviders('', '983');
            Assert.areEqual(
                new List<VCC_Vista_User__c>(),
                result,
                'Expected result to be an empty VCC_Vista_User__c List when search string is blank.'
            );
            Test.stopTest();
        }
    }

    @IsTest
    private static void unitSearchProvidersFirstParamLengthLessThanThreeNegative() {
        System.runAs(createTestAdminUser()) {
            Test.startTest();
            List<VCC_Vista_User__c> result = VCC_SignersController.searchProviders('12', '983');
            Assert.areEqual(
                new List<VCC_Vista_User__c>(),
                result,
                'Expected result to be an empty VCC_Vista_User__c List when search string is less than 3 in length.'
            );
            Test.stopTest();
        }
    }

    @IsTest
    private static void unitSearchProvidersSecondParamEmptyNegative() {
        System.runAs(createTestAdminUser()) {
            Test.startTest();
            List<VCC_Vista_User__c> result = VCC_SignersController.searchProviders('test', '');
            Assert.areEqual(
                new List<VCC_Vista_User__c>(),
                result,
                'Expected result to be an empty VCC_Vista_User__c List when site id is blank.'
            );
            Test.stopTest();
        }
    }
}
