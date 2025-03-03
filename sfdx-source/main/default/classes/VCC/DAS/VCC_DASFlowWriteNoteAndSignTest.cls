/**
 * @description Test class for VCC_DASFlowWriteNoteAndSign
 * @author      Booz Allen
 * @since       May 10, 2024
 * @see         VCC_DASFlowWriteNoteAndSign
 * @see         VCC_DAS
 * @see         VCC_DASServiceParser
 * @see         VCC_DASServiceUtilities
 * @see         VCC_SignersService
 */
@IsTest
private class VCC_DASFlowWriteNoteAndSignTest {
    @TestVisible
    private static VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest generateFlowRequest(
        Id testRecordId,
        VCC_Progress_Note__c testProgressNote
    ) {
        VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest flowRequest = new VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest();
        flowRequest.recordId = testRecordId;
        flowRequest.progressNote = testProgressNote;
        flowRequest.titleIEN = 'test';
        flowRequest.encounterString = 'test';
        flowRequest.authorDUZ = '000777';
        flowRequest.cosignerDUZ = 'test';
        flowRequest.providerLoginSiteCode = '123';
        flowRequest.providerName = 'test';
        flowRequest.providerUserId = 'test';
        flowRequest.patientLocalPid = 'test';
        flowRequest.patientLocalSiteId = '123';
        flowRequest.patientName = 'test';
        flowRequest.esig = 'test';
        return flowRequest;
    }

    @TestVisible
    private static VCC_DASServiceParser stubParserService(VCC_Progress_Note__c progressNote, String text) {
        VCC_DASServiceParser parserStub = (VCC_DASServiceParser) new VATEST_StubBuilder(VCC_DASServiceParser.class)
            .mockingMethodCall('parse', Sobject.class)
            .withParameterValues(progressNote)
            .returning(text)
            .defineStub();
        return parserStub;
    }

    @TestVisible
    private static VCC_DASServiceUtilities stubUtilService(
        String authorDUZ,
        VCC_Progress_Note__c progressNote,
        String recordType
    ) {
        VCC_DASServiceUtilities utilStub = (VCC_DASServiceUtilities) new VATEST_StubBuilder(
                VCC_DASServiceUtilities.class
            )
            .mockingMethodCall('getProviderDuz', Id.class, String.class)
            .withParameterValues(UserInfo.getUserId(), '123')
            .returning(authorDUZ)
            .mockingMethodCall('getRecordTypeApiName', SObject.class)
            .withParameterValues(progressNote)
            .returning(recordType)
            .defineStub();
        return utilStub;
    }

    @TestVisible
    private static VCC_SignersService stubSignersService(Id recordId, List<String> signersDUZ) {
        VCC_SignersService signersStub = (VCC_SignersService) new VATEST_StubBuilder(VCC_SignersService.class)
            .mockingMethodCall('getSignerDuzListForCallout', Id.class)
            .withParameterValues(recordId)
            .returning(signersDUZ)
            .defineStub();
        return signersStub;
    }

    @TestVisible
    static void stubDas(
        VCC_DASWriteNoteAndSignRQ stubRequest,
        VCC_DAS.State dasState,
        VCC_DASWriteNoteSignSuccessRS successRS
    ) {
        VCC_DASServicesTest.stubApi(
            new List<VATEST_MockedMethod>{
                VCC_DASServiceApiTest.getMockedMethodWriteNoteAndSign()
                    .withParameterValues(new List<Object>{ stubRequest, dasState })
                    .returning(successRS)
            }
        );
    }

