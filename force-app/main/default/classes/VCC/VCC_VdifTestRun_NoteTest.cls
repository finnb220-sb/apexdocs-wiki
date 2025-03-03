@IsTest
public with sharing class VCC_VdifTestRun_NoteTest {
    private static String username = 'VCC_VdifTestRun_NoteTest';

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
    static void onStartTestAddSigners() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Stub vdifQueueableCallbackStub = new VCC_Stub(VCC_VdifQueueableCallback.class);
            VCC_VdifQueueableCallback vdifQueueableCallback = (VCC_VdifQueueableCallback) vdifQueueableCallbackStub.instance;
            VCC_VdifParameters vdifParams = new VCC_VdifParameters();
            VCC_VdifTestRun_Note testRunNote = new VCC_VdifTestRun_Note();

            vdifQueueableCallbackStub.setReturnValue('getVdifParameters', vdifParams);
            vdifQueueableCallbackStub.setReturnValue('getStage', VCC_VdifQueueableCallback.Stage.ADD_SIGNERS);
            testRunNote.testPatientMetadata = new VCC_Test_Configuration_Data__c(VCC_Additional_Signer_IEN__c = 'test');

            testRunNote.onQueueableStart(vdifQueueableCallback);
            vdifQueueableCallbackStub.assertInvoked('getVdifParameters');
            vdifQueueableCallbackStub.assertInvoked('getStage');
            System.assert(vdifParams.vdifNote.additionalSigners[0] == testRunNote.testPatientMetadata.VCC_Additional_Signer_IEN__c, 'Expected an additional signer.');
        }
        Test.stopTest();
    }

    @IsTest
    static void onStartTestCreateAddendum() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Stub vdifQueueableCallbackStub = new VCC_Stub(VCC_VdifQueueableCallback.class);
            VCC_VdifQueueableCallback vdifQueueableCallback = (VCC_VdifQueueableCallback) vdifQueueableCallbackStub.instance;
            VCC_VdifParameters vdifParams = new VCC_VdifParameters();
            VCC_VdifTestRun_Note testRunNote = new VCC_VdifTestRun_Note();

            vdifQueueableCallbackStub.setReturnValue('getVdifParameters', vdifParams);
            vdifQueueableCallbackStub.setReturnValue('getStage', VCC_VdifQueueableCallback.Stage.CREATE_ADDENDUM);

            testRunNote.testPatientMetadata = new VCC_Test_Configuration_Data__c(VCC_Addendum_IEN__c = 'test');

            testRunNote.onQueueableStart(vdifQueueableCallback);
            vdifQueueableCallbackStub.assertInvoked('getVdifParameters');
            vdifQueueableCallbackStub.assertInvoked('getStage');

            System.assert(vdifParams.vdifNote.noteTitleIen == testRunNote.testPatientMetadata.VCC_Addendum_IEN__c, 'Expected addendum ien to match.');
        }
        Test.stopTest();
    }

    @IsTest
    static void onStartTestWriteNote() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Stub vdifQueueableCallbackStub = new VCC_Stub(VCC_VdifQueueableCallback.class);
            VCC_VdifQueueableCallback vdifQueueableCallback = (VCC_VdifQueueableCallback) vdifQueueableCallbackStub.instance;
            VCC_VdifParameters vdifParams = new VCC_VdifParameters();
            VCC_VdifTestRun_Note testRunNote = new VCC_VdifTestRun_Note();

            vdifQueueableCallbackStub.setReturnValue('getVdifParameters', vdifParams);
            vdifQueueableCallbackStub.setReturnValue('getStage', VCC_VdifQueueableCallback.Stage.WRITE_NOTE);
            testRunNote.testPatientMetadata = new VCC_Test_Configuration_Data__c(VCC_Location_IEN__c = '1234', VCC_Note_Text__c = 'nt', VCC_Note_Title_IEN__c = 'nti');

            testRunNote.onQueueableStart(vdifQueueableCallback);
            vdifQueueableCallbackStub.assertInvoked('getVdifParameters');
            vdifQueueableCallbackStub.assertInvoked('getStage');

            System.assert(vdifParams.vdifNote.text == testRunNote.testPatientMetadata.VCC_Note_Text__c, 'Expected note text to match');
            System.assert(vdifParams.vdifNote.noteTitleIen == testRunNote.testPatientMetadata.VCC_Note_Title_IEN__c, 'Expected note title ien to match');
        }
        Test.stopTest();
    }

    @IsTest
    static void onExceptionTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Stub vdifQueueableCallbackStub = new VCC_Stub(VCC_VdifQueueableCallback.class);
            VCC_VdifQueueableCallback vdifQueueableCallback = (VCC_VdifQueueableCallback) vdifQueueableCallbackStub.instance;
            VCC_VdifTestRun_Note testRunNote = new VCC_VdifTestRun_Note();
            Exception e = new AuraHandledException('test');
            testRunNote.onException(e, vdifQueueableCallback);
            System.assert(true, 'An assert.');
        }
        Test.stopTest();
    }

    @IsTest
    static void onCalloutSignersTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Stub vdifQueueableCallbackStub = new VCC_Stub(VCC_VdifQueueableCallback.class);
            VCC_VdifQueueableCallback vdifQueueableCallback = (VCC_VdifQueueableCallback) vdifQueueableCallbackStub.instance;
            VCC_VdifParameters vdifParameters = new VCC_VdifParameters();
            VCC_VdifTestRun_Note testRunNote = new VCC_VdifTestRun_Note();
            VCC_VdifGetAdditionalSignersRS addSignersRS = new VCC_VdifGetAdditionalSignersRS();
            VCC_VdifRSCommon.TaggedText tt = new VCC_VdifRSCommon.TaggedText();

            testRunNote.testPatientMetadata = new VCC_Test_Configuration_Data__c(VCC_Additional_Signer_IEN__c = '1234');
            vdifQueueableCallbackStub.setReturnValue('getStage', VCC_VdifQueueableCallback.Stage.ADD_SIGNERS);

            tt.text = testRunNote.testPatientMetadata.VCC_Additional_Signer_IEN__c;
            addSignersRS.taggedTextArray.count = 1;
            addSignersRS.taggedTextArray.results.taggedText.add(tt);

            testRunNote.onCalloutResponse(addSignersRS, vdifQueueableCallback);

            vdifQueueableCallbackStub.assertInvoked('getStage');
        }
        Test.stopTest();
    }

    @IsTest
    static void onCalloutSignNoteTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Stub vdifQueueableCallbackStub = new VCC_Stub(VCC_VdifQueueableCallback.class);
            VCC_VdifQueueableCallback vdifQueueableCallback = (VCC_VdifQueueableCallback) vdifQueueableCallbackStub.instance;
            VCC_VdifParameters vdifParameters = new VCC_VdifParameters();
            VCC_VdifTestRun_Note testRunNote = new VCC_VdifTestRun_Note();
            VCC_VdifSignNoteRS signNoteRS = new VCC_VdifSignNoteRS();
            signNoteRS.signNoteTextTO.text = 'OK';

            vdifQueueableCallbackStub.setReturnValue('getStage', VCC_VdifQueueableCallback.Stage.SIGN_NOTE);

            testRunNote.onCalloutResponse(signNoteRS, vdifQueueableCallback);

            vdifQueueableCallbackStub.assertInvoked('getStage');
        }
        Test.stopTest();
    }

    @IsTest
    static void onCalloutCreateAddendumTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Stub vdifQueueableCallbackStub = new VCC_Stub(VCC_VdifQueueableCallback.class);
            VCC_VdifQueueableCallback vdifQueueableCallback = (VCC_VdifQueueableCallback) vdifQueueableCallbackStub.instance;
            VCC_VdifParameters vdifParameters = new VCC_VdifParameters();
            VCC_VdifTestRun_Note testRunNote = new VCC_VdifTestRun_Note();
            VCC_VdifCreateAddendumRS createAddendumRS = new VCC_VdifCreateAddendumRS();

            vdifQueueableCallbackStub.setReturnValue('getStage', VCC_VdifQueueableCallback.Stage.CREATE_ADDENDUM);
            vdifQueueableCallbackStub.setReturnValue('getVdifParameters', vdifParameters);
            createAddendumRS.createAddendumTextTO.text = '2345';

            testRunNote.onCalloutResponse(createAddendumRS, vdifQueueableCallback);

            vdifQueueableCallbackStub.assertInvoked('getStage');
            vdifQueueableCallbackStub.assertInvoked('getVdifParameters');
            System.assert(vdifParameters.vdifNote.itemId == createAddendumRS.createAddendumTextTO.text, 'Expected item ids to match');
        }
        Test.stopTest();
    }

    @IsTest
    static void onCalloutWriteNoteTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Stub vdifQueueableCallbackStub = new VCC_Stub(VCC_VdifQueueableCallback.class);
            VCC_VdifQueueableCallback vdifQueueableCallback = (VCC_VdifQueueableCallback) vdifQueueableCallbackStub.instance;
            VCC_VdifParameters vdifParameters = new VCC_VdifParameters();
            VCC_VdifTestRun_Note testRunNote = new VCC_VdifTestRun_Note();
            VCC_VdifWriteNoteRS writeNoteRS = new VCC_VdifWriteNoteRS();

            vdifQueueableCallbackStub.setReturnValue('getStage', VCC_VdifQueueableCallback.Stage.WRITE_NOTE);
            vdifQueueableCallbackStub.setReturnValue('getVdifParameters', vdifParameters);
            writeNoteRS.noteResultTO.id = '2345';

            testRunNote.onCalloutResponse(writeNoteRS, vdifQueueableCallback);

            vdifQueueableCallbackStub.assertInvoked('getStage');
            vdifQueueableCallbackStub.assertInvoked('getVdifParameters');
            System.assert(vdifParameters.vdifNote.itemId == writeNoteRS.noteResultTO.id, 'Expected item ids to match');
        }
        Test.stopTest();
    }

    @IsTest
    static void onEndAddSigners() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Stub vdifQueueableCallbackStub = new VCC_Stub(VCC_VdifQueueableCallback.class);
            VCC_VdifQueueableCallback vdifQueueableCallback = (VCC_VdifQueueableCallback) vdifQueueableCallbackStub.instance;
            VCC_VdifTestRun_Note testRunNote = new VCC_VdifTestRun_Note();

            vdifQueueableCallbackStub.setReturnValue('getStage', VCC_VdifQueueableCallback.Stage.ADD_SIGNERS);
            vdifQueueableCallbackStub.setReturnValue('enqueueStage', null);

            testRunNote.onQueueableEnd(vdifQueueableCallback);

            vdifQueueableCallbackStub.assertInvoked('getStage');
            vdifQueueableCallbackStub.assertInvoked('enqueueStage');
            vdifQueueableCallbackStub.assertNotInvoked('getPreviousStage');
            System.assert(true, 'An assert.');
        }
        Test.stopTest();
    }

    @IsTest
    static void onEndValidateEsig() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Stub vdifQueueableCallbackStub = new VCC_Stub(VCC_VdifQueueableCallback.class);
            VCC_VdifQueueableCallback vdifQueueableCallback = (VCC_VdifQueueableCallback) vdifQueueableCallbackStub.instance;
            VCC_VdifTestRun_Note testRunNote = new VCC_VdifTestRun_Note();

            vdifQueueableCallbackStub.setReturnValue('getStage', VCC_VdifQueueableCallback.Stage.VALIDATE_ESIG);
            vdifQueueableCallbackStub.setReturnValue('enqueueStage', null);

            testRunNote.onQueueableEnd(vdifQueueableCallback);

            vdifQueueableCallbackStub.assertInvoked('getStage');
            vdifQueueableCallbackStub.assertInvoked('enqueueStage');
            vdifQueueableCallbackStub.assertNotInvoked('getPreviousStage');
            System.assert(true, 'An assert.');
        }
        Test.stopTest();
    }

    @IsTest
    static void onEndCreateAddendum() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Stub vdifQueueableCallbackStub = new VCC_Stub(VCC_VdifQueueableCallback.class);
            VCC_VdifQueueableCallback vdifQueueableCallback = (VCC_VdifQueueableCallback) vdifQueueableCallbackStub.instance;
            VCC_VdifTestRun_Note testRunNote = new VCC_VdifTestRun_Note();

            vdifQueueableCallbackStub.setReturnValue('getStage', VCC_VdifQueueableCallback.Stage.CREATE_ADDENDUM);
            vdifQueueableCallbackStub.setReturnValue('enqueueStage', null);

            testRunNote.onQueueableEnd(vdifQueueableCallback);

            vdifQueueableCallbackStub.assertInvoked('getStage');
            vdifQueueableCallbackStub.assertInvoked('enqueueStage');
            vdifQueueableCallbackStub.assertNotInvoked('getPreviousStage');
            System.assert(true, 'An assert.');
        }
        Test.stopTest();
    }

    @IsTest
    static void onEndCreateSignNote() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Stub vdifQueueableCallbackStub = new VCC_Stub(VCC_VdifQueueableCallback.class);
            VCC_VdifQueueableCallback vdifQueueableCallback = (VCC_VdifQueueableCallback) vdifQueueableCallbackStub.instance;
            VCC_VdifTestRun_Note testRunNote = new VCC_VdifTestRun_Note();

            vdifQueueableCallbackStub.setReturnValue('getStage', VCC_VdifQueueableCallback.Stage.SIGN_NOTE);
            vdifQueueableCallbackStub.setReturnValue('getPreviousStage', VCC_VdifQueueableCallback.Stage.ADD_SIGNERS);
            vdifQueueableCallbackStub.setReturnValue('enqueueStage', null);

            testRunNote.onQueueableEnd(vdifQueueableCallback);

            vdifQueueableCallbackStub.assertInvoked('getStage');
            vdifQueueableCallbackStub.assertInvoked('enqueueStage');
            vdifQueueableCallbackStub.assertInvoked('getPreviousStage');
            System.assert(true, 'An assert.');
        }
        Test.stopTest();
    }

    @IsTest
    static void onEndWriteNote() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Stub vdifQueueableCallbackStub = new VCC_Stub(VCC_VdifQueueableCallback.class);
            VCC_VdifQueueableCallback vdifQueueableCallback = (VCC_VdifQueueableCallback) vdifQueueableCallbackStub.instance;
            VCC_VdifTestRun_Note testRunNote = new VCC_VdifTestRun_Note();
            testRunNote.testPatientMetadata = new VCC_Test_Configuration_Data__c();

            vdifQueueableCallbackStub.setReturnValue('getStage', VCC_VdifQueueableCallback.Stage.WRITE_NOTE);
            vdifQueueableCallbackStub.setReturnValue('enqueueStage', null);

            testRunNote.onQueueableEnd(vdifQueueableCallback);
            testRunNote.testPatientMetadata = new VCC_Test_Configuration_Data__c(VCC_Additional_Signer_IEN__c = '1234');
            testRunNote.onQueueableEnd(vdifQueueableCallback);

            vdifQueueableCallbackStub.assertInvoked('getStage');
            vdifQueueableCallbackStub.assertInvoked('enqueueStage');
            vdifQueueableCallbackStub.assertNotInvoked('getPreviousStage');

            System.assert(true, 'An assert.');
        }
        Test.stopTest();
    }
}
