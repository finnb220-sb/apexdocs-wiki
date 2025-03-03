@isTest
public with sharing class VCC_PatientVisitServiceTest {
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
    static void stubTest() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_Stub patientServiceStub = VCC_PatientVisitService.stub();
            System.assert(patientServiceStub.instance === patientServiceStub.instance, 'Expected stub.');
            Test.stopTest();
        }
    }

    @IsTest
    static void getVisitByUuidSadNullArg() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_PatientVisitService.PatientVisitServiceException expectedException;
            try {
                VCC_PatientVisitService.instance.getVisitByUid(null, null);
            } catch (VCC_PatientVisitService.PatientVisitServiceException e) {
                expectedException = e;
            }
            System.assert(expectedException != null, 'Expected an exception.');
            Test.stopTest();
        }
    }

    @IsTest
    static void getVisitByUuidInvalidUrn() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_PatientVisitService.PatientVisitServiceException expectedException;
            try {
                VCC_PatientVisitService.instance.getVisitByUid(new URN(), '12345');
            } catch (VCC_PatientVisitService.PatientVisitServiceException e) {
                expectedException = e;
            }
            System.assert(expectedException != null, 'Expected an exception.');
            Test.stopTest();
        }
    }

    @IsTest
    static void getVisitByUuidSadBadStatus() {
        System.runAs(getTestUser()) {
            VCC_Stub urnServiceStub = VCC_UrnService.stub();
            urnServiceStub.setReturnValue('isValidUrn', true);
            URN visitUrn = new URN();
            visitUrn.namespaceSpecificSection = 'visit';

            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            VCC_HttpOverride_Mock.mockNext(res);

            Test.startTest();
            VCC_RemoteServiceException expectedException;
            try {
                VCC_PatientVisitService.instance.getVisitByUid(visitUrn, '12345');
            } catch (VCC_RemoteServiceException e) {
                expectedException = e;
            }
            System.assert(expectedException != null, 'Expected an exception.');
            Test.stopTest();
        }
    }

    @IsTest
    static void getVisitByUuidSadNoResults() {
        System.runAs(getTestUser()) {
            VCC_Stub urnServiceStub = VCC_UrnService.stub();
            urnServiceStub.setReturnValue('isValidUrn', true);
            URN visitUrn = new URN();
            visitUrn.namespaceSpecificSection = 'visit';

            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(JSON.serialize(new VCC_BridgVisitsRS()));
            VCC_HttpOverride_Mock.mockNext(res);

            Test.startTest();
            VCC_PatientVisitService.PatientVisitServiceException expectedException;
            try {
                VCC_PatientVisitService.instance.getVisitByUid(visitUrn, '12345');
            } catch (VCC_PatientVisitService.PatientVisitServiceException e) {
                expectedException = e;
            }
            System.assert(expectedException != null, 'Expected an exception.');
            Test.stopTest();
        }
    }

    @IsTest
    static void getVisitByUuidHappy() {
        System.runAs(getTestUser()) {
            VCC_Stub urnServiceStub = VCC_UrnService.stub();
            urnServiceStub.setReturnValue('isValidUrn', true);
            URN visitUrn = new URN();
            visitUrn.namespaceSpecificSection = 'visit';

            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);

            VCC_BridgVisitsRS rsBdy = new VCC_BridgVisitsRS();
            rsBdy.sites.add(new VCC_BridgVisitsRs.VisitSite());
            VCC_BridgVisitsRS.VisitItem itm = new VCC_BridgVisitsRs.VisitItem();
            itm.categoryCode = 't';
            rsBdy.sites[0].data.items.add(itm);
            rsBdy.sites[0].data.totalItems = '1';

            res.setBody(JSON.serialize(rsBdy));
            VCC_HttpOverride_Mock.mockNext(res);

            Test.startTest();
            VCC_BridgVisitsRS.VisitItem result = VCC_PatientVisitService.instance.getVisitByUid(visitUrn, '12345');
            System.assert(result.categoryCode == 't', 'Expected correct result.');
            Test.stopTest();
        }

    }
}
