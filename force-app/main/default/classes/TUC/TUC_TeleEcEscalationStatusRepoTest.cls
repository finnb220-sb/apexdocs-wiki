/**
 * @description Tests the TUC_TeleEcEscalationStatusRepo class
 * @author Booz Allen
 *
 * @see TUC_TeleEcEscalationStatusRepo for class being tested
 *
 */
@isTest
public with sharing class TUC_TeleEcEscalationStatusRepoTest {
    /**
     * @description Test fetching Tele EC Escalation object for positive result
     */
    @IsTest
    private static void unitTestgetEscalationStatusWithVisnAndQueueTypePositive() {
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet('TED_Medical_Provider')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);

        System.runAs(doctorUser) {
            String providedVisn = '0';
            String queueType = 'High Acuity';
            Tele_EC_Escalation_Status__c escalationStatusPrototype = new Tele_EC_Escalation_Status__c();
            escalationStatusPrototype.TUC_Status_Datetime__c = System.now();
            escalationStatusPrototype.TUC_VISN__c = providedVisn;
            escalationStatusPrototype.TUC_Is_Current_Status__c = true;
            escalationStatusPrototype.TUC_Queue_Type__c = queueType;
            escalationStatusPrototype.TUC_Pause_Reason__c = 'Provider unavailable- service at capacity';
            escalationStatusPrototype.TUC_Status_Type__c = 'Paused';
            VATEST_SObjectFactory.createSObject(escalationStatusPrototype, true);

            TUC_TeleEcEscalationStatusRepo testRepo = new TUC_TeleEcEscalationStatusRepo();
            List<Tele_EC_Escalation_Status__c> results = testRepo.getEscalationStatusWithVisnAndQueueType(
                providedVisn,
                queueType
            );

            Assert.areEqual(
                results.size(),
                1,
                'Expected single record to be returned but ' + results.size() + ' were returned'
            );
        }
    }

    /**
     * @description Test fetching Tele EC Escalation object for negative result
     */
    @IsTest
    private static void unitTestgetEscalationStatusWithVisnAndQueueTypeNegative() {
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet('TED_Medical_Provider')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);

        System.runAs(doctorUser) {
            TUC_TeleEcEscalationStatusRepo testRepo = new TUC_TeleEcEscalationStatusRepo();
            List<Tele_EC_Escalation_Status__c> results = testRepo.getEscalationStatusWithVisnAndQueueType(
                '1',
                'Intermediate Acuity'
            );

            Assert.areEqual(
                results.size(),
                0,
                'Expected no records to be returned but ' + results.size() + ' were returned'
            );
        }
    }
}
