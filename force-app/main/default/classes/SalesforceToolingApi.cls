/**
 * Author:Jaren Yach
 *  Created Date 05/06/2022
 *  Purpose: This class is used to make callouts into the org using
 *  the Salesforce Tooling api.
 */
public inherited sharing class SalesforceToolingApi extends BaseSalesforceApi {
    public static final String API_VERSION = '54.0';
    private String baseUrl;
    private String endpoint;
    private HttpRequest httpRequest;
    private Integer calloutAttempt;

    public SalesforceToolingApi() {
        this(false);
    }

    public SalesforceToolingApi(Boolean useVFPageForSession) {
        super(useVFPageForSession);
        httpRequest = new HttpRequest();
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setHeader('Authorization', 'Bearer ' + this.sessionId);
        httpRequest.setTimeout(120000);
        this.setToolingAPIURL();
    }

    /**
     * Sets the endpoint to call.
     *
     * @param endpoint
     *
     * @return SalesforceToolingApi
     */
    public SalesforceToolingApi setURL(String endpoint) {
        this.endpoint = endpoint;
        return this;
    }

    /**
     * Builds the json body
     *
     * @param reqObject - generic object map
     *
     * @return SalesforceToolingApi
     */
    public SalesforceToolingApi setRequestBody(Map<String, Object> reqObject) {
        this.httpRequest.setBody(JSON.serialize(reqObject));
        return this;
    }

    /**
     * Sets the http method to GET and does callout
     *
     * @return http response body
     */
    public String doGET() {
        this.httpRequest.setMethod('GET');
        return doCallOut();
    }

    /**
     * Sets the http method to Patch and does callout
     *
     * @return http response body
     */
    public String doPatch() {
        this.httpRequest.setMethod('PATCH');
        return doCallOut();
    }

    /**
     * This method will call the Tooling api to get profile details based on
     * a set of profile ids
     *
     * @param profileIds - The set of profile ids to query
     *
     * @return QueryResult
     */
    public QueryResult getProfileByIds(Set<Id> profileIds) {
        String profileIdFilter = null;
        for (String item : profileIds) {
            if (profileIdFilter == null) {
                profileIdFilter = '\'' + item + '\'';
            } else {
                profileIdFilter += ',' + '\'' + item + '\'';
            }
        }
        List<String> queryFields = new List<String>{ 'Id,Name,FullName' };

        String query = 'SELECT ' + String.join(queryFields, ',') + ' FROM Profile where Id in(' + profileIdFilter + ')';
        this.setURL('/query/?q=' + EncodingUtil.urlEncode(query, 'UTF-8'));

        String results = this.doGET();
        return (QueryResult) JSON.deserialize(results, QueryResult.class);
    }

    /**
     * Gets ApexClass records that are unmanaged
     * @return QueryResult
     */
    public QueryResult getUnmanagedClasses() {
        List<String> queryFields = new List<String>{ 'Id,Name' };

        String filter = '\'unmanaged\'';
        String query = 'SELECT ' + String.join(queryFields, ',') + ' FROM ApexClass where ManageableState =' + filter;
        this.setURL('/query/?q=' + EncodingUtil.urlEncode(query, 'UTF-8'));

        String results = this.doGET();
        return (QueryResult) JSON.deserialize(results, QueryResult.class);
    }

    /**
     * Gets ApexTrigger records that are unmanaged
     * @return QueryResult
     */
    public QueryResult getUnmanagedTriggers() {
        List<String> queryFields = new List<String>{ 'Id,Name' };

        String filter = '\'unmanaged\'';
        String query = 'SELECT ' + String.join(queryFields, ',') + ' FROM ApexTrigger where ManageableState =' + filter;
        this.setURL('/query/?q=' + EncodingUtil.urlEncode(query, 'UTF-8'));

        String results = this.doGET();
        return (QueryResult) JSON.deserialize(results, QueryResult.class);
    }

    public String doGetQuery(String query) {
        this.setURL('/query/?q=' + EncodingUtil.urlEncode(query, 'UTF-8'));
        return this.doGET();
    }

    /**
     * Performs Callout using tooling api
     *
     * @return http response body
     */
    private String doCallOut() {
        String response = '';
        this.httpRequest.setEndpoint(this.baseUrl + endpoint);
        try {
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpRequest);
            Integer statusCode = httpResponse.getStatusCode();
            if (statusCode >= 200 && statusCode <= 299) {
                response = httpResponse.getBody();
            } else {
                throw new CalloutException(httpResponse.getBody());
            }
        } catch (CalloutException ex) {
            if (ex.getMessage().containsIgnoreCase('Unauthorized endpoint')) {
                if (canRetry()) {
                    return doCallOut();
                } else {
                    throw ex;
                }
            }
        }
        return response;
    }

    /**
     * Sets the base url for the tooling api.  Calling the api from
     * a sandbox requires the instance name.
     */
    private void setToolingAPIURL() {
        this.baseUrl = 'https://' + DTCUtils.getOrgHost();
        Organization orgInfo = DTCUtils.getOrgInfo();
        if (orgInfo.IsSandbox) {
            if (calloutAttempt == 1) {
                //Add instance name to url
                this.baseUrl += '.' + orgInfo.InstanceName;
            }
        }
        this.baseUrl += '.my.salesforce.com/services/data/v' + API_VERSION + '/tooling';
    }

    /**
     * Determines if the api call can happen again or not.
     *
     * @return
     */
    private Boolean canRetry() {
        if (calloutAttempt == null) {
            calloutAttempt = 1;
        }
        if (calloutAttempt == 1 && DTCUtils.getOrgInfo().IsSandbox) {
            setToolingAPIURL();
            this.calloutAttempt = 2;
            return true;
        }
        return false;
    }

    public class QueryResult {
        public String entityTypeName;
        public String nextRecordsUrl;
        public String queryLocator;
        public List<Record> records;
        public Integer size;
        public Integer totalSize;
    }

    /**
     * Base class for records
     */
    public virtual class Record {
        public String Id;
        public String Name;
        public String FullName;
    }
}
