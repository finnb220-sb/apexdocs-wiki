@SuppressWarnings('PMD.ExcessivePublicCount, PMD.TooManyFields')
public with sharing class VCC_MPISearchRequest {
    public String firstName;
    public String lastName;
    public String dob;
    public String ssn;
    private String userId = 'VACH CRM';
    private Boolean retrieveRelationships = false;
    public List<String> datasets = new List<String>{ 'VA_PROFILE' };

    public VCC_MPISearchRequest(Map<String, Object> params) {
        this.firstName = (String) params.get('firstName');
        this.lastName = (String) params.get('lastName');
        this.dob = (String) params.get('dob');
        this.ssn = (String) params.get('ssn');
    }
}
