/**
 * @description General util methods
 *
 * @author Liberty
 * @since 01/07/2024
 * @group Helpers/Utilities
 */
public inherited sharing class VCC_Util {
    /**
     * @description converts string date number to a date type
     *
     * @param dateNumber
     * @return  `Date`
     */
    public static Date getDateFromNumber(String dateNumber) {
        try {
            Integer.valueOf(dateNumber.subStringBefore('.'));
        } catch (Exception e) {
            Logger.error('error occured getting Integer value of ' + dateNumber, e);
            Logger.saveLog();
            return null;
        }
        String dateNumberStr = dateNumber + '';
        Integer year = Integer.valueOf(dateNumberStr.substring(0, 3)) + 1700;
        //Integer month = Integer.valueOf(dateNumberStr.substring(3,5)) - 1;
        Integer month = Integer.valueOf(dateNumberStr.substring(3, 5));
        Integer day = Integer.valueOf(dateNumberStr.substring(5, 7));
        //Integer hours = Integer.valueOf(dateNumberStr.substring(8,10));
        //Integer minutes = Integer.valueOf(dateNumberStr.substring(10,12));
        if (month == 0 && day == 0) {
            month = 1;
            day = 1;
        }
        return Date.newinstance(year, month, day);
    }

    /**
     * @description Returns the list of permission sets that are in a Permission Set Group
     *
     * @param permSetGroupAPIName
     * @return  `List<PermissionSet>`
     */
    public static List<PermissionSet> getPermissionSetsFromGroup(String permSetGroupAPIName) {
        PermissionSetGroup psg;
        List<PermissionSetGroupComponent> permSetGroupComponents;
        Set<Id> permSetIds;

        try {
            psg = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName = :permSetGroupAPIName WITH SECURITY_ENFORCED];
        } catch (Exception e) {
            Logger.error('error occured fetching permission set group named ' + permSetGroupAPIName, e);
            Logger.saveLog();
            return null;
        }

        if (psg != null) {
            try {
                permSetGroupComponents = [SELECT Id, PermissionSetId FROM PermissionSetGroupComponent WHERE PermissionSetGroupId = :psg.Id WITH SECURITY_ENFORCED];
            } catch (Exception e) {
                Logger.error('error occured getting permission set group components of ' + permSetGroupAPIName, e);
                Logger.saveLog();
            }

            if (permSetGroupComponents != null && permSetGroupComponents.size() > 0) {
                permSetIds = new Set<Id>();
                for (PermissionSetGroupComponent psa : permSetGroupComponents) {
                    permSetIds.add(psa.PermissionSetId);
                }
            }
        }

        return [SELECT Id FROM PermissionSet WHERE Id IN :permSetIds WITH SECURITY_ENFORCED];
    }

    /**
     * @description Adds a user to a permission set group
     *
     * @param permSetGroupAPIName
     * @param u
     */
    public static void addPermSetGroupToUser(String permSetGroupAPIName, User u) {
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        for (PermissionSet ps : getPermissionSetsFromGroup(permSetGroupAPIName)) {
            psaList.add(new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = u.Id));
        }
        if (PermissionSetAssignment.SObjectType.getDescribe(SObjectDescribeOptions.DEFAULT).isCreateable()) {
            insert psaList;
        }
    }
}
