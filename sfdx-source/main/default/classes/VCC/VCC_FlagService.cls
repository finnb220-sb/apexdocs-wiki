/**
 * @author Kumar Balan
 * @group API - Bridg - Flags
 * @description VCC Flag Service
 */
public inherited sharing class VCC_FlagService {
    public static final String VCC_FLAG_NAMEDCRED = 'callout:VCC_Flags';
    public static String enviornment;
    public static final String TYPE_FLAG = 'Flags';

    /**
     * @description empty default constructor
     */
    public VCC_FlagService() {
        //empty constructor
    }
    /**
     * @description Get Flags
     * @param flagReqWrp VCC_FlagLightningRequestWrp
     *
     * @return VCC_FlagResponseWrp
     */
    public VCC_FlagResponseWrp getFlags(VCC_FlagLightningRequestWrp flagReqWrp) {
        String recordId = flagReqWrp.recordId;
        String facility = flagReqWrp.facility;
        String startDate = flagReqWrp.startDate;
        String endDate = flagReqWrp.endDate;

        if (recordId == null || facility == null || startDate == null || endDate == null) {
            return null;
        }
        // Flag Fixes
        String accountId = recordId;
        String sObjName = Id.valueOf(recordId).getSobjectType().getDescribe().getName();
        if (sObjName == 'VCC_Progress_Note__c') {
            accountId = [
                SELECT VCC_Case__r.AccountId
                FROM VCC_Progress_Note__c
                WHERE Id = :recordId
                WITH SECURITY_ENFORCED
            ][0]
            .VCC_Case__r.AccountId;
        } else if (sObjName == 'Case') {
            accountId = [
                SELECT AccountId
                FROM Case
                WHERE Id = :recordId
                WITH SECURITY_ENFORCED
            ][0]
            .AccountId;
        }

        VCC_FlagModal flagModalObj;
        VCC_FlagResponseWrp flagResWrp = new VCC_FlagResponseWrp();
        String responseBody = '';
        Integer responseCode = 0;

        String env = VCC_ApiSettingUtility.getEnviornment();
        if (String.isBlank(enviornment)) {
            enviornment = env;
        }

        if (VCC_TrainingModeService.isTrainingModeEnabled()) {
            // responseBody = VCC_TrainingModeService.getFlagsByAccountId(recordId);
            responseBody = VCC_TrainingModeService.getFlagsByAccountId(accountId);

            flagResWrp.status = true;
            flagResWrp.errorMsg = '';
            responseCode = 200;
        } else {
            if (enviornment == VCC_ApiSettingUtility.ENV_PROD) {
                HttpResponse flagCalloutResponse = retrieveFlagCallout(recordId, facility, startDate, endDate);

                responseBody = flagCalloutResponse.getBody();
                responseCode = flagCalloutResponse.getStatusCode();

                // Womens Health Details
                HttpResponse womensHealthCalloutResponse = retrieveWomenHealthCallout(
                    recordId,
                    facility,
                    startDate,
                    endDate
                );

                flagResWrp.womenHealthResponseBody = womensHealthCalloutResponse.getBody();
            } else {
                flagResWrp.status = true;
                flagResWrp.errorMsg = '';
                responseCode = 200;
                responseBody = [
                        SELECT Id, Body
                        FROM StaticResource
                        WHERE Name = 'VCC_FlagJsonExample'
                        WITH SECURITY_ENFORCED
                        LIMIT 1
                    ][0]
                    .Body.toString();
            }

            flagResWrp.statusCode = responseCode;
            flagResWrp.responseBody = responseBody;
        }

        if (responseCode == 200) {
            flagModalObj = (VCC_FlagModal) VCC_JSONUtil.deserialize(responseBody, Type.forName('VCC_FlagModal'));

            flagResWrp.flagModal = flagModalObj;
        }
        return flagResWrp;
    }
    /**
     * @description
     * @param recordId
     * @param facility
     * @param startDate
     * @param endDate
     *
     * @return HttpResponse
     */
    public HttpResponse retrieveFlagCallout(String recordId, String facility, String startDate, String endDate) {
        VCC_HttpRequest request = new VCC_HttpRequest();
        request.requestMethod = VCC_HttpRequest.REQUEST_METHOD_POST;
        //request.namedCredentialEndpointURL =  VCC_FLAG_NAMEDCRED;
        request.NAMED_CRED_NAME = 'vccBridgFlags';
        // request.addBodyParameter(VCC_HttpRequest.NATIONAL_ID, '1012881470V086192');
        request.addBodyParameter(VCC_HttpRequest.NATIONAL_ID, VCC_QuerySelector.getContactNationalID(recordId));
        // request.addBodyParameter(VCC_HttpRequest.IEN, '202243');
        request.addBodyParameter(VCC_HttpRequest.ASSIGNING_FACILITY, facility);
        return request.makeRequestAndGetResponse();
    }

    /**
     * @description This method retrieves Women Health Callout.
     * @param recordId Input recordId that represents the unique identifier of the record.
     * @param facility Input facility, as a string, that specifies the facility to be used.
     * @param startDate Start date for the request in string format.
     * @param endDate End date for the request in string format.
     * @return HttpResponse The method returns the Http Response after making the request.
     *
     * @example
     * HttpResponse response = retrieveWomenHealthCallout('recordId123', 'facilityX', '2022-01-01', '2022-12-31');
     */
    public HttpResponse retrieveWomenHealthCallout(String recordId, String facility, String startDate, String endDate) {
        VCC_HttpRequest request = new VCC_HttpRequest();
        request.requestMethod = VCC_HttpRequest.REQUEST_METHOD_POST;
        //request.namedCredentialEndpointURL =  VCC_FLAG_NAMEDCRED;
        request.NAMED_CRED_NAME = 'vccBridgWomensHealth';
        // request.addBodyParameter(VCC_HttpRequest.NATIONAL_ID, '1012881470V086192');
        request.addBodyParameter(VCC_HttpRequest.NATIONAL_ID, VCC_QuerySelector.getContactNationalID(recordId));
        // request.addBodyParameter(VCC_HttpRequest.IEN, '202243');
        request.addBodyParameter(VCC_HttpRequest.ASSIGNING_FACILITY, facility);
        request.addBodyParameter(VCC_HttpRequest.ASSIGNING_AUTHORITY, 'USVHA');
        request.addBodyParameter(VCC_HttpRequest.START_DATE, startDate);
        request.addBodyParameter(VCC_HttpRequest.END_DATE, endDate);
        request.addBodyParameter(VCC_HttpRequest.ASSIGNING_FACILITY, facility);
        return request.makeRequestAndGetResponse();
    }
}
