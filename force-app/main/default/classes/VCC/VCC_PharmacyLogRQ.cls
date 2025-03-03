public class VCC_PharmacyLogRQ extends VCC_DivaRequest {
    public String facilityId;
    public String prescriptionId;

    public Boolean isValid() {
        return !string.isBlank(this.facilityId) && !string.isBlank(this.prescriptionId);
    }

    public VCC_PharmacyLogRQ(String facilityId, String prescriptionId) {
        this.facilityId = facilityId;
        this.prescriptionId = prescriptionId;
    }

    public VCC_PharmacyLogRQ(Map<String, Object> jsObject) {
        this.facilityId = String.valueOf(jsObject.get('facilityId'))?.substring(0, 3);
        this.prescriptionId = String.valueOf(jsObject.get('prescriptionId'));
    }
}
