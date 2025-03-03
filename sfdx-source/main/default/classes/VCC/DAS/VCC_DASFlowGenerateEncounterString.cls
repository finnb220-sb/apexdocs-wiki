/**
 * @description Flow invocable as well as Request/Result types for said invocable. Generates an encounter string for note signing
 * @author Booz Allen Hamilton
 */

public with sharing class VCC_DASFlowGenerateEncounterString {
    @TestVisible
    private static final String NULL_OR_EMPTY_REQUEST_LIST_EXCEPTION_MESSAGE = 'generateEncounterStringRequestList is null or empty';

    @TestVisible
    private static final String SIZE_GREATER_THAN_ONE_REQUEST_LIST_EXCEPTION_MESSAGE = 'generateEncounterStringRequestList contains more than one request - this invocable is not bulkified';
    /**
     * @description  Used in to stub flow tests
     */
    @TestVisible
    private static VCC_DASFlowGenerateEncounterString flowGenerateEncounterStringInstance {
        get {
            if (flowGenerateEncounterStringInstance == null) {
                flowGenerateEncounterStringInstance = new VCC_DASFlowGenerateEncounterString();
            }
            return flowGenerateEncounterStringInstance;
        }
        set;
    }

    /**
     * @description Flow invocable to generate an encounter string
     * @param generateEncounterStringRequestList
     * @return `List<Result>`
     */
    @InvocableMethod(
        label='Generate Encounter String'
        description='For non-encounter notes, generate the encounter string.'
        category='DAS'
    )
    public static List<Result> generateEncounterString(List<Request> generateEncounterStringRequestList) {
        return flowGenerateEncounterStringInstance.handleFlowGenerateEncounterString(
            generateEncounterStringRequestList
        );
    }

    /**
     * @description Instance method for stubbing purposes
     * @param generateEncounterStringRequestList `List<Request>`
     * @return `Result`
     */
    public List<Result> handleFlowGenerateEncounterString(List<Request> generateEncounterStringRequestList) {
        try {
            flowGenerateEncounterStringInstance.validateInvocableRequestList(generateEncounterStringRequestList);
            Request generateEncounterStringRequest = generateEncounterStringRequestList[0];
            return new List<Result>{
                new Result(VCC_DAS.SERVICES.ENCOUNTER.generateEncounterString(generateEncounterStringRequest))
            };
        } catch (VCC_DASException dasException) {
            throw dasException;
        } catch (Exception e) {
            throw new GenerageEncounterStringException(e);
        }
    }

    @TestVisible
    private void validateInvocableRequestList(List<Request> generateEncounterStringRequestList) {
        if (generateEncounterStringRequestList == null || generateEncounterStringRequestList.isEmpty()) {
            throw new IllegalArgumentException(NULL_OR_EMPTY_REQUEST_LIST_EXCEPTION_MESSAGE);
        }
        if (generateEncounterStringRequestList.size() > 1) {
            throw new IllegalArgumentException(SIZE_GREATER_THAN_ONE_REQUEST_LIST_EXCEPTION_MESSAGE);
        }
    }

    /**
     * @description Request class for the invocable
     */
    public class Request {
        @InvocableVariable(label='noteAndEncounterParameters (VCC_Vdif_NoteAndEncounterParams)' required=true)
        public VCC_Vdif_NoteAndEncounterParams noteAndEncounterParameters;
    }

    /**
     * @description Result class of the invocable
     */
    public class Result {
        @InvocableVariable(label='Encounter string')
        public String encounterString;

        /**
         * @description Single arg constructor accepting a string
         * @param encounterString The encounter string
         */
        public Result(String encounterString) {
            this.encounterString = encounterString;
        }
    }

    /**
     * @description Exception thrown when an exception occurs in this invocable
     */
    public class GenerageEncounterStringException extends VCC_DASException {
    }
}
