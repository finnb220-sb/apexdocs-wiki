@IsTest
public with sharing class VCC_VdifTestRun_EncTest {
    private static String username = 'VCC_VdifTestRun_EncTest';

    @TestSetup
    public static void makeData() {
        User testUser = VCC_TestDataFactory.insertUser('Standard User');
        VCC_TestDataFactory.assignPermissionSetByName(testUser, 'VCC_Integration_Test_Utility_Base');
        VCC_TestDataFactory.assignPermissionSetByName(testUser, 'VCC_Integration_Test_Utility_Vdif');
        testUser.Username = username + testUser.Username;
        update testUser;
    }

    public static User getTestUser() {
        return [SELECT Id FROM User WHERE Username LIKE :username + '%' LIMIT 1];
    }

    @IsTest
    static void onStartTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_VdifParameters vdifParams = new VCC_VdifParameters();
            VCC_Test_Run__c testRun = new VCC_Test_Run__c(
                VCC_Category__c = 'VDIF',
                VCC_Sub_Category__c = 'Create encounter, note, and sign',
                RecordTypeId = Schema.SObjectType.VCC_Test_Run__c.getRecordTypeInfosByDeveloperName().get('VCC_Vdif_Test_Run').getRecordTypeId()
            );
            VCC_Test_Configuration_Data__c testPatientMtd = new VCC_Test_Configuration_Data__c(
                VCC_Additional_Signer_IEN__c = 'asi',
                VCC_Diagnosis_Codes__c = 'dc1,dc2',
                VCC_Note_Text__c = 'nt',
                VCC_Note_Title_IEN_For_Encounter__c = 'ntife',
                VCC_Location_IEN__c = 'li',
                VCC_Procedure_Codes__c = 'pc',
                VCC_Visit_Related_Tos__c = 'vrt'
            );
            VCC_VdifQueueStrat_TestRun testRunQueueStrat = new VCC_VdifQueueStrat_TestRun(testRun, testPatientMtd);
            VCC_VdifQueueableCallback vdifQueueableCallback = new VCC_VdifQueueableCallback(vdifParams, testRunQueueStrat);

            System.assert(testRunQueueStrat.subStrategy instanceof VCC_VdifTestRun_Encounter, 'Expected a different sub-strategy.');

            vdifQueueableCallback.setStage(VCC_VdifQueueableCallback.Stage.ADD_SIGNERS);
            testRunQueueStrat.subStrategy.onQueueableStart(vdifQueueableCallback);
            vdifQueueableCallback.setStage(VCC_VdifQueueableCallback.Stage.WRITE_NOTE);
            testRunQueueStrat.subStrategy.onQueueableStart(vdifQueueableCallback);
            vdifQueueableCallback.setStage(VCC_VdifQueueableCallback.Stage.CREATE_ENCOUNTER);
            testRunQueueStrat.subStrategy.onQueueableStart(vdifQueueableCallback);

            System.assert(vdifParams.vdifNote.additionalSigners[0] == 'asi', 'Expected vdifParams.vdifNote.additionalSigners[0] to be "asi".');
            System.assert(vdifParams.vdifNote.text == 'nt', 'Expected vdifParams.vdifNote.text to be "nt".');
            System.assert(vdifParams.vdifNote.noteTitleIen == 'ntife', 'Expected vdifParams.vdifNote.noteTitleIen to be "nti".');
            System.assert(vdifParams.vdifEncounter.diagnoses == 'dc1^^1^^dc2^^^^', 'Expected vdifParams.vdifEncounter.diagnoses to be "dc1^^1^^dc2^^^^".');
            System.assert(vdifParams.vdifEncounter.locationIen == 'li', 'Expected vdifEncounter.locationIen to be "li".');
            System.assert(vdifParams.vdifEncounter.noteTitleIen == 'ntife', 'Expected vdifEncounter.noteTitleIen to be "ntife".');
            System.assert(vdifParams.vdifEncounter.procedures == 'pc^^^^null', 'Expected vdifEncounter.procedures to be "pc^^^^null".');
            System.assert(vdifParams.vdifEncounter.serviceCategory == 'T', 'Expected vdifEncounter.serviceCategory to be "T".');
            System.assert(vdifParams.vdifEncounter.visitRelatedTos == 'vrt', 'Expected vdifEncounter.visitRelatedTos to be "vrt".');
        }
        Test.stopTest();
    }

    @IsTest
    static void onExceptionTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_VdifParameters vdifParams = new VCC_VdifParameters();
            VCC_Test_Run__c testRun = new VCC_Test_Run__c(
                VCC_Category__c = 'VDIF',
                VCC_Sub_Category__c = 'Create encounter, note, and sign',
                RecordTypeId = Schema.SObjectType.VCC_Test_Run__c.getRecordTypeInfosByDeveloperName().get('VCC_Vdif_Test_Run').getRecordTypeId()
            );
            VCC_Test_Configuration_Data__c testPatientMtd = new VCC_Test_Configuration_Data__c(
                VCC_Additional_Signer_IEN__c = 'asi',
                VCC_Diagnosis_Codes__c = 'dc1,dc2',
                VCC_Note_Text__c = 'nt',
                VCC_Note_Title_IEN_For_Encounter__c = 'ntife',
                VCC_Location_IEN__c = 'li',
                VCC_Procedure_Codes__c = 'pc',
                VCC_Visit_Related_Tos__c = 'vrt'
            );
            VCC_VdifQueueStrat_TestRun testRunQueueStrat = new VCC_VdifQueueStrat_TestRun(testRun, testPatientMtd);
            VCC_VdifQueueableCallback vdifQueueableCallback = new VCC_VdifQueueableCallback(vdifParams, testRunQueueStrat);

            System.assert(testRunQueueStrat.subStrategy instanceof VCC_VdifTestRun_Encounter, 'Expected a different sub-strategy.');
            try {
                throw new AuraHandledException('test');
            } catch (Exception e) {
                testRunQueueStrat.subStrategy.onException(e, vdifQueueableCallback);
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void onCalloutSignNote() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Stub vdifQueueableCallbackStub = new VCC_Stub(VCC_VdifQueueableCallback.class);
            VCC_VdifQueueableCallback vdifQueueableCallback = (VCC_VdifQueueableCallback) vdifQueueableCallbackStub.instance;
            VCC_VdifParameters vdifParams = new VCC_VdifParameters();
            VCC_VdifSignNoteRS signNoteRS = new VCC_VdifSignNoteRS();

            vdifQueueableCallbackStub.setReturnValue('getVdifParameters', vdifParams);
            vdifQueueableCallbackStub.setReturnValue('getStage', VCC_VdifQueueableCallback.Stage.SIGN_NOTE);

            VCC_VdifTestRun_Encounter testRunEncounter = new VCC_VdifTestRun_Encounter();

            VCC_IntegrationTestUtilityService.AssertFailedException expectedException;
            try {
                testRunEncounter.onCalloutResponse(signNoteRS, vdifQueueableCallback);
            } catch (VCC_IntegrationTestUtilityService.AssertFailedException e) {
                expectedException = e;
            }
            System.assert(expectedException != null, 'Expected an exception.');

            signNoteRS.signNoteTextTO.text = 'OK';
            testRunEncounter.onCalloutResponse(signNoteRS, vdifQueueableCallback);
        }
        Test.stopTest();
    }

    @IsTest
    static void onCalloutWriteNote() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Stub vdifQueueableCallbackStub = new VCC_Stub(VCC_VdifQueueableCallback.class);
            VCC_VdifQueueableCallback vdifQueueableCallback = (VCC_VdifQueueableCallback) vdifQueueableCallbackStub.instance;
            VCC_VdifParameters vdifParams = new VCC_VdifParameters();
            VCC_VdifWriteNoteRS writeNoteRS = new VCC_VdifWriteNoteRS();

            vdifQueueableCallbackStub.setReturnValue('getVdifParameters', vdifParams);
            vdifQueueableCallbackStub.setReturnValue('getStage', VCC_VdifQueueableCallback.Stage.WRITE_NOTE);

            VCC_VdifTestRun_Encounter testRunEncounter = new VCC_VdifTestRun_Encounter();

            VCC_IntegrationTestUtilityService.AssertFailedException expectedException;
            try {
                testRunEncounter.onCalloutResponse(writeNoteRS, vdifQueueableCallback);
            } catch (VCC_IntegrationTestUtilityService.AssertFailedException e) {
                expectedException = e;
            }
            System.assert(expectedException != null, 'Expected an exception.');

            writeNoteRS.noteResultTO.id = '12345';
            testRunEncounter.onCalloutResponse(writeNoteRS, vdifQueueableCallback);
        }
        Test.stopTest();
    }

    @IsTest
    static void onCalloutEncounterTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Stub vdifQueueableCallbackStub = new VCC_Stub(VCC_VdifQueueableCallback.class);
            VCC_VdifQueueableCallback vdifQueueableCallback = (VCC_VdifQueueableCallback) vdifQueueableCallbackStub.instance;
            VCC_VdifParameters vdifParams = new VCC_VdifParameters();
            VCC_VdifSaveNoteAndEncounterRS saveNoteAndEncounterRS = new VCC_VdifSaveNoteAndEncounterRS();

            vdifQueueableCallbackStub.setReturnValue('getVdifParameters', vdifParams);
            vdifQueueableCallbackStub.setReturnValue('getStage', VCC_VdifQueueableCallback.Stage.CREATE_ENCOUNTER);

            VCC_VdifTestRun_Encounter testRunEncounter = new VCC_VdifTestRun_Encounter();
            saveNoteAndEncounterRS.saveNoteAndEncounterTextTO.text = 'fail';
            VCC_IntegrationTestUtilityService.AssertFailedException expectedException;

            try {
                testRunEncounter.onCalloutResponse(saveNoteAndEncounterRS, vdifQueueableCallback);
            } catch (VCC_IntegrationTestUtilityService.AssertFailedException e) {
                expectedException = e;
            }
            System.assert(expectedException != null, 'Expected an exception.');

            String encString = VCC_EncounterService.generateEncounterString(1111);
            saveNoteAndEncounterRS.saveNoteAndEncounterTextTO.text = encString;
            testRunEncounter.onCalloutResponse(saveNoteAndEncounterRS, vdifQueueableCallback);

            System.assert(vdifParams.vdifNote.encounterString == encString, 'Missing encounter string.');
        }
        Test.stopTest();
    }

    @IsTest
    static void onCalloutSignersTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Stub vdifQueueableCallbackStub = new VCC_Stub(VCC_VdifQueueableCallback.class);
            VCC_VdifQueueableCallback vdifQueueableCallback = (VCC_VdifQueueableCallback) vdifQueueableCallbackStub.instance;
            VCC_VdifParameters vdifParams = new VCC_VdifParameters();
            VCC_VdifGetAdditionalSignersRS getAdditionalSignersRS = new VCC_VdifGetAdditionalSignersRS();

            vdifQueueableCallbackStub.setReturnValue('getVdifParameters', vdifParams);
            vdifQueueableCallbackStub.setReturnValue('getStage', VCC_VdifQueueableCallback.Stage.ADD_SIGNERS);

            VCC_VdifTestRun_Encounter testRunEncounter = new VCC_VdifTestRun_Encounter();
            testRunEncounter.testPatientMetadata = new VCC_Test_Configuration_Data__c(VCC_Additional_Signer_IEN__c = 'test');
            VCC_IntegrationTestUtilityService.AssertFailedException expectedException;

            try {
                testRunEncounter.onCalloutResponse(getAdditionalSignersRS, vdifQueueableCallback);
            } catch (VCC_IntegrationTestUtilityService.AssertFailedException e) {
                expectedException = e;
            }
            System.assert(expectedException != null, 'Expected exception was not thrown.');
            expectedException = null;

            getAdditionalSignersRS.taggedTextArray.count = 1;
            getAdditionalSignersRS.taggedTextArray.results.taggedText.add(new VCC_VdifRSCommon.TaggedText());
            try {
                testRunEncounter.onCalloutResponse(getAdditionalSignersRS, vdifQueueableCallback);
            } catch (VCC_IntegrationTestUtilityService.AssertFailedException e) {
                expectedException = e;
            }
            System.assert(expectedException != null, 'Expected exception was not thrown.');

            VCC_VdifRSCommon.TaggedText tt = new VCC_VdifRSCommon.TaggedText();
            tt.text = testRunEncounter.testPatientMetadata.VCC_Additional_signer_IEN__c;
            getAdditionalSignersRS.taggedTextArray.results.taggedText[0] = tt;
            testRunEncounter.onCalloutResponse(getAdditionalSignersRS, vdifQueueableCallback);
        }
        Test.stopTest();
    }

    @IsTest
    static void onEndTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Stub vdifQueueableCallbackStub = new VCC_Stub(VCC_VdifQueueableCallback.class);
            vdifQueueableCallbackStub.setReturnValue('enqueueStage', null);

            VCC_Stub stubClone = vdifQueueableCallbackStub.clone();
            VCC_VdifTestRun_Encounter testRunEncounter = new VCC_VdifTestRun_Encounter();

            stubClone.setReturnValue('getStage', VCC_VdifQueueableCallback.Stage.ADD_SIGNERS);
            testRunEncounter.onQueueableEnd((VCC_VdifQueueableCallback) stubClone.instance);
            stubClone.assertInvoked('enqueueStage');
            stubClone.assertInvoked('getStage');

            stubClone = vdifQueueableCallbackStub.clone();
            stubClone.setReturnValue('getStage', VCC_VdifQueueableCallback.Stage.VALIDATE_ESIG);
            testRunEncounter.onQueueableEnd((VCC_VdifQueueableCallback) stubClone.instance);
            stubClone.assertInvoked('enqueueStage');
            stubClone.assertInvoked('getStage');

            stubClone = vdifQueueableCallbackStub.clone();
            stubClone.setReturnValue('getStage', VCC_VdifQueueableCallback.Stage.CREATE_ENCOUNTER);
            testRunEncounter.onQueueableEnd((VCC_VdifQueueableCallback) stubClone.instance);
            stubClone.assertInvoked('enqueueStage');
            stubClone.assertInvoked('getStage');

            testRunEncounter.testPatientMetadata = new VCC_Test_Configuration_Data__c();
            stubClone = vdifQueueableCallbackStub.clone();
            stubClone.setReturnValue('getStage', VCC_VdifQueueableCallback.Stage.WRITE_NOTE);
            testRunEncounter.onQueueableEnd((VCC_VdifQueueableCallback) stubClone.instance);
            stubClone.assertInvoked('enqueueStage');
            stubClone.assertInvoked('getStage');

            testRunEncounter.testPatientMetadata.VCC_Additional_Signer_IEN__c = 'idk';
            stubClone = vdifQueueableCallbackStub.clone();
            stubClone.setReturnValue('getStage', VCC_VdifQueueableCallback.Stage.WRITE_NOTE);
            testRunEncounter.onQueueableEnd((VCC_VdifQueueableCallback) stubClone.instance);
            stubClone.assertInvoked('enqueueStage');
            stubClone.assertInvoked('getStage');

            System.assert(true, 'An assert.');
        }
        Test.stopTest();
    }
}
