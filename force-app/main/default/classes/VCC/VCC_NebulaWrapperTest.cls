/**
 * @description Test class for VCC_NebulaWrapper
 * @author Booz Allen Hamilton
 * @since 06/22/2024
 * @see VCC_NebulaWrapper
 */
@IsTest
private class VCC_NebulaWrapperTest {
    /**
     * @description Creating an Admin test user
     * @return `User`
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

    @IsTest
    static void unitConstructorPositive() {
        System.runAs(createTestAdminUser()) {
            Test.startTest();
            Assert.isNotNull(new VCC_NebulaWrapper(), 'Expected non-null return value');
            Test.stopTest();
        }

    }

    @IsTest
    static void unitGetTransactionIdPositive() {
        System.runAs(createTestAdminUser()) {
            VCC_NebulaWrapper nebulaWrapper = new VCC_NebulaWrapper();
            Test.startTest();
            Assert.isNotNull(nebulaWrapper.getTransactionId(), 'Expected non-null return value');
            Test.stopTest();
        }
    }

    @IsTest
    static void unitDebugPositive() {
        System.runAs(createTestAdminUser()) {
            VCC_NebulaWrapper nebulaWrapper = new VCC_NebulaWrapper();
            Test.startTest();
            Assert.isNotNull(nebulaWrapper.debug('test'), 'Expected non-null return value');
            Test.stopTest();
        }
    }

    @IsTest
    static void unitDebugNullArgsNegative() {
        System.runAs(createTestAdminUser()) {
            VCC_NebulaWrapper nebulaWrapper = new VCC_NebulaWrapper();
            Test.startTest();
            Assert.isNotNull(nebulaWrapper.debug(null), 'Expected non-null return value');
            Test.stopTest();
        }
    }

    @IsTest
    static void unitErrorPositive() {
        System.runAs(createTestAdminUser()) {
            VCC_NebulaWrapper nebulaWrapper = new VCC_NebulaWrapper();
            Test.startTest();
            Assert.isNotNull(nebulaWrapper.error('test', new NullPointerException()), 'Expected non-null return value');
            Test.stopTest();
        }
    }

    @IsTest
    static void unitErrorObjectAsSecondArgNegative() {
        System.runAs(createTestAdminUser()) {
            VCC_NebulaWrapper nebulaWrapper = new VCC_NebulaWrapper();
            Test.startTest();
            Assert.isNotNull(nebulaWrapper.error('test', (Object) null), 'Expected non-null return value');
            Test.stopTest();
        }
    }

    @IsTest
    static void unitErrorNullArgsNegative() {
        System.runAs(createTestAdminUser()) {
            VCC_NebulaWrapper nebulaWrapper = new VCC_NebulaWrapper();
            Test.startTest();
            Assert.isNotNull(nebulaWrapper.error(null, null), 'Expected non-null return value');
            Test.stopTest();
        }
    }

    @IsTest
    static void unitSaveLogPositive() {
        System.runAs(createTestAdminUser()) {
            VCC_NebulaWrapper nebulaWrapper = new VCC_NebulaWrapper();
            Test.startTest();
            nebulaWrapper.saveLog();
            Assert.isTrue(true, 'No exceptions. Test passes.');
            Test.stopTest();
        }
    }
}
