@IsTest
public with sharing class VCC_LabTest {
    @testSetup
    static void makeData() {
        VCC_TestDataFactory.insertUser('System Administrator');
    }
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
    }

    @IsTest
    private static void ctor() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_Lab lab = new VCC_Lab();
            Test.stopTest();

            System.assert(lab != null, 'Expected the class to be initialized.');
        }
    }

    @IsTest
    private static void ctorOverrideNoComment() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_Lab lab = new VCC_Lab('dateTestVCC', 'interpretation', 'loinc', 'provider', 'result', 'sample', 'status', 'test');
            Test.stopTest();

            System.assert(lab != null, 'Expected the class to be initialized.');
            System.assertEquals('dateTestVCC', lab.DateTestVCC, 'Expected the values to match.');
            System.assertEquals('interpretation', lab.Interpretation, 'Expected the values to match.');
            System.assertEquals('loinc', lab.Loinc, 'Expected the values to match.');
            System.assertEquals('provider', lab.Provider, 'Expected the values to match.');
            System.assertEquals('result', lab.Result, 'Expected the values to match.');
            System.assertEquals('sample', lab.Sample, 'Expected the values to match.');
            System.assertEquals('status', lab.Status, 'Expected the values to match.');
            System.assertEquals('test', lab.Test, 'Expected the values to match.');
        }
    }

    @IsTest
    private static void ctorOverrideWithComment() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_Lab lab = new VCC_Lab('comment', 'dateTestVCC', 'interpretation', 'loinc', 'provider', 'result', 'sample', 'status', 'test');
            Test.stopTest();

            System.assert(lab != null, 'Expected the class to be initialized.');
            //System.assertEquals('comment', lab.Comment, 'Expected the values to match.');
            System.assertEquals('dateTestVCC', lab.DateTestVCC, 'Expected the values to match.');
            System.assertEquals('interpretation', lab.Interpretation, 'Expected the values to match.');
            System.assertEquals('loinc', lab.Loinc, 'Expected the values to match.');
            System.assertEquals('provider', lab.Provider, 'Expected the values to match.');
            System.assertEquals('result', lab.Result, 'Expected the values to match.');
            System.assertEquals('sample', lab.Sample, 'Expected the values to match.');
            System.assertEquals('status', lab.Status, 'Expected the values to match.');
            System.assertEquals('test', lab.Test, 'Expected the values to match.');
        }
    }
}
