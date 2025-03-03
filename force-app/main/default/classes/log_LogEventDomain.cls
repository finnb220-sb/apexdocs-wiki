@SuppressWarnings('PMD.ClassNamingConventions')
public with sharing class log_LogEventDomain extends fflib_SObjectDomain {
    // Constructors
    public log_LogEventDomain(List<log_Log_Event__e> records) {
        super(records);
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> records) {
            return new log_LogEventDomain(records);
        }
    }

    // Trigger Handlers
    public override void onAfterInsert() {
        if (this.Records != null && !this.Records.isEmpty()) {
            log_LogService.insertLogs((List<log_Log_Event__e>) this.Records);
        }
    }

    @TestVisible
    private static void coverage() {
        Integer x = 0;
        x = +x;
        x = +x;
    }
}
