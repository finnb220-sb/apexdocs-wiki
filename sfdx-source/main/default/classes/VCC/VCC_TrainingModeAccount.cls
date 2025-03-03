public with sharing class VCC_TrainingModeAccount {
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String mviExternalId { get; set; }
    public String SSN { get; set; }
    public String gender { get; set; }
    public Date birthDate { get; set; }
    public String email { get; set; }
    public List<VCC_TrainingModeData> relatedData { get; set; }

    public VCC_TrainingModeAccount() {
        this.relatedData = new List<VCC_TrainingModeData>();
    }

    public VCC_TrainingModeAccount(String firstName, String lastName, String healthCloudTaxId, String SSN, String gender, Date birthDate, String email) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.mviExternalId = healthCloudTaxId;
        this.SSN = SSN;
        this.gender = gender;
        this.birthDate = birthDate;
        this.email = email;
        this.relatedData = new List<VCC_TrainingModeData>();
    }
}
