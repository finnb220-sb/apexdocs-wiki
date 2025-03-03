/**
 * @description Controller for retrieving Clinical Triage progress notes, focusing on patient demographics.
 * @author Booz Allen
 * @see VCC_HighlightBarControllerTest
 */

public with sharing class VCC_HighlightBarController {
    /**
     * @description Factory for creating repository instances.
     */
    private static final VTC_RepoFactory repoFactory {
        get {
            return VTC_RepoFactory.repoFactory;
        }
    }

    /**
     * @description Retrieves patient demographics for a given Progress Note record.
     * @param recordId Id of the current Progress Note
     * @return Map<String, String> A map of demographic fields and their values.
     */
    @AuraEnabled(Cacheable=true)
    public static Map<String, String> getPatientDemographics(String recordId) {
        if (String.isBlank(recordId)) {
            return new Map<String, String>();
        }
        VCC_HighlightBarController newInst = new VCC_HighlightBarController();
        return newInst.executeGetPatientDemographics(recordId);
    }

    /**
     * @description Executes the retrieval and mapping of patient demographics.
     * @param recordId Id of the current Progress Note
     * @return Map<String, String> A map of demographic fields and their values.
     */
    public Map<String, String> executeGetPatientDemographics(String recordId) {
        Map<String, String> demographics = new Map<String, String>();

        SObject progressNoteWithPopulatedFieldValues = fetchProgressNote(recordId);
        demographics.putAll(mapFields(progressNoteWithPopulatedFieldValues, getProgressNoteFieldNames()));

        String caseRecordId = (String) progressNoteWithPopulatedFieldValues.get('VCC_Case__c');
        if (caseRecordId != null) {
            demographics.putAll(fetchAndMapCaseFields(caseRecordId));
        }
        return demographics;
    }

    /**
     * @description Fetches fields for a given Progress Note record.
     * @param recordId Id of the Progress Note
     * @return SObject The Progress Note record with the configured fields for recordId.
     * @throws IllegalArgumentException if an error occurs while fetching the Progress Note.
     */
    private SObject fetchProgressNote(String recordId) {
        try {
            VCR_ProgressNoteRepo progressNoteRepo = (VCR_ProgressNoteRepo) createRepo(recordId, 'VCR_ProgressNoteRepo');
            Set<String> fieldNames = new Set<String>(getProgressNoteFieldNames().keySet());
            return progressNoteRepo.fetchById(recordId, fieldNames);
        } catch (Exception exc) {
            Logger.error(LoggingLevel.ERROR + 'Error processing record with Id: ' + recordId, exc);
            throw new IllegalArgumentException('Invalid Progress Note ID: ' + recordId);
        } finally {
            Logger.saveLog();
        }
    }

    /**
     * @description Fetches fields for a given Case record.
     * @param caseRecordId Id of the Case
     * @return SObject The Case record containing the Case fields.
     * @throws IllegalArgumentException if an error occurs while fetching the Case.
     */
    private SObject fetchCase(String caseRecordId) {
        try {
            VCR_CaseRepo caseRepo = (VCR_CaseRepo) createRepo(caseRecordId, 'VCR_CaseRepo');
            Set<String> fieldNames = new Set<String>(getCaseFieldNames().keySet());
            return caseRepo.fetchById(caseRecordId, fieldNames);
        } catch (Exception exc) {
            Logger.error(LoggingLevel.ERROR + 'Error processing record with Id: ' + caseRecordId, exc);
            throw new IllegalArgumentException('Invalid Case ID: ' + caseRecordId);
        } finally {
            Logger.saveLog();
        }
    }

    /**
     * @description Fetches a Contact record with configured/desired field(s).
     * @param contactRecordId Id of the Contact
     * @return SObject The Contact record containing the Contact fields.
     * @throws IllegalArgumentException if an error occurs while fetching the Contact.
     */
    private SObject fetchContact(String contactRecordId) {
        try {
            VCR_ContactRepo contactRepo = (VCR_ContactRepo) createRepo(contactRecordId, 'VCR_ContactRepo');
            Set<String> fieldNames = new Set<String>(getContactFieldNames().keySet());
            return contactRepo.fetchById(contactRecordId, fieldNames);
        } catch (Exception exc) {
            Logger.error(LoggingLevel.ERROR + 'Error processing record with Id: ' + contactRecordId, exc);
            throw new IllegalArgumentException('Invalid Contact ID: ' + contactRecordId);
        } finally {
            Logger.saveLog();
        }
    }

    /**
     * @description Fetches fields for a given Account record via Contact.
     * @param accountRecordId Id of the Account
     * @return SObject The Account record containing the Account fields.
     * @throws IllegalArgumentException if an error occurs while fetching the Account.
     */
    private SObject fetchAccount(String accountRecordId) {
        try {
            VCR_AccountRepo accountRepo = (VCR_AccountRepo) createRepo(accountRecordId, 'VCR_AccountRepo');
            Set<String> fieldNames = new Set<String>(getAccountFieldNames().keySet());
            return accountRepo.fetchById(accountRecordId, fieldNames);
        } catch (Exception exc) {
            Logger.error(LoggingLevel.ERROR + 'Error processing record with Id: ' + accountRecordId, exc);
            throw new IllegalArgumentException('Invalid Account ID: ' + accountRecordId);
        } finally {
            Logger.saveLog();
        }
    }

    /**
     * @description Fetches and maps Case fields, and retrieves related Contact fields.
     * @param caseRecordId Id of the Case
     * @return Map<String, String> A map of Case and related Contact fields.
     */
    private Map<String, String> fetchAndMapCaseFields(String caseRecordId) {
        Map<String, String> demographics = new Map<String, String>();
        SObject caseWithPopulatedFieldValues = fetchCase(caseRecordId);
        demographics.putAll(mapFields(caseWithPopulatedFieldValues, getCaseFieldNames()));

        String contactRecordId = (String) caseWithPopulatedFieldValues.get('ContactId');
        if (contactRecordId != null) {
            demographics.putAll(fetchAndMapContactFields(contactRecordId));
        }
        return demographics;
    }

    /**
     * @description Fetches and maps Contact fields.
     * @param contactRecordId Id of the Contact
     * @return Map<String, String> A map of Contact fields.
     */
    private Map<String, String> fetchAndMapContactFields(String contactRecordId) {
        SObject contactWithPopulatedFieldValues = fetchContact(contactRecordId);
        Map<String, String> demographics = mapFields(contactWithPopulatedFieldValues, getContactFieldNames());

        String accountRecordId = (String) contactWithPopulatedFieldValues.get('AccountId');
        if (accountRecordId != null) {
            demographics.putAll(fetchAndMapAccountFields(accountRecordId));
        }
        return demographics;
    }

    /**
     * @description Fetches and maps Account fields.
     * @param accountRecordId Id of the Account
     * @return Map<String, String> A map of Account fields.
     */
    private Map<String, String> fetchAndMapAccountFields(String accountRecordId) {
        SObject accountWithPopulatedFieldValues = fetchAccount(accountRecordId);
        return mapFields(accountWithPopulatedFieldValues, getAccountFieldNames());
    }

    /**
     * @description Creates a repository for a given record and repository name.
     * @param recordId Id of the record
     * @param repoName Name of the repository
     * @return VTC_BaseRepo The repository instance.
     */
    private VTC_BaseRepo createRepo(String recordId, String repoName) {
        SObjectType sobjType = Id.valueOf(recordId).getSobjectType();
        return repoFactory.createRepo(sobjType, repoName);
    }

    /**
     * @description Gets the field names for the Progress Note object.
     * @return Map<String, String> A map of field API names to labels.
     */
    private Map<String, String> getProgressNoteFieldNames() {
        return new Map<String, String>{
            'VCC_Date_of_Birth__c' => 'DOB',
            'VCC_Patient_Age__c' => 'Age',
            'VCC_Gender__c' => 'Gender',
            'VCC_Current_Location__c' => 'Current Location',
            'VCC_Case__c' => 'CaseId'
        };
    }

    /**
     * @description Gets the field names for the Case object.
     * @return Map<String, String> A map of field API names to labels.
     */
    private Map<String, String> getCaseFieldNames() {
        return new Map<String, String>{
            'VCC_Call_back_phone_number__c' => 'Call Back Number',
            'ContactId' => 'ContactId'
        };
    }

    /**
     * @description Gets the field names for the Account object.
     * @return Map<String, String> A map of field API names to labels.
     */
    private Map<String, String> getAccountFieldNames() {
        return new Map<String, String>{ 'VCC_Gender_Identity__c' => 'Gender Identity' };
    }

    /**
     * @description Gets the field names for the Contact object.
     * @return Map<String, String> A map of field API names to labels.
     */
    private Map<String, String> getContactFieldNames() {
        return new Map<String, String>{
            'AccountId' => 'AccountId',
            'VCC_Emergency_Contact__c' => 'Emergency Contact',
            'VCC_Emergency_Contact_Phone__c' => 'Emergency Contact Phone'
        };
    }

    /**
     * @description Maps the fields from an SObject to a map of field names and values.
     * @param fields The SObject containing fields to map
     * @param fieldNames A map of field API names to labels
     * @return Map<String, String> A map of field labels to their values.
     */
    private Map<String, String> mapFields(SObject fields, Map<String, String> fieldNames) {
        Map<String, Object> fieldsToValue = fields.getPopulatedFieldsAsMap();
        Map<String, String> mappedFields = new Map<String, String>();
        for (String key : fieldsToValue.keySet()) {
            if (fieldNames.containsKey(key)) {
                mappedFields.put(fieldNames.get(key), String.valueOf(fieldsToValue.get(key)));
            }
        }
        return mappedFields;
    }
}
