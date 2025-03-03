/**************************************************
 * Name    : DeactivateUsers1Test
 * Author  : Jaren Yach
 * Purpose : This is the Test class for Batch class named DeactivateUsers1
 * Created Date: 04/27/2022
 * Modification History:
 *****************************************************/
@IsTest
public class DeactivateUsers1Test {
    @IsTest
    static void testWarningEmail() {
        System.runAs(DTCTestUtil.createSysAdminUser()) {
            User_Deactivation_Configuration__mdt USERCONFIG = User_Deactivation_Configuration__mdt.getInstance('Default');
            Profile pr = [SELECT Id, Name FROM Profile WHERE Name = :'Standard User'];
            List<User> warningUsers = DTCTestUtil.createUsers(pr.Id, 5, false);
            for (User u : warningUsers) {
                u.LastName = 'Warning1234';
            }
            insert warningUsers;

            //Simulates users that haven't logged on for 76 days
            Datetime warningEmailDate = Datetime.now().addDays(-76);
            DTCTestUtil.setCreatedDate(warningUsers, warningEmailDate);

            Test.startTest();
            DeactivateUsers1 uu = new DeactivateUsers1();
            Database.executeBatch(uu);
            Test.stopTest();
            //Assert there are 5 records still active since the criteria was not met.
            System.assertEquals(5, [SELECT COUNT() FROM User WHERE IsActive = TRUE AND LastName = 'Warning1234']);
            System.assertEquals(5, DeactivateUsers1.testEmailsSent.size());
            User createdUser = [SELECT Id, CreatedDate FROM User WHERE LastName = 'Warning1234' LIMIT 1];

            Integer dateDiff = (createdUser.CreatedDate.date()).daysBetween(System.today());
            Integer numberOfDaysUntilDeactivated = Integer.valueOf(USERCONFIG.Deactivation_Days__c) - dateDiff;
            Date deactivationDate = Date.today().addDays(numberOfDaysUntilDeactivated);
            for (Messaging.SingleEmailMessage message : DeactivateUsers1.testEmailsSent) {
                System.assertEquals(Label.WarningEmailSubject, message.getSubject());
                System.assert(message.htmlBody.contains('76 days'), 'Email does not contain 76 days');
                System.assert(message.htmlBody.contains(deactivationDate.format()), 'The deactivation date is not correct');
            }
        }
    }

    @IsTest
    static void testWarningEmailPlusThreeDays() {
        System.runAs(DTCTestUtil.createSysAdminUser()) {
            User_Deactivation_Configuration__mdt USERCONFIG = User_Deactivation_Configuration__mdt.getInstance('Default');
            Profile pr = [SELECT Id, Name FROM Profile WHERE Name = :'Standard User'];
            List<User> warningUsers = DTCTestUtil.createUsers(pr.Id, 5, false);
            for (User u : warningUsers) {
                u.LastName = 'Warning1234';
            }

            insert warningUsers;

            //Simulates users that haven't logged on for 79 days
            Datetime warningEmailDate = Datetime.now().addDays(-79);
            DTCTestUtil.setCreatedDate(warningUsers, warningEmailDate);

            Test.startTest();
            DeactivateUsers1 uu = new DeactivateUsers1();
            Database.executeBatch(uu);
            Test.stopTest();
            //Assert there are 5 records still active since the criteria was not met.
            System.assertEquals(5, [SELECT COUNT() FROM User WHERE IsActive = TRUE AND LastName = 'Warning1234']);
            System.assertEquals(5, DeactivateUsers1.testEmailsSent.size());
            User createdUser = [SELECT Id, CreatedDate FROM User WHERE LastName = 'Warning1234' LIMIT 1];

            Integer dateDiff = (createdUser.CreatedDate.date()).daysBetween(System.today());
            Integer numberOfDaysUntilDeactivated = Integer.valueOf(USERCONFIG.Deactivation_Days__c) - dateDiff;
            Date deactivationDate = Date.today().addDays(numberOfDaysUntilDeactivated);
            for (Messaging.SingleEmailMessage message : DeactivateUsers1.testEmailsSent) {
                System.assertEquals(Label.WarningEmailSubject, message.getSubject());
                System.assert(message.htmlBody.contains('79 days'), 'Email does not contain 79 days');
                System.assert(message.htmlBody.contains(deactivationDate.format()), 'The deactivation date is not correct');
            }
        }
    }