    // Positive Class Properties Tests
    @IsTest
    static void unitInnerRequestClassReadPropertiesPositive() {
        Test.startTest();
        try {
            VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest flowWriteNoteAndSignRequest = new VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest();
            Assert.isNotNull(
                flowWriteNoteAndSignRequest,
                'Expected flowWriteNoteAndSignRequest to be instantiated successfully and be a non-null value.'
            );
            Assert.isNull(flowWriteNoteAndSignRequest.recordId, 'Expected null value since recordId was never set.');
            Assert.isNull(
                flowWriteNoteAndSignRequest.progressNote,
                'Expected null value since progress note was never set.'
            );
            Assert.isTrue(
                String.isEmpty(flowWriteNoteAndSignRequest.titleIEN),
                'Expected empty string because titleIEN was never set.'
            );
            Assert.isTrue(
                String.isEmpty(flowWriteNoteAndSignRequest.encounterString),
                'Expected empty string because encounterString was never set.'
            );
            Assert.isTrue(
                String.isEmpty(flowWriteNoteAndSignRequest.authorDUZ),
                'Expected empty string because authorDUZ was never set.'
            );
            Assert.isTrue(
                String.isEmpty(flowWriteNoteAndSignRequest.cosignerDUZ),
                'Expected empty string because cosignerDUZ was never set.'
            );
            Assert.isTrue(
                String.isEmpty(flowWriteNoteAndSignRequest.esig),
                'Expected empty string because esig was never set.'
            );
            Assert.isTrue(
                String.isEmpty(flowWriteNoteAndSignRequest.providerLoginSiteCode),
                'Expected empty string because providerLoginSiteCode was never set.'
            );
            Assert.isTrue(
                String.isEmpty(flowWriteNoteAndSignRequest.providerName),
                'Expected empty string because providerName was never set.'
            );
            Assert.isTrue(
                String.isEmpty(flowWriteNoteAndSignRequest.providerUserId),
                'Expected empty string because providerUserId was never set.'
            );
            Assert.isTrue(
                String.isEmpty(flowWriteNoteAndSignRequest.patientLocalPid),
                'Expected empty string because patientLocalPid was never set.'
            );
            Assert.isTrue(
                String.isEmpty(flowWriteNoteAndSignRequest.patientLocalSiteId),
                'Expected empty string because patientLocalSiteId was never set.'
            );
            Assert.isTrue(
                String.isEmpty(flowWriteNoteAndSignRequest.patientName),
                'Expected empty string because patientName was never set.'
            );
        } catch (Exception thrownException) {
            Assert.fail(
                'Expected no exception, instead found ' +
                    thrownException.getTypeName() +
                    '\n' +
                    thrownException.getStackTraceString()
            );
        }
        Test.stopTest();
    }

    // Positive writeNoteAndSign tests for each record type
    @IsTest
    static void unitWriteNoteAndSignClinicalTriagePositive() {
        Id testRecordId = VATEST_IdFactory.get(VCC_Progress_Note__c.class);
        VCC_Progress_Note__c testProgressNote = new VCC_Progress_Note__c(Id = testRecordId);
        VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest flowRequest = generateFlowRequest(
            testRecordId,
            testProgressNote
        );
        List<String> signersDUZ = new List<String>{ '777000' };

        List<VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest> requestList = new List<VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest>{
            flowRequest
        };

        VCC_DASWriteNoteAndSignRQ stubbedRequest = new VCC_DASWriteNoteAndSignRQ();
        stubbedRequest.esig = 'test';
        stubbedRequest.providerName = 'test';
        stubbedRequest.providerLoginSiteCode = '123';
        stubbedRequest.providerUserId = 'test';
        stubbedRequest.supplementalParameters = signersDUZ;
        stubbedRequest.titleIEN = 'test';
        stubbedRequest.encounterString = 'test';
        stubbedRequest.text = 'test';
        stubbedRequest.authorDUZ = '000777';
        stubbedRequest.cosignerDUZ = 'test';
        stubbedRequest.patientLocalPid = 'test';
        stubbedRequest.patientLocalSiteId = '123';
        stubbedRequest.patientName = 'test';
        VCC_DASWriteNoteAndSignRQ.signersService = stubSignersService(testRecordId, signersDUZ);
        VCC_DASWriteNoteAndSignRQ.parserService = stubParserService(testProgressNote, 'test');
        VCC_DASWriteNoteAndSignRQ.utilitiesService = stubUtilService(
            '000777',
            testProgressNote,
            'VCC_Clinical_Triage_Note_Progress_Note'
        );
        VCC_DAS.State dasState = new VCC_DAS.State(new VCC_SiteId('123'), 'VAHC', testRecordId);
        dasState.endpoint = VCC_DAS.Endpoint.WRITE_NOTE_AND_SIGN;
        stubDas(stubbedRequest, dasState, new VCC_DASWriteNoteSignSuccessRS());

        Test.startTest();
        List<VCC_DASFlowConsolidatedEndpointResult> resultList = VCC_DASFlowWriteNoteAndSign.writeNoteAndSign(
            requestList
        );
        Test.stopTest();

        Assert.isNotNull(resultList, 'Expected resultList to be non-null.');
        Assert.areEqual(1, resultList.size(), 'Expect resultsList to be size of 1.');
        Assert.isFalse(resultList[0].isError, 'Expected isError property to be false.');
        Assert.isNull(resultList[0].errorDescription, 'Expected property to exist and be null.');
        Assert.isNull(resultList[0].errorMessage, 'Expected property to exist and be null.');
        Assert.isNull(resultList[0].errorCode, 'Expected property to exist and be null.');
        Assert.isNull(resultList[0].noteOrAddendumIen, 'Expected property to exist and be null.');
        Assert.isNull(resultList[0].text, 'Expected property to exist and be null.');
    }

