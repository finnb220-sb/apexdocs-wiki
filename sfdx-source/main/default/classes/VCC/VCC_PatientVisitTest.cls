@IsTest
public with sharing class VCC_PatientVisitTest {
    @testSetup
    static void makeData() {
        VCC_TestDataFactory.insertUser('System Administrator');

        insert new Account(Name = 'test');
    }
    /**
     * @description create a test user for running tests
     * @return A test user
     **/
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
    }

    @IsTest
    public static void ctor() {
        System.runAs(getTestUser()) {
            VCC_PatientVisit visit;

            Test.startTest();
            visit = new VCC_PatientVisit();
            Test.stopTest();

            System.assert(visit != null, 'Patient Visit did not construct.');
        }
    }
    @IsTest
    public static void patientVisitWithVisitItem() {
        System.runAs(getTestUser()) {
            Account acc = new Account(
                LastName = 'Patient1',
                VCC_MVI_External_Id__pc = 'te123456st',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
            );
            insert acc;

            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);

            VCC_BridgVisitsRS rsBdy = new VCC_BridgVisitsRS();
            rsBdy.sites.add(new VCC_BridgVisitsRs.VisitSite());
            VCC_BridgVisitsRS.VisitItem itm = new VCC_BridgVisitsRs.VisitItem();
            itm.dateTime_s = '20180523153210';
            itm.locationName = 't';
            rsBdy.sites[0].data.items.add(itm);
            rsBdy.sites[0].data.totalItems = '1';

            res.setBody(JSON.serialize(rsBdy));
            VCC_HttpOverride_Mock.mockAll(res);

            VCC_PatientVisit visit;

            Test.startTest();
            visit = new VCC_PatientVisit(itm);
            Test.stopTest();

            System.assert(visit != null, 'Patient Visit with visit item did not construct.');
        }
    }
}
