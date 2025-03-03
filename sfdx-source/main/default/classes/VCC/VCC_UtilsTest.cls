@isTest
public class VCC_UtilsTest {
    @isTest
    public static void testAddPermSetGroupToUser() {
        List<PermissionSetAssignment> userPerms;
        User testuser = VCC_TestDataFactory.insertUser('System Administrator');
        System.runAs(testuser) {
            test.startTest();
            User u = VCC_TestDataFactory.insertUser('Standard User');
            VCC_Util.addPermSetGroupToUser('VCC_Clinical_Supervisor', u);
            userPerms = [
                SELECT Id, PermissionSetId
                FROM PermissionsetAssignment
                WHERE AssigneeId = :u.Id
            ];
            test.stopTest();
        }

        Set<Id> userPermIds = new Set<Id>();
        Set<Id> groupPermIds = new Set<Id>();
        for (PermissionsetAssignment userPermSet : userPerms) {
            userPermIds.add(userPermSet.PermissionSetId);
        }

        for (PermissionSet groupPermSet : VCC_Util.getPermissionSetsFromGroup('VCC_Clinical_Supervisor')) {
            groupPermIds.add(groupPermSet.Id);
        }
        System.assert(userPermIds.containsAll(groupPermIds), 'Permission sets were not found to be assigned to test user');
    }

    @isTest
    public static void getDateFromNumberTest() {
        Date date1;
        Date date2;
        Date date3;
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            date1 = VCC_Util.getDateFromNumber('20200212111731');
            date2 = VCC_Util.getDateFromNumber('3130308.131706');
            date3 = VCC_Util.getDateFromNumber('0000000.111');
        }

        System.assert(date1 == null, 'Date 1 was expected to be null');
        System.assert(date2 != null, 'Date 2 was not converted into a date');
        System.assert(date3 != null, 'Date 2 was not converted into a date');
    }
}
