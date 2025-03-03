/**
 * @description       : Test Class for TUC_CustomCasePathController
 * @author            : Booz Allen
 **/
@isTest
public with sharing class TUC_CustomCasePathController_Test {
    /**
     * @description - Runs the getCaseData method and tests for positive results
     */
    @isTest
    public static void funcTestGetCaseDataPositive() {
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet('TED_Medical_Provider_Group')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
        Case newCase = (Case) VATEST_SObjectFactory.createSObject(new Case());
        Set<String> exampleSet = new Set<String>{ 'Status' };

        VCR_CaseRepo stubCaseRepo = (VCR_CaseRepo) new VATEST_StubBuilder(VCR_CaseRepo.class)
            .mockingMethodCall('fetchById')
            .withParameterTypes(Id.class, Set<String>.class)
            .withParameterValues(newCase.Id, exampleSet)
            .returning(newCase)
            .defineStub();
        TUC_CustomCasePathController.memoizedCaseRepo = stubCaseRepo; // dependency injected a fake implementation of the case repo.

        System.runAs(doctorUser) {
            Test.startTest();
            sObject retCase = TUC_CustomCasePathController.getCaseData(newCase.Id);
            Test.stopTest();
            Assert.areEqual(newCase.Id, retCase.Id, 'Expected Ids to match');
        }
    }

    /**
     * @description - Checks the caseRepo value. CaseRepo should auto initialize if the memoized caseRepo is null.
     */
    @isTest
    public static void unitTestNullCaseNullRepoNegative() {
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet('TED_Medical_Provider_Group')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
        System.runAs(doctorUser) {
            Assert.isNotNull(TUC_CustomCasePathController.caseRepo, 'Expected Case Repo to not be null.');
        }
    }

    /**
     * @description - Runs the getCaseData method and tests for a negative result with a null input
     */
    @isTest
    public static void unitTestGetCaseDataNullIdNegative() {
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet('TED_Medical_Provider_Group')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
        Boolean exceptionThrown = false;
        System.runAs(doctorUser) {
            Test.startTest();
            try {
                TUC_CustomCasePathController.getCaseData(null);
            } catch (AuraHandledException e) {
                exceptionThrown = true;
            }
            Test.stopTest();
            Assert.isTrue(exceptionThrown, 'Aura exception occurred, expected result');
        }
    }

    /**
     * @description - Runs the getPickListLabels method with a sample String list from initial production, and tests for a positive return of a wrapper list
     */
    @isTest
    public static void funcTestGetPicklistLabelsPositive() {
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet('TED_Medical_Provider_Group')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
        List<String> sampleLabels = new List<String>{
            'New',
            'Patient Call Back',
            'TED Nurse Encounter',
            'Ready for MP',
            'TED MP Encounter',
            'Closed'
        };
        System.runAs(doctorUser) {
            Test.startTest();
            List<TUC_CustomCasePathController.TUC_PathWrapper> wrapperList = TUC_CustomCasePathController.getPickListLabels(
                sampleLabels
            );
            Test.stopTest();
            Assert.areEqual(
                6,
                wrapperList.size(),
                'Expected returned list size to be 6 but was :' + wrapperList.size()
            );
        }
    }

    /**
     * @description - Runs the getPickListLabels method with an empty list, testing for a negative result
     */
    @isTest
    public static void unitTestGetPicklistLabelsEmptyListNegative() {
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet('TED_Medical_Provider_Group')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
        Boolean exceptionThrown = false;
        System.runAs(doctorUser) {
            Test.startTest();
            try {
                TUC_CustomCasePathController.getPickListLabels(new List<String>{});
            } catch (AuraHandledException e) {
                exceptionThrown = true;
            }
            Test.stopTest();
            Assert.isTrue(exceptionThrown, 'Aura exception occurred, expected result');
        }
    }

    /**
     * @description - Tests the updateCaseWithJSONString function, providing a good sample data JSON, then asserts for a positive result
     */
    @isTest
    public static void funcTestCaseUpdateWithMapPositive() {
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet('TED_Medical_Provider_Group')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
        Case newCase = (Case) VATEST_SObjectFactory.createSObject(new Case(Subject = 'Test', Status = 'Closed'));
        String testJSON = '{"Status":"Closed","Subject":"Test"}';

        SobjectType objType = Id.valueOf(newCase.Id).getSObjectType();
        sObject sObjectToUpdate = objType.newSObject();
        sObjectToUpdate.Id = newCase.Id;
        sObjectToUpdate.put('Status', 'Closed');
        sObjectToUpdate.put('Subject', 'Test');

        VCR_CaseRepo stubCaseRepo = (VCR_CaseRepo) new VATEST_StubBuilder(VCR_CaseRepo.class)
            .mockingMethodCall('doUpdate')
            .withParameterTypes(sObject.class)
            .withParameterValues(sObjectToUpdate)
            .returning()
            .defineStub();
        TUC_CustomCasePathController.memoizedCaseRepo = stubCaseRepo; // dependency injected a fake implementation of the case repo.
        System.runAs(doctorUser) {
            Test.startTest();
            String result = TUC_CustomCasePathController.updateCaseWithJSONString(newCase.Id, testJSON);
            Test.stopTest();
            Assert.areEqual(result, 'true', 'Expected return of true but was :' + result);
        }
    }

    /**
     * @description - Tests the updateCaseWithJSONString method, providing a bad JSON entry, testing for a negative result
     */
    @isTest
    public static void unitTestCaseUpdateWithMapBadJSONNegative() {
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet('TED_Medical_Provider_Group')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
        Boolean exceptionThrown = false;
        Case newCase = (Case) VATEST_SObjectFactory.createSObject(new Case());
        String testJSON = '{badData":1234}';

        System.runAs(doctorUser) {
            Test.startTest();
            try {
                TUC_CustomCasePathController.updateCaseWithJSONString(newCase.Id, testJSON);
            } catch (AuraHandledException e) {
                exceptionThrown = true;
            }
            Test.stopTest();
            Assert.isTrue(exceptionThrown, 'Aura exception occurred, expected result');
        }
    }

    /**
     * @description - Tests the updateCaseWithJSONString method, providing a bad JSON dataload, testing for a negative result
     */
    @isTest
    public static void unitTestCaseUpdateWithMapBadDataNegative() {
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet('TED_Medical_Provider_Group')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
        Boolean exceptionThrown = false;
        Case newCase = (Case) VATEST_SObjectFactory.createSObject(new Case());
        String testJSON = '{"Statu$":"Close@"}';

        System.runAs(doctorUser) {
            Test.startTest();
            try {
                TUC_CustomCasePathController.updateCaseWithJSONString(newCase.Id, testJSON);
            } catch (AuraHandledException e) {
                exceptionThrown = true;
            }
            Test.stopTest();
            Assert.isTrue(exceptionThrown, 'Aura exception occurred, expected result');
        }
    }

    /**
     * @description - Tests the updateCaseWithJSONString method, providing a bad id, testing for a negative result
     */
    @isTest
    public static void unitTestCaseUpdateWithMapBadIdNegative() {
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet('TED_Medical_Provider_Group')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
        Boolean exceptionThrown = false;
        String testJSON = '{"Status":"Closed","Subject":"Test"}';

        System.runAs(doctorUser) {
            Test.startTest();
            try {
                TUC_CustomCasePathController.updateCaseWithJSONString(null, testJSON);
            } catch (AuraHandledException e) {
                exceptionThrown = true;
            }
            Test.stopTest();
            Assert.isTrue(exceptionThrown, 'Aura exception occurred, expected result');
        }
    }
}
