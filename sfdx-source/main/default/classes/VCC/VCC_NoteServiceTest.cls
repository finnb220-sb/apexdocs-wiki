@isTest
public with sharing class VCC_NoteServiceTest {
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

    @isTest
    public static void unitCreateAddendumPositive() {
        System.runAs(createTestAdminUser()) {
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_vdifCreateAddendumMockResponse');
            Test.setMock(HttpCalloutMock.class, mock);

            VCC_VdifRSCommon.TextTO result;
            VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams = new VCC_Vdif_NoteAndEncounterParams();
            VCC_Vdif_PatientAndProviderParams patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();

            noteAndEncounterParams.itemId = 'test';
            noteAndEncounterParams.noteAndEncounterNoteTitleIen = 'test';
            patientAndProviderParams.providerLoginSiteCode = 'test';
            patientAndProviderParams.providerUserId = 'test';

            Test.startTest();
            result = VCC_NoteService.createAddendum(
                'test',
                noteAndEncounterParams,
                patientAndProviderParams,
                createProgressNoteId()
            );
            Test.stopTest();

            Assert.isTrue(result.text == '5269041', 'Expected "5269041" from static resource.');
        }
    }
    @isTest
    public static void unitSignNotePositive() {
        System.runAs(createTestAdminUser()) {
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_vdifSignNoteMockResponse');
            Test.setMock(HttpCalloutMock.class, mock);

            VCC_VdifRSCommon.TextTO result;
            VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams = new VCC_Vdif_NoteAndEncounterParams();
            VCC_Vdif_PatientAndProviderParams patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
            patientAndProviderParams.eSig = 'test';
            patientAndProviderParams.providerLoginSiteCode = 'test';
            patientAndProviderParams.providerName = 'test';
            patientAndProviderParams.providerUserId = 'test';
            noteAndEncounterParams.itemId = 'test';
            patientAndProviderParams.authorDUZ = 'test';

            Test.startTest();
            result = VCC_NoteService.signNote(noteAndEncounterParams, patientAndProviderParams, createProgressNoteId());
            Test.stopTest();

            Assert.isTrue(result.text == 'OK', 'Expected "OK" from static resource.');
        }
    }
    @isTest
    public static void unitWriteNotePositive() {
        System.runAs(createTestAdminUser()) {
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_vdifWriteNoteMockResponse');
            Test.setMock(HttpCalloutMock.class, mock);

            VCC_VdifWriteNoteRS.NoteResultTO result;
            VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams = new VCC_Vdif_NoteAndEncounterParams();
            VCC_Vdif_PatientAndProviderParams patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();

            noteAndEncounterParams.encounterString = 'test';
            patientAndProviderParams.providerName = 'test';
            patientAndProviderParams.providerLoginSiteCode = 'test';
            patientAndProviderParams.providerUserId = 'test';
            patientAndProviderParams.patientLocalPid = 12345;
            noteAndEncounterParams.noteAndEncounterNoteTitleIen = 'test';
            patientAndProviderParams.patientLocalSiteId = 'test';
            patientAndProviderParams.authorDUZ = 'test';

            Test.startTest();
            result = VCC_NoteService.writeNote(
                'test',
                noteAndEncounterParams,
                patientAndProviderParams,
                createProgressNoteId()
            );
            Test.stopTest();

            System.assert(result.Id == '1810049', 'Expected "1810049" from static resource.');
        }
    }

    @isTest
    public static void unitAddSignersPositive() {
        System.runAs(createTestAdminUser()) {
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_vdifGetAdditionalSignersMockResponse');
            Test.setMock(HttpCalloutMock.class, mock);

            VCC_VdifGetAdditionalSignersRS result;
            VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams = new VCC_Vdif_NoteAndEncounterParams();
            VCC_Vdif_PatientAndProviderParams patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
            patientAndProviderParams.providerName = 'test';
            patientAndProviderParams.providerUserId = 'test';
            patientAndProviderParams.providerLoginSiteCode = 'test';
            noteAndEncounterParams.itemId = 'test';
            List<String> providerDuzList = new List<String>{ 'one', 'two' };

            Test.startTest();
            result = VCC_NoteService.addSigners(
                noteAndEncounterParams,
                patientAndProviderParams,
                providerDuzList,
                createProgressNoteId()
            );
            Test.stopTest();

            Assert.isTrue(
                result.taggedTextArray.results.taggedText[0].tag == '983',
                'Expected "983" from static resource.'
            );
        }
    }

    @IsTest
    private static void unitAddSignersNegative() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            try {
                Id nullRecordId;
                VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams = new VCC_Vdif_NoteAndEncounterParams();
                VCC_Vdif_PatientAndProviderParams patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
                patientAndProviderParams.providerName = 'test';
                patientAndProviderParams.providerUserId = 'test';
                patientAndProviderParams.providerLoginSiteCode = 'test';
                noteAndEncounterParams.itemId = 'test';
                List<String> providerDuzList = new List<String>{ 'one', 'two' };

                VCC_NoteService.addSigners(
                    noteAndEncounterParams,
                    patientAndProviderParams,
                    providerDuzList,
                    nullRecordId
                );
            } catch (VCC_TransactionId.InstantiationException thrownException) {
                Assert.isTrue(
                    thrownException.getMessage().contains(VCC_TransactionId.NULL_INPUT_EXCEPTION_MESSAGE),
                    'Expected exception message to contain string defined in VCC_TransationId.NULL_INPUT_EXCEPTION_MESSAGE'
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitWriteNoteNegative() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            try {
                Id nullRecordId;
                VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams = new VCC_Vdif_NoteAndEncounterParams();
                VCC_Vdif_PatientAndProviderParams patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
                noteAndEncounterParams.encounterString = 'test';
                patientAndProviderParams.providerName = 'test';
                patientAndProviderParams.providerLoginSiteCode = 'test';
                patientAndProviderParams.providerUserId = 'test';
                patientAndProviderParams.patientLocalPid = 12345;
                noteAndEncounterParams.noteAndEncounterNoteTitleIen = 'test';
                patientAndProviderParams.patientLocalSiteId = 'test';
                patientAndProviderParams.authorDUZ = 'test';

                VCC_NoteService.writeNote('test', noteAndEncounterParams, patientAndProviderParams, nullRecordId);
            } catch (VCC_TransactionId.InstantiationException thrownException) {
                Assert.isTrue(
                    thrownException.getMessage().contains(VCC_TransactionId.NULL_INPUT_EXCEPTION_MESSAGE),
                    'Expected exception message to contain string defined in VCC_TransationId.NULL_INPUT_EXCEPTION_MESSAGE'
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitSignNoteNegative() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            try {
                Id nullRecordId;
                VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams = new VCC_Vdif_NoteAndEncounterParams();
                VCC_Vdif_PatientAndProviderParams patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
                patientAndProviderParams.eSig = 'test';
                patientAndProviderParams.providerLoginSiteCode = 'test';
                patientAndProviderParams.providerName = 'test';
                patientAndProviderParams.providerUserId = 'test';
                noteAndEncounterParams.itemId = 'test';
                patientAndProviderParams.authorDUZ = 'test';

                VCC_NoteService.signNote(noteAndEncounterParams, patientAndProviderParams, nullRecordId);
            } catch (VCC_TransactionId.InstantiationException thrownException) {
                Assert.isTrue(
                    thrownException.getMessage().contains(VCC_TransactionId.NULL_INPUT_EXCEPTION_MESSAGE),
                    'Expected exception message to contain string defined in VCC_TransationId.NULL_INPUT_EXCEPTION_MESSAGE'
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitCreateAddendumNegative() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            try {
                Id nullRecordId;
                VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams = new VCC_Vdif_NoteAndEncounterParams();
                VCC_Vdif_PatientAndProviderParams patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();

                noteAndEncounterParams.itemId = 'test';
                noteAndEncounterParams.noteAndEncounterNoteTitleIen = 'test';
                patientAndProviderParams.providerLoginSiteCode = 'test';
                patientAndProviderParams.providerUserId = 'test';

                VCC_NoteService.createAddendum('test', noteAndEncounterParams, patientAndProviderParams, nullRecordId);
            } catch (VCC_TransactionId.InstantiationException thrownException) {
                Assert.isTrue(
                    thrownException.getMessage().contains(VCC_TransactionId.NULL_INPUT_EXCEPTION_MESSAGE),
                    'Expected exception message to contain string defined in VCC_TransationId.NULL_INPUT_EXCEPTION_MESSAGE'
                );
            }
        }
        Test.stopTest();
    }
}
