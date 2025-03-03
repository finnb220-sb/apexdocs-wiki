/**
 * @description Test class for VCC_VdifClient

 * @see VCC_BaseClient
 * @see VCC_HttpHeaderB3
 * @see VCC_VdifGetAdditionalSignersRQ
 * @see VCC_VdifSelectPatientRQ
 * @see VCC_VdifSignNoteRQ
 * @see VCC_VdifGetProvidersBySiteRQ
 * @see VCC_VdifCreateAddendumRQ
 * @see VCC_VdifIsValidEsigRQ
 * @see VCC_VdifSaveNoteAndEncounterRQ
 * @see VCC_VdifWriteNoteRQ
 * @see VCC_VdifGetAdditionalSignersRS
 * @see VCC_VdifSelectPatientRS
 * @see VCC_VdifSignNoteRS
 * @see VCC_VdifGetProvidersBySiteRS
 * @see VCC_VdifCreateAddendumRS
 * @see VCC_VdifIsValidEsigRS
 * @see VCC_VdifSaveNoteAndEncounterRS
 * @see VCC_VdifWriteNoteRS
 */

@IsTest
private class VCC_VdifClientTest {
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

    private static User createTestTraineeUser() {
        return (new VATEST_UserBuilder())
            .withStandardData()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSets(new Set<String>(new List<String>{ 'VAHC_Super_User', 'VCC_Trainee' }))
            .build(true);
    }

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

    @IsTest
    private static void unitGenerateB3HeaderPositive() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            VCC_VdifGetAdditionalSignersRQ additionalSignerRQ = new VCC_VdifGetAdditionalSignersRQ();
            additionalSignerRQ.recordId = createProgressNoteId();

            VCC_VdifClient vdifClient = new VCC_VdifClient();
            vdifClient.serviceName = 'vccVdifGetAdditionalSigners';
            VCC_HttpHeaderB3 b3Header = vdifClient.generateB3Header(additionalSignerRQ);

