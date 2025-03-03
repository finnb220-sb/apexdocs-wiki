@SuppressWarnings('PMD.ExcessivePublicCount, PMD.ApexDoc')
/**
 * @description EncounterService for encounterString
 * @author unknown
 * @group bah
 * @last modified on 6/15/23
 * @last modified by Raj Hoare
 **/
public with sharing class VCC_EncounterService {
    // class level constants
    private static final String SERVICE_CATEGORY = 'T';
    private static final Integer VISTA_BASE_YEAR = 1700;
    private static final String VDIF_DIAGNOSIS_TEMPLATE = '{0}^^{1}^^';
    private static final String DAS_PRIMARY_DIAGNOSIS_TEMPLATE = '{0}^^^1^^';
    private static final String DAS_SECONDARY_DIAGNOSIS_TEMPLATE = '{0}^';
    private static final String PROCEDURE_TEMPLATE = '{0}^^^^{1}';

    /**
     * @description Used to create saveNoteAndEncounter RQ with a record Id and calls vdifClient to sent HTTP request
     * @param noteAndEncounterParams `VCC_Vdif_NoteAndEncounterParams` note params
     * @param patientAndProviderParams `VCC_Vdif_PatientAndProviderParams` patient params
     * @param recordId `Id` of progress note or addendum record
     * @return                         `String`
     */
    public static String saveNoteAndEncounter(
        VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams,
        VCC_Vdif_PatientAndProviderParams patientAndProviderParams,
        Id recordId
    ) {
        List<CodeSet> codeSetList = (new VCC_CodeSetSelector())
            .selectByIds(
                new Set<Id>{
                    noteAndEncounterParams.procedureCode.Id,
                    noteAndEncounterParams.primaryDiagnosis.Id,
                    noteAndEncounterParams.secondaryDiagnosis.Id
                }
            );

        for (CodeSet codeSet : codeSetList) {
            if (noteAndEncounterParams.procedureCode.Id == codeSet.Id) {
                noteAndEncounterParams.procedureCode = codeSet;
            }
            if (noteAndEncounterParams.primaryDiagnosis.Id == codeSet.Id) {
                noteAndEncounterParams.primaryDiagnosis = codeSet;
            }
            if (noteAndEncounterParams.secondaryDiagnosis.Id == codeSet.Id) {
                noteAndEncounterParams.secondaryDiagnosis = codeSet;
            }
        }

        VCC_VdifSaveNoteAndEncounterRQ saveNoteAndEncounterRQ = new VCC_VdifSaveNoteAndEncounterRQ(
            patientAndProviderParams.providerLoginSiteCode,
            patientAndProviderParams.providerUserId,
            String.valueOf(patientAndProviderParams.patientLocalPid),
            patientAndProviderParams.patientLocalSiteId,
            noteAndEncounterParams.noteAndEncounterLocationIen,
            noteAndEncounterParams.noteAndEncounterNoteTitleIen,
            getEncounterServiceCategory(),
            createProcedureString(
                noteAndEncounterParams.procedureCode,
                VCC_ProviderService.getProviderDuz(UserInfo.getUserId(), patientAndProviderParams.providerLoginSiteCode)
            ),
            createDiagnosisString(noteAndEncounterParams.primaryDiagnosis, noteAndEncounterParams.secondaryDiagnosis)
        );
        saveNoteAndEncounterRQ.noteAndEncounterVisitRelatedTos = noteAndEncounterParams.noteAndEncounterVisitRelatedTos;
        saveNoteAndEncounterRQ.recordId = recordId;

        VCC_VdifSaveNoteAndEncounterRS saveNoteAndEncounterRS = (new VCC_VdifClient())
            .saveNoteAndEncounter(saveNoteAndEncounterRQ);

        return getAndReturnEncounterStringOrReturnErrorMessage(saveNoteAndEncounterRS.saveNoteAndEncounterTextTO.text);
    }

    /**
     * @description: This method returns the service category.
     * @return String the service category.
     **/
    public static String getEncounterServiceCategory() {
        return SERVICE_CATEGORY;
    }

    /**
     * @description Made this for DAS. It's called from VCC_DASEncounterService
     * @param text saveNoteAndEncounterRS.saveNoteAndEncounterTextTO.text
     * @return `String` the encounterString or an error message
     */
    public static String getAndReturnEncounterStringOrReturnErrorMessage(String text) {
        String encounterString;
        String error;
        try {
            if (String.isBlank(text)) {
                Exception e = new EncounterServiceException('Unable to find encounter string in \'null\'.');
                throw e;
            }
            encounterString = findEncounterString(text);
            if (encounterString == null || String.isBlank(encounterString)) {
                Exception e = new EncounterServiceException(String.valueOf(text).replace(';', '\n'));
                throw e;
            }
        } catch (Exception e) {
            Logger.info('END ERROR:: <=== ERROR MESSAGE ===>' + e);
            Logger.saveLog();
            error = 'ERROR: ' + e.getMessage();
        }

        if (!String.isBlank(encounterString)) {
            return encounterString;
        } else {
            return error;
        }
    }

    /**
     * @description: This method creates a procedure string.
     * @param procedureCode CodeSet for the procedure.
     * @param providerDuz String containing the provider Duz.
     * @return String the procedure string.
     **/
    public static String createProcedureString(CodeSet procedureCode, String providerDuz) {
        return (new Procedure(procedureCode, providerDuz)).toString();
    }

    /**
     * @description Create diagnosis String
     * @return creates creatediagnosisString
     * @param  primaryCode
     * @param  secondaryCode
     **/
    public static String createDiagnosisString(CodeSet primaryCode, CodeSet secondaryCode) {
        return createDiagnosisString(primaryCode, secondaryCode, DiagnosisTemplateType.VDIF);
    }

    /**
     * @description: This method creates a diagnosis string.
     * @param primaryCode CodeSet for the primary diagnosis.
     * @param secondaryCode CodeSet for the secondary diagnosis.
     * @param templateType DiagnosisTemplateType for the template type.
     * @return String the created diagnosis string.
     **/
    public static String createDiagnosisString(
        CodeSet primaryCode,
        CodeSet secondaryCode,
        DiagnosisTemplateType templateType
    ) {
        Diagnosis primary = new Diagnosis(primaryCode, true, templateType);
        Diagnosis secondary = new Diagnosis(secondaryCode, false, templateType);
        return (primary.toString()) + (!String.isBlank(secondary.toString()) ? ';' + secondary.toString() : '');
    }

    /**
     * @description: This method is used to find an encounter string.
     * @param text String containing the text to find in.
     * @return String the found encounter string.
     **/
    public static String findEncounterString(String text) {
        Pattern ptrn = Pattern.compile('([0-9]+;[0-9]+\\.[0-9]*;T)');
        Matcher mchr = ptrn.matcher(text);
        String encounterString;
        if (mchr.find()) {
            encounterString = mchr.group();
        }
        return encounterString;
    }

    /**
     * @description: This method generates an encounter string.
     * @param locationIEN Integer for location IEN.
     * @return String the generated encounter string.
     **/
    public static String generateEncounterString(Integer locationIEN) {
        Datetime now;
        if (Test.isRunningTest()) {
            now = Datetime.valueOf('2021-07-23 13:15:03');
        } else {
            now = Datetime.now();
        }

        String timeStamp = String.valueOf((now.year() - VISTA_BASE_YEAR)) + now.format('MMdd.HHmmss');

        return locationIEN + ';' + timeStamp + ';' + getEncounterServiceCategory();
    }

    public enum DiagnosisTemplateType {
        VDIF,
        DAS
    }

    /**
     * @description: This inner class is for diagnosis check.
     * @author: Unknown
     * @last modified: Unknown
     * @last modified by: Unknown
     * @group bah
     **/
    public class Diagnosis {
        //declarations
        DiagnosisTemplateType templateType = DiagnosisTemplateType.VDIF;

        public Boolean isPrimary { get; set; }
        public CodeSet diagnosisCode { get; set; }

        /**
         * @description Diagnosis
         **/
        public Diagnosis() {
            this.isPrimary = false;
        }

        /**
         * @description is the constructor for the Diagnosis class.
         *
         * @param diagnosisCode A CodeSet that represents the diagnosis code. This code identifies a specific medical condition.
         * @param isPrimary A Boolean value that shows whether this diagnosis is the primary one. If true, this diagnosis is considered as the main diagnosis.
         */
        public Diagnosis(CodeSet diagnosisCode, Boolean isPrimary) {
            this.isPrimary = isPrimary;
            this.diagnosisCode = diagnosisCode;
        }

        /**
         * @description Constructor for Diagnosis Class with DiagnosisTemplateType Object.
         * This constructor initialises the required properties of the Diagnosis object.
         *
         * @param diagnosisCode CodeSet - The diagnosis code identifier.
         * @param isPrimary Boolean - Indicates whether the diagnosis is primary or not.
         * @param templateType DiagnosisTemplateType - The type of template for diagnosis.
         */
        public Diagnosis(CodeSet diagnosisCode, Boolean isPrimary, DiagnosisTemplateType templateType) {
            this(diagnosisCode, isPrimary);
            this.templateType = templateType;
        }

        /**
         * @description: Validates the diagnosis code according to the business rules.
         * @return Boolean indicating if the diagnosis code is valid.
         **/
        public Boolean isValid() {
            if (
                this.isPrimary != null &&
                this.diagnosisCode != null &&
                this.diagnosisCode.Code != null &&
                this.diagnosisCode.CodeSetType != null &&
                this.diagnosisCode.CodeSetType == 'Diagnosis (ICD10)'
            ) {
                return true;
            }
            return false;
        }

        /**
         * @description overrides toString
         * @return toString
         **/
        public override String toString() {
            if (this.isValid() == false) {
                return '';
            }
            return String.format(
                (this.templateType == DiagnosisTemplateType.DAS)
                    ? ((this.isPrimary == true) ? DAS_PRIMARY_DIAGNOSIS_TEMPLATE : DAS_SECONDARY_DIAGNOSIS_TEMPLATE)
                    : VDIF_DIAGNOSIS_TEMPLATE,
                new List<String>{ this.diagnosisCode.Code, (isPrimary == true) ? '1' : '' }
            );
        }
    }

    /**
     * @description Procedure Class
     * @author unknown
     * @group bah
     * @last modified on unknown
     * @last modified by unknown
     **/
    public class Procedure {
        public String providerDuz { get; set; }
        public CodeSet procedureCode { get; set; }

        /**
         * @description Procedure Code validation
         * @return isValid
         **/
        public Boolean isValid() {
            if (
                !String.isBlank(this.providerDuz) &&
                this.procedureCode != null &&
                this.procedureCode.Code != null &&
                this.procedureCode.CodeSetType != null &&
                this.procedureCode.CodeSetType == 'Procedure (CPT)' &&
                this.providerDuz != null &&
                !String.isBlank(this.providerDuz)
            ) {
                return true;
            }
            return false;
        }

        /**
         * @description overrides toString
         * @return toString
         **/
        public override String toString() {
            if (this.isValid()) {
                return String.format(PROCEDURE_TEMPLATE, new List<String>{ this.procedureCode.Code, this.providerDuz });
            }

            return '';
        }

        /**
         * @description Procedure nebula logger
         **/
        public Procedure() {
            return;
        }

        /**
         * Constructor for the Procedure class
         *
         * @description This constructor initializes a new Procedure object with a given procedure code and provider DUZ (Duz is often a term used in healthcare systems to represent a clinician's unique identifier).
         * @param procedureCode the procedure code for this procedure.
         * @param providerDuz the unique identifier for the provider.
         */
        public Procedure(CodeSet procedureCode, String providerDuz) {
            this.providerDuz = providerDuz;
            this.procedureCode = procedureCode;
        }
    }

    /**
     * @description EncounterServiceException error handling
     * @author unknown
     * @group bah
     * @last modified on unknown
     * @last modified by unknown
     **/
    public class EncounterServiceException extends Exception {
    }
}
