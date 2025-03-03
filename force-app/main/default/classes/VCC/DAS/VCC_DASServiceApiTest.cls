@IsTest
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class VCC_DASServiceApiTest {
    @TestVisible
    private static VATEST_MockedMethod getMockedMethodGetAdditionalSigners() {
        return new VATEST_MockedMethod(
            new VATEST_MethodSignature(
                'getAdditionalSigners',
                new List<System.Type>{ VCC_DASGetAdditionalSignersRQ.class, VCC_DAS.State.class }
            )
        );
    }

    @TestVisible
    private static VATEST_MockedMethod getMockedMethodCreateAddendumAndSign() {
        return new VATEST_MockedMethod(
            new VATEST_MethodSignature(
                'createAddendumAndSign',
                new List<System.Type>{ VCC_DASCreateAddendumAndSignRQ.class, VCC_DAS.State.class }
            )
        );
    }

    @TestVisible
    private static VATEST_MockedMethod getMockedMethodWriteNoteAndSign() {
        return new VATEST_MockedMethod(
            new VATEST_MethodSignature(
                'writeNoteAndSign',
                new List<System.Type>{ VCC_DASWriteNoteAndSignRQ.class, VCC_DAS.State.class }
            )
        );
    }

    @IsTest
    static void unitIsValidEsigTestPositive() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;

        HttpResponse httpResponse = new HttpResponse();
        httpResponse.setBody(JSON.serialize(new Map<String, Object>{ 'test' => 1 }));
        httpStub.setReturnValue('send', httpResponse.getBody());

        VCC_DASIsValidEsigRQ isValidEsigRq = new VCC_DASIsValidEsigRQ();

        Test.startTest();
        VCC_DAS das = new VCC_DAS(
            new VCC_DAS.State(new VCC_SiteId('123'), 'TestAppName', VATEST_IdFactory.get(VCC_Progress_Note__c.class))
        );
        VCC_DASIsValidEsigRS response = das.isValidEsig(isValidEsigRq);
        Test.stopTest();
        httpStub.assertInvoked('send');
        Assert.isNotNull(response, 'Expected VCC_DASIsValidEsigRS to be not null.');
    }

    @IsTest
    static void unitIsValidEsigTestDasExceptionNegative() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;

        httpStub.setException('send', new VCC_DASServiceHttp.RemoteServiceException('test'));

        VCC_DASIsValidEsigRQ isValidEsigRq = new VCC_DASIsValidEsigRQ();

        Test.startTest();
        try {
            VCC_DAS das = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId('123'),
                    'TestAppName',
                    VATEST_IdFactory.get(VCC_Progress_Note__c.class)
                )
            );
            das.isValidEsig(isValidEsigRq);
            Assert.fail('Expected an exception.');
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VCC_DASException.class,
                'Expected exception to be instance of VCC_DASException'
            );
        }

        Test.stopTest();
    }

    @IsTest
    static void unitIsValidEsigTestOtherExceptionNegative() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;

        httpStub.setException('send', new NullPointerException());

        VCC_DASIsValidEsigRQ isValidEsigRq = new VCC_DASIsValidEsigRQ();

        Test.startTest();
        try {
            VCC_DAS das = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId('123'),
                    'TestAppName',
                    VATEST_IdFactory.get(VCC_Progress_Note__c.class)
                )
            );
            das.isValidEsig(isValidEsigRq);
            Assert.fail('Expected an exception.');
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VCC_DASException.class,
                'Expected exception to be instance of VCC_DASException'
            );
        }

        Test.stopTest();
    }

    @IsTest
    static void unitWriteNotePositive() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;

        HttpResponse httpResponse = new HttpResponse();
        httpResponse.setBody(JSON.serialize(new Map<String, Object>{ 'test' => 1 }));
        httpStub.setReturnValue('send', httpResponse.getBody());

        VCC_DASWriteNoteRQ writeNoteRq = new VCC_DASWriteNoteRQ();

        Test.startTest();
        VCC_DAS das = new VCC_DAS(
            new VCC_DAS.State(new VCC_SiteId('123'), 'TestAppName', VATEST_IdFactory.get(VCC_Progress_Note__c.class))
        );
        VCC_DASWriteNoteRS response = das.writeNote(writeNoteRq);
        Test.stopTest();
        Assert.isNotNull(response, 'Expected VCC_DASWriteNoteRS to be not null.');
        httpStub.assertInvoked('send');
    }

    @IsTest
    static void unitWriteNoteDasExceptionNegative() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;

        httpStub.setException('send', new VCC_DASServiceHttp.RemoteServiceException('test'));

        VCC_DASWriteNoteRQ writeNoteRq = new VCC_DASWriteNoteRQ();

        Test.startTest();
        try {
            VCC_DAS das = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId('123'),
                    'TestAppName',
                    VATEST_IdFactory.get(VCC_Progress_Note__c.class)
                )
            );
            das.writeNote(writeNoteRq);
            Assert.fail('Expected an exception.');
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VCC_DASException.class,
                'Expected exception to be instance of VCC_DASException'
            );
        }
        httpStub.assertInvoked('send');

        Test.stopTest();
    }

    @IsTest
    static void unitWriteNoteOtherExceptionNegative() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;

        httpStub.setException('send', new NullPointerException());

        VCC_DASWriteNoteRQ writeNoteRq = new VCC_DASWriteNoteRQ();

        Test.startTest();
        try {
            VCC_DAS das = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId('123'),
                    'TestAppName',
                    VATEST_IdFactory.get(VCC_Progress_Note__c.class)
                )
            );
            das.writeNote(writeNoteRq);
            Assert.fail('Expected an exception.');
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VCC_DASException.class,
                'Expected exception to be instance of VCC_DASException'
            );
        }
        httpStub.assertInvoked('send');

        Test.stopTest();
    }

    @IsTest
    static void unitCreateAddendumPositive() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;

        HttpResponse httpResponse = new HttpResponse();
        httpResponse.setBody(JSON.serialize(new Map<String, Object>{ 'test' => 1 }));
        httpStub.setReturnValue('send', httpResponse.getBody());

        VCC_DASCreateAddendumRQ createAddendumRq = new VCC_DASCreateAddendumRQ();

        Test.startTest();
        VCC_DAS das = new VCC_DAS(
            new VCC_DAS.State(new VCC_SiteId('123'), 'TestAppName', VATEST_IdFactory.get(VCC_Progress_Note__c.class))
        );
        VCC_DASCreateAddendumRS response = das.createAddendum(createAddendumRq);
        Test.stopTest();
        httpStub.assertInvoked('send');
        Assert.isNotNull(response, 'Expected VCC_DASCreateAddendumRS to be not null.');
    }

    @IsTest
    static void unitCreateAddendumDasExceptionNegative() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;

        httpStub.setException('send', new VCC_DASServiceHttp.RemoteServiceException('test'));

        VCC_DASCreateAddendumRQ createAddendumRq = new VCC_DASCreateAddendumRQ();

        Test.startTest();
        try {
            VCC_DAS das = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId('123'),
                    'TestAppName',
                    VATEST_IdFactory.get(VCC_Progress_Note__c.class)
                )
            );
            das.createAddendum(createAddendumRq);
            Assert.fail('Expected an exception.');
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VCC_DASException.class,
                'Expected exception to be instance of VCC_DASException'
            );
        }
        httpStub.assertInvoked('send');

        Test.stopTest();
    }

    @IsTest
    static void unitCreateAddendumOtherExceptionNegative() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;

        httpStub.setException('send', new NullPointerException());

        VCC_DASCreateAddendumRQ createAddendumRq = new VCC_DASCreateAddendumRQ();

        Test.startTest();
        try {
            VCC_DAS das = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId('123'),
                    'TestAppName',
                    VATEST_IdFactory.get(VCC_Progress_Note__c.class)
                )
            );
            das.createAddendum(createAddendumRq);
            Assert.fail('Expected an exception.');
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VCC_DASException.class,
                'Expected exception to be instance of VCC_DASException'
            );
        }
        httpStub.assertInvoked('send');

        Test.stopTest();
    }

    @IsTest
    static void unitGetAdditionalSignersPositive() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;

        HttpResponse httpResponse = new HttpResponse();
        httpResponse.setBody(JSON.serialize(new Map<String, Object>{ 'test' => 1 }));
        httpStub.setReturnValue('send', httpResponse.getBody());

        VCC_DASGetAdditionalSignersRQ getAdditionalSignersRq = new VCC_DASGetAdditionalSignersRQ();

        Test.startTest();
        VCC_DAS das = new VCC_DAS(
            new VCC_DAS.State(new VCC_SiteId('123'), 'TestAppName', VATEST_IdFactory.get(VCC_Progress_Note__c.class))
        );
        VCC_DASGetAdditionalSignersRS response = das.getAdditionalSigners(getAdditionalSignersRq);
        Test.stopTest();
        httpStub.assertInvoked('send');
        Assert.isNotNull(response, 'Expected VCC_DASGetAdditionalSignersRS to be not null.');
    }

    @IsTest
    static void unitGetAdditionalSignersDasExceptionNegative() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;

        httpStub.setException('send', new VCC_DASServiceHttp.RemoteServiceException('test'));

        VCC_DASGetAdditionalSignersRQ getAdditionalSignersRq = new VCC_DASGetAdditionalSignersRQ();

        Test.startTest();
        try {
            VCC_DAS das = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId('123'),
                    'TestAppName',
                    VATEST_IdFactory.get(VCC_Progress_Note__c.class)
                )
            );
            das.getAdditionalSigners(getAdditionalSignersRq);
            Assert.fail('Expected an exception.');
        } catch (VCC_DASException dasException) {
            Assert.isTrue(true, 'Exception caught. Test passes.');
        }
        httpStub.assertInvoked('send');

        Test.stopTest();
    }

    @IsTest
    static void unitGetAdditionalSignersOtherExceptionNegative() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;

        httpStub.setException('send', new NullPointerException());

        VCC_DASGetAdditionalSignersRQ getAdditionalSignersRq = new VCC_DASGetAdditionalSignersRQ();

        Test.startTest();
        try {
            VCC_DAS das = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId('123'),
                    'TestAppName',
                    VATEST_IdFactory.get(VCC_Progress_Note__c.class)
                )
            );
            das.getAdditionalSigners(getAdditionalSignersRq);
            Assert.fail('Expected an exception.');
        } catch (VCC_DASException dasException) {
            Assert.isTrue(true, 'Test passes. Exception caught.');
        }
        httpStub.assertInvoked('send');

        Test.stopTest();
    }

    @IsTest
    static void unitSaveNoteAndEncounterPositive() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;

        HttpResponse httpResponse = new HttpResponse();
        httpResponse.setBody(JSON.serialize(new Map<String, Object>{ 'test' => 1 }));
        httpStub.setReturnValue('send', httpResponse.getBody());

        VCC_DASSaveNoteAndEncounterRQ saveNoteAndEncounterRq = new VCC_DASSaveNoteAndEncounterRQ();

        Test.startTest();
        VCC_DAS das = new VCC_DAS(
            new VCC_DAS.State(new VCC_SiteId('123'), 'TestAppName', VATEST_IdFactory.get(VCC_Progress_Note__c.class))
        );
        VCC_DASSaveNoteAndEncounterRS response = das.saveNoteAndEncounter(saveNoteAndEncounterRq);
        Test.stopTest();
        httpStub.assertInvoked('send');
        Assert.isNotNull(response, 'Expected VCC_DASSaveNoteAndEncounterRS to be not null.');
    }

    @IsTest
    static void unitSaveNoteAndEncounterDasExceptionNegative() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;

        httpStub.setException('send', new VCC_DASServiceHttp.RemoteServiceException('test'));

        VCC_DASSaveNoteAndEncounterRQ saveNoteAndEncounterRq = new VCC_DASSaveNoteAndEncounterRQ();

        Test.startTest();
        try {
            VCC_DAS das = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId('123'),
                    'TestAppName',
                    VATEST_IdFactory.get(VCC_Progress_Note__c.class)
                )
            );
            das.saveNoteAndEncounter(saveNoteAndEncounterRq);
            Assert.fail('Expected an exception.');
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VCC_DASException.class,
                'Expected exception to be instance of VCC_DASException'
            );
        }
        httpStub.assertInvoked('send');

        Test.stopTest();
    }

    @IsTest
    static void unitSaveNoteAndEncounterOtherExceptionNegative() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;

        httpStub.setException('send', new NullPointerException());

        VCC_DASSaveNoteAndEncounterRQ saveNoteAndEncounterRq = new VCC_DASSaveNoteAndEncounterRQ();

        Test.startTest();
        try {
            VCC_DAS das = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId('123'),
                    'TestAppName',
                    VATEST_IdFactory.get(VCC_Progress_Note__c.class)
                )
            );
            das.saveNoteAndEncounter(saveNoteAndEncounterRq);
            Assert.fail('Expected an exception.');
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VCC_DASException.class,
                'Expected exception to be instance of VCC_DASException'
            );
        }
        httpStub.assertInvoked('send');

        Test.stopTest();
    }

    @IsTest
    static void unitSignNotePositive() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;

        HttpResponse httpResponse = new HttpResponse();
        httpResponse.setBody(JSON.serialize(new Map<String, Object>{ 'test' => 1 }));
        httpStub.setReturnValue('send', httpResponse.getBody());

        VCC_DASSignNoteRQ signNoteRq = new VCC_DASSignNoteRQ();

        Test.startTest();
        VCC_DAS das = new VCC_DAS(
            new VCC_DAS.State(new VCC_SiteId('123'), 'TestAppName', VATEST_IdFactory.get(VCC_Progress_Note__c.class))
        );
        VCC_DASSignNoteRS response = das.signNote(signNoteRq);
        Test.stopTest();
        httpStub.assertInvoked('send');
        Assert.isNotNull(response, 'Expected VCC_DASSignNoteRS to be not null.');
    }

    @IsTest
    static void unitSignNoteDasExceptionNegative() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;

        httpStub.setException('send', new VCC_DASServiceHttp.RemoteServiceException('test'));

        VCC_DASSignNoteRQ signNoteRq = new VCC_DASSignNoteRQ();

        Test.startTest();
        try {
            VCC_DAS das = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId('123'),
                    'TestAppName',
                    VATEST_IdFactory.get(VCC_Progress_Note__c.class)
                )
            );
            das.signNote(signNoteRq);
            Assert.fail('Expected an exception.');
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VCC_DASException.class,
                'Expected exception to be instance of VCC_DASException'
            );
        }
        httpStub.assertInvoked('send');

        Test.stopTest();
    }

    @IsTest
    static void unitSignNoteOtherExceptionNegative() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;

        httpStub.setException('send', new NullPointerException());

        VCC_DASSignNoteRQ signNoteRq = new VCC_DASSignNoteRQ();

        Test.startTest();
        try {
            VCC_DAS das = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId('123'),
                    'TestAppName',
                    VATEST_IdFactory.get(VCC_Progress_Note__c.class)
                )
            );
            das.signNote(signNoteRq);
            Assert.fail('Expected an exception.');
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VCC_DASException.class,
                'Expected exception to be instance of VCC_DASException'
            );
        }
        httpStub.assertInvoked('send');

        Test.stopTest();
    }

    @IsTest
    static void unitSelectPatientPositive() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;

        HttpResponse httpResponse = new HttpResponse();
        httpResponse.setBody(JSON.serialize(new List<VCC_DASSelectPatientRS>{ new VCC_DASSelectPatientRS() }));
        httpStub.setReturnValue('send', httpResponse.getBody());

        VCC_DASSelectPatientRQ selectPatientRq = new VCC_DASSelectPatientRQ();

        Test.startTest();
        VCC_DAS das = new VCC_DAS(
            new VCC_DAS.State(new VCC_SiteId('123'), 'TestAppName', VATEST_IdFactory.get(VCC_Progress_Note__c.class))
        );
        List<VCC_DASSelectPatientRS> responseList = das.selectPatient(selectPatientRq);
        Test.stopTest();
        httpStub.assertInvoked('send');
        Assert.isNotNull(responseList, 'Expected VCC_DASSelectPatientRS to be not null.');
    }

    @IsTest
    static void unitSelectPatientDasExceptionNegative() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;

        httpStub.setException('send', new VCC_DASServiceHttp.RemoteServiceException('test'));

        VCC_DASSelectPatientRQ selectPatientRq = new VCC_DASSelectPatientRQ();

        Test.startTest();
        try {
            VCC_DAS das = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId('123'),
                    'TestAppName',
                    VATEST_IdFactory.get(VCC_Progress_Note__c.class)
                )
            );
            das.selectPatient(selectPatientRq);
            Assert.fail('Expected an exception.');
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VCC_DASException.class,
                'Expected exception to be instance of VCC_DASException'
            );
        }
        httpStub.assertInvoked('send');

        Test.stopTest();
    }

    @IsTest
    static void unitSelectPatientOtherExceptionNegative() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;

        httpStub.setException('send', new NullPointerException());

        VCC_DASSelectPatientRQ selectPatientRq = new VCC_DASSelectPatientRQ();

        Test.startTest();
        try {
            VCC_DAS das = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId('123'),
                    'TestAppName',
                    VATEST_IdFactory.get(VCC_Progress_Note__c.class)
                )
            );
            das.selectPatient(selectPatientRq);
            Assert.fail('Expected an exception.');
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VCC_DASException.class,
                'Expected exception to be instance of VCC_DASException'
            );
        }
        httpStub.assertInvoked('send');

        Test.stopTest();
    }

    @IsTest
    static void unitWriteNoteAndSignPositive() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;
        HttpResponse httpResponse = new HttpResponse();
        httpResponse.setBody(JSON.serialize(new Map<String, Object>{ 'test' => 1 }));

        httpStub.setReturnValue('send', httpResponse.getBody());

        VCC_DASWriteNoteAndSignRQ writeNoteAndSignRq = new VCC_DASWriteNoteAndSignRQ();

        Test.startTest();
        VCC_DAS dasCalls = new VCC_DAS(
            new VCC_DAS.State(new VCC_SiteId('123'), 'TestAppName', VATEST_IdFactory.get(VCC_Progress_Note__c.class))
        );
        VCC_DASWriteNoteSignSuccessRS response = dasCalls.writeNoteAndSign(writeNoteAndSignRq);
        Assert.isNotNull(response, 'Expected value to be a VCC_DASWriteNoteSignSuccessRS');
        Test.stopTest();
        httpStub.assertInvoked('send');
    }

    @IsTest
    static void unitWriteNoteAndSignStatusCodeExceptionNegative() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;
        VCC_DASServiceHttp.StatusCodeException statusCodeExcept = new VCC_DASServiceHttp.StatusCodeException('test');
        statusCodeExcept.responseBody = JSON.serialize(new Map<String, Object>{ 'test' => 1 });

        httpStub.setException('send', statusCodeExcept);

        VCC_DASWriteNoteAndSignRQ writeNoteAndSignRq = new VCC_DASWriteNoteAndSignRQ();

        Test.startTest();
        try {
            VCC_DAS dasCalls = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId('123'),
                    'TestAppName',
                    VATEST_IdFactory.get(VCC_Progress_Note__c.class)
                )
            );
            dasCalls.writeNoteAndSign(writeNoteAndSignRq);
            Assert.fail('Expected an exception.');
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VCC_DASConsolidatedEndpointException.class,
                'Expected exception to be instance of VCC_DASException'
            );
        }
        httpStub.assertInvoked('send');

        Test.stopTest();
    }

    @IsTest
    static void unitWriteNoteAndSignDASExceptionNegative() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;

        httpStub.setException('send', new VCC_DASServiceHttp.RemoteServiceException('test'));

        VCC_DASWriteNoteAndSignRQ writeNoteAndSignRq = new VCC_DASWriteNoteAndSignRQ();

        Test.startTest();
        try {
            VCC_DAS dasCalls = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId('123'),
                    'TestAppName',
                    VATEST_IdFactory.get(VCC_Progress_Note__c.class)
                )
            );
            dasCalls.writeNoteAndSign(writeNoteAndSignRq);
            Assert.fail('Expected an exception.');
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VCC_DASException.class,
                'Expected exception to be instance of VCC_DASException'
            );
        }
        httpStub.assertInvoked('send');

        Test.stopTest();
    }

    @IsTest
    static void unitWriteNoteAndSignAPIExceptionNegative() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;

        httpStub.setException('send', new NullPointerException());

        VCC_DASWriteNoteAndSignRQ writeNoteAndSignRq = new VCC_DASWriteNoteAndSignRQ();

        Test.startTest();
        try {
            VCC_DAS dasCalls = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId('123'),
                    'TestAppName',
                    VATEST_IdFactory.get(VCC_Progress_Note__c.class)
                )
            );
            dasCalls.writeNoteAndSign(writeNoteAndSignRq);
            Assert.fail('Expected an exception.');
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VCC_DASException.class,
                'Expected exception to be instance of VCC_DASException'
            );
        }
        httpStub.assertInvoked('send');

        Test.stopTest();
    }

    @IsTest
    static void unitWriteNoteAndSignJSONExceptionNegative() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;
        HttpResponse httpResponse = new HttpResponse();
        // using a blob to make the deserialize method fail inside writeNoteAndSign
        String myString = 'StringToBlob';
        Blob myBlob = Blob.valueof(myString);
        httpResponse.setBodyAsBlob(myBlob);
        httpResponse.setStatusCode(400);
        VCC_DASServiceHttp.StatusCodeException statusCodeExcept = new VCC_DASServiceHttp.StatusCodeException(
            'test',
            httpResponse
        );
        httpStub.setReturnValue('send', httpResponse.getBody());
        httpStub.setException('send', statusCodeExcept);

        VCC_DASWriteNoteAndSignRQ writeNoteAndSignRq = new VCC_DASWriteNoteAndSignRQ();
        Test.startTest();
        try {
            VCC_DAS dasCalls = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId('123'),
                    'TestAppName',
                    VATEST_IdFactory.get(VCC_Progress_Note__c.class)
                )
            );
            dasCalls.writeNoteAndSign(writeNoteAndSignRq);
            Assert.fail('Expected an exception.');
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VCC_DASServiceHttp.StatusCodeException.class,
                'Expected exception to be instance of VCC_DASServiceHttp.StatusCodeException'
            );
        }
        httpStub.assertInvoked('send');

        Test.stopTest();
    }

    @IsTest
    static void unitCreateAddendumAndSignPositive() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;

        HttpResponse httpResponse = new HttpResponse();
        httpResponse.setBody(JSON.serialize(new Map<String, Object>{ 'test' => 1 }));

        httpStub.setReturnValue('send', httpResponse.getBody());

        VCC_DASCreateAddendumAndSignRQ createAddendumAndSignRQ = new VCC_DASCreateAddendumAndSignRQ();

        Test.startTest();
        VCC_DAS dasCalls = new VCC_DAS(
            new VCC_DAS.State(new VCC_SiteId('123'), 'TestAppName', VATEST_IdFactory.get(VCC_Progress_Note__c.class))
        );
        VCC_DASCreateAddendumAndSignSuccessRS response = dasCalls.createAddendumAndSign(createAddendumAndSignRQ);
        Assert.isNotNull(response, 'Expected value to be a VCC_DASCreateAddendumAndSignSuccessRS');
        Test.stopTest();
        httpStub.assertInvoked('send');
    }

    @IsTest
    static void unitCreateAddendumAndSignStatusCodeExceptionNegative() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;
        VCC_DASServiceHttp.StatusCodeException statusCodeExcept = new VCC_DASServiceHttp.StatusCodeException('test');
        statusCodeExcept.responseBody = JSON.serialize(new Map<String, Object>{ 'test' => 1 });

        httpStub.setException('send', statusCodeExcept);

        VCC_DASCreateAddendumAndSignRQ createAddendumAndSignRQ = new VCC_DASCreateAddendumAndSignRQ();

        Test.startTest();
        try {
            VCC_DAS dasCalls = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId('123'),
                    'TestAppName',
                    VATEST_IdFactory.get(VCC_Progress_Note__c.class)
                )
            );
            dasCalls.createAddendumAndSign(createAddendumAndSignRQ);
            Assert.fail('Expected an exception.');
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VCC_DASConsolidatedEndpointException.class,
                'Expected exception to be instance of VCC_DASException'
            );
        }
        httpStub.assertInvoked('send');

        Test.stopTest();
    }

    @IsTest
    static void unitCreateAddendumAndSignDASExceptionNegative() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;

        httpStub.setException('send', new VCC_DASServiceHttp.RemoteServiceException('test'));

        VCC_DASCreateAddendumAndSignRQ createAddendumAndSignRQ = new VCC_DASCreateAddendumAndSignRQ();

        Test.startTest();
        try {
            VCC_DAS dasCalls = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId('123'),
                    'TestAppName',
                    VATEST_IdFactory.get(VCC_Progress_Note__c.class)
                )
            );
            dasCalls.createAddendumAndSign(createAddendumAndSignRQ);
            Assert.fail('Expected an exception.');
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VCC_DASException.class,
                'Expected exception to be instance of VCC_DASException'
            );
        }
        httpStub.assertInvoked('send');

        Test.stopTest();
    }

    @IsTest
    static void unitCreateAddendumAndSignAPIExceptionNegative() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;

        httpStub.setException('send', new NullPointerException());

        VCC_DASCreateAddendumAndSignRQ createAddendumAndSignRQ = new VCC_DASCreateAddendumAndSignRQ();

        Test.startTest();
        try {
            VCC_DAS dasCalls = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId('123'),
                    'TestAppName',
                    VATEST_IdFactory.get(VCC_Progress_Note__c.class)
                )
            );
            dasCalls.createAddendumAndSign(createAddendumAndSignRQ);
            Assert.fail('Expected an exception.');
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VCC_DASException.class,
                'Expected exception to be instance of VCC_DASException'
            );
        }
        httpStub.assertInvoked('send');

        Test.stopTest();
    }

    @IsTest
    static void unitCreateAddendumAndSignJSONExceptionNegative() {
        VCC_DASStub httpStub = new VCC_DASStub(VCC_DASServiceHttp.class);
        VCC_DAS.SERVICES.httpService = (VCC_DASServiceHttp) httpStub.instance;
        HttpResponse httpResponse = new HttpResponse();
        // using a blob to make the deserialize method in createAddendumAndSign fail
        String myString = 'StringToBlob';
        Blob myBlob = Blob.valueof(myString);
        httpResponse.setBodyAsBlob(myBlob);
        httpResponse.setStatusCode(400);
        VCC_DASServiceHttp.StatusCodeException statusCodeExcept = new VCC_DASServiceHttp.StatusCodeException(
            'test',
            httpResponse
        );
        httpStub.setReturnValue('send', httpResponse.getBody());
        httpStub.setException('send', statusCodeExcept);

        VCC_DASCreateAddendumAndSignRQ createAddendumAndSignRQ = new VCC_DASCreateAddendumAndSignRQ();
        Test.startTest();
        try {
            VCC_DAS dasCalls = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId('123'),
                    'TestAppName',
                    VATEST_IdFactory.get(VCC_Progress_Note__c.class)
                )
            );
            dasCalls.createAddendumAndSign(createAddendumAndSignRQ);
            Assert.fail('Expected an exception.');
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VCC_DASServiceHttp.StatusCodeException.class,
                'Expected exception to be instance of VCC_DASServiceHttp.StatusCodeException'
            );
        }
        httpStub.assertInvoked('send');

        Test.stopTest();
    }
}