            Assert.isNotNull(b3Header, 'Expected b3Header to be constructed successfully and not be null.');
            Assert.areEqual(
                VCC_HttpHeaderB3.VCC_HEADER_NAME_B3,
                b3Header.name,
                'Expected name to be equal to VCC_HEADER_NAME_B3 label.'
            );
            Assert.isTrue(
                (b3Header.value.contains('GetAdditionalSigners;') &&
                b3Header.value.contains((String) additionalSignerRQ.recordId)),
                'Expected value to contain endpoint name and record id.'
            );
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitGenerateB3HeaderNegative() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            try {
                VCC_VdifGetAdditionalSignersRQ additionalSignerRQ = new VCC_VdifGetAdditionalSignersRQ();
                additionalSignerRQ.recordId = createProgressNoteId();
                (new VCC_VdifClient()).generateB3Header(additionalSignerRQ);
                Assert.fail('Expected InstantiationException was not thrown.');
            } catch (VCC_TransactionId.InstantiationException thrownException) {
                Assert.isTrue(
                    thrownException.getMessage().contains(VCC_TransactionId.NULL_INPUT_EXCEPTION_MESSAGE),
                    'Expected exception message to contain string defined in VCC_TransactionId.NULL_INPUT_EXCEPTION_MESSAGE'
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitCreateHttpRequestPositive() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            VCC_VdifGetAdditionalSignersRQ getAdditionalSignersRQ = new VCC_VdifGetAdditionalSignersRQ(
                'test',
                'test',
                'test',
                'test',
                new List<String>{ 'test' }
            );
            getAdditionalSignersRQ.recordId = createProgressNoteId();
            VCC_VdifClient vdifClient = new VCC_VdifClient();
            vdifClient.serviceName = 'vccVdifGetAdditionalSigners';
            HttpRequest request = vdifClient.createHttpRequest('POST', getAdditionalSignersRQ);
            Assert.isNotNull(request.getHeader('b3'), 'Expected b3 header to not be null.');
            Assert.isTrue(
                (request.getHeader('b3').contains(getAdditionalSignersRQ.recordId) &&
                request.getHeader('b3').contains('GetAdditionalSigners')),
                'Expected b3Header to contain endpoint name and record Id'
            );
            Assert.areEqual('x-sfTransactionId', VCC_VdifClient.VDIF_TRANSACTION_ID_KEY, 'Expected x-sfTransactionId.');
            Assert.areEqual(
                System.Request.getCurrent().getRequestId(),
                request.getHeader(VCC_VdifClient.VDIF_TRANSACTION_ID_KEY),
                'Expected matching values.'
            );
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitCreateHttpRequestNegative() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            try {
                VCC_VdifGetAdditionalSignersRQ getAdditionalSignersRQ = new VCC_VdifGetAdditionalSignersRQ(
                    'test',
                    'test',
                    'test',
                    'test',
                    new List<String>{ 'test' }
                );

                (new VCC_VdifClient()).createHttpRequest('POST', getAdditionalSignersRQ);
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
    private static void unitGetAdditionalSignersPositive() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_vdifGetAdditionalSignersMockResponse');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_VdifClient vdifClient = new VCC_VdifClient(
            new Set<VCC_BaseClient.ClientOption>{ VCC_BaseClient.ClientOption.DEBUG_MODE }
        );

        VCC_VdifGetAdditionalSignersRQ getAdditionalSignersRQ = new VCC_VdifGetAdditionalSignersRQ(
            'test',
            'test',
            'test',
            'test',
            new List<String>{ 'test' }
        );
        getAdditionalSignersRQ.recordId = createProgressNoteId();
        VCC_VdifGetAdditionalSignersRS getAdditionalSignersRS;
        Exception unexpectedException;

        System.runAs(createTestAdminUser()) {
            Test.startTest();
            try {
                getAdditionalSignersRS = vdifClient.getAdditionalSigners(getAdditionalSignersRQ);
            } catch (Exception thrownException) {
                unexpectedException = thrownException;
            }
            Test.stopTest();
        }
        Assert.isTrue(unexpectedException == null, 'An exception was thrown unexpectedly.');
        Assert.isTrue(getAdditionalSignersRS.taggedTextArray != null, 'Response not deserialized as expected.');
    }

    @IsTest
    private static void unitGetAdditionalSignersNegative() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_badResponse');
        mock.setStatusCode(504);
        Test.setMock(HttpCalloutMock.class, mock);

        String message;

        VCC_VdifClient vdifClient = new VCC_VdifClient(
            new Set<VCC_BaseClient.ClientOption>{ VCC_BaseClient.ClientOption.DEBUG_MODE }
        );

        VCC_VdifGetAdditionalSignersRQ invalidRQ = new VCC_VdifGetAdditionalSignersRQ();
        new VCC_VdifGetAdditionalSignersRQ('test', 'test', 'test', 'test', new List<String>{ 'test' });

        VCC_VdifGetAdditionalSignersRS getAdditionalSignersRS;
        VCC_VdifClient.InvalidRequestException expectedRQException;
        System.runAs(createTestAdminUser()) {
            Test.startTest();
            try {
                getAdditionalSignersRS = vdifClient.getAdditionalSigners(invalidRQ);
            } catch (VCC_VdifClient.InvalidRequestException thrownException) {
                expectedRQException = thrownException;
                message = 'exception thrown';
            }
        }
        Test.stopTest();
        Assert.isTrue(message != null, 'exception thrown');
        Assert.isTrue(expectedRQException != null, 'Expected exception was not caught.');
        Assert.isTrue(getAdditionalSignersRS == null, 'Parsing was unexpectedly successful.');
    }

