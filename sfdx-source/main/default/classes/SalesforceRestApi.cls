/**
 * Author:Jaren Yach
 *  Created Date 05/13/2022
 *  Purpose: This class is used to make callouts into the org using
 *  the Salesforce Rest api.
 */
public with sharing class SalesforceRestApi extends BaseSalesforceApi {
    public static final String API_VERSION = '54.0';
    private String restAPIURL;
    private HttpRequest httpRequest;

    /**
     * Constructor
     */
    public SalesforceRestApi() {
        this(false);
    }
    public SalesforceRestApi(Boolean useVFPageForSession) {
        super(useVFPageForSession);
        httpRequest = new HttpRequest();
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setHeader('Authorization', 'Bearer ' + this.sessionId);
        httpRequest.setTimeout(120000);
    }

    /**
     * Set the URL to call
     *
     * @param endpoint - Endpoint to call
     *
     * @return SalesforceRestApi
     */
    public SalesforceRestApi setURL(String endpoint) {
        this.restAPIURL = Url.getSalesforceBaseUrl().toExternalForm() + endpoint;
        this.httpRequest.setEndpoint(this.restAPIURL);
        return this;
    }

    /**
     * Add headers
     *
     * @param key - key
     * @param value - va;ie
     *
     * @return SalesforceRestApi
     */
    public SalesforceRestApi setHeader(String key, String value) {
        this.httpRequest.setHeader(key, value);
        return this;
    }

    /**
     * Set the Request Body
     *
     * @param body -Request body
     *
     * @return SalesforceRestApi
     */
    public SalesforceRestApi setBody(String body) {
        this.httpRequest.setBody(body);
        return this;
    }

    /**
     * Makes api callout with POST method
     *
     * @return - response body
     */
    public String doPost() {
        this.httpRequest.setMethod('POST');
        return doCallOut();
    }

    /**
     * Does the API Call Out
     *
     * @return response
     */
    private String doCallOut() {
        String response = '';
        try {
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpRequest);
            Integer statusCode = httpResponse.getStatusCode();
            if (statusCode >= 200 && statusCode <= 299) {
                response = httpResponse.getBody();
            } else {
                throw new CalloutException(httpResponse.getBody());
            }
        } catch (System.Exception e) {
            throw e;
        }
        return response;
    }
}
