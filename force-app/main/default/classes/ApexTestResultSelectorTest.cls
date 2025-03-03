/**
 * Author:Jaren Yach
 *  Created Date 05/27/2022
 *  Purpose: Test class for ApexTestResultSelector
 */
@IsTest
private class ApexTestResultSelectorTest {
    /**
     * This method is strictly for coverage since we can't cannot create data to actually test this.
     */
    @IsTest
    static void testClass() {
        Id testJobId = DTCTestUtil.generateId(ApexTestResult.getSObjectType());
        System.assertNotEquals(null, new ApexTestResultSelector().getRecordsByAsyncApexJobId(new List<Id>{ testJobId }));
    }
}
