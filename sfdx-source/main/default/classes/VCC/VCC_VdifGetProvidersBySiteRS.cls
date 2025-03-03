/**
 * @description Get Providerrs By Site RS object definitions
 *
 * @author Libety
 * @since 01/07/2024
 */
@SuppressWarnings('PMD.ClassNamingConventions')
public with sharing class VCC_VdifGetProvidersBySiteRS extends VCC_BaseClient.BaseResponse {
    public TaggedProviderArray taggedProviderArray;

    /**
     * @description Tagged Provider Array object definition
     */
    public class TaggedProviderArray {
        public VCC_VdifRSCommon.FaultTO fault;
        public Long count;
        public String tag;
        public ArrayOfProviderTO providers;

        /**
         * @description default constructor
         */
        public TaggedProviderArray() {
            this.fault = new VCC_VdifRSCommon.FaultTO();
            this.providers = new ArrayOfProviderTO();
        }
    }

    /**
     * @description Provider Array object
     */
    public class ArrayOfProviderTO {
        public List<ProviderTO> providerTO;

        /**
         * @description default constructor
         */
        public ArrayOfProviderTO() {
            this.providerTO = new List<ProviderTO>();
        }
    }

    /**
     * @description ProviderTO object
     */
    public class ProviderTO {
        public VCC_VdifRSCommon.FaultTO fault;
        public String duz;
        public String providername;
        public String providertitle;
        public String loginSiteCode;

        /**
         * @description default constructor
         */
        public ProviderTO() {
            this.fault = new VCC_VdifRSCommon.FaultTO();
        }
    }

    /**
     * @description default constructor
     */
    public VCC_VdifGetProvidersBySiteRS() {
        this.taggedProviderArray = new TaggedProviderArray();
    }

    /**
     * @description Constructory with baseResponse as argument
     *
     * @param baseResponse
     */
    public VCC_VdifGetProvidersBySiteRS(VCC_BaseClient.BaseResponse baseResponse) {
        super(baseResponse);
        if (baseResponse?.httpResponse != null) {
            this.taggedProviderArray = ((VCC_VdifGetProvidersBySiteRS) JSON.deserialize(baseResponse.httpResponse.getBody(), VCC_VdifGetProvidersBySiteRS.class))
                .taggedProviderArray;
        }
    }
}
