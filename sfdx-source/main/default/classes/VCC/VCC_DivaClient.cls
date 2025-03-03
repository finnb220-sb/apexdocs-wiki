/**
 * @description
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class VCC_DivaClient {
    @TestVisible
    private static final String NAMED_CREDENTIAL = (Test.isRunningTest()) ? 'https://divaclient.mock' : VCC_EndpointUtility.getEndpoint('DIVA', 'vccRxRefill');

    @TestVisible
    private static Boolean bypassCallout = false;

    public refillMedicationsRQ rqBody;

    /**
     * @description
     */
    public class VCC_DivaClientException extends Exception {
    }
    /**
     * @description
     */
    public class VCC_DivaBadRequestException extends Exception {
    }

    /**
     * @description
     */
    public class VCC_DivaRemoteInternalException extends Exception {
    }

    /**
     * @description
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public VCC_DivaClient() {
    }

    // TODO: make this more general
    private ResponseJSON refillMedication(RefillRequest refillRequest) {
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint(NAMED_CREDENTIAL);
        httpRequest.setHeader('Accept', 'application/json');
        httpRequest.setHeader('Content-Type', 'application/json; charset=UTF-8');

        httpRequest.setHeader('clientId', '{!$Credential.Username}');
        httpRequest.setHeader('clientSecret', '{!$Credential.Password}');
        httpRequest.setMethod('POST');

        httpRequest.setBody(JSON.serialize(refillRequest));
        // System.debug('refillRequest::: ' + JSON.serializePretty(refillRequest));
        httpRequest.setTimeout(120000);

        HttpResponse httpResponse = new Http().send(httpRequest);

        ResponseJSON responseJSON = (ResponseJSON) JSON.deserialize(httpResponse.getbody(), ResponseJSON.class);

        System.debug('### ' + responseJSON);

        responseJSON.prescriptionId = refillRequest.prescriptionId;

        return responseJSON;
    }

    /**
     * @param refillMedicationsRQ
     * @description
     * @return RefillMedicationsRS
     */
    public RefillMedicationsRS refillMedications(RefillMedicationsRQ refillMedicationsRQ) {
        if (refillMedicationsRQ.refillRequests.size() > 99) {
            throw new VCC_DivaClientException('Refill request size exceeds limit.');
        }

        RefillMedicationsRS resultsList = new RefillMedicationsRS();
        List<ResponseJSON> results = new List<ResponseJSON>();

        for (RefillRequest refillRequest : refillMedicationsRQ.refillRequests) {
            ResponseJSON result = new ResponseJSON();
            result = refillMedication(refillRequest);
            results.add(result);
        }

        resultsList.responseJSON = results;
        return resultsList;
    }

    /**
     * @description
     */
    public class RefillMedicationsRS {
        /**
         * @description
         */
        public List<ResponseJSON> responseJSON { get; set; }

        /**
         * @description
         */
        public Boolean allSuccessful {
            public get {
                for (ResponseJSON response : responseJSON) {
                    Boolean isParkedMed = response.success == null && response.status.length() > 0;

                    if (isParkedMed && response.status == 'OK') {
                        response.success = true;
                    }

                    if (isParkedMed && response.status != 'OK') {
                        response.success = false;
                    }

                    if (response.success != true) {
                        return false;
                    }
                }

                return true;
            }
            private set;
        }

        /**
         * @description
         */
        public RefillMedicationsRS() {
            this.responseJSON = new List<ResponseJSON>();
        }
    }

    /**
     * @description
     */
    public class ResponseJSON {
        /**
         * @description
         */
        public Boolean success { get; set; }
        /**
         * @description
         */
        public String message { get; set; }
        /**
         * @description
         */
        public String prescriptionId { get; set; }

        public String status;
        public List<Result> results;

        /**
         * @description
         */
        public ResponseJSON() {
            this.success = false;
            if (this.status != null && this.status.equals('OK')) {
                this.success = true;
            }
        }
    }

    public class Result {
        public String vista;
        public Metadata metadata;
        public Response response;
        public String error;
    }

    public class Metadata {
        public String timezone;
    }

    public class Response {
        public String header;
        public List<String> bodies;
    }

    /**
     * @description
     */
    public class RefillMedicationsRQ {
        /**
         * @description
         */
        public List<RefillRequest> refillRequests { get; set; }

        /**
         * @description
         */
        public RefillMedicationsRQ() {
            this.refillRequests = new List<RefillRequest>();
        }

        /**
         * @description
         * @param refillRequests
         */
        public RefillMedicationsRQ(List<RefillRequest> refillRequests) {
            this.refillRequests = refillRequests;
        }

        /**
         * @param medRefillRequests
         * @description
         */
        public RefillMedicationsRQ(List<VCC_MedsService.MedRefillRequest> medRefillRequests) {
            this.refillRequests = new List<RefillRequest>();
            for (VCC_MedsService.MedRefillRequest medRefillRequest : medRefillRequests) {
                this.refillRequests.add(new RefillRequest(medRefillRequest));
            }
        }
    }

    @SuppressWarnings('PMD.ApexDoc')
    public class RefillRequest {
        public String facilityId { get; set; }
        public String prescriptionId { get; set; }
        public String icn { get; set; }
        public String requesterId { get; set; }

        @SuppressWarnings('PMD.ExcessiveParameterList')
        public RefillRequest(String facilityId, String prescriptionId, String icn, String requesterId) {
            this.facilityId = facilityId;
            this.prescriptionId = prescriptionId;
            this.icn = icn;
            this.requesterId = requesterId;
        }

        public RefillRequest(VCC_MedsService.MedRefillRequest medRefillRequest) {
            this.facilityId = medRefillRequest.facilityId;
            this.prescriptionId = medRefillRequest.prescriptionId;
            this.icn = medRefillRequest.icn;
            this.requesterId = medRefillRequest.requesterId;
        }
    }

    /**
     * @description Gets the Activity Log of a med
     * @param rq Activity Log Request
     * @return VCC_ActivityLogRS
     */

    public VCC_ActivityLogRS getActivityLog(VCC_PharmacyLogRQ rq) {
        if (!bypassCallout) {
            return VCC_ActivityLogRS.parse(callDiva(rq, 'vccDivaActivityLog').getBody()).concatOtherComments();
        }
        return null; // Test class expects this
    }

    /**
     * @description Gets the Activity Log of a med
     * @param rq Activity Log Request
     * @return VCC_RefillLogRS
     */

    public VCC_RefillLogRS getRefillLog(VCC_PharmacyLogRQ rq) {
        if (!bypassCallout) {
            return VCC_RefillLogRS.parse(callDiva(rq, 'vccDivaRefillLog').getBody());
        }
        return null; // Test class expects this
    }

    /**
     * @param rq
     * @description
     * @return VCC_LabelLogRS
     */
    public VCC_LabelLogRS getLabelLog(VCC_PharmacyLogRQ rq) {
        if (!bypassCallout) {
            return VCC_LabelLogRS.parse(callDiva(rq, 'vccDivaLabelLog').getBody());
        }
        return null; // Test class expects this
    }

    /**
     * @param rq
     * @description
     * @return VCC_ErxLogRS
     */
    public VCC_ErxLogRS getERXLog(VCC_PharmacyLogRQ rq) {
        if (!bypassCallout) {
            return VCC_ErxLogRS.parse(callDiva(rq, 'vccDivaERXLog').getBody());
        }
        return null; // Test class expects this
    }

    /**
     * @param rq
     * @description
     * @return VCC_CmopLogRS
     */
    public VCC_CmopLogRS getCMOPLog(VCC_PharmacyLogRQ rq) {
        if (!bypassCallout) {
            return VCC_CmopLogRS.parse(callDiva(rq, 'vccDivaCMOPLog').getBody(), rq);
        }
        return null; // Test class expects this
    }

    /**
     * @param rq
     * @description
     * @return VCC_CopayLogRS
     */
    public VCC_CopayLogRS getCopayLog(VCC_PharmacyLogRQ rq) {
        if (!bypassCallout) {
            return VCC_CopayLogRS.parse(callDiva(rq, 'vccDivaCopayLog').getBody());
        }
        return null; // Test class expects this
    }

    /**
     * @param rq
     * @description
     * @return VCC_EcmeLogRS
     */
    public VCC_EcmeLogRS getECMELog(VCC_PharmacyLogRQ rq) {
        if (!bypassCallout) {
            return VCC_EcmeLogRS.parse(callDiva(rq, 'vccDivaECMELog').getBody());
        }
        return null; // Test class expects this
    }

    /**
     * @param rq
     * @description
     * @return VCC_PartialsLogRS
     */
    public VCC_PartialsLogRS getPartialsLog(VCC_PharmacyLogRQ rq) {
        if (!bypassCallout) {
            return VCC_PartialsLogRS.parse(callDiva(rq, 'vccDivaPartialsFillLog').getBody());
        }
        return null; // Test class expects this
    }

    /**
     * @param rq
     * @description
     * @return VCC_CmopLotExpLogRS
     */
    public VCC_CmopLotExpLogRS getCMOPLotExpLog(VCC_PharmacyLogRQ rq) {
        if (!bypassCallout) {
            return VCC_CmopLotExpLogRS.parse(callDiva(rq, 'vccDivaCMOPLotExpirationLog').getBody());
        }
        return null; // Test class expects this
    }

    /**
     * @description Callout to DIVA remote service
     * @param rq Request
     * @param serviceName Name of vccEndpoint Custom MD record for endpoint utility
     * @return  `HTTP` Response
     * @exception 'VCC_DivaClientException'
     */

    @TestVisible
    public static HttpResponse callDiva(VCC_DivaRequest rq, String serviceName) {
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint(VCC_EndpointUtility.getEndpoint('DIVA', serviceName));
        httpRequest.setHeader('Accept', 'application/json');
        httpRequest.setHeader('Content-Type', 'application/json; charset=UTF-8');
        httpRequest.setHeader('clientId', '{!$Credential.Username}');
        httpRequest.setHeader('clientSecret', '{!$Credential.Password}');
        httpRequest.setMethod('POST'); // Will these endponts always be POSTs?
        httpRequest.setBody(JSON.serialize(rq));
        httpRequest.setTimeout(120000); // TODO: this needs to be in custom md

        HttpResponse res = new Http().send(httpRequest);

        switch on handleStatusCode(res.getStatusCode()) {
            when SUCCESS {
                return res;
            }
            when BAD_REQUEST {
                throw new VCC_DivaBadRequestException(res.getBody());
            }
            when SERVER_ERROR {
                throw new VCC_DivaRemoteInternalException(res.getBody());
            }
            when else {
                throw new VCC_DivaClientException('DIVA Client has thrown an exception');
            }
        }
    }

    static VCC_Enum.VCC_HTTPStatusEnum handleStatusCode(Integer statusCode) {
        if (statusCode >= 200 && statusCode <= 299) {
            return VCC_Enum.VCC_HTTPStatusEnum.SUCCESS;
        }

        if (statusCode >= 400 && statusCode <= 499) {
            return VCC_Enum.VCC_HTTPStatusEnum.BAD_REQUEST;
        }

        if (statusCode >= 500 && statusCode <= 599) {
            return VCC_Enum.VCC_HTTPStatusEnum.SERVER_ERROR;
        }

        return VCC_Enum.VCC_HTTPStatusEnum.UNKNOWN;
    }
}