    @IsTest
    static void unitWriteNoteAndSignSchedulingPositive() {
        Id testRecordId = VATEST_IdFactory.get(VCC_Progress_Note__c.class);
        VCC_Progress_Note__c testProgressNote = new VCC_Progress_Note__c(Id = testRecordId);
        VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest flowRequest = generateFlowRequest(
            testRecordId,
            testProgressNote
        );

        List<String> signersDUZ = new List<String>{ '777000' };
        List<VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest> requestList = new List<VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest>{
            flowRequest
        };

        VCC_DASWriteNoteAndSignRQ stubbedRequest = new VCC_DASWriteNoteAndSignRQ();
        stubbedRequest.esig = 'test';
        stubbedRequest.providerName = 'test';
        stubbedRequest.providerLoginSiteCode = '123';
        stubbedRequest.providerUserId = 'test';
        stubbedRequest.supplementalParameters = signersDUZ;
        stubbedRequest.titleIEN = 'test';
        stubbedRequest.encounterString = 'test';
        stubbedRequest.text = 'test';
        stubbedRequest.authorDUZ = '000777';
        stubbedRequest.cosignerDUZ = 'test';
        stubbedRequest.patientLocalPid = 'test';
        stubbedRequest.patientLocalSiteId = '123';
        stubbedRequest.patientName = 'test';
        VCC_DASWriteNoteAndSignRQ.signersService = stubSignersService(testRecordId, signersDUZ);
        VCC_DASWriteNoteAndSignRQ.parserService = stubParserService(testProgressNote, 'test');
        VCC_DASWriteNoteAndSignRQ.utilitiesService = stubUtilService(
            '000777',
            testProgressNote,
            'VCC_Scheduling_Progress_Note'
        );
        VCC_DAS.State dasState = new VCC_DAS.State(new VCC_SiteId('123'), 'VAHC', testRecordId);
        dasState.endpoint = VCC_DAS.Endpoint.WRITE_NOTE_AND_SIGN;
        stubDas(stubbedRequest, dasState, new VCC_DASWriteNoteSignSuccessRS());

        Test.startTest();
        List<VCC_DASFlowConsolidatedEndpointResult> resultList = VCC_DASFlowWriteNoteAndSign.writeNoteAndSign(
            requestList
        );
        Test.stopTest();

        Assert.isNotNull(resultList, 'Expected resultList to be non-null.');
        Assert.areEqual(1, resultList.size(), 'Expect resultsList to be size of 1.');
        Assert.isFalse(resultList[0].isError, 'Expected isError property to be false.');
        Assert.isNull(resultList[0].errorDescription, 'Expected property to exist and be null.');
        Assert.isNull(resultList[0].errorMessage, 'Expected property to exist and be null.');
        Assert.isNull(resultList[0].errorCode, 'Expected property to exist and be null.');
        Assert.isNull(resultList[0].noteOrAddendumIen, 'Expected property to exist and be null.');
        Assert.isNull(resultList[0].text, 'Expected property to exist and be null.');
    }

