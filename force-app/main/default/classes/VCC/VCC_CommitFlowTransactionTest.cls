/**
 * @description This class contains unit tests for the VCC_CommmitFlowTransaction class.
 * @author BAH
 * @see VCC_CommitFlowTransaction
 */

@isTest
private class VCC_CommitFlowTransactionTest {
    private static User getTestUser() {
        return (new VATEST_UserBuilder())
            .withStandardData()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSets(
                new Set<String>{
                    'HealthCloudFoundation',
                    'VAHC_Read_Progress_Notes',
                    'VAHC_RN_Standard_VCC_User',
                    'VAHC_RN_User',
                    'VAHC_Write_Clinical_Triage_Progress_Note',
                    'VAHC_Standard_VCC_User',
                    'VCC_DAS'
                }
            )
            .build(true);
    }

    @isTest
    static void unitPerformDummyActionPositive() {
        System.runAs(getTestUser()) {
            Test.startTest();
            try {
                VCC_CommitFlowTransaction.performDummyAction();
                Assert.isTrue(true, 'Method executed without exception');
            } catch (Exception thrownException) {
                Assert.fail('Unexpected exception thrown: ' + thrownException.getMessage());
            }
            Test.stopTest();
        }
    }
}
