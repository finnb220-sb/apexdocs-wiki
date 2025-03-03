/**
 * @description       : Class used to test the NTSP_CaseTriggerHelper Apex class
 * @author            : George Elias
 * @group             : Liberty IT Solutions
 * @last modified on  : 03-22-2022
 * @last modified by  : George Elias
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   03-22-2022   George Elias                          Initial Version
 **/
@isTest
public class NTSP_CaseTriggerHelper_Test {
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
     * @description Unit test for the populateESTHour method in the NTSP_CaseTriggerHelper class
     * @author George Elias | 03-22-2022
     * @return  void
     **/
    @isTest
    static void populateESTHourTest() {
        List<NTSP_Case__c> caseList = [SELECT Id, NTSP_Facility__c FROM NTSP_Case__c];

        for (NTSP_Case__c ntspCase : caseList) {
            ntspCase.Consult_Time_Local_Time_24_hrs__c = '1200';
        }
        final User consultant = [SELECT Id, Name FROM User WHERE LastName = 'NTSP Consultant' LIMIT 1];
        final NTSP_Facility__c location = [SELECT Id, Name, CreatedById, NTSP_Registered_Site__c FROM NTSP_Facility__c WHERE Name = 'Test 1' LIMIT 1];
        NTSP_Case__c ntspCase = new NTSP_Case__c(
            Consult_Date__c = Date.today(),
            Consult_Time_Local_Time_24_hrs__c = '1200',
            Last_Name__c = 'test',
            Last_Four__c = '1234',
            Telestroke_Consultant__c = consultant.Id,
            NTSP_Facility__c = location.Id,
            Location__c = 'Inpatient',
            Outcome__c = 'Cancelled'
        );

        insert ntspCase;

        ntspCase = [SELECT consult_hour__c FROM NTSP_Case__c WHERE Id = :ntspCase.Id];

        System.assertEquals('13', ntspCase.Consult_Hour__c);
    }
}
