@isTest
private class VCC_QuerySelectorTest {
    @testSetup
    static void makeData() {
        VCC_TestDataFactory.insertUser('System Administrator');
    }
    /**
     * @description create a test user for running tests
     * @return A test user
     **/
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
    }

    @isTest
    static void testAssignedPermissionSetNames() {
        System.runAs(getTestUser()) {
            Test.startTest();
            List<String> permissionSetNames = VCC_QuerySelector.getAssignedPermissionSetNames(getTestUser().Id);
            Test.stopTest();
            Assert.areNotEqual(null, permissionSetNames, 'Permission set names should not be null');
        }
    }

    @isTest
    static void testContactNationalId() {
        System.runAs(getTestUser()) {
            RecordType caseRecordType = VCC_TestDataFactory.getRecordType('Case', 'VCC_Pharmacy');
            Account account = VCC_TestDataFactory.generateVccPersonAccounts(1)[0];
            Case cse = VCC_TestDataFactory.createCase('VCC_MedsServiceTest', caseRecordType.Id, account.Id);
            VCC_Progress_Note__c progressNote = VCC_TestDataFactory.createProgressNote(cse.Id);
            Test.startTest();
            String nationalIdFromProgressNote = VCC_QuerySelector.getContactNationalID(progressNote.Id);
            String nationalIdFromAccount = VCC_QuerySelector.getContactNationalID(account.Id);
            String nationalIdFromCase = VCC_QuerySelector.getContactNationalID(cse.Id);
            Test.stopTest();
            Assert.areNotEqual(null, nationalIdFromProgressNote, 'National Id from progress note should not be null');
            Assert.areNotEqual(null, nationalIdFromAccount, 'National Id from account should not be null');
            Assert.areNotEqual(null, nationalIdFromCase, 'National Id from Case should not be null');
        }
    }
}
