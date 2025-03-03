/**
 * @description Parser for meds response.
 * @group API - Bridg - Meds
 */
// Jeff Watson 2023.05.24 Signed off of PMD suppression.  This code needs to be rewritten.
@SuppressWarnings(
    'PMD.ApexDoc, PMD.ExcessivePublicCount, PMD.OneDeclarationPerLine, PMD.VariableNamingConventions, PMD.FieldDeclarationsShouldBeAtStart, PMD.TooManyFields, PMD.FieldNamingConventions'
)
public with sharing class VCC_BridgMedsResponseParser {
    /**
     * @description
     */
    @AuraEnabled
    public List<Site> sites;

    public class Site {
        @AuraEnabled
        public Result results;
        @AuraEnabled
        public ErrorSection errorSection;
        @AuraEnabled
        public SiteSupplemental siteSupplemental;
    }

    public class Result {
        @AuraEnabled
        public Meds meds;
    }

    public class Meds {
        @AuraEnabled
        public String total;
        @AuraEnabled
        public List<Medication> med;
        @AuraEnabled
        public List<VCC_MedsListController.FormattedMed> formattedMed;

        public Meds() {
            this.med = new List<Medication>();
        }
    }

    public class ErrorSection {
        @AuraEnabled
        public List<Error> errors;
        public ErrorSection(List<Error> errors) {
            this.errors = errors;
        }
    }

    public class Error {
        @AuraEnabled
        public String displayMessage;
        public Error(String displayMessage) {
            this.displayMessage = displayMessage;
        }
    }

    /**
     * @description
     */
    @SuppressWarnings('PMD.TooManyFields, PMD.ExcessivePublicCount')
    public class Medication {
        @AuraEnabled
        public MedsExpires expires;
        @AuraEnabled
        public MedsDoses doses;
        @AuraEnabled
        public MedsVaStatus vaStatus;
        @AuraEnabled
        public MedsFillsAllowed fillsAllowed;
        @AuraEnabled
        public MedsMedId medID;
        @AuraEnabled
        public MedsPharmacist pharmacist;
        @AuraEnabled
        public MedsLastFilled lastFilled;
        @AuraEnabled
        public MedsType type;
        @AuraEnabled
        public MedsProducts products;
        @AuraEnabled
        public MedsSig sig;
        @AuraEnabled
        public MedsRouting routing;
        @AuraEnabled
        public MedsFillsRemaining fillsRemaining;
        @AuraEnabled
        public MedsId id;
        @AuraEnabled
        public MedsFills fills;
        @AuraEnabled
        public MedsVaType vaType;
        @AuraEnabled
        public MedsOrdered ordered;
        @AuraEnabled
        public MedsOrderingProvider orderingProvider;
        @AuraEnabled
        public MedsQuantity quantity;
        @AuraEnabled
        public MedsOrderID orderID;
        @AuraEnabled
        public MedsDaysSupply daysSupply;
        @AuraEnabled
        public MedsStart start;
        @AuraEnabled
        public MedsFillCost fillCost;
        @AuraEnabled
        public MedsForm form;
        @AuraEnabled
        public MedsStop stop;
        @AuraEnabled
        public MedsPrescription prescription;
        @AuraEnabled
        public MedsName name;
        @AuraEnabled
        public MedsLocation location;
        @AuraEnabled
        public MedsFacility facility;
        @AuraEnabled
        public MedsCurrentProvider currentProvider;
        @AuraEnabled
        public MedsStatus status;
        @AuraEnabled
        public MedsPtInstructions ptInstructions;
        @AuraEnabled
        @SuppressWarnings('PMD.FieldNamingConventions')
        public MedsImo IMO;
        @AuraEnabled
        public MedsParent parent;
        @AuraEnabled
        public MedsIvLimit ivLimit;
        @AuraEnabled
        public Supplemental supplemental;
    }

    /**
     * @description
     */
    public class MedsExpires {
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String expiresMonthValue {
            get {
                return addMonthSearch(this.value);
            }
        }
        @AuraEnabled
        public String formattedValue {
            get {
                return transformDate(this.value);
            }
        }
    }

    /**
     * @description
     */
    public class MedsVaStatus {
        @AuraEnabled
        public String value;
    }

    /**
     * @description
     */
    public class MedsFillsAllowed {
        @AuraEnabled
        public String value;
    }

    /**
     * @description
     */
    public class MedsMedId {
        @AuraEnabled
        public String value;
    }

    /**
     * @description
     */
    public class MedsPharmacist {
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String name;
    }

    /**
     * @description
     */
    public class MedsLastFilled {
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String valueMonth {
            get {
                return addMonthSearch(this.value);
            }
        }
        @AuraEnabled
        public String formattedValue {
            get {
                return transformDate(this.value);
            }
        }
    }

    /**
     * @description
     */
    public class MedsType {
        @AuraEnabled
        public String value;
    }

    /**
     * @description
     */
    public class MedsSig {
        @AuraEnabled
        public String content;
    }

    /**
     * @description
     */
    public class MedsRouting {
        @AuraEnabled
        public String value;
    }

    /**
     * @description
     */
    public class MedsFillsRemaining {
        @AuraEnabled
        public String value;
        @AuraEnabled
        public Integer formattedValue {
            get {
                if (!String.isBlank(this.value)) {
                    return Integer.valueOf(this.value);
                } else {
                    return 0;
                }
            }
        }
    }

    /**
     * @description
     */
    public class MedsId {
        @AuraEnabled
        public String value;
    }

    /**
     * @description
     */
    public class MedsFills {
        @AuraEnabled
        public List<MedsFill> fill;
    }

    /**
     * @description
     */
    public class MedsVaType {
        @AuraEnabled
        public String value;
    }

    /**
     * @description
     */
    public class MedsOrdered {
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String formattedValue {
            get {
                return transformDate(this.value);
            }
        }
    }

    /**
     * @description
     */
    public class MedsOrderingProvider {
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String service;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String officePhone;
        @AuraEnabled
        public String analogPager;
        @AuraEnabled
        public String fax;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String taxonomyCode;
        @AuraEnabled
        public String providerType;
        @AuraEnabled
        public String classification;
        @AuraEnabled
        public String specialization;
    }

    /**
     * @description
     */
    public class MedsQuantity {
        @AuraEnabled
        public String value;
        @AuraEnabled
        public Double formattedValue {
            get {
                if (!String.isBlank(this.value)) {
                    return Double.valueOf(this.value);
                } else {
                    return 0;
                }
            }
        }
    }

    /**
     * @description
     */
    public class MedsOrderID {
        @AuraEnabled
        public String value;
    }

    /**
     * @description
     */
    public class MedsDaysSupply {
        @AuraEnabled
        public String value;
    }

    /**
     * @description
     */
    public class MedsStart {
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String valueMonth {
            get {
                return addMonthSearch(this.value);
            }
        }
        @AuraEnabled
        public String formattedValue {
            get {
                return transformDate(this.value);
            }
        }
    }

    /**
     * @description
     */
    public class MedsFillCost {
        @AuraEnabled
        public String value;
    }

    /**
     * @description
     */
    public class MedsForm {
        @AuraEnabled
        public String value;
    }

    /**
     * @description
     */
    public class MedsStop {
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String formattedValue {
            get {
                return transformDate(this.value);
            }
        }
    }

    /**
     * @description
     */
    public class MedsPrescription {
        @AuraEnabled
        public String value;
    }

    /**
     * @description
     */
    public class MedsName {
        @AuraEnabled
        public String value;
    }

    /**
     * @description
     */
    public class MedsLocation {
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String name;
    }

    /**
     * @description
     */
    public class MedsFacility {
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String name;
    }

    /**
     * @description
     */
    public class MedsCurrentProvider {
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String service;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String officePhone;
        @AuraEnabled
        public String analogPager;
        @AuraEnabled
        public String fax;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String taxonomyCode;
        @AuraEnabled
        public String providerType;
        @AuraEnabled
        public String classification;
        @AuraEnabled
        public String specialization;
    }

    /**
     * @description
     */
    public class MedsStatus {
        @AuraEnabled
        public String value;
    }

    /**
     * @description
     */
    public class MedsPtInstructions {
        @AuraEnabled
        public String content;
    }

    /**
     * @description
     */
    public class MedsImo {
        @AuraEnabled
        public String value;
    }

    /**
     * @description
     */
    public class MedsParent {
        @AuraEnabled
        public String value;
    }

    /**
     * @description
     */
    public class MedsIvLimit {
        @AuraEnabled
        public String value;
    }

    /**
     * @description
     */
    public class MedsProducts {
        @AuraEnabled
        public List<Product> product;
    }

    /**
     * @description
     */
    public class Product {
        @AuraEnabled
        public MedsVaGeneric vaGeneric;
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String role;
        @AuraEnabled
        public MedsVaProduct vaProduct;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String concentration;
        // public MedsClass class;
        @AuraEnabled
        public String order;
        @AuraEnabled
        public MedsOrdItem ordItem;
    }

    /**
     * @description
     */
    public class MedsVaGeneric {
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String vuid;
    }

    /**
     * @description
     */
    public class MedsVaProduct {
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String vuid;
    }

    /**
     * @description
     */
    public class MedsClass {
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String vuid;
    }

    /**
     * @description
     */
    public class MedsOrdItem {
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String name;
    }

    /**
     * @description
     */
    public class MedsFill {
        @AuraEnabled
        public String fillDate;
        @AuraEnabled
        public String formattedFillDate {
            get {
                return transformDate(this.fillDate);
            }
        }
        @AuraEnabled
        public String fillDaysSupply;
        @AuraEnabled
        public String fillQuantity;
        @AuraEnabled
        public String fillRouting;
        @AuraEnabled
        public String releaseDate;
        @AuraEnabled
        public String releaseDateMonth {
            get {
                return addMonthSearch(this.releaseDate);
            }
        }
        @AuraEnabled
        public String formattedReleaseDate {
            get {
                return transformDate(this.releaseDate);
            }
        }
        @AuraEnabled
        public String partial;
    }

    /**
     * @description
     */
    public class MedsDoses {
        @AuraEnabled
        public List<Dose> dose;
    }

    /**
     * @description
     */
    public class Dose {
        @AuraEnabled
        public String schedule;
        @AuraEnabled
        public String dose;
        @AuraEnabled
        public String doseStop;
        @AuraEnabled
        public String formattedDoseStop {
            get {
                return transformDate(this.doseStop);
            }
        }
        @AuraEnabled
        public String route;
        @AuraEnabled
        public String noun;
        @AuraEnabled
        public String unitsPerDose;
        @AuraEnabled
        public String units;
        @AuraEnabled
        public String doseStart;
        @AuraEnabled
        public String formattedDoseStart {
            get {
                return transformDate(this.doseStart);
            }
        }
    }

    public class Supplemental {
        @AuraEnabled
        public OutpatientRxFields outpatientRxFields;
        @AuraEnabled
        public PendingMedFields pendingMedFields;
        @AuraEnabled
        public NonVaMedFields nonVaMedFields;
    }

    public class OutpatientRxFields {
        @AuraEnabled
        public String rxNumber;
        @AuraEnabled
        public NameIdAbbr rxPatientStatus;
        @AuraEnabled
        public Ecme ecme;
        @AuraEnabled
        public ProviderComments providerComments;
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String indicationForUseFlag;
        @AuraEnabled
        public String indicationForUse;
        @AuraEnabled
        public String remarks;
        @AuraEnabled
        public Drug drug;
        @AuraEnabled
        public NameIdAbbr copayTransactionType;
        @AuraEnabled
        public String parkedInd;
        @AuraEnabled
        public String otherIndicationForUse;
        @AuraEnabled
        public String titrationInd;
        @AuraEnabled
        public String returnedToStock;
        @AuraEnabled
        public LastCmopEvent lastCmopEvent;
        @AuraEnabled
        public String placerNumber;
        @AuraEnabled
        public String erxHubId;
    }

    public class Ecme {
        @AuraEnabled
        public String ecmeNumber;
        @AuraEnabled
        public String reject;
    }

    public class ProviderComments {
        @AuraEnabled
        public List<String> text;
    }

    public class Drug {
        @AuraEnabled
        public String deaSpeclHandling;
        @AuraEnabled
        public String cmopId;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String id;
    }

    public class NameIdAbbr {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String abbr;
    }

    public class LastCmopEvent {
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String transmissionNumber;
        @AuraEnabled
        public String transmissionStatus;
    }

    public class PendingMedFields {
        @AuraEnabled
        public String numberOfRefills;
        @AuraEnabled
        public String genericDrugName;
        @AuraEnabled
        public String cmopId;
        @AuraEnabled
        public String daysSupply;
        @AuraEnabled
        public String pickupRouting;
        @AuraEnabled
        public String loginDate;
        @AuraEnabled
        public String priority;
        @AuraEnabled
        public String placerNumber;
        @AuraEnabled
        public String enteredBy;
        @AuraEnabled
        public String enteredByDEA;
        @AuraEnabled
        public String provider;
        @AuraEnabled
        public String natureOfOrder;
        @AuraEnabled
        public String qty;
        @AuraEnabled
        public String id;
        @AuraEnabled
        public Clinic clinic;
        @AuraEnabled
        public OrderableItem orderableItem;
    }

    public class Clinic {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String siteAddress;
        @AuraEnabled
        public String abbr;
        @AuraEnabled
        public String facility;
    }

    public class OrderableItem {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public DosageForm dosageForm;
    }

    public class DosageForm {
        @AuraEnabled
        public String conjunction;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String verb;
        @AuraEnabled
        public Nouns nouns;
        @AuraEnabled
        public DispenseUnitsPerDose dispenseUnitsPerDose;
    }

    public class Nouns {
        @AuraEnabled
        public List<String> noun;
    }

    public class DispenseUnitsPerDose {
        @AuraEnabled
        public List<String> unit;
    }

    public class NonVaMedFields {
        @AuraEnabled
        public NonVaMedFieldsDocumentedBy documentedBy;
        @AuraEnabled
        public List<NonVaMedFieldsComments> comments;
        @AuraEnabled
        public String orderNumber;
        @AuraEnabled
        public String genericDrugName;
    }

    public class NonVaMedFieldsDocumentedBy {
        @AuraEnabled
        public NonVaMedFieldsDocumentedDate documentedDate;
        @AuraEnabled
        public NonVaMedFieldsPractitioner practitioner;
    }

    public class NonVaMedFieldsComments {
        @AuraEnabled
        public String comment;
    }

    public class NonVaMedFieldsComment {
        @AuraEnabled
        public String comment;
    }

    public class NonVaMedFieldsDocumentedDate {
        @AuraEnabled
        public String literal;
        @AuraEnabled
        public String formattedDocumentedDate {
            get {
                return transformLiteral(this.literal);
            }
        }
    }

    public class NonVaMedFieldsPractitioner {
        @AuraEnabled
        public NonVaMedFieldsIdentifier indentifier;
        @AuraEnabled
        public String idSourceTable;
        @AuraEnabled
        public NonVaMedFieldsName name;
    }

    public class NonVaMedFieldsIdentifier {
        @AuraEnabled
        public String identity;
        @AuraEnabled
        public String assigningFacility;
        @AuraEnabled
        public String assigningAuthority;
    }

    public class NonVaMedFieldsName {
        @AuraEnabled
        public String given;
        @AuraEnabled
        public String middle;
        @AuraEnabled
        public String family;
        @AuraEnabled
        public String title;
    }

    public class SiteSupplemental {
        @AuraEnabled
        public ServiceConnected serviceConnected;
        @AuraEnabled
        public String cap;
        @AuraEnabled
        public String mailStatus;
        @AuraEnabled
        public Eligibility eligibility;
        @AuraEnabled
        public String dfn;
        @AuraEnabled
        public String facility;
        @AuraEnabled
        public String mailStatusExpDate;
        @AuraEnabled
        public String badAddressIndicator;
        @AuraEnabled
        public String narrative;
    }

    public class ServiceConnected {
        @AuraEnabled
        public String percentage;
        @AuraEnabled
        public Conditions conditions;
    }

    public class Conditions {
        @AuraEnabled
        public List<String> condition;
        @AuraEnabled
        public List<String> conditionPercentage;
    }

    public class Eligibility {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String printName;
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String abbr;
    }

    /**
     * @description
     */
    // public class Errors {
    //     public List<Object> errors; //to-do get schema and complete this parser
    //     public List<Object> fatalErrors;
    //     public List<Object> warnings;
    // }

    //including transformDate in the main parser because it's likely that all meds use cases would need a formatted date
    public static String transformDate(String dateString) {
        String y, m, d, formattedString;

        try {
            if (dateString != null && dateString != '' && dateString != '0') {
                y = dateString.substring(0, 3); //0, 3
                m = dateString.substring(3, 5); //3, 2
                d = dateString.substring(5, 7); //5, 2

                formattedString = String.valueOf(
                    Date.newInstance(1700 + Integer.valueOf(y), Integer.valueOf(m), Integer.valueOf(d))
                );
            }
        } catch (Exception e) {
            Logger.error(e.getStackTraceString());
        }

        return formattedString == null ? '' : formattedString;
    }

    public static String transformLiteral(String dateString) {
        String y, m, d, formattedString;

        try {
            if (dateString != null && dateString != '' && dateString != '0') {
                y = dateString.substring(0, 4);
                m = dateString.substring(4, 6);
                d = dateString.substring(6, 8);

                formattedString = String.valueOf(
                    Date.newInstance(Integer.valueOf(y), Integer.valueOf(m), Integer.valueOf(d))
                );
            }
        } catch (Exception e) {
            Logger.error(e.getStackTraceString());
        }

        return formattedString == null ? '' : formattedString;
    }

    //A class to add a searchable month to each medication.
    public static String addMonthSearch(String dateString) {
        DateTime passedInDate;
        String y, m, d, returnedMonth;

        try {
            if (dateString != null && dateString != '' && dateString != '0') {
                y = dateString.substring(0, 3);
                m = dateString.substring(3, 5);
                d = dateString.substring(5, 7);

                passedInDate = DateTime.newInstance(1700 + Integer.valueOf(y), Integer.valueOf(m), Integer.valueOf(d));
                returnedMonth = passedInDate.format('MMMM');
            }
        } catch (Exception e) {
            Logger.error(e.getStackTraceString());
        }

        return returnedMonth == null ? '' : returnedMonth;
    }
}
