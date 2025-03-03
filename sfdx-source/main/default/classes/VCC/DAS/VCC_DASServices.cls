/**
 * @description DAS Services
 * Must be stubbable: https://developer.salesforce.com/docs/atlas.en-us.244.0.apexcode.meta/apexcode/apex_testing_stub_api.htm
 */
public with sharing class VCC_DASServices {
    /** API Service */

    public final VCC_DASServiceApi API {
        public get {
            if (apiService != null) {
                return apiService;
            }
            apiService = new VCC_DASServiceApi();
            return apiService;
        }
    }

    @TestVisible
    private VCC_DASServiceApi apiService;

    /** ENCOUNTER Service */

    public final VCC_DASServiceEncounter ENCOUNTER {
        public get {
            if (encounterService != null) {
                return encounterService;
            }
            encounterService = new VCC_DASServiceEncounter();
            return encounterService;
        }
    }

    @TestVisible
    private VCC_DASServiceEncounter encounterService;

    /** ENDPOINT Service */

    public final VCC_DASServiceEndpoint ENDPOINT {
        public get {
            if (endpointService != null) {
                return endpointService;
            }
            endpointService = new VCC_DASServiceEndpoint();
            return endpointService;
        }
    }

    @TestVisible
    private VCC_DASServiceEndpoint endpointService;

    /** HTTP Service */

    public final VCC_DASServiceHttp HTTP {
        public get {
            if (httpService != null) {
                return httpService;
            }
            httpService = new VCC_DASServiceHttp();
            return httpService;
        }
    }

    @TestVisible
    private VCC_DASServiceHttp httpService;

    /** LOGGER Service */

    public final VCC_DASServiceLogger LOGGER {
        public get {
            if (loggerService != null) {
                return loggerService;
            }
            loggerService = new VCC_DASServiceLogger();
            return loggerService;
        }
    }

    @TestVisible
    private VCC_DASServiceLogger loggerService;

    /** METADATA Service */

    public final VCC_DASServiceMetadata METADATA {
        public get {
            if (metadataService != null) {
                return metadataService;
            }
            metadataService = new VCC_DASServiceMetadata();
            return metadataService;
        }
    }

    @TestVisible
    private VCC_DASServiceMetadata metadataService;

    /** PARSER Service */

    public final VCC_DASServiceParser PARSER {
        public get {
            if (parserService != null) {
                return parserService;
            }
            parserService = new VCC_DASServiceParser();
            return parserService;
        }
    }

    @TestVisible
    private VCC_DASServiceParser parserService;

    /** UTILITIES Service */

    public final VCC_DASServiceUtilities UTILITIES {
        public get {
            if (utilitiesService != null) {
                return utilitiesService;
            }
            utilitiesService = new VCC_DASServiceUtilities();
            return utilitiesService;
        }
    }

    @TestVisible
    private VCC_DASServiceUtilities utilitiesService;
}