    @IsTest
    static void unitWriteNoteAndSignVCVPositive() {
        Id testRecordId = VATEST_IdFactory.get(VCC_Progress_Note__c.class);
        VCC_Progress_Note__c testProgressNote = new VCC_Progress_Note__c(Id = testRecordId);
        VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest flowRequest = generateFlowRequest(
            testRecordId,
            testProgressNote
        );
        List<String> signersDUZ = new List<String>{ '777000' };
        List<VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest> requestList = new List<VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest>{
            flowRequest
        };

        VCC_DASWriteNoteAndSignRQ stubbedRequest = new VCC_DASWriteNoteAndSignRQ();
        stubbedRequest.esig = 'test';
        stubbedRequest.providerName = 'test';
        stubbedRequest.providerLoginSiteCode = '123';
        stubbedRequest.providerUserId = 'test';
        stubbedRequest.supplementalParameters = signersDUZ;
        stubbedRequest.titleIEN = 'test';
        stubbedRequest.encounterString = 'test';
        stubbedRequest.text = 'test';
        stubbedRequest.authorDUZ = '000777';
        stubbedRequest.cosignerDUZ = 'test';
        stubbedRequest.patientLocalPid = 'test';
        stubbedRequest.patientLocalSiteId = '123';
        stubbedRequest.patientName = 'test';
        VCC_DASWriteNoteAndSignRQ.signersService = stubSignersService(testRecordId, signersDUZ);
        VCC_DASWriteNoteAndSignRQ.parserService = stubParserService(testProgressNote, 'test');
        VCC_DASWriteNoteAndSignRQ.utilitiesService = stubUtilService(
            '000777',
            testProgressNote,
            'VCC_Virtual_Visit_Progress_Note'
        );
        VCC_DAS.State dasState = new VCC_DAS.State(new VCC_SiteId('123'), 'VAHC', testRecordId);
        dasState.endpoint = VCC_DAS.Endpoint.WRITE_NOTE_AND_SIGN;
        stubDas(stubbedRequest, dasState, new VCC_DASWriteNoteSignSuccessRS());

        Test.startTest();
        List<VCC_DASFlowConsolidatedEndpointResult> resultList = VCC_DASFlowWriteNoteAndSign.writeNoteAndSign(
            requestList
        );
        Test.stopTest();

        Assert.isNotNull(resultList, 'Expected resultList to be non-null.');
        Assert.areEqual(1, resultList.size(), 'Expect resultsList to be size of 1.');
        Assert.isFalse(resultList[0].isError, 'Expected isError property to be false.');
        Assert.isNull(resultList[0].errorDescription, 'Expected property to exist and be null.');
        Assert.isNull(resultList[0].errorMessage, 'Expected property to exist and be null.');
        Assert.isNull(resultList[0].errorCode, 'Expected property to exist and be null.');
        Assert.isNull(resultList[0].noteOrAddendumIen, 'Expected property to exist and be null.');
        Assert.isNull(resultList[0].text, 'Expected property to exist and be null.');
    }

    @IsTest
    static void unitWriteNoteAndSignPharm1Positive() {
        Id testRecordId = VATEST_IdFactory.get(VCC_Progress_Note__c.class);
        VCC_Progress_Note__c testProgressNote = new VCC_Progress_Note__c(Id = testRecordId);
        VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest flowRequest = generateFlowRequest(
            testRecordId,
            testProgressNote
        );
        List<String> signersDUZ = new List<String>{ '777000' };
        List<VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest> requestList = new List<VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest>{
            flowRequest
        };

        VCC_DASWriteNoteAndSignRQ stubbedRequest = new VCC_DASWriteNoteAndSignRQ();
        stubbedRequest.esig = 'test';
        stubbedRequest.providerName = 'test';
        stubbedRequest.providerLoginSiteCode = '123';
        stubbedRequest.providerUserId = 'test';
        stubbedRequest.supplementalParameters = signersDUZ;
        stubbedRequest.titleIEN = 'test';
        stubbedRequest.encounterString = 'test';
        stubbedRequest.text = 'test';
        stubbedRequest.authorDUZ = '000777';
        stubbedRequest.cosignerDUZ = 'test';
        stubbedRequest.patientLocalPid = 'test';
        stubbedRequest.patientLocalSiteId = '123';
        stubbedRequest.patientName = 'test';
        VCC_DASWriteNoteAndSignRQ.signersService = stubSignersService(testRecordId, signersDUZ);
        VCC_DASWriteNoteAndSignRQ.parserService = stubParserService(testProgressNote, 'test');
        VCC_DASWriteNoteAndSignRQ.utilitiesService = stubUtilService(
            '000777',
            testProgressNote,
            'VCC_Tier_I_Progress_Note'
        );
        VCC_DAS.State dasState = new VCC_DAS.State(new VCC_SiteId('123'), 'VAHC', testRecordId);
        dasState.endpoint = VCC_DAS.Endpoint.WRITE_NOTE_AND_SIGN;
        stubDas(stubbedRequest, dasState, new VCC_DASWriteNoteSignSuccessRS());

        Test.startTest();
        List<VCC_DASFlowConsolidatedEndpointResult> resultList = VCC_DASFlowWriteNoteAndSign.writeNoteAndSign(
            requestList
        );
        Test.stopTest();

        Assert.isNotNull(resultList, 'Expected resultList to be non-null.');
        Assert.areEqual(1, resultList.size(), 'Expect resultsList to be size of 1.');
        Assert.isFalse(resultList[0].isError, 'Expected isError property to be false.');
        Assert.isNull(resultList[0].errorDescription, 'Expected property to exist and be null.');
        Assert.isNull(resultList[0].errorMessage, 'Expected property to exist and be null.');
        Assert.isNull(resultList[0].errorCode, 'Expected property to exist and be null.');
        Assert.isNull(resultList[0].noteOrAddendumIen, 'Expected property to exist and be null.');
        Assert.isNull(resultList[0].text, 'Expected property to exist and be null.');
    }

