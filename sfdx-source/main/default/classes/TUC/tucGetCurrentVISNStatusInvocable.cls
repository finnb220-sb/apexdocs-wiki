public with sharing class tucGetCurrentVISNStatusInvocable {
    @InvocableMethod(label='Get TeleEc Status for VISN')
    public static List<String> getCurrentStatusInvocable(List<String> providedVISNList) {
        List<String> stringList = new List<String>();
        if (providedVISNList.size() > 0) {
            stringList.add(tucCommonUtils.getCurrentStatusString(providedVISNList[0]));
        }
        return stringList;
    }
}
