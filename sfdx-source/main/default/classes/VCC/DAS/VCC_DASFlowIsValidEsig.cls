/**
 * @author Booz Allen Hamilton
 * @description Class that holds the flow-exposed invocable method for IsValidEsig
 */
public with sharing class VCC_DASFlowIsValidEsig {
    /**
     * @description used to stub VCC_DASFLowIsValidEsig in flow test
     */
    @TestVisible
    private static VCC_DASFlowIsValidEsig flowIsValidEsigInstance {
        get {
            return flowisValidEsigInstance ?? new VCC_DASFlowIsValidEsig();
        }
        private set;
    }

    @InvocableMethod(
        label='Is Valid e-Signature'
        description='Validate a users e-Signature through DAS.'
        callout=true
        category='DAS'
    )
    /**
     * @description The flow-exposed invocable method for validating an e-signature on VistA
     * @param flowIsValidEsigRequestList flow request list
     * @return `List<IsValidEsigResult>` flow result list
     */
    public static List<Result> isValidEsig(List<Request> flowIsValidEsigRequestList) {
        return flowisValidEsigInstance.handleIsValidEsig(flowIsValidEsigRequestList);
    }

    /**
     * @description Used in flow invocable method to handle flow requests and perform callout.
     * @param flowIsValidEsigRequestList flow request list
     * @return `List<Result>` flow result list
     */
    public List<Result> handleIsValidEsig(List<Request> flowIsValidEsigRequestList) {
        try {
            Request flowIsValidEsigRequest = flowIsValidEsigRequestList[0];

            VCC_DASIsValidEsigRQ isValidEsigRq = new VCC_DASIsValidEsigRQ();
            isValidEsigRq.criteria = flowIsValidEsigRequest.criteria;
            isValidEsigRq.providerLoginSiteCode = flowIsValidEsigRequest.providerLoginSiteCode;
            isValidEsigRq.providerName = flowIsValidEsigRequest.providerName;
            isValidEsigRq.providerUserId = flowIsValidEsigRequest.providerUserId;

            VCC_DAS das = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId(flowIsValidEsigRequest?.providerLoginSiteCode),
                    Label.VCC_VAHC_AppName,
                    flowIsValidEsigRequest?.recordId
                )
            );

            return new List<Result>{ new Result(das.isValidEsig(isValidEsigRq)) };
        } catch (VCC_DASException dasException) {
            throw dasException;
        } catch (Exception e) {
            throw new FlowIsValidEsigException(e);
        }
    }

    /**
     * @description flow-exposed apex type for isValidEsig
     */
    public class Request {
        @InvocableVariable(label='Progress Note or Addendum record Id' required=true)
        public Id recordId;

        @InvocableVariable(label='Provider Site Code' required=true)
        public String providerLoginSiteCode;

        @InvocableVariable(label='Provider Name' required=true)
        public String providerName;

        @InvocableVariable(label='Token' required=true)
        public String providerUserId;

        @InvocableVariable(label='e-Signature' required=true)
        public String criteria;
    }

    /**
     * @description flow-exposed apex type for isValidEsig
     */
    public class Result {
        @InvocableVariable
        public Boolean isValid;

        /**
         * @description  Result class constructor
         * @param isValidEsigRs response object
         */
        public Result(VCC_DASIsValidEsigRS isValidEsigRs) {
            this.isValid = (isValidEsigRs.textTO.text == 'True');
        }
    }

    /**
     * @description Flow exception class
     */
    public class FlowIsValidEsigException extends VCC_DASException {
    }
}
