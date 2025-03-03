/**
 * @description       : Class used to test the NTSP_NurseNoteController Apex class
 * @author            : George Elias
 * @group             : Liberty IT Solutions
 * @last modified on  : 02-16-2022
 * @last modified by  : George Elias
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   02-16-2022   George Elias                          Initial Version
 **/
@isTest
public class NTSP_NurseNoteController_Test {
    /**
     * @description Method to create test data for unit tests
     * @author George Elias | 02-16-2022
     * @return  void
     **/
    @TestSetup
    static void makeData() {
        final User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = TRUE LIMIT 1];

        System.runAs(testUser) {
            final Profile baseProfile = [SELECT Id FROM Profile WHERE Name = 'VAVET Base Profile'];

            Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));

            final User nurse = new User(
                Email = 'test@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'NTSP Nurse',
                Alias = 'Nurse',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = baseProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'nurse' + randomInt + '@ntsp.com'
            );

            insert nurse;

            final Id nursePM = [SELECT Id, MasterLabel FROM PermissionSetGroup WHERE MasterLabel = 'NTSP Triage Nurse'].Id;

            // PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = nurse.Id, PermissionSetGroupId = nursePM);

            // insert psa;

            NTSP_TestDataFactory.mockPermGroupAssignment(nurse.Id, nursePM);
        }

        final Schema.Location loc = new Schema.Location(Name = 'Test', LocationType = 'Test', VAF_Facility_ID__c = '1234');
        insert loc;

        final NTSP_Facility__c ntspFacility = new NTSP_Facility__c(Name = 'Test', Station_Code__c = '12345', Location__c = loc.Id, NTSP_Registered_Site__c = true);
        insert ntspFacility;

        final NTSP_Case__c ntspCase = new NTSP_Case__c(
            Consult_Date__c = Date.today(),
            Consult_Time_Local_Time_24_hrs__c = '1122',
            Last_Name__c = 'Test',
            Last_Four__c = '1234',
            NTSP_Facility__c = ntspFacility.Id,
            Location__c = 'ED',
            outcome__c = 'Cancelled'
        );

        insert ntspCase;

        final NTSP_Nurse_Note__c note = new NTSP_Nurse_Note__c(NTSP_Case__c = ntspCase.Id);

        insert note;
    }

    /**
     * @description Method to test the fetchCaseSummary method in the NTSP_NurseNoteController class
     * @author George Elias | 02-16-2022
     * @return  void
     **/
    @isTest
    static void fetchCaseSummaryTest() {
        NTSP_Case__c ntspCase = [SELECT Id FROM NTSP_Case__c LIMIT 1];

        Map<String, Object> returnMap = NTSP_NurseNoteController.fetchCaseSummary(ntspCase.Id);

        List<NTSP_Case__c> caseList = (List<NTSP_Case__c>) returnMap.get('case');
        Boolean valueCheck = caseList[0].Id == ntspCase.Id;

        List<NTSP_Nurse_Note__c> noteList = (List<NTSP_Nurse_Note__c>) returnMap.get('note');
        valueCheck = valueCheck && noteList.size() == 1;
        System.assertEquals(valueCheck, true, 'valueCheck was determined to be false, excpected return values are incorrect');
    }
}
