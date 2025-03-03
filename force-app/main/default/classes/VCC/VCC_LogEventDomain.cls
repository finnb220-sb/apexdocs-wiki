public with sharing class VCC_LogEventDomain extends fflib_SObjectDomain {
    // Constructors
    public VCC_LogEventDomain(List<VCC_Log_Event__e> records) {
        super(records);
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> records) {
            return new VCC_LogEventDomain(records);
        }
    }

    // Trigger Handlers
    public override void onAfterInsert() {
        if (this.Records != null && !this.Records.isEmpty()) {
            VCC_LogService.insertLogs((List<VCC_Log_Event__e>) this.Records);
        }
    }
}
