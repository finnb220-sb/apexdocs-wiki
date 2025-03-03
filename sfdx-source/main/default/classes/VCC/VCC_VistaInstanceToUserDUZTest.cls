@isTest
public with sharing class VCC_VistaInstanceToUserDUZTest {
    @TestSetup
    static void makeData() {
        IAM_SSOi_Vista_Instance_to_User_DUZ__c vtud = new IAM_SSOi_Vista_Instance_to_User_DUZ__c(Name = 'Test2', User_Id__c = UserInfo.getUserId(), VistA_Instance__c = '983');
        insert vtud;

        vtud = new IAM_SSOi_Vista_Instance_to_User_DUZ__c(Name = 'Test3', User_Id__c = UserInfo.getUserId(), VistA_Instance__c = '984');
        insert vtud;
    }
    @isTest
    public static void instantiationTest() {
        Test.startTest();
        VCC_VistaInstanceToUserDUZSelector vistaToDuzSelector = new VCC_VistaInstanceToUserDUZSelector();
        Test.stopTest();

        System.assert(vistaToDuzSelector != null, 'Did not instantiate as expected.');
    }

    @isTest
    public static void addSObjectFieldsTest() {
        VCC_VistaInstanceToUserDUZSelector vistaToDuzSelector = new VCC_VistaInstanceToUserDUZSelector();

        System.assert(!vistaToDuzSelector.getSObjectFieldList().contains(IAM_SSOi_Vista_Instance_to_User_DUZ__c.SystemModStamp), 'Selector already contains the field to test.');

        Test.startTest();
        vistaToDuzSelector.addSObjectFields(new List<SObjectField>{ IAM_SSOi_Vista_Instance_to_User_DUZ__c.SystemModStamp });
        Test.stopTest();

        System.assert(vistaToDuzSelector.getSObjectFieldList().contains(IAM_SSOi_Vista_Instance_to_User_DUZ__c.SystemModStamp), 'Selector did not add SObject field correctly.');
    }

    @isTest
    public static void selectByIdsTest() {
        VCC_VistaInstanceToUserDUZSelector vistaToDuzSelector = new VCC_VistaInstanceToUserDUZSelector();
        IAM_SSOi_Vista_Instance_to_User_DUZ__c vtud = new IAM_SSOi_Vista_Instance_to_User_DUZ__c(Name = 'Test');
        insert vtud;

        Test.startTest();
        List<IAM_SSOi_Vista_Instance_to_User_DUZ__c> vitudList = vistaToDuzSelector.selectByIds(new Set<Id>{ vtud.Id });
        Test.stopTest();

        System.assert(vitudList.size() == 1, 'Expected one record returned.');
    }

    @isTest
    public static void selectByUserIdAndVistaInstanceTest() {
        VCC_VistaInstanceToUserDUZSelector vistaToDuzSelector = new VCC_VistaInstanceToUserDUZSelector();

        Test.startTest();
        IAM_SSOi_Vista_Instance_to_User_DUZ__c vitud = vistaToDuzSelector.selectByUserIdAndVistaInstance(UserInfo.getUserId(), '983');
        Test.stopTest();

        System.assert(vitud != null, 'Expected one record returned.');
    }

    @isTest
    public static void selectByUserIdTest() {
        VCC_VistaInstanceToUserDUZSelector vistaToDuzSelector = new VCC_VistaInstanceToUserDUZSelector();

        Test.startTest();
        List<IAM_SSOi_Vista_Instance_to_User_DUZ__c> vitudList = vistaToDuzSelector.selectByUserId(UserInfo.getUserId());
        Test.stopTest();
        System.debug(vitudList);
        System.assert(vitudList.size() == 2, 'Expected two records returned.');
    }

    @isTest
    public static void selectByNameTest() {
        VCC_VistaInstanceToUserDUZSelector vistaToDuzSelector = new VCC_VistaInstanceToUserDUZSelector();
        Test.startTest();
        IAM_SSOi_Vista_Instance_to_User_DUZ__c vitud = vistaToDuzSelector.selectByName('Test3');
        Test.stopTest();

        System.assert(vitud != null, 'Expected a record.');
    }
}
