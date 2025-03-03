public with sharing class VCC_PatientMedsService {
    /**
     * @description Calls out to DIVA and gets activity logs for an individual Rx/Med
     * @param rxId unique identifier for medication
     * @param logType type of activity log to fetch from DIP
     * @return  `String` Activity Log Response
     */

    public static String getActivityLog(String logType, String rxId) {
        // TODO: Integrate with DIVA when DIP is done 11/15/2022
        try {
            return new VCC_StaticResourceSelector().selectByName(logType)[0].Body.toString();
        } catch (Exception ex) {
            throw new VCC_InternalException('Unable to fetch mock activity log data');
        }
    }
}
