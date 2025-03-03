/**
 * @description Test class for VCC_RecentViewHelper
 * @author Booz Allen Hamilton
 * @see VCC_VCC_RecentViewHelper
 */
@IsTest
public with sharing class VCC_RecentViewHelperTest {
    @TestSetup
    static void setup() {
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VCC_MSA_User');
    }

    static testMethod void willGetRecentView() {
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VCC_MSA_User');

        VCC_Recent_View__c recentView;

        Test.startTest();

        System.runAs(runAsUser) {
            List<Account> accts = VCC_TestDataFactory.generateVccPersonAccounts(1);
            recentView = VCC_RecentViewHelper.getRecentView(accts[0].Id);
        }

        Test.stopTest();

        Assert.isNotNull(recentView, 'The recent view record should have been created.');
    }

    static testMethod void willGetRecentViews() {
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VCC_MSA_User');

        List<VCC_Recent_View__c> recentViews = new List<VCC_Recent_View__c>();

        Test.startTest();

        System.runAs(runAsUser) {
            List<Account> accts = VCC_TestDataFactory.generateVccPersonAccounts(1);
            recentViews = VCC_RecentViewHelper.getRecentView(new List<string>{ accts[0].Id });
        }

        Test.stopTest();

        Assert.isFalse(recentViews.isEmpty(), 'The recent view records should have been created.');
    }

    static testMethod void willAcknowledgeRecentView() {
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VCC_MSA_User');

        VCC_Recent_View__c recentView;

        Test.startTest();

        System.runAs(runAsUser) {
            List<Account> accts = VCC_TestDataFactory.generateVccPersonAccounts(1);
            VCC_RecentViewHelper.acknowledge(accts[0].Id, VCC_RecentViewHelper.TYPE_VERIFY_PATIENT);
            recentView = VCC_RecentViewHelper.getRecentView(accts[0].Id);
        }

        Test.stopTest();

        Assert.isFalse(
            recentView.VCC_Is_Acknowledged__c,
            'The recent view record should not have been acknowledged for TYPE Verify Patient.'
        );
    }

    @IsTest
    static void willNotAcknowledgeRecentViewFacilityAccess() {
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VCC_MSA_User');

        VCC_Recent_View__c recentView;

        Test.startTest();

        System.runAs(runAsUser) {
            List<Account> accts = VCC_TestDataFactory.generateVccPersonAccounts(1);
            VCC_RecentViewHelper.acknowledge(accts[0].Id, VCC_RecentViewHelper.TYPE_FACILITY_ACCESS);
            recentView = VCC_RecentViewHelper.getRecentView(accts[0].Id);
        }

        Test.stopTest();

        Assert.isFalse(
            recentView.VCC_Is_Acknowledged__c,
            'The recent view record should not have been acknowledged for TYPE Facility Access.'
        );
    }
}
