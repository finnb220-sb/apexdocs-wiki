/**
 * VCC_UserSelectorTest
 * @description Test for VCC_UserSelector class.
 * @author Liberty
 * @date 12/15/2021
 *
 * updated 01/07/2024 by Lung Joe - corrections to satisfy PMD warnings
 */
@IsTest
public with sharing class VCC_UserSelectorTest {
    @IsTest
    private static void ctor() {
        Test.startTest();
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        System.runAs(testuser) {
            VCC_UserSelector userSelector = new VCC_UserSelector();
            System.assert(userSelector != null, 'Expected the class to be initialized.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void addSObjectFields() {
        Test.startTest();
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        System.runAs(testuser) {
            VCC_UserSelector userSelector = new VCC_UserSelector();
            Integer fieldCount = userSelector.getSObjectFieldList().size();
            userSelector.addSObjectFields(new List<SObjectField>{ Account.LastModifiedDate });
            Integer newFieldCount = userSelector.getSObjectFieldList().size();
            System.assertEquals(fieldCount + 1, newFieldCount, 'Field count should have been increased by 1 field.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void selectById() {
        Test.startTest();
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        System.runAs(testuser) {
            List<User> users = new VCC_UserSelector().selectById(new Set<Id>{ UserInfo.getUserId() });
            System.assert(users != null, 'user was unexpectedly null');
            System.assertEquals(1, users.size(), 'Expected only 1 item in the list.');
            System.assertEquals(UserInfo.getUserId(), users[0].Id, 'Expected Org Ids to match.');
        }
        Test.stopTest();
    }
}
