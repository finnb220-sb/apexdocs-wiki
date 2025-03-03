/**************************************************
 * Name    : DeactivateUsers2Test
 * Author  : Jaren Yach
 * Purpose : This is the Test class for Batch class named DeactivateUsers2
 * Created Date: 05/03/2022
 * Modification History:
 *****************************************************/
@IsTest
private class DeactivateUsers2Test {
    @IsTest
    static void testDeactivation() {
        Profile pr = [SELECT Id, Name FROM Profile WHERE Name = :'Standard User'];

        List<User> deactivateUsers = DTCTestUtil.createUsers(pr.Id, 5, false);
        Set<Id> userIds = new Set<Id>();
        for (User u : deactivateUsers) {
            u.LastName = 'Deactivate1234';
        }
        insert deactivateUsers;
        for (User u : deactivateUsers) {
            userIds.add(u.Id);
        }

        //Simulates users that haven't logged on for 90 days.  This will allow for DeactivateUser2 to be called
        Datetime deactivationDate = Datetime.now().dateGmt().addDays(-90);
        DTCTestUtil.setCreatedDate(deactivateUsers, deactivationDate);

        System.runAs(DTCTestUtil.createSysAdminUser()) {
            Test.startTest();
            DeactivateUsers2 uu = new DeactivateUsers2(userIds);
            Database.executeBatch(uu);
            Test.stopTest();

            //Assert there are 0 records still active that meet the criteria for being deactivated.
            List<User> users = [SELECT IsActive FROM User WHERE Id IN :userIds];
            for (User u : users) {
                System.assertEquals(false, u.IsActive);
            }
        }
    }
}