    @IsTest
    private static void unitCreateAddendumPositive() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_vdifCreateAddendumMockResponse');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_VdifClient vdifClient = new VCC_VdifClient(
            new Set<VCC_BaseClient.ClientOption>{ VCC_BaseClient.ClientOption.DEBUG_MODE }
        );

        VCC_VdifCreateAddendumRQ createAddendumRQ = new VCC_VdifCreateAddendumRQ(
            'test',
            'test',
            'test',
            'test',
            'test'
        );
        createAddendumRQ.recordId = createProgressNoteId();
        VCC_VdifCreateAddendumRS createAddendumRS;
        Exception unexpectedException;
        System.runAs(createTestAdminUser()) {
            Test.startTest();
            try {
                createAddendumRS = vdifClient.createAddendum(createAddendumRQ);
            } catch (Exception thrownException) {
                unexpectedException = thrownException;
            }
            Test.stopTest();
        }
        Assert.isTrue(unexpectedException == null, 'An exception was thrown unexpectedly.');
        Assert.isTrue(createAddendumRS.createAddendumTextTO != null, 'Response not deserialized as expected.');
    }

    @IsTest
    private static void unitCreateAddendumNegative() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_badResponse');
        mock.setStatusCode(504);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_VdifClient vdifClient = new VCC_VdifClient(
            new Set<VCC_BaseClient.ClientOption>{ VCC_BaseClient.ClientOption.DEBUG_MODE }
        );
        VCC_VdifCreateAddendumRQ invalidRQ = new VCC_VdifCreateAddendumRQ();
        VCC_VdifCreateAddendumRS createAddendumRS;
        VCC_VdifClient.InvalidRequestException expectedRQException;
        System.runAs(createTestAdminUser()) {
            Test.startTest();
            try {
                createAddendumRS = vdifClient.createAddendum(invalidRQ);
            } catch (VCC_VdifClient.InvalidRequestException thrownException) {
                expectedRQException = thrownException;
            }
            Test.stopTest();
        }
        Assert.isTrue(expectedRQException != null, 'Expected exception was not caught.');
        Assert.isTrue(createAddendumRS == null, 'Parsing was unexpectedly successful.');
    }

    @IsTest
    private static void unitIsValidEsigPositive() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_vdifIsValidEsigMockResponse');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_VdifClient vdifClient = new VCC_VdifClient(
            new Set<VCC_BaseClient.ClientOption>{ VCC_BaseClient.ClientOption.DEBUG_MODE }
        );

        VCC_VdifIsValidEsigRQ isValidEsigRQ = new VCC_VdifIsValidEsigRQ('test', 'test', 'test', 'test');
        isValidEsigRQ.recordId = createProgressNoteId();
        VCC_VdifIsValidEsigRS isValidEsigRS;
        Exception unexpectedException;
        System.runAs(createTestAdminUser()) {
            Test.startTest();
            try {
                isValidEsigRS = vdifClient.isValidEsig(isValidEsigRQ);
            } catch (Exception thrownException) {
                unexpectedException = thrownException;
            }
            Test.stopTest();
        }
        Assert.isTrue(unexpectedException == null, 'An exception was thrown unexpectedly.');
        Assert.isTrue(isValidEsigRS.isValidEsigTextTO != null, 'Response not deserialized as expected.');
    }

    @IsTest
    private static void unitIsValidEsigTrainingModePositive() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_vdifIsValidEsigMockResponse');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_VdifClient vdifClient = new VCC_VdifClient(
            new Set<VCC_BaseClient.ClientOption>{ VCC_BaseClient.ClientOption.DEBUG_MODE }
        );

        VCC_VdifIsValidEsigRQ isValidEsigRQ = new VCC_VdifIsValidEsigRQ('test', 'test', 'test', 'test');
        isValidEsigRQ.recordId = createProgressNoteId();
        VCC_VdifIsValidEsigRS isValidEsigRS;
        Exception unexpectedException;

        System.runAs(createTestTraineeUser()) {
            Test.startTest();
            try {
                isValidEsigRS = vdifClient.isValidEsig(isValidEsigRQ);
            } catch (Exception thrownException) {
                unexpectedException = thrownException;
            }
            Test.stopTest();
        }
        Assert.isTrue(unexpectedException == null, 'An exception was thrown unexpectedly.');
        Assert.isTrue(isValidEsigRS.isValidEsigTextTO != null, 'Response not deserialized as expected.');
    }

    @IsTest
    private static void unitIsValidEsigNegative() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_badResponse');
        mock.setStatusCode(504);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_VdifClient vdifClient = new VCC_VdifClient(
            new Set<VCC_BaseClient.ClientOption>{ VCC_BaseClient.ClientOption.DEBUG_MODE }
        );
        VCC_VdifIsValidEsigRQ invalidRQ = new VCC_VdifIsValidEsigRQ();
        VCC_VdifIsValidEsigRS isValidEsigRS;
        VCC_VdifClient.InvalidRequestException expectedRQException;
        System.runAs(createTestAdminUser()) {
            Test.startTest();
            try {
                isValidEsigRS = vdifClient.isValidEsig(invalidRQ);
            } catch (VCC_VdifClient.InvalidRequestException thrownException) {
                expectedRQException = thrownException;
            }
            Test.stopTest();
        }
        Assert.isTrue(expectedRQException != null, 'Expected exception was not caught.');
        Assert.isTrue(isValidEsigRS == null, 'Parsing was unexpectedly successful.');
    }

    @IsTest
    private static void unitSaveNoteAndEncounterPositive() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_vdifSaveNoteAndEncounterMockResponse');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_VdifClient vdifClient = new VCC_VdifClient(
            new Set<VCC_BaseClient.ClientOption>{ VCC_BaseClient.ClientOption.DEBUG_MODE }
        );

        VCC_VdifSaveNoteAndEncounterRQ saveNoteAndEncounterRQ = new VCC_VdifSaveNoteAndEncounterRQ(
            'test',
            'test',
            'test',
            'test',
            'test',
            'test',
            'test',
            'test',
            'test'
        );
        saveNoteAndEncounterRQ.recordId = createProgressNoteId();
        VCC_VdifSaveNoteAndEncounterRS saveNoteAndEncounterRS;
        Exception unexpectedException;

        System.runAs(createTestAdminUser()) {
            Test.startTest();
            try {
                saveNoteAndEncounterRS = vdifClient.saveNoteAndEncounter(saveNoteAndEncounterRQ);
            } catch (Exception thrownException) {
                unexpectedException = thrownException;
            }
            Test.stopTest();
        }
        Assert.isTrue(unexpectedException == null, 'An exception was thrown unexpectedly.');
        Assert.isTrue(
            saveNoteAndEncounterRS.saveNoteAndEncounterTextTO != null,
            'Response not deserialized as expected.'
        );
    }

    @IsTest
    private static void unitSaveNoteAndEncounterNegative() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_badResponse');
        mock.setStatusCode(504);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_VdifClient vdifClient = new VCC_VdifClient(
            new Set<VCC_BaseClient.ClientOption>{ VCC_BaseClient.ClientOption.DEBUG_MODE }
        );

        VCC_VdifSaveNoteAndEncounterRQ invalidRQ = new VCC_VdifSaveNoteAndEncounterRQ();
        VCC_VdifSaveNoteAndEncounterRS saveNoteAndEncounterRS;
        VCC_VdifClient.InvalidRequestException expectedRQException;

        System.runAs(createTestAdminUser()) {
            Test.startTest();
            try {
                saveNoteAndEncounterRS = vdifClient.saveNoteAndEncounter(invalidRQ);
            } catch (VCC_VdifClient.InvalidRequestException thrownException) {
                expectedRQException = thrownException;
            }
            Test.stopTest();
        }
        Assert.isTrue(expectedRQException != null, 'Expected exception was not caught.');
        Assert.isTrue(saveNoteAndEncounterRS == null, 'Parsing was unexpectedly successful.');
    }

    @IsTest
    private static void unitSignNotePositive() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_vdifSignNoteMockResponse');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_VdifClient vdifClient = new VCC_VdifClient(
            new Set<VCC_BaseClient.ClientOption>{ VCC_BaseClient.ClientOption.DEBUG_MODE }
        );

        VCC_VdifSignNoteRQ signNoteRQ = new VCC_VdifSignNoteRQ('test', 'test', 'test', 'test', 'test', 'test');
        signNoteRQ.recordId = createProgressNoteId();

        VCC_VdifSignNoteRS signNoteRS;
        Exception unexpectedException;

        System.runAs(createTestAdminUser()) {
            Test.startTest();
            try {
                signNoteRS = vdifClient.signNote(signNoteRQ);
            } catch (Exception thrownException) {
                unexpectedException = thrownException;
            }
            Test.stopTest();
        }
        Assert.isTrue(unexpectedException == null, 'An exception was thrown unexpectedly.');
        Assert.isTrue(signNoteRS.signNoteTextTO != null, 'Response not deserialized as expected.');
    }

    @IsTest
    private static void unitSignNoteTrainingModePositive() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_vdifSignNoteMockResponse');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_VdifClient vdifClient = new VCC_VdifClient(
            new Set<VCC_BaseClient.ClientOption>{ VCC_BaseClient.ClientOption.DEBUG_MODE }
        );

        VCC_VdifSignNoteRQ signNoteRQ = new VCC_VdifSignNoteRQ('test', 'test', 'test', 'test', 'test', 'test');
        signNoteRQ.recordId = createProgressNoteId();
        VCC_VdifSignNoteRS signNoteRS;
        Exception unexpectedException;

        System.runAs(createTestTraineeUser()) {
            Test.startTest();
            try {
                signNoteRS = vdifClient.signNote(signNoteRQ);
            } catch (Exception thrownException) {
                unexpectedException = thrownException;
            }
            Test.stopTest();
        }
        Assert.isTrue(unexpectedException == null, 'An exception was thrown unexpectedly.');
        Assert.isTrue(signNoteRS.signNoteTextTO != null, 'Response not deserialized as expected.');
    }

    @IsTest
    private static void unitSignNoteNegative() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_badResponse');
        mock.setStatusCode(504);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_VdifClient vdifClient = new VCC_VdifClient(
            new Set<VCC_BaseClient.ClientOption>{ VCC_BaseClient.ClientOption.DEBUG_MODE }
        );

        VCC_VdifSignNoteRQ invalidRQ = new VCC_VdifSignNoteRQ();
        VCC_VdifSignNoteRS signNoteRS;
        VCC_VdifClient.InvalidRequestException expectedRQException;
        System.runAs(createTestAdminUser()) {
            Test.startTest();
            try {
                signNoteRS = vdifClient.signNote(invalidRQ);
            } catch (VCC_VdifClient.InvalidRequestException thrownException) {
                expectedRQException = thrownException;
            }
            Test.stopTest();
        }
        Assert.isTrue(expectedRQException != null, 'Expected exception was not caught.');
        Assert.isTrue(signNoteRS == null, 'Parsing was unexpectedly successful.');
    }

    @IsTest
    private static void unitWriteNotePositive() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_vdifWriteNoteMockResponse');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_VdifClient vdifClient = new VCC_VdifClient(
            new Set<VCC_BaseClient.ClientOption>{ VCC_BaseClient.ClientOption.DEBUG_MODE }
        );

        VCC_VdifWriteNoteRQ writeNoteRQ = new VCC_VdifWriteNoteRQ(
            'test',
            'test',
            'test',
            'test',
            'test',
            'test',
            'test'
        );
        writeNoteRQ.recordId = createProgressNoteId();
        VCC_VdifWriteNoteRS writeNoteRS;
        Exception unexpectedException;
        System.runAs(createTestAdminUser()) {
            Test.startTest();
            try {
                writeNoteRS = vdifClient.writeNote(writeNoteRQ);
            } catch (Exception thrownException) {
                unexpectedException = thrownException;
            }
            Test.stopTest();
        }
        Assert.isTrue(unexpectedException == null, 'An exception was thrown unexpectedly.');
        Assert.isTrue(writeNoteRS.noteResultTO != null, 'Response not deserialized as expected.');
    }

    @IsTest
    private static void unitWriteNoteTrainingModePositive() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_vdifWriteNoteMockResponse');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_VdifClient vdifClient = new VCC_VdifClient(
            new Set<VCC_BaseClient.ClientOption>{ VCC_BaseClient.ClientOption.DEBUG_MODE }
        );

        VCC_VdifWriteNoteRQ writeNoteRQ = new VCC_VdifWriteNoteRQ(
            'test',
            'test',
            'test',
            'test',
            'test',
            'test',
            'test'
        );
        writeNoteRQ.recordId = createProgressNoteId();
        VCC_VdifWriteNoteRS writeNoteRS;
        Exception unexpectedException;

        System.runAs(createTestTraineeUser()) {
            Test.startTest();
            try {
                writeNoteRS = vdifClient.writeNote(writeNoteRQ);
            } catch (Exception thrownException) {
                unexpectedException = thrownException;
            }
            Test.stopTest();
        }
        Assert.isTrue(unexpectedException == null, 'An exception was thrown unexpectedly.');
        Assert.isTrue(writeNoteRS.noteResultTO != null, 'Response not deserialized as expected.');
    }

    @IsTest
    private static void unitWriteNoteNegative() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_badResponse');
        mock.setStatusCode(504);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_VdifClient vdifClient = new VCC_VdifClient(
            new Set<VCC_BaseClient.ClientOption>{ VCC_BaseClient.ClientOption.DEBUG_MODE }
        );

        VCC_VdifWriteNoteRQ invalidRQ = new VCC_VdifWriteNoteRQ();
        VCC_VdifWriteNoteRS writeNoteRS;
        VCC_VdifClient.InvalidRequestException expectedRQException;

        System.runAs(createTestAdminUser()) {
            Test.startTest();
            try {
                writeNoteRS = vdifClient.writeNote(invalidRQ);
            } catch (VCC_VdifClient.InvalidRequestException thrownException) {
                expectedRQException = thrownException;
            }
            Test.stopTest();
        }
        Assert.isTrue(expectedRQException != null, 'Expected exception was not caught.');
        Assert.isTrue(writeNoteRS == null, 'Parsing was unexpectedly successful.');
    }

    @IsTest
    private static void unitSelectPatientPositive() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_vdifSelectPatientMockResponse');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_VdifClient vdifClient = new VCC_VdifClient(
            new Set<VCC_BaseClient.ClientOption>{ VCC_BaseClient.ClientOption.DEBUG_MODE }
        );

        VCC_VdifSelectPatientRQ selectPatientRQ = new VCC_VdifSelectPatientRQ(
            'test',
            'test',
            'test',
            new List<String>{ 'test' },
            'test'
        );
        selectPatientRQ.recordId = createProgressNoteId();
        VCC_VdifSelectPatientRS selectPatientRS;
        Exception unexpectedException;

        System.runAs(createTestAdminUser()) {
            Test.startTest();
            try {
                selectPatientRS = vdifClient.selectPatient(selectPatientRQ);
            } catch (Exception thrownException) {
                unexpectedException = thrownException;
            }
            Test.stopTest();
        }
        Assert.isTrue(unexpectedException == null, 'An exception was thrown unexpectedly.');
        Assert.isTrue(selectPatientRS.patientTOList[0] != null, 'Response not deserialized as expected.');
    }

    @IsTest
    private static void unitSelectPatientNegative() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_badResponse');
        mock.setStatusCode(504);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_VdifClient vdifClient = new VCC_VdifClient(
            new Set<VCC_BaseClient.ClientOption>{ VCC_BaseClient.ClientOption.DEBUG_MODE }
        );

        VCC_VdifSelectPatientRQ invalidRQ = new VCC_VdifSelectPatientRQ();
        VCC_VdifSelectPatientRS selectPatientRS;
        VCC_VdifClient.InvalidRequestException expectedRQException;

        System.runAs(createTestAdminUser()) {
            Test.startTest();
            try {
                selectPatientRS = vdifClient.selectPatient(invalidRQ);
            } catch (VCC_VdifClient.InvalidRequestException thrownException) {
                expectedRQException = thrownException;
            }
            Test.stopTest();
        }
        Assert.isTrue(expectedRQException != null, 'Expected exception was not caught.');
        Assert.isTrue(selectPatientRS == null, 'Parsing was unexpectedly successful.');
    }

    @IsTest
    private static void unitGetProvidersBySitePositive() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_vdifGetProvidersBySiteMockReponse');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_VdifClient vdifClient = new VCC_VdifClient(
            new Set<VCC_BaseClient.ClientOption>{ VCC_BaseClient.ClientOption.DEBUG_MODE }
        );

        VCC_VdifGetProvidersBySiteRQ getProvidersBySiteRQ = new VCC_VdifGetProvidersBySiteRQ('test', 'test', 'test');
        getProvidersBySiteRQ.recordId = createProgressNoteId();
        VCC_VdifGetProvidersBySiteRS getProvidersBySiteRS;
        Exception unexpectedException;
        System.runAs(createTestAdminUser()) {
            Test.startTest();
            try {
                getProvidersBySiteRS = vdifClient.getProvidersBySite(getProvidersBySiteRQ);
            } catch (Exception thrownException) {
                unexpectedException = thrownException;
            }
            Test.stopTest();
        }
        Assert.isTrue(unexpectedException == null, 'An exception was thrown unexpectedly.');
        Assert.isTrue(getProvidersBySiteRS.taggedProviderArray != null, 'Response not deserialized as expected.');
    }

    @IsTest
    private static void unitGetProvidersBySiteNegative() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_badResponse');
        mock.setStatusCode(504);
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_VdifClient vdifClient = new VCC_VdifClient(
            new Set<VCC_BaseClient.ClientOption>{ VCC_BaseClient.ClientOption.DEBUG_MODE }
        );

        VCC_VdifGetProvidersBySiteRQ invalidRQ = new VCC_VdifGetProvidersBySiteRQ();
        VCC_VdifGetProvidersBySiteRS getProvidersBySiteRS;
        VCC_VdifClient.InvalidRequestException expectedRQException;

        System.runAs(createTestAdminUser()) {
            Test.startTest();
            try {
                getProvidersBySiteRS = vdifClient.getProvidersBySite(invalidRQ);
            } catch (VCC_VdifClient.InvalidRequestException thrownException) {
                expectedRQException = thrownException;
            }
            Test.stopTest();
        }
        Assert.isTrue(expectedRQException != null, 'Expected exception was not caught.');
        Assert.isTrue(getProvidersBySiteRS == null, 'Parsing was unexpectedly successful.');
    }
}
