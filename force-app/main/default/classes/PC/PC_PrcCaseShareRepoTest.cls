/**
 * @description Test class for PC_PrcCaseShareRepo.
 * @author      Booz Allen
 * @since       2024
 * @see         PC_PrcCaseShareRepo
 */
@IsTest
private class PC_PrcCaseShareRepoTest {
    private final static User FLP_USER;
    private final static User SPECIALIST_USER;

    static {
        FLP_USER = new VATEST_UserBuilder()
            .withPermissionSet('PrC_FLP_Users')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);

        SPECIALIST_USER = new VATEST_UserBuilder()
            .withPermissionSet('PrC_Specialist_Users')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
    }

    /**
     * @description Positive test for Constructor
     */
    @IsTest
    static void unitConstructorPositive() {
        Test.startTest();
        PC_PrcCaseShareRepo repo;
        System.runAs(FLP_USER) {
            repo = new PC_PrcCaseShareRepo();
        }
        Test.stopTest();

        Assert.isNotNull(repo, 'Expected constructor to properly instantiate a PC_PrcCaseShareRepo class object');
        Assert.isTrue(
            String.valueOf(repo).containsIgnoreCase('VTC_BaseRepo.sObjectType=PC_Case__Share'),
            'Expected the SObject type to be PrC Case Share'
        );
    }

    /**
     * @description Positive test unSafe insert on doCreate for PC_Case_share
     */
    @IsTest
    static void unitDoCreatePositive() {
        PC_PrcCaseShareRepo caseShareRepo = new PC_PrcCaseShareRepo();
        PC_PrcCaseRepo repo = new PC_PrcCaseRepo();
        PC_Case__Share caseShare = new PC_Case__Share();
        PC_Case__c testPRCCase;

        System.runAs(FLP_USER) {
            testPRCCase = (PC_Case__c) VATEST_SObjectFactory.createSObject(
                new PC_Case__c(
                    RecordTypeId = repo.recordTypeConstant.fromDeveloperName('Provider_Connect_Case').Id,
                    Status__c = 'Open',
                    Channel__c = 'Chat',
                    Specialty__c = 'Cardiology',
                    isRunningTest_DO_NOT_USE__c = true //this flag prevents the routing Flow from triggering
                ),
                true
            );

            testPRCCase.OwnerId = SPECIALIST_USER.Id;
            update testPRCCase;
        }

        System.runAs(SPECIALIST_USER) {
            caseShare.UserOrGroupId = FLP_USER.Id;
            caseShare.ParentId = testPRCCase.Id;
            caseShare.AccessLevel = 'Edit';

            Test.startTest();
            caseShareRepo.performCreateUnsafe(caseShare);
            Test.stopTest();
        }

        Assert.areEqual(
            FLP_USER.Id,
            caseShare.UserOrGroupId,
            'Expected PRC Case__Share to be created while Running as FLP User'
        );
    }

    /**
     * @description Negative test unSafe insert on doCreate for PC_Case_share
     */
    @IsTest
    static void unitDoCreateNegative() {
        PC_PrcCaseShareRepo caseShareRepo = new PC_PrcCaseShareRepo();
        PC_PrcCaseRepo repo = new PC_PrcCaseRepo();
        PC_Case__Share caseShare = new PC_Case__Share();
        PC_Case__c testPRCCase;
        Boolean hasFailure = false;

        System.runAs(FLP_USER) {
            testPRCCase = (PC_Case__c) VATEST_SObjectFactory.createSObject(
                new PC_Case__c(
                    RecordTypeId = repo.recordTypeConstant.fromDeveloperName('Provider_Connect_Case').Id,
                    Status__c = 'Open',
                    Channel__c = 'Chat',
                    Specialty__c = 'Cardiology',
                    isRunningTest_DO_NOT_USE__c = true //this flag prevents the routing Flow from triggering
                ),
                true
            );

            testPRCCase.OwnerId = SPECIALIST_USER.Id;
            update testPRCCase;
        }

        System.runAs(SPECIALIST_USER) {
            caseShare.UserOrGroupId = FLP_USER.Id;
            caseShare.ParentId = testPRCCase.Id;
            caseShare.AccessLevel = 'test';

            Test.startTest();
            try {
                caseShareRepo.performCreateUnsafe(caseShare);
            } catch (PC_CustomException e) {
                hasFailure = true;
            }
            Test.stopTest();
        }

        // Asserts
        Assert.isTrue(hasFailure, 'Expected Repo method to throw Exception');
    }
}