    @IsTest
    static void testWarningEmailPlusSixDays() {
        System.runAs(DTCTestUtil.createSysAdminUser()) {
            User_Deactivation_Configuration__mdt USERCONFIG = User_Deactivation_Configuration__mdt.getInstance('Default');

            Profile pr = [SELECT Id, Name FROM Profile WHERE Name = :'Standard User'];
            List<User> warningUsers = DTCTestUtil.createUsers(pr.Id, 5, false);
            for (User u : warningUsers) {
                u.LastName = 'Warning1234';
            }
            insert warningUsers;

            //Simulates users that haven't logged on for 82 days
            Datetime warningEmailDate = Datetime.now().addDays(-82);
            DTCTestUtil.setCreatedDate(warningUsers, warningEmailDate);

            Test.startTest();
            DeactivateUsers1 uu = new DeactivateUsers1();
            Database.executeBatch(uu);
            Test.stopTest();
            //Assert there are 5 records still active since the criteria was not met.
            System.assertEquals(5, [SELECT COUNT() FROM User WHERE IsActive = TRUE AND LastName = 'Warning1234']);
            System.assertEquals(5, DeactivateUsers1.testEmailsSent.size());
            User createdUser = [SELECT Id, CreatedDate FROM User WHERE LastName = 'Warning1234' LIMIT 1];

            Integer dateDiff = (createdUser.CreatedDate.date()).daysBetween(System.today());
            Integer numberOfDaysUntilDeactivated = Integer.valueOf(USERCONFIG.Deactivation_Days__c) - dateDiff;
            Date deactivationDate = Date.today().addDays(numberOfDaysUntilDeactivated);
            for (Messaging.SingleEmailMessage message : DeactivateUsers1.testEmailsSent) {
                System.assertEquals(Label.WarningEmailSubject, message.getSubject());
                System.assert(message.htmlBody.contains('82 days'), 'Email does not contain 82 days');
                System.assert(message.htmlBody.contains(deactivationDate.format()), 'The deactivation date is not correct');
            }
        }
    }

    @IsTest
    static void testWarningEmailPlusNineDays() {
        System.runAs(DTCTestUtil.createSysAdminUser()) {
            User_Deactivation_Configuration__mdt USERCONFIG = User_Deactivation_Configuration__mdt.getInstance('Default');

            Profile pr = [SELECT Id, Name FROM Profile WHERE Name = :'Standard User'];
            List<User> warningUsers = DTCTestUtil.createUsers(pr.Id, 5, false);
            for (User u : warningUsers) {
                u.LastName = 'Warning1234';
            }
            insert warningUsers;

            //Simulates users that haven't logged on for 85 days
            Datetime warningEmailDate = Datetime.now().addDays(-85);
            DTCTestUtil.setCreatedDate(warningUsers, warningEmailDate);

            Test.startTest();
            DeactivateUsers1 uu = new DeactivateUsers1();
            Database.executeBatch(uu);
            Test.stopTest();
            //Assert there are 5 records still active since the criteria was not met.
            System.assertEquals(5, [SELECT COUNT() FROM User WHERE IsActive = TRUE AND LastName = 'Warning1234']);
            System.assertEquals(5, DeactivateUsers1.testEmailsSent.size());
            User createdUser = [SELECT Id, CreatedDate FROM User WHERE LastName = 'Warning1234' LIMIT 1];

            Integer dateDiff = (createdUser.CreatedDate.date()).daysBetween(System.today());
            Integer numberOfDaysUntilDeactivated = Integer.valueOf(USERCONFIG.Deactivation_Days__c) - dateDiff;
            Date deactivationDate = Date.today().addDays(numberOfDaysUntilDeactivated);
            for (Messaging.SingleEmailMessage message : DeactivateUsers1.testEmailsSent) {
                System.assertEquals(Label.WarningEmailSubject, message.getSubject());
                System.assert(message.htmlBody.contains('85 days'), 'Email does not contain 85 days');
                System.assert(message.htmlBody.contains(deactivationDate.format()), 'The deactivation date is not correct');
            }
        }
    }

