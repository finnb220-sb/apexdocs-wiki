/**
 * @description       : Test Class for TUC_EscalatePauseButtonController
 * @author            : Booz Allen
 **/
@isTest
public with sharing class TUC_EscalatePauseButtonControllerTest {
    static final String TEST_QUEUE_TYPE = 'High Acuity'; //must match a Tele-EC Queue Type, defined in the TUC_Queue_Type__c field
    static final String TEST_PAUSE_REASON = 'Provider unavailable- service at capacity'; //must match a Tele-EC Pause Reason, defined in the TUC_Pause_Reason__c field

    /**
     * @description - Simple test for the get visn data
     */
    @isTest
    public static void unitTestGetVISNData() {
        User minimumAccessMolly = VATEST_UserFactory.createMinAccessPersonaUser(false);
        minimumAccessMolly.Division = 'VISN 0';
        System.runAs(minimumAccessMolly) {
            Test.startTest();
            String visn = TUC_EscalatePauseButtonController.getVISNData();
            Assert.areEqual('0', visn, 'Expected 0 but was ' + visn);
            Test.stopTest();
        }
    }

    /**
     * @description - Functional test for the status record creation. Builds out a mock record, stubs the create repo call, and then runs the function and tests.
     */
    @isTest
    public static void funcTestCreateStatus() {
        String providedVisn = '0';
        String queueType = TEST_QUEUE_TYPE;
        Tele_EC_Escalation_Status__c escalationStatusPrototype = new Tele_EC_Escalation_Status__c();
        DateTime sys = System.now();
        escalationStatusPrototype.TUC_Status_Datetime__c = DateTime.newInstance(
            sys.year(),
            sys.month(),
            sys.day(),
            sys.hour(),
            sys.minute(),
            0
        );
        escalationStatusPrototype.TUC_VISN__c = providedVisn;
        escalationStatusPrototype.TUC_Is_Current_Status__c = true;
        escalationStatusPrototype.TUC_Queue_Type__c = queueType;
        escalationStatusPrototype.TUC_Pause_Reason__c = TEST_PAUSE_REASON;
        escalationStatusPrototype.TUC_Status_Type__c = 'Paused';
        Tele_EC_Escalation_Status__c escalationStatusPrototypeResumed = new Tele_EC_Escalation_Status__c();
        escalationStatusPrototypeResumed.TUC_Status_Datetime__c = DateTime.newInstance(
            sys.year(),
            sys.month(),
            sys.day(),
            sys.hour(),
            sys.minute(),
            0
        );
        escalationStatusPrototypeResumed.TUC_VISN__c = providedVisn;
        escalationStatusPrototypeResumed.TUC_Is_Current_Status__c = true;
        escalationStatusPrototypeResumed.TUC_Queue_Type__c = queueType;
        escalationStatusPrototypeResumed.TUC_Pause_Reason__c = TEST_PAUSE_REASON;
        escalationStatusPrototypeResumed.TUC_Original_Pause_Record__c = null;
        escalationStatusPrototypeResumed.TUC_Status_Type__c = 'Resumed';
        List<Tele_EC_Escalation_Status__c> recordList = new List<Tele_EC_Escalation_Status__c>{
            escalationStatusPrototype
        };

        TUC_TeleEcEscalationStatusRepo stubRepo = (TUC_TeleEcEscalationStatusRepo) new VATEST_StubBuilder(
                TUC_TeleEcEscalationStatusRepo.class
            )
            .mockingMethodCall('getEscalationStatusWithVisnAndQueueType')
            .withParameterTypes(String.class, String.class)
            .withParameterValues(providedVisn, queueType)
            .returning(recordList)
            .mockingMethodCall('doUpdate')
            .withParameterTypes(sObject.class)
            .withParameterValues(escalationStatusPrototype)
            .returning()
            .mockingMethodCall('doCreate')
            .withParameterTypes(sObject.class)
            .withParameterValues(escalationStatusPrototypeResumed)
            .returning()
            .defineStub();
        TUC_EscalatePauseButtonController.memoizedEscalationRepo = stubRepo; // dependency injected a fake implementation of the repo.

        String fieldsJSON =
            '{"providedVISN":"0","queueType":"' +
            TEST_QUEUE_TYPE +
            '","pauseReason":"' +
            TEST_PAUSE_REASON +
            '"}';

        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet('TED_Medical_Provider_Group')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(false);

        System.runAs(doctorUser) {
            Test.startTest();
            String statusRet = TUC_EscalatePauseButtonController.createTeleEcStatusRecord(fieldsJSON);
            Assert.areEqual('Success', statusRet, 'Expected Success but was ' + statusRet);
            Test.stopTest();
        }
    }

    /**
     * @description - Functional test for the get escalation status. Mocks and creates an escalation record, stubs the query method on the repo, then tests that record is queried correctly
     */
    @isTest
    public static void funcTestGetStatus() {
        String providedVisn = '0';
        String queueType = TEST_QUEUE_TYPE;
        Tele_EC_Escalation_Status__c escalationStatusPrototype = new Tele_EC_Escalation_Status__c();
        DateTime sys = System.now();
        escalationStatusPrototype.TUC_Status_Datetime__c = DateTime.newInstance(
            sys.year(),
            sys.month(),
            sys.day(),
            sys.hour(),
            sys.minute(),
            0
        );
        escalationStatusPrototype.TUC_VISN__c = providedVisn;
        escalationStatusPrototype.TUC_Is_Current_Status__c = true;
        escalationStatusPrototype.TUC_Queue_Type__c = queueType;
        escalationStatusPrototype.TUC_Pause_Reason__c = TEST_PAUSE_REASON;
        escalationStatusPrototype.TUC_Status_Type__c = 'Paused';
        Tele_EC_Escalation_Status__c mockRecord = ((Tele_EC_Escalation_Status__c) VATEST_SObjectFactory.createSObject(
            escalationStatusPrototype,
            true
        ));
        List<Tele_EC_Escalation_Status__c> recordList = new List<Tele_EC_Escalation_Status__c>{ mockRecord };

        TUC_TeleEcEscalationStatusRepo stubRepo = (TUC_TeleEcEscalationStatusRepo) new VATEST_StubBuilder(
                TUC_TeleEcEscalationStatusRepo.class
            )
            .mockingMethodCall('getEscalationStatusWithVisnAndQueueType')
            .withParameterTypes(String.class, String.class)
            .withParameterValues(providedVisn, queueType)
            .returning(recordList)
            .defineStub();
        TUC_EscalatePauseButtonController.memoizedEscalationRepo = stubRepo; // dependency injected a fake implementation of the repo.

        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet('TED_Medical_Provider_Group')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(false);

        System.runAs(doctorUser) {
            Test.startTest();
            Tele_EC_Escalation_Status__c statusRecord = TUC_EscalatePauseButtonController.getCurrentStatusRecord(
                providedVisn,
                queueType
            );
            String statusString = statusRecord.TUC_Status_Type__c;
            Assert.areEqual('Paused', statusString, 'Expected Paused but was ' + statusString);
            Test.stopTest();
        }
    }

    /**
     * @description - Tests the parse method, providing a bad json to the create function, testing for a negative result.
     */
    @isTest
    public static void unitTestDeserializeJSONParseNegative() {
        Boolean exceptionThrown = false;
        String testJSON = '{"Statu$\';"Close@"}}';
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet('TED_Medical_Provider_Group')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(false);

        System.runAs(doctorUser) {
            Test.startTest();
            try {
                TUC_EscalatePauseButtonController.createTeleEcStatusRecord(testJSON);
            } catch (AuraHandledException e) {
                if (e.getMessage().contains('JSON is malformed')) {
                    exceptionThrown = true;
                }
            }
            Test.stopTest();
            Assert.isTrue(exceptionThrown, 'Aura exception occurred, expected result');
        }
    }
}
