public class VCC_ActivityLogRQ extends VCC_DivaRequest {
    public String facilityId;
    public String prescriptionId;

    public VCC_ActivityLogRQ(String facilityId, String prescriptionId) {
        this.facilityId = facilityId;
        this.prescriptionId = prescriptionId;
    }

    public static VCC_ActivityLogRQ parse(String req) {
        return (VCC_ActivityLogRQ) JSON.deserialize(req, VCC_ActivityLogRQ.class);
    }
}