    @IsTest
    static void testWarningEmailPlusTwelveDays() {
        System.runAs(DTCTestUtil.createSysAdminUser()) {
            User_Deactivation_Configuration__mdt USERCONFIG = User_Deactivation_Configuration__mdt.getInstance('Default');
            Profile pr = [SELECT Id, Name FROM Profile WHERE Name = :'Standard User'];
            List<User> warningUsers = DTCTestUtil.createUsers(pr.Id, 5, false);
            for (User u : warningUsers) {
                u.LastName = 'Warning1234';
            }
            insert warningUsers;

            //Simulates users that haven't logged on for 88 days
            Datetime warningEmailDate = Datetime.now().addDays(-88);
            DTCTestUtil.setCreatedDate(warningUsers, warningEmailDate);

            Test.startTest();
            DeactivateUsers1 uu = new DeactivateUsers1();
            Database.executeBatch(uu);
            Test.stopTest();
            //Assert there are 5 records still active since the criteria was not met.
            System.assertEquals(5, [SELECT COUNT() FROM User WHERE IsActive = TRUE AND LastName = 'Warning1234']);
            System.assertEquals(5, DeactivateUsers1.testEmailsSent.size());
            User createdUser = [SELECT Id, CreatedDate FROM User WHERE LastName = 'Warning1234' LIMIT 1];

            Integer dateDiff = (createdUser.CreatedDate.date()).daysBetween(System.today());
            Integer numberOfDaysUntilDeactivated = Integer.valueOf(USERCONFIG.Deactivation_Days__c) - dateDiff;
            Date deactivationDate = Date.today().addDays(numberOfDaysUntilDeactivated);
            for (Messaging.SingleEmailMessage message : DeactivateUsers1.testEmailsSent) {
                System.assertEquals(Label.WarningEmailSubject, message.getSubject());
                System.assert(message.htmlBody.contains('88 days'), 'Email does not contain 88 days');
                System.assert(message.htmlBody.contains(deactivationDate.format()), 'The deactivation date is not correct');
            }
        }
    }

    @IsTest
    static void testDeactivationAndWarningEmail() {
        System.runAs(DTCTestUtil.createSysAdminUser()) {
            Profile pr = [SELECT Id, Name FROM Profile WHERE Name = :'Standard User'];

            List<User> warningUsers = DTCTestUtil.createUsers(pr.Id, 5, false);
            for (User u : warningUsers) {
                u.LastName = 'Warning1234';
            }
            insert warningUsers;
            //Simulates users that haven't logged on for 76 days
            Datetime warningEmailDate = Datetime.now().addDays(-76);
            DTCTestUtil.setCreatedDate(warningUsers, warningEmailDate);

            List<User> deactivateUsers = DTCTestUtil.createUsers(pr.Id, 5, false);
            for (User u : deactivateUsers) {
                u.LastName = 'Deactivate1234';
            }

            deactivateUsers[0].FederationIdentifier = null;
            deactivateUsers[1].FederationIdentifier = null;
            insert deactivateUsers;

            //Simulates users that haven't logged on for 90 days.  This will allow for DeactivateUser2 to be called
            Datetime deactivationDate = Datetime.now().addDays(-90);
            DTCTestUtil.setCreatedDate(deactivateUsers, deactivationDate);

            Test.startTest();
            DeactivateUsers1 uu = new DeactivateUsers1();
            Database.executeBatch(uu);
            Test.stopTest();

            System.assertEquals(10, DeactivateUsers1.testEmailsSent.size());
        }
    }

    @IsTest
    static void testDeactivationEmail() {
        System.runAs(DTCTestUtil.createSysAdminUser()) {
            Profile pr = [SELECT Id, Name FROM Profile WHERE Name = :'Standard User'];

            List<User> deactivateUsers = DTCTestUtil.createUsers(pr.Id, 5, false);
            for (User u : deactivateUsers) {
                u.LastName = 'Deactivate1234';
            }

            insert deactivateUsers;

            //Simulates users that haven't logged on for 90 days.  This will allow for DeactivateUser2 to be called
            Datetime deactivationDate = Datetime.now().addDays(-90);
            DTCTestUtil.setCreatedDate(deactivateUsers, deactivationDate);

            Test.startTest();
            DeactivateUsers1 uu = new DeactivateUsers1();
            Database.executeBatch(uu);
            Test.stopTest();

            System.assertEquals(5, DeactivateUsers1.testEmailsSent.size());

            for (Messaging.SingleEmailMessage message : DeactivateUsers1.testEmailsSent) {
                System.assert(message.htmlBody.contains(Label.DeactivationEmail));
            }
        }
    }

    @IsTest
    static void testNonDeactivation() {
        System.runAs(DTCTestUtil.createSysAdminUser()) {
            Profile pr = [SELECT Id, Name FROM Profile WHERE Name = :'Standard User'];
            List<User> users = DTCTestUtil.createUsers(pr.Id, 5, false);
            for (User u : users) {
                u.LastName = 'Deactivate1234';
            }
            insert users;
            Datetime deactivationDate = Datetime.now().addDays(-89);
            DTCTestUtil.setCreatedDate(users, deactivationDate);

            Test.startTest();
            DeactivateUsers1 uu = new DeactivateUsers1();
            Database.executeBatch(uu);
            Test.stopTest();

            //Assert no emails were sent since no users would have been deactivated or warned
            System.assertEquals(0, DeactivateUsers1.testEmailsSent.size());
        }
    }

