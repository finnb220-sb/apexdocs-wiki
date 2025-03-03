/**
 * Author:Jaren Yach
 *  Created Date 05/04/2022
 *  Purpose: Unit test class for RevertInvalidEmailsBatch
 */
@IsTest
private class RevertInvalidEmailsBatchTest {
    @IsTest
    static void testRevertingInvalidWithUpdatingProfile() {
        System.runAs(DTCTestUtil.createSysAdminUser()) {
            Profile pr = [SELECT Id, Name FROM Profile WHERE Name = :'Standard User'];
            List<User> users = DTCTestUtil.createUsers(pr.Id, 5, false);
            Set<Id> userIds = new Set<Id>();
            //Assign .invalid to emails
            for (User u : users) {
                u.Email = u.Email + '.invalid';
                userIds.add(u.Id);
            }
            insert users;

            for (User u : users) {
                userIds.add(u.Id);
            }

            List<DTC_Sandbox_Refresh_User_Whitelist__mdt> mockWhiteListRecords = new List<DTC_Sandbox_Refresh_User_Whitelist__mdt>();
            for (User u : users) {
                mockWhiteListRecords.add(new DTC_Sandbox_Refresh_User_Whitelist__mdt(Label = u.LastName, DeveloperName = u.LastName, UserId__c = u.Id));
            }

            DTC_Sandbox_Refresh_Setting__mdt mockSettingRecord = new DTC_Sandbox_Refresh_Setting__mdt();
            mockSettingRecord.Label = 'Default';
            mockSettingRecord.DeveloperName = 'Default';
            mockSettingRecord.Update_To_System_Admin_Profile__c = true;

            // Create a new mock provider
            MockProvider mock = new MockProvider();

            // Create mock instances
            DTCSandboxRefreshUserWhiteListSelector mockWhiteListSelector = (DTCSandboxRefreshUserWhiteListSelector) mock.createMock(DTCSandboxRefreshUserWhiteListSelector.class);
            DTCSandboxRefreshSettingSelector mockSettingSelector = (DTCSandboxRefreshSettingSelector) mock.createMock(DTCSandboxRefreshSettingSelector.class);

            // Create a mock injector
            Injector mockInjector = (Injector) mock.createMock(Injector.class);

            // Setup the Injector to return the mock injector
            Injector.mockInjector = mockInjector;

            // Assign Mock Classes
            mock.setMock().mockReturnValue(mockInjector.instantiate('DTCSandboxRefreshUserWhiteListSelector'), mockWhiteListSelector);
            mock.setMock().mockReturnValue(mockInjector.instantiate('DTCSandboxRefreshSettingSelector'), mockSettingSelector);

            // Mock return values
            mock.setMock().mockReturnValue(mockWhiteListSelector.getAllRecords(), mockWhiteListRecords);
            mock.setMock().mockReturnValue(mockSettingSelector.getSettingForOrg(), mockSettingRecord);

            List<User> recs = [SELECT Email FROM User WHERE Id IN :userIds];
            for (User u : recs) {
                System.assert(u.Email.endsWith('.invalid'), 'Email does not end with .invalid');
            }

            Test.startTest();
            RevertInvalidEmailsBatch.run();
            Test.stopTest();

            recs = [SELECT Email, ProfileId FROM User WHERE Id IN :userIds];
            Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

            for (User u : recs) {
                System.assert(u.Email.endsWith('.com'), 'Email ends with .invalid');
                System.assertEquals(sysAdminProfile.Id, u.ProfileId);
            }
        }
    }

    @IsTest
    static void testRevertingInvalidWithNotUpdatingProfile() {
        System.runAs(DTCTestUtil.createSysAdminUser()) {
            Profile pr = [SELECT Id, Name FROM Profile WHERE Name = :'Standard User'];
            List<User> users = DTCTestUtil.createUsers(pr.Id, 5, false);
            Set<Id> userIds = new Set<Id>();
            //Assign .invalid to emails
            for (User u : users) {
                u.Email = u.Email + '.invalid';
                userIds.add(u.Id);
            }
            insert users;

            for (User u : users) {
                userIds.add(u.Id);
            }

            List<DTC_Sandbox_Refresh_User_Whitelist__mdt> mockWhiteListRecords = new List<DTC_Sandbox_Refresh_User_Whitelist__mdt>();
            for (User u : users) {
                mockWhiteListRecords.add(new DTC_Sandbox_Refresh_User_Whitelist__mdt(Label = u.LastName, DeveloperName = u.LastName, UserId__c = u.Id));
            }

            DTC_Sandbox_Refresh_Setting__mdt mockSettingRecord = new DTC_Sandbox_Refresh_Setting__mdt();
            mockSettingRecord.Label = 'Default';
            mockSettingRecord.DeveloperName = 'Default';
            mockSettingRecord.Update_To_System_Admin_Profile__c = false;

            // Create a new mock provider
            MockProvider mock = new MockProvider();

            // Create mock instances
            DTCSandboxRefreshUserWhiteListSelector mockWhiteListSelector = (DTCSandboxRefreshUserWhiteListSelector) mock.createMock(DTCSandboxRefreshUserWhiteListSelector.class);
            DTCSandboxRefreshSettingSelector mockSettingSelector = (DTCSandboxRefreshSettingSelector) mock.createMock(DTCSandboxRefreshSettingSelector.class);

            // Create a mock injector
            Injector mockInjector = (Injector) mock.createMock(Injector.class);

            // Setup the Injector to return the mock injector
            Injector.mockInjector = mockInjector;

            // Assign Mock Classes
            mock.setMock().mockReturnValue(mockInjector.instantiate('DTCSandboxRefreshUserWhiteListSelector'), mockWhiteListSelector);
            mock.setMock().mockReturnValue(mockInjector.instantiate('DTCSandboxRefreshSettingSelector'), mockSettingSelector);

            // Mock return values
            mock.setMock().mockReturnValue(mockWhiteListSelector.getAllRecords(), mockWhiteListRecords);
            mock.setMock().mockReturnValue(mockSettingSelector.getSettingForOrg(), mockSettingRecord);

            List<User> recs = [SELECT Email FROM User WHERE Id IN :userIds];
            for (User u : recs) {
                System.assert(u.Email.endsWith('.invalid'), 'Email does not end with .invalid');
            }

            Test.startTest();
            RevertInvalidEmailsBatch.run();
            Test.stopTest();

            recs = [SELECT Email, ProfileId FROM User WHERE Id IN :userIds];

            for (User u : recs) {
                System.assert(u.Email.endsWith('.com'), 'Email ends with .invalid');
                System.assertEquals(pr.Id, u.ProfileId);
            }
        }
    }
}
