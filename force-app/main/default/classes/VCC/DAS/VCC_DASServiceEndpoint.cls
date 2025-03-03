/**
 * @author Booz Allen Hamilton
 * @description Leverages VCC_EndpointUtility to generate and endpoint string for other VCC_DASServices (primarily VCC_DASServiceApi).
 */
public with sharing class VCC_DASServiceEndpoint {
    @TestVisible
    private final String APP_NAME = System.Label.VCC_DAS_EndpointService_APP_NAME;

    @TestVisible
    private final String UNMAPPED_ENDPOINT = System.Label.VCC_DAS_EndpointService_UNMAPPED_ENDPOINT;

    @TestVisible
    private final String BAD_CONFIGURATION = System.Label.VCC_DAS_EndpointService_BAD_CONFIGURATION;

    @TestVisible
    private final Map<VCC_DAS.Endpoint, String> endpointToServiceNameMap = new Map<VCC_DAS.Endpoint, String>{
        VCC_DAS.Endpoint.IS_VALID_ESIG => APP_NAME + '_isValidEsig',
        VCC_DAS.Endpoint.SELECT_PATIENT => APP_NAME + '_selectPatient',
        VCC_DAS.Endpoint.WRITE_NOTE => APP_NAME + '_writeNote',
        VCC_DAS.Endpoint.SIGN_NOTE => APP_NAME + '_signNote',
        VCC_DAS.Endpoint.GET_ADDITIONAL_SIGNERS => APP_NAME + '_getAdditionalSigners',
        VCC_DAS.Endpoint.CREATE_ADDENDUM => APP_NAME + '_createAddendum',
        VCC_DAS.Endpoint.SAVE_NOTE_AND_ENCOUNTER => APP_NAME + '_saveNoteAndEncounter',
        VCC_DAS.Endpoint.WRITE_NOTE_AND_SIGN => APP_NAME + '_writeNoteAndSign',
        VCC_DAS.Endpoint.CREATE_ADDENDUM_AND_SIGN => APP_NAME + '_createAddendumAndSign'
    };

    /**
     * @description Gets the endpoint string for a callout.
     * @param endpoint A `VCC_DAS.Endpoint` value.
     * @return A `String` named credential.
     */
    public String getEndpoint(VCC_DAS.Endpoint endpoint) {
        VCC_DAS.SERVICES.LOGGER.debug((endpoint == null) ? 'endpoint is null' : endpoint.name());

        String serviceName = endpointToServiceNameMap.get(endpoint);
        if (serviceName == null) {
            throw new UnmappedEndpointException(UNMAPPED_ENDPOINT);
        }

        String endpointString;
        try {
            endpointString = VCC_EndpointUtility.getEndpoint(APP_NAME, serviceName);
        } catch (Exception e) {
            throw new BadConfigurationException(BAD_CONFIGURATION);
        }

        return endpointString;
    }

    public class UnmappedEndpointException extends VCC_DASException {
    }
    public class BadConfigurationException extends VCC_DASException {
    }
}
