/**
 * @description       : Test Class for TUC_GetCurrentVISNStatusInvocable
 * @author            : Booz Allen
 * @see               : TUC_GetCurrentVISNStatusInvocable
 **/
@IsTest
private class TUC_GetCurrentVISNStatusInvocableTest {
    /**
     * @description - Unit test for the get escalation status. Mocks and creates an escalation record, stubs the query method on the repo, then tests that record is queried correctly
     */
    @isTest
    public static void unitGetStatus() {
        String providedVisn = '0';
        String queueType = 'High Acuity';
        Tele_EC_Escalation_Status__c escalationStatusPrototype = new Tele_EC_Escalation_Status__c();
        escalationStatusPrototype.TUC_Status_Datetime__c = System.now();
        escalationStatusPrototype.TUC_VISN__c = providedVisn;
        escalationStatusPrototype.TUC_Is_Current_Status__c = false;
        escalationStatusPrototype.TUC_Queue_Type__c = queueType;
        escalationStatusPrototype.TUC_Status_Type__c = 'Paused';
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
            .defineStub();
        TUC_EscalatePauseButtonController.memoizedEscalationRepo = stubRepo; // dependency injected a fake implementation of the repo.

        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet('TED_Medical_Provider_Group')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(false);

        System.runAs(doctorUser) {
            String statusString;
            List<String> returnListEmptyCheck;
            List<String> returnListNoRecord;
            Test.startTest();
            {
                TUC_GetCurrentVISNStatusInvocable.EscalationStatusRequest escalationRequest = new TUC_GetCurrentVISNStatusInvocable.EscalationStatusRequest();
                escalationRequest.providedVISN = providedVisn;
                escalationRequest.queueType = queueType;
                List<TUC_GetCurrentVISNStatusInvocable.EscalationStatusRequest> escalationInputs = new List<TUC_GetCurrentVISNStatusInvocable.EscalationStatusRequest>{
                    escalationRequest
                };
                List<String> returnList = TUC_GetCurrentVISNStatusInvocable.getCurrentEscalationStatusInvocable(
                    escalationInputs
                );
                statusString = returnList[0];

                returnListEmptyCheck = TUC_GetCurrentVISNStatusInvocable.getCurrentEscalationStatusInvocable(null);

                stubRepo = (TUC_TeleEcEscalationStatusRepo) new VATEST_StubBuilder(TUC_TeleEcEscalationStatusRepo.class)
                    .mockingMethodCall('getEscalationStatusWithVisnAndQueueType')
                    .withParameterTypes(String.class, String.class)
                    .withParameterValues('30', 'Low Acuity')
                    .returning(new List<Tele_EC_Escalation_Status__c>())
                    .defineStub();
                TUC_EscalatePauseButtonController.memoizedEscalationRepo = stubRepo;

                TUC_GetCurrentVISNStatusInvocable.EscalationStatusRequest escalationRequestNoRecord = new TUC_GetCurrentVISNStatusInvocable.EscalationStatusRequest();
                escalationRequestNoRecord.providedVISN = '30';
                escalationRequestNoRecord.queueType = 'Low Acuity';
                List<TUC_GetCurrentVISNStatusInvocable.EscalationStatusRequest> escalationInputsNoRecord = new List<TUC_GetCurrentVISNStatusInvocable.EscalationStatusRequest>{
                    escalationRequestNoRecord
                };
                returnListNoRecord = TUC_GetCurrentVISNStatusInvocable.getCurrentEscalationStatusInvocable(
                    escalationInputsNoRecord
                );
            }
            Test.stopTest();
            Assert.areEqual(
                'Paused',
                statusString,
                'Expected Paused status when getting Current Escalation Status but was ' + statusString
            );
            Assert.isNotNull(
                returnListEmptyCheck,
                'Expect an empty list to be returned when empty list of Requests is provided'
            );
            Assert.isNotNull(
                returnListNoRecord,
                'Expect empty list to be returned when the request cant be found while getting Current Escalation Status'
            );
        }
    }
}