    @IsTest
    static void unitWriteNoteAndSignPharm2Positive() {
        Id testRecordId = VATEST_IdFactory.get(VCC_Progress_Note__c.class);
        VCC_Progress_Note__c testProgressNote = new VCC_Progress_Note__c(Id = testRecordId);
        VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest flowRequest = generateFlowRequest(
            testRecordId,
            testProgressNote
        );
        List<String> signersDUZ = new List<String>{ '777000' };
        List<VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest> requestList = new List<VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest>{
            flowRequest
        };

        VCC_DASWriteNoteAndSignRQ stubbedRequest = new VCC_DASWriteNoteAndSignRQ();
        stubbedRequest.esig = 'test';
        stubbedRequest.providerName = 'test';
        stubbedRequest.providerLoginSiteCode = '123';
        stubbedRequest.providerUserId = 'test';
        stubbedRequest.supplementalParameters = signersDUZ;
        stubbedRequest.titleIEN = 'test';
        stubbedRequest.encounterString = 'test';
        stubbedRequest.text = 'test';
        stubbedRequest.authorDUZ = '000777';
        stubbedRequest.cosignerDUZ = 'test';
        stubbedRequest.patientLocalPid = 'test';
        stubbedRequest.patientLocalSiteId = '123';
        stubbedRequest.patientName = 'test';
        VCC_DASWriteNoteAndSignRQ.signersService = stubSignersService(testRecordId, signersDUZ);
        VCC_DASWriteNoteAndSignRQ.parserService = stubParserService(testProgressNote, 'test');
        VCC_DASWriteNoteAndSignRQ.utilitiesService = stubUtilService(
            '000777',
            testProgressNote,
            'VCC_Tier_II_Progress_Note'
        );
        VCC_DAS.State dasState = new VCC_DAS.State(new VCC_SiteId('123'), 'VAHC', testRecordId);
        dasState.endpoint = VCC_DAS.Endpoint.WRITE_NOTE_AND_SIGN;
        stubDas(stubbedRequest, dasState, new VCC_DASWriteNoteSignSuccessRS());

        Test.startTest();
        List<VCC_DASFlowConsolidatedEndpointResult> resultList = VCC_DASFlowWriteNoteAndSign.writeNoteAndSign(
            requestList
        );
        Test.stopTest();

        Assert.isNotNull(resultList, 'Expected resultList to be non-null.');
        Assert.areEqual(1, resultList.size(), 'Expect resultsList to be size of 1.');
        Assert.isFalse(resultList[0].isError, 'Expected isError property to be false.');
        Assert.isNull(resultList[0].errorDescription, 'Expected property to exist and be null.');
        Assert.isNull(resultList[0].errorMessage, 'Expected property to exist and be null.');
        Assert.isNull(resultList[0].errorCode, 'Expected property to exist and be null.');
        Assert.isNull(resultList[0].noteOrAddendumIen, 'Expected property to exist and be null.');
        Assert.isNull(resultList[0].text, 'Expected property to exist and be null.');
    }

