public with sharing class COMM_Vdif_NoteAndEncounterParams {
    @AuraEnabled
    public String noteAndEncounterLocationIen; //same as selected

    @AuraEnabled
    public String noteAndEncounterNoteTitleIen; //from tbd GetNoteTitles

    @AuraEnabled
    public String noteAndEncounterProcedures; //from Flow

    @AuraEnabled
    public String noteAndEncounterDiagnoses; //from Flow

    @AuraEnabled
    public String noteAndEncounterVisitRelatedTos;

    @AuraEnabled
    public String itemId;

    @AuraEnabled
    public String encounterString;

    @AuraEnabled
    public List<String> fieldsToWriteToNote;

    @AuraEnabled
    public String authorDUZ;

    @AuraEnabled
    public String cosignerDUZ;
}
