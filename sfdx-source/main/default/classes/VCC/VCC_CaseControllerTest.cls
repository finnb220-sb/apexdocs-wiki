@IsTest
private class VCC_CaseControllerTest {
    private static String username = 'caseCont';

    @TestSetup
    public static void makeData() {
        User testUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VCC_Registered_Nurse', testUser);
        testUser.Username = username + testUser.Username;
        update testUser;
    }

    public static User getTestUser() {
        return [SELECT Id FROM User WHERE Username LIKE :username + '%' LIMIT 1];
    }

    @IsTest
    static void getCaseInfoTestCaseId() {
        Test.startTest();
        System.runAs(getTestUser()) {
            Case c = new Case(
                RecordTypeId = Case.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Clinical_Triage').getRecordTypeId(),
                Subject = 'Test Subject'
            );
            insert c;

            VCC_CaseController.CaseInfo caseInfo = VCC_CaseController.getCaseInfo(c.Id);

            System.assert(caseInfo.id == c.Id, 'Failed caseInfo assert, incorrect info received.');
            System.assert(caseInfo.subject == c.Subject, 'Failed caseInfo assert, incorrect info received.');
            System.assert(caseInfo.recordTypeDeveloperName == 'VCC_Clinical_Triage', 'Failed caseInfo assert, incorrect info received.');
            System.assert(
                caseInfo.recordTypeId == Case.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Clinical_Triage').getRecordTypeId(),
                'Failed caseInfo assert, incorrect info received.'
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void getCaseInfoTestProgressNoteId() {
        Test.startTest();
        System.runAs(getTestUser()) {
            Case c = new Case(
                RecordTypeId = Case.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Clinical_Triage').getRecordTypeId(),
                Subject = 'Test Subject'
            );
            insert c;

            VCC_Progress_Note__c pn = new VCC_Progress_Note__c(VCC_Case__c = c.Id);
            insert pn;

            VCC_CaseController.CaseInfo caseInfo = VCC_CaseController.getCaseInfo(pn.Id);

            System.assert(caseInfo.id == c.Id, 'Failed caseInfo assert, incorrect info received.');
            System.assert(caseInfo.subject == c.Subject, 'Failed caseInfo assert, incorrect info received.');
            System.assert(caseInfo.recordTypeDeveloperName == 'VCC_Clinical_Triage', 'Failed caseInfo assert, incorrect info received.');
            System.assert(
                caseInfo.recordTypeId == Case.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Clinical_Triage').getRecordTypeId(),
                'Failed caseInfo assert, incorrect info received.'
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void getCaseInfoWrapperTest() {
        Case c = new Case(
            RecordTypeId = Case.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Clinical_Triage').getRecordTypeId(),
            Subject = 'Test Subject'
        );
        insert c;

        Test.startTest();
        String caseInfoResult = VCC_CaseController.getCaseInfoWrapper(c.Id);
        System.assert(caseInfoResult.length() > 0, 'String length should be longer than zero');
        Test.stopTest();
    }
}
