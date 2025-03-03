/**
 * @description Apex test class for the flow VCC Sign Note Subflow : DAS Create Addendum And Sign
 * @author      Booz Allen Hamilton
 * @see         VCC_Sign_Note_Subflow_DAS_Create_Addendum_And_Sign
 * @see         VCC_DASFlowCreateAddendumAndSign
 */

@IsTest
private with sharing class VCC_DASCreateAddendumAndSignSubflowTest {
    private static final User VCC_TESTUSER = createTestUser();

    /**
     * @description Creates test RN user
     * @return      `User`
     */
    private static User createTestUser() {
        return VATEST_UserFactory.create(VATEST_UserPersonaEnum.Nurse, true);
    }

    @IsTest
    static void unitfaultoccuredPositive() {
        System.runAs(VCC_TESTUSER) {
            VCC_Progress_Note__c progressNotesFlow = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
                new VCC_Progress_Note__c()
            );

            VCC_Addendum__c adden = (VCC_Addendum__c) VATEST_SObjectFactory.createSObject(
                new VCC_Addendum__c(VCC_Related_Note__c = progressNotesFlow.Id)
            );

            Map<String, Object> params = new Map<String, Object>();

            //Flow Variables
            VCC_Vdif_NoteAndEncounterParams neParams = new VCC_Vdif_NoteAndEncounterParams();
            neParams.noteAndEncounterNoteTitleIen = 'tests';
            neParams.itemId = 'tests';

            VCC_Vdif_PatientAndProviderParams pParams = new VCC_Vdif_PatientAndProviderParams();
            pParams.esig = 'test1';
            pParams.providerName = 'test2';
            pParams.providerUserId = 'test3';
            pParams.providerLoginSiteCode = 'test6';

            params.put('recordId', adden.Id);
            params.put('ProgressNoteRecord_DAS', progressNotesFlow);
            params.put('noteAndEncounterParams', neParams);
            params.put('patientAndProviderParams', pParams);

            //Stubbing The Data
            VCC_DASFlowCreateAddendumAndSign.Request createAddendumSign = new VCC_DASFlowCreateAddendumAndSign.Request();
            createAddendumSign.recordId = adden.Id;
            createAddendumSign.esig = 'test1';
            createAddendumSign.providerName = 'test2';
            createAddendumSign.providerUserId = 'test3';
            createAddendumSign.type = 'tests';
            createAddendumSign.siteCode = 'test6';
            createAddendumSign.itemId = 'tests';

            VCC_DASCreateAddendumAndSignSuccessRS addenRs = new VCC_DASCreateAddendumAndSignSuccessRS();
            addenRs.textTo.text = 'Addendum 1';
            addenRs.textTo.addendumIen = 'Addendum 2';

            VCC_DASFlowConsolidatedEndpointResult endPoint = new VCC_DASFlowConsolidatedEndpointResult(addenRs);
            endPoint.isError = false;

            List<VCC_DASFlowConsolidatedEndpointResult> resultList = new List<VCC_DASFlowConsolidatedEndpointResult>{
                endPoint
            };

            VCC_DASFlowCreateAddendumAndSign addenStub = (VCC_DASFlowCreateAddendumAndSign) new VATEST_StubBuilder(
                    VCC_DASFlowCreateAddendumAndSign.class
                )
                .mockingMethodCall(
                    'handleFlowCreateAddendumAndSign',
                    List<VCC_DASFlowCreateAddendumAndSign.Request>.class
                )
                .withParameterValues(new List<VCC_DASFlowCreateAddendumAndSign.Request>{ createAddendumSign })
                .returning(resultList)
                .defineStub();

            VCC_DASFlowCreateAddendumAndSign.flowCreateAddendumAndSignInstance = addenStub;

            Flow.Interview addendumFlow = Flow.Interview.createInterview(
                'VCC_Sign_Note_Subflow_DAS_Create_Addendum_And_Sign',
                params
            );

            Test.startTest();

            addendumFlow.start();
            Assert.areEqual(
                false,
                addendumFlow.getVariableValue('faultOccurred'),
                'Expected faultOccurred to be set to false.'
            );
            Test.stopTest();
        }
    }

    @IsTest
    static void unitcheckNoteIENTestPositive() {
        System.runAs(VCC_TESTUSER) {
            VCC_Progress_Note__c progressNotesFlow = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
                new VCC_Progress_Note__c()
            );

            VCC_Addendum__c adden = (VCC_Addendum__c) VATEST_SObjectFactory.createSObject(
                new VCC_Addendum__c(VCC_Related_Note__c = progressNotesFlow.Id)
            );

            Map<String, Object> params = new Map<String, Object>();

            //Flow Variables
            VCC_Vdif_NoteAndEncounterParams neParams = new VCC_Vdif_NoteAndEncounterParams();
            neParams.noteAndEncounterNoteTitleIen = 'tests';
            neParams.itemId = 'tests';

            VCC_Vdif_PatientAndProviderParams pParams = new VCC_Vdif_PatientAndProviderParams();
            pParams.esig = 'test1';
            pParams.providerName = 'test2';
            pParams.providerUserId = 'test3';
            pParams.providerLoginSiteCode = 'test6';

            params.put('recordId', adden.Id);
            params.put('ProgressNoteRecord_DAS', progressNotesFlow);
            params.put('noteAndEncounterParams', neParams);
            params.put('patientAndProviderParams', pParams);

            //Stubbing The Data
            VCC_DASFlowCreateAddendumAndSign.Request createAddendumSign = new VCC_DASFlowCreateAddendumAndSign.Request();
            createAddendumSign.recordId = adden.Id;
            createAddendumSign.esig = 'test1';
            createAddendumSign.providerName = 'test2';
            createAddendumSign.providerUserId = 'test3';
            createAddendumSign.type = 'tests';
            createAddendumSign.siteCode = 'test6';
            createAddendumSign.itemId = 'tests';

            VCC_DASCreateAddendumAndSignSuccessRS addenRs = new VCC_DASCreateAddendumAndSignSuccessRS();
            addenRs.textTo.text = 'Addendum 1';
            addenRs.textTo.addendumIen = 'Addendum 2';

            VCC_DASFlowConsolidatedEndpointResult endPoint = new VCC_DASFlowConsolidatedEndpointResult(addenRs);
            endPoint.isError = true;

            List<VCC_DASFlowConsolidatedEndpointResult> resultList = new List<VCC_DASFlowConsolidatedEndpointResult>{
                endPoint
            };

            VCC_DASFlowCreateAddendumAndSign addenStub = (VCC_DASFlowCreateAddendumAndSign) new VATEST_StubBuilder(
                    VCC_DASFlowCreateAddendumAndSign.class
                )
                .mockingMethodCall(
                    'handleFlowCreateAddendumAndSign',
                    List<VCC_DASFlowCreateAddendumAndSign.Request>.class
                )
                .withParameterValues(new List<VCC_DASFlowCreateAddendumAndSign.Request>{ createAddendumSign })
                .returning(resultList)
                .defineStub();

            VCC_DASFlowCreateAddendumAndSign.flowCreateAddendumAndSignInstance = addenStub;

            Flow.Interview addendumFlow = Flow.Interview.createInterview(
                'VCC_Sign_Note_Subflow_DAS_Create_Addendum_And_Sign',
                params
            );

            Test.startTest();

            addendumFlow.start();
            Assert.areEqual(
                true,
                addendumFlow.getVariableValue('faultFlag_ResumeConsolidatedEndpoint'),
                'Expected faultFlag_ResumeConsolidatedEndpoint to be set to true.'
            );
            Test.stopTest();
        }
    }

    @IsTest
    static void unitErrorCode1500Positive() {
        System.runAs(VCC_TESTUSER) {
            VCC_Progress_Note__c progressNotesFlow = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
                new VCC_Progress_Note__c()
            );

            VCC_Addendum__c adden = (VCC_Addendum__c) VATEST_SObjectFactory.createSObject(
                new VCC_Addendum__c(VCC_Related_Note__c = progressNotesFlow.Id)
            );

            Map<String, Object> params = new Map<String, Object>();

            //Flow Variables
            VCC_Vdif_NoteAndEncounterParams neParams = new VCC_Vdif_NoteAndEncounterParams();
            neParams.noteAndEncounterNoteTitleIen = 'tests';
            neParams.itemId = 'tests';

            VCC_Vdif_PatientAndProviderParams pParams = new VCC_Vdif_PatientAndProviderParams();
            pParams.esig = 'test1';
            pParams.providerName = 'test2';
            pParams.providerUserId = 'test3';
            pParams.providerLoginSiteCode = 'test6';

            params.put('recordId', adden.Id);
            params.put('ProgressNoteRecord_DAS', progressNotesFlow);
            params.put('noteAndEncounterParams', neParams);
            params.put('patientAndProviderParams', pParams);

            //Stubbing The Data
            VCC_DASFlowCreateAddendumAndSign.Request createAddendumSign = new VCC_DASFlowCreateAddendumAndSign.Request();
            createAddendumSign.recordId = adden.Id;
            createAddendumSign.esig = 'test1';
            createAddendumSign.providerName = 'test2';
            createAddendumSign.providerUserId = 'test3';
            createAddendumSign.type = 'tests';
            createAddendumSign.siteCode = 'test6';
            createAddendumSign.itemId = 'tests';

            VCC_DASCreateAddendumAndSignSuccessRS addenRs = new VCC_DASCreateAddendumAndSignSuccessRS();
            addenRs.textTo.text = 'Addendum 1';
            addenRs.textTo.addendumIen = 'Addendum 2';

            VCC_DASFlowConsolidatedEndpointResult endPoint = new VCC_DASFlowConsolidatedEndpointResult(addenRs);
            endPoint.isError = true;
            endPoint.errorCode = '1500';

            List<VCC_DASFlowConsolidatedEndpointResult> resultList = new List<VCC_DASFlowConsolidatedEndpointResult>{
                endPoint
            };

            VCC_DASFlowCreateAddendumAndSign addenStub = (VCC_DASFlowCreateAddendumAndSign) new VATEST_StubBuilder(
                    VCC_DASFlowCreateAddendumAndSign.class
                )
                .mockingMethodCall(
                    'handleFlowCreateAddendumAndSign',
                    List<VCC_DASFlowCreateAddendumAndSign.Request>.class
                )
                .withParameterValues(new List<VCC_DASFlowCreateAddendumAndSign.Request>{ createAddendumSign })
                .returning(resultList)
                .defineStub();

            VCC_DASFlowCreateAddendumAndSign.flowCreateAddendumAndSignInstance = addenStub;

            Flow.Interview addendumFlow = Flow.Interview.createInterview(
                'VCC_Sign_Note_Subflow_DAS_Create_Addendum_And_Sign',
                params
            );

            Test.startTest();

            addendumFlow.start();
            Assert.areEqual(
                true,
                addendumFlow.getVariableValue('faultFlag_ResumeConsolidatedEndpoint'),
                'Expected faultFlag_ResumeConsolidatedEndpoint to be set to true.'
            );
            Test.stopTest();
        }
    }

    @IsTest
    static void unitErrorCode1800Positive() {
        System.runAs(VCC_TESTUSER) {
            VCC_Progress_Note__c progressNotesFlow = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
                new VCC_Progress_Note__c()
            );

            VCC_Addendum__c adden = (VCC_Addendum__c) VATEST_SObjectFactory.createSObject(
                new VCC_Addendum__c(VCC_Related_Note__c = progressNotesFlow.Id)
            );

            Map<String, Object> params = new Map<String, Object>();

            //Flow Variables
            VCC_Vdif_NoteAndEncounterParams neParams = new VCC_Vdif_NoteAndEncounterParams();
            neParams.noteAndEncounterNoteTitleIen = 'tests';
            neParams.itemId = 'tests';

            VCC_Vdif_PatientAndProviderParams pParams = new VCC_Vdif_PatientAndProviderParams();
            pParams.esig = 'test1';
            pParams.providerName = 'test2';
            pParams.providerUserId = 'test3';
            pParams.providerLoginSiteCode = 'test6';

            params.put('recordId', adden.Id);
            params.put('ProgressNoteRecord_DAS', progressNotesFlow);
            params.put('noteAndEncounterParams', neParams);
            params.put('patientAndProviderParams', pParams);

            //Stubbing The Data
            VCC_DASFlowCreateAddendumAndSign.Request createAddendumSign = new VCC_DASFlowCreateAddendumAndSign.Request();
            createAddendumSign.recordId = adden.Id;
            createAddendumSign.esig = 'test1';
            createAddendumSign.providerName = 'test2';
            createAddendumSign.providerUserId = 'test3';
            createAddendumSign.type = 'tests';
            createAddendumSign.siteCode = 'test6';
            createAddendumSign.itemId = 'tests';

            VCC_DASCreateAddendumAndSignSuccessRS addenRs = new VCC_DASCreateAddendumAndSignSuccessRS();
            addenRs.textTo.text = 'Addendum 1';
            addenRs.textTo.addendumIen = 'Addendum 2';

            VCC_DASFlowConsolidatedEndpointResult endPoint = new VCC_DASFlowConsolidatedEndpointResult(addenRs);
            endPoint.isError = true;
            endPoint.errorCode = '1800';

            List<VCC_DASFlowConsolidatedEndpointResult> resultList = new List<VCC_DASFlowConsolidatedEndpointResult>{
                endPoint
            };

            VCC_DASFlowCreateAddendumAndSign addenStub = (VCC_DASFlowCreateAddendumAndSign) new VATEST_StubBuilder(
                    VCC_DASFlowCreateAddendumAndSign.class
                )
                .mockingMethodCall(
                    'handleFlowCreateAddendumAndSign',
                    List<VCC_DASFlowCreateAddendumAndSign.Request>.class
                )
                .withParameterValues(new List<VCC_DASFlowCreateAddendumAndSign.Request>{ createAddendumSign })
                .returning(resultList)
                .defineStub();

            VCC_DASFlowCreateAddendumAndSign.flowCreateAddendumAndSignInstance = addenStub;

            Flow.Interview addendumFlow = Flow.Interview.createInterview(
                'VCC_Sign_Note_Subflow_DAS_Create_Addendum_And_Sign',
                params
            );

            Test.startTest();

            addendumFlow.start();
            Assert.areEqual(
                true,
                addendumFlow.getVariableValue('faultFlag_ResumeConsolidatedEndpoint'),
                'Expected faultFlag_ResumeConsolidatedEndpoint variable to be true'
            );
            Test.stopTest();
        }
    }

    @IsTest
    static void unitErrorCode1300Positive() {
        System.runAs(VCC_TESTUSER) {
            VCC_Progress_Note__c progressNotesFlow = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
                new VCC_Progress_Note__c()
            );

            VCC_Addendum__c adden = (VCC_Addendum__c) VATEST_SObjectFactory.createSObject(
                new VCC_Addendum__c(VCC_Related_Note__c = progressNotesFlow.Id)
            );

            Map<String, Object> params = new Map<String, Object>();

            //Flow Variables
            VCC_Vdif_NoteAndEncounterParams neParams = new VCC_Vdif_NoteAndEncounterParams();
            neParams.noteAndEncounterNoteTitleIen = 'tests';
            neParams.itemId = 'tests';

            VCC_Vdif_PatientAndProviderParams pParams = new VCC_Vdif_PatientAndProviderParams();
            pParams.esig = 'test1';
            pParams.providerName = 'test2';
            pParams.providerUserId = 'test3';
            pParams.providerLoginSiteCode = 'test6';

            params.put('recordId', adden.Id);
            params.put('ProgressNoteRecord_DAS', progressNotesFlow);
            params.put('noteAndEncounterParams', neParams);
            params.put('patientAndProviderParams', pParams);

            //Stubbing The Data
            VCC_DASFlowCreateAddendumAndSign.Request createAddendumSign = new VCC_DASFlowCreateAddendumAndSign.Request();
            createAddendumSign.recordId = adden.Id;
            createAddendumSign.esig = 'test1';
            createAddendumSign.providerName = 'test2';
            createAddendumSign.providerUserId = 'test3';
            createAddendumSign.type = 'tests';
            createAddendumSign.siteCode = 'test6';
            createAddendumSign.itemId = 'tests';

            VCC_DASCreateAddendumAndSignSuccessRS addenRs = new VCC_DASCreateAddendumAndSignSuccessRS();
            addenRs.textTo.text = 'Addendum 1';
            addenRs.textTo.addendumIen = 'Addendum 2';

            VCC_DASFlowConsolidatedEndpointResult endPoint = new VCC_DASFlowConsolidatedEndpointResult(addenRs);
            endPoint.noteOrAddendumIen = null;
            endPoint.isError = true;
            endPoint.errorCode = '1300';

            List<VCC_DASFlowConsolidatedEndpointResult> resultList = new List<VCC_DASFlowConsolidatedEndpointResult>{
                endPoint
            };

            VCC_DASFlowCreateAddendumAndSign addenStub = (VCC_DASFlowCreateAddendumAndSign) new VATEST_StubBuilder(
                    VCC_DASFlowCreateAddendumAndSign.class
                )
                .mockingMethodCall(
                    'handleFlowCreateAddendumAndSign',
                    List<VCC_DASFlowCreateAddendumAndSign.Request>.class
                )
                .withParameterValues(new List<VCC_DASFlowCreateAddendumAndSign.Request>{ createAddendumSign })
                .returning(resultList)
                .defineStub();

            VCC_DASFlowCreateAddendumAndSign.flowCreateAddendumAndSignInstance = addenStub;

            Flow.Interview addendumFlow = Flow.Interview.createInterview(
                'VCC_Sign_Note_Subflow_DAS_Create_Addendum_And_Sign',
                params
            );

            Test.startTest();

            addendumFlow.start();
            Assert.areEqual(
                true,
                addendumFlow.getVariableValue('faultFlag_RevalidateEsig'),
                'Expected faultFlag_RevalidateEsig to be set to true.'
            );
            Test.stopTest();
        }
    }

    @IsTest
    static void unitFaultPathPositive() {
        System.runAs(VCC_TESTUSER) {
            VCC_Progress_Note__c progressNotesFlow = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
                new VCC_Progress_Note__c()
            );

            VCC_Addendum__c adden = (VCC_Addendum__c) VATEST_SObjectFactory.createSObject(
                new VCC_Addendum__c(VCC_Related_Note__c = progressNotesFlow.Id)
            );

            Map<String, Object> params = new Map<String, Object>();

            //Flow Variables

            VCC_Vdif_NoteAndEncounterParams neParams = new VCC_Vdif_NoteAndEncounterParams();
            neParams.noteAndEncounterNoteTitleIen = 'tests';
            neParams.itemId = 'tests';

            VCC_Vdif_PatientAndProviderParams pParams = new VCC_Vdif_PatientAndProviderParams();
            pParams.esig = 'test1';
            pParams.providerName = 'test2';
            pParams.providerUserId = 'test3';
            pParams.providerLoginSiteCode = 'test6';

            params.put('recordId', adden.Id);
            params.put('ProgressNoteRecord_DAS', progressNotesFlow);
            params.put('noteAndEncounterParams', neParams);
            params.put('patientAndProviderParams', pParams);

            //Stubbing The Data

            VCC_DASFlowCreateAddendumAndSign.Request createAddendumSign = new VCC_DASFlowCreateAddendumAndSign.Request();
            createAddendumSign.recordId = adden.Id;
            createAddendumSign.esig = 'test1';
            createAddendumSign.providerName = 'test2';
            createAddendumSign.providerUserId = 'test3';
            createAddendumSign.type = 'tests';
            createAddendumSign.siteCode = 'test6';
            createAddendumSign.itemId = 'tests';

            //RETURN vcc_das
            VCC_DASCreateAddendumAndSignSuccessRS addenRs = new VCC_DASCreateAddendumAndSignSuccessRS();
            addenRs.textTo.text = 'Addendum 1';
            addenRs.textTo.addendumIen = 'Addendum 2';

            VCC_DASFlowConsolidatedEndpointResult endPoint = new VCC_DASFlowConsolidatedEndpointResult(addenRs);
            endPoint.noteOrAddendumIen = null;
            endPoint.isError = true;
            endPoint.errorCode = '0000';
            endPoint.errorDescription = 'Sign addendum error found';

            List<VCC_DASFlowConsolidatedEndpointResult> resultList = new List<VCC_DASFlowConsolidatedEndpointResult>{
                endPoint
            };

            VCC_DASFlowCreateAddendumAndSign addenStub = (VCC_DASFlowCreateAddendumAndSign) new VATEST_StubBuilder(
                    VCC_DASFlowCreateAddendumAndSign.class
                )
                .mockingMethodCall(
                    'handleFlowCreateAddendumAndSign',
                    List<VCC_DASFlowCreateAddendumAndSign.Request>.class
                )
                .withParameterValues(new List<VCC_DASFlowCreateAddendumAndSign.Request>{ createAddendumSign })
                .returning(resultList)
                .defineStub();

            VCC_DASFlowCreateAddendumAndSign.flowCreateAddendumAndSignInstance = addenStub;

            Flow.Interview addendumFlow = Flow.Interview.createInterview(
                'VCC_Sign_Note_Subflow_DAS_Create_Addendum_And_Sign',
                params
            );

            Test.startTest();
            addendumFlow.start();
            Assert.areEqual(
                addendumFlow.getVariableValue('faultFlag_DisplayFlowError'),
                true,
                'Expected faultFlag_DisplayFlowError to be set to true.'
            );
            Assert.areEqual(
                addendumFlow.getVariableValue('faultMessage'),
                'Sign addendum error found',
                'Expected matching result.'
            );
            Test.stopTest();
        }
    }

    @IsTest
    static void unitErrorCodeNegative() {
        System.runAs(VCC_TESTUSER) {
            VCC_Progress_Note__c progressNotesFlow = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
                new VCC_Progress_Note__c()
            );

            VCC_Addendum__c adden = (VCC_Addendum__c) VATEST_SObjectFactory.createSObject(
                new VCC_Addendum__c(VCC_Related_Note__c = progressNotesFlow.Id)
            );

            Map<String, Object> params = new Map<String, Object>();

            //Flow Variables

            VCC_Vdif_NoteAndEncounterParams neParams = new VCC_Vdif_NoteAndEncounterParams();
            neParams.noteAndEncounterNoteTitleIen = 'tests';
            neParams.itemId = 'tests';

            VCC_Vdif_PatientAndProviderParams pParams = new VCC_Vdif_PatientAndProviderParams();
            pParams.esig = 'test1';
            pParams.providerName = 'test2';
            pParams.providerUserId = 'test3';
            pParams.providerLoginSiteCode = 'test6';

            params.put('recordId', adden.Id);
            params.put('ProgressNoteRecord_DAS', progressNotesFlow);
            params.put('noteAndEncounterParams', neParams);
            params.put('patientAndProviderParams', pParams);

            //Stubbing The Data

            VCC_DASFlowCreateAddendumAndSign.Request createAddendumSign = new VCC_DASFlowCreateAddendumAndSign.Request();
            createAddendumSign.recordId = adden.Id;
            createAddendumSign.esig = 'test1';
            createAddendumSign.providerName = 'test2';
            createAddendumSign.providerUserId = 'test3';
            createAddendumSign.type = 'tests';
            createAddendumSign.siteCode = 'test6';
            createAddendumSign.itemId = 'tests';

            //RETURN vcc_das
            VCC_DASCreateAddendumAndSignSuccessRS addenRs = new VCC_DASCreateAddendumAndSignSuccessRS();
            addenRs.textTo.text = 'Addendum 1';
            addenRs.textTo.addendumIen = 'Addendum 2';

            VCC_DASFlowConsolidatedEndpointResult endPoint = new VCC_DASFlowConsolidatedEndpointResult(addenRs);
            endPoint.noteOrAddendumIen = null;
            endPoint.isError = true;
            endPoint.errorCode = null;
            endPoint.errorDescription = 'Sign addendum error found';

            List<VCC_DASFlowConsolidatedEndpointResult> resultList = new List<VCC_DASFlowConsolidatedEndpointResult>{
                endPoint
            };

            VCC_DASFlowCreateAddendumAndSign addenStub = (VCC_DASFlowCreateAddendumAndSign) new VATEST_StubBuilder(
                    VCC_DASFlowCreateAddendumAndSign.class
                )
                .mockingMethodCall(
                    'handleFlowCreateAddendumAndSign',
                    List<VCC_DASFlowCreateAddendumAndSign.Request>.class
                )
                .withParameterValues(new List<VCC_DASFlowCreateAddendumAndSign.Request>{ createAddendumSign })
                .returning(resultList)
                .defineStub();

            VCC_DASFlowCreateAddendumAndSign.flowCreateAddendumAndSignInstance = addenStub;

            Flow.Interview addendumFlow = Flow.Interview.createInterview(
                'VCC_Sign_Note_Subflow_DAS_Create_Addendum_And_Sign',
                params
            );

            Test.startTest();
            addendumFlow.start();
            Assert.areEqual(
                addendumFlow.getVariableValue('faultFlag_DisplayFlowError'),
                true,
                'Expectedault Flag_DisplayFlowError to be set to true.'
            );
            Assert.areEqual(
                addendumFlow.getVariableValue('faultMessage'),
                'Sign addendum error found',
                'Expected matching result.'
            );
            Test.stopTest();
        }
    }

    @IsTest
    static void unitInvocableMethodTestPositive() {
        System.runAs(VCC_TESTUSER) {
            VCC_Progress_Note__c progressNotesFlow = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
                new VCC_Progress_Note__c()
            );

            VCC_Addendum__c adden = (VCC_Addendum__c) VATEST_SObjectFactory.createSObject(
                new VCC_Addendum__c(VCC_Related_Note__c = progressNotesFlow.Id)
            );

            Map<String, Object> params = new Map<String, Object>();

            //Flow Variables

            VCC_Vdif_NoteAndEncounterParams neParams = new VCC_Vdif_NoteAndEncounterParams();
            neParams.noteAndEncounterNoteTitleIen = 'tests';
            neParams.itemId = 'tests';

            VCC_Vdif_PatientAndProviderParams pParams = new VCC_Vdif_PatientAndProviderParams();
            pParams.esig = 'test1';
            pParams.providerName = 'test2';
            pParams.providerUserId = 'test3';
            pParams.providerLoginSiteCode = 'test6';

            params.put('recordId', adden.Id);
            params.put('ProgressNoteRecord_DAS', progressNotesFlow);
            params.put('noteAndEncounterParams', neParams);
            params.put('patientAndProviderParams', pParams);

            //Stubbing The Data

            VCC_DASFlowCreateAddendumAndSign.Request createAddendumSign = new VCC_DASFlowCreateAddendumAndSign.Request();
            createAddendumSign.recordId = adden.Id;
            createAddendumSign.esig = 'test1';
            createAddendumSign.providerName = 'test2';
            createAddendumSign.providerUserId = 'test3';
            createAddendumSign.type = 'tests';
            createAddendumSign.siteCode = 'test6';
            createAddendumSign.itemId = 'tests';

            //RETURN vcc_das
            VCC_DASCreateAddendumAndSignSuccessRS addenRs = new VCC_DASCreateAddendumAndSignSuccessRS();
            addenRs.textTo.text = 'Addendum 1';
            addenRs.textTo.addendumIen = 'Addendum 2';

            VCC_DASFlowConsolidatedEndpointResult endPoint = new VCC_DASFlowConsolidatedEndpointResult(addenRs);
            endPoint.isError = false;

            List<VCC_DASFlowConsolidatedEndpointResult> resultList = new List<VCC_DASFlowConsolidatedEndpointResult>{
                endPoint
            };

            VCC_DASFlowCreateAddendumAndSign addenStub = (VCC_DASFlowCreateAddendumAndSign) new VATEST_StubBuilder(
                    VCC_DASFlowCreateAddendumAndSign.class
                )
                .mockingMethodCall(
                    'handleFlowCreateAddendumAndSign',
                    List<VCC_DASFlowCreateAddendumAndSign.Request>.class
                )
                .withParameterValues(new List<VCC_DASFlowCreateAddendumAndSign.Request>{ createAddendumSign })
                .returning(resultList)
                .defineStub();

            VCC_DASFlowCreateAddendumAndSign.flowCreateAddendumAndSignInstance = addenStub;

            Flow.Interview addendumFlow = Flow.Interview.createInterview(
                'VCC_Sign_Note_Subflow_DAS_Create_Addendum_And_Sign',
                params
            );

            Test.startTest();
            addendumFlow.start();
            Assert.areEqual(
                addendumFlow.getVariableValue('faultOccurred'),
                false,
                'Expected faultOccurred to be set to false.'
            );
            Test.stopTest();
        }
    }

    @IsTest
    static void unitfaultPath2Positive() {
        System.runAs(VCC_TESTUSER) {
            VCC_Progress_Note__c progressNotesFlow = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
                new VCC_Progress_Note__c()
            );

            VCC_Addendum__c adden = (VCC_Addendum__c) VATEST_SObjectFactory.createSObject(
                new VCC_Addendum__c(VCC_Related_Note__c = progressNotesFlow.Id)
            );

            Map<String, Object> params = new Map<String, Object>();

            //Flow Variables

            VCC_Vdif_NoteAndEncounterParams neParams = new VCC_Vdif_NoteAndEncounterParams();
            neParams.noteAndEncounterNoteTitleIen = 'tests';
            neParams.itemId = 'tests';

            VCC_Vdif_PatientAndProviderParams pParams = new VCC_Vdif_PatientAndProviderParams();
            pParams.esig = 'test1';
            pParams.providerName = 'test2';
            pParams.providerUserId = 'test3';
            pParams.providerLoginSiteCode = 'test6';

            params.put('recordId', adden.Id);
            params.put('ProgressNoteRecord_DAS', progressNotesFlow);

            Flow.Interview addendumFlow = Flow.Interview.createInterview(
                'VCC_Sign_Note_Subflow_DAS_Create_Addendum_And_Sign',
                params
            );

            Test.startTest();
            addendumFlow.start();
            Assert.areEqual(
                addendumFlow.getVariableValue('faultOccurred'),
                true,
                'Expected faultOccurred to be set to true.'
            );
            Test.stopTest();
        }
    }
}
