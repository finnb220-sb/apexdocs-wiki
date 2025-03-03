/**
 * @description This class creates a unique ID for DAS & VDIF HTTP transactions. The purpose of this transaction ID is to assist with troubleshooting errors.
 * @author      Booz Allen
 */
public with sharing class VCC_TransactionId {
    // endpointString;YYMMdd;HH:mm:ss:SSS;18characterRecordId
    @TestVisible
    private static final String TRANSACTION_ID_TEMPLATE = System.Label.VCC_DAS_TransactionId_TRANSACTION_ID_TEMPLATE;

    //exception message when null's are provided to the constructor
    @TestVisible
    private static final String NULL_INPUT_EXCEPTION_MESSAGE = System.Label.VCC_DAS_TransactionId_NULL_INPUT_EXCEPTION_MESSAGE;

    //exception message when the Id provided to the constructor is neither VCC_Progress_Note__c nor VCC_Addendum__c
    @TestVisible
    private static final String BAD_ID_TYPE_EXCEPTION_MESSAGE = System.Label.VCC_DAS_TransactionId_BAD_ID_TYPE_EXCEPTION_MESSAGE;

    //exception message when the VCC_DAS.Endpoint enum value provided is not added to the DAS_ENDPOINT_TO_STRING_MAP
    @TestVisible
    private static final String UNMAPPED_ENDPOINT_EXCEPTION_MESSAGE = System.Label.VCC_DAS_TransactionId_UNMAPPED_ENDPOINT_EXCEPTION_MESSAGE; //update this label so it can be used for vdif too?

    //format for use in Datetime.format()
    @TestVisible
    private static final String YEAR_MONTH_DAY_FORMAT = 'YYMMdd';

    //format for use in Datetime.format()
    @TestVisible
    private static final String HOUR_MINUTE_SECOND_MILLISECONDS_FORMAT = 'HH:mm:ss:SSS';

    // The prefix of the transaction id string. Assigned in the constructor - the value comes from the DAS_ENDPOINT_TO_STRING_MAP.
    @TestVisible
    private String prefix;

    // The record id, placed at the end of the transaction id string.
    @TestVisible
    private Id recordId;

    // Self-explanitory, the current date and time. Formatted into a string and placed in the middle of the transaction id string.
    @TestVisible
    private Datetime currentDateAndTime = Datetime.now();

    // map from VCC_DAS.Endpoint enum value to the string
    @TestVisible
    private static final Map<VCC_DAS.Endpoint, String> DAS_ENDPOINT_TO_STRING_MAP = new Map<VCC_DAS.Endpoint, String>{
        VCC_DAS.Endpoint.IS_VALID_ESIG => 'IsValidESig',
        VCC_DAS.Endpoint.SELECT_PATIENT => 'Select',
        VCC_DAS.Endpoint.WRITE_NOTE => 'WriteNote',
        VCC_DAS.Endpoint.SIGN_NOTE => 'SignNote',
        VCC_DAS.Endpoint.GET_ADDITIONAL_SIGNERS => 'GetAdditionalSigners',
        VCC_DAS.Endpoint.CREATE_ADDENDUM => 'CreateAddendum',
        VCC_DAS.Endpoint.SAVE_NOTE_AND_ENCOUNTER => 'SaveNoteAndEncounter',
        VCC_DAS.Endpoint.WRITE_NOTE_AND_SIGN => 'WriteNoteAndSign',
        VCC_DAS.Endpoint.CREATE_ADDENDUM_AND_SIGN => 'CreateAddendumAndSign'
    };

    /**
     * @description TestVisible empty constructor for testing purposes
     */
    @TestVisible
    private VCC_TransactionId() {
        return;
    }

    /**
     * @description Transaction ID constructor for DAS
     * @param dasEndpoint `VCC_DAS.Endpoint` das endpoint enum
     * @param recordId `Id` Progress Note or Addendum record ID associated with the transaction
     */
    public VCC_TransactionId(VCC_DAS.Endpoint dasEndpoint, Id recordId) {
        this.validateDASEndpoint(dasEndpoint);
        this.recordId = recordId;
        this.prefix = DAS_ENDPOINT_TO_STRING_MAP.get(dasEndpoint);
        this.validateConstructorInput(this.prefix, this.recordId);
    }

    /**
     * @description Transaction ID constructor for VDIF
     * @param serviceName `String` vdif endpoint enum
     * @param recordId `Id` Progress Note or Addendum record ID associated with the transaction
     */
    public VCC_TransactionId(String serviceName, Id recordId) {
        this.prefix = serviceNameToEndpointName(serviceName); //do i need to include this.serviceNameToEndpointName
        this.recordId = recordId;
        this.validateConstructorInput(this.prefix, this.recordId);
    }

    /**
     * @description Returns string without the vccVdif prefix
     * @param serviceName `String` that stems from VCC_BaseClient.serviceName
     * @return            `String` vdif endpoint name
     */
    public String serviceNameToEndpointName(String serviceName) {
        if (serviceName == null) {
            return null;
        }
        String endpointName = serviceName.replace('vccVdif', '');
        return endpointName;
    }

    /**
     * @description Validates the constructor input
     * @param endpoint `String` string value of VCC_DAS.Endpoint or VdifEndpoint
     * @param recordId `Id`  Progress Note or Addendum record ID associated with the transaction
     * @exception `InstantiationException` when parameter values are invalid
     */
    @TestVisible
    private void validateConstructorInput(String endpoint, Id recordId) {
        try {
            validateParams(endpoint, recordId);
            validateId(recordId);
        } catch (VCC_DASException dasException) {
            throw dasException;
        } catch (Exception anyOtherException) {
            throw new InstantiationException(anyOtherException);
        }
    }

    private void validateParams(String endpoint, Id recordId) {
        if (endpoint == null || recordId == null) {
            throw new InstantiationException(NULL_INPUT_EXCEPTION_MESSAGE);
        }
    }

    private void validateId(Id recordId) {
        if (
            recordId.getSobjectType() != VCC_Progress_Note__c.SObjectType &&
            recordId.getSobjectType() != VCC_Addendum__c.SObjectType &&
            recordId.getSobjectType() != VCC_Test_Run__c.SObjectType
        ) {
            throw new InstantiationException(BAD_ID_TYPE_EXCEPTION_MESSAGE);
        }
    }

    private void validateDASEndpoint(VCC_DAS.Endpoint dasEndpoint) {
        try {
            if (!DAS_ENDPOINT_TO_STRING_MAP.containsKey(dasEndpoint)) {
                throw new InstantiationException(UNMAPPED_ENDPOINT_EXCEPTION_MESSAGE);
            }
        } catch (VCC_DASException dasException) {
            throw dasException;
        } catch (Exception anyOtherException) {
            throw new InstantiationException(anyOtherException);
        }
    }

    /**
     * @description Override of toString(), formats the pieces of the transaction ID string together
     * @return transaction Id `String` in the format of 'endpointString;YYMMDD;HH:MM:SS:ms;recordId'
     */
    public override String toString() {
        return String.format(
            TRANSACTION_ID_TEMPLATE,
            new List<String>{
                this.prefix,
                this.currentDateAndTime.format(YEAR_MONTH_DAY_FORMAT),
                this.currentDateAndTime.format(HOUR_MINUTE_SECOND_MILLISECONDS_FORMAT),
                this.recordId
            }
        );
    }

    /**
     * @description Exception class for validateConstructorInput method
     */
    public class InstantiationException extends VCC_DASException {
    }
}