    @IsTest
    static void unitWriteNoteAndSignPharm3Positive() {
        Id testRecordId = VATEST_IdFactory.get(VCC_Progress_Note__c.class);
        VCC_Progress_Note__c testProgressNote = new VCC_Progress_Note__c(Id = testRecordId);
        VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest flowRequest = generateFlowRequest(
            testRecordId,
            testProgressNote
        );
        List<String> signersDUZ = new List<String>{ '777000' };
        List<VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest> requestList = new List<VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest>{
            flowRequest
        };

        VCC_DASWriteNoteAndSignRQ stubbedRequest = new VCC_DASWriteNoteAndSignRQ();
        stubbedRequest.esig = 'test';
        stubbedRequest.providerName = 'test';
        stubbedRequest.providerLoginSiteCode = '123';
        stubbedRequest.providerUserId = 'test';
        stubbedRequest.supplementalParameters = signersDUZ;
        stubbedRequest.titleIEN = 'test';
        stubbedRequest.encounterString = 'test';
        stubbedRequest.text = 'test';
        stubbedRequest.authorDUZ = '000777';
        stubbedRequest.cosignerDUZ = 'test';
        stubbedRequest.patientLocalPid = 'test';
        stubbedRequest.patientLocalSiteId = '123';
        stubbedRequest.patientName = 'test';
        VCC_DASWriteNoteAndSignRQ.signersService = stubSignersService(testRecordId, signersDUZ);
        VCC_DASWriteNoteAndSignRQ.parserService = stubParserService(testProgressNote, 'test');
        VCC_DASWriteNoteAndSignRQ.utilitiesService = stubUtilService(
            '000777',
            testProgressNote,
            'VCC_Tier_III_Progress_Note'
        );
        VCC_DAS.State dasState = new VCC_DAS.State(new VCC_SiteId('123'), 'VAHC', testRecordId);
        dasState.endpoint = VCC_DAS.Endpoint.WRITE_NOTE_AND_SIGN;
        stubDas(stubbedRequest, dasState, new VCC_DASWriteNoteSignSuccessRS());

        Test.startTest();
        List<VCC_DASFlowConsolidatedEndpointResult> resultList = VCC_DASFlowWriteNoteAndSign.writeNoteAndSign(
            requestList
        );
        Test.stopTest();

        Assert.isNotNull(resultList, 'Expected resultList to be non-null.');
        Assert.areEqual(1, resultList.size(), 'Expect resultsList to be size of 1.');
        Assert.isFalse(resultList[0].isError, 'Expected isError property to be false.');
        Assert.isNull(resultList[0].errorDescription, 'Expected property to exist and be null.');
        Assert.isNull(resultList[0].errorMessage, 'Expected property to exist and be null.');
        Assert.isNull(resultList[0].errorCode, 'Expected property to exist and be null.');
        Assert.isNull(resultList[0].noteOrAddendumIen, 'Expected property to exist and be null.');
        Assert.isNull(resultList[0].text, 'Expected property to exist and be null.');
    }

    @IsTest
    static void unitWriteNoteAndSignMultipleRequestsPositive() {
        Id testRecordId = VATEST_IdFactory.get(VCC_Progress_Note__c.class);
        VCC_Progress_Note__c testProgressNote = new VCC_Progress_Note__c(Id = testRecordId);
        VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest flowRequest = generateFlowRequest(
            testRecordId,
            testProgressNote
        );
        List<String> signersDUZ = new List<String>{ '777000' };
        List<VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest> requestList = new List<VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest>{
            flowRequest,
            flowRequest.clone(),
            flowRequest.clone(),
            flowRequest.clone(),
            flowRequest.clone()
        };

        VCC_DASWriteNoteAndSignRQ stubbedRequest = new VCC_DASWriteNoteAndSignRQ();
        stubbedRequest.esig = 'test';
        stubbedRequest.providerName = 'test';
        stubbedRequest.providerLoginSiteCode = '123';
        stubbedRequest.providerUserId = 'test';
        stubbedRequest.supplementalParameters = signersDUZ;
        stubbedRequest.titleIEN = 'test';
        stubbedRequest.encounterString = 'test';
        stubbedRequest.text = 'test';
        stubbedRequest.authorDUZ = '000777';
        stubbedRequest.cosignerDUZ = 'test';
        stubbedRequest.patientLocalPid = 'test';
        stubbedRequest.patientLocalSiteId = '123';
        stubbedRequest.patientName = 'test';
        VCC_DASWriteNoteAndSignRQ.signersService = stubSignersService(testRecordId, signersDUZ);
        VCC_DASWriteNoteAndSignRQ.parserService = stubParserService(testProgressNote, 'test');
        VCC_DASWriteNoteAndSignRQ.utilitiesService = stubUtilService(
            '000777',
            testProgressNote,
            'VCC_Clinical_Triage_Note_Progress_Note'
        );
        VCC_DAS.State dasState = new VCC_DAS.State(new VCC_SiteId('123'), 'VAHC', testRecordId);
        dasState.endpoint = VCC_DAS.Endpoint.WRITE_NOTE_AND_SIGN;
        stubDas(stubbedRequest, dasState, new VCC_DASWriteNoteSignSuccessRS());

        Test.startTest();
        List<VCC_DASFlowConsolidatedEndpointResult> resultList = VCC_DASFlowWriteNoteAndSign.writeNoteAndSign(
            requestList
        );
        Test.stopTest();

        Assert.isNotNull(resultList, 'Expected resultList to be non-null.');
        Assert.areEqual(5, resultList.size(), 'Expect resultsList to be size of 1.');
    }

