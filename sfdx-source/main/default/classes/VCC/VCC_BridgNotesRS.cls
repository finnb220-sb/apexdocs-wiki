public with sharing class VCC_BridgNotesRS extends VCC_BaseClient.BaseResponse {
    public List<DocumentSite> sites;
    public Boolean isMaxRecordsError;

    public class DocumentSite {
        public String apiVersion;
        public DocumentParams params;
        public DocumentDataClass data;
        public VCC_BridgRSCommon.FpdsErrorSection errorSection;

        public DocumentSite() {
            this.params = new DocumentParams();
            this.data = new DocumentDataClass();
            this.errorSection = new VCC_BridgRSCommon.FpdsErrorSection();
        }
    }

    public class DocumentParams {
        public String domain;
        public String systemId;
    }

    public class DocumentDataClass {
        public string updated;
        public string totalItems;
        public List<DocumentItem> items;

        public DocumentDataClass() {
            this.items = new List<DocumentItem>();
        }
    }

    public class DocumentItem {
        public String documentClass;
        public String documentTypeCode;
        public String documentTypeName;
        public String encounterName;
        public String encounterUid;
        public String entered;
        public String facilityCode;
        public String facilityName;
        public String localId;
        public String localTitle;
        public DocumentNationalTitle nationalTitle;
        public DocumentNationalTitleType nationalTitleType;
        public String referenceDateTime;
        public String statusName;
        public List<DocumentText> text;
        public String uid;
        public DocumentNationalTitleSubject nationalTitleSubject;
        public DocumentNationalTitleService nationalTitleService;
        public DocumentNationalTitleRole nationalTitleRole;
        public DocumentNationalTitleSetting nationalTitleSetting;
        public String parent;
        public String images;
        public String urgency;
        public String attendingName;
        public String attendingUid;

        public DocumentItem() {
            this.nationalTitle = new DocumentNationalTitle();
            this.nationalTitleType = new DocumentNationalTitleType();
            this.text = new List<DocumentText>();
            this.nationalTitleSubject = new DocumentNationalTitleSubject();
            this.nationalTitleService = new DocumentNationalTitleService();
            this.nationalTitleRole = new DocumentNationalTitleRole();
            this.nationalTitleSetting = new DocumentNationalTitleSetting();
        }
    }
    public class DocumentNationalTitle {
        public String vuid;
        public String title;
    }
    public class DocumentNationalTitleType {
        public String vuid;
        public String type;
    }
    public class DocumentNationalTitleSubject {
        public String vuid;
        public String subject;
    }
    public class DocumentNationalTitleService {
        public String vuid;
        public String service;
    }
    public class DocumentNationalTitleRole {
        public String vuid;
        public String role;
    }
    public class DocumentNationalTitleSetting {
        public String vuid;
        public String setting;
    }

    public class DocumentText {
        public List<DocumentClinician> clinicians;
        public String content;
        public String dateTime_s;
        public String status;
        public String uid;

        public DocumentText() {
            this.clinicians = new List<DocumentClinician>();
        }
    }

    public class DocumentClinician {
        public String name;
        public String role;
        public String uid;
        public String signature;
        public String signedDateTime;
    }

    public VCC_BridgNotesRS() {
        this.sites = new List<DocumentSite>();
    }

    public VCC_BridgNotesRS(VCC_BaseClient.BaseResponse baseResponse) {
        super(baseResponse);
        String jsonBody;
        try {
            jsonBody = baseResponse.httpResponse.getBody()
                .replace('"dateTime"', '"dateTime_s"')
                .replace('"exception"', '"exception_s"');
        } catch (Exception e) {
            System.debug('$$$$$$$$ Exception caught on line 126' + e.getMessage());
            this.exceptions.add(e);
            return;
        }

        try {
            this.sites = ((VCC_BridgNotesRS) JSON.deserialize(jsonBody, VCC_BridgNotesRS.class)).sites;

            if (baseResponse.httpResponse.getBody().contains('Exceeded Max')) {
                System.debug('##### Exceeded Max Records');
                this.isMaxRecordsError = true;
            }
        } catch (Exception e) {
            System.debug('$$$$$$$$ Exception caught ' + e.getMessage());
            this.exceptions.add(e);
        }
    }
}
