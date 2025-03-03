@IsTest
public with sharing class VCC_EncounterServiceTest {
    @TestSetup
    static void makeData() {
        insert new IAM_SSOi_Vista_Instance_to_User_DUZ__c(
            User_Id__c = UserInfo.getUserId(),
            DUZ__c = '12345',
            VistA_Instance__c = '983',
            Name = 'mockSSO.' + UserInfo.getUserId()
        );
    }

    /**
     * @description Creates an admin test user
     * @return      `User`
     */
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
     * @description Creates progress note record
     * @return      `Id` record Id
     */
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
    public static void unitSaveNoteAndEncounterPositive() {
        System.runAs(createTestAdminUser()) {
            VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams = new VCC_Vdif_NoteAndEncounterParams();
            noteAndEncounterParams.noteAndEncounterLocationIen = 'test';
            noteAndEncounterParams.noteAndEncounterNoteTitleIen = 'test';
            noteAndEncounterParams.noteAndEncounterProcedures = 'test';
            CodeSet primaryDiagnosis = (CodeSet) VATEST_SObjectFactory.createSObject(
                new CodeSet(Code = 'TST.33', Name = 'TST.33', CodeSetType = 'Diagnosis (ICD10)')
            );
            CodeSet secondaryDiagnosis = (CodeSet) VATEST_SObjectFactory.createSObject(
                new CodeSet(Code = 'TST.34', Name = 'TST.34', CodeSetType = 'Diagnosis (ICD10)')
            );
            CodeSet procedureCode = (CodeSet) VATEST_SObjectFactory.createSObject(
                new CodeSet(Code = 'TST.35', Name = 'TST.35', CodeSetType = 'Procedure (CPT)')
            );
            noteAndEncounterParams.primaryDiagnosis = primaryDiagnosis;
            noteAndEncounterParams.secondaryDiagnosis = secondaryDiagnosis;
            noteAndEncounterParams.procedureCode = procedureCode;
            noteAndEncounterParams.supplementalParameters = 'test';
            noteAndEncounterParams.itemId = 'test';
            noteAndEncounterParams.encounterString = 'test';
            noteAndEncounterParams.authorDUZ = 'test';

            VCC_Vdif_PatientAndProviderParams patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
            patientAndProviderParams.providerUserId = 'test';
            patientAndProviderParams.providerName = 'test';
            patientAndProviderParams.patientLocalPid = 1;
            patientAndProviderParams.patientLocalSiteId = 'test';
            patientAndProviderParams.providerLoginSiteCode = 'test';
            patientAndProviderParams.eSig = 'test';
            patientAndProviderParams.authorDUZ = 'test';

            String encounterString = '9941;3200723.131503;T';
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_vdifSaveNoteAndEncounterMockResponse');
            mock.setStatusCode(200);
            String result;
            Test.setMock(HttpCalloutMock.class, mock);
            Test.startTest();
            result = VCC_EncounterService.saveNoteAndEncounter(
                noteAndEncounterParams,
                patientAndProviderParams,
                createProgressNoteId()
            );
            Test.stopTest();

            Assert.isTrue(result == encounterString, 'Expected ' + encounterString + '.');
        }

    }

    @IsTest
    public static void generateEncounterStringTest() {
        System.assert(
            VCC_EncounterService.generateEncounterString(999) == '999;3210723.131503;T',
            'encounterString did not generate correctly.'
        );
    }
    @IsTest
    public static void testGetAndReturnEncounterStringOrReturnErrorMessageWithBlankText() {
        String result;
        String errorMessage;
        String expectedResult = 'ERROR: Salesforce is great';
        try {
            Test.startTest();
            result = VCC_EncounterService.getAndReturnEncounterStringOrReturnErrorMessage('Salesforce is great');
            //System.debug( 'result: ' + result );
            Test.stopTest();
        } catch (Exception e) {
            errorMessage = e.getMessage();
        }
        System.assertEquals(expectedResult, result);
        //System.assert( result.contains( 'EncounterServiceException' ), 'Expected EncounterServiceException was found.' );
    }
    @IsTest
    public static void testGetAndReturnEncounterStringOrReturnErrorMessageWithException() {
        String result;
        String errorMessage;
        try {
            Test.startTest();
            result = VCC_EncounterService.getAndReturnEncounterStringOrReturnErrorMessage('triggerException');
            Test.stopTest();
        } catch (Exception e) {
            errorMessage = e.getMessage();
        }
        System.assertEquals(null, errorMessage);
    }
    @IsTest
    public static void testIsValidReturnsFalse() {
        VCC_EncounterService.Diagnosis instance = new VCC_EncounterService.Diagnosis(null, null, null); // Create a new instance. Replace TheClassName with your actual class name.

        Boolean result = instance.isValid(); // Call the isValid method

        System.assertEquals(false, result, 'Expected isValid to be false');
    }

    @IsTest
    public static void unitIsValidFirstParamNullNegative() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            VCC_EncounterService.Diagnosis instance = new VCC_EncounterService.Diagnosis(
                (CodeSet) VATEST_SObjectFactory.createSObject(
                    new CodeSet(Code = 'TST.33', Name = 'TST.33', CodeSetType = 'Diagnosis (ICD10)')
                ),
                true
            );

            Assert.isTrue(instance.isValid(), 'Expected isValid to be false.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitGetAndReturnEncounterStringOrReturnErrorMessageNegative() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            try {
                String blankString;
                VCC_EncounterService.getAndReturnEncounterStringOrReturnErrorMessage(blankString);
            } catch (VCC_EncounterService.EncounterServiceException thrownException) {
                Assert.isTrue(
                    thrownException.getMessage().contains('Unable to find encounter string in \'null\'.'),
                    'Expected exception message to match.'
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitDiagnosisConstructorPositive() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            VCC_EncounterService.Diagnosis diagnosis = new VCC_EncounterService.Diagnosis();
            Assert.isFalse(diagnosis.isPrimary, 'Expected isPrimary attribute to be false.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitToStringNegative() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            VCC_EncounterService.Diagnosis diagnosis = new VCC_EncounterService.Diagnosis();
            Assert.areEqual('', diagnosis.toString(), 'Expected toString method to return blank string.');
        }
        Test.stopTest();
    }
}
