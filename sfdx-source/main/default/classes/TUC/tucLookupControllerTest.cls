@isTest
/**
 * @description
 * @author Neelam Pandey
 * @since
 * @group Test Classes
 * @see tucLookupController
 */
public class tucLookupControllerTest {
    @isTest
    public static void testLookup() {
        Test.startTest();
        tucLookupController.findRecords('613', 'Day', 'VCC_Virtual_Visit_Progress_Note');
        tucLookupController.findRecords('613', 'Day', 'VCC_Scheduling_Progress_Note');
        tucLookupController.findRecords('613', 'Day', 'VCC_Tier_I_Progress_Note');
        tucLookupController.findRecords('613', 'Day', 'VCC_Tier_II_Progress_Note');
        tucLookupController.findRecords('613', 'Day', 'VCC_Clinical_Triage_Note_Progress_Note');
        Test.stopTest();
    }
}
