/**
 * @description VCC_EndpointService class
 * This class contains methods to get status code metadata and endpoint
 */
public with sharing class VCC_EndpointService {
    /**
     * @description Method to get status code metadata
     * @param statusCode - The status code for which metadata is to be retrieved
     * @param endpointName - The name of the endpoint
     * @param appName - The name of the application
     * @return List<StatusCodeMetadata> - Returns a list of StatusCodeMetadata
     */
    public static List<StatusCodeMetadata> getStatusCodeMetadata(Integer statusCode, String endpointName, String appName) {
        Map<Id, StatusCodeMetadata> configMap = new Map<Id, StatusCodeMetadata>();
        VCC_EndpointStatusCodeSelector codeSelector = new VCC_EndpointStatusCodeSelector();
        VCC_EndpointStatusCodeRangeSelector rangeSelector = new VCC_EndpointStatusCodeRangeSelector();

        //endpoint specific code
        for (VCC_Endpoint_Status_Code__mdt sc : codeSelector.selectByCodeAndEndpoint(statusCode, endpointName)) {
            configMap.put(sc.VCC_Endpoint_Status_Code_Configuration__r.Id, new StatusCodeMetadata(sc, statusCode));
        }

        //endpoint specific range
        if (configMap.keySet().size() == 0) {
            for (VCC_Endpoint_Status_Code_Range__mdt range : rangeSelector.selectByCodeAndApp(statusCode, appName)) {
                configMap.put(range.VCC_Endpoint_Status_Code_Configuration__r.Id, new StatusCodeMetadata(range, statusCode));
            }
        }

        //app specific code
        if (configMap.keySet().size() == 0) {
            for (VCC_Endpoint_Status_Code__mdt sc : codeSelector.selectByCodeAndApp(statusCode, appName)) {
                configMap.put(sc.VCC_Endpoint_Status_Code_Configuration__r.Id, new StatusCodeMetadata(sc, statusCode));
            }
        }

        //app specific range
        if (configMap.keySet().size() == 0) {
            for (VCC_Endpoint_Status_Code_Range__mdt range : rangeSelector.selectByCodeAndEndpoint(statusCode, endpointName)) {
                configMap.put(range.VCC_Endpoint_Status_Code_Configuration__r.Id, new StatusCodeMetadata(range, statusCode));
            }
        }

        //global code
        if (configMap.keySet().size() == 0) {
            for (VCC_Endpoint_Status_Code__mdt sc : codeSelector.selectGlobalByCode(statusCode)) {
                configMap.put(sc.VCC_Endpoint_Status_Code_Configuration__r.Id, new StatusCodeMetadata(sc, statusCode));
            }
        }

        //global range
        if (configMap.keySet().size() == 0) {
            for (VCC_Endpoint_Status_Code_Range__mdt range : rangeSelector.selectGlobalByCode(statusCode)) {
                configMap.put(range.VCC_Endpoint_Status_Code_Configuration__r.Id, new StatusCodeMetadata(range, statusCode));
            }
        }

        for (VCC_Endpoint_Status_Code_Configuration__mdt config : (new VCC_EndpointStatusCodeConfigSelector()).selectById(configMap.keySet())) {
            configMap.get(config.Id).setProps(config);
        }

        return configMap.values();
    }

    /**
     * @description class
     * Class to store attributes related to status code metadata
     */
    public class StatusCodeMetadata {
        /**
         * @description getter and setter for isRange
         */
        public Boolean isRange { get; set; }
        /**
         * @description getter and setter for message
         */
        public String message { get; set; }
        /**
         * @description getter and setter for subMessage
         */
        public String subMessage { get; set; }
        /**
         * @description getter and setter for type
         */
        public String type { get; set; }
        /**
         * @description getter and setter for illustrationVariant
         */
        public String illustrationVariant { get; set; }
        /**
         * @description getter and setter for statusCode
         */
        public Integer statusCode { get; set; }
        /**
         * @description Sets the properties of the instance with the values from the given custom metadata record.
         *
         * @param config The custom metadata record (of type VCC_Endpoint_Status_Code_Configuration__mdt)
         *               used to set the instance properties
         * @property message It is set to the value of VCC_Message__c field from the config parameter
         * @property subMessage It is set to the value of VCC_SubMessage__c field from the config parameter
         * @property type It is set to the value of VCC_Type__c field from the config parameter
         * @property illustrationVariant It is set to the value of VCC_Illustration_Variant__c field
         *                               from the config parameter
         */
        public void setProps(VCC_Endpoint_Status_Code_Configuration__mdt config) {
            this.message = config.VCC_Message__c;
            this.subMessage = config.VCC_SubMessage__c;
            this.type = config.VCC_Type__c;
            this.illustrationVariant = config.VCC_Illustration_Variant__c;
        }
        /**
         * @description Constructs a StatusCodeMetadata object with parameters for a Status Code and a Metadata driven range.
         *
         * @param range       The `VCC_Endpoint_Status_Code_Range__mdt` metadata parameter specifying a range.
         * @param statusCode  An Integer parameter for specifying the status code.
         */
        public StatusCodeMetadata(VCC_Endpoint_Status_Code_Range__mdt range, Integer statusCode) {
            this.statusCode = statusCode;
            this.isRange = true;
        }
        /**
         * @description Constructor for StatusCodeMetadata class.
         *
         * @param range Input VCC_Endpoint_Status_Code__mdt object
         * @param statusCode Input Integer as statusCode
         * Using these parameters, a StatusCodeMetadata object will be instantiated. The values of
         * 'range' and 'statusCode' will be used to set the appropriate attributes for the
         * object. 'isRange' attribute would be set to false.
         *
         * This method does not return any value.
         */
        public StatusCodeMetadata(VCC_Endpoint_Status_Code__mdt range, Integer statusCode) {
            this.statusCode = statusCode;
            this.isRange = false;
        }
        /**
         * @description default empty constructor
         */
        public StatusCodeMetadata() {
            //System.debug( LoggingLevel.INFO, 'Empty constructor.' );
        }
    }
    /**
     * @description Method to get the endpoint based on the application name and service name
     * @param appName - The name of the application
     * @param serviceName - The name of the service
     * @return Sting - Returns the endpoint corresponding to the application and service name.
     */
    public static String getEndpoint(String appName, String serviceName) {
        return VCC_EndpointUtility.getEndpoint(appName, serviceName);
    }
    /**
     * @description class
     * Custom exception for endpoint status code issues
     */
    class EndpointStatusCodeException extends Exception {
    }
    /**
     * @description EndpointServiceException class
     * Custom exception for endpoint service issues
     */
    class EndpointServiceException extends Exception {
    }
}
