public with sharing class VCC_MpiRetrieveRQ {
    public String userId; // 'VAHC CRM', or first/last name;
    public String id; //identifier of veteran
    public String idType; // identifier type [ salesforceId, ICN, fileNumber, externalSystemId, corpId, rawId ]
    public Boolean unattended = true; //is this an automated search?
    public Boolean showCorrelated = false; //do you want correlated view?
    public List<String> datasets; //[ EE, VA_PROFILE, BGS ]

    public VCC_MpiRetrieveRQ() {
        this.datasets = new List<String>();
    }

    public Boolean isValid() {
        if (!String.isBlank(this.userId) && !String.isBlank(this.id) && !String.isBlank(this.idType) && this.showCorrelated != null) {
            return true;
        }
        return false;
    }
}
