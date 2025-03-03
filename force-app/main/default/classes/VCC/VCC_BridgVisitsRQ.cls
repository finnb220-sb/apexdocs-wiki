public with sharing class VCC_BridgVisitsRQ extends VCC_BaseRQ {
    public String nationalId { get; set; }
    public String ien { get; set; }
    public String assigningFacility { get; set; }
    public String assigningAuthority { get; set; }
    public String startDate { public get; public set; }
    public String stopDate { public get; public set; }
    public String max { get; set; }
    public String uid { get; set; }

    public override Boolean isValid() {
        Boolean valid = false;

        if (!String.isBlank(this.nationalId) && !String.isBlank(this.assigningAuthority)) {
            valid = true;
        }

        return valid;
    }

    public VCC_BridgVisitsRQ(String nationalId, String assigningAuthority) {
        this.nationalId = nationalId;
        this.assigningAuthority = assigningAuthority;
    }

    public VCC_BridgVisitsRQ(Map<String, Object> params) {
        this.nationalId = (params.get('nationalId') == null) ? null : String.valueOf(params.get('nationalId'));
        this.ien = (params.get('ien') == null) ? null : String.valueOf(params.get('ien'));
        this.assigningAuthority = (params.get('assigningAuthority') == null) ? null : String.valueOf(params.get('assigningAuthority'));
        this.assigningFacility = (params.get('assigningFacility') == null) ? null : String.valueOf(params.get('assigningFacility'));
        this.startDate = (params.get('startDate') == null) ? null : String.valueOf(params.get('startDate'));
        this.stopDate = (params.get('stopDate') == null) ? null : String.valueOf(params.get('stopDate'));
        this.max = (params.get('max') == null) ? null : String.valueOf(params.get('max'));
        this.uid = (params.get('uid') == null) ? null : String.valueOf(params.get('uid'));
    }

    public VCC_BridgVisitsRQ() {
        System.debug(LoggingLevel.INFO, 'Default constructor.');
    }

    public VCC_BridgVisitsRQ(String nationalId, String assigningAuthority, Integer months) {
        this.nationalId = nationalId;
        this.assigningAuthority = assigningAuthority;
        this.startDate = System.now().addMonths(-months).format('yyyy-MM-dd');
        this.stopDate = System.now().format('yyyy-MM-dd');
    }
}