    @IsTest
    static void testNonDeactivationWithServiceAccount() {
        System.runAs(DTCTestUtil.createSysAdminUser()) {
            Profile pr = [SELECT Id, Name FROM Profile WHERE Name = :'Standard User'];
            List<User> users = DTCTestUtil.createUsers(pr.Id, 5, false);
            for (User u : users) {
                u.LastName = 'Deactivate1234';
                u.User_Type__c = 'Service Account';
            }
            insert users;
            Datetime deactivationDate = Datetime.now().addDays(-95);
            DTCTestUtil.setCreatedDate(users, deactivationDate);

            Test.startTest();
            DeactivateUsers1 uu = new DeactivateUsers1();
            Database.executeBatch(uu);
            Test.stopTest();

            //Assert no emails were sent since no users would have been deactivated or warned
            System.assertEquals(0, DeactivateUsers1.testEmailsSent.size());
        }
    }

    @IsTest
    static void testScheduling() {
        System.runAs(DTCTestUtil.createSysAdminUser()) {
            Test.startTest();
            DeactivateUsers1 scheduledJob = new DeactivateUsers1();
            String chron = '0 0 23 * * ?';
            Id jobId = System.schedule('Test User Deactivation', chron, scheduledJob);
            Test.stopTest();
            System.assertNotEquals(null, jobId);
        }
    }

    @IsTest
    static void testUserWhiteList() {
        //This test requires at least one permission set in the org.
        PermissionSet ps = [
            SELECT Id, Label, Name
            FROM PermissionSet
            WHERE ProfileId = NULL
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        Profile pr = [SELECT Id, Name FROM Profile WHERE Name = :'Standard User'];
        System.runAs(DTCTestUtil.createSysAdminUser()) {
            // Create a new mock provider
            MockProvider mock = new MockProvider();
            // Create mock instances
            UserDeactivationWhitelistSelector mockWhiteListSelector = (UserDeactivationWhitelistSelector) mock.createMock(UserDeactivationWhitelistSelector.class);

            // Create a mock injector
            Injector mockInjector = (Injector) mock.createMock(Injector.class);

            // Setup the Injector to return the mock injector
            Injector.mockInjector = mockInjector;

            // Assign Mock Classes
            mock.setMock().mockReturnValue(mockInjector.instantiate('UserDeactivationWhitelistSelector'), mockWhiteListSelector);

            // Mock return values
            User_Deactivation_Whitelist__mdt mockSettingRecord = new User_Deactivation_Whitelist__mdt();
            mockSettingRecord.Label = ps.Label;
            mockSettingRecord.DeveloperName = ps.Name;
            mockSettingRecord.Api_Name__c = ps.Name;
            mock.setMock().mockReturnValue(mockWhiteListSelector.getAllRecords(), new List<User_Deactivation_Whitelist__mdt>{ mockSettingRecord });

            List<User> warningUsers = DTCTestUtil.createUsers(pr.Id, 1, false);
            for (User u : warningUsers) {
                u.LastName = 'Warning1234';
            }
            insert warningUsers;

            //Simulates users that haven't logged on for 76 days
            Datetime warningEmailDate = Datetime.now().addDays(-76);
            DTCTestUtil.setCreatedDate(warningUsers, warningEmailDate);

            List<User> deactivateUsers = DTCTestUtil.createUsers(pr.Id, 1, false);
            for (User u : deactivateUsers) {
                u.LastName = 'Deactivate1234';
            }

            insert deactivateUsers;

            //Simulates users that haven't logged on for 90 days.  This will allow for DeactivateUser2 to be called
            Datetime deactivationDate = Datetime.now().addDays(-90);
            DTCTestUtil.setCreatedDate(deactivateUsers, deactivationDate);

            //Add users to permission sets
            List<User> allUsers = new List<User>();
            allUsers.addAll(warningUsers);
            allUsers.addAll(deactivateUsers);
            DTCTestUtil.addPermSetsToUsers(allUsers, new List<String>{ ps.Name });

            Test.startTest();
            DeactivateUsers1 uu = new DeactivateUsers1();
            Database.executeBatch(uu);
            Test.stopTest();

            //Assert that no emails were sent
            System.assertEquals(0, DeactivateUsers1.testEmailsSent.size());
        }
    }
}
