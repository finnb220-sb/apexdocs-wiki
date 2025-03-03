/**
 * @description Un-stubbed end-to-end integration tests for all DAS calls.
 * @author     Booz Allen
 */
@IsTest
public with sharing class VCC_DASTest {
    private static User getTestUser() {
        return (new VATEST_UserBuilder())
            .withStandardData()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSets(
                new Set<String>{
                    'HealthCloudFoundation',
                    'VAHC_Read_Progress_Notes',
                    'VAHC_RN_Standard_VCC_User',
                    'VAHC_RN_User',
                    'VAHC_Write_Clinical_Triage_Progress_Note',
                    'VAHC_Standard_VCC_User',
                    'VCC_DAS'
                }
            )
            .build(true);
    }

    @IsTest
    static void unitGetAdditionalSignersTestPositive() {
        Test.startTest();
        VCC_DAS.State dasState = new VCC_DAS.State(
            new VCC_SiteId('123'),
            'TestAppName',
            VATEST_IdFactory.get(VCC_Progress_Note__c.class)
        );
        VCC_DASGetAdditionalSignersRQ getAdditionalSignersRq = new VCC_DASGetAdditionalSignersRQ();
        VCC_DASGetAdditionalSignersRS getAdditionalSignersRs = new VCC_DASGetAdditionalSignersRS();
        VATEST_MockedMethod getAdditionalSignersMockedMethod = VCC_DASServiceApiTest.getMockedMethodGetAdditionalSigners()
            .withParameterValues(new List<Object>{ getAdditionalSignersRq, dasState })
            .returning(getAdditionalSignersRs);
        VCC_DASServicesTest.stubApi(new List<VATEST_MockedMethod>{ getAdditionalSignersMockedMethod });
        Assert.areEqual(
            getAdditionalSignersRs,
            (new VCC_DAS(dasState)).getAdditionalSigners(getAdditionalSignersRq),
            'Expected return value to be the stubbed return value'
        );
        getAdditionalSignersMockedMethod.assertMockedMethodWasCalled();
        Test.stopTest();
    }

    @IsTest
    static void flowCreateAddendumTest() {
        System.runAs(getTestUser()) {
            Case testCase = new Case();
            insert testCase;

            VCC_Progress_Note__c testProgressNote = new VCC_Progress_Note__c(VCC_Case__c = testCase.Id);
            insert testProgressNote;

            VCC_Addendum__c addendum = new VCC_Addendum__c(
                VCC_Related_Note__c = testProgressNote.Id,
                VCC_Addendum__c = 'test'
            );
            insert addendum;

            VCC_DAS.SERVICES.PARSER.stubParser = false;

            StaticResourceCalloutMock calloutMock = new StaticResourceCalloutMock();
            calloutMock.setStaticResource('VCC_vdifCreateAddendumMockResponse');
            Test.setMock(HttpCalloutMock.class, calloutMock);

            VCC_DASFlowCreateAddendum.Request flowCreateAddendumRequest = new VCC_DASFlowCreateAddendum.Request();

            flowCreateAddendumRequest.itemId = 'test';
            flowCreateAddendumRequest.type = 'test';
            flowCreateAddendumRequest.providerLoginSiteCode = '123';
            flowCreateAddendumRequest.providerUserId = 'test';
            flowCreateAddendumRequest.providerName = 'test';
            flowCreateAddendumRequest.recordId = addendum.Id;
            flowCreateAddendumRequest.addendum = new VCC_Addendum__c(Id = addendum.Id);

            Test.startTest();
            VCC_DASFlowCreateAddendum.Result flowCreateAddendumResult = VCC_DASFlowCreateAddendum.createAddendum(
                new List<VCC_DASFlowCreateAddendum.Request>{ flowCreateAddendumRequest }
            )[0];
            Test.stopTest();

            Assert.areEqual(
                '5269041',
                flowCreateAddendumResult.text,
                'Expected correct text value from static resource.'
            );
            Assert.isNull(flowCreateAddendumResult.faultMessage, 'Expected null value for faultMessage');
        }
    }

    @IsTest
    static void flowIsValidEsigTest() {
        System.runAs(getTestUser()) {
            Case testCase = new Case();
            insert testCase;

            VCC_Progress_Note__c testProgressNote = new VCC_Progress_Note__c(VCC_Case__c = testCase.Id);
            insert testProgressNote;

            StaticResourceCalloutMock calloutMock = new StaticResourceCalloutMock();
            calloutMock.setStaticResource('VCC_vdifIsValidEsigMockResponse');
            Test.setMock(HttpCalloutMock.class, calloutMock);

            VCC_DASFlowIsValidEsig.Request flowIsValidEsigRequest = new VCC_DASFlowIsValidEsig.Request();
            flowIsValidEsigRequest.criteria = 'test';
            flowIsValidEsigRequest.providerLoginSiteCode = '123';
            flowIsValidEsigRequest.providerName = 'test';
            flowIsValidEsigRequest.providerUserId = 'test';
            flowIsValidEsigRequest.recordId = testProgressNote.Id;

            Test.startTest();
            VCC_DASFlowIsValidEsig.Result flowIsValidEsigResult = VCC_DASFlowIsValidEsig.isValidEsig(
                new List<VCC_DASFlowIsValidEsig.Request>{ flowIsValidEsigRequest }
            )[0];
            Test.stopTest();
            Assert.areEqual(true, flowIsValidEsigResult.isValid, 'Expected value matching the mock response');
        }
    }

    @IsTest
    static void flowSaveNoteAndEncounterTest() {
        System.runAs(getTestUser()) {
            Case testCase = new Case();
            insert testCase;

            VCC_Progress_Note__c testProgressNote = new VCC_Progress_Note__c(VCC_Case__c = testCase.Id);
            insert testProgressNote;

            CodeSet procedureCode = new CodeSet(Code = 'TST.35', Name = 'TST.35', CodeSetType = 'Procedure (CPT)');

            insert procedureCode;

            CodeSet primaryDiagnosis = new CodeSet(Code = 'TST.33', Name = 'TST.33', CodeSetType = 'Diagnosis (ICD10)');

            CodeSet secondaryDiagnosis = new CodeSet(
                Code = 'TST.34',
                Name = 'TST.34',
                CodeSetType = 'Diagnosis (ICD10)'
            );

            insert new List<CodeSet>{ primaryDiagnosis, secondaryDiagnosis };

            StaticResourceCalloutMock calloutMock = new StaticResourceCalloutMock();
            calloutMock.setStaticResource('VCC_vdifSaveNoteAndEncounterMockResponse');
            Test.setMock(HttpCalloutMock.class, calloutMock);

            VCC_DASFlowSaveNoteAndEncounter.Request flowSaveNoteAndEncounterRequest = new VCC_DASFlowSaveNoteAndEncounter.Request();
            flowSaveNoteAndEncounterRequest.providerUserId = 'test';
            flowSaveNoteAndEncounterRequest.patientLocalPid = 'test';
            flowSaveNoteAndEncounterRequest.patientName = 'test';
            flowSaveNoteAndEncounterRequest.patientLocalSiteId = '123';
            flowSaveNoteAndEncounterRequest.noteAndEncounterLocationIen = 'test';
            flowSaveNoteAndEncounterRequest.noteAndEncounterNoteTitleIen = 'test';
            flowSaveNoteAndEncounterRequest.noteAndEncounterVisitRelatedTos = 'test';
            flowSaveNoteAndEncounterRequest.procedureCode = procedureCode;
            flowSaveNoteAndEncounterRequest.primaryDiagnosis = primaryDiagnosis;
            flowSaveNoteAndEncounterRequest.secondaryDiagnosis = secondaryDiagnosis;
            flowSaveNoteAndEncounterRequest.recordId = testProgressNote.Id;

            Test.startTest();
            VCC_DASFlowSaveNoteAndEncounter.Result flowSaveNoteAndEncounterResult = VCC_DASFlowSaveNoteAndEncounter.saveNoteAndEncounter(
                new List<VCC_DASFlowSaveNoteAndEncounter.Request>{ flowSaveNoteAndEncounterRequest }
            )[0];
            Test.stopTest();

            Assert.areEqual(
                '9941;3200723.131503;T',
                flowSaveNoteAndEncounterResult.text,
                'Expected correct value from mock response'
            );
        }
    }

    @IsTest
    static void flowSignNoteTest() {
        System.runAs(getTestUser()) {
            Case testCase = new Case();
            insert testCase;

            VCC_Progress_Note__c testProgressNote = new VCC_Progress_Note__c(VCC_Case__c = testCase.Id);
            insert testProgressNote;

            StaticResourceCalloutMock calloutMock = new StaticResourceCalloutMock();
            calloutMock.setStaticResource('VCC_vdifSignNoteMockResponse');
            Test.setMock(HttpCalloutMock.class, calloutMock);

            VCC_DASFlowSignNote.Request flowSignNoteRequest = new VCC_DASFlowSignNote.Request();
            flowSignNoteRequest.esig = 'test';
            flowSignNoteRequest.providerLoginSiteCode = '123';
            flowSignNoteRequest.providerName = 'test';
            flowSignNoteRequest.providerUserId = 'test';
            flowSignNoteRequest.noteIEN = 'test';
            flowSignNoteRequest.recordId = testProgressNote.Id;
            Test.startTest();
            VCC_DASFlowSignNote.Result flowSignNoteResult = VCC_DASFlowSignNote.signNote(
                new List<VCC_DASFlowSignNote.Request>{ flowSignNoteRequest }
            )[0];
            Test.stopTest();

            Assert.areEqual('OK', flowSignNoteResult.text, 'Expected correct value from mock response');
            Assert.isNull(flowSignNoteResult.faultMessage, 'Expected null value');
        }
    }

    @IsTest
    static void flowWriteNoteTest() {
        System.runAs(getTestUser()) {
            Case testCase = new Case();
            insert testCase;

            VCC_Progress_Note__c testProgressNote = new VCC_Progress_Note__c(
                VCC_Case__c = testCase.Id,
                RecordTypeId = Schema.SObjectType.VCC_Progress_Note__c.getRecordTypeInfosByDeveloperName()
                    .get('VCC_Clinical_Triage_Note_Progress_Note')
                    .getRecordTypeId()
            );
            insert testProgressNote;

            StaticResourceCalloutMock calloutMock = new StaticResourceCalloutMock();
            calloutMock.setStaticResource('VCC_vdifWriteNoteMockResponse');
            Test.setMock(HttpCalloutMock.class, calloutMock);

            VCC_DASFlowWriteNote.Request flowWriteNoteRequest = new VCC_DASFlowWriteNote.Request();
            flowWriteNoteRequest.encounterString = 'test';
            flowWriteNoteRequest.providerUserId = 'test';
            flowWriteNoteRequest.patientLocalPid = 'test';
            flowWriteNoteRequest.titleIEN = 'test';
            flowWriteNoteRequest.patientLocalSiteId = '123';
            flowWriteNoteRequest.patientName = 'test';
            flowWriteNoteRequest.recordId = testProgressNote.Id;
            flowWriteNoteRequest.progressNote = testProgressNote;

            Test.startTest();
            VCC_DASFlowWriteNote.Result flowWriteNoteResult = VCC_DASFlowWriteNote.writeNote(
                new List<VCC_DASFlowWriteNote.Request>{ flowWriteNoteRequest }
            )[0];
            Test.stopTest();

            Assert.areEqual('1810049', flowWriteNoteResult.id, 'Expected value to match static resource');
            Assert.areEqual(1, flowWriteNoteResult.totalPages, 'Expected value to match static resource');
            Assert.areEqual(1, flowWriteNoteResult.lastPageRecd, 'Expected value to match static resource');
            Assert.isNull(flowWriteNoteResult.explanation, 'Expected null, matching static resource');
            Assert.isNull(flowWriteNoteResult.faultMessage, 'Expected null, matching static resource');
        }
    }

    @IsTest
    static void flowSelectPatientTest() {
        System.runAs(getTestUser()) {
            Case testCase = new Case();
            insert testCase;

            VCC_Progress_Note__c testProgressNote = new VCC_Progress_Note__c(VCC_Case__c = testCase.Id);
            insert testProgressNote;

            StaticResourceCalloutMock calloutMock = new StaticResourceCalloutMock();
            calloutMock.setStaticResource('VCC_vdifSelectPatientMockResponse');
            Test.setMock(HttpCalloutMock.class, calloutMock);

            VCC_DASFlowSelectPatient.Request flowSelectPatientRequest = new VCC_DASFlowSelectPatient.Request();
            flowSelectPatientRequest.providerLoginSiteCode = '123';
            flowSelectPatientRequest.providerName = 'test';
            flowSelectPatientRequest.providerUserId = 'test';
            flowSelectPatientRequest.patientLocalPid = new List<String>{ 'test' };
            flowSelectPatientRequest.patientLocalSiteId = 'test';
            flowSelectPatientRequest.recordId = testProgressNote.Id;

            Test.startTest();
            VCC_DASFlowSelectPatient.Result flowSelectPatientResult = VCC_DASFlowSelectPatient.selectPatient(
                new List<VCC_DASFlowSelectPatient.Request>{ flowSelectPatientRequest }
            )[0];
            Test.stopTest();

            Assert.areEqual(1, flowSelectPatientResult.selectPatientRSList.size(), 'Expected one result.');
        }
    }

    @IsTest
    private static void unitWriteNoteAndSignPositive() {
        VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;
        apiStub.setReturnValue('writeNoteAndSign', new VCC_DASWriteNoteSignSuccessRS());
        VCC_DASWriteNoteAndSignRQ writeNoteAndSignRQ = new VCC_DASWriteNoteAndSignRQ();

        Test.startTest();
        VCC_DAS dasCall = new VCC_DAS(
            new VCC_DAS.State(new VCC_SiteId('123'), 'TestAppName', VATEST_IdFactory.get(VCC_Progress_Note__c.class))
        );
        VCC_DASWriteNoteSignSuccessRS writeNoteAndSignRS = dasCall.writeNoteAndSign(writeNoteAndSignRQ);
        Test.stopTest();
        Assert.isNotNull(
            writeNoteAndSignRS,
            'Expected writeNoteAndSignRS to be non-null value. The response should hold the textTo attribute.'
        );
        Assert.isNotNull(
            writeNoteAndSignRS.textTO,
            'Expected TextTO attribute to be non-null. The attribute should hold the text and fault attributes.'
        );
        Assert.isNull(
            writeNoteAndSignRS.textTO.text,
            'Expected text attribute to be null since the response is empty.'
        );
        apiStub.assertInvoked('writeNoteAndSign');
    }

    @IsTest
    private static void unitWriteNoteAndSignNegative() {
        Test.startTest();
        try {
            VCC_DAS dasCall = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId('123'),
                    'TestAppName',
                    VATEST_IdFactory.get(VCC_Progress_Note__c.class)
                )
            );
            dasCall.writeNoteAndSign(null);
            Assert.fail('Expected an exception.');
        } catch (VCC_DASException dasException) {
            Assert.isTrue(
                dasException.getMessage().contains('Provided request is invalid. Unable to perform callout.'),
                'Expected the VCC_DASException contains the message "Provided request is invalid. Unable to perform callout." '
            );
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitCreateAddendumAndSignPositive() {
        VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;
        apiStub.setReturnValue('createAddendumAndSign', new VCC_DASCreateAddendumAndSignSuccessRS());
        VCC_DASCreateAddendumAndSignRQ createAddendumAndSignRQ = new VCC_DASCreateAddendumAndSignRQ();

        Test.startTest();
        VCC_DAS dasCall = new VCC_DAS(
            new VCC_DAS.State(new VCC_SiteId('123'), 'TestAppName', VATEST_IdFactory.get(VCC_Progress_Note__c.class))
        );
        VCC_DASCreateAddendumAndSignSuccessRS createAddendumAndSignRS = dasCall.createAddendumAndSign(
            createAddendumAndSignRq
        );
        Assert.isNotNull(
            createAddendumAndSignRS,
            'Expected createAddendumAndSignRS to be non-null value. The response should hold the textTo attribute.'
        );
        Assert.isNotNull(
            createAddendumAndSignRS.textTO,
            'Expected TextTO attribute to be non-null. The attribute should hold the text and fault attributes.'
        );
        Assert.isNull(
            createAddendumAndSignRS.textTO.text,
            'Expected text attribute to be null since the response is empty.'
        );
        apiStub.assertInvoked('createAddendumAndSign');
        Test.stopTest();
    }

    @IsTest
    private static void unitCreateAddendumAndSignNegative() {
        Test.startTest();
        try {
            VCC_DAS dasCall = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId('123'),
                    'TestAppName',
                    VATEST_IdFactory.get(VCC_Progress_Note__c.class)
                )
            );
            dasCall.createAddendumAndSign(null);
            Assert.fail('Expected an exception.');
        } catch (VCC_DASException dasException) {
            Assert.isTrue(
                dasException.getMessage().contains('Provided request is invalid. Unable to perform callout.'),
                'Expected the VCC_DASException contains the message "Provided request is invalid. Unable to perform callout." '
            );
        }
        Test.stopTest();
    }

    @IsTest
    private static void permWriteNoteAndSignPositive() {
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User testUser = builder.withUserProfile('VAVET Base Profile')
            .withPermissionSet('VCC_DAS')
            .withStandardData()
            .build(true);
        System.runAs(testUser) {
            VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
            VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;
            apiStub.setReturnValue('writeNoteAndSign', new VCC_DASWriteNoteSignSuccessRS());
            VCC_DASWriteNoteAndSignRQ writeNoteAndSignRQ = new VCC_DASWriteNoteAndSignRQ();

            Test.startTest();
            VCC_DAS dasCall = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId('123'),
                    'TestAppName',
                    VATEST_IdFactory.get(VCC_Progress_Note__c.class)
                )
            );
            VCC_DASWriteNoteSignSuccessRS writeNoteAndSignRS = dasCall.writeNoteAndSign(writeNoteAndSignRQ);
            Assert.isNotNull(writeNoteAndSignRS, 'Expected value to be VCC_DASWriteNoteSignSuccessRS.');
            Assert.isNotNull(writeNoteAndSignRS.textTO, 'Expected value to be VCC_DASRSCommon.TextTO.');
            apiStub.assertInvoked('writeNoteAndSign');
            Test.stopTest();
        }
    }

    @IsTest
    private static void permCreateAddendumAndSignPositive() {
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User testUser = builder.withUserProfile('VAVET Base Profile')
            .withPermissionSet('VCC_DAS')
            .withStandardData()
            .build(true);
        System.runAs(testUser) {
            VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
            VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;
            apiStub.setReturnValue('createAddendumAndSign', new VCC_DASCreateAddendumAndSignSuccessRS());
            VCC_DASCreateAddendumAndSignRQ createAddendumAndSignRQ = new VCC_DASCreateAddendumAndSignRQ();

            Test.startTest();

            VCC_DAS dasCall = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId('123'),
                    'TestAppName',
                    VATEST_IdFactory.get(VCC_Progress_Note__c.class)
                )
            );
            VCC_DASCreateAddendumAndSignSuccessRS createAddendumAndSignRS = dasCall.createAddendumAndSign(
                createAddendumAndSignRq
            );
            Assert.isNotNull(
                createAddendumAndSignRS,
                'Expected value to be type VCC_DASCreateAddendumAndSignSuccessRS'
            );
            Assert.isNotNull(createAddendumAndSignRS.textTO, 'Expected value to be VCC_DASRSCommon.TextTO');
            apiStub.assertInvoked('createAddendumAndSign');
            Test.stopTest();
        }
    }
}
