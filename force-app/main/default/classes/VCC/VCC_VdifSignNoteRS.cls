public with sharing class VCC_VdifSignNoteRS extends VCC_BaseClient.BaseResponse {
    public VCC_VdifRSCommon.TextTO signNoteTextTO;

    public VCC_VdifSignNoteRS() {
        this.signNoteTextTO = new VCC_VdifRSCommon.TextTO();
    }

    public VCC_VdifSignNoteRS(VCC_BaseClient.BaseResponse baseResponse) {
        super(baseResponse);
        if (baseResponse?.httpResponse != null) {
            this.signNoteTextTO = ((VCC_VdifSignNoteRS) JSON.deserialize(baseResponse.httpResponse.getBody().replace('"textTO"', '"signNoteTextTO"'), VCC_VdifSignNoteRS.class))
                .signNoteTextTO;
        }
    }
}
