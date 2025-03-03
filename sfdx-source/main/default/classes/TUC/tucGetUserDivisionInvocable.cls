public with sharing class tucGetUserDivisionInvocable {
    @InvocableMethod(label='Get User Division Assigned VISN')
    public static List<String> getUserDivisionVISNInvocable() {
        List<String> stringList = new List<String>();
        String userDivisionVISN = tucCommonUtils.getUserDivisionVISN();
        if (userDivisionVISN != null && userDivisionVISN != '') {
            stringList.add(userDivisionVISN);
        }

        return stringList;
    }
}