    // Negative Exception Test
    @IsTest
    static void unitWriteNoteAndSignDasException() {
        Id testRecordId = VATEST_IdFactory.get(VCC_Progress_Note__c.class);
        VCC_Progress_Note__c testProgressNote = new VCC_Progress_Note__c(Id = testRecordId);
        VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest flowRequest = generateFlowRequest(
            testRecordId,
            testProgressNote
        );
        List<String> signersDUZ = new List<String>{ '777000' };
        List<VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest> requestList = new List<VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest>{
            flowRequest
        };

        VCC_DASWriteNoteAndSignRQ stubbedRequest = new VCC_DASWriteNoteAndSignRQ();
        stubbedRequest.esig = 'test';
        stubbedRequest.providerName = 'test';
        stubbedRequest.providerLoginSiteCode = '123';
        stubbedRequest.providerUserId = 'test';
        stubbedRequest.supplementalParameters = signersDUZ;
        stubbedRequest.titleIEN = 'test';
        stubbedRequest.encounterString = 'test';
        stubbedRequest.text = 'test';
        stubbedRequest.authorDUZ = '000777';
        stubbedRequest.cosignerDUZ = 'test';
        stubbedRequest.patientLocalPid = 'test';
        stubbedRequest.patientLocalSiteId = '123';
        stubbedRequest.patientName = 'test';
        VCC_DASWriteNoteAndSignRQ.signersService = stubSignersService(testRecordId, signersDUZ);
        VCC_DASWriteNoteAndSignRQ.parserService = stubParserService(testProgressNote, 'test');
        VCC_DASWriteNoteAndSignRQ.utilitiesService = stubUtilService(
            '000777',
            testProgressNote,
            'VCC_Tier_III_Progress_Note'
        );

        VCC_DASWriteNoteSignFailureRS failureRS = new VCC_DASWriteNoteSignFailureRS();
        VCC_DASServicesTest.stubApi(
            new List<VATEST_MockedMethod>{
                VCC_DASServiceApiTest.getMockedMethodWriteNoteAndSign()
                    .withParameterValues(new List<Object>{ stubbedRequest, testRecordId })
                    .throwingException(new VCC_DASConsolidatedEndpointException(failureRS))
            }
        );

        Test.startTest();
        List<VCC_DASFlowConsolidatedEndpointResult> resultList = VCC_DASFlowWriteNoteAndSign.writeNoteAndSign(
            requestList
        );
        Test.stopTest();

        Assert.isNotNull(resultList, 'Expected resultList to be non null value.');
        Assert.isNotNull(resultList[0], 'Expected first element to not be null.');
        Assert.areEqual(1, resultList.size(), 'Expected size of result list to be 1.');
        Assert.isTrue(resultList[0].isError, 'Expected isError propety to be true.');
        Assert.isNotNull(resultList[0].errorDescription, 'Expected errorDescription to not be null.');
        Assert.isNull(resultList[0].errorMessage, 'Expected errorMessage to exist and be null.');
        Assert.isNull(resultList[0].errorCode, 'Expected errorCode to exist and be null.');
        Assert.isNull(resultList[0].noteOrAddendumIen, 'Expected noteOrAddendumIen to exist and be null.');
        Assert.isNull(resultList[0].text, 'Expected text to exist and be null.');
    }

