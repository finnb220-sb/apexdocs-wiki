/**
 * @description Apex-defined type for use in flows.
 * @author Patrick Skamarak
 * @since 10/4/2021
 * @group API - VDIF
 * @see VCC_ProgressNoteController
 */
public with sharing class VCC_Vdif_Actions {
    @AuraEnabled
    public final String ADD_SIGNERS;

    @AuraEnabled
    public final String AUTH_TOKEN_RETRIEVAL;

    @AuraEnabled
    public final String CREATE_ADDENDUM;

    @AuraEnabled
    public final String CREATE_ENCOUNTER;

    @AuraEnabled
    public final String GET_ENCOUNTER_STRING;

    @AuraEnabled
    public final String GET_NOTE_TEXT;

    @AuraEnabled
    public final String SIGN_NOTE;

    @AuraEnabled
    public final String VALIDATE_ESIG;

    @AuraEnabled
    public final String WRITE_NOTE;

    @AuraEnabled
    public final String GET_VISIT_RELATED_TOS;

    @AuraEnabled
    public final String GET_CUSTOM_SETTINGS;
}
