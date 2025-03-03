public class VCC_QueryParam {
    public enum QueryParamCondition {
        CONTAINS,
        EQUALS
    }
    public enum QueryParamType {
        DATETYPE,
        STRINGTYPE
    }

    public Schema.SObjectField field { get; set; }
    public QueryParamCondition condition { get; set; }
    public QueryParamType type { get; set; }
    public String value { get; set; }

    public VCC_QueryParam(Schema.SObjectField field, QueryParamCondition condition, QueryParamType type, String value) {
        this.field = field;
        this.condition = condition;
        this.value = value;
        this.type = type;
    }
}
