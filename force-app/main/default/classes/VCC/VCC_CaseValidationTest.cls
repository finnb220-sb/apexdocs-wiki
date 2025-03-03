@IsTest
public with sharing class VCC_CaseValidationTest {
    private static String username = 'casevrule';

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
    static void contactAccountMismatchTest() {
        Id personAcctRecType = Account.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account acct = new Account(LastName = 'test', RecordTypeId = personAcctRecType);
        insert acct;

        Contact con = [SELECT Id FROM Contact c, c.Account a WHERE a.Id = :acct.Id LIMIT 1];

        Contact con1 = new Contact(FirstName = 'test', LastName = 'name');
        insert con1;

        Test.startTest();
        System.runAs(getTestUser()) {
            Case a = new Case(ContactId = con.Id, AccountId = acct.Id);
            insert a;

            DmlException expectedException;
            try {
                Case b = new Case(ContactId = con1.Id, AccountId = acct.Id);
                insert b;
            } catch (DmlException e) {
                expectedException = e;
            }

            System.assert(expectedException != null, 'Expected an exception.');
            System.assert(expectedException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Expected validation exception.');
            System.assert(
                expectedException.getMessage()
                    .contains(
                        'The related account and related contact are different. ' + 'Please refresh your browser and try again, or create a DTC Helpdesk ticket for assistance.'
                    ),
                'Expected correct validation rule message.'
            );
        }
        Test.stopTest();
    }
}
