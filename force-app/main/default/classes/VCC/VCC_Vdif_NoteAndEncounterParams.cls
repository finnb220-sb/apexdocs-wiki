/**
 * @description Apex-defined type for use in flows.
 * @author Patrick Skamarak
 * @since 8/10/2021
 * @group API - VDIF
 * @see VCC_ProgressNoteController
 */
public with sharing class VCC_Vdif_NoteAndEncounterParams {
    @AuraEnabled
    public String noteAndEncounterLocationIen;

    @AuraEnabled
    public String noteAndEncounterNoteTitleIen;

    @AuraEnabled
    public String noteAndEncounterProcedures;

    @AuraEnabled
    public CodeSet primaryDiagnosis;

    @AuraEnabled
    public CodeSet secondaryDiagnosis;

    @AuraEnabled
    public CodeSet procedureCode;

    @AuraEnabled
    /**
     * @deprecated
     */
    public String noteAndEncounterDiagnoses;

    @AuraEnabled
    /**
     * @deprecated
     */
    public String noteAndEncounterVisitRelatedTos;

    @AuraEnabled
    public String supplementalParameters;

    @AuraEnabled
    public String itemId;

    @AuraEnabled
    public String encounterString;

    @AuraEnabled
    /**
     * @deprecated
     */
    public List<String> fieldsToWriteToNote;

    @AuraEnabled
    /**
     * @depreciated
     */
    public String authorDUZ;

    @AuraEnabled
    public Boolean noShowNoWelfare;

    @AuraEnabled
    public Boolean noShowWithWelfare;
}
