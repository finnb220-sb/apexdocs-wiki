@IsTest
public with sharing class VCC_MpiRetrieveRSTest {
    private static String username = 'mpiretrs';

    @TestSetup
    public static void makeData() {
        User testUser = VCC_TestDataFactory.insertUser('Standard User');
        VCC_TestDataFactory.assignPermissionSetByName(testUser, 'VAHC_Standard_VCC_User');
        testUser.Username = username + testUser.Username;
        update testUser;
    }

    public static User getTestUser() {
        return [SELECT Id FROM User WHERE Username LIKE :username + '%' LIMIT 1];
    }

    @IsTest
    static void unitConstructorPositveTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            new VCC_MpiRetrieveRS();
            VCC_MpiRetrieveRS.MpiResponse rsMpiResponse = new VCC_MpiRetrieveRS.MpiResponse();
            VCC_MpiRetrieveRS.Address rsAddress = new VCC_MpiRetrieveRS.Address();
            VCC_MpiRetrieveRS.PhoneNumber rsPhoneNumber = new VCC_MpiRetrieveRS.PhoneNumber();
            VCC_MpiRetrieveRS.MedicalCenterFacility rsMedicalCenterFacility = new VCC_MpiRetrieveRS.MedicalCenterFacility();
            VCC_MpiRetrieveRS.CorrelatedId rsCorrelatedId = new VCC_MpiRetrieveRS.CorrelatedId();
            VCC_MpiRetrieveRS.MpiRelationship rsMpiRelationship = new VCC_MpiRetrieveRS.MpiRelationship();

            System.assert(rsMpiResponse != null, 'Expected not null.');
            System.assert(rsAddress != null, 'Expected not null.');
            System.assert(rsPhoneNumber != null, 'Expected not null.');
            System.assert(rsMedicalCenterFacility != null, 'Expected not null.');
            System.assert(rsCorrelatedId != null, 'Expected not null.');
            System.assert(rsMpiRelationship != null, 'Expected not null.');
        }
        Test.stopTest();
    }
}
