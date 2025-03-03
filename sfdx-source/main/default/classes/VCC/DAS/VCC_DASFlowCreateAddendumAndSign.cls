/**
 * @description Flow Invocable for DAS/createAddendumAndSign
 * @author Booz Allen Hamilton
 * @since 05/09/2024 - CCCM-31251
 */
public with sharing class VCC_DASFlowCreateAddendumAndSign {
    @TestVisible
    private static VCC_DASFlowCreateAddendumAndSign flowCreateAddendumAndSignInstance {
        get {
            if (flowCreateAddendumAndSignInstance == null) {
                flowCreateAddendumAndSignInstance = new VCC_DASFlowCreateAddendumAndSign();
            }
            return flowCreateAddendumAndSignInstance;
        }
        set;
    }

    /**
     * @description Flow-accessible method that calls DAS API createAddendumAndSign
     * @param flowRequests
     * @return `List<VCC_DASFlowConsolidatedEndpointResult>`
     */
    @InvocableMethod(label='Create Addendum And Sign' description='DAS Integration' callout=true category='DAS')
    public static List<VCC_DASFlowConsolidatedEndpointResult> createAddendumAndSign(List<Request> flowRequests) {
        return flowCreateAddendumAndSignInstance.handleFlowCreateAddendumAndSign(flowRequests);
    }

    /**
     * @description Instance method that actually handles the flow request(s) and performs callout(s). Its
     * an instance method for stubbing purposes mostly.
     * @param flowRequests
     * @return `List<VCC_DASFlowConsolidatedEndpointResult>`
     */
    public List<VCC_DASFlowConsolidatedEndpointResult> handleFlowCreateAddendumAndSign(List<Request> flowRequests) {
        List<VCC_DASFlowConsolidatedEndpointResult> flowResults = new List<VCC_DASFlowConsolidatedEndpointResult>();
        for (Request flowRequest : flowRequests ?? new List<VCC_DASFlowCreateAddendumAndSign.Request>()) {
            flowRequest = flowRequest ?? new Request();
            try {
                VCC_DAS das = new VCC_DAS(
                    new VCC_DAS.State(
                        new VCC_SiteId(flowRequest?.siteCode),
                        Label.VCC_VAHC_AppName,
                        flowRequest?.recordId
                    )
                );
                flowResults.add(
                    new VCC_DASFlowConsolidatedEndpointResult(
                        das.createAddendumAndSign(flowRequest.toCreateAddendumAndSignRq())
                    )
                );
            } catch (VCC_DASConsolidatedEndpointException consolidatedEndpointException) {
                flowResults.add(new VCC_DASFlowConsolidatedEndpointResult(consolidatedEndpointException));
            } catch (Exception otherThrownException) {
                flowResults.add(new VCC_DASFlowConsolidatedEndpointResult(otherThrownException));
            }
        }
        return flowResults;
    }

    /**
     * @description A flow-accessible datatype for use in invoking the method createAddendumAndSign
     */
    public class Request {
        @InvocableVariable(label='Addendum Record Id' required=true)
        public Id recordId;

        @InvocableVariable(label='Site Code' required=true)
        public String siteCode;

        @InvocableVariable(label='Provider Name' required=true)
        public String providerName;

        @InvocableVariable(label='Token' required=true)
        public String providerUserId;

        @InvocableVariable(label='e-Signature' required=true)
        public String esig;

        @InvocableVariable(label='Progress Note VistA Internal Entry Number (IEN)' required=true)
        public String itemId;

        @InvocableVariable(label='Note Title IEN' required=true)
        public String type;

        /**
         * @description Coverts the flow request into a `VCC_DASCreateAddendumAndSignRQ`
         * @return `VCC_DASCreateAddendumAndSignRQ`
         */
        public VCC_DASCreateAddendumAndSignRQ toCreateAddendumAndSignRq() {
            VCC_DASCreateAddendumAndSignRQ createAddendumAndSignRq = new VCC_DASCreateAddendumAndSignRQ();
            createAddendumAndSignRq.providerLoginSiteCode = this?.siteCode;
            createAddendumAndSignRq.providerUserId = this?.providerUserId;
            createAddendumAndSignRq.providerName = this?.providerName;
            createAddendumAndSignRq.esig = this?.esig;
            createAddendumAndSignRq.supplementalParameters = VCC_SignersService.instance.getSignerDuzListForCallout(
                this?.recordId
            );
            createAddendumAndSignRq.itemId = this?.itemId;
            createAddendumAndSignRq.type = this?.type;
            createAddendumAndSignRq.criteria = VCC_DAS.SERVICES.PARSER.parse(new VCC_Addendum__c(Id = this?.recordId));
            return createAddendumAndSignRq;
        }
    }
}
