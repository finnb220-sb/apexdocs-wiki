/**
 * @description This repository is for Task Database Operations
 * @author Booz Allen
 *
 * @example
 * public class MyLWCController{
 *  @TestVisible
 *  private static VCR_TaskRepo memoizedTaskRepo;
 *
 *
 *    An internally available getter that returns the memoized version if available.
 *    This allows us to only have one instance of the repo at a time
 *
 *  private static VCR_TaskRepo taskRepo {
 *     get {
 *          if (memoizedTaskRepo == null) {
 *                 memoizedTaskRepo = new VCR_TaskRepo();
 *              }
 *            return memoizedTaskRepo;
 *         }
 *     }
 *
 *
 * Using FetchById with defaultSelectFields
 * List<Task> tasks = taskRepo.fetchById(recordId);
 *
 * Using FetchById with additional fields
 * Set<String> myAdditionalFields = new Set<String>{'Phone'};
 * List<Task> tasks = taskRepo.fetchById(recordId, myAdditionalFields);
 */
public virtual inherited sharing class VCR_TaskRepo extends VTC_BaseRepo {
    private static final String BASE_SELECT_CLAUSE = 'SELECT Id, Subject, Status, ActivityDate, FORMAT(ActivityDate) DueDate, CreatedDate, CreatedById, CreatedBy.Name, WhatId, Owner.name, OwnerId,';
    private static final String BASE_WHERE_CLAUSE_END = '\' AND RecordType.Name LIKE \'%Renewal Request%\' ALL ROWS';
    private static final String BLANK_SPACE_FOR_QUERY = ' ';

    /**
     * @description Constructor function for VCR_TaskRepo. Calls super constructor which sets this.sObjectType to 'Task'
     *  Adds additional defaultSelectFields
     */
    public VCR_TaskRepo() {
        super(Task.sObjectType);
        this.defaultSelectFields.add('WhoId');
    }

    /**
     * @description method to query for relevant fields on the task record in order to populate the detail screen
     * @param objRecordId Id of the record passed in, will never be null as calling method has null check
     * @param whatObject a string representing the API name of the object passed in, will never be null as calling method has null check
     * @return <List>Task - list of tasks to be returned, will return empty list if none are returned
     */
    public List<Task> fetchTaskFromPNoteRecordId(Id objRecordId, String whatObject) {
        String selectClause = BASE_SELECT_CLAUSE;
        String typeOfClause = this.calculateTypeOfClause(whatObject);
        String fromClause = this.calculateFromClause();
        String whereClause = this.calculateWhereClauseWhatId(objRecordId);
        String query =
            selectClause +
            BLANK_SPACE_FOR_QUERY +
            typeOfClause +
            BLANK_SPACE_FOR_QUERY +
            fromClause +
            BLANK_SPACE_FOR_QUERY +
            whereClause;
        return this.fetch(query, new Map<String, Object>{ 'objRecordId' => objRecordId });
    }

    /**
     * @description method to query for relevant fields on the task record in order to populate the detail screen
     * @param inputMap a map of String,Object to hold records to be referenced in typeOf and Where clauses
     * @return <List>Task - list of tasks to be returned
     */
    public List<Task> fetchTaskFromTaskRecordId(Map<String, Object> inputMap) {
        String selectClause = BASE_SELECT_CLAUSE;
        String typeOfClause = this.calculateTypeOfClause(String.valueOf(inputMap.get('whatObject')));
        String fromClause = this.calculateFromClause();
        String whereClause = this.calculateWhereClause(inputMap);
        String query =
            selectClause +
            BLANK_SPACE_FOR_QUERY +
            typeOfClause +
            BLANK_SPACE_FOR_QUERY +
            fromClause +
            BLANK_SPACE_FOR_QUERY +
            whereClause;
        return this.fetch(query, new Map<String, Object>{ 'objRecordId' => String.valueOf(inputMap.get('recId')) });
    }

    /**
     * @description method to query for relevant fields on the task record in order to populate the detail screen
     * @param objRecordId Id of the record passed in, will never be null as calling method has null check
     * @param whatObject a string representing the name of the object passed in, will never be null as calling method has null check
     * @return <List>Task - list of tasks to be returned
     */
    public List<Task> fetchTaskFromCaseRecordId(Id objRecordId, String whatObject) {
        String selectClause = BASE_SELECT_CLAUSE;
        String typeOfClause = this.calculateTypeOfClause(whatObject);
        String fromClause = this.calculateFromClause();
        String whereClause = this.calculateWhereClauseWhatId(objRecordId);
        String query =
            selectClause +
            BLANK_SPACE_FOR_QUERY +
            typeOfClause +
            BLANK_SPACE_FOR_QUERY +
            fromClause +
            BLANK_SPACE_FOR_QUERY +
            whereClause;
        return this.fetch(query, new Map<String, Object>{ 'objRecordId' => objRecordId });
    }

    /**
     * @description method to query for relevant fields on the task record in order to populate the detail screen
     * @param objRecordId Id of the record passed in, will never be null as calling method has null check
     * @param whatObject a string representing the name of the object passed in, will never be null as calling method has null check
     * @return <List>Task - list of tasks to be returned
     */
    public List<Task> fetchTaskFromAccountRecordId(Id objRecordId, String whatObject) {
        String selectClause = BASE_SELECT_CLAUSE;
        String typeOfClause = this.calculateTypeOfClause(whatObject);
        String fromClause = this.calculateFromClause();
        String whereClause = this.calculateWhereClauseWhoId(objRecordId);
        String query =
            selectClause +
            BLANK_SPACE_FOR_QUERY +
            typeOfClause +
            BLANK_SPACE_FOR_QUERY +
            fromClause +
            BLANK_SPACE_FOR_QUERY +
            whereClause;
        return this.fetch(query, new Map<String, Object>{ 'objRecordId' => objRecordId });
    }

    /**
     * @description helper method to determine typeOf Clause for query
     * @param whatObject - a string representing the name of the object passed in
     * @return 'String' typeOf clause for soql query
     */
    private String calculateTypeOfClause(String whatObject) {
        String typeOfClause = '';
        switch on (whatObject) {
            when 'VCC_Progress_Note__c', 'Case' {
                typeOfClause = 'TYPEOF What WHEN VCC_Progress_Note__c THEN Name END';
            }
            when 'Task', 'Account' {
                typeOfClause = 'TYPEOF What WHEN Case THEN CaseNumber WHEN VCC_Progress_Note__c THEN Name END';
            }
            when else {
                typeOfClause = '';
            }
        }

        return typeOfClause;
    }

    /**
     * @description helper method to determine the Where clause of the query
     * @param objRecordId Id of the record passed in
     * @return String - whereClause String representing the WHERE clause of the query
     */
    public String calculateWhereClauseWhatId(Id objRecordId) {
        return 'WHERE WhatId =\'' + objRecordId + BASE_WHERE_CLAUSE_END;
    }

    /**
     * @description helper method to determine the Where clause of the query for accounts
     * @param objRecordId Id of the Account passed in
     * @return String - whereClause String representing the WHERE clause of the query
     */
    public String calculateWhereClauseWhoId(Id objRecordId) {
        return 'WHERE WhoId =\'' + objRecordId + BASE_WHERE_CLAUSE_END;
    }

    /**
     * @description overloaded method to help build the WHERE clause for tasks
     * @param inputMap map holding objects for reference in where clause
     * @return String - to help build the WHERE clause
     */
    public String calculateWhereClause(Map<String, Object> inputMap) {
        VCC_Progress_Note__c tempNote = (VCC_Progress_Note__c) inputMap.get('pNoteRecord');
        Task tempTask = (Task) inputMap.get('taskRecord');
        String whereClauseStart = 'WhatId =\'' + inputMap.get('recId');
        String whereClauseEnd = '\' AND RecordType.Name LIKE \'%Renewal Request%\' AND IsClosed = FALSE ALL ROWS';
        String whereClauseForWhatIdEnd = '\' AND Id !=\'' + tempTask.Id + whereClauseEnd;

        if (inputMap.get('taskWhatObject') == 'VCC_Progress_Note__c') {
            //these strings are local to the if block because if tempNote.VCC_Case__c is null it breaks one of the test methods
            //it is not ever null in this if block
            String whereClauseForPNote = '\' OR WhatId =\'' + tempNote.VCC_Case__c;
            String whereClauseForWhatIdPNoteEnd = '\') AND Id !=\'' + tempTask.Id + whereClauseEnd;
            return 'WHERE (' + whereClauseStart + whereClauseForPNote + whereClauseForWhatIdPNoteEnd;
        } else {
            return 'WHERE ' + whereClauseStart + whereClauseForWhatIdEnd;
        }
    }

    /**
     * @description : This method is used to Update Task record
     * @param taskList : List of Task records to be updated.
     * @return List<Database.UpdateResult> : List of updated Tasks.
     */

    public List<Database.SaveResult> updateTasks(List<Task> taskList) {
        return this.doUpdate(taskList);
    }
    // Other queries can be copy pasted here.
}
