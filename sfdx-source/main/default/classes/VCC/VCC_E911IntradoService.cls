/**
 * @description e911 Intrado service callout handler. Contructs request bodies and handles the http request call. Intrado is a 3rd party API that is responsible for providing temporary local e911 phone numbers according to the address provided
 * @author Booz Allen
 * @since 04/2024
 */
public with sharing class VCC_E911IntradoService {
    /**
     * @description handles the callout to Intrado to retrived data. Will retry according to the max attempts specified due to the middle layer having handshake issues
     * @param requestBody - request body for callout
     * @param endpoint - endpoint to callout to (validate address or get transfer number
     * @return String - response body from callout
     */
    public static String handleCallout(String requestBody, String endpoint) {
        String endpointAddr = VCC_EndpointUtility.getEndpoint('e911', endpoint);

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpointAddr);
        req.setMethod('POST');
        req.setBody(requestBody);

        //Need retry logic because middle layer can produce handshake error during callout
        Integer numAttempts = 5;
        while (numAttempts > 0) {
            Http http = new Http();
            HTTPResponse res = http.send(req);
            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                Logger.info(numAttempts + ' remaining attemps when successful');
                return res.getBody();
            } else if (res.getStatusCode() >= 400 && res.getStatusCode() < 500) {
                //400 level errors will not resolve with retry
                Logger.error(
                    'intrado call resulted in a ' +
                        res.getStatus() +
                        ' status code: ' +
                        res.getBody() +
                        '. Stopping call'
                );
                return null;
            } else {
                //500 usually indicates soap handshake error on DIP side
                Logger.error(
                    'intrado callout ran into an issue ' +
                        res.getBody() +
                        '\n retrying with ' +
                        numAttempts +
                        'attempts'
                );
                numAttempts--;
            }
        }
        // Maximum number of retry attempts reached, return null
        return null;
    }

    /**
     * @description builds the reqeust body for e911 getTransferNumber endpoint
     * @param e911Metric - e911 Metric record with address and callback information
     * @return serialized request body
     */
    public static String buildReqBodyFromMetric(VCC_e911_Metrics__c e911Metric) {
        CivicAddress addr = new CivicAddress();
        Pattern pattern = Pattern.compile('(\\d+) (.*)');
        Matcher patternMatcher = pattern.matcher(e911Metric.VCC_Street__c);
        if (patternMatcher.matches()) {
            addr.houseNumber = patternMatcher.group(1);
            addr.road = patternMatcher.group(2);
        }
        addr.city = e911Metric.VCC_City__c;
        addr.state = e911Metric.VCC_State__c;
        addr.postalCode = e911Metric.VCC_Zip_Code__c;
        addr.country = 'US';

        E911RequestBody body = new E911RequestBody();
        body.civicAddress = addr;
        body.callbackNumber = e911Metric.VCC_Call_Back_Number__c.replace('-', '');

        return JSON.serialize(body);
    }

    /**
     * @description request body class
     */
    @SuppressWarnings('PMD.ClassNamingConventions')
    @TestVisible
    private class E911RequestBody {
        /**
         * @description civic address object
         */
        public CivicAddress civicAddress;
        /**
         * @description callback number of employee
         */
        public String callbackNumber;
    }

    /**
     * @description civic address inside request body
     */
    @SuppressWarnings('PMD.ClassNamingConventions')
    @TestVisible
    private class CivicAddress {
        /**
         * @description house number
         */
        public String houseNumber;
        /**
         * @description road or street of address
         */
        public String road;
        /**
         * @description city of address
         */
        public String city;
        /**
         * @description state of address
         */
        public String state;
        /**
         * @description zip code of address
         */
        public String postalCode;
        /**
         * @description country of address
         */
        public String country;
    }

    /**
     * @description E911 Callout Response object
     */
    @SuppressWarnings('PMD.ClassNamingConventions')
    public class E911Response {
        /**
         * @description successful callout: true or false
         */
        @InvocableVariable
        public String success;
        /**
         * @description details of callout response
         */
        @InvocableVariable
        public String message;
        /**
         * @description response object
         */
        @InvocableVariable
        public ResponseData response;
    }

    /**
     * @description E911 Callout Nested Response Data object
     */
    @SuppressWarnings('PMD.ClassNamingConventions')
    public class ResponseData {
        /**
         * @description status of callout
         */
        @InvocableVariable(label='status' description='status of call')
        public String status;
        /**
         * @description message id
         */
        @InvocableVariable
        public String messageId;
        /**
         * @description level of service
         */
        @InvocableVariable
        public String levelOfService;
        /**
         * @description transfer number
         */
        @InvocableVariable
        public String transferNumber;
    }
}
