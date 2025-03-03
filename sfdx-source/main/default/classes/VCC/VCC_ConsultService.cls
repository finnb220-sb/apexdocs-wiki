/**
 * @author Kumar Balan
 * @group API - Bridg - Consults
 * @description VCC Consult Service class.
 */
public inherited sharing class VCC_ConsultService {
    public VCC_ConsultService() {
        System.debug(LoggingLevel.INFO, 'VCC_ConsultService initialized.');
    }
    public static String VCC_CONSULT_NAMEDCRED = 'callout:VCC_Consults';
    public static String enviornment;

    /**
     * @description Contructor
     * @param consultReqWrp
     *
     * @return
     */
    public VCC_ConsultResponseWrp getConsults(VCC_ConsultLightningRequestWrp consultReqWrp) {
        System.debug('VCC_ConsultService:getConsults:Start');
        String recordId = consultReqWrp.recordId;
        String facility = consultReqWrp.facility;
        String startDate = consultReqWrp.startDate;
        String endDate = consultReqWrp.endDate;

        if (recordId == null || facility == null || startDate == null || endDate == null) {
            return null;
        }

        VCC_ConsultModal consultModalObj;
        VCC_ConsultResponseWrp consultResWrp = new VCC_ConsultResponseWrp();
        String responseBody = '';
        Integer responseCode = 0;

        String env = VCC_ApiSettingUtility.getEnviornment();
        if (String.isBlank(enviornment)) {
            enviornment = env;
        }

        if (enviornment == VCC_ApiSettingUtility.ENV_PROD) {
            HttpResponse consultCalloutResponse = retrieveConsultCallout(recordId, facility, startDate, endDate);
            System.debug(LoggingLevel.INFO, 'VCC_ConsultService:getConsults:consultsCalloutResponse.getBody(): ' + consultCalloutResponse.getBody());
            System.debug(LoggingLevel.INFO, 'VCC_ConsultService:getConsults:consultsCalloutResponse.getStatusCode(): ' + consultCalloutResponse.getStatusCode());
            responseBody = consultCalloutResponse.getBody();
            responseCode = consultCalloutResponse.getStatusCode();
        } else {
            consultResWrp.status = true;
            consultResWrp.errorMsg = '';
            responseCode = 200;
            responseBody = [SELECT Id, Body FROM StaticResource WHERE Name = 'VCC_ConsultJsonExample' WITH USER_MODE LIMIT 1][0].Body.toString();
        }

        consultResWrp.statusCode = responseCode;
        consultResWrp.responseBody = responseBody;
        System.debug(LoggingLevel.INFO, 'VCC_ConsultService:getConsults:No Consults results for contact: ' + recordId + ' body: ' + responseBody);
        if (responseCode == 200) {
            consultModalObj = (VCC_ConsultModal) VCC_JSONUtil.deserialize(responseBody, Type.forName('VCC_ConsultModal'));
            System.debug(LoggingLevel.INFO, 'VCC_ConsultService:getConsults:consultModalObj: ' + consultModalObj);
            consultResWrp.consultModal = consultModalObj;
        }
        return consultResWrp;
    }

    /**
     * @description Callout to retrieve consult
     * @param recordId
     * @param facility
     * @param startDate
     * @param endDate
     *
     * @return HttpResponse
     */
    public HttpResponse retrieveConsultCallout(String recordId, String facility, String startDate, String endDate) {
        VCC_HttpRequest request = new VCC_HttpRequest();
        request.requestMethod = VCC_HttpRequest.REQUEST_METHOD_POST;
        // request.namedCredentialEndpointURL =  VCC_CONSULT_NAMEDCRED;
        request.NAMED_CRED_NAME = 'vccBridgConsults';
        //request.addBodyParameter(VCC_HttpRequest.NATIONAL_ID, '1012991510V125649');
        request.addBodyParameter(VCC_HttpRequest.NATIONAL_ID, VCC_QuerySelector.getContactNationalID(recordId));
        // request.addBodyParameter(VCC_HttpRequest.IEN, '202243');
        request.addBodyParameter(VCC_HttpRequest.ASSIGNING_FACILITY, facility);
        request.addBodyParameter(VCC_HttpRequest.START_DATE, startDate);
        request.addBodyParameter(VCC_HttpRequest.STOP_DATE, endDate);
        request.addBodyParameter(VCC_HttpRequest.MAX, '100');
        request.addBodyParameter(VCC_HttpRequest.FILTER, '1');

        return request.makeRequestAndGetResponse();
    }
}
