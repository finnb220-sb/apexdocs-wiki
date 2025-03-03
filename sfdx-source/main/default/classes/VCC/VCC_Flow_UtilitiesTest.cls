@IsTest
/**
 * @description
 * @author Patrick Skamarak
 * @since 8/5/2021
 * @see VCC_Flow_Utilities
 * @group Test Classes
 */
public class VCC_Flow_UtilitiesTest {
    @TestSetup
    static void makeData() {
        Case testCase = new Case();
        testCase.RecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Clinical Triage Case').getRecordTypeId();
        insert testCase;
        VCC_Progress_Note__c pn = new VCC_Progress_Note__c(VCC_Case__c = testCase.Id);
        insert pn;
        VCC_Addendum__c ad = new VCC_Addendum__c(VCC_Related_Note__c = pn.Id, VCC_Addendum__c = 'Addendum Description here...');
        insert ad;
    }
    @IsTest
    public static void getSObjectTypeTest() {
        VCC_Flow_Utilities.ActionParams params = new VCC_Flow_Utilities.ActionParams();
        params.actionName = 'GetSObjectTypeForId';
        params.recordId = [
            SELECT Id
            FROM VCC_Progress_Note__c
            LIMIT 1
        ]
        .Id;
        System.assert(VCC_Flow_Utilities.flowUtility(new List<VCC_Flow_Utilities.ActionParams>{ params })[0] == 'VCC_Progress_Note__c');

        params.recordId = [
            SELECT Id
            FROM VCC_Addendum__c
            LIMIT 1
        ]
        .Id;
        System.assert(VCC_Flow_Utilities.flowUtility(new List<VCC_Flow_Utilities.ActionParams>{ params })[0] == 'VCC_Addendum__c');
    }
}
