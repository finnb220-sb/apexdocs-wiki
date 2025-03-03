public class VCC_LogService {
    public static String CORRELATION_ID = getGUID();
    private static final List<VCC_Log_Event__e> LOG_EVENTS = new List<VCC_Log_Event__e>();

    public static void log(String name, VCC_LogService.VCC_LogType logType, Object obj) {
        log(name, logType, JSON.serializePretty(obj));
    }

    public static void log(String name, VCC_LogService.VCC_LogType logType, List<Object> objs) {
        log(name, logType, JSON.serializePretty(objs));
    }

    public static void log(String name, VCC_LogService.VCC_LogType logType, List<Object> objs, String correlationId) {
        if (String.isNotBlank(correlationId)) {
            CORRELATION_ID = correlationId;
        }
        for (Object obj : objs) {
            log(name, logType, JSON.serializePretty(obj));
        }
    }

    public static void log(String name, VCC_LogService.VCC_LogType logType, Exception ex) {
        log(name, logType, ex.getMessage() + '\n' + ex.getStackTraceString());
    }

    public static void log(String name, VCC_LogService.VCC_LogType logType, Exception ex, String correlationId) {
        if (String.isNotBlank(correlationId)) {
            CORRELATION_ID = correlationId;
        }
        log(name, logType, ex.getMessage() + '\n' + ex.getStackTraceString());
    }

    public static void log(String name, VCC_LogService.VCC_LogType logType, String message, String correlationId) {
        if (String.isNotBlank(correlationId)) {
            CORRELATION_ID = correlationId;
        }
        LOG_EVENTS.add(
            new VCC_Log_Event__e(
                Log_Name__c = name,
                Timestamp__c = Datetime.now(),
                Correlation_Id__c = CORRELATION_ID,
                Log_Type__c = logType.name(),
                Username__c = UserInfo.getUserName(),
                Message__c = message
            )
        );
        System.debug(JSON.serializePretty(LOG_EVENTS[LOG_EVENTS.size() - 1]));
    }

    public static void log(String name, VCC_LogService.VCC_LogType logType, String message) {
        if (String.isBlank(name) || String.isBlank(message)) {
            return;
        }
        LOG_EVENTS.add(
            new VCC_Log_Event__e(
                Log_Name__c = name,
                Timestamp__c = Datetime.now(),
                Correlation_Id__c = CORRELATION_ID,
                Log_Type__c = logType.name(),
                Username__c = UserInfo.getUserName(),
                Message__c = message
            )
        );
        System.debug(JSON.serializePretty(LOG_EVENTS[LOG_EVENTS.size() - 1]));
    }

    public static void publish() {
        try {
            EventBus.publish(LOG_EVENTS);
            LOG_EVENTS.clear();
        } catch (Exception e) {
            System.debug(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    public static void insertLogs(List<VCC_Log_Event__e> logEvents) {
        fflib_ISObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<Schema.SObjectType>{ VCC_Log__c.SObjectType });
        List<VCC_Log__c> logs = new List<VCC_Log__c>();
        for (VCC_Log_Event__e logEvent : logEvents) {
            logs.add(
                new VCC_Log__c(
                    Name = logEvent.Log_Name__c,
                    Timestamp__c = logEvent.Timestamp__c,
                    Correlation_Id__c = logEvent.Correlation_Id__c,
                    Log_Type__c = logEvent.Log_Type__c,
                    Username__c = logEvent.Username__c,
                    Message__c = logEvent.Message__c
                )
            );
        }
        VCC_LogService.insertLogs(logs, uow);
        uow.commitWork();
    }

    public static void insertLogs(List<VCC_Log__c> logs, fflib_ISObjectUnitOfWork uow) {
        uow.registerNew(logs);
    }

    public static void deleteLogs(List<VCC_Log__c> logs) {
        fflib_ISObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<Schema.SObjectType>{ VCC_Log__c.SObjectType });
        VCC_LogService.deleteLogs(logs, uow);
        uow.commitWork();
    }

    public static void deleteLogs(List<VCC_Log__c> logs, fflib_ISObjectUnitOfWork uow) {
        uow.registerDeleted(logs);
    }

    private static String getGUID() {
        Blob b = Crypto.generateAesKey(128);
        String h = EncodingUtil.convertToHex(b);
        return h.substring(0, 8) + '-' + h.substring(8, 12) + '-' + h.substring(12, 16) + '-' + h.substring(16, 20) + '-' + h.substring(20);
    }

    public enum VCC_LogType {
        ERROR,
        INFO
    }
}
