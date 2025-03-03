/**
 * @description Apex test class for the flow VCC Sign Note Subflow: DAS Resume Consolidated Endpoint Failure
 * @author      Booz Allen
 * @see         VCC_Sign_Note_Subflow_DAS_Resume_Consolidated_Endpoint_Failure
 * @see         VCC_DASFlowIsValidEsig
 * @see         VCC_DASFlowGetAdditionalSigners
 * @see         VCC_DASFlowSignNote
 */
@IsTest
private with sharing class VCC_DASSignNoteSubflowTest {
    private static VCC_Progress_Note__c createTestProgressNote(
        String caseRecordTypeApiName,
        String progressNoteRecordTypeApiName
    ) {
        Account testAccount = (Account) VATEST_SObjectFactory.createSObject(new Account());
        Case testCase = (Case) VATEST_SObjectFactory.createSObject(
            new Case(
                RecordTypeId = Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                    .getRecordTypeInfosByDeveloperName()
                    .get(caseRecordTypeApiName)
                    .getRecordTypeId(),
                AccountId = testAccount.Id
            )
        );
        VCC_Progress_Note__c testProgressNote = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
            new VCC_Progress_Note__c(
                VCC_Case__c = testCase.Id,
                RecordTypeId = VCC_Progress_Note__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                    .getRecordTypeInfosByDeveloperName()
                    .get(progressNoteRecordTypeApiName)
                    .getRecordTypeId()
            )
        );
        return testProgressNote;
    }

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
     * @description Tests the path for the isValidEsig apex action when the apex action returns a fault.
     */
    @IsTest
    private static void unitIsValidEsigFaultPathNegative() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            VCC_Progress_Note__c testProgressNote = createTestProgressNote(
                'VCC_Clinical_Triage',
                'VCC_Clinical_Triage_Note_Progress_Note'
            );

            // stub isValidEsig
            VCC_DASFlowIsValidEsig.Request isValidEsigRequest = new VCC_DASFlowIsValidEsig.Request();
            isValidEsigRequest.criteria = 'test';
            isValidEsigRequest.providerLoginSiteCode = '983';
            isValidEsigRequest.providerName = 'test';
            isValidEsigRequest.providerUserId = '000000';
            isValidEsigRequest.recordId = testProgressNote.Id;

            List<VCC_DASFlowIsValidEsig.Request> isValidEsigRequestList = new List<VCC_DASFlowIsValidEsig.Request>{
                isValidEsigRequest
            };

            VCC_DASFlowIsValidEsig isValidEsigStub = (VCC_DASFlowIsValidEsig) new VATEST_StubBuilder(
                    VCC_DASFlowIsValidEsig.class
                )
                .mockingMethodCall('isValidEsig', List<VCC_DASFlowIsValidEsig.Request>.class)
                .withParameterValues(isValidEsigRequestList)
                .throwingException()
                .mockingMethodCall('handleIsValidEsig', List<VCC_DASFlowIsValidEsig.Request>.class)
                .withParameterValues(isValidEsigRequestList)
                .throwingException()
                .defineStub();

            VCC_DASFlowIsValidEsig.flowIsValidEsigInstance = isValidEsigStub;

            // start flow
            VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams = new VCC_Vdif_NoteAndEncounterParams();
            VCC_Vdif_PatientAndProviderParams patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
            patientAndProviderParams.providerName = 'test';
            patientAndProviderParams.providerLoginSiteCode = '983';
            patientAndProviderParams.providerUserId = '000000';
            patientAndProviderParams.eSig = 'test';

            Flow.Interview signNoteSubflowInterview = Flow.Interview.createInterview(
                'VCC_Sign_Note_Subflow_DAS_Resume_Consolidated_Endpoint_Failure',
                new Map<String, Object>{
                    'errorCode' => 1500,
                    'isValidEsig' => false,
                    'ProgressNoteRecord_DAS' => testProgressNote,
                    'recordId' => testProgressNote.Id,
                    'recordTypeId' => testProgressNote.RecordTypeId,
                    'noteAndEncounterParams' => noteAndEncounterParams,
                    'patientAndProviderParams' => patientAndProviderParams
                }
            );

            signNoteSubflowInterview.start();

            // asserts
            Assert.isTrue(
                (Boolean) signNoteSubflowInterview.getVariableValue('faultFlag_DisplayFlowError'),
                'Expected flow output faultFlag_DisplayFlowError to be true since a fault occurred.'
            );
            Assert.isTrue(
                (Boolean) signNoteSubflowInterview.getVariableValue('faultOccurred'),
                'Expected flow output faultOccurred to be true since a fault occurred.'
            );
            Assert.isTrue(
                ((String) signNoteSubflowInterview.getVariableValue('faultMessage'))
                    .contains('An Apex error occurred:'),
                'Expected fault message to contain the message An Apex error occurred.'
            );

            Assert.isFalse(
                (Boolean) signNoteSubflowInterview.getVariableValue('faultFlag_RevalidateEsig'),
                'Expected flow output faultFlag_RevalidateEsig to be false since a fault occurred.'
            );
            Assert.isFalse(
                (Boolean) signNoteSubflowInterview.getVariableValue('signatureSuccessful'),
                'Expected signatureSuccessful to be false since a fault occurred.'
            );
        }
        Test.stopTest();
    }

    /**
     * @description Tests the path for isValidEsig apex action when apex action returns false.
     */
    @IsTest
    private static void unitIsValidEsigFalseNegative() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            VCC_Progress_Note__c testProgressNote = createTestProgressNote(
                'VCC_Clinical_Triage',
                'VCC_Clinical_Triage_Note_Progress_Note'
            );

            // stub isValidEsig apex action
            VCC_DASFlowIsValidEsig.Request isValidEsigRequest = new VCC_DASFlowIsValidEsig.Request();
            isValidEsigRequest.criteria = 'test';
            isValidEsigRequest.providerLoginSiteCode = '983';
            isValidEsigRequest.providerName = 'test';
            isValidEsigRequest.providerUserId = '000000';
            isValidEsigRequest.recordId = testProgressNote.Id;

            List<VCC_DASFlowIsValidEsig.Request> isValidEsigRequestList = new List<VCC_DASFlowIsValidEsig.Request>{
                isValidEsigRequest
            };
            VCC_DASIsValidEsigRS response = new VCC_DASIsValidEsigRS();
            VCC_DASFlowIsValidEsig.Result isValidEsigResult = new VCC_DASFlowIsValidEsig.Result(response);
            isValidEsigResult.isValid = false;
            List<VCC_DASFlowIsValidEsig.Result> isValidEsigResultList = new List<VCC_DASFlowIsValidEsig.Result>{
                isValidEsigResult
            };

            VCC_DASFlowIsValidEsig isValidEsigStub = (VCC_DASFlowIsValidEsig) new VATEST_StubBuilder(
                    VCC_DASFlowIsValidEsig.class
                )
                .mockingMethodCall('isValidEsig', List<VCC_DASFlowIsValidEsig.Request>.class)
                .withParameterValues(isValidEsigRequestList)
                .returning(isValidEsigResultList)
                .mockingMethodCall('handleIsValidEsig', List<VCC_DASFlowIsValidEsig.Request>.class)
                .withParameterValues(isValidEsigRequestList)
                .returning(isValidEsigResultList)
                .defineStub();

            VCC_DASFlowIsValidEsig.flowIsValidEsigInstance = isValidEsigStub;

            // start flow
            VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams = new VCC_Vdif_NoteAndEncounterParams();
            VCC_Vdif_PatientAndProviderParams patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
            patientAndProviderParams.providerName = 'test';
            patientAndProviderParams.providerLoginSiteCode = '983';
            patientAndProviderParams.providerUserId = '000000';
            patientAndProviderParams.eSig = 'test';

            Flow.Interview signNoteSubflowInterview = Flow.Interview.createInterview(
                'VCC_Sign_Note_Subflow_DAS_Resume_Consolidated_Endpoint_Failure',
                new Map<String, Object>{
                    'errorCode' => 1500,
                    'isValidEsig' => false,
                    'ProgressNoteRecord_DAS' => testProgressNote,
                    'recordId' => testProgressNote.Id,
                    'recordTypeId' => testProgressNote.RecordTypeId,
                    'noteAndEncounterParams' => noteAndEncounterParams,
                    'patientAndProviderParams' => patientAndProviderParams
                }
            );
            signNoteSubflowInterview.start();

            // asserts
            Assert.isTrue(
                (Boolean) signNoteSubflowInterview.getVariableValue('faultFlag_RevalidateEsig'),
                'Expected flow output faultFlag_RevalidateEsig to be true since esig apex action returned false.'
            );
            Assert.isTrue(
                (Boolean) signNoteSubflowInterview.getVariableValue('faultOccurred'),
                'Expected flow output faultOccurred to be false since no fault occurred.'
            );
            Assert.isNull(
                (String) signNoteSubflowInterview.getVariableValue('faultMessage'),
                'Expected flow output faultMessage to be null since no fault occurred.'
            );
            Assert.isFalse(
                (Boolean) signNoteSubflowInterview.getVariableValue('faultFlag_DisplayFlowError'),
                'Expected flow output faultFlag_DisplayFlowError to be false since no fault occurred.'
            );
            Assert.isFalse(
                (Boolean) signNoteSubflowInterview.getVariableValue('signatureSuccessful'),
                'Expected signatureSuccessful to be false since a fault occurred.'
            );
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitGetAdditionalSignersErrorCode1500Negative() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            VCC_Progress_Note__c testProgressNote = createTestProgressNote(
                'VCC_Clinical_Triage',
                'VCC_Clinical_Triage_Note_Progress_Note'
            );

            // stub for get signers apex action
            VCC_DASFlowGetAdditionalSigners.Request getSignersFlowRequest = new VCC_DASFlowGetAdditionalSigners.Request();
            getSignersFlowRequest.recordId = testProgressNote.Id;
            getSignersFlowRequest.providerName = 'test';
            getSignersFlowRequest.providerUserId = '000000';
            getSignersFlowRequest.providerLoginSiteCode = '983';
            getSignersFlowRequest.itemId = 'test';
            List<VCC_DASFlowGetAdditionalSigners.Request> getSignersRequest = new List<VCC_DASFlowGetAdditionalSigners.Request>{
                getSignersFlowRequest
            };

            VCC_DASFlowGetAdditionalSigners getSignersStub = (VCC_DASFlowGetAdditionalSigners) new VATEST_StubBuilder(
                    VCC_DASFlowGetAdditionalSigners.class
                )
                .mockingMethodCall('getAdditionalSigners', List<VCC_DASFlowGetAdditionalSigners.Request>.class)
                .withParameterValues(getSignersRequest)
                .throwingException()
                .mockingMethodCall(
                    'handleFlowGetAdditionalSigners',
                    List<VCC_DASFlowGetAdditionalSigners.Request>.class
                )
                .withParameterValues(getSignersRequest)
                .throwingException()
                .defineStub();

            VCC_DASFlowGetAdditionalSigners.flowGetAdditionalSignersInstance = getSignersStub;

            // start flow
            VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams = new VCC_Vdif_NoteAndEncounterParams();
            noteAndEncounterParams.itemId = 'test';
            VCC_Vdif_PatientAndProviderParams patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
            patientAndProviderParams.providerName = 'test';
            patientAndProviderParams.providerLoginSiteCode = '983';
            patientAndProviderParams.providerUserId = '000000';
            patientAndProviderParams.eSig = 'test';

            Flow.Interview signNoteSubflowInterview = Flow.Interview.createInterview(
                'VCC_Sign_Note_Subflow_DAS_Resume_Consolidated_Endpoint_Failure',
                new Map<String, Object>{
                    'errorCode' => 1500,
                    'isValidEsig' => true,
                    'ProgressNoteRecord_DAS' => testProgressNote,
                    'recordId' => testProgressNote.Id,
                    'recordTypeId' => testProgressNote.RecordTypeId,
                    'noteAndEncounterParams' => noteAndEncounterParams,
                    'patientAndProviderParams' => patientAndProviderParams
                }
            );
            signNoteSubflowInterview.start();

            // asserts
            Assert.isTrue(
                (Boolean) signNoteSubflowInterview.getVariableValue('faultFlag_DisplayFlowError'),
                'Expected flow output faultFlag_DisplayFlowError to be true since a fault occurred.'
            );
            Assert.isTrue(
                (Boolean) signNoteSubflowInterview.getVariableValue('faultOccurred'),
                'Expected flow output faultOccurred to be true since a fault occurred.'
            );
            Assert.isTrue(
                ((String) signNoteSubflowInterview.getVariableValue('faultMessage'))
                    .contains('An Apex error occurred:'),
                'Expected fault message to contain the message An Apex error occurred.'
            );
            Assert.isFalse(
                (Boolean) signNoteSubflowInterview.getVariableValue('signatureSuccessful'),
                'Expected signatureSuccessful to be false since a fault occurred.'
            );
            Assert.isFalse(
                (Boolean) signNoteSubflowInterview.getVariableValue('faultFlag_RevalidateEsig'),
                'Expected flow output faultFlag_RevalidateEsig to be false.'
            );
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitSignNoteErrorCode1600Negative() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            VCC_Progress_Note__c testProgressNote = createTestProgressNote(
                'VCC_Clinical_Triage',
                'VCC_Clinical_Triage_Note_Progress_Note'
            );

            // stub for signNote apex action
            VCC_DASFlowSignNote.Request signNoteFlowRequest = new VCC_DASFlowSignNote.Request();
            signNoteFlowRequest.recordId = testProgressNote.Id;
            signNoteFlowRequest.providerName = 'test';
            signNoteFlowRequest.providerUserId = '000000';
            signNoteFlowRequest.providerLoginSiteCode = '983';
            signNoteFlowRequest.esig = 'test';
            signNoteFlowRequest.noteIEN = 'test';
            List<VCC_DASFlowSignNote.Request> signNoteRequest = new List<VCC_DASFlowSignNote.Request>{
                signNoteFlowRequest
            };

            VCC_DASFlowSignNote signNoteStub = (VCC_DASFlowSignNote) new VATEST_StubBuilder(VCC_DASFlowSignNote.class)
                .mockingMethodCall('signNote', List<VCC_DASFlowSignNote.Request>.class)
                .withParameterValues(signNoteRequest)
                .throwingException()
                .mockingMethodCall('handleSignNote', List<VCC_DASFlowSignNote.Request>.class)
                .withParameterValues(signNoteRequest)
                .throwingException()
                .defineStub();

            VCC_DASFlowSignNote.flowSignNoteInstance = signNoteStub;

            // start flow
            VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams = new VCC_Vdif_NoteAndEncounterParams();
            noteAndEncounterParams.itemId = 'test';
            noteAndEncounterParams.noteAndEncounterNoteTitleIen = 'test';
            VCC_Vdif_PatientAndProviderParams patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
            patientAndProviderParams.providerName = 'test';
            patientAndProviderParams.providerLoginSiteCode = '983';
            patientAndProviderParams.providerUserId = '000000';
            patientAndProviderParams.eSig = 'test';

            Flow.Interview signNoteSubflowInterview = Flow.Interview.createInterview(
                'VCC_Sign_Note_Subflow_DAS_Resume_Consolidated_Endpoint_Failure',
                new Map<String, Object>{
                    'errorCode' => 1600,
                    'isValidEsig' => true,
                    'ProgressNoteRecord_DAS' => testProgressNote,
                    'recordId' => testProgressNote.Id,
                    'recordTypeId' => testProgressNote.RecordTypeId,
                    'noteAndEncounterParams' => noteAndEncounterParams,
                    'patientAndProviderParams' => patientAndProviderParams
                }
            );
            signNoteSubflowInterview.start();

            // asserts
            Assert.isTrue(
                (Boolean) signNoteSubflowInterview.getVariableValue('faultFlag_DisplayFlowError'),
                'Expected flow output faultFlag_DisplayFlowError to be true since a fault occurred.'
            );
            Assert.isTrue(
                (Boolean) signNoteSubflowInterview.getVariableValue('faultOccurred'),
                'Expected flow output faultOccurred to be true since a fault occurred.'
            );
            Assert.isTrue(
                ((String) signNoteSubflowInterview.getVariableValue('faultMessage'))
                    .contains('An Apex error occurred:'),
                'Expected fault message to contain the message An Apex error occurred since a fault occurred.'
            );
            Assert.isFalse(
                (Boolean) signNoteSubflowInterview.getVariableValue('signatureSuccessful'),
                'Expected signatureSuccessful to be false since a fault occurred.'
            );
            Assert.isFalse(
                (Boolean) signNoteSubflowInterview.getVariableValue('faultFlag_RevalidateEsig'),
                'Expected flow output faultFlag_RevalidateEsig to be false.'
            );
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitSignNoteErrorCode1800Negative() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            VCC_Progress_Note__c testProgressNote = createTestProgressNote(
                'VCC_Clinical_Triage',
                'VCC_Clinical_Triage_Note_Progress_Note'
            );

            // stub for signNote apex action
            VCC_DASFlowSignNote.Request signNoteFlowRequest = new VCC_DASFlowSignNote.Request();
            signNoteFlowRequest.recordId = testProgressNote.Id;
            signNoteFlowRequest.providerName = 'test';
            signNoteFlowRequest.providerUserId = '000000';
            signNoteFlowRequest.providerLoginSiteCode = '983';
            signNoteFlowRequest.esig = 'test';
            signNoteFlowRequest.noteIEN = 'test';
            List<VCC_DASFlowSignNote.Request> signNoteRequest = new List<VCC_DASFlowSignNote.Request>{
                signNoteFlowRequest
            };

            VCC_DASFlowSignNote signNoteStub = (VCC_DASFlowSignNote) new VATEST_StubBuilder(VCC_DASFlowSignNote.class)
                .mockingMethodCall('signNote', List<VCC_DASFlowSignNote.Request>.class)
                .withParameterValues(signNoteRequest)
                .throwingException()
                .mockingMethodCall('handleSignNote', List<VCC_DASFlowSignNote.Request>.class)
                .withParameterValues(signNoteRequest)
                .throwingException()
                .defineStub();

            VCC_DASFlowSignNote.flowSignNoteInstance = signNoteStub;

            // start flow
            VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams = new VCC_Vdif_NoteAndEncounterParams();
            noteAndEncounterParams.itemId = 'test';
            noteAndEncounterParams.noteAndEncounterNoteTitleIen = 'test';
            VCC_Vdif_PatientAndProviderParams patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
            patientAndProviderParams.providerName = 'test';
            patientAndProviderParams.providerLoginSiteCode = '983';
            patientAndProviderParams.providerUserId = '000000';
            patientAndProviderParams.eSig = 'test';

            Flow.Interview signNoteSubflowInterview = Flow.Interview.createInterview(
                'VCC_Sign_Note_Subflow_DAS_Resume_Consolidated_Endpoint_Failure',
                new Map<String, Object>{
                    'errorCode' => 1800,
                    'isValidEsig' => true,
                    'ProgressNoteRecord_DAS' => testProgressNote,
                    'recordId' => testProgressNote.Id,
                    'recordTypeId' => testProgressNote.RecordTypeId,
                    'noteAndEncounterParams' => noteAndEncounterParams,
                    'patientAndProviderParams' => patientAndProviderParams
                }
            );
            signNoteSubflowInterview.start();

            // asserts
            Assert.isTrue(
                (Boolean) signNoteSubflowInterview.getVariableValue('faultFlag_DisplayFlowError'),
                'Expected flow output faultFlag_DisplayFlowError to be true since a fault occurred.'
            );
            Assert.isTrue(
                (Boolean) signNoteSubflowInterview.getVariableValue('faultOccurred'),
                'Expected flow output faultOccurred to be true since a fault occurred.'
            );
            Assert.isTrue(
                ((String) signNoteSubflowInterview.getVariableValue('faultMessage'))
                    .contains('An Apex error occurred:'),
                'Expected fault message to contain the message An Apex error occurred since a fault occurred.'
            );
            Assert.isFalse(
                (Boolean) signNoteSubflowInterview.getVariableValue('signatureSuccessful'),
                'Expected signatureSuccessful to be false since a fault occurred.'
            );
            Assert.isFalse(
                (Boolean) signNoteSubflowInterview.getVariableValue('faultFlag_RevalidateEsig'),
                'Expected flow output faultFlag_RevalidateEsig to be false.'
            );
        }
        Test.stopTest();
    }

    @IsTest
    private static void funcValidateEsigPositiveThenGetAdditionalSignersPostiveThenSignNotePositive() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            VCC_Progress_Note__c testProgressNote = createTestProgressNote(
                'VCC_Clinical_Triage',
                'VCC_Clinical_Triage_Note_Progress_Note'
            );

            // stub isValidEsig apex action
            VCC_DASFlowIsValidEsig.Request isValidEsigRequest = new VCC_DASFlowIsValidEsig.Request();
            isValidEsigRequest.criteria = 'test';
            isValidEsigRequest.providerLoginSiteCode = '983';
            isValidEsigRequest.providerName = 'test';
            isValidEsigRequest.providerUserId = '000000';
            isValidEsigRequest.recordId = testProgressNote.Id;

            List<VCC_DASFlowIsValidEsig.Request> isValidEsigRequestList = new List<VCC_DASFlowIsValidEsig.Request>{
                isValidEsigRequest
            };
            VCC_DASIsValidEsigRS response = new VCC_DASIsValidEsigRS();

            VCC_DASFlowIsValidEsig.Result isValidEsigResult = new VCC_DASFlowIsValidEsig.Result(response);
            isValidEsigResult.isValid = true;

            List<VCC_DASFlowIsValidEsig.Result> isValidEsigResultList = new List<VCC_DASFlowIsValidEsig.Result>{
                isValidEsigResult
            };

            VCC_DASFlowIsValidEsig isValidEsigStub = (VCC_DASFlowIsValidEsig) new VATEST_StubBuilder(
                    VCC_DASFlowIsValidEsig.class
                )
                .mockingMethodCall('isValidEsig', List<VCC_DASFlowIsValidEsig.Request>.class)
                .withParameterValues(isValidEsigRequestList)
                .returning(isValidEsigResultList)
                .mockingMethodCall('handleIsValidEsig', List<VCC_DASFlowIsValidEsig.Request>.class)
                .withParameterValues(isValidEsigRequestList)
                .returning(isValidEsigResultList)
                .defineStub();

            VCC_DASFlowIsValidEsig.flowIsValidEsigInstance = isValidEsigStub;

            // stub getSigners apex action
            VCC_DASFlowGetAdditionalSigners.Request getSignersFlowRequest = new VCC_DASFlowGetAdditionalSigners.Request();
            getSignersFlowRequest.recordId = testProgressNote.Id;
            getSignersFlowRequest.providerName = 'test';
            getSignersFlowRequest.providerUserId = '000000';
            getSignersFlowRequest.providerLoginSiteCode = '983';
            getSignersFlowRequest.itemId = 'test';
            List<VCC_DASFlowGetAdditionalSigners.Request> getSignersRequest = new List<VCC_DASFlowGetAdditionalSigners.Request>{
                getSignersFlowRequest
            };
            VCC_DASGetAdditionalSignersRS getSignersRS = new VCC_DASGetAdditionalSignersRS();
            VCC_DASFlowGetAdditionalSigners.Result getSignersFlowResult = new VCC_DASFlowGetAdditionalSigners.Result(
                getSignersRS
            );
            List<VCC_DASFlowGetAdditionalSigners.Result> getSignersResult = new List<VCC_DASFlowGetAdditionalSigners.Result>{
                getSignersFlowResult
            };
            VCC_DASFlowGetAdditionalSigners getSignersStub = (VCC_DASFlowGetAdditionalSigners) new VATEST_StubBuilder(
                    VCC_DASFlowGetAdditionalSigners.class
                )
                .mockingMethodCall('getAdditionalSigners', List<VCC_DASFlowGetAdditionalSigners.Request>.class)
                .withParameterValues(getSignersRequest)
                .returning(getSignersResult)
                .mockingMethodCall(
                    'handleFlowGetAdditionalSigners',
                    List<VCC_DASFlowGetAdditionalSigners.Request>.class
                )
                .withParameterValues(getSignersRequest)
                .returning(getSignersResult)
                .defineStub();
            VCC_DASFlowGetAdditionalSigners.flowGetAdditionalSignersInstance = getSignersStub;

            // stub signNote apex action
            VCC_DASFlowSignNote.Request signNoteFlowRequest = new VCC_DASFlowSignNote.Request();
            signNoteFlowRequest.recordId = testProgressNote.Id;
            signNoteFlowRequest.providerName = 'test';
            signNoteFlowRequest.providerUserId = '000000';
            signNoteFlowRequest.providerLoginSiteCode = '983';
            signNoteFlowRequest.esig = 'test';
            signNoteFlowRequest.noteIEN = 'test';
            List<VCC_DASFlowSignNote.Request> signNoteRequest = new List<VCC_DASFlowSignNote.Request>{
                signNoteFlowRequest
            };
            VCC_DASFlowSignNote.Result signNoteFlowResult = new VCC_DASFlowSignNote.Result(new VCC_DASSignNoteRS());
            List<VCC_DASFlowSignNote.Result> signNoteResult = new List<VCC_DASFlowSignNote.Result>{
                signNoteFlowResult
            };
            VCC_DASFlowSignNote signNoteStub = (VCC_DASFlowSignNote) new VATEST_StubBuilder(VCC_DASFlowSignNote.class)
                .mockingMethodCall('signNote', List<VCC_DASFlowSignNote.Request>.class)
                .withParameterValues(signNoteRequest)
                .returning(signNoteResult)
                .mockingMethodCall('handleSignNote', List<VCC_DASFlowSignNote.Request>.class)
                .withParameterValues(signNoteRequest)
                .returning(signNoteResult)
                .defineStub();
            VCC_DASFlowSignNote.flowSignNoteInstance = signNoteStub;

            // start flow
            VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams = new VCC_Vdif_NoteAndEncounterParams();
            noteAndEncounterParams.itemId = 'test';
            noteAndEncounterParams.noteAndEncounterNoteTitleIen = 'test';
            VCC_Vdif_PatientAndProviderParams patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
            patientAndProviderParams.providerName = 'test';
            patientAndProviderParams.providerLoginSiteCode = '983';
            patientAndProviderParams.providerUserId = '000000';
            patientAndProviderParams.eSig = 'test';

            Flow.Interview signNoteSubflowInterview = Flow.Interview.createInterview(
                'VCC_Sign_Note_Subflow_DAS_Resume_Consolidated_Endpoint_Failure',
                new Map<String, Object>{
                    'errorCode' => 1500,
                    'isValidEsig' => false,
                    'ProgressNoteRecord_DAS' => testProgressNote,
                    'recordId' => testProgressNote.Id,
                    'recordTypeId' => testProgressNote.RecordTypeId,
                    'noteAndEncounterParams' => noteAndEncounterParams,
                    'patientAndProviderParams' => patientAndProviderParams
                }
            );
            signNoteSubflowInterview.start();

            // asserts
            Assert.isFalse(
                (Boolean) signNoteSubflowInterview.getVariableValue('faultFlag_DisplayFlowError'),
                'Expected flow output faultFlag_DisplayFlowError to be false.'
            );
            Assert.isFalse(
                (Boolean) signNoteSubflowInterview.getVariableValue('faultFlag_RevalidateEsig'),
                'Expected flow output faultFlag_RevalidateEsig to be false.'
            );
            Assert.isFalse(
                (Boolean) signNoteSubflowInterview.getVariableValue('faultOccurred'),
                'Expected flow output faultOccurred to be false since no failures or faults occurred.'
            );
            Assert.isNull(
                (String) signNoteSubflowInterview.getVariableValue('faultMessage'),
                'Expected faultMessage output to be null since no failures or faults occurred.'
            );
            Assert.isTrue(
                (Boolean) signNoteSubflowInterview.getVariableValue('signatureSuccessful'),
                'Expected signatureSuccessful to be true since no failures or faults occurred.'
            );
        }
        Test.stopTest();
    }

    @IsTest
    private static void funcValidateEsigPositiveThenGetAdditionalSignersPositiveThenSignNoteNegative() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            VCC_Progress_Note__c testProgressNote = createTestProgressNote(
                'VCC_Clinical_Triage',
                'VCC_Clinical_Triage_Note_Progress_Note'
            );

            // stub isValidEsig apex action
            VCC_DASFlowIsValidEsig.Request isValidEsigRequest = new VCC_DASFlowIsValidEsig.Request();
            isValidEsigRequest.criteria = 'test';
            isValidEsigRequest.providerLoginSiteCode = '983';
            isValidEsigRequest.providerName = 'test';
            isValidEsigRequest.providerUserId = '000000';
            isValidEsigRequest.recordId = testProgressNote.Id;

            List<VCC_DASFlowIsValidEsig.Request> isValidEsigRequestList = new List<VCC_DASFlowIsValidEsig.Request>{
                isValidEsigRequest
            };
            VCC_DASIsValidEsigRS response = new VCC_DASIsValidEsigRS();
            VCC_DASFlowIsValidEsig.Result isValidEsigResult = new VCC_DASFlowIsValidEsig.Result(response);
            isValidEsigResult.isValid = true;
            List<VCC_DASFlowIsValidEsig.Result> isValidEsigResultList = new List<VCC_DASFlowIsValidEsig.Result>{
                isValidEsigResult
            };

            VCC_DASFlowIsValidEsig isValidEsigStub = (VCC_DASFlowIsValidEsig) new VATEST_StubBuilder(
                    VCC_DASFlowIsValidEsig.class
                )
                .mockingMethodCall('isValidEsig', List<VCC_DASFlowIsValidEsig.Request>.class)
                .withParameterValues(isValidEsigRequestList)
                .returning(isValidEsigResultList)
                .mockingMethodCall('handleIsValidEsig', List<VCC_DASFlowIsValidEsig.Request>.class)
                .withParameterValues(isValidEsigRequestList)
                .returning(isValidEsigResultList)
                .defineStub();

            VCC_DASFlowIsValidEsig.flowIsValidEsigInstance = isValidEsigStub;

            // stub getSigners apex action
            VCC_DASFlowGetAdditionalSigners.Request getSignersFlowRequest = new VCC_DASFlowGetAdditionalSigners.Request();
            getSignersFlowRequest.recordId = testProgressNote.Id;
            getSignersFlowRequest.providerName = 'test';
            getSignersFlowRequest.providerUserId = '000000';
            getSignersFlowRequest.providerLoginSiteCode = '983';
            getSignersFlowRequest.itemId = 'test';
            List<VCC_DASFlowGetAdditionalSigners.Request> getSignersRequest = new List<VCC_DASFlowGetAdditionalSigners.Request>{
                getSignersFlowRequest
            };
            VCC_DASGetAdditionalSignersRS getSignersRS = new VCC_DASGetAdditionalSignersRS();
            VCC_DASFlowGetAdditionalSigners.Result getSignersFlowResult = new VCC_DASFlowGetAdditionalSigners.Result(
                getSignersRS
            );
            List<VCC_DASFlowGetAdditionalSigners.Result> getSignersResult = new List<VCC_DASFlowGetAdditionalSigners.Result>{
                getSignersFlowResult
            };
            VCC_DASFlowGetAdditionalSigners getSignersStub = (VCC_DASFlowGetAdditionalSigners) new VATEST_StubBuilder(
                    VCC_DASFlowGetAdditionalSigners.class
                )
                .mockingMethodCall('getAdditionalSigners', List<VCC_DASFlowGetAdditionalSigners.Request>.class)
                .withParameterValues(getSignersRequest)
                .returning(getSignersResult)
                .mockingMethodCall(
                    'handleFlowGetAdditionalSigners',
                    List<VCC_DASFlowGetAdditionalSigners.Request>.class
                )
                .withParameterValues(getSignersRequest)
                .returning(getSignersResult)
                .defineStub();
            VCC_DASFlowGetAdditionalSigners.flowGetAdditionalSignersInstance = getSignersStub;

            // stub signNote apex action
            VCC_DASFlowSignNote.Request signNoteFlowRequest = new VCC_DASFlowSignNote.Request();
            signNoteFlowRequest.recordId = testProgressNote.Id;
            signNoteFlowRequest.providerName = 'test';
            signNoteFlowRequest.providerUserId = '000000';
            signNoteFlowRequest.providerLoginSiteCode = '983';
            signNoteFlowRequest.esig = 'test';
            signNoteFlowRequest.noteIEN = 'test';
            List<VCC_DASFlowSignNote.Request> signNoteRequest = new List<VCC_DASFlowSignNote.Request>{
                signNoteFlowRequest
            };

            VCC_DASFlowSignNote signNoteStub = (VCC_DASFlowSignNote) new VATEST_StubBuilder(VCC_DASFlowSignNote.class)
                .mockingMethodCall('signNote', List<VCC_DASFlowSignNote.Request>.class)
                .withParameterValues(signNoteRequest)
                .throwingException()
                .mockingMethodCall('handleSignNote', List<VCC_DASFlowSignNote.Request>.class)
                .withParameterValues(signNoteRequest)
                .throwingException()
                .defineStub();

            VCC_DASFlowSignNote.flowSignNoteInstance = signNoteStub;

            // start flow
            VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams = new VCC_Vdif_NoteAndEncounterParams();
            noteAndEncounterParams.itemId = 'test';
            noteAndEncounterParams.noteAndEncounterNoteTitleIen = 'test';
            VCC_Vdif_PatientAndProviderParams patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
            patientAndProviderParams.providerName = 'test';
            patientAndProviderParams.providerLoginSiteCode = '983';
            patientAndProviderParams.providerUserId = '000000';
            patientAndProviderParams.eSig = 'test';

            Flow.Interview signNoteSubflowInterview = Flow.Interview.createInterview(
                'VCC_Sign_Note_Subflow_DAS_Resume_Consolidated_Endpoint_Failure',
                new Map<String, Object>{
                    'errorCode' => 1500,
                    'isValidEsig' => false,
                    'ProgressNoteRecord_DAS' => testProgressNote,
                    'recordId' => testProgressNote.Id,
                    'recordTypeId' => testProgressNote.RecordTypeId,
                    'noteAndEncounterParams' => noteAndEncounterParams,
                    'patientAndProviderParams' => patientAndProviderParams
                }
            );
            signNoteSubflowInterview.start();

            // asserts
            Assert.isTrue(
                (Boolean) signNoteSubflowInterview.getVariableValue('faultFlag_DisplayFlowError'),
                'Expected flow output faultFlag_DisplayFlowError to be true since a fault occurred.'
            );
            Assert.isFalse(
                (Boolean) signNoteSubflowInterview.getVariableValue('faultFlag_RevalidateEsig'),
                'Expected flow output faultFlag_RevalidateEsig to be false.'
            );
            Assert.isTrue(
                (Boolean) signNoteSubflowInterview.getVariableValue('faultOccurred'),
                'Expected flow output faultOccurred to be true since faults occurred during the sign note apex action.'
            );
            Assert.isTrue(
                ((String) signNoteSubflowInterview.getVariableValue('faultMessage'))
                    .contains('An Apex error occurred:'),
                'Expected fault message to contain the message An Apex error occurred since a fault occurred.'
            );
            Assert.isFalse(
                (Boolean) signNoteSubflowInterview.getVariableValue('signatureSuccessful'),
                'Expected signatureSuccessful to be true since a fault occurred.'
            );
        }
        Test.stopTest();
    }
}
