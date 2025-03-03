public with sharing class VCC_BridgVitalsRS extends VCC_BaseClient.BaseResponse {
    public List<VitalsSite> sites;

    public class VitalsSite {
        public VitalsResults results;
        public VCC_BridgRSCommon.FpdsErrorSection errorSection;
        public Boolean isMaxRecordsError;

        public VitalsSite() {
            this.results = new VitalsResults();
            this.errorSection = new VCC_BridgRSCommon.FpdsErrorSection();
            this.isMaxRecordsError = false;
        }
    }

    public class VitalsResults {
        public String timeZone;
        public VitalsVitals vitals;
        public String version;

        public VitalsResults() {
            this.vitals = new VitalsVitals();
        }
    }

    public class VitalsVitals {
        public String total;
        public List<VitalsVital> vital;

        public VitalsVitals() {
            this.vital = new List<VitalsVital>();
        }
    }

    public class VitalsVital {
        public VitalsEntered entered;
        public VitalsLocation location;
        public VitalsTaken taken;
        public VitalsFacility facility;
        public VitalsMeasurements measurements;
        public List<VitalsRemoved> removed;

        public VitalsVital() {
            this.entered = new VitalsEntered();
            this.location = new VitalsLocation();
            this.taken = new VitalsTaken();
            this.facility = new VitalsFacility();
            this.measurements = new VitalsMeasurements();
            this.removed = new List<VitalsRemoved>();
        }
    }

    public class VitalsEntered {
        public String value;
    }
    public class VitalsLocation {
        public String code;
        public String name;
    }
    public class VitalsTaken {
        public String value;
    }
    public class VitalsFacility {
        public String code;
        public String name;
    }
    public class VitalsMeasurements {
        public List<VitalsMeasurement> measurement;

        public VitalsMeasurements() {
            this.measurement = new List<VitalsMeasurement>();
        }
    }
    public class VitalsRemoved {
        public String value; //enum [ INCORRECT DATE/TIME, INCORRECT READING, INCORRECT PATIENT, INVALID RECORD ]
    }

    public class VitalsMeasurement {
        public String high;
        public String low;
        public String name;
        public String id;
        public String units;
        public String vuid;
        public String value;
        public String metricValue;
        public String metricUnits;
        public String bmi;
        public VitalsQualifiers qualifiers;

        public VitalsMeasurement() {
            this.qualifiers = new VitalsQualifiers();
        }
    }

    public class VitalsQualifiers {
        public List<VitalsQualifier> qualifier;

        public VitalsQualifiers() {
            this.qualifier = new List<VitalsQualifier>();
        }
    }

    public class VitalsQualifier {
        public String name;
        public String vuid;
    }

    public VCC_BridgVitalsRS() {
        this.sites = new List<VitalsSite>();
    }

    public VCC_BridgVitalsRS(VCC_BaseClient.BaseResponse baseResponse) {
        super(baseResponse);
        try {
            this.sites = ((VCC_BridgVitalsRS) JSON.deserialize(baseResponse.httpResponse.getBody().replace('"exception"', '"exception_s"'), VCC_BridgVitalsRS.class)).sites;

            if (baseResponse.httpResponse.getBody().contains('errorSection')) {
                this.sites[0].isMaxRecordsError = true;
            }
        } catch (Exception e) {
            this.exceptions.add(e);
        }
    }
}
