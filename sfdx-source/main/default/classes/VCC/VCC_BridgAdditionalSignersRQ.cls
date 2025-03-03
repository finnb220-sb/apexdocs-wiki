/**
 * @description Bridg AdditionalSigners Request Object
 * @author      Booz Allen
 */
public with sharing class VCC_BridgAdditionalSignersRQ extends VCC_BaseRQ {
    public String nationalId { get; set; }
    public String assigningAuthority { get; set; }
    public String assigningFacility { get; set; }
    public List<String> documents { get; set; }

    /**
     * @description - constructor for the class
     */
    public class VCC_AdditionalSignersBridgException extends Exception {
    }

    /**
     * @description method to return whether national ID is valid
     * @return      `Boolean` returns true if national ID is not blank
     */
    public override Boolean isValid() {
        return !String.isBlank(this.nationalId);
    }

    /**
     * @description overloaded method taking in two strings for callout
     * @param nationalId the national id
     * @param assigningAuthority the assigning authority
     */
    public VCC_BridgAdditionalSignersRQ(String nationalId, String assigningAuthority) {
        this.nationalId = nationalId;
        this.assigningAuthority = assigningAuthority;
    }

    /**
     * @description overloaded method taking in map for callout
     * @param params the param map for the callout
     */
    public VCC_BridgAdditionalSignersRQ(Map<String, Object> params) {
        this.nationalId = (params.get('nationalId') == null) ? null : String.valueOf(params.get('nationalId'));

        this.assigningAuthority = (params.get('assigningAuthority') == null)
            ? null
            : String.valueOf(params.get('assigningAuthority'));
        this.assigningFacility = (params.get('assigningFacility') == null)
            ? null
            : String.valueOf(params.get('assigningFacility'));
        // this.documents = (params.get('documents') == null) ? null : (List<String>) params.get('documents');
        // making a roundtrip
        this.documents = (List<String>) JSON.deserialize(JSON.serialize(params.get('documents')), List<String>.class);
        // throw new VCC_AdditionalSignersBridgException(String.valueOf(preParseDocs.get(0)));
    }

    /**
     * @description empty constructor
     */
    public VCC_BridgAdditionalSignersRQ() {
        Logger.error('Constructor was called with no params.');
        Logger.saveLog();
    }
}
