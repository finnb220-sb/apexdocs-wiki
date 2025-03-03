/**
 * @description Test class for VCC_DASWriteNoteAndSignRQ
 * @author      BAH
 * @since       April 15 2024
 * @see         VCC_DASWriteNoteAndSignRQ
 * @see         VCC_DASBaseRQ
 * @see         VCC_DASServiceParser
 * @see         VCC_DASServiceUtilities
 * @see         VCC_SignersService
 */
@IsTest
private class VCC_DASWriteNoteAndSignRQTest {
    /**
     * @description  Used to stub the parser service attribute in VCC_DASWriteNoteAndSignRQ
     * @param progressNote parameter for parse method
     * @param text   progress note text parameter for parse method
     * @return             `VCC_DASServiceParser`
     */
    @TestVisible
    private static VCC_DASServiceParser stubParserService(VCC_Progress_Note__c progressNote, String text) {
        VCC_DASServiceParser parserStub = (VCC_DASServiceParser) new VATEST_StubBuilder(VCC_DASServiceParser.class)
            .mockingMethodCall('parse', Sobject.class)
            .withParameterValues(progressNote)
            .returning(text)
            .defineStub();
        return parserStub;
    }

    /**
     * @description     Used to stub the utility service attribute in VCC_DASWriteNoteAndSignRQ
     * @param authorDUZ    Provider's Designated User Id number return value for getProviderDuz method
     * @param progressNote  Parameter for getRecordTypeApiName method
     * @param siteCode     Parameter for getProviderDuz method
     * @return             `VCC_DASServiceUtilities`
     */
    @TestVisible
    private static VCC_DASServiceUtilities stubUtilService(
        String authorDUZ,
        VCC_Progress_Note__c progressNote,
        String siteCode
    ) {
        VCC_DASServiceUtilities utilStub = (VCC_DASServiceUtilities) new VATEST_StubBuilder(
                VCC_DASServiceUtilities.class
            )
            .mockingMethodCall('getProviderDuz', Id.class, String.class)
            .withParameterValues(UserInfo.getUserId(), siteCode)
            .returning(authorDUZ)
            .mockingMethodCall('getRecordTypeApiName', SObject.class)
            .withParameterValues(progressNote)
            .returning('VCC_Clinical_Triage_Note_Progress_Note')
            .defineStub();
        return utilStub;
    }

    /**
     * @description Used to stub the signers service attribute in VCC_DASWriteNoteAndSignRQ
     * @param recordId   progress note record id parameter for getSignerDuzListForCallout
     * @param signersDUZ   `List<String>` of signers duz numbers for return value
     * @return           `VCC_SignersService`
     */
    @TestVisible
    private static VCC_SignersService stubSignersService(Id recordId, List<String> signersDUZ) {
        VCC_SignersService signersStub = (VCC_SignersService) new VATEST_StubBuilder(VCC_SignersService.class)
            .mockingMethodCall('getSignerDuzListForCallout', Id.class)
            .withParameterValues(recordId)
            .returning(signersDUZ)
            .defineStub();
        return signersStub;
    }

