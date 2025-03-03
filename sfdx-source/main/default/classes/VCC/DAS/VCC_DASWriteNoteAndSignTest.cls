/**
 * @description Test class for the VCC_Sign_Note_Subflow_DAS_Write_Note_And_Sign flow.
 * @see VCC_Sign_Note_Subflow_DAS_Write_Note_And_Sign
 * @see VCC_DASFlowGenerateEncounterString
 * @see    VCC_DASFlowSaveNoteAndEncounter
 * @see    VCC_DASFlowWriteNoteAndSign
 */
@IsTest
private with sharing class VCC_DASWriteNoteAndSignTest {
    private static final User VCC_TESTUSER = createTestRNUser();

    private static VCC_Progress_Note__c createTestProgressNote(
        String caseRecordTypeApiName,
        String progressNoteRecordTypeApiName
    ) {
        Account testAccount = (Account) VATEST_SObjectFactory.createSObject(new Account());

        Case testCase = (Case) VATEST_SObjectFactory.createSObject(
            new Case(
                RecordTypeId = new VCR_CaseRepo().recordTypeConstant.fromDeveloperName(caseRecordTypeApiName).Id,
                AccountId = testAccount.Id
            )
        );

        VCC_Progress_Note__c testProgressNote = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
            new VCC_Progress_Note__c(
                VCC_Case__c = testCase.Id,
                RecordTypeId = new VCR_CaseRepo().recordTypeConstant.fromDeveloperName(caseRecordTypeApiName).Id
            )
        );
        return testProgressNote;
    }

    /**
     * @description Creates test RN user to use to run the flow tests
     * @return `User`
     */
    private static User createTestRNUser() {
        return VATEST_UserFactory.create(VATEST_UserPersonaEnum.Nurse, true);
    }

    private static VCC_Vdif_NoteAndEncounterParams createNoteAndEncounterParams() {
        VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams = new VCC_Vdif_NoteAndEncounterParams();
        noteAndEncounterParams.encounterString = 'testEncounterString';
        noteAndEncounterParams.noteAndEncounterNoteTitleIen = 'test';
        CodeSet codeSetTest = new CodeSet(Code = 'TST.33', Name = 'TST.33', CodeSetType = 'Diagnosis (ICD10)');
        noteAndEncounterParams.primaryDiagnosis = codeSetTest;
        noteAndEncounterParams.procedureCode = codeSetTest;
        noteAndEncounterParams.secondaryDiagnosis = codeSetTest;
        noteAndEncounterParams.noteAndEncounterVisitRelatedTos = 'test';
        noteAndEncounterParams.noteAndEncounterLocationIen = '1234';
        return noteAndEncounterParams;
    }
    private static VCC_Vdif_PatientAndProviderParams createPatientAndProviderParams() {
        VCC_Vdif_PatientAndProviderParams patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
        patientAndProviderParams.eSig = 'eSig test';
        patientAndProviderParams.patientLocalPid = 1;
        patientAndProviderParams.patientLocalSiteId = '123';
        patientAndProviderParams.providerLoginSiteCode = '983';
        patientAndProviderParams.providerUserId = '000000';
        patientAndProviderParams.authorDUZ = 'test';
        return patientAndProviderParams;
    }

    private static VCC_DASFlowSaveNoteAndEncounter.Request saveNoteAndEncounterRequest() {
        VCC_Vdif_PatientAndProviderParams patientAndProviderParams = createPatientAndProviderParams();
        patientAndProviderParams.patientName = 'Test Patient Name';
        VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams = createNoteAndEncounterParams();
        VCC_DASFlowSaveNoteAndEncounter.Request saveNoteAndEncounterRequest = new VCC_DASFlowSaveNoteAndEncounter.Request();

        saveNoteAndEncounterRequest.providerUserId = patientAndProviderParams.providerUserId;
        saveNoteAndEncounterRequest.patientLocalPid = String.valueOf(patientAndProviderParams.patientLocalPid);
        saveNoteAndEncounterRequest.patientLocalSiteId = patientAndProviderParams.patientLocalSiteId;
        saveNoteAndEncounterRequest.noteAndEncounterLocationIen = noteAndEncounterParams.noteAndEncounterLocationIen;
        saveNoteAndEncounterRequest.noteAndEncounterNoteTitleIen = noteAndEncounterParams.noteAndEncounterNoteTitleIen;
        saveNoteAndEncounterRequest.noteAndEncounterVisitRelatedTos = noteAndEncounterParams.noteAndEncounterVisitRelatedTos;
        saveNoteAndEncounterRequest.patientName = patientAndProviderParams.patientName;
        saveNoteAndEncounterRequest.procedureCode = noteAndEncounterParams.procedureCode;
        saveNoteAndEncounterRequest.secondaryDiagnosis = noteAndEncounterParams.secondaryDiagnosis;
        saveNoteAndEncounterRequest.primaryDiagnosis = noteAndEncounterParams.primaryDiagnosis;
        return saveNoteAndEncounterRequest;
    }

    private static VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest writeNoteAndSignRequest() {
        VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest writeNoteAndSignRequest = new VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest();
        VCC_Vdif_PatientAndProviderParams patientAndProviderParams = createPatientAndProviderParams();
        VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams = createNoteAndEncounterParams();

        writeNoteAndSignRequest.titleIEN = noteAndEncounterParams.noteAndEncounterNoteTitleIen;
        writeNoteAndSignRequest.encounterString = noteAndEncounterParams.encounterString;
        writeNoteAndSignRequest.authorDUZ = patientAndProviderParams.authorDUZ;
        writeNoteAndSignRequest.esig = patientAndProviderParams.eSig;
        writeNoteAndSignRequest.providerLoginSiteCode = patientAndProviderParams.providerLoginSiteCode;
        writeNoteAndSignRequest.providerUserId = patientAndProviderParams.providerUserId;
        writeNoteAndSignRequest.patientLocalPid = String.valueOf(patientAndProviderParams.patientLocalPid);
        writeNoteAndSignRequest.patientLocalSiteId = patientAndProviderParams.patientLocalSiteId;
        return writeNoteAndSignRequest;
    }

    /**
     * @description Test the VCC Sign Note Subflow: DAS Write Note And Sign
     *              Verifies the path
     *              is Encounterable -> null
     */
    @IsTest
    static void unitIsEncounterableNegative() {
        Map<String, Object> params = new Map<String, Object>();
        params.put('isEncounterable', null);

        Flow.Interview writeNoteAndSignSubflow = Flow.Interview.createInterview(
            'VCC_Sign_Note_Subflow_DAS_Write_Note_And_Sign',
            params
        );
        Test.startTest();
        System.runAs(VCC_TESTUSER) {
            writeNoteAndSignSubflow.start();

            Assert.isNotNull(
                (String) writeNoteAndSignSubflow.getVariableValue('faultMessage'),
                'Expected faultMessage to be not null since isEncounterable is null.'
            );
            Assert.isTrue(
                (Boolean) writeNoteAndSignSubflow.getVariableValue('faultOccurred'),
                'Expected faultOccurred to be true since fault occurred on isEncounterable.'
            );
            Assert.isTrue(
                (Boolean) writeNoteAndSignSubflow.getVariableValue('faultFlag_DisplayFlowError'),
                'Expected faultFlag_DisplayFlowError to be true since isEncounterable was null.'
            );
            Assert.isNull(
                (Boolean) writeNoteAndSignSubflow.getVariableValue('isEncounterable'),
                'Expected isEncounterable to be null since we set it that way in the params to test the Unable to Determine path.'
            );
        }
        Test.stopTest();
    }

    /**
     * @description Test the VCC Sign Note Subflow: DAS Write Note And Sign
     *              Verifies the path
     *              is Encounterable -> No -> Invoke Generate Encounter String Apex Action -> fault -> Set faultMessage for Generate Encounter String
     */
    @IsTest
    static void unitInvokeGenerateEncounterStringApexActionFaultNegative() {
        String progressNoteID = VATEST_IdFactory.get('VCC_Progress_Note__c');
        VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams = createNoteAndEncounterParams();
        VCC_DASFlowGenerateEncounterString.Request request = new VCC_DASFlowGenerateEncounterString.Request();
        request.noteAndEncounterParameters = noteAndEncounterParams;

        List<VCC_DASFlowGenerateEncounterString.Request> requestList = new List<VCC_DASFlowGenerateEncounterString.Request>{
            request
        };
        VCC_DASFlowGenerateEncounterString generateEncounterStringStub = (VCC_DASFlowGenerateEncounterString) new VATEST_StubBuilder(
                VCC_DASFlowGenerateEncounterString.class
            )
            .mockingMethodCall(
                'handleFlowGenerateEncounterString',
                new List<System.Type>{ List<VCC_DASFlowGenerateEncounterString.Request>.class }
            )
            .withParameterTypes()
            .withParameterValues(requestList)
            .throwingException()
            .defineStub();

        VCC_DASFlowGenerateEncounterString.flowGenerateEncounterStringInstance = generateEncounterStringStub;

        Map<String, Object> params = new Map<String, Object>();
        params.put('isEncounterable', false);
        params.put('ProgressNoteRecord_DAS', new VCC_Progress_Note__c(Id = progressNoteID));
        params.put('noteAndEncounterParams', noteAndEncounterParams);

        Test.startTest();
        System.runAs(VCC_TESTUSER) {
            Flow.Interview writeNoteAndSignSubflow = Flow.Interview.createInterview(
                'VCC_Sign_Note_Subflow_DAS_Write_Note_And_Sign',
                params
            );
            writeNoteAndSignSubflow.start();
            Assert.isTrue(
                ((String) writeNoteAndSignSubflow.getVariableValue('faultMessage')).contains('An Apex error occurred:'),
                'Expected fault message to contain the message, "An Apex Error Occurred" since we are throwing an exception'
            );
            Assert.isTrue(
                (Boolean) writeNoteAndSignSubflow.getVariableValue('faultFlag_DisplayFlowError'),
                'Expected faultFlag_DisplayFlowError to be true since there was an exception.'
            );
            Assert.isFalse(
                (Boolean) writeNoteAndSignSubflow.getVariableValue('isEncounterable'),
                'Expected isEncounterable to be false since we set it to false in the params.'
            );
        }
        Test.stopTest();
    }

    /**
     * @description Test the VCC Sign Note Subflow: DAS Write Note And Sign
     *              Verifies the path
     *              is Encounterable -> No -> Invoke Generate Encounter String Apex Action -> Set encounterString for Generate Encounter String
     *               -> Set noteAndEncounterParams ->  Invoke Write note and Sign Apex Action -> fault
     */
    @IsTest
    static void funcInvokeWriteNoteAndSignApexActionFaultNegative() {
        System.runAs(VCC_TESTUSER) {
            VCC_Progress_Note__c testProgressNote = createTestProgressNote(
                'VCC_Clinical_Triage',
                'VCC_Clinical_Triage_Note_Progress_Note'
            );
            VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams = createNoteAndEncounterParams();
            VCC_Vdif_PatientAndProviderParams patientAndProviderParams = createPatientAndProviderParams();

            //stub generate encounter string apex action
            VCC_DASFlowGenerateEncounterString.Request generateEncounterStringRequest = new VCC_DASFlowGenerateEncounterString.Request();
            generateEncounterStringRequest.noteAndEncounterParameters = noteAndEncounterParams;

            List<VCC_DASFlowGenerateEncounterString.Request> generateEncounterStringRequestList = new List<VCC_DASFlowGenerateEncounterString.Request>{
                generateEncounterStringRequest
            };

            VCC_DASFlowGenerateEncounterString.Result generateEncounterStringResult = new VCC_DASFlowGenerateEncounterString.Result(
                noteAndEncounterParams.encounterString
            );

            List<VCC_DASFlowGenerateEncounterString.Result> generateEncounterStringResultList = new List<VCC_DASFlowGenerateEncounterString.Result>{
                generateEncounterStringResult
            };

            VCC_DASFlowGenerateEncounterString generateEncounterStringStub = (VCC_DASFlowGenerateEncounterString) new VATEST_StubBuilder(
                    VCC_DASFlowGenerateEncounterString.class
                )
                .mockingMethodCall(
                    'handleFlowGenerateEncounterString',
                    List<VCC_DASFlowGenerateEncounterString.Request>.class
                )
                .withParameterValues(generateEncounterStringRequestList)
                .returning(generateEncounterStringResultList)
                .defineStub();

            VCC_DASFlowGenerateEncounterString.flowGenerateEncounterStringInstance = generateEncounterStringStub;
            //Stub Write Note And Sign Apex Action
            VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest writeNoteAndSignRequest = writeNoteAndSignRequest();

            List<VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest> writeNoteAndSignRequestList = new List<VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest>{
                writeNoteAndSignRequest
            };

            VCC_DASFlowWriteNoteAndSign writeNoteAndSignStub = (VCC_DASFlowWriteNoteAndSign) new VATEST_StubBuilder(
                    VCC_DASFlowWriteNoteAndSign.class
                )
                .mockingMethodCall(
                    'handleWriteNoteAndSign',
                    List<VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest>.class
                )
                .withParameterValues(writeNoteAndSignRequestList)
                .throwingException()
                .defineStub();

            VCC_DASFlowWriteNoteAndSign.flowWriteNoteAndSignInstance = writeNoteAndSignStub;

            Map<String, Object> params = new Map<String, Object>();
            params.put('isEncounterable', false);
            params.put('ProgressNoteRecord_DAS', testProgressNote);
            params.put('noteAndEncounterParams', noteAndEncounterParams);
            params.put('patientAndProviderParams', patientAndProviderParams);
            params.put('recordId', testProgressNote.Id);

            Test.startTest();
            Flow.Interview writeNoteAndSignSubflow = Flow.Interview.createInterview(
                'VCC_Sign_Note_Subflow_DAS_Write_Note_And_Sign',
                params
            );
            writeNoteAndSignSubflow.start();
            Assert.isNotNull(
                (String) writeNoteAndSignSubflow.getVariableValue('encounterString'),
                'Expected encounterString to be not null because it should have been generated in the Generate Encounter String Apex Action' +
                    ' Actual: ' +
                    (String) writeNoteAndSignSubflow.getVariableValue('encounterString')
            );
            Assert.areEqual(
                (String) writeNoteAndSignSubflow.getVariableValue('encounterString'),
                noteAndEncounterParams.encounterString,
                'Expected encounterString equals the value of noteAndEncounterParams.encounterString'
            );
            Assert.isTrue(
                (Boolean) writeNoteAndSignSubflow.getVariableValue('faultFlag_DisplayFlowError'),
                'Expected faultFlag_DisplayFlowError to be true since we are throwing an exception.'
            );
            Assert.isNotNull(
                writeNoteAndSignSubflow.getVariableValue('faultMessage'),
                'Expected Fault Message to be not Null since there was an exception thrown.'
            );
            Test.stopTest();
        }
    }

    /**
     * @description Test the VCC Sign Note Subflow: DAS Write Note And Sign
     *              Verifies the path
     *              is Encounterable -> No -> Invoke Generate Encounter String Apex Action -> Set encounterString for Generate Encounter String
     *               -> Set noteAndEncounterParams ->  Invoke Write note and Sign Apex Action -> What Was the Result of Write Note and Sign -> Error ->
     *              Does flow invocable result have IEN -> No -> Does the Flow Invocable Result Have an Error Code? -> No
     */
    @IsTest
    static void funcInvokeWriteNoteAndSignApexActionErrorPositiveNoErrorCode() {
        System.runAs(VCC_TESTUSER) {
            VCC_Progress_Note__c testProgressNote = createTestProgressNote(
                'VCC_Clinical_Triage',
                'VCC_Clinical_Triage_Note_Progress_Note'
            );
            VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams = createNoteAndEncounterParams();
            VCC_Vdif_PatientAndProviderParams patientAndProviderParams = createPatientAndProviderParams();

            //stub generate encounter string apex action
            VCC_DASFlowGenerateEncounterString.Request generateEncounterStringRequest = new VCC_DASFlowGenerateEncounterString.Request();
            generateEncounterStringRequest.noteAndEncounterParameters = noteAndEncounterParams;

            List<VCC_DASFlowGenerateEncounterString.Request> generateEncounterStringRequestList = new List<VCC_DASFlowGenerateEncounterString.Request>{
                generateEncounterStringRequest
            };

            VCC_DASFlowGenerateEncounterString.Result generateEncounterStringResult = new VCC_DASFlowGenerateEncounterString.Result(
                noteAndEncounterParams.encounterString
            );

            List<VCC_DASFlowGenerateEncounterString.Result> generateEncounterStringResultList = new List<VCC_DASFlowGenerateEncounterString.Result>{
                generateEncounterStringResult
            };

            VCC_DASFlowGenerateEncounterString generateEncounterStringStub = (VCC_DASFlowGenerateEncounterString) new VATEST_StubBuilder(
                    VCC_DASFlowGenerateEncounterString.class
                )
                .mockingMethodCall(
                    'handleFlowGenerateEncounterString',
                    List<VCC_DASFlowGenerateEncounterString.Request>.class
                )
                .withParameterValues(generateEncounterStringRequestList)
                .returning(generateEncounterStringResultList)
                .defineStub();

            VCC_DASFlowGenerateEncounterString.flowGenerateEncounterStringInstance = generateEncounterStringStub;
            //Stub Write Note And Sign Apex Action
            VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest writeNoteAndSignRequest = writeNoteAndSignRequest();
            // Set the request parameters
            writeNoteAndSignRequest.recordId = testProgressNote.Id;
            writeNoteAndSignRequest.progressNote = testProgressNote;

            List<VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest> writeNoteAndSignRequestList = new List<VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest>{
                writeNoteAndSignRequest
            };
            VCC_DASWriteNoteSignSuccessRS successRS = new VCC_DASWriteNoteSignSuccessRS();
            VCC_DASFlowConsolidatedEndpointResult result = new VCC_DASFlowConsolidatedEndpointResult(successRS);

            result.errorDescription = 'Test Error Description';
            result.isError = true;
            result.errorCode = '';

            List<VCC_DASFlowConsolidatedEndpointResult> resultList = new List<VCC_DASFlowConsolidatedEndpointResult>{
                result
            };

            VCC_DASFlowWriteNoteAndSign writeNoteAndSignStub = (VCC_DASFlowWriteNoteAndSign) new VATEST_StubBuilder(
                    VCC_DASFlowWriteNoteAndSign.class
                )
                .mockingMethodCall(
                    'handleWriteNoteAndSign',
                    List<VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest>.class
                )
                .withParameterValues(writeNoteAndSignRequestList)
                .returning(resultList)
                .defineStub();

            VCC_DASFlowWriteNoteAndSign.flowWriteNoteAndSignInstance = writeNoteAndSignStub;

            // Start Flow
            Map<String, Object> params = new Map<String, Object>();
            params.put('ProgressNoteRecord_DAS', testProgressNote);
            params.put('noteAndEncounterParams', noteAndEncounterParams);
            params.put('patientAndProviderParams', patientAndProviderParams);
            params.put('recordId', testProgressNote.Id);

            Test.startTest();
            Flow.Interview writeNoteAndSignSubflow = Flow.Interview.createInterview(
                'VCC_Sign_Note_Subflow_DAS_Write_Note_And_Sign',
                params
            );
            writeNoteAndSignSubflow.start();
            Assert.isTrue(
                String.isBlank((String) writeNoteAndSignSubflow.getVariableValue('errorCode')),
                'Expected errorCode to an empty String since we are testing the path where no error code is returned.'
            );
            Assert.isNotNull(
                writeNoteAndSignSubflow.getVariableValue('faultMessage'),
                'Expected faultMessage to be not null because we set isError to true.'
            );
            Assert.isNotNull(
                writeNoteAndSignSubflow.getVariableValue('encounterString'),
                'Expected encounterString to be not null because we generated that in the Generate Encounter String Apex Action.'
            );
            Assert.isTrue(
                (Boolean) writeNoteAndSignSubflow.getVariableValue('faultFlag_DisplayFlowError'),
                'Expected faultFlag_DisplayFlowError to be true since we set isError to true.'
            );
            Assert.isFalse(
                (Boolean) writeNoteAndSignSubflow.getVariableValue('faultFlag_ResumeConsolidatedEndpoint'),
                'Expected faultFlag_ResumeConsolidatedEndpoint to be false since there was no IEN.'
            );
            Assert.isNull(
                writeNoteAndSignSubflow.getVariableValue('noteOrAddendumIen'),
                'Expected noteOrAddendumIen to be null because we did not set one because that is the path in the flow that we are testing.'
            );
            Test.stopTest();
        }
    }

    /**
     * @description Tests the path for the DAS Save Note and Encounter Apex Action when the apex action returns a CodeSet Error
     */
    @IsTest
    static void unitInvokeSaveNoteAndEncounterApexActionCodeSetErrorNegative() {
        System.runAs(VCC_TESTUSER) {
            VCC_Progress_Note__c testProgressNote = createTestProgressNote(
                'VCC_Clinical_Triage',
                'VCC_Clinical_Triage_Note_Progress_Note'
            );

            VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams = createNoteAndEncounterParams();
            VCC_Vdif_PatientAndProviderParams patientAndProviderParams = createPatientAndProviderParams();
            patientAndProviderParams.patientName = 'Test Patient Name';

            //Stub Save Note and Encounter Apex Action
            VCC_DASFlowSaveNoteAndEncounter.Request saveNoteAndEncounterRequest = saveNoteAndEncounterRequest();

            saveNoteAndEncounterRequest.recordId = testProgressNote.Id;

            List<VCC_DASFlowSaveNoteAndEncounter.Request> saveNoteAndEncounterRequestList = new List<VCC_DASFlowSaveNoteAndEncounter.Request>{
                saveNoteAndEncounterRequest
            };
            VCC_DASSaveNoteAndEncounterRS successRS = new VCC_DASSaveNoteAndEncounterRS();
            VCC_DASFlowSaveNoteAndEncounter.Result saveNoteAndEncounterResult = new VCC_DASFlowSaveNoteAndEncounter.Result(
                successRS
            );
            saveNoteAndEncounterResult.text = 'not an active ICD Code';

            List<VCC_DASFlowSaveNoteAndEncounter.Result> saveNoteAndEncounterResultList = new List<VCC_DASFlowSaveNoteAndEncounter.Result>{
                saveNoteAndEncounterResult
            };

            VCC_DASFlowSaveNoteAndEncounter saveNoteAndEncounterStub = (VCC_DASFlowSaveNoteAndEncounter) new VATEST_StubBuilder(
                    VCC_DASFlowSaveNoteAndEncounter.class
                )
                .mockingMethodCall('handleSaveNoteAndEncounter', List<VCC_DASFlowSaveNoteAndEncounter.Request>.class)
                .withParameterValues(saveNoteAndEncounterRequestList)
                .returning(saveNoteAndEncounterResultList)
                .defineStub();

            VCC_DASFlowSaveNoteAndEncounter.flowSaveNoteAndEncounterInstance = saveNoteAndEncounterStub;

            Test.startTest();
            Flow.Interview writeNoteAndSignSubflow = Flow.Interview.createInterview(
                'VCC_Sign_Note_Subflow_DAS_Write_Note_And_Sign',
                new Map<String, Object>{
                    'recordId' => testProgressNote.Id,
                    'noteAndEncounterParams' => noteAndEncounterParams,
                    'patientAndProviderParams' => patientAndProviderParams,
                    'isEncounterable' => true,
                    'ProgressNoteRecord_DAS' => testProgressNote
                }
            );

            writeNoteAndSignSubflow.start();

            //asserts
            Assert.isTrue(
                (Boolean) writeNoteAndSignSubflow.getVariableValue('faultFlag_CodeAssignmentSubflow'),
                'Expected flow output faultFlag_CodeAssignmentSubflow to be true since there was a Code Set Error.'
            );
        }
    }

    /**
     * @description Tests the path for the DAS Save Note and Encounter Apex Action when the apex action returns Other Error
     */
    @IsTest
    static void unitInvokeSaveNoteAndEncounterApexActionOtherErrorNegative() {
        System.runAs(VCC_TESTUSER) {
            VCC_Progress_Note__c testProgressNote = createTestProgressNote(
                'VCC_Clinical_Triage',
                'VCC_Clinical_Triage_Note_Progress_Note'
            );
            VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams = createNoteAndEncounterParams();
            VCC_Vdif_PatientAndProviderParams patientAndProviderParams = createPatientAndProviderParams();
            patientAndProviderParams.patientName = 'Test Patient Name';

            //Stub Save Note and Encounter Apex Action
            VCC_DASFlowSaveNoteAndEncounter.Request saveNoteAndEncounterRequest = saveNoteAndEncounterRequest();

            saveNoteAndEncounterRequest.recordId = testProgressNote.Id;

            List<VCC_DASFlowSaveNoteAndEncounter.Request> saveNoteAndEncounterRequestList = new List<VCC_DASFlowSaveNoteAndEncounter.Request>{
                saveNoteAndEncounterRequest
            };
            VCC_DASSaveNoteAndEncounterRS successRS = new VCC_DASSaveNoteAndEncounterRS();
            VCC_DASFlowSaveNoteAndEncounter.Result saveNoteAndEncounterResult = new VCC_DASFlowSaveNoteAndEncounter.Result(
                successRS
            );
            saveNoteAndEncounterResult.text = 'ERROR:';

            List<VCC_DASFlowSaveNoteAndEncounter.Result> saveNoteAndEncounterResultList = new List<VCC_DASFlowSaveNoteAndEncounter.Result>{
                saveNoteAndEncounterResult
            };

            VCC_DASFlowSaveNoteAndEncounter saveNoteAndEncounterStub = (VCC_DASFlowSaveNoteAndEncounter) new VATEST_StubBuilder(
                    VCC_DASFlowSaveNoteAndEncounter.class
                )
                .mockingMethodCall('handleSaveNoteAndEncounter', List<VCC_DASFlowSaveNoteAndEncounter.Request>.class)
                .withParameterValues(saveNoteAndEncounterRequestList)
                .returning(saveNoteAndEncounterResultList)
                .defineStub();

            VCC_DASFlowSaveNoteAndEncounter.flowSaveNoteAndEncounterInstance = saveNoteAndEncounterStub;

            Test.startTest();
            Flow.Interview writeNoteAndSignSubflow = Flow.Interview.createInterview(
                'VCC_Sign_Note_Subflow_DAS_Write_Note_And_Sign',
                new Map<String, Object>{
                    'recordId' => testProgressNote.Id,
                    'noteAndEncounterParams' => noteAndEncounterParams,
                    'patientAndProviderParams' => patientAndProviderParams,
                    'isEncounterable' => true,
                    'ProgressNoteRecord_DAS' => testProgressNote
                }
            );

            writeNoteAndSignSubflow.start();

            //asserts
            Assert.isTrue(
                (Boolean) writeNoteAndSignSubflow.getVariableValue('faultFlag_DisplayFlowError'),
                'Expected flow output faultFlag_DisplayFlowError to be true since the flow returned \'Other Error\'.'
            );
            Assert.isNotNull(
                writeNoteAndSignSubflow.getVariableValue('faultMessage'),
                'Expected flow output faultMessage to be be not null since the flow returned \'Other Error\'.'
            );
        }
    }

    /**
     * @description Tests the path for the DAS Save Note and Encounter Apex Action when the apex action returns a fault
     */
    @IsTest
    static void unitInvokeSaveNoteAndEncounterApexActionFaultNegative() {
        Test.startTest();
        System.runAs(VCC_TESTUSER) {
            VCC_Progress_Note__c testProgressNote = createTestProgressNote(
                'VCC_Clinical_Triage',
                'VCC_Clinical_Triage_Note_Progress_Note'
            );

            VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams = createNoteAndEncounterParams();
            VCC_Vdif_PatientAndProviderParams patientAndProviderParams = createPatientAndProviderParams();
            patientAndProviderParams.patientName = 'Test Patient Name';

            VCC_DASFlowSaveNoteAndEncounter.Request saveNoteAndEncounterRequest = new VCC_DASFlowSaveNoteAndEncounter.Request();

            saveNoteAndEncounterRequest.recordId = testProgressNote.Id;

            List<VCC_DASFlowSaveNoteAndEncounter.Request> saveNoteAndEncounterRequestList = new List<VCC_DASFlowSaveNoteAndEncounter.Request>{
                saveNoteAndEncounterRequest
            };
            VCC_DASSaveNoteAndEncounterRS successRS = new VCC_DASSaveNoteAndEncounterRS();
            VCC_DASFlowSaveNoteAndEncounter.Result saveNoteAndEncounterResult = new VCC_DASFlowSaveNoteAndEncounter.Result(
                successRS
            );

            saveNoteAndEncounterResult.text = '9941;3200723.131503;T';

            VCC_DASFlowSaveNoteAndEncounter saveNoteAndEncounterStub = (VCC_DASFlowSaveNoteAndEncounter) new VATEST_StubBuilder(
                    VCC_DASFlowSaveNoteAndEncounter.class
                )
                .mockingMethodCall('handleSaveNoteAndEncounter', List<VCC_DASFlowSaveNoteAndEncounter.Request>.class)
                .withParameterValues(saveNoteAndEncounterRequestList)
                .throwingException()
                .defineStub();

            VCC_DASFlowSaveNoteAndEncounter.flowSaveNoteAndEncounterInstance = saveNoteAndEncounterStub;

            //start flow
            Flow.Interview saveNoteAndEncounterSubflow = Flow.Interview.createInterview(
                'VCC_Sign_Note_Subflow_DAS_Write_Note_And_Sign',
                new Map<String, Object>{
                    'recordId' => testProgressNote.Id,
                    'noteAndEncounterParams' => noteAndEncounterParams,
                    'patientAndProviderParams' => patientAndProviderParams,
                    'ProgressNoteRecord_DAS' => testProgressNote,
                    'isEncounterable' => true
                }
            );

            saveNoteAndEncounterSubflow.start();

            //Asserts
            Assert.isTrue(
                (Boolean) saveNoteAndEncounterSubflow.getVariableValue('faultFlag_DisplayFlowError'),
                'Expected faultFlag_DisplayFlowError to be true since we are throwing an exception.'
            );
            Assert.isNotNull(
                saveNoteAndEncounterSubflow.getVariableValue('faultMessage'),
                'Expected Fault Message to be not Null because an exception was thrown so the flow should return a fault.'
            );
            Test.stopTest();
        }
    }
}
