public with sharing class VCC_BridgLabsRS extends VCC_BaseClient.BaseResponse {
    public List<LabsSite> sites;

    public class LabsSite {
        public LabsResults results;
        public VCC_BridgRSCommon.FpdsErrorSection errorSection;
        public Boolean isMaxRecordsError;

        public LabsSite() {
            this.results = new LabsResults();
            this.errorSection = new VCC_BridgRSCommon.FpdsErrorSection();
            this.isMaxRecordsError = false;
        }
    }

    public class LabsResults {
        public LabsLabs labs;
        public String timeZone;
        public String version;

        public LabsResults() {
            this.labs = new LabsLabs();
        }
    }

    public class LabsLabs {
        public String total;
        public List<LabsLab> lab;

        public LabsLabs() {
            this.lab = new List<LabsLab>();
        }
    }

    public class LabsLab {
        public LabsResulted resulted;
        public LabsPerformingLab performingLab;
        public LabsTest test;
        public LabsOrderID orderID;
        public LabsCollected collected;
        public LabsUnits units;
        public LabsType type;
        public LabsSample sample;
        public LabsVuid vuid;
        public LabsResult result;
        public LabsLocalName localName;
        public LabsGroupName groupName;
        public LabsHigh high;
        public LabsInterpretation interpretation;
        public LabsLow low;
        public LabsProvider provider;
        public LabsSpecimen specimen;
        public LabsComment comment;
        public LabsId id;
        public LabsFacility facility;
        public LabsLabOrderID labOrderID;
        public LabsLoinc loinc;
        public LabsStatus status;

        public LabsLab() {
            this.resulted = new LabsResulted();
            this.performingLab = new LabsPerformingLab();
            this.test = new LabsTest();
            this.orderID = new LabsOrderID();
            this.collected = new LabsCollected();
            this.units = new LabsUnits();
            this.type = new LabsType();
            this.sample = new LabsSample();
            this.vuid = new LabsVuid();
            this.result = new LabsResult();
            this.localName = new LabsLocalName();
            this.groupName = new LabsGroupName();
            this.high = new LabsHigh();
            this.interpretation = new LabsInterpretation();
            this.low = new LabsLow();
            this.provider = new LabsProvider();
            this.specimen = new LabsSpecimen();
            this.comment = new LabsComment();
            this.id = new LabsId();
            this.facility = new LabsFacility();
            this.labOrderID = new LabsLabOrderID();
            this.loinc = new LabsLoinc();
            this.status = new LabsStatus();
        }
    }

    public class LabsResulted {
        public String value;
    }
    public class LabsPerformingLab {
        public String value;
    }
    public class LabsTest {
        public String value;
    }
    public class LabsOrderID {
        public String value;
    }
    public class LabsCollected {
        public String value;
    }
    public class LabsUnits {
        public String value;
    }
    public class LabsType {
        public String value;
    }
    public class LabsSample {
        public String value;
    }
    public class LabsVuid {
        public String value;
    }
    public class LabsResult {
        public String value;
    }
    public class LabsLocalName {
        public String value;
    }
    public class LabsGroupName {
        public String value;
    }
    public class LabsHigh {
        public String value;
    }
    public class LabsInterpretation {
        public String value; //enum [ L, L*, H, H*, null ]
    }
    public class LabsLow {
        public String value;
    }
    public class LabsProvider {
        public String code;
        public String service;
        public String name;
        public String officePhone;
        public String analogPager;
        public String fax;
        public String email;
        public String taxonomyCode;
        public String providerType;
        public String classification;
        public String specialization;
    }
    public class LabsSpecimen {
        public String code;
        public String name;
    }
    public class LabsComment {
        public String content;
        //public String value;
    }
    public class LabsId {
        public String value;
    }
    public class LabsFacility {
        public String code;
        public String name;
    }
    public class LabsLabOrderID {
        public String value;
    }
    public class LabsLoinc {
        public String value;
    }
    public class LabsStatus {
        public String value; //enum [ completed, incomplete ]
    }

    public VCC_BridgLabsRS() {
        this.sites = new List<LabsSite>();
    }

    public VCC_BridgLabsRS(VCC_BaseClient.BaseResponse baseResponse) {
        super(baseResponse);
        try {
            this.sites = ((VCC_BridgLabsRS) JSON.deserialize(baseResponse.httpResponse.getBody().replace('"exception"', '"exception_s"'), VCC_BridgLabsRS.class)).sites;

            if (baseResponse.httpResponse.getBody().contains('Exceeded Max')) {
                this.sites[0].isMaxRecordsError = true;
            }
        } catch (Exception e) {
            this.exceptions.add(e);
        }
    }
}