    @IsTest
    private static void unitConstructorWithParamsPositive() {
        Id testRecordId = VATEST_IdFactory.get(VCC_Progress_Note__c.class);
        VCC_Progress_Note__c stubProgressNote = new VCC_Progress_Note__c(Id = testRecordId);
        List<String> signersDUZ = new List<String>{ '777000' };
        String testString = 'test';

        VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest testFlowRequest = new VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest();
        testFlowRequest.recordId = testRecordId;
        testFlowRequest.progressNote = stubProgressNote;
        testFlowRequest.titleIEN = testString;
        testFlowRequest.encounterString = testString;
        testFlowRequest.authorDUZ = '000777';
        testFlowRequest.cosignerDUZ = testString;
        testFlowRequest.providerLoginSiteCode = testString;
        testFlowRequest.providerName = testString;
        testFlowRequest.providerUserId = testString;
        testFlowRequest.patientLocalPid = testString;
        testFlowRequest.patientLocalSiteId = '983';
        testFlowRequest.patientName = testString;
        testFlowRequest.esig = testString;

        VCC_DASWriteNoteAndSignRQ.signersService = stubSignersService(testRecordId, signersDUZ);
        VCC_DASWriteNoteAndSignRQ.parserService = stubParserService(stubProgressNote, testString);
        VCC_DASWriteNoteAndSignRQ.utilitiesService = stubUtilService('000777', stubProgressNote, '983');

        Test.startTest();
        VCC_DASWriteNoteAndSignRQ writeNoteAndSignRQ = new VCC_DASWriteNoteAndSignRQ(testFlowRequest);
        Test.stopTest();
        Assert.isNotNull(
            writeNoteAndSignRQ,
            'Expected writeNoteAndSignRQ to be constructed successfully and not be null.'
        );
        Assert.areEqual(testString, writeNoteAndSignRQ.titleIEN, 'Expected titleIEN to be test.');
        Assert.areEqual(testString, writeNoteAndSignRQ.encounterString, 'Expected encounterString to be test.');
        Assert.areEqual(testString, writeNoteAndSignRQ.cosignerDUZ, 'Expected cosignerDUZ to be test.');
        Assert.areEqual(
            testString,
            writeNoteAndSignRQ.providerLoginSiteCode,
            'Expected providerLoginSiteCode to be test.'
        );
        Assert.areEqual(testString, writeNoteAndSignRQ.providerUserId, 'Expected providerUserId to be test.');
        Assert.areEqual(testString, writeNoteAndSignRQ.patientLocalPid, 'Expected patientLocalPid to be test.');
        Assert.areEqual('983', writeNoteAndSignRQ.patientLocalSiteId, 'Expected patientLocalSiteId to be 983.');
        Assert.areEqual(testString, writeNoteAndSignRQ.esig, 'Expected esig to be test.');
        Assert.areEqual(testString, writeNoteAndSignRQ.providerName, 'Expected providerName to be test.');
        Assert.areEqual(testString, writeNoteAndSignRQ.patientName, 'Expected patientName to be test.');
        Assert.areEqual(
            signersDUZ,
            writeNoteAndSignRQ.supplementalParameters,
            'Expected supplementalParameters to be a list with an element 777000'
        );
        Assert.areEqual(testString, writeNoteAndSignRQ.text, 'Expected text to be test.');
        Assert.areEqual('000777', writeNoteAndSignRQ.authorDUZ, 'Expected authorDUZ to be 000777.');
    }

    @IsTest
    private static void unitConstructorWithParamsNegative() {
        VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest testFlowRequest = new VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest();

        VCC_DASWriteNoteAndSignRQ.signersService = stubSignersService(null, new List<String>());
        VCC_DASWriteNoteAndSignRQ.parserService = stubParserService(null, '');
        VCC_DASWriteNoteAndSignRQ.utilitiesService = stubUtilService('', null, '');

        Test.startTest();
        VCC_DASWriteNoteAndSignRQ writeNoteAndSignRQ = new VCC_DASWriteNoteAndSignRQ(testFlowRequest);
        Test.stopTest();
        Assert.isNotNull(
            writeNoteAndSignRQ,
            'Expected writeNoteAndSignRQ to be constructed successfully and not be null.'
        );
        Assert.isTrue(String.isBlank(writeNoteAndSignRQ.text), 'Expected text to be a non-null value');
        Assert.isTrue(String.isBlank(writeNoteAndSignRQ.authorDUZ), 'Expected authorDUZ to be a non-null value');
        Assert.isTrue(String.isBlank(writeNoteAndSignRQ.titleIEN), 'Expected titleIEN to be a non-null value');
        Assert.isTrue(String.isBlank(writeNoteAndSignRQ.esig), 'Expected esig to be a non-null value');
        Assert.isTrue(
            writeNoteAndSignRQ.supplementalParameters.isEmpty(),
            'Expected supplementalParameters to be a non-null value'
        );
        Assert.isTrue(String.isBlank(writeNoteAndSignRQ.providerName), 'Expected providerName to be a non-null value');
        Assert.isTrue(
            String.isBlank(writeNoteAndSignRQ.providerUserId),
            'Expected providerUserId to be a non-null value'
        );
        Assert.isTrue(
            String.isBlank(writeNoteAndSignRQ.providerLoginSiteCode),
            'Expected providerLoginSiteCode to be a non-null value'
        );
        Assert.isTrue(
            String.isBlank(writeNoteAndSignRQ.encounterString),
            'Expected encounterString to be a non-null value'
        );
        Assert.isTrue(String.isBlank(writeNoteAndSignRQ.cosignerDUZ), 'Expected cosignerDUZ to be a non-null value');
        Assert.isTrue(
            String.isBlank(writeNoteAndSignRQ.patientLocalPid),
            'Expected patientLocalPid to be a non-null value'
        );
        Assert.isTrue(
            String.isBlank(writeNoteAndSignRQ.patientLocalSiteId),
            'Expected patientLocalSiteId to be a non-null value'
        );
        Assert.isTrue(String.isBlank(writeNoteAndSignRQ.patientName), 'Expected patientName to be a non-null value');
    }

