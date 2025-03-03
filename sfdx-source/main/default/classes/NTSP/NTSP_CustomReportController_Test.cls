/**
 * @description       : Class used to test the NTSP_CustomReportController Apex class
 * @author            : George Elias
 * @group             : Liberty IT Solutions
 * @last modified on  : 03-22-2022
 * @last modified by  : George Elias
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   03-22-2022   George Elias                          Initial Version
 **/
@isTest
public class NTSP_CustomReportController_Test {
    /**
     * @description Method to create test data for unit tests
     * @author George Elias | 03-22-2022
     * @return  void
     **/
    @TestSetup
    static void makeData() {
        NTSP_TestDataFactory.createTestUsers();
        NTSP_TestDataFactory.createLocations();
        NTSP_TestDataFactory.createCases();
        NTSP_TestDataFactory.createPeerReviews();
    }

    /**
     * @description Unit test for the fetchPicklistOptions method in the NTSP_CustomReportController class
     * @author George Elias | 03-22-2022
     * @return  void
     **/
    @isTest
    static void fetchPicklistOptionsTest() {
        final List<NTSP_Case__c> caseList = [SELECT Id, CreatedById FROM NTSP_Case__c];

        final User consultant = [SELECT Id FROM User WHERE LastName = 'NTSP Consultant PR'];
        NTSP_TestDataFactory.mockCaseCriteriaSharing(caseList, consultant.Id); //Criteria sharing is not evaluated in test classes, added method to mock functionality

        final User admin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];

        //Run as an admin, create users and assign permission sets
        System.runAs(admin) {
            final PermissionSetGroup psg = [SELECT Id FROM PermissionSetGroup WHERE MasterLabel = 'NTSP Telestroke Usage'];
            // insert new PermissionSetAssignment(PermissionSetGroupId = psg.Id, AssigneeId=consultant.Id);
            NTSP_TestDataFactory.mockPermGroupAssignment(consultant.Id, psg.Id);
        }

        System.runAs(consultant) {
            List<Map<String, String>> options = NTSP_CustomReportController.fetchPicklistOptions('Telestroke_Consultant__c', 'Role_Type__c  = \'NTSP Consultant\'');
            System.assert(options.size() >= 3); //The list should at least return the two consultants created in makeData() and the all option.
        }
    }

    /**
     * @description Unit test for the fetchCustomReportData method in the NTSP_CustomReportController class
     * @author George Elias | 03-22-2022
     * @return  void
     **/
    @isTest
    static void fetchCustomReportDataTest() {
        final List<NTSP_Case__c> caseList = [SELECT Id, CreatedById FROM NTSP_Case__c];

        final User consultant = [SELECT Id FROM User WHERE LastName = 'NTSP Consultant PR'];
        NTSP_TestDataFactory.mockCaseCriteriaSharing(caseList, consultant.Id); //Criteria sharing is not evaluated in test classes, added method to mock functionality

        final User admin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];

        //Run as an admin, create users and assign permission sets
        System.runAs(admin) {
            final PermissionSetGroup psg = [SELECT Id FROM PermissionSetGroup WHERE MasterLabel = 'NTSP Telestroke Usage'];
            // insert new PermissionSetAssignment(PermissionSetGroupId = psg.Id, AssigneeId=consultant.Id);
            NTSP_TestDataFactory.mockPermGroupAssignment(consultant.Id, psg.Id);
        }

        System.runAs(consultant) {
            Map<String, List<sObject>> data = NTSP_CustomReportController.fetchCustomReportData(
                'Consult_Date__c = Last_N_Days:365',
                'all',
                'Telestroke_Consultant__c',
                'Outcome__c',
                'None'
            );
            System.assertEquals(data.get('countByDay').size(), caseList.size());
        }
    }
}
