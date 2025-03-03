@isTest
public without sharing class VCC_OutputTextUtilityTest {
    @testSetup
    static void makeData() {
        VCC_TestDataFactory.insertUser('System Administrator');
    }

    /**
     * @description create a test user for running tests
     * @return A test user
     */
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
    }
    @isTest
    public static void testImport() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_OutputTextUtility.import();
            Test.stopTest();
            List<VCC_Output_Text__c> records = [SELECT Id FROM VCC_Output_Text__c];
            System.assertEquals(24, records.size(), 'Expected twenty four records');
        }
    }
    @IsTest
    public static void unitNegativeReturnNoRecords() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_OutputTextUtility.import();
            Test.stopTest();
            List<VCC_Output_Text__c> records = [SELECT Id, Name FROM VCC_Output_Text__c WHERE Name = 'Fakey Fakeson'];
            System.assertEquals(0, records.size(), 'Expected no records found with fake name');
        }
    }
}
