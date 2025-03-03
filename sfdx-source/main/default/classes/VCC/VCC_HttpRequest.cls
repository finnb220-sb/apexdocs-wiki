/**
 * @description
 * @author Kumar Balan
 * @since 5/28/2021
 * @group HTTP
 */
@SuppressWarnings('PMD.ApexDoc')
public inherited sharing class VCC_HttpRequest {
    private Map<String, String> requestBodyParameters;

    public String namedCredentialEndpointURL { get; set; }
    public String requestMethod { get; set; }
    private VCC_API_Setting__mdt settings;

    public String NAMED_CRED_NAME { get; set; }

    public static final String CONTENT_HEADER_TYPE_VALUE = 'application/json';
    public static final String API_KEY_VALUE = '{!$Credential.Password}';

    public static final String REQUEST_METHOD_POST = 'POST';
    public static final String REQUEST_METHOD_GET = 'GET';

    // Params Names
    public static final String ASSIGNING_AUTHORITY = 'assigningAuthority';
    public static final String ASSIGNING_FACILITY = 'assigningFacility';
    public static final String DEFAULT_SETTINGS = 'CCM_Default_Settings';
    public static final String NATIONAL_ID = 'nationalId';
    public static final String IEN = 'ien';
    public static final String API_KEY = 'apiKey';
    public static final String CLIENT_NAME = 'clientName';

    public static final String START_DATE = 'startDate';
    public static final String STOP_DATE = 'stopDate';
    public static final String END_DATE = 'endDate';
    public static final String VAR_TYPE = 'vaType';
    public static final String MAX = 'max';
    public static final String FILTER = 'filter';
    public static final String CATEGORY = 'category';

    public VCC_HttpRequest() {
        this.settings = VCC_ApiSettingUtility.getInstance();
        if (requestBodyParameters == null) {
            requestBodyParameters = new Map<String, String>();
        }
        requestBodyParameters.put(VCC_HttpRequest.ASSIGNING_AUTHORITY, this.settings.VCC_AssigningAuthority__c);
    }

    public void addBodyParameter(String key, String value) {
        if (requestBodyParameters == null) {
            requestBodyParameters = new Map<String, String>();
        }
        requestBodyParameters.put(key, value);
    }

    public Map<String, String> getRequestBodyParameters() {
        return requestBodyParameters;
    }

    public HttpResponse makeRequestAndGetResponse() {
        String response = '';
        HttpRequest calloutRequest = new HttpRequest();
        HttpResponse calloutResponse = null;
        //calloutRequest.setEndpoint(this.namedCredentialEndpointURL);
        calloutRequest.setEndpoint(VCC_EndpointUtility.getEndpoint('Bridg', NAMED_CRED_NAME));
        calloutRequest.setMethod(this.requestMethod);
        System.debug(LoggingLevel.INFO, this.settings);
        calloutRequest.setHeader(API_KEY, '{!$Credential.Password}');
        calloutRequest.setHeader('Content-Type', CONTENT_HEADER_TYPE_VALUE);
        calloutRequest.setBody(JSON.serialize(getRequestBodyParameters()));
        calloutRequest.setTimeout(this.settings.VCC_Callout_Timeout__c.intValue());
        System.debug(LoggingLevel.INFO, 'getRequestBodyParameters() ===> ' + getRequestBodyParameters());
        calloutResponse = new Http().send(calloutRequest);
        return calloutResponse;
    }
}
