@IsTest
public with sharing class VCC_DASFlowGenerateEncounterStringTest {
    @IsTest
    static void resultConstructorTest() {
        Test.startTest();
        try {
            VCC_DASFlowGenerateEncounterString.Result flowCreateAddendumResult = new VCC_DASFlowGenerateEncounterString.Result(
                'encounterString'
            );
            Assert.areEqual('encounterString', flowCreateAddendumResult.encounterString, 'Expected matching result.');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void requestConstructorTest() {
        Test.startTest();
        try {
            Assert.isNotNull(new VCC_DASFlowGenerateEncounterString.Request());
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void generateEncounterStringTestHappy() {
        VCC_DASStub encounterStub = new VCC_DASStub(VCC_DASServiceEncounter.class);
        VCC_DAS.SERVICES.encounterService = (VCC_DASServiceEncounter) encounterStub.instance;

        encounterStub.setReturnValue('generateEncounterString', 'returnValue');

        Test.startTest();
        try {
            VCC_DASFlowGenerateEncounterString.Request flowCreateAddendumRequest = new VCC_DASFlowGenerateEncounterString.Request();
            VCC_DASFlowGenerateEncounterString.Result flowCreateAddendumResult = VCC_DASFlowGenerateEncounterString.generateEncounterString(
                new List<VCC_DASFlowGenerateEncounterString.Request>{ flowCreateAddendumRequest }
            )[0];
            Assert.isNotNull(flowCreateAddendumResult, 'Expected non-null value.');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void generateEncounterStringTestSadDasException() {
        VCC_DASStub encounterStub = new VCC_DASStub(VCC_DASServiceEncounter.class);
        VCC_DAS.SERVICES.encounterService = (VCC_DASServiceEncounter) encounterStub.instance;

        encounterStub.setException(
            'generateEncounterString',
            new VCC_DASServiceEncounter.GenerateEncounterStringException('test')
        );

        Test.startTest();
        try {
            VCC_DASFlowGenerateEncounterString.Request flowCreateAddendumRequest = new VCC_DASFlowGenerateEncounterString.Request();
            VCC_DASFlowGenerateEncounterString.Result flowCreateAddendumResult = VCC_DASFlowGenerateEncounterString.generateEncounterString(
                new List<VCC_DASFlowGenerateEncounterString.Request>{ flowCreateAddendumRequest }
            )[0];
            Assert.fail('Expected an exception.');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, VCC_DASException.class, 'Expected a VCC_DASException');
        }
        Test.stopTest();
    }

    @IsTest
    static void generateEncounterStringTestSadOtherException() {
        VCC_DASStub encounterStub = new VCC_DASStub(VCC_DASServiceEncounter.class);
        VCC_DAS.SERVICES.encounterService = (VCC_DASServiceEncounter) encounterStub.instance;

        encounterStub.setException('generateEncounterString', new NullPointerException());

        Test.startTest();
        try {
            VCC_DASFlowGenerateEncounterString.Request flowCreateAddendumRequest = new VCC_DASFlowGenerateEncounterString.Request();
            VCC_DASFlowGenerateEncounterString.Result flowCreateAddendumResult = VCC_DASFlowGenerateEncounterString.generateEncounterString(
                new List<VCC_DASFlowGenerateEncounterString.Request>{ flowCreateAddendumRequest }
            )[0];
            Assert.fail('Expected an exception.');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, VCC_DASException.class, 'Expected a VCC_DASException');
        }
        Test.stopTest();
    }
}
