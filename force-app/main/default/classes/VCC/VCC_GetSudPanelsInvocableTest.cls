@IsTest
public with sharing class VCC_GetSudPanelsInvocableTest {
    @IsTest
    private static void getSUDLabResultsIndexOutOfBounds() {
        Test.startTest();
        try {
            VCC_GetSudPanelsInvocable.getSUDLabResults(new List<String>());
        } catch (System.ListException e) {
            Assert.areEqual('List index out of bounds: 0', e.getMessage(), 'Expected exception messages to match.');
        }
        Test.stopTest();
    }
}
