public with sharing class VCC_VdifWriteNoteRS extends VCC_BaseClient.BaseResponse {
    public NoteResultTO noteResultTO;

    public class NoteResultTO {
        public VCC_VdifRSCommon.FaultTO fault;
        public String id;
        public Long totalPages;
        public Long lastPageRecd;
        public String explanation;

        public NoteResultTO() {
            this.fault = new VCC_VdifRSCommon.FaultTO();
        }
    }

    public VCC_VdifWriteNoteRS() {
        this.noteResultTO = new NoteResultTO();
    }

    public VCC_VdifWriteNoteRS(VCC_BaseClient.BaseResponse baseResponse) {
        super(baseResponse);
        if (baseResponse?.httpResponse != null) {
            this.noteResultTO = ((VCC_VdifWriteNoteRS) JSON.deserialize(baseResponse.httpResponse.getBody(), VCC_VdifWriteNoteRS.class)).noteResultTO;
        }
    }
}