    @IsTest
    private static void unitConstructorPositive() {
        Test.startTest();
        try {
            VCC_DASWriteNoteAndSignRQ writeNoteAndSignRQ = new VCC_DASWriteNoteAndSignRQ();
            Assert.isNotNull(
                writeNoteAndSignRQ,
                'unitConstructorPositive test failed. Expected non-null value for constructor.'
            );
            Assert.isNotNull(
                writeNoteAndSignRQ.supplementalParameters,
                'unitConstructorPositive test failed. Expected non-null value for constructor.'
            );
        } catch (Exception thrownException) {
            Assert.fail(
                'Expected no exception, but instead found: ' +
                    thrownException.getTypeName() +
                    '\n' +
                    thrownException.getStackTraceString()
            );
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitConstructorNegative() {
        Test.startTest();
        VCC_DASWriteNoteAndSignRQ writeNoteAndSignEmptyRQ;
        Test.stopTest();
        Assert.isNull(writeNoteAndSignEmptyRQ, 'unitConstructorNegative test failed. Expected constructor to be null.');
    }

    @IsTest
    private static void unitReadServicePropertiesPositive() {
        Test.startTest();
        Assert.areEqual(
            VCC_DAS.SERVICES.UTILITIES,
            VCC_DASWriteNoteAndSignRQ.utilitiesService,
            'Expected utilitiesService to be equal to VCC_DAS.SERVICES.UTILITIES.'
        );
        Assert.areEqual(
            VCC_DAS.SERVICES.PARSER,
            VCC_DASWriteNoteAndSignRQ.parserService,
            'Expected parserService to be equal to VCC_DAS.SERVICES.PARSER.'
        );
        Assert.areEqual(
            VCC_SignersService.instance,
            VCC_DASWriteNoteAndSignRQ.signersService,
            'Expected signersService to be equal to VCC_SignersService.instance.'
        );
        Test.stopTest();
    }

    @IsTest
    private static void unitReadNotePropertiesPositive() {
        Test.startTest();
        try {
            VCC_DASWriteNoteAndSignRQ writeNoteAndSignRQ = new VCC_DASWriteNoteAndSignRQ();
            Assert.isTrue(String.isBlank(writeNoteAndSignRQ.esig), 'Expected esig to be a non-null value');
            Assert.isTrue(
                String.isBlank(writeNoteAndSignRQ.providerName),
                'Expected providerName to be a non-null value'
            );
            Assert.isTrue(
                String.isBlank(writeNoteAndSignRQ.providerUserId),
                'Expected providerUserId to be a non-null value'
            );
            Assert.isTrue(
                String.isBlank(writeNoteAndSignRQ.providerLoginSiteCode),
                'Expected providerLoginSiteCode to be a non-null value'
            );
            Assert.isTrue(
                writeNoteAndSignRQ.supplementalParameters.isEmpty(),
                'Expected supplementalParameters to be a non-null value'
            );
            Assert.isTrue(String.isBlank(writeNoteAndSignRQ.titleIEN), 'Expected titleIEN to be a non-null value');
            Assert.isTrue(
                String.isBlank(writeNoteAndSignRQ.encounterString),
                'Expected encounterString to be a non-null value'
            );
            Assert.isTrue(String.isBlank(writeNoteAndSignRQ.text), 'Expected text to be a non-null value');
            Assert.isTrue(String.isBlank(writeNoteAndSignRQ.authorDUZ), 'Expected authorDUZ to be a non-null value');
            Assert.isTrue(
                String.isBlank(writeNoteAndSignRQ.cosignerDUZ),
                'Expected cosignerDUZ to be a non-null value'
            );
            Assert.isTrue(
                String.isBlank(writeNoteAndSignRQ.patientLocalPid),
                'Expected patientLocalPid to be a non-null value'
            );
            Assert.isTrue(
                String.isBlank(writeNoteAndSignRQ.patientLocalSiteId),
                'Expected patientLocalSiteId to be a non-null value'
            );
            Assert.isTrue(
                String.isBlank(writeNoteAndSignRQ.patientName),
                'Expected patientName to be a non-null value'
            );
        } catch (Exception thrownException) {
            Assert.fail(
                'Expected no exception, but instead found: ' +
                    thrownException.getTypeName() +
                    '\n' +
                    thrownException.getStackTraceString()
            );
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitWriteNotePropertiesPositive() {
        Test.startTest();
        try {
            String testEsig = 'test esig';
            String testProviderName = 'test provider name';
            String testProviderUserId = 'test provider user id';
            String testProviderLoginSiteCode = 'test provider login site code';
            List<String> testSupplementalParameters = new List<String>{ 'test supplemental parameter' };
            String testTitleIEN = 'test';
            String testEncounterString = 'test';
            String testText = 'test';
            String testAuthorDUZ = 'test';
            String testCosignerDUZ = 'test';
            String testPatientLocalPid = 'test';
            String testPatientLocalSiteId = 'test';
            String testPatientName = 'test';
            VCC_DASWriteNoteAndSignRQ writeNoteAndSignRQ = new VCC_DASWriteNoteAndSignRQ();
            writeNoteAndSignRQ.esig = testEsig;
            writeNoteAndSignRQ.providerName = testProviderName;
            writeNoteAndSignRQ.providerLoginSiteCode = testProviderLoginSiteCode;
            writeNoteAndSignRQ.providerUserId = testProviderUserId;
            writeNoteAndSignRQ.supplementalParameters = testSupplementalParameters;
            writeNoteAndSignRQ.titleIEN = testTitleIEN;
            writeNoteAndSignRQ.encounterString = testEncounterString;
            writeNoteAndSignRQ.text = testText;
            writeNoteAndSignRQ.authorDUZ = testAuthorDUZ;
            writeNoteAndSignRQ.cosignerDUZ = testCosignerDUZ;
            writeNoteAndSignRQ.patientLocalPid = testPatientLocalPid;
            writeNoteAndSignRQ.patientLocalSiteId = testPatientLocalSiteId;
            writeNoteAndSignRQ.patientName = testPatientName;
            Assert.areEqual(testTitleIEN, writeNoteAndSignRQ.titleIEN, 'Expected to find test value on property.');
            Assert.areEqual(
                testEncounterString,
                writeNoteAndSignRQ.encounterString,
                'Expected to find test value on property.'
            );
            Assert.areEqual(testText, writeNoteAndSignRQ.text, 'Expected to find test value on property.');
            Assert.areEqual(testAuthorDUZ, writeNoteAndSignRQ.authorDUZ, 'Expected to find test value on property.');
            Assert.areEqual(
                testCosignerDUZ,
                writeNoteAndSignRQ.cosignerDUZ,
                'Expected to find test value on property.'
            );
            Assert.areEqual(
                testPatientLocalPid,
                writeNoteAndSignRQ.patientLocalPid,
                'Expected to find test value on property.'
            );
            Assert.areEqual(
                testPatientLocalSiteId,
                writeNoteAndSignRQ.patientLocalSiteId,
                'Expected to find test value on property.'
            );
            Assert.areEqual(
                testPatientName,
                writeNoteAndSignRQ.patientName,
                'Expected to find test value on property.'
            );
            Assert.areEqual(testEsig, writeNoteAndSignRQ.esig, 'Expected to find test value on property.');
            Assert.areEqual(
                testProviderName,
                writeNoteAndSignRQ.providerName,
                'Expected to find test value on property.'
            );
            Assert.areEqual(
                testProviderLoginSiteCode,
                writeNoteAndSignRQ.providerLoginSiteCode,
                'Expected to find test value on property.'
            );
            Assert.areEqual(
                testSupplementalParameters,
                writeNoteAndSignRQ.supplementalParameters,
                'Expected to find test value on property.'
            );
            Assert.areEqual(
                testProviderUserId,
                writeNoteAndSignRQ.providerUserId,
                'Expected to find test value on property.'
            );
        } catch (Exception thrownException) {
            Assert.fail(
                'Expected no exception, but instead found: ' +
                    thrownException.getTypeName() +
                    '\n' +
                    thrownException.getStackTraceString()
            );
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitIsValidPositive() {
        Test.startTest();
        VCC_DASWriteNoteAndSignRQ writeNoteAndSignRQ = new VCC_DASWriteNoteAndSignRQ();
        writeNoteAndSignRQ.titleIEN = 'test';
        writeNoteAndSignRQ.encounterString = 'test';
        writeNoteAndSignRQ.text = 'test note';
        writeNoteAndSignRQ.authorDUZ = '432455';
        writeNoteAndSignRQ.providerLoginSiteCode = '983';
        writeNoteAndSignRQ.providerUserId = '4324589h97hk5';
        writeNoteAndSignRQ.patientLocalPid = '432405';
        writeNoteAndSignRQ.patientLocalSiteId = '983';
        writeNoteAndSignRQ.supplementalParameters = new List<String>();
        writeNoteAndSignRQ.esig = 'TESTER';
        Test.stopTest();
        Assert.areEqual(true, writeNoteAndSignRQ.isValid(), 'unitIsValidPositive test failed. Expected true.');
        Assert.areEqual('test', writeNoteAndSignRQ.titleIEN, 'Expected title IEN to be test.');
        Assert.areEqual('test', writeNoteAndSignRQ.encounterString, 'Expected encounter string to be test.');
        Assert.areEqual('test note', writeNoteAndSignRQ.text, 'Expected text to be test note.');
        Assert.areEqual('432455', writeNoteAndSignRQ.authorDUZ, 'Expected author DUZ to be 432455.');

        Assert.areEqual(
            '983',
            writeNoteAndSignRQ.providerLoginSiteCode,
            'Expected provider login site code to be 983.'
        );
        Assert.areEqual(
            '4324589h97hk5',
            writeNoteAndSignRQ.providerUserId,
            'Expected provider user id to be 4324589h97hk5.'
        );
        Assert.areEqual('432405', writeNoteAndSignRQ.patientLocalPid, 'Expected patient Local Pid to be 432405.');
        Assert.areEqual('983', writeNoteAndSignRQ.patientLocalSiteId, 'Expected patient local site id to be 983.');
        Assert.areEqual('TESTER', writeNoteAndSignRQ.esig, 'Expected esig to be TESTER.');
        Assert.areEqual(
            new List<String>(),
            writeNoteAndSignRQ.supplementalParameters,
            'Expected supplementalParameters to be empty list.'
        );
    }

    @IsTest
    private static void unitIsValidNegative() {
        Test.startTest();
        VCC_DASWriteNoteAndSignRQ writeNoteAndSignRQ = new VCC_DASWriteNoteAndSignRQ();
        Test.stopTest();
        Assert.areEqual(false, writeNoteAndSignRQ.isValid(), 'unitIsValidNegative test failed. Expected false.');
    }

    @IsTest
    private static void unitIsNoteInfoValidNegative() {
        Test.startTest();
        VCC_DASWriteNoteAndSignRQ writeNoteAndSignRQ = new VCC_DASWriteNoteAndSignRQ();
        writeNoteAndSignRQ.titleIEN = 'test';
        writeNoteAndSignRQ.esig = 'TESTER';
        writeNoteAndSignRQ.providerLoginSiteCode = '983';
        writeNoteAndSignRQ.providerUserId = '4324589h97hk5';
        Test.stopTest();
        Assert.areEqual(false, writeNoteAndSignRQ.isValid(), 'unitIsNoteInfoValid test failed. Expected false');
    }

    @IsTest
    /**
     * @description Found that the flow will give a number with comma's in it ex: 512,122
     * this test ensures they're being removed
     */
    private static void unitFlowRequestConstructorPatientPidWithCommaNegative() {
        VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest dasFlowWriteNoteAndSignRequest = new VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest();
        dasFlowWriteNoteAndSignRequest.patientLocalPid = '512,123,999';

        Test.startTest();
        VCC_DASWriteNoteAndSignRQ writeNoteAndSignRq = new VCC_DASWriteNoteAndSignRQ(dasFlowWriteNoteAndSignRequest);
        Assert.isFalse(
            writeNoteAndSignRq.patientLocalPid.contains(','),
            'Expected writeNoteAndSignRq.patientLocalPid to contain no commas'
        );
        Test.stopTest();
    }
}
