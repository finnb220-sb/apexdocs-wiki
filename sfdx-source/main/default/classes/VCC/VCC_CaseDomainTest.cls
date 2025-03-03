/**
 * @description       : Test class for VCC_CaseDomain
 * @author            : Booz Allen Hamilton
 * @date              : 12/2024
 **/
@IsTest
private with sharing class VCC_CaseDomainTest {
    /**
     * @description creates test Pharm user
     */
    @TestSetup
    static void makeData() {
        new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSets(new Set<String>{ 'VAHC_Standard_VCC_User', 'VCC_Pharmacy_I', 'HealthCloudFoundation' })
            .withStandardData()
            .build(true);
    }

    /**
     * @description gets test pharm user
     * @return A test pharm user
     */
    public static User getTestPharmUser() {
        return [
            SELECT Id, Title
            FROM User
            WHERE Email LIKE 'Testuser@test.example.com%'
            LIMIT 1
        ];
    }

    /**
     * @description test run of constructor positive
     */
    @IsTest
    private static void unitConstructPositive() {
        System.runAs(getTestPharmUser()) {
            Test.startTest();
            VCC_CaseDomain casedomain = new VCC_CaseDomain();
            Test.stopTest();

            Assert.isNotNull(casedomain, 'Expected the class to be initialized.');
        }
    }

    /**
     * @description tests the init of refill description layout positive
     */
    @IsTest
    private static void unitRefillDescriptionLayoutPositive() {
        System.runAs(getTestPharmUser()) {
            Test.startTest();
            VCC_CaseDomain.RefillDescriptionLayout refillDescriptionLayout = new VCC_CaseDomain.RefillDescriptionLayout();
            Test.stopTest();

            Assert.isNotNull(refillDescriptionLayout, 'Expected class to be initialized.');
            Assert.isTrue(refillDescriptionLayout.success, 'Expected property to be initialized.');
        }
    }

    /**
     * @description test for creating medication refill case to have Pharm user values positive
     */
    @IsTest
    private static void funcCreateMedicationRefillCaseAsPharmUserPositive() {
        Case testCase;
        System.runAs(getTestPharmUser()) {
            Account testAccount = (Account) VATEST_SObjectFactory.createSObject(
                new Account(
                    RecordTypeId = new VCR_AccountRepo().recordTypeConstant.fromDeveloperName('PersonAccount').Id
                ),
                true
            );
            Test.startTest();
            testCase = new VCC_CaseDomain().createMedicationRefillCase(testAccount, 1, true);
            Test.stopTest();
        }

        Assert.isNotNull(testCase, 'Expected a new case to be created.');
        Assert.areEqual(
            'Pharmacy',
            testCase.Type,
            'Expected a new case to be an Admin type but was not: ' + testCase.Type
        );
        Assert.areEqual(
            'Medication Refill',
            testCase.VCC_Case_Reason_Multi__c,
            'Expected case reason to be Medication Refill but was not: ' + testCase.VCC_Case_Reason_Multi__c
        );
        Assert.areEqual(
            'Processed Medication Refill',
            testCase.VCC_Case_Outcome_Multi__c,
            'Expected case outcome to be Processed Medication Refill but was not: ' + testCase.VCC_Case_Outcome_Multi__c
        );
    }

    /**
     * @description test for creating medication refill case to have MSA user values positive
     */
    @IsTest
    private static void funcCreateMedicationRefillCaseAsMSAUserPositive() {
        User testUser = new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSets(new Set<String>{ 'VCC_Advanced_Medical_Support_Assistant', 'HealthCloudFoundation' })
            .withStandardData()
            .build(true);
        Case testCase;
        System.runAs(testUser) {
            Account testAccount = (Account) VATEST_SObjectFactory.createSObject(
                new Account(
                    RecordTypeId = new VCR_AccountRepo().recordTypeConstant.fromDeveloperName('PersonAccount').Id
                ),
                true
            );
            Test.startTest();
            testCase = new VCC_CaseDomain().createMedicationRefillCase(testAccount, 1, true);
            Test.stopTest();
        }
        Assert.isNotNull(testCase, 'Expected a new case to be created.');
        Assert.areEqual(
            'Administrative',
            testCase.Type,
            'Expected a new case to be a Admin type but was not: ' + testCase.Type
        );
        Assert.areEqual(
            'Medication Refill/Renewal',
            testCase.VCC_Case_Reason_Multi__c,
            'Expected case reason to be Medication Refill/Renewal but was not: ' + testCase.VCC_Case_Reason_Multi__c
        );
        Assert.areEqual(
            'Refilled Medication',
            testCase.VCC_Case_Outcome_Multi__c,
            'Expected case outcome to be Refill Medication but was not: ' + testCase.VCC_Case_Outcome_Multi__c
        );
    }

    /**
     * @description Tests the setting of case description when the response is of a failure, negative
     */
    @IsTest
    private static void unitSetMedicationRefillDescriptionNegative() {
        Account testAccount = (Account) VATEST_SObjectFactory.createSObject(
            new Account(RecordTypeId = new VCR_AccountRepo().recordTypeConstant.fromDeveloperName('PersonAccount').Id),
            true
        );
        Case testCase = (Case) VATEST_SObjectFactory.createSObject(
            new Case(
                RecordTypeId = new VCR_CaseRepo().recordTypeConstant.fromDeveloperName('VCC_Pharmacy').Id,
                Subject = 'VCC_CaseDomainTestTest',
                AccountId = testAccount.Id,
                VCC_Caller_Relation__c = 'Self',
                VCC_Caller_Name__c = 'Unit Test'
            ),
            true
        );

        VCC_DivaClient.ResponseJSON responseJSON = new VCC_DivaClient.ResponseJSON();
        responseJSON.prescriptionId = 'fakeId';
        responseJSON.success = false;
        responseJSON.message = 'Fail response';
        List<VCC_DivaClient.ResponseJSON> responseJSONs = new List<VCC_DivaClient.ResponseJSON>{ responseJSON };

        VCC_MedsService.MedRefillRequest medRefillRequest = new VCC_MedsService.MedRefillRequest();
        medRefillRequest.prescriptionId = 'fakeId';
        List<VCC_MedsService.MedRefillRequest> medRefillRequests = new List<VCC_MedsService.MedRefillRequest>{
            medRefillRequest
        };
        System.runAs(getTestPharmUser()) {
            Test.startTest();
            new VCC_CaseDomain().setMedicationRefillDescription(testCase, responseJSONs, medRefillRequests);
            Test.stopTest();
        }

        Assert.isTrue(
            testCase.description.contains('Fail response'),
            'Expected to have failure in description of case but did not'
        );
    }
}
