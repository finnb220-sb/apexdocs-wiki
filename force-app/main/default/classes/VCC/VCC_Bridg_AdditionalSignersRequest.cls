public with sharing class VCC_Bridg_AdditionalSignersRequest {
    public string nationalId;
    public string assigningAuthority = 'USVHA';
    public string assigningFacility;
    public List<String> documents;

    public VCC_Bridg_AdditionalSignersRequest(Map<String, Object> params) {
        this.nationalId = (params.get('id') == null) ? null : String.valueOf(params.get('id'));
        // this.assigningAuthority = (params.get('assigningAuthority') == null) ? null : String.valueOf(params.get('assigningAuthority'));
        this.assigningFacility = (params.get('assigningFacility') == null) ? null : String.valueOf(params.get('assigningFacility'));
        this.documents = (List<String>) JSON.deserialize(JSON.serialize(params.get('documents')), List<String>.class);
    }
}
