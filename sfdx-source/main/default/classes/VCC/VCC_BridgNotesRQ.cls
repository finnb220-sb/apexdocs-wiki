public with sharing class VCC_BridgNotesRQ extends VCC_BaseRQ {
    public String nationalId; //ICN
    public String ien;
    public String assigningAuthority; //USVHA
    public String assigningFacility; //note: this does not filter based on site
    public String startDate { public get; public set; }
    public String stopDate { public get; public set; }
    public String max; //max number of notes ****PER SITE****
    public String uid;
    /**
     * category:
     * Progess Notes(PN), Consult Report(CR), Crisis Note(C), Clinical Warning(W), Allergy/Adverse Reaction(A),
     * Advance Directive(D), Discharge Summary(DS), Surgical Reports(SR), Clinical Procedures(CP), Laboratory Reports(LR),
     * or Radiology Report(RA)
     */
    public String category; //Enum: [ PN, CR, C, W, A, D, DS, SR, CP, LR, RA ]
    public String status; //Enum: [ completed, unsigned, all ]
    public String text; //Enum: [ 1, 0 ] 1 or 0, to include 'content' text of document.

    public override Boolean isValid() {
        Boolean valid = false;

        if (!String.isBlank(this.nationalId) && !String.isBlank(this.assigningAuthority)) {
            valid = true;
        }

        return valid;
    }

    public VCC_BridgNotesRQ(String nationalId, String assigningAuthority) {
        this.nationalId = nationalId;
        this.assigningAuthority = assigningAuthority;
    }

    public VCC_BridgNotesRQ(Map<String, Object> params) {
        this.nationalId = (params.get('nationalId') == null) ? null : String.valueOf(params.get('nationalId'));
        this.ien = (params.get('ien') == null) ? null : String.valueOf(params.get('ien'));
        this.assigningAuthority = (params.get('assigningAuthority') == null) ? null : String.valueOf(params.get('assigningAuthority'));
        this.assigningFacility = (params.get('assigningFacility') == null) ? null : String.valueOf(params.get('assigningFacility'));
        this.startDate = (params.get('startDate') == null) ? null : String.valueOf(params.get('startDate'));
        this.stopDate = (params.get('stopDate') == null) ? null : String.valueOf(params.get('stopDate'));
        this.max = (params.get('max') == null) ? null : String.valueOf(params.get('max'));
        this.uid = (params.get('uid') == null) ? null : String.valueOf(params.get('uid'));
        this.category = (params.get('category') == null) ? null : String.valueOf(params.get('category'));
        this.status = (params.get('status') == null) ? null : String.valueOf(params.get('status'));
        this.text = (params.get('text') == null) ? null : String.valueOf(params.get('text'));
    }

    public VCC_BridgNotesRQ() {
        System.debug(LoggingLevel.INFO, 'Empty constructor.');
    }

    public VCC_BridgNotesRQ(String nationalId, String assigningAuthority, Integer months) {
        this.nationalId = nationalId;
        this.assigningAuthority = assigningAuthority;
        this.startDate = System.now().addMonths(-months).format('yyyy-MM-dd');
        this.stopDate = System.now().format('yyyy-MM-dd');
    }
}
