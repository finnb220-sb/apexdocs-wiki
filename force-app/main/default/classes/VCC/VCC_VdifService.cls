/**
 * @description Calls made through this class are validated against preconfigured callouts.
 * @author Patrick Skamarak
 * @since 8/4/2021
 * @group API - VDIF
 * @see VCC_ProgressNoteController
 */
public with sharing class VCC_VdifService {
    @TestVisible
    private static final String VDIF_MISSING_OR_INVALID_FIELD_MESSAGE = 'The following required fields are missing or invalid: ';
    private static final String VDIF_SERVICE_EXCEPTION_MESSAGE = 'The provided VDIF service name has not been configured yet.';
    @TestVisible
    private static final Map<String, Set<String>> REQUIRED_FIELDS_MAP = new Map<String, Set<String>>{
        'vccVdifWriteNote' => new Set<String>{ 'encounterString', 'text', 'providerName', 'providerLoginSiteCode', 'providerUserId', 'patientLocalPid', 'titleIEN' },
        'vccVdifSaveNoteAndEncounter' => new Set<String>{
            'providerLoginSiteCode',
            'providerUserId',
            'patientLocalPid',
            'patientLocalSiteId',
            'noteAndEncounterLocationIen',
            'noteAndEncounterNoteTitleIen',
            'noteAndEncounterServiceCategory',
            'noteAndEncounterProcedures',
            'noteAndEncounterDiagnoses'
        },
        'vccVdifSignNote' => new Set<String>{ 'esig', 'providerLoginSiteCode', 'providerName', 'providerUserId', 'noteIEN', 'userDUZ' },
        'vccVdifGetAdditionalSigners' => new Set<String>{ 'providerName', 'providerUserId', 'providerLoginSiteCode', 'itemId', 'supplementalParameters' },
        'vccVdifIsValidEsig' => new Set<String>{ 'providerLoginSiteCode', 'providerName', 'providerUserId', 'criteria' },
        'vccVdifGetProvidersBySite' => new Set<String>{ 'target', 'providerUserId', 'providerLoginSiteCode', 'maxRecords', 'direction', 'providerName' },
        'vccVdifCreateAddendum' => new Set<String>{ 'itemId', 'type', 'criteria', 'providerLoginSiteCode', 'providerUserId' },
        'vccVdifSelectPatient' => new Set<String>{ 'providerLoginSiteCode', 'providerName', 'providerUserId', 'patientLocalPid', 'patientLocalSiteId' }
    };

    @TestVisible
    private class VdifHttpRequest {
        private HttpRequest req = new HttpRequest();
        private Set<String> requiredFields;
        String body;

        /**
         * @description Constructor
         * @param serviceName
         */
        public VdifHttpRequest(String serviceName) {
            this.requiredFields = REQUIRED_FIELDS_MAP.get(serviceName);
            if (this.requiredFields == null) {
                throw new ServiceNotConfiguredException(VDIF_SERVICE_EXCEPTION_MESSAGE);
            }

            req.setEndpoint(VCC_EndpointUtility.getEndpoint('Vdif', serviceName));
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            req.setHeader('clientid', '{!$Credential.UserName}');
            req.setHeader('clientSecret', '{!$Credential.Password}');
            req.setTimeout(120000);
        }

        /**
         * @description Sets the body of the request
         * @param body
         */
        public void setBody(Map<String, Object> body) {
            if (validateRequestBody(body)) {
                this.body = JSON.serialize(body);
                req.setBody(this.body);
            }
        }

        private Boolean validateRequestBody(Map<String, Object> body) {
            Boolean containsMissingOrInvalidFields = false;
            Set<String> invalidOrMissingFields = new Set<String>();
            Set<String> bodyFields = body.keySet();

            for (String field : this.requiredFields) {
                if (!bodyFields.contains(field)) {
                    invalidOrMissingFields.add(field);
                    containsMissingOrInvalidFields = true;
                }
            }

            if (containsMissingOrInvalidFields) {
                throw new MissingOrInvalidParameterException(VDIF_MISSING_OR_INVALID_FIELD_MESSAGE + String.join(new List<String>(invalidOrMissingFields), ', '));
            }
            return (!containsMissingOrInvalidFields);
        }

        public HttpResponse send() {
            if (this.body != null) {
                return (new Http()).send(this.req);
            }
            return null;
        }
    }

    /**
     * @description
     * @param serviceName
     * @param body
     *
     * @return VCC_VDIFResponseParser
     */
    public static VCC_VDIFResponseParser callService(String serviceName, Map<String, Object> body) {
        for (String key : body.keySet()) {
            System.debug(LoggingLevel.INFO, key + ' : ' + body.get(key));
        }
        VdifHttpRequest req = new VdifHttpRequest(serviceName);
        req.setBody(body);

        HttpResponse res = req.send();

        VCC_VDIFResponseParser vdifResponse;

        vdifResponse = (VCC_VDIFResponseParser) JSON.deserialize(res.getBody().replace('"number":', '"phoneNum":').replace('"end":', '"endValue":'), VCC_VDIFResponseParser.class);

        System.debug(LoggingLevel.INFO, vdifResponse);

        if (vdifResponse.exceptionOccurred == true) {
            throw new VdifException(vdifResponse.exceptionMessage);
        }

        return vdifResponse;
    }

    @TestVisible
    private class MissingOrInvalidParameterException extends Exception {
    }
    @TestVisible
    private class ServiceNotConfiguredException extends Exception {
    }
    @TestVisible
    private class VdifException extends Exception {
    }
}
