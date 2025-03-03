public with sharing class VCC_BridgAllergyRQ extends VCC_BaseRQ {
    public String assigningAuthority { get; set; }
    public String nationalId { get; set; }
    public String assigningFacility { get; set; }
    public String ien { get; set; }

    public override Boolean isValid() {
        Boolean valid = false;

        if (!String.isBlank(this.assigningAuthority) && !String.isBlank(this.nationalId)) {
            valid = true;
        }

        return valid;
    }

    public VCC_BridgAllergyRQ(String nationalId, String assigningAuthority) {
        this.nationalId = nationalId;
        this.assigningAuthority = assigningAuthority;
    }

    public VCC_BridgAllergyRQ(Map<String, Object> params) {
        this.nationalId = (params.get('nationalId') == null) ? null : String.valueOf(params.get('nationalId'));
        this.ien = (params.get('ien') == null) ? null : String.valueOf(params.get('ien'));
        this.assigningAuthority = (params.get('assigningAuthority') == null) ? null : String.valueOf(params.get('assigningAuthority'));
        this.assigningFacility = (params.get('assigningFacility') == null) ? null : String.valueOf(params.get('assigningFacility'));
    }

    public VCC_BridgAllergyRQ() {
        System.debug(LoggingLevel.INFO, 'Empty constructor.');
    }
}
