/**
 * @description VCC Bridg Labs RQ
 **/

@SuppressWarnings('PMD.ApexDoc')
public with sharing class VCC_BridgLabsRQ extends VCC_BaseRQ {
    public String nationalId { get; set; }
    public String ien { get; set; }
    public String assigningAuthority { get; set; }
    public String assigningFacility { get; set; }
    public String startDate { public get; private set; }
    public String stopDate { public get; private set; }
    public String max { get; set; }
    public String type { get; set; } //type of lab - format example (CH=Chemistry, MI=Microbiology): "CH,MI"

    public override Boolean isValid() {
        Boolean valid = false;

        if (!String.isBlank(this.nationalId) && !String.isBlank(this.assigningAuthority)) {
            valid = true;
        }

        return valid;
    }

    @TestVisible
    private VCC_BridgLabsRQ() {
        this.startDate = System.now().addMonths(-12).format('yyyy-MM-dd');
        this.stopDate = System.now().format('yyyy-MM-dd');
    }

    //Todo: This ctor should be removed
    public VCC_BridgLabsRQ(String nationalId, String assigningAuthority) {
        this.nationalId = nationalId;
        this.assigningAuthority = assigningAuthority;
        this.startDate = System.now().addMonths(-12).format('yyyy-MM-dd');
        this.stopDate = System.now().format('yyyy-MM-dd');
    }

    public VCC_BridgLabsRQ(String nationalId, String assigningAuthority, Integer months) {
        this.nationalId = nationalId;
        this.assigningAuthority = assigningAuthority;
        this.startDate = System.now().addMonths(-months).format('yyyy-MM-dd');
        this.stopDate = System.now().format('yyyy-MM-dd');
    }
}
