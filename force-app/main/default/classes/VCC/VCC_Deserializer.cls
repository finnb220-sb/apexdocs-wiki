public with sharing class VCC_Deserializer {
    private final String INTERFACE_EXCEPTION_MSG = 'Deserialization target must implement the VCC_DeserializationTarget interface.';
    private final String PARAMETER_EXCEPTION_MSG = 'Deserializer is missing either jsonString, deserializationType, or both.';

    public System.Type deserializationType { get; set; }
    public String jsonString { get; set; }
    public VCC_DeserializationOutcome outcome { get; private set; }

    public VCC_DeserializationOutcome deserializeStrictInto(Object deserializationTarget) {
        this.interfaceCheck(deserializationTarget);
        VCC_DeserializationTarget target = (VCC_DeserializationTarget) deserializationTarget;
        VCC_DeserializationOutcome outcome = new VCC_DeserializationOutcome(this.deserializationType);
        try {
            outcome.deserializedObject = this.deserializeStrict();
            outcome.result = VCC_DeserializationResult.STRICT;
        } catch (Exception e) {
            outcome.caughtException = e;
            outcome.result = VCC_DeserializationResult.ERROR;
        }
        target.completeDeserialization(outcome);
        this.outcome = outcome;
        return outcome;
    }

    public VCC_DeserializationOutcome deserializeInto(Object deserializationTarget) {
        this.interfaceCheck(deserializationTarget);
        VCC_DeserializationTarget target = (VCC_DeserializationTarget) deserializationTarget;
        VCC_DeserializationOutcome outcome = new VCC_DeserializationOutcome(this.deserializationType);
        try {
            outcome.deserializedObject = this.deserialize(false);
            outcome.result = VCC_DeserializationResult.UNSTRICT;
        } catch (Exception e) {
            outcome.caughtException = e;
            outcome.result = VCC_DeserializationResult.ERROR;
        }
        target.completeDeserialization(outcome);
        this.outcome = outcome;
        return outcome;
    }

    public Object deserialize(Boolean useStrictDeserialization) {
        return (useStrictDeserialization) ? this.deserializeStrict() : this.deserializeUnstrict();
    }

    private Object deserializeStrict() {
        this.parameterCheck();
        Object deserializedObject = JSON.deserializeStrict(this.jsonString, this.deserializationType);
        return deserializedObject;
    }

    private Object deserializeUnstrict() {
        this.parameterCheck();
        Object deserializedObject = JSON.deserialize(this.jsonString, this.deserializationType);
        return deserializedObject;
    }

    private void parameterCheck() {
        if (this.jsonString == null || String.isBlank(this.jsonString) || this.deserializationType == null) {
            throw new MissingParameterException(PARAMETER_EXCEPTION_MSG);
        }
    }

    private void interfaceCheck(Object deserializationTarget) {
        if (!this.isImplementingInterface(deserializationTarget)) {
            throw new MissingInterfaceException(INTERFACE_EXCEPTION_MSG);
        }
    }

    private Boolean isImplementingInterface(Object deserializationTarget) {
        return deserializationTarget instanceof VCC_DeserializationTarget;
    }

    public VCC_Deserializer() {
        System.debug(LoggingLevel.INFO, 'Empty constructor.');
    }

    public VCC_Deserializer(System.Type deserializationType) {
        this.deserializationType = deserializationType;
    }

    public VCC_Deserializer(String jsonString, System.Type deserializationType) {
        this.deserializationType = deserializationType;
        this.jsonString = jsonString;
    }

    public class MissingInterfaceException extends Exception {
    }
    public class MissingParameterException extends Exception {
    }
    public class LockedException extends Exception {
    }
}
