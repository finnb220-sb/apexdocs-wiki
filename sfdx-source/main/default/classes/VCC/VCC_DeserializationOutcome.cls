public with sharing class VCC_DeserializationOutcome {
    public VCC_DeserializationResult result;

    public System.Type type { get; private set; }

    public Exception caughtException;

    public Object deserializedObject;

    public VCC_DeserializationOutcome(System.Type type) {
        this.type = type;
    }
}
