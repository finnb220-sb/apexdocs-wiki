@isTest
private class VCC_DASFlowWriteNoteTest {
    @IsTest
    static void unitResultConstructorPositive() {
        Test.startTest();
        VCC_DASWriteNoteRS writeNoteRs = new VCC_DASWriteNoteRS();
        Assert.isNotNull(new VCC_DASFlowWriteNote.Result(writeNoteRs), 'Expected non-null value');
        Test.stopTest();
    }

    @IsTest
    static void unitRequestConstructorPositive() {
        Test.startTest();
        VCC_DASFlowWriteNote.Request flowWriteNoteRequest = new VCC_DASFlowWriteNote.Request();
        Assert.isNotNull(flowWriteNoteRequest, 'Expected non-null values');
        Test.stopTest();
    }

    @IsTest
    static void unitWriteNotePositive() {
        VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
        VCC_DASStub parserStub = new VCC_DASStub(VCC_DASServiceParser.class);
        VCC_DASStub utilitiesStub = new VCC_DASStub(VCC_DASServiceUtilities.class);

        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;
        VCC_DAS.SERVICES.parserService = (VCC_DASServiceParser) parserStub.instance;
        VCC_DAS.SERVICES.utilitiesService = (VCC_DASServiceUtilities) utilitiesStub.instance;

        parserStub.setReturnValue('parse', '');
        utilitiesStub.setReturnValue('getProviderDuz', '');
        apiStub.setReturnValue('writeNote', new VCC_DASWriteNoteRS());

        Test.startTest();
        try {
            VCC_DASFlowWriteNote.Request flowWriteNoteRequest = new VCC_DASFlowWriteNote.Request();
            flowWriteNoteRequest.patientLocalSiteId = '123';
            VCC_DASFlowWriteNote.Result flowWriteNoteResult = VCC_DASFlowWriteNote.writeNote(
                new List<VCC_DASFlowWriteNote.Request>{ flowWriteNoteRequest }
            )[0];
            Assert.isNotNull(flowWriteNoteResult, 'Expected non-null value.');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();

        apiStub.assertInvoked('writeNote');
    }

    @IsTest
    static void unitWriteNoteDasExceptionNegative() {
        VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
        VCC_DASStub parserStub = new VCC_DASStub(VCC_DASServiceParser.class);
        VCC_DASStub utilitiesStub = new VCC_DASStub(VCC_DASServiceUtilities.class);

        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;
        VCC_DAS.SERVICES.parserService = (VCC_DASServiceParser) parserStub.instance;
        VCC_DAS.SERVICES.utilitiesService = (VCC_DASServiceUtilities) utilitiesStub.instance;

        parserStub.setReturnValue('parse', '');
        utilitiesStub.setReturnValue('getProviderDuz', '');
        apiStub.setException('writeNote', new VCC_DASServiceApi.ApiServiceException());

        Test.startTest();
        try {
            VCC_DASFlowWriteNote.Request flowWriteNoteRequest = new VCC_DASFlowWriteNote.Request();
            VCC_DASFlowWriteNote.writeNote(new List<VCC_DASFlowWriteNote.Request>{ flowWriteNoteRequest });
            Assert.fail('Expected an exception.');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, VCC_DASException.class, 'Expected a VCC_DASException');
        }
        Test.stopTest();
    }

    @IsTest
    static void unitWriteNoteOtherExceptionNegative() {
        VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
        VCC_DASStub parserStub = new VCC_DASStub(VCC_DASServiceParser.class);
        VCC_DASStub utilitiesStub = new VCC_DASStub(VCC_DASServiceUtilities.class);

        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;
        VCC_DAS.SERVICES.parserService = (VCC_DASServiceParser) parserStub.instance;
        VCC_DAS.SERVICES.utilitiesService = (VCC_DASServiceUtilities) utilitiesStub.instance;

        parserStub.setReturnValue('parse', '');
        utilitiesStub.setReturnValue('getProviderDuz', '');
        apiStub.setException('writeNote', new NullPointerException());

        Test.startTest();
        try {
            VCC_DASFlowWriteNote.Request flowWriteNoteRequest = new VCC_DASFlowWriteNote.Request();
            VCC_DASFlowWriteNote.writeNote(new List<VCC_DASFlowWriteNote.Request>{ flowWriteNoteRequest });
            Assert.fail('Expected an exception.');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, VCC_DASException.class, 'Expected a VCC_DASException');
        }
        Test.stopTest();
    }

    @IsTest
    static void funcWriteNotePositive() {
        System.runAs((new VATEST_UserBuilder())
            .withStandardData()
            .withUserProfile('System Administrator')
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
            .build(true)) {
            Case testCase = new Case(
                RecordTypeId = Case.SobjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                    .getRecordTypeInfosByName()
                    .get('Clinical Triage Case')
                    .getRecordTypeId(),
                VCC_Caller_Relation__c = 'Self'
            );
            insert testCase;
            VCC_Progress_Note__c testProgressNote = new VCC_Progress_Note__c(
                VCC_Additional_Comments__c = 'Some additional comment.',
                VCC_Comments_patient_in_crisis__c = 'some long string that will be longer than 😀 80 characters long to demonstrate the line breaking',
                VCC_Case__c = testCase.Id,
                RecordTypeId = Schema.SObjectType.VCC_Progress_Note__c.getRecordTypeInfosByDeveloperName()
                    .get('VCC_Clinical_Triage_Note_Progress_Note')
                    .getRecordTypeId()
            );
            insert testProgressNote;

            VCC_DASFlowWriteNote.Request flowRequest = new VCC_DASFlowWriteNote.Request();
            flowRequest.progressNote = new VCC_Progress_Note__c(Id = testProgressNote.Id);
            flowRequest.recordId = testProgressNote.Id;
            flowRequest.encounterString = 'encounter string test';
            flowRequest.patientLocalPid = 'patient local pid test';
            flowRequest.patientLocalSiteId = '123';
            flowRequest.patientName = 'patient name test';
            flowRequest.providerUserId = 'provider user id test';
            flowRequest.titleIEN = 'title ien test';

            StaticResourceCalloutMock staticResourceCalloutMock = new StaticResourceCalloutMock();
            staticResourceCalloutMock.setStaticResource('VCC_vdifWriteNoteMockResponse');
            staticResourceCalloutMock.setStatusCode(200);
            Test.setMock(HttpCalloutMock.class, staticResourceCalloutMock);
            Test.startTest();
            VCC_NoteParserService.didReplaceCharacters = true;
            VCC_DASFlowWriteNote.writeNote(new List<VCC_DASFlowWriteNote.Request>{ flowRequest });
            Assert.isTrue(true, 'No Exceptions. Test Passes.');
            Test.stopTest();
        }
    }
}
