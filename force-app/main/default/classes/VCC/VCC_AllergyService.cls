/**
 * @author Kumar Balan
 * @group API - Bridg - Allergy
 * @description Allergy Service class.
 */
public inherited sharing class VCC_AllergyService {
    /**
     * @description Default constructor.
     */
    public VCC_allergyService() {
        System.debug(LoggingLevel.INFO, 'AllergyService initilized');
    }
    public static String VCC_ALLERGY_NAMEDCRED = 'callout:VCC_Allergy';
    public static String enviornment;

    /**
     * @description Makes a callout to get allergy information.
     * @param allergyReqWrp
     *
     * @return
     */
    public VCC_AllergyResponseWrp getAllergy(VCC_AllergyLightningRequestWrp allergyReqWrp) {
        VCC_Workstream_Settings__mdt workstreamSettings = VCC_WorkstreamSettingsController.getWorkstreamSettings();

        String recordId = allergyReqWrp.recordId;
        String facility = allergyReqWrp.facility;
        String startDate = System.now().addMonths(-Integer.valueOf(workstreamSettings.VCC_Allergies_Adverse_Reactions_Duration__c)).format('yyyy-MM-dd');
        String endDate = System.now().format('yyyy-MM-dd');

        if (recordId == null || facility == null || startDate == null || endDate == null) {
            return null;
        }

        VCC_AllergyModal allergyModalObj;
        VCC_AllergyResponseWrp allergyResWrp = new VCC_AllergyResponseWrp();
        String responseBody = '';
        Integer responseCode = 0;

        String env = VCC_ApiSettingUtility.getEnviornment();
        if (String.isBlank(enviornment)) {
            enviornment = env;
        }

        if (enviornment == VCC_ApiSettingUtility.ENV_PROD) {
            HttpResponse allergysCalloutResponse = retrieveAllergyCallout(recordId, facility, startDate, endDate);
            System.debug(LoggingLevel.INFO, 'VCC_AllergyService:getAllergy:consultsCalloutResponse.getBody(): ' + allergysCalloutResponse.getBody());
            System.debug(LoggingLevel.INFO, 'VCC_AllergyService:getAllergy:consultsCalloutResponse.getStatusCode(): ' + allergysCalloutResponse.getStatusCode());
            responseBody = allergysCalloutResponse.getBody();
            responseCode = allergysCalloutResponse.getStatusCode();
        } else {
            allergyResWrp.status = true;
            allergyResWrp.errorMsg = '';
            responseCode = 200;
            responseBody = [SELECT Id, Body FROM StaticResource WHERE Name = 'VCC_AllergyJsonExample' WITH USER_MODE LIMIT 1][0].Body.toString();
        }

        allergyResWrp.statusCode = responseCode;
        allergyResWrp.responseBody = responseBody;
        System.debug(LoggingLevel.INFO, 'VCC_AllergyService:getAllergy:No Allergies results for contact: ' + recordId + ' body: ' + responseBody);
        if (responseCode == 200) {
            allergyModalObj = (VCC_AllergyModal) VCC_JSONUtil.deserialize(responseBody, Type.forName('VCC_AllergyModal'));
            System.debug(LoggingLevel.INFO, 'VCC_AllergyService:getAllergy:allergyModalObj: ' + allergyModalObj);
            allergyResWrp.allergyModal = allergyModalObj;
        }
        return allergyResWrp;
    }

    public HttpResponse retrieveAllergyCallout(String recordId, String facility, String startDate, String endDate) {
        VCC_HttpRequest request = new VCC_HttpRequest();
        request.requestMethod = VCC_HttpRequest.REQUEST_METHOD_POST;
        request.NAMED_CRED_NAME = 'vccBridgAllergy';
        //request.addBodyParameter(VCC_HttpRequest.CLIENT_NAME, 'VRECRM');
        /*if (facility != null && String.isBlank(facility))
            request.addBodyParameter(VCC_HttpRequest.NATIONAL_ID, getContactNationalID(recordId));
        request.addBodyParameter(VCC_HttpRequest.IEN, getIEN(recordId));
        */

        request.addBodyParameter(VCC_HttpRequest.NATIONAL_ID, VCC_QuerySelector.getContactNationalID(recordId));
        request.addBodyParameter(VCC_HttpRequest.IEN, '29918');
        request.addBodyParameter(VCC_HttpRequest.ASSIGNING_FACILITY, facility);
        //request.addBodyParameter(VCC_HttpRequest.START_DATE, startDate);
        //request.addBodyParameter(VCC_HttpRequest.END_DATE, endDate);
        return request.makeRequestAndGetResponse();
    }
}
