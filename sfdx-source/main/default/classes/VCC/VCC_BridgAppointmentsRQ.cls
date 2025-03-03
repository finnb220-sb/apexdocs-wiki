public with sharing class VCC_BridgAppointmentsRQ extends VCC_BaseRQ {
    public String nationalId;
    public String ien;
    public String assigningAuthority;
    public String assigningFacility;
    public String startDate { public get; private set; }
    public String endDate { public get; public set; }

    public override Boolean isValid() {
        Boolean valid = false;

        if (!String.isBlank(this.assigningAuthority) && !String.isBlank(this.nationalId)) {
            valid = true;
        }

        return valid;
    }

    public VCC_BridgAppointmentsRQ(String nationalId, String assigningAuthority) {
        this.nationalId = nationalId;
        this.assigningAuthority = assigningAuthority;
    }

    public VCC_BridgAppointmentsRQ(Map<String, Object> params) {
        this.nationalId = (params.get('nationalId') == null) ? null : String.valueOf(params.get('nationalId'));
        this.ien = (params.get('ien') == null) ? null : String.valueOf(params.get('ien'));
        this.assigningAuthority = (params.get('assigningAuthority') == null) ? null : String.valueOf(params.get('assigningAuthority'));
        this.assigningFacility = (params.get('assigningFacility') == null) ? null : String.valueOf(params.get('assigningFacility'));
        this.startDate = (params.get('startDate') == null) ? null : String.valueOf(params.get('startDate'));
        this.endDate = (params.get('endDate') == null) ? null : String.valueOf(params.get('endDate'));
    }

    public VCC_BridgAppointmentsRQ() {
        System.debug(LoggingLevel.INFO, 'Empty constructor.');
    }

    public VCC_BridgAppointmentsRQ(String nationalId, String assigningAuthority, Integer months) {
        this.nationalId = nationalId;
        this.assigningAuthority = assigningAuthority;
        this.startDate = System.now().addMonths(-months).format('yyyy-MM-dd');
        this.endDate = System.now().addYears(25).format('yyyy-MM-dd');
    }
}
