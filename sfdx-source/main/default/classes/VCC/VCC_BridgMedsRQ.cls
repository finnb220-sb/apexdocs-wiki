public with sharing class VCC_BridgMedsRQ extends VCC_BaseRQ {
    public String nationalId;
    public String ien;
    public String assigningAuthority;
    public String assigningFacility;
    public String startDate { public get; public set; }
    public String stopDate { public get; public set; }
    public String vaType;

    public override Boolean isValid() {
        Boolean valid = false;

        if (!String.isBlank(this.nationalId) && !String.isBlank(this.assigningAuthority)) {
            valid = true;
        }

        return valid;
    }

    public VCC_BridgMedsRQ(String nationalId, String assigningAuthority) {
        this.nationalId = nationalId;
        this.assigningAuthority = assigningAuthority;
    }

    public VCC_BridgMedsRQ(Map<String, Object> params) {
        this.nationalId = (params.get('nationalId') == null) ? null : String.valueOf(params.get('nationalId'));
        this.ien = (params.get('ien') == null) ? null : String.valueOf(params.get('ien'));
        this.assigningAuthority = (params.get('assigningAuthority') == null) ? null : String.valueOf(params.get('assigningAuthority'));
        this.assigningFacility = (params.get('assigningFacility') == null) ? null : String.valueOf(params.get('assigningFacility'));
        this.startDate = (params.get('startDate') == null) ? null : String.valueOf(params.get('startDate'));
        this.stopDate = (params.get('stopDate') == null) ? null : String.valueOf(params.get('stopDate'));
        this.vaType = (params.get('vaType') == null) ? null : String.valueOf(params.get('vaType'));
    }

    public VCC_BridgMedsRQ() {
        System.debug(LoggingLevel.INFO, 'Empty constructor.');
    }

    public VCC_BridgMedsRQ(String nationalId, String assigningAuthority, Integer months) {
        this.nationalId = nationalId;
        this.assigningAuthority = assigningAuthority;
        this.startDate = System.now().addMonths(-months).format('yyyy-MM-dd');
        this.stopDate = System.now().format('yyyy-MM-dd');
    }
    /**
     * @description constructor for VCC_MedsListCOntroller.getMedsWithParams
     * @param nationalId string holding patient nationalId/ICN Number
     * @param startDate string Medication StartDate formatted  yyyy-mm-dd
     * @param assigningAuthority string Assigning authority
     */
    public VCC_BridgMedsRQ(String nationalId, String startDate, String assigningAuthority) {
        this.nationalId = nationalId;
        this.startDate = startDate;
        this.assigningAuthority = assigningAuthority;
    }
}
