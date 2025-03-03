/**
 * @description This class exists to get around a Copado limitation. This class wraps enums for code coverage.
 * It provides three enums specifically for `PharmacyLogType`, `HTTPStatusEnum`, and `WorkstreamSettingsTypeEnum`.
 **/
public with sharing class VCC_Enum {
    /**
     * @description The `VCC_PharmacyLogType` enum provides several options for representing different types of Pharmacy logs.
     **/
    public enum VCC_PharmacyLogType {
        ACTIVITY,
        ECME,
        CMOP,
        COPAY,
        ERX,
        LABEL,
        REFILL,
        PARTIAL,
        CMOPLOTLOG,
        TEST_EXECUTION
    }

    /**
     * @description The `VCC_HTTPStatusEnum` enum provides different HTTP status for successful requests, server errors, bad requests and unknown requests.
     **/
    public enum VCC_HTTPStatusEnum {
        SUCCESS,
        SERVER_ERROR,
        BAD_REQUEST,
        UNKNOWN
    }

    /**
     * @description The `VCC_WorkstreamSettingsTypeEnum` enum provides different Workstream settings such as MSA, Pharmacy, RN, and VCV.
     **/
    public enum VCC_WorkstreamSettingsTypeEnum {
        MSA,
        Pharmacy,
        RN,
        VCV
    }

    /**
     * @description The default constructor for code coverage.
     **/
    public VCC_Enum() {
        // default constructor for code coverage
    }
}
