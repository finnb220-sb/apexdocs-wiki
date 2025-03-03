public with sharing class VCC_BridgVitalsRQ extends VCC_BaseRQ {
    public String nationalId;
    public String ien;
    public String assigningAuthority;
    public String assigningFacility;
    public String startDate { public get; private set; }
    public String stopDate { public get; private set; }
    public String max;

    public override Boolean isValid() {
        Boolean valid = false;

        if (!String.isBlank(this.nationalId) && !String.isBlank(this.assigningAuthority)) {
            valid = true;
        }

        return valid;
    }

    public VCC_BridgVitalsRQ(String nationalId, String assigningAuthority) {
        this.nationalId = nationalId;
        this.assigningAuthority = assigningAuthority;
    }

    public VCC_BridgVitalsRQ(Map<String, Object> params) {
        this.nationalId = (params.get('nationalId') == null) ? null : String.valueOf(params.get('nationalId'));
        this.ien = (params.get('ien') == null) ? null : String.valueOf(params.get('ien'));
        this.assigningAuthority = (params.get('assigningAuthority') == null) ? null : String.valueOf(params.get('assigningAuthority'));
        this.assigningFacility = (params.get('assigningFacility') == null) ? null : String.valueOf(params.get('assigningFacility'));
        this.startDate = (params.get('startDate') == null) ? null : String.valueOf(params.get('startDate'));
        this.stopDate = (params.get('stopDate') == null) ? null : String.valueOf(params.get('stopDate'));
        this.max = (params.get('max') == null) ? null : String.valueOf(params.get('max'));
    }

    public VCC_BridgVitalsRQ() {
        System.debug(LoggingLevel.INFO, 'Empty constructor.');
    }

    public VCC_BridgVitalsRQ(String nationalId, String assigningAuthority, Integer months) {
        this.nationalId = nationalId;
        this.assigningAuthority = assigningAuthority;
        this.startDate = System.now().addMonths(-months).format('yyyy-MM-dd');
        this.stopDate = System.now().format('yyyy-MM-dd');
    }
}
