@IsTest
/**
 * @description Test class for VCC_DASServiceEncounter
 */
public with sharing class VCC_DASServiceEncounterTest {
    @IsTest
    static void generateEncounterStringTestHappy() {
        VCC_DASFlowGenerateEncounterString.Request generateEncounterStringRequest = new VCC_DASFlowGenerateEncounterString.Request();
        generateEncounterStringRequest.noteAndEncounterParameters = new VCC_Vdif_NoteAndEncounterParams();
        generateEncounterStringRequest.noteAndEncounterParameters.noteAndEncounterLocationIen = '55';

        Test.startTest();
        try {
            Assert.isNotNull(
                VCC_DAS.SERVICES.ENCOUNTER.generateEncounterString(generateEncounterStringRequest),
                'Expected non-null value.'
            );
        } catch (Exception e) {
            Assert.fail('Unexpected exception caught: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void generateEncounterStringTestSad() {
        VCC_DASFlowGenerateEncounterString.Request generateEncounterStringRequest = new VCC_DASFlowGenerateEncounterString.Request();
        generateEncounterStringRequest.noteAndEncounterParameters = new VCC_Vdif_NoteAndEncounterParams();
        generateEncounterStringRequest.noteAndEncounterParameters.noteAndEncounterLocationIen = null;

        Test.startTest();
        try {
            VCC_DAS.SERVICES.ENCOUNTER.generateEncounterString(generateEncounterStringRequest);
            Assert.fail('Expected an exception.');
        } catch (VCC_DASServiceEncounter.GenerateEncounterStringException e) {
            Assert.isNotNull(e, 'Expected an exception.');
        } catch (Exception e) {
            Assert.fail('Unexpected exception caught: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void createProcedureStringTestSadNullCodeSet() {
        Test.startTest();
        Assert.areEqual('', VCC_DAS.SERVICES.ENCOUNTER.createProcedureString(null, 'test'), 'Expected empty string.');
        Test.stopTest();
    }

    @IsTest
    static void createProcedureStringTestSadNullProviderDuz() {
        CodeSet procedureCode = new CodeSet(Code = 'TST.35', Name = 'TST.35', CodeSetType = 'Procedure (CPT)');

        insert procedureCode;

        procedureCode = [
            SELECT Id
            FROM CodeSet
            WHERE CodeSetType = 'Procedure (CPT)'
            LIMIT 1
        ];

        Test.startTest();
        Assert.areEqual(
            '',
            VCC_DAS.SERVICES.ENCOUNTER.createProcedureString(procedureCode, null),
            'Expected empty string.'
        );
        Test.stopTest();
    }

    @IsTest
    static void createProcedureStringTestHappy() {
        CodeSet procedureCode = new CodeSet(Code = 'TST.35', Name = 'TST.35', CodeSetType = 'Procedure (CPT)');

        insert procedureCode;

        procedureCode = [
            SELECT Id
            FROM CodeSet
            WHERE CodeSetType = 'Procedure (CPT)'
            LIMIT 1
        ];

        Test.startTest();
        String procedureString = VCC_DAS.SERVICES.ENCOUNTER.createProcedureString(procedureCode, 'test');
        Assert.isNotNull(procedureString, 'Expected non-null value');
        Assert.isFalse(String.isBlank(procedureString), 'Expected non-empty string.');
        Test.stopTest();
    }

    @IsTest
    static void createDiagnosisStringTestSadNullAll() {
        Test.startTest();
        Assert.areEqual('', VCC_DAS.SERVICES.ENCOUNTER.createDiagnosisString(null, null), 'Expected empty string.');
        Test.stopTest();
    }

    @IsTest
    static void createDiagnosisStringTestHappyNullSecondary() {
        CodeSet primaryDiagnosis = new CodeSet(Code = 'TST.33', Name = 'TST.33', CodeSetType = 'Diagnosis (ICD10)');

        insert new List<CodeSet>{ primaryDiagnosis };

        Test.startTest();
        String diagnosisString = VCC_DAS.SERVICES.ENCOUNTER.createDiagnosisString(primaryDiagnosis, null);
        Assert.isNotNull(diagnosisString, 'Expected non-null value.');
        Assert.areNotEqual('', diagnosisString, 'Expected non-empty string.');
        Test.stopTest();
    }

    @IsTest
    static void createDiagnosisStringTestHappy() {
        CodeSet primaryDiagnosis = new CodeSet(Code = 'TST.33', Name = 'TST.33', CodeSetType = 'Diagnosis (ICD10)');

        CodeSet secondaryDiagnosis = new CodeSet(Code = 'TST.34', Name = 'TST.34', CodeSetType = 'Diagnosis (ICD10)');

        insert new List<CodeSet>{ primaryDiagnosis, secondaryDiagnosis };

        Test.startTest();
        String diagnosisString = VCC_DAS.SERVICES.ENCOUNTER.createDiagnosisString(primaryDiagnosis, secondaryDiagnosis);
        Assert.isNotNull(diagnosisString, 'Expected non-null value.');
        Assert.areNotEqual('', diagnosisString, 'Expected non-empty string.');
        Assert.areEqual(
            'TST.33^^^1^^;TST.34^',
            diagnosisString,
            'Expected diagnosisString to be equal to TST.33^^^1^^;TST.34^'
        );
        Test.stopTest();
    }

    @IsTest
    static void getAndReturnEncounterStringOrReturnErrorMessage() {
        Test.startTest();
        Assert.areEqual(
            '9941;3200723.131503;T',
            VCC_DAS.SERVICES.ENCOUNTER.getAndReturnEncounterStringOrReturnErrorMessage('9941;3200723.131503;T'),
            'Expected correct value'
        );
        Test.stopTest();
    }

    @IsTest
    static void getEncounterServiceCategory() {
        Test.startTest();
        Assert.areEqual('test', VCC_DAS.SERVICES.ENCOUNTER.getEncounterServiceCategory());
        Test.stopTest();
    }
}
