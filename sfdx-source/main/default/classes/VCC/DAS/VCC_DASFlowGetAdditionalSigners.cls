/**
 * @author Booz Allen Hamilton
 * @description flow-exposed DAS api call getAdditionalSigners
 */
@SuppressWarnings('PMD.ClassNamingConventions')
public with sharing class VCC_DASFlowGetAdditionalSigners {
    @TestVisible
    private static final String NULL_OR_EMPTY_REQUEST_LIST_EXCEPTION_MESSAGE = 'flowGetAdditionalSignersRequestList is null or empty';

    @TestVisible
    private static final String NOT_BULKIFIED_EXCEPTION_MESSAGE = 'flowGetAdditionalSignersRequestList contains more than one request - this invocable is not bulkified';

    @TestVisible
    private static VCC_DASFlowGetAdditionalSigners flowGetAdditionalSignersInstance {
        get {
            if (flowGetAdditionalSignersInstance == null) {
                flowGetAdditionalSignersInstance = new VCC_DASFlowGetAdditionalSigners();
            }
            return flowGetAdditionalSignersInstance;
        }
        set;
    }

    @InvocableMethod(label='Get Additional Signers' description='DAS Integration' callout=true category='DAS')
    /**
     * @description flow-exposed DAS api call getAdditionalSigners
     * @param flowGetAdditionalSignersRequestList `List<GetAdditionalSignersRequest>`
     * @return `List<GetAdditionalSignersResult>`
     */
    public static List<Result> getAdditionalSigners(List<Request> flowGetAdditionalSignersRequestList) {
        return flowGetAdditionalSignersInstance.handleFlowGetAdditionalSigners(flowGetAdditionalSignersRequestList);
    }

    /**
     * @description Instance method for stubbing purposes
     * @param flowGetAdditionalSignersRequestList `List<Request>`
     * @return `Result`
     */
    public List<Result> handleFlowGetAdditionalSigners(List<Request> flowGetAdditionalSignersRequestList) {
        try {
            flowGetAdditionalSignersInstance.validateInvocableRequestList(flowGetAdditionalSignersRequestList);
            Request flowGetAdditionalSignersRequest = flowGetAdditionalSignersRequestList[0];
            VCC_DASGetAdditionalSignersRQ getAdditionalSignersRq = flowGetAdditionalSignersRequest.toDasGetAdditionalSignersRq();
            List<Result> flowInvocableResultList = new List<Result>();
            if (
                getAdditionalSignersRq.supplementalParameters == null ||
                getAdditionalSignersRq.supplementalParameters.isEmpty()
            ) {
                flowInvocableResultList.add(new Result());
                return flowInvocableResultList;
            }
            VCC_DAS das = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId(flowGetAdditionalSignersRequest?.providerLoginSiteCode),
                    Label.VCC_VAHC_AppName,
                    flowGetAdditionalSignersRequest?.recordId
                )
            );
            flowInvocableResultList.add(new Result(das.getAdditionalSigners(getAdditionalSignersRq)));
            return flowInvocableResultList;
        } catch (VCC_DASException dasException) {
            throw dasException;
        } catch (Exception e) {
            throw new FlowGetAdditionalSignersException(e);
        }
    }

    /**
     * @description validates the flow invocable input
     * @param flowGetAdditionalSignersRequestList
     */
    @TestVisible
    private void validateInvocableRequestList(List<Request> flowGetAdditionalSignersRequestList) {
        if (flowGetAdditionalSignersRequestList == null || flowGetAdditionalSignersRequestList.isEmpty()) {
            throw new IllegalArgumentException(NULL_OR_EMPTY_REQUEST_LIST_EXCEPTION_MESSAGE);
        }
        if (flowGetAdditionalSignersRequestList.size() > 1) {
            throw new IllegalArgumentException(NOT_BULKIFIED_EXCEPTION_MESSAGE);
        }
    }

    /**
     * @description Apex Type for use in flows for the getAdditionalSigners api call
     */
    @SuppressWarnings('PMD.ClassNamingConventions') // suppress inner class naming false positive
    public class Request {
        @InvocableVariable(label='Progress Note or Addendum record Id' required=true)
        public Id recordId;

        @InvocableVariable(label='Provider Name' required=true)
        public String providerName;

        @InvocableVariable(label='Token' required=true)
        public String providerUserId;

        @InvocableVariable(label='Provider Site Code' required=true)
        public String providerLoginSiteCode;

        @InvocableVariable(label='Note VistA Id' required=true)
        public String itemId;

        @InvocableVariable(label='DEPRECATED, DO NOT USE Signer IENs')
        public List<String> supplementalParameters;

        /**
         * @description uses this Request class to create a VCC_DASGetAdditionalSignersRQ
         * @return `VCC_DASGetAdditionalSignersRQ`
         */
        public VCC_DASGetAdditionalSignersRQ toDasGetAdditionalSignersRq() {
            VCC_DASGetAdditionalSignersRQ getAdditionalSignersRq = new VCC_DASGetAdditionalSignersRQ();
            getAdditionalSignersRq.itemId = this.itemId;
            getAdditionalSignersRq.providerUserId = this.providerUserId;
            getAdditionalSignersRq.providerLoginSiteCode = this.providerLoginSiteCode;
            getAdditionalSignersRq.supplementalParameters = VCC_SignersService.instance.getSignerDuzListForCallout(
                this.recordId
            );
            return getAdditionalSignersRq;
        }
    }

    /**
     * @description Result Apex Type given to the flow from the api call
     */
    public class Result {
        @InvocableVariable(label='List of Signer DUZ that were added as a signer')
        public List<String> addedSigners = new List<String>();

        /**
         * @description Empty constructor for when no signers are added
         */
        public Result() {
            return;
        }

        /**
         * @description Constructor accepting the VCC_DASGetAdditionalSignersRS class
         * @param getAdditionalSignersRs
         */
        public Result(VCC_DASGetAdditionalSignersRS getAdditionalSignersRs) {
            for (VCC_DASRSCommon.TaggedText taggedText : getAdditionalSignersRs?.taggedTextArray?.results?.taggedText) {
                if (String.isNotBlank(taggedText?.fault?.message)) {
                    continue;
                }
                this.addedSigners.add(taggedText?.text);
            }
        }
    }

    /**
     * @description Exception thrown when an error occurs in this flow invocable
     */
    public class FlowGetAdditionalSignersException extends VCC_DASException {
    }
}
