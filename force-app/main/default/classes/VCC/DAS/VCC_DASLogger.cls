/**
 * @description Nebula wrapper that adds the "DAS" tag automatically
 * @author Booz Allen Hamilton
 * @see VCC_NebulaWrapperWithTags
 * @see VCC_NebulaWrapper
 */
public inherited sharing class VCC_DASLogger extends VCC_NebulaWrapperWithTags {
    @TestVisible
    private static final String DAS_LOGGER_TAG = System.Label.VCC_DAS_EndpointService_VCC_DAS_LOGGER_TAG;

    /**
     * @description Constructor. Instantiates the parent class with the "DAS" tag.
     */
    public VCC_DASLogger() {
        super(new Set<String>{ DAS_LOGGER_TAG });
    }
}
