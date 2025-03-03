/**
 * @description test class for PC_AWPushEventRepo.
 * @author      Booz Allen Hamilton
 * @since       2024
 * @see         PC_AWPushEventRepo
 */
@IsTest
private class PC_AWPushEventRepoTest {
    private static PC_AWPushEventRepo systemUnderTest;
    private final static User FLP_USER;
    private final static User SPECIALIST_USER;
    static {
        systemUnderTest = new PC_AWPushEventRepo();

        //mixed DML error workaround
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            FLP_USER = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .withPermissionSet('PrC_FLP_Users')
                .build(true);
            SPECIALIST_USER = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .withPermissionSet('PrC_Specialist_Users')
                .build(true);
        }
    }

    @TestSetup
    static void makeData() {
        PC_AWPushEvent__c awPushEvent = new PC_AWPushEvent__c();
        insert awPushEvent;
    }

    /**
     * @description positive test of getMostRecentAWPushEventByOwner to ensure that the correct Agent Work Push Event record is returned when provided its owner
     */
    @IsTest
    private static void funcGetMostRecentAWPushEventByOwnerPositive() {
        // Test data setup
        PC_AWPushEvent__c expectedAWPushEvent = [SELECT Id, OwnerId FROM PC_AWPushEvent__c LIMIT 1];

        VATEST_SObjectFactory.createSObject(
            new PC_AWPushEvent__Share(
                ParentId = expectedAWPushEvent.Id,
                UserOrGroupId = SPECIALIST_USER.Id,
                RowCause = 'Manual',
                AccessLevel = 'Read'
            ),
            true
        );

        // Actual test
        Test.startTest();

        List<PC_AWPushEvent__c> result;
        System.runAs(SPECIALIST_USER) {
            result = systemUnderTest.getAWPushEventsByOwners(new Set<String>{ expectedAWPushEvent.OwnerId });
        }

        Test.stopTest();

        // Asserts
        Assert.areEqual(
            expectedAWPushEvent.Id,
            result[0].Id,
            'Expected getMostRecentAWPushEventByOwner to return the AW Push Event record created in setup, but a different record was returned.'
        );
    }

    /**
     * @description positive test of performUpsertUnsafe
     */
    @IsTest
    private static void funcPerformUpsertUnsafePositive() {
        // Test data setup
        systemUnderTest = new PC_AWPushEventRepo(true);

        // Actual test

        System.runAs(FLP_USER) {
            Test.startTest();

            systemUnderTest.performUpsertUnsafe(
                new List<PC_AWPushEvent__c>{ new PC_AWPushEvent__c(OwnerId = SPECIALIST_USER.Id) }
            );

            Test.stopTest();
        }

        // Asserts
        Assert.areNotEqual(
            [SELECT COUNT() FROM PC_AWPushEvent__c WHERE OwnerId = :SPECIALIST_USER.Id LIMIT 1],
            0,
            'Expected an AW Push Event record owned by the Specialist User to be upserted successfully by the FLP user, but no record was found'
        );
    }

    /**
     * @description negative test of performUpsertUnsafe
     */
    @IsTest
    private static void funcPerformUpsertUnsafeNegative() {
        // Test data setup
        systemUnderTest = new PC_AWPushEventRepo(true);

        String caughtMessage = '';
        // Actual test
        System.runAs(FLP_USER) {
            Test.startTest();

            try {
                String fakeId = VATEST_IdFactory.get(Type.forName('PC_AWPushEvent__c'));
                systemUnderTest.performUpsertUnsafe(
                    new List<PC_AWPushEvent__c>{ new PC_AWPushEvent__c(OwnerId = fakeId) }
                );
                Assert.fail('Expected an exception to be thrown due to an invalid OwnerId field value.');
            } catch (PC_CustomException caughtException) {
                caughtMessage = caughtException.getMessage();
            }

            Test.stopTest();
        }

        // Asserts
        Assert.isTrue(
            caughtMessage.containsIgnoreCase('FIELD_INTEGRITY_EXCEPTION'),
            'Expected the unsafe upsert to fail and return a field integrity exception message, but it did not fail.'
        );
    }
}
