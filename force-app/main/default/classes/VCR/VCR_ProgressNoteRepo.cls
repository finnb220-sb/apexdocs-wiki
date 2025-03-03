/**
 * @description This repository is for Progress Note Database Operations
 * @author Booz Allen
 *
 * @example
 * public class MyLWCController{
 *  @TestVisible
 *  private static VCR_ProgressNoteRepo memoizedProgressNoteRepo;
 *
 *
 *    An internally available getter that returns the memoized version if available.
 *    This allows us to only have one instance of the repo at a time
 *
 *  private static VCR_ProgressNoteRepo pnRepo {
 *     get {
 *          if (memoizedProgressNoteRepo == null) {
 *                 memoizedProgressNoteRepo = new VCR_ProgressNoteRepo();
 *              }
 *            return memoizedProgressNoteRepo;
 *         }
 *     }
 *
 *
 * Using FetchById with defaultSelectFields
 * List<VCC_Progress_Note__c> prognotes = pnRepo.fetchById(recordId);
 *
 * Using FetchById with additional fields
 * Set<String> myAdditionalFields = new Set<String>{'FieldName'};
 * List<VCC_Progress_Note__c> prognotes = pnRepo.fetchById(recordId, myAdditionalFields);
 */
public virtual inherited sharing class VCR_ProgressNoteRepo extends VTC_BaseRepo {
    private static final String BLANK_SPACE_STRING = ' ';

    /**
     * @description - Static instance of the callable VTC Data Service.
     */
    @TestVisible
    private static VTC_PatientService patientService = VTC_PatientService.instance;

    /**
     * @description Constructor function for VCR_ProgressNoteRepo. Calls super constructor which sets this.sObjectType to 'ProgressNote'
     *  Adds additional defaultSelectFields
     */
    public VCR_ProgressNoteRepo() {
        super(VCC_Progress_Note__c.sObjectType);
        this.defaultSelectFields.add('Name');
    }

    /**
     * @description Constructor function for VCR_ProgressNoteRepo. Calls super constructor which sets this.sObjectType to 'ProgressNote'
     *  Adds additional defaultSelectFields. This constructor allows for unsafe DML
     * @param allowUnsafe a boolean to allow P Notes to be inserted in System Mode rather than user mode
     */
    public VCR_ProgressNoteRepo(Boolean allowUnsafe) {
        super(VCC_Progress_Note__c.sObjectType, allowUnsafe);
        this.defaultSelectFields.add('Name');
    }

    /**
     * @description This method inserts a list of Progress Notes
     * @param pNotes This is the list of Progress Notes to be added to the database
     * @return List of Database.SaveResult, results of the create operation
     */
    public List<Database.SaveResult> insertProgressNotesAllOrNoneFalse(List<VCC_Progress_Note__c> pNotes) {
        this.allOrNone = false;
        return this.doCreate(pNotes);
    }

    /**
     * @description This method inserts a list of Progress Notes
     * @param pNotes This is the list of Progress Notes to be added to the database
     * @return List of Database.SaveResult, results of the create operation
     * @justification We must use unsafe doCreate because TIERIII users do not currently have access to TIERI Notes in a normal
     * circumstance, but when creating a Note from FRR Task they should be able to create a TierI note
     */
    public List<Database.SaveResult> insertProgressNotesAllOrNoneFalseUnsafe(List<VCC_Progress_Note__c> pNotes) {
        this.allOrNone = false;
        return this.doCreateUnsafe(pNotes);
    }

    /**
     * @description Fetch Notes data for the given application & Patient (identified by icn) from the configured provider
     * @param args - The arguments to pass to the provider
     * @return VTC_DataModel - The data model containing the ehr notes data
     */
    public VTC_DataModel fetchNotes(Map<String, Object> args) {
        return (VTC_DataModel) patientService.call('get_notes', args);
    }

    /**
     * @description Fetch Directives data for the given application & Patient (identified by icn) from the configured provider
     * @param args - The arguments to pass to the provider
     * @return VTC_DataModel - The data model containing the directives data
     */
    public VTC_DataModel fetchDirectives(Map<String, Object> args) {
        return (VTC_DataModel) patientService.call('get_directives', args);
    }

    /**
     * @description fetching a Progress Note from a Case Id
     * @param caseID the case in which the progress note is associated
     * @return VCC_Progress_Note__c returns a single Progress Note based on the VCC_Case__c field
     */
    public List<VCC_Progress_Note__c> fetchProgressNoteFromCaseId(Id caseID) {
        String whereClause = 'WHERE VCC_Case__c =\'' + caseID + '\'';
        return fetchProgressNoteFromCaseId(caseID, whereClause, true);
    }

    /**
     * @description overloading of fetchProgressNoteFromCaseId in order for other methods to be able to use
     * @param caseID string of the case Id
     * @param whereClause string of the where clause
     * @param limitToOneRecord boolean to determine if limit one or not
     * @return 'List<VCC_Progress_Note__c>' returns a list of progress notes, could be size 1 or larger
     */
    public List<VCC_Progress_Note__c> fetchProgressNoteFromCaseId(
        String caseID,
        String whereClause,
        Boolean limitToOneRecord
    ) {
        String selectClause = 'SELECT ID, VCC_Case__c, VCC_Visit_Modality__c, VCC_Signed__c';
        String fromClause = this.calculateFromClause();
        if (limitToOneRecord) {
            whereClause += ' LIMIT 1';
        }
        String query = selectClause + BLANK_SPACE_STRING + fromClause + BLANK_SPACE_STRING + whereClause;
        return this.fetch(query, new Map<String, Object>{ 'caseID' => caseID });
    }

    /**
     * @description return a List of unsigned Progress Notes associated with a Case
     * @param caseID the case to check for unsigned Notes
     * @return VCC_Progress_Note__c returns a List of unsigned Progress Notes associated with a Case
     */
    public List<VCC_Progress_Note__c> fetchUnsignedProgressNotesFromCaseId(Id caseID) {
        String whereClause = 'WHERE VCC_Case__c =\'' + caseID + '\' AND VCC_Signed__c = false';
        return fetchProgressNoteFromCaseId(caseID, whereClause, false);
    }

    /**
     * @description this method constructs the query string that will be used to get VCC_Progress_Note__c that don't have VCC_Case_Metrics__c field populated
     * @return
     */

    private String getQueryString() {
        String selectClause = 'SELECT ID, VCC_Case_Metrics__c, VCC_Case__c';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE VCC_Case_Metrics__c = ' + null;
        String query = selectClause + BLANK_SPACE_STRING + fromClause + BLANK_SPACE_STRING + whereClause;
        return query;
    }

    /**
     * @description Used to set the context for the databasequerylocator
     * @return String representing the query string to be used in the fetch method.
     */
    public String getQueryLocatorString() {
        return this.getQueryString();
    }

    /**
     * @description : This method is used to Update Progress Note record.
     * @param progressNotesList : List of Progress Notes records to be updated.
     * @return List<Database.SaveResult> : List of updated Progress Notes.
     */

    public List<Database.SaveResult> updateProgressNotes(List<VCC_Progress_Note__c> progressNotesList) {
        return this.doUpdate(progressNotesList);
    }

    /**
     * @description
     * @param query query string to be used in the query locator.
     * @return Database.QueryLocator representing a complex query on the Case object
     */
    public Database.QueryLocator getQueryLocator(String query) {
        return Database.getQueryLocator(query);
    }
}
