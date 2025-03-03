/**
 * @description Request class for DAS writeNoteAndSign request
 * @author      BAH
 * @since       April 15 2024
 * @see         VCC_DASBaseRQ
 * @see         VCC_DASConsolidatedEndpointBaseRQ
 * @see         VCC_DASWriteNoteAndSignRQTest
 */
@SuppressWarnings('PMD.DescriptionMustHaveText, PMD.ApexDoc')
public with sharing class VCC_DASWriteNoteAndSignRQ extends VCC_DASConsolidatedEndpointBaseRQ {
    /**
     * @description Used to call or stub VCC_SignersService
     */
    @TestVisible
    private static VCC_SignersService signersService {
        get {
            return signersService = signersService ?? VCC_SignersService.instance;
        }
        private set;
    }

    /**
     * @description Used to call or stub VCC_DASServiceParser
     */
    @TestVisible
    private static VCC_DASServiceParser parserService {
        get {
            return parserService = parserService ?? VCC_DAS.SERVICES.PARSER;
        }
        private set;
    }

    /**
     * @description Used to call or stub VCC_DASServiceUtilities
     */
    @TestVisible
    private static VCC_DASServiceUtilities utilitiesService {
        get {
            return utilitiesService = utilitiesService ?? VCC_DAS.SERVICES.UTILITIES;
        }
        private set;
    }

    public String titleIEN {
        get {
            return propertyGetter(titleIEN);
        }
        set;
    }

    public String encounterString {
        get {
            return propertyGetter(encounterString);
        }
        set;
    }

    public String text {
        get {
            return propertyGetter(text);
        }
        set;
    }

    public String authorDUZ {
        get {
            return propertyGetter(authorDUZ);
        }
        set;
    }

    public String cosignerDUZ {
        get {
            return propertyGetter(cosignerDUZ);
        }
        set;
    }

    public String patientLocalPid {
        get {
            return propertyGetter(patientLocalPid);
        }
        set;
    }

    public String patientLocalSiteId {
        get {
            return propertyGetter(patientLocalSiteId);
        }
        set;
    }

    public String patientName {
        get {
            return propertyGetter(patientName);
        }
        set;
    }

    /**
     * @description Constructor
     */
    public VCC_DASWriteNoteAndSignRQ() {
        return;
    }

    /**
     * @description     Constructor called in VCC_DASFlowWriteNoteAndSign to map flow variables to the request properties.
     * @param flowRequest `VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest`
     */
    public VCC_DASWriteNoteAndSignRQ(VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest flowRequest) {
        this.titleIEN = flowRequest?.titleIEN;
        this.encounterString = flowRequest?.encounterString;
        this.cosignerDUZ = flowRequest?.cosignerDUZ;
        this.providerLoginSiteCode = flowRequest?.providerLoginSiteCode;
        this.providerUserId = flowRequest?.providerUserId;
        if (flowRequest?.patientLocalPid != null) {
            this.patientLocalPid = flowRequest.patientLocalPid.replace(',', '');
        }
        this.patientLocalSiteId = flowRequest?.patientLocalSiteId;
        this.esig = flowRequest?.esig;
        this.providerName = flowRequest?.providerName;
        this.patientName = flowRequest?.patientName;
        if (flowRequest?.recordId != null) {
            this.supplementalParameters = signersService.getSignerDuzListForCallout(flowRequest?.recordId);
        }
        if (flowRequest.progressNote != null) {
            this.text = parserService.parse((SObject) flowRequest?.progressNote);
        }
        if (flowRequest?.patientLocalSiteId != null) {
            this.authorDUZ = utilitiesService.getProviderDuz(UserInfo.getUserId(), flowRequest?.patientLocalSiteId);
        }
    }

    /**
     * @description Used to determine if the request is valid (properties are not null or blank) for callout
     * @return  `Boolean` Returns true if note properties are not blank
     */
    public override Boolean isValid() {
        if (super.isValid() && isNoteInfoValid()) {
            return true;
        }
        return false;
    }

    private Boolean isNoteInfoValid() {
        if (
            !String.isBlank(this.titleIEN) &&
            !String.isBlank(this.encounterString) &&
            !String.isBlank(this.text) &&
            !String.isBlank(this.authorDUZ) &&
            !String.isBlank(this.patientLocalPid) &&
            !String.isBlank(this.patientLocalSiteId)
        ) {
            return true;
        }
        return false;
    }
}