    @IsTest
    static void unitWriteNoteAndSignGeneralException() {
        Id testRecordId = VATEST_IdFactory.get(VCC_Progress_Note__c.class);
        VCC_Progress_Note__c testProgressNote = new VCC_Progress_Note__c(Id = testRecordId);
        VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest flowRequest = generateFlowRequest(
            testRecordId,
            testProgressNote
        );
        List<String> signersDUZ = new List<String>{ '777000' };
        List<VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest> requestList = new List<VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest>{
            flowRequest
        };

        VCC_DASWriteNoteAndSignRQ stubbedRequest = new VCC_DASWriteNoteAndSignRQ();
        stubbedRequest.esig = 'test';
        stubbedRequest.providerName = 'test';
        stubbedRequest.providerLoginSiteCode = '123';
        stubbedRequest.providerUserId = 'test';
        stubbedRequest.supplementalParameters = signersDUZ;
        stubbedRequest.titleIEN = 'test';
        stubbedRequest.encounterString = 'test';
        stubbedRequest.text = 'test';
        stubbedRequest.authorDUZ = '000777';
        stubbedRequest.cosignerDUZ = 'test';
        stubbedRequest.patientLocalPid = 'test';
        stubbedRequest.patientLocalSiteId = '123';
        stubbedRequest.patientName = 'test';
        VCC_DASWriteNoteAndSignRQ.signersService = stubSignersService(testRecordId, signersDUZ);
        VCC_DASWriteNoteAndSignRQ.parserService = stubParserService(testProgressNote, 'test');
        VCC_DASWriteNoteAndSignRQ.utilitiesService = stubUtilService(
            '000777',
            testProgressNote,
            'VCC_Tier_III_Progress_Note'
        );

        VCC_DASServicesTest.stubApi(
            new List<VATEST_MockedMethod>{
                VCC_DASServiceApiTest.getMockedMethodWriteNoteAndSign()
                    .withParameterValues(new List<Object>{ stubbedRequest, testRecordId })
                    .throwingException()
            }
        );

        Test.startTest();
        List<VCC_DASFlowConsolidatedEndpointResult> resultList = VCC_DASFlowWriteNoteAndSign.writeNoteAndSign(
            requestList
        );
        Test.stopTest();

        Assert.isNotNull(resultList, 'Expected resultList to be non null value.');
        Assert.isNotNull(resultList[0], 'Expected first element to not be null.');
        Assert.areEqual(1, resultList.size(), 'Expected size of result list to be 1.');
        Assert.isTrue(resultList[0].isError, 'Expected isError propety to be true.');
        Assert.isNotNull(resultList[0].errorDescription, 'Expected errorDescription to not be null.');
        Assert.isNull(resultList[0].errorMessage, 'Expected errorMessage to exist and be null.');
        Assert.isNull(resultList[0].errorCode, 'Expected errorCode to exist and be null.');
        Assert.isNull(resultList[0].noteOrAddendumIen, 'Expected noteOrAddendumIen to exist and be null.');
        Assert.isNull(resultList[0].text, 'Expected text to exist and be null.');
    }

    // Negative Input Tests
    @IsTest
    static void unitWriteNoteAndSignNullIParamNegative() {
        Test.startTest();
        try {
            List<VCC_DASFlowConsolidatedEndpointResult> results = VCC_DASFlowWriteNoteAndSign.writeNoteAndSign(null);
            Assert.areEqual(0, results.size(), 'Expected empty list as result.');
        } catch (Exception thrownException) {
            Assert.fail(
                'Expected no exception, instead found ' +
                    thrownException.getTypeName() +
                    '\n' +
                    thrownException.getStackTraceString()
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void unitWriteNoteAndSignEmptyListNegative() {
        Test.startTest();
        try {
            List<VCC_DASFlowConsolidatedEndpointResult> results = VCC_DASFlowWriteNoteAndSign.writeNoteAndSign(
                new List<VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest>()
            );
            Assert.areEqual(0, results.size(), 'Expected empty list as result.');
        } catch (Exception thrownException) {
            Assert.fail(
                'Expected no exception, instead found ' +
                    thrownException.getTypeName() +
                    '\n' +
                    thrownException.getStackTraceString()
            );
        }
        Test.stopTest();
    }
}
