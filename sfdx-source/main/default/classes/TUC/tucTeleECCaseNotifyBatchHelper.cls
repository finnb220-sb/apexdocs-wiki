public with sharing class tucTeleECCaseNotifyBatchHelper {
    @TestVisible
    private static List<TED_TeleECCase__e> events = new List<TED_TeleECCase__e>();

    public static void checkCasesToNotify(List<Case> cases) {
        events.clear();
        Pattern p = Pattern.compile('(\\d+):(\\d+)');
        for (Case c : cases) {
            Matcher m = p.matcher(c.TUC_Wait_Time__c);
            if (!m.matches()) {
                continue;
            }
            Integer hours = Integer.valueOf(m.group(1));
            Integer minutes = Integer.valueOf(m.group(2));
            //Change the minutes comparison values based on the intervalInMinutes
            if (hours == 0 && ((minutes >= 5 && minutes <= 6) || (minutes >= 10 && minutes <= 11))) {
                TED_TeleECCase__e notifyEvent = new TED_TeleECCase__e();
                notifyEvent.caseNum__c = c.CaseNumber;
                if (minutes >= 10) {
                    notifyEvent.message__c = 'Case has been in High Acuity queue for more than 10 minutes';
                    notifyEvent.eventType__c = '10min';
                } else {
                    notifyEvent.message__c = 'Case has been in High Acuity queue for more than 5 minutes';
                    notifyEvent.eventType__c = '5min';
                }
                notifyEvent.VISN__c = String.valueOf(c.TUC_Assigned_VISN__c);
                events.add(notifyEvent);
            }
        }
        EventBus.publish(events);
    }
}
