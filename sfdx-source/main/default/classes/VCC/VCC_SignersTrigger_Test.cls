/*
 * Test Class for VCC_Prevent_Deletion_Of_Signers Trigger
 *
 */
@isTest
@SuppressWarnings(
    'PMD.ApexDoc, PMD.ExcessivePublicCount, PMD.OneDeclarationPerLine, PMD.VariableNamingConventions, PMD.FieldDeclarationsShouldBeAtStart, PMD.TooManyFields, PMD.FieldNamingConventions'
)
public with sharing class VCC_SignersTrigger_Test {
    @isTest
    static void preventDeletionTest() {
        // Test User to Run Test
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'System Administrator' WITH SECURITY_ENFORCED];
        User u = new User(
            FirstName = 'Test1',
            LastName = 'User1',
            Email = 'testuser1@test1.com',
            Username = 'testuser@test.com.vahcteam439687',
            Alias = 'tuser1',
            CommunityNickname = 'testuser6554',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = prof.Id,
            LanguageLocaleKey = 'en_US',
            Division = 'VISN 8'
        );
        if (User.SObjectType.getDescribe(SOBJECTDescribeOptions.DEFERRED).isCreateable()) {
            insert u;
        }

        // Create Case
        Case c = new Case();
        if (Case.SObjectType.getDescribe(SOBJECTDescribeOptions.DEFERRED).isCreateable()) {
            insert c;
        }
        // Create Signed Progress Note
        VCC_Progress_Note__c p = new VCC_Progress_Note__c();
        p.VCC_Case__c = c.Id;
        p.VCC_Signed__c = true;
        if (VCC_Progress_Note__c.SObjectType.getDescribe(SOBJECTDescribeOptions.DEFERRED).isCreateable()) {
            insert p;
        }
        // Create Signed Addendum
        VCC_Addendum__c a = new VCC_Addendum__c();
        a.VCC_Related_Note__c = p.Id;
        a.VCC_Addendum__c = 'Test';
        a.VCC_Signed__c = true;
        if (VCC_Addendum__c.SObjectType.getDescribe(SOBJECTDescribeOptions.DEFERRED).isCreateable()) {
            insert a;
        }
        // List for Signer Records
        List<VCC_Signers__c> sLst = new List<VCC_Signers__c>();
        // Create Signer Attached to Progress Note
        VCC_Signers__c s1 = new VCC_Signers__c();
        s1.VCC_Progress_Note__c = p.Id;
        s1.Name = 'PN test';
        // Create Signer Attached to Addendum
        VCC_Signers__c s2 = new VCC_Signers__c();
        s2.VCC_Addendum__c = a.Id;
        s2.Name = 'Ad test';
        // Add Signers to List
        sLst.add(s1);
        sLst.add(s2);
        if (VCC_Signers__c.SObjectType.getDescribe(SOBJECTDescribeOptions.DEFERRED).isCreateable()) {
            insert sLst;
        }
        // Run Test as Test User
        System.runAs(u) {
            Test.startTest();
            VCC_SignersTriggerHandler.Prevent_Deletion(sLst);
            // Delete Signers List
            if (VCC_Signers__c.SObjectType.getDescribe(SOBJECTDescribeOptions.DEFERRED).isDeletable()) {
                Database.DeleteResult[] deleteSigners = Database.delete(sLst, false);
                for (Database.DeleteResult d : deleteSigners) {
                    // assert to check Delete failed
                    System.assert(d.isSuccess() == false, 'Deletion unsuccessful');
                    // assert that 1 error occurred for each Delete
                    System.assertEquals(d.getErrors().size() == 1, true, 'One Error for each Delete');
                }
            }
            Test.stopTest();
        }
    }
}
