/**
 * @description Nebula wrapper that adds the "VDIF" tag automatically
 * @author Booz Allen Hamilton
 * @see VCC_NebulaWrapper
 * @see VCC_NebulaWrapperWithTags
 */
public inherited sharing class VCC_VdifLogger extends VCC_NebulaWrapperWithTags {
    @TestVisible
    private static final String VDIF_LOGGER_TAG = System.Label.VCC_VDIF_LoggerTag;

    /**
     * @description Constructor. Instantiates the parent class with the "VDIF" tag.
     */
    public VCC_VdifLogger() {
        super(new Set<String>{ VDIF_LOGGER_TAG });
    }
}
