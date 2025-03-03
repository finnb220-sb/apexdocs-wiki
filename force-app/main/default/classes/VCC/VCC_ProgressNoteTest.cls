@IsTest
/**
 * @description Test class for VCC_Progress_Note__c
 * @author Patrick Skamarak
 * @since 02/13/2024 - added code coverage for VCC_ProgressNoteTrigger apex trigger
 */
private class VCC_ProgressNoteTest {
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
    @IsTest
    static void validateApex() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_ProgressNote note = new VCC_ProgressNote();
            Test.stopTest();
            System.assert(note != null, 'ProgressNote was not created as expected');
        }
    }

    @IsTest
    static void progressNoteTriggerCodeCoverageTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            try {
                Account accountForProgressNoteCreation = new Account(
                    LastName = 'Test',
                    RecordTypeId = Account.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId()
                );
                insert accountForProgressNoteCreation;
                Case caseForProgressNoteCreation = new Case(AccountId = accountForProgressNoteCreation.Id);
                insert caseForProgressNoteCreation;
                VCC_Progress_Note__c progressNoteForDelete = new VCC_Progress_Note__c(VCC_Case__c = caseForProgressNoteCreation.Id);
                insert progressNoteForDelete;
                delete progressNoteForDelete;
            } catch (Exception thrownException) {
                Assert.fail('Unexpected exception thrown ' + thrownException);
            }
        }
        Test.stopTest();
    }
}
