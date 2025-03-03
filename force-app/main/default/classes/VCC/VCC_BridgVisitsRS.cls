public with sharing class VCC_BridgVisitsRS extends VCC_BaseClient.BaseResponse {
    public List<VisitSite> sites;
    public Boolean isMaxRecordsError;

    public class VisitSite {
        public String apiVersion;
        public VisitParams params;
        public VisitDataClass data;
        public VCC_BridgRSCommon.FpdsErrorSection errorSection;

        public VisitSite() {
            this.params = new VisitParams();
            this.data = new VisitDataClass();
            this.errorSection = new VCC_BridgRSCommon.FpdsErrorSection();
        }
    }

    public class VisitParams {
        public String domain;
        public String systemId;
    }

    public class VisitDataClass {
        public String updated;
        public String totalItems;
        public List<VisitItem> items;

        public VisitDataClass() {
            this.items = new List<VisitItem>();
        }
    }

    public class VisitItem {
        public String categoryCode;
        public String categoryName;
        public String dateTime_s;
        public List<VisitDocument> documents;
        public String facilityCode;
        public String facilityName;
        public String localId;
        public String locationName;
        public String locationUid;
        public String patientClassCode;
        public String patientClassName;
        public String stopCodeName;
        public String stopCodeUid;
        public String typeName;
        public String uid;
        public String current;
        public List<VisitProvider> providers;
        public String reasonName;
        public String service;
        public String specialty;
        public VisitStay stay;
        public String summary;
        public String checkOut;
        public List<VisitMovement> movements;
        public String reasonUid;
        public String roomBed;

        public VisitItem() {
            this.documents = new List<VisitDocument>();
            this.providers = new List<VisitProvider>();
            this.stay = new VisitStay();
            this.movements = new List<VisitMovement>();
        }
    }

    public class VisitDocument {
        public String localTitle;
        public String nationalTitle;
        public String uid;
    }

    public class VisitProvider {
        public String providerName;
        public String providerUid;
        public String role;
        public Boolean primary;

        public VisitProvider() {
            this.primary = false;
        }
    }

    public class VisitStay {
        public String arrivalDateTime;
        public String dischargeDateTime;
    }

    public class VisitMovement {
        public String dateAndTime;
        public String localId;
        public String locationName;
        public String locationUid;
        public String movementType;
        public String providerName;
        public String providerUid;
        public String specialty;
    }

    public VCC_BridgVisitsRS() {
        this.sites = new List<VisitSite>();
    }

    public VCC_BridgVisitsRS(VCC_BaseClient.BaseResponse baseResponse) {
        super(baseResponse);
        try {
            this.sites = ((VCC_BridgVisitsRS) JSON.deserialize(
                    baseResponse.httpResponse.getBody().replace('"dateTime"', '"dateTime_s"').replace('"exception"', '"exception_s"'),
                    VCC_BridgVisitsRS.class
                ))
                .sites;

            if (baseResponse.httpResponse.getBody().contains('Exceeded Max')) {
                this.isMaxRecordsError = true;
            }
        } catch (Exception e) {
            this.exceptions.add(e);
        }
    }
}
