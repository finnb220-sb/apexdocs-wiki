/**
 *  Description: Test class for ApexTestQueueItemSelector
 *  Author: Booz Allen Hamilton
 *
 *  @see ApexTestQueueItemSelector
 */
@IsTest
private class ApexTestQueueItemSelectorTest {
    private static final User VAVET_BASE_USER = new VATEST_UserBuilder()
        .withUserProfile('VAVET Base Profile')
        .withPermissionSet('VCC_Medical_Provider')
        .withStandardData()
        .build(true);

    /**
     * This method is strictly for coverage since we can't cannot create data to actually test this.
     */
    @IsTest
    static void testClass() {
        System.runAs(VAVET_BASE_USER) {
            Id testJobId = DTCTestUtil.generateId(ApexTestQueueItem.getSObjectType());
            System.assertNotEquals(
                null,
                new ApexTestQueueItemSelector().getRecordsById(new Set<Id>{ testJobId }),
                'Should not be null'
            );
            System.assertNotEquals(
                null,
                new ApexTestQueueItemSelector().getRecordByParentJobIds(new List<Id>{ testJobId }),
                'Should not be null'
            );
        }
    }
}
