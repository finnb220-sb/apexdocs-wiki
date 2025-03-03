@SuppressWarnings('PMD.ApexDoc, PMD.ExcessivePublicCount')
public with sharing class VCC_BridgMedsRS extends VCC_BaseClient.BaseResponse {
    public List<MedsSite> sites;
    public Boolean isMaxRecordsError;

    private static final String CLASS_STRING = '"class"';
    private static final String CLASS_S_STRING = '"class_s"';
    private static final String EXCEPTION_STRING = '"exception"';
    private static final String EXCEPTION_S_STRING = '"exception_s"';

    public class MedsSite {
        public MedsResults results;
        public VCC_BridgRSCommon.FpdsErrorSection errorSection;
        public SiteSupplemental siteSupplemental;

        public MedsSite() {
            this.results = new MedsResults();
            this.errorSection = new VCC_BridgRSCommon.FpdsErrorSection();
            this.siteSupplemental = new siteSupplemental();
        }
    }

    public class MedsResults {
        public MedsMeds meds;
        public String timeZone;
        public String version;

        public MedsResults() {
            this.meds = new MedsMeds();
        }
    }

    public class MedsMeds {
        public String total;
        public List<MedsMed> med;

        public MedsMeds() {
            this.med = new List<MedsMed>();
        }
    }

    @SuppressWarnings('PMD.TooManyFields')
    public class MedsMed {
        public MedsExpires expires;
        public MedsDoses doses;
        public MedsVaStatus vaStatus;
        public MedsFillsAllowed fillsAllowed;
        public MedsMedId medID;
        public MedsPharmacist pharmacist;
        public MedsLastFilled lastFilled;
        public MedsType type;
        public MedsProducts products;
        public MedsSig sig;
        public MedsRouting routing;
        public MedsFillsRemaining fillsRemaining;
        public MedsId id;
        public MedsFills fills;
        public MedsVaType vaType;
        public MedsOrdered ordered;
        public MedsOrderingProvider orderingProvider;
        public MedsQuantity quantity;
        public MedsOrderID orderID;
        public MedsDaysSupply daysSupply;
        public MedsStart start;
        public MedsFillCost fillCost;
        public MedsForm form;
        public MedsStop stop;
        public MedsPrescription prescription;
        public MedsName name;
        public MedsLocation location;
        public MedsFacility facility;
        public MedsCurrentProvider currentProvider;
        public MedsStatus status;
        public MedsPtInstructions ptInstructions;
        @SuppressWarnings('PMD.VariableNamingConventions, PMD.FieldNamingConventions')
        public MedsImo IMO;
        public MedsParent parent;
        public MedsIvLimit ivLimit;
        public Supplemental supplemental;

        public MedsMed() {
            this.expires = new MedsExpires();
            this.doses = new MedsDoses();
            this.vaStatus = new MedsVaStatus();
            this.fillsAllowed = new MedsFillsAllowed();
            this.medID = new MedsMedId();
            this.pharmacist = new MedsPharmacist();
            this.lastFilled = new MedsLastFilled();
            this.type = new MedsType();
            this.products = new MedsProducts();
            this.sig = new MedsSig();
            this.routing = new MedsRouting();
            this.fillsRemaining = new MedsFillsRemaining();
            this.id = new MedsId();
            this.fills = new MedsFills();
            this.vaType = new MedsVaType();
            this.ordered = new MedsOrdered();
            this.orderingProvider = new MedsOrderingProvider();
            this.quantity = new MedsQuantity();
            this.orderID = new MedsOrderID();
            this.daysSupply = new MedsDaysSupply();
            this.start = new MedsStart();
            this.fillCost = new MedsFillCost();
            this.form = new MedsForm();
            this.stop = new MedsStop();
            this.prescription = new MedsPrescription();
            this.name = new MedsName();
            this.location = new MedsLocation();
            this.facility = new MedsFacility();
            this.currentProvider = new MedsCurrentProvider();
            this.status = new MedsStatus();
            this.ptInstructions = new MedsPtInstructions();
            this.IMO = new MedsImo();
            this.parent = new MedsParent();
            this.ivLimit = new MedsIvLimit();
            this.supplemental = new Supplemental();
        }
    }

    public class MedsExpires {
        public String value;
    }
    public class MedsDoses {
        public List<MedsDose> dose;

        public MedsDoses() {
            this.dose = new List<MedsDose>();
        }
    }
    public class MedsVaStatus {
        public String value;
    }
    public class MedsFillsAllowed {
        public String value;
    }
    public class MedsMedId {
        public String value;
    }
    public class MedsPharmacist {
        public String code;
        public String name;
    }
    public class MedsLastFilled {
        public String value;
    }
    public class MedsType {
        public String value;
    }
    public class MedsProducts {
        public List<MedsProduct> product;

        public MedsProducts() {
            this.product = new List<MedsProduct>();
        }
    }
    public class MedsSig {
        public String content;
    }
    public class MedsRouting {
        public String value; //enum [ W, M, C ]
    }
    public class MedsFillsRemaining {
        public String value;
    }
    public class MedsId {
        public String value;
    }
    public class MedsFills {
        public List<MedsFill> fill;

        public MedsFills() {
            this.fill = new List<MedsFill>();
        }
    }
    public class MedsVaType {
        public String value; //enum [ V, O, I, N ]
    }
    public class MedsOrdered {
        public String value;
    }
    public class MedsOrderingProvider {
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
    public class MedsQuantity {
        public String value;
    }
    public class MedsOrderID {
        public String value;
    }
    public class MedsDaysSupply {
        public String value;
    }
    public class MedsStart {
        public String value;
    }
    public class MedsFillCost {
        public String value;
    }
    public class MedsForm {
        public String value;
    }
    public class MedsStop {
        public String value;
    }
    public class MedsPrescription {
        public String value;
    }
    public class MedsName {
        public String value;
    }
    public class MedsLocation {
        public String code;
        public String name;
    }
    public class MedsFacility {
        public String code;
        public String name;
    }
    public class MedsCurrentProvider {
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
    public class MedsStatus {
        public String value; //enum [ active, hold, historical, not active ]
    }
    public class MedsPtInstructions {
        public String content;
    }
    public class MedsImo {
        public String value;
    }
    public class MedsParent {
        public String value;
    }
    public class MedsIvLimit {
        public String value;
    }
    public class MedsDose {
        public String schedule;
        public String dose;
        public String doseStop;
        public String route;
        public String noun;
        public String unitsPerDose;
        public String units;
        public String doseStart;
        public String duration;
        public String conjunction; //enum [ A, T, E ]
        public String order;
    }
    public class MedsProduct {
        public MedsVaGeneric vaGeneric;
        public string code;
        public string role;
        public MedsVaProduct vaProduct;
        public string name;
        public string concentration;
        @SuppressWarnings('PMD.VariableNamingConventions, PMD.FieldNamingConventions')
        public MedsClass class_s;
        public string order;
        public MedsOrdItem ordItem;

        public MedsProduct() {
            this.vaGeneric = new MedsVaGeneric();
            this.vaProduct = new MedsVaProduct();
            this.class_s = new MedsClass();
            this.ordItem = new MedsOrdItem();
        }
    }
    public class MedsVaGeneric {
        public String code;
        public String name;
        public String vuid;
    }
    public class MedsVaProduct {
        public String code;
        public String name;
        public String vuid;
    }
    public class MedsClass {
        public String code;
        public String name;
        public String vuid;
    }
    public class MedsOrdItem {
        public String code;
        public String name;
    }
    public class MedsFill {
        public String fillDate;
        public String fillDaysSupply;
        public String fillQuantity;
        public String fillRouting; //enum [ W, M, C ]
        public String releaseDate;
        public String partial;
    }

    public class Supplemental {
        public OutpatientRxFields outpatientRxFields;
        public PendingMedFields pendingMedFields;
        public NonVaMedFields nonVaMedFields;
    }

    public class OutpatientRxFields {
        public String rxNumber;
        public NameIdAbbr rxPatientStatus;
        public Ecme ecme;
        public ProviderComments providerComments;
        public String id;
        public String indicationForUseFlag;
        public String indicationForUse;
        public String remarks;
        public Drug drug;
        public NameIdAbbr copayTransactionType;
        public String parkedInd;
        public String otherIndicationForUse;
        public String titrationInd;
        public String returnedToStock;
        public LastCmopEvent lastCmopEvent;
        public String placerNumber;
        public String erxHubId;
    }

    public class Ecme {
        @SuppressWarnings('PMD.VariableNamingConventions, PMD.FieldNamingConventions')
        public String ecmeNumber;
        public String reject;
    }

    public class ProviderComments {
        public List<String> text;
    }

    public class Drug {
        public String deaSpeclHandling;
        public String cmopId;
        public String name;
        public String id;
    }

    public class NameIdAbbr {
        public String name;
        public String id;
        public String abbr;
    }

    public class LastCmopEvent {
        public String status;
        public String transmissionNumber;
        public String transmissionStatus;
    }

    @SuppressWarnings('PMD.TooManyFields')
    public class PendingMedFields {
        public String numberOfRefills;
        public String genericDrugName;
        public String cmopId;
        public String daysSupply;
        public String pickupRouting;
        public String loginDate;
        public String priority;
        public String placerNumber;
        public String enteredBy;
        public String enteredByDEA;
        public String provider;
        public String natureOfOrder;
        public String qty;
        public String id;
        public Clinic clinic;
        public OrderableItem orderableItem;
    }

    public class Clinic {
        public String name;
        public String siteAddress;
        public String abbr;
        public String facility;
    }

    public class OrderableItem {
        public String name;
        public DosageForm dosageForm;
    }

    public class DosageForm {
        public String conjunction;
        public String name;
        public String verb;
        public Nouns nouns;
        public DispenseUnitsPerDose dispenseUnitsPerDose;
    }

    public class Nouns {
        public List<String> noun;
    }

    public class DispenseUnitsPerDose {
        public List<String> unit;
    }

    public class NonVaMedFields {
        public NonVaMedFieldsDocumentedBy documentedBy;
        public List<NonVaMedFieldsComments> comments;
        public String orderNumber;
        public String genericDrugName;
    }

    public class NonVaMedFieldsDocumentedBy {
        public NonVaMedFieldsDocumentedDate documentedDate;
        public NonVaMedFieldsPractitioner practitioner;
    }

    public class NonVaMedFieldsComments {
        public String comment;
    }

    public class NonVaMedFieldsComment {
        public String comment;
    }

    public class NonVaMedFieldsDocumentedDate {
        public String literal;
    }

    public class NonVaMedFieldsPractitioner {
        public NonVaMedFieldsIdentifier indentifier;
        public String idSourceTable;
        public NonVaMedFieldsName name;
    }

    public class NonVaMedFieldsIdentifier {
        public String identity;
        public String assigningFacility;
        public String assigningAuthority;
    }

    public class NonVaMedFieldsName {
        public String given;
        public String middle;
        public String family;
        public String title;
    }

    public class SiteSupplemental {
        public ServiceConnected serviceConnected;
        public String cap;
        public String mailStatus;
        public Eligibility eligibility;
        public String dfn;
        public String facility;
        public String mailStatusExpDate;
        public String badAddressIndicator;
        public String narrative;
    }

    public class ServiceConnected {
        public String percentage;
        public Conditions conditions;
    }

    public class Conditions {
        public List<String> condition;
        public List<String> conditionPercentage;
    }

    public class Eligibility {
        public String name;
        public String printName;
        public String id;
        public String abbr;
    }

    public VCC_BridgMedsRS() {
        this.sites = new List<MedsSite>();
    }

    public VCC_BridgMedsRS(VCC_BaseClient.BaseResponse baseResponse) {
        super(baseResponse);
        try {
            this.sites = ((VCC_BridgMedsRS) JSON.deserialize(
                    baseResponse.httpResponse.getBody()
                        .replace(CLASS_STRING, CLASS_S_STRING)
                        .replace(EXCEPTION_STRING, EXCEPTION_S_STRING),
                    VCC_BridgMedsRS.class
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
