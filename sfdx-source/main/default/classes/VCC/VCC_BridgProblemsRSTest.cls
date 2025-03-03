@isTest
public with sharing class VCC_BridgProblemsRSTest {
    @isTest
    public static void instantiationTest() {
        Test.startTest();
        System.assert(new VCC_BridgProblemsRS() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsSite() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsResults() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsProblems() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsProblem() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsAcuity() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsComments() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsSctt() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsSctc() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsEntered() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsIcd() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsIcdd() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsSc() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsRemoved() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsProvider() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsSctd() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsName() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsUnverified() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsLocation() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsCodingSystem() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsId() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsFacility() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsUpdated() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsStatus() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsExposures() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsOnset() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsResolved() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsService() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsComment() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgProblemsRS.ProblemsExposure() != null, 'Instantiation failed.');
        Test.stopTest();
    }

    @isTest
    public static void baseResponse() {
        VCC_BaseClient.BaseResponse base = new VCC_BaseClient.BaseResponse();
        VCC_BridgProblemsRS bridg = new VCC_BridgProblemsRS();
        bridg.sites.add(new VCC_BridgProblemsRS.ProblemsSite());
        bridg.sites[0].isMaxRecordsError = false;
        bridg.sites[0].results.version = 'Exceeded Max';
        base.httpResponse = new HttpResponse();
        base.httpResponse.setBody(json.serialize(bridg));

        Test.startTest();
        System.assert(bridg.sites[0].isMaxRecordsError == false, ' Variable isMaxRecordsError  does not exist and is not instantiated');
        VCC_BridgProblemsRS bridg2 = new VCC_BridgProblemsRS(base);
        System.assertEquals(true, bridg2.sites[0].isMaxRecordsError);
        Test.stopTest();
    }
}
