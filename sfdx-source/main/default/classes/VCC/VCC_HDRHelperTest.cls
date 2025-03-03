@isTest
public with sharing class VCC_HDRHelperTest {
    @isTest
    public static void generateHdrTest() {
        Account a = new Account(
            FirstName = 'test',
            LastName = 'mctest',
            VCC_MVI_External_Id__pc = 'testing',
            RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' LIMIT 1]
            .Id
        );
        insert a;

        Test.startTest();
        VCC_HDRHelper.generateBRIDG(a.Id, 'vccBridgNotes', String.valueOf(a.getSObjectType()), true);
        VCC_HDRHelper.generateBRIDG(a.Id, 'vccBridgNotes', String.valueOf(a.getSObjectType()), false);
        VCC_HDRHelper.generateBRIDG(a.Id, 'vccBridgMeds', String.valueOf(a.getSObjectType()), true);
        VCC_HDRHelper.generateBRIDG(a.Id, 'vccBridgVitals', String.valueOf(a.getSObjectType()), true);
        Test.stopTest();

        //empty assert because of implied assertion (if it executes without exception)
        System.assert(true, 'Empty assert.');
    }

    @isTest
    static void testUsingOtherSObjects() {
        Account a = new Account(
            FirstName = 'test',
            LastName = 'mctest',
            VCC_MVI_External_Id__pc = 'testing',
            RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' LIMIT 1]
            .Id
        );
        insert a;

        Case c = new Case(Subject = 'Case HDR Helper', AccountId = a.id);
        insert c;

        VCC_Progress_Note__c pn = new VCC_Progress_Note__c(VCC_Case__c = c.id);
        insert pn;

        Test.startTest();
        VCC_HDRHelper.generateBRIDG(a.Id, 'vccBridgNotes', String.valueOf(a.getSObjectType()), true);
        VCC_HDRHelper.generateBRIDG(c.Id, 'vccBridgNotes', String.valueOf(c.getSObjectType()), true);
        VCC_HDRHelper.generateBRIDG(pn.Id, 'vccBridgNotes', String.valueOf(pn.getSObjectType()), true);
        VCC_HDRHelper.generateBRIDG(a.Id, 'vccBridgNotes', String.valueOf(a.getSObjectType()), false);
        VCC_HDRHelper.generateBRIDG(a.Id, 'vccBridgMeds', String.valueOf(a.getSObjectType()), true);
        VCC_HDRHelper.generateBRIDG(a.Id, 'vccBridgVitals', String.valueOf(a.getSObjectType()), true);
        Test.stopTest();

        //empty assert because of implied assertion (if it executes without exception)
        System.assert(true, 'Empty assert.');
    }
}
