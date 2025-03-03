public abstract with sharing class VCC_Result {
    public Kind kind { get; private set; }

    @AuraEnabled
    public String kindString {
        get {
            if (this.kind == null) {
                return null;
            }
            return this.kind.name();
        }
    }

    public enum Kind {
        ERR,
        OK
    }

    public class Ok extends VCC_Result {
        @AuraEnabled
        public Object value { get; private set; }

        public Ok(Object value) {
            this.value = value;
            this.kind = VCC_Result.Kind.OK;
        }
    }

    public class Err extends VCC_Result {
        @AuraEnabled
        public Object value { get; private set; }

        public Err(Object value) {
            this.value = value;
            this.kind = VCC_Result.Kind.ERR;
        }
    }

    public static Err err(Object value) {
        return new Err(value);
    }

    public static Ok ok(Object value) {
        return new Ok(value);
    }

    public static Boolean isErr(VCC_Result result) {
        return (result?.kind == Kind.ERR) && (result instanceof Err);
    }

    public static Boolean isOk(VCC_Result result) {
        return (result?.kind == Kind.OK) && (result instanceof Ok);
    }

    public static Ok asOk(VCC_Result result) {
        return (Ok) result;
    }

    public static Err asErr(VCC_Result result) {
        return (Err) result;
    }
}
