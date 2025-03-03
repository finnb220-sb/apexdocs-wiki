public class VCC_HeartbeatTemplate {
    public VCC_HeartbeatTemplate() {
        this.name = '';
        this.id = '';
        this.endpoint = '';
        this.description = '';
        this.method = 'POST';
        this.params = new List<Parameter>();
        this.path = '';
        this.schedule = 'None';
        this.expectedResponse = '';

        this.getDataTypes();
        this.getMethods();
        this.getSchedules();
    }

    public VCC_HeartbeatTemplate(VCC_Heartbeat_Template__c record) {
        this.id = record?.Id;
        this.name = record?.Name;
        this.endpoint = record?.Endpoint__c;
        this.description = record?.Description__c;
        this.method = record?.Method__c;
        this.params = new List<Parameter>();
        this.path = '';
        this.schedule = record?.AutoRun_Schedule__c;
        this.expectedResponse = record?.Expected_Response__c;

        Integer ctr = 0;
        for (VCC_Heartbeat_Template_Parameter__c item : record?.Heartbeat_Template_Parameters__r) {
            this.params.add(new Parameter(item, ctr));
            ctr++;
        }

        this.getDataTypes();
        this.getMethods();
        this.getSchedules();
    }

    public void getDataTypes() {
        this.dataTypes = new List<Option>();
        Schema.DescribeFieldResult fieldResult = VCC_Heartbeat_Template_Parameter__c.Data_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            this.dataTypes.add(new Option(pickListVal.getLabel(), pickListVal.getValue()));
        }
    }

    public void getMethods() {
        this.methods = new List<Option>();
        Schema.DescribeFieldResult fieldResult = VCC_Heartbeat_Template__c.Method__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            this.methods.add(new Option(pickListVal.getLabel(), pickListVal.getValue()));
        }
    }

    public void getSchedules() {
        this.schedules = new List<Option>();
        Schema.DescribeFieldResult fieldResult = VCC_Heartbeat_Template__c.AutoRun_Schedule__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            this.schedules.add(new Option(pickListVal.getLabel(), pickListVal.getValue()));
        }
    }

    public List<Option> dataTypes { get; set; }
    public List<Option> methods { get; set; }
    public List<Option> schedules { get; set; }
    public string id { get; set; }
    public string name { get; set; }
    public string schedule { get; set; }
    public string path { get; set; }
    public string endpoint { get; set; }
    public string description { get; set; }
    public string method { get; set; }
    public List<Parameter> params { get; set; }
    public List<Option> headers { get; set; }
    public string passwordHeader { get; set; }
    public string expectedResponse { get; set; }

    public class Parameter {
        public string name { get; set; }
        public string dataType { get; set; }
        public string row { get; set; }
        public boolean isRequired { get; set; }
        public string format { get; set; }
        public string description { get; set; }
        public string value { get; set; }
        public string defaultValue { get; set; }
        public string type { get; set; }

        public Parameter() {
            this.name = '';
            this.dataType = 'String';
            this.row = 'PARAM-0';
            this.isRequired = false;
            this.format = '';
            this.description = '';
            this.value = '';
            this.type = 'body';
            this.defaultValue = '';
        }

        public Parameter(VCC_Heartbeat_Template_Parameter__c param, integer ctr) {
            this.name = param?.Name;
            this.dataType = param?.Data_Type__c;
            this.isRequired = param?.Is_Required__c;
            this.format = param?.Format__c;
            this.description = param?.Description__c;
            this.row = 'PARAM-' + ctr;
            this.value = param?.Default_Value__c;
        }
    }

    public class Option {
        public Option(string lbl, string val) {
            this.label = lbl;
            this.value = val;
        }

        public string label { get; set; }
        public string value { get; set; }
    }

    public class Param {
        public Param() {
            this.name = '';
            this.value = '';
            this.type = 'String';
            this.format = '';
        }

        public string name { get; set; }
        public string value { get; set; }
        public string type { get; set; }
        public string format { get; set; }
    }

    public class TestRunInfo {
        public TestRunInfo() {
            this.id = '';
            this.endpoint = '';
            this.method = 'POST';
            this.params = new List<Param>();
            this.schedule = 'None';
            this.expectedResponse = '';
        }

        public string id { get; set; }
        public string endpoint { get; set; }
        public string method { get; set; }
        public string schedule { get; set; }
        public string path { get; set; }
        public List<Param> params { get; set; }
        public string expectedResponse { get; set; }
    }

    public class TestResult {
        public TestResult() {
            this.success = false;
            this.message = '';
            this.status = 0;
        }

        public string message { get; set; }
        public boolean success { get; set; }
        public integer status { get; set; }
    }
}
