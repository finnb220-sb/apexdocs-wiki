/**
 * @description Tests for VCR_IAMSSOiVistaInstToUserDUZRepo class
 * @author      Booz Allen Hamilton
 *
 * @see VCR_IAMSSOiVistaInstToUserDUZRepo
 */
@IsTest
private with sharing class VCR_IAMSSOiVistaInstToUserDUZRepoTest {
    final static User VAVET_BASE;
    final static User SYS_ADMIN;
    static {
        VAVET_BASE = new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSet('VAHC_Standard_VCC_User')
            .withStandardData()
            .build(true);
        SYS_ADMIN = new VATEST_UserBuilder()
            .withUserProfile('System Administrator')
            .withPermissionSet('VAHC_Standard_VCC_User')
            .withStandardData()
            .build(true);
    }
    /**
     * @description Build test data for use in test methods
     */
    private static void buildData() {
        System.runAs(SYS_ADMIN) {
            List<IAM_SSOi_Vista_Instance_to_User_DUZ__c> iamSSOiVistaInstanceToUserDUZs = new List<IAM_SSOi_Vista_Instance_to_User_DUZ__c>();
            IAM_SSOi_Vista_Instance_to_User_DUZ__c iamSSOiVistaInstanceToUserDUZ = new IAM_SSOi_Vista_Instance_to_User_DUZ__c(
                Name = 'mockSSO',
                DUZ__c = '52064917',
                VistA_Instance__c = '98',
                User_Id__c = VAVET_BASE.Id
            );
            iamSSOiVistaInstanceToUserDUZs = VATEST_SObjectFactory.createSObjects(
                iamSSOiVistaInstanceToUserDUZ,
                5,
                true
            );
        }
    }

    /**
     * @description Test the initialization
     */
    @IsTest
    private static void unitTestRepoPostive() {
        buildData();
        VCR_IAMSSOiVistaInstToUserDUZRepo repo;
        System.runAs(VAVET_BASE) {
            Test.startTest();
            repo = new VCR_IAMSSOiVistaInstToUserDUZRepo();
            repo.fetchByUserId(UserInfo.getUserId());
            Test.stopTest();
        }
        Assert.isNotNull(repo, 'Expected constructor to properly instantiate a VCR_IAMSSOiVistaInstToUserDUZRepo');
    }
    /**
     * @description Test fetchMockSSORecord
     */
    @IsTest
    private static void unitTestfetchMockSSORecordPostive() {
        buildData();
        VCR_IAMSSOiVistaInstToUserDUZRepo repo = new VCR_IAMSSOiVistaInstToUserDUZRepo();
        System.runAs(VAVET_BASE) {
            Test.startTest();
            repo.fetchMockSSORecord(UserInfo.getUserId());
            Test.stopTest();
        }
        Assert.isNotNull(repo, 'Expected repo to not be null');
    }
    /**
     * @description Test fetchMockSSORecord
     */
    @IsTest
    private static void unitTestfetchMockSSORecordNegative() {
        buildData();
        VCR_IAMSSOiVistaInstToUserDUZRepo repo = new VCR_IAMSSOiVistaInstToUserDUZRepo();
        System.runAs(VAVET_BASE) {
            Test.startTest();
            repo.fetchMockSSORecord(VATEST_IdFactory.get('IAM_SSOi_Vista_Instance_to_User_DUZ__c'));
            Test.stopTest();
        }
        Assert.isNotNull(repo, 'Expected repo to not be null');
    }

    /**
     * @description Test the unsafe insert
     */
    @IsTest
    private static void unitRepoUnsafeInsertPositive() {
        buildData();
        VCR_IAMSSOiVistaInstToUserDUZRepo repo;
        Integer numRecords = [SELECT COUNT() FROM IAM_SSOi_Vista_Instance_to_User_DUZ__c];
        System.runAs(VAVET_BASE) {
            IAM_SSOi_Vista_Instance_to_User_DUZ__c vistaInstanceToUserDUZ = new IAM_SSOi_Vista_Instance_to_User_DUZ__c(
                Name = 'Test SSO',
                DUZ__c = '37689',
                VistA_Instance__c = '984',
                User_Id__c = UserInfo.getUserId()
            );

            Test.startTest();
            repo = new VCR_IAMSSOiVistaInstToUserDUZRepo(true);
            repo.performUnsafeInsert(vistaInstanceToUserDUZ);
            Test.stopTest();
        }
        Assert.areEqual(
            numRecords + 1,
            [SELECT COUNT() FROM IAM_SSOi_Vista_Instance_to_User_DUZ__c],
            'Expected a new record to be inserted using SYSTEM_MODE'
        );
    }

    /**
     * @description Test the unsafe update
     */
    @IsTest
    private static void unitRepoUnsafeUpdatePositive() {
        buildData();
        VCR_IAMSSOiVistaInstToUserDUZRepo repo;
        IAM_SSOi_Vista_Instance_to_User_DUZ__c vistaInstanceToUserDUZ = [
            SELECT Id, Name, DUZ__c
            FROM IAM_SSOi_Vista_Instance_to_User_DUZ__c
            LIMIT 1
        ];
        System.runAs(VAVET_BASE) {
            vistaInstanceToUserDUZ.Name += ' New name';
            vistaInstanceToUserDUZ.DUZ__c += '111';

            Test.startTest();
            repo = new VCR_IAMSSOiVistaInstToUserDUZRepo(true);
            repo.performUnsafeUpdate(vistaInstanceToUserDUZ);
            Test.stopTest();
        }
        Assert.areEqual(
            vistaInstanceToUserDUZ.Name,
            [SELECT Name FROM IAM_SSOi_Vista_Instance_to_User_DUZ__c WHERE Id = :vistaInstanceToUserDUZ.Id].Name,
            'Expected Name of existing record to be updated but instead observed a difference.'
        );
        Assert.areEqual(
            vistaInstanceToUserDUZ.DUZ__c,
            [SELECT DUZ__c FROM IAM_SSOi_Vista_Instance_to_User_DUZ__c WHERE Id = :vistaInstanceToUserDUZ.Id].DUZ__c,
            'Expected DUZ__c of existing record to be updated but instead observed a difference'
        );
    }
}
