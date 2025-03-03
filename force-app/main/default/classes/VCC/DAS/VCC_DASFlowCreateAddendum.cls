/**
 * @description Flow Invocable for DAS/createAddendum
 * @author      Booz Allen
 * @see         VCC_DASCreateAddendumRQ
 * @see         VCC_DASCreateAddendumRS
 * @see         VCC_DASException
 */
public with sharing class VCC_DASFlowCreateAddendum {
    /**
     * @description Invocable method that calls DAS API createAddendum
     * @param flowCreateAddenumRequests createAddendum requests
     * @return `List<Result>` list of VCC_DASFlowCreateAddendum.Result
     */
    @InvocableMethod(label='Create Addendum' description='DAS Integration' callout=true category='DAS')
    public static List<Result> createAddendum(List<Request> flowCreateAddenumRequests) {
        try {
            Request flowCreateAddendumRequest = flowCreateAddenumRequests[0];
            VCC_DASCreateAddendumRQ createAddendumRq = new VCC_DASCreateAddendumRQ();

            createAddendumRq.itemId = flowCreateAddendumRequest.itemId;
            createAddendumRq.type = flowCreateAddendumRequest.type;
            createAddendumRq.providerLoginSiteCode = flowCreateAddendumRequest.providerLoginSiteCode;
            createAddendumRq.providerUserId = flowCreateAddendumRequest.providerUserId;
            createAddendumRq.providerName = flowCreateAddendumRequest.providerName;
            createAddendumRq.criteria = VCC_DAS.SERVICES.PARSER.parse((SObject) flowCreateAddendumRequest.addendum);
            VCC_DAS das = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId(flowCreateAddendumRequest?.providerLoginSiteCode),
                    Label.VCC_VAHC_AppName,
                    flowCreateAddendumRequest?.recordId
                )
            );
            return new List<Result>{ new Result(das.createAddendum(createAddendumRq)) };
        } catch (VCC_DASException dasException) {
            throw dasException;
        } catch (Exception e) {
            throw new FlowCreateAddendumException(e);
        }
    }

    /**
     * @description Shape of the input parameter to the invocable method in this class
     */
    public class Request {
        @InvocableVariable(label='Progress Note or Addendum record Id' required=true)
        public Id recordId;

        @InvocableVariable(label='VistA Id of Note to Addend' required=true)
        public String itemId;

        @InvocableVariable(label='Addendum IEN' required=true)
        public String type;

        @InvocableVariable(label='Addendum' required=true)
        public VCC_Addendum__c addendum;

        @InvocableVariable(label='Provider Site Code' required=true)
        public String providerLoginSiteCode;

        @InvocableVariable(label='Provider Name' required=true)
        public String providerName;

        @InvocableVariable(label='Token' required=true)
        public String providerUserId;
    }

    /**
     * @description Shape of the output of the invocable method in this class
     */
    public class Result {
        @InvocableVariable
        public String text;

        @InvocableVariable
        public String faultMessage;

        /**
         * @description  Result constructor
         * @param createAddendumRs `VCC_DASCreateAddendumRS`
         */
        public Result(VCC_DASCreateAddendumRS createAddendumRs) {
            this.text = createAddendumRs?.textTO?.text;
            this.faultMessage = createAddendumRs?.textTO?.fault?.message;
        }
    }

    /**
     * @description Exception class for invocable method
     */
    public class FlowCreateAddendumException extends VCC_DASException {
    }
}
