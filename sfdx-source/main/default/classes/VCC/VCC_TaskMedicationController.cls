/**
 * @description Serves as a controller for Task Medications. Allows Users to create PNote from FRR Task
 * @author Booz Allen Hamilton
 * @see VCC_TaskMedicationControllerTest for test class, and associated Repo Classes
 * @group Objects - VCC_Progress_Note__c, Tasks
 */
public with sharing class VCC_TaskMedicationController {
    private static final String COMPLETED_STATUS_STRING = 'Completed';
    @TestVisible
    /**
     * @description instantiation of Progress Note repo
     */
    private static VCR_ProgressNoteRepo pNoteRepo {
        get {
            return pNoteRepo = pNoteRepo ?? new VCR_ProgressNoteRepo();
        }
        set;
    }

    @TestVisible
    /**
     * @description instantiation of Progress Note repo with unsafe doCreate
     */
    private static VCR_ProgressNoteRepo pNoteRepoUnsafe {
        get {
            return pNoteRepoUnsafe = pNoteRepoUnsafe ?? new VCR_ProgressNoteRepo(true);
        }
        set;
    }

    @TestVisible
    /**
     * @description instantiation of Task repo
     */
    private static VCR_TaskRepo taskRepo {
        get {
            return taskRepo = taskRepo ?? new VCR_TaskRepo();
        }
        set;
    }

    @TestVisible
    /**
     * @description instantiation of Contact repo
     */
    private static VCR_ContactRepo contRepo {
        get {
            return contRepo = contRepo ?? new VCR_ContactRepo();
        }
        set;
    }

    @TestVisible
    /**
     * @description instantiation of Case repo
     */
    private static VCR_CaseRepo caseRepo {
        get {
            return caseRepo = caseRepo ?? new VCR_CaseRepo();
        }
        set;
    }

    @AuraEnabled
    /**
     * @description - Get list of tasks for table
     * @param recId - Id of the Task record
     * @return List<Task> - The list of tasks matching the query
     */
    public static List<Task> getTableData(String recId) {
        Set<String> myAdditionalFields = new Set<String>{ 'Description', 'OwnerId', 'Status', 'WhoId', 'WhatId' };
        List<Task> tskList = new List<Task>();
        Task taskToAdd = (Task) taskRepo.fetchById(recId, myAdditionalFields);
        tskList.add(taskToAdd);
        return tskList;
    }

    @AuraEnabled
    /**
     * @description - Check for unsigned Progress Notes on the Case
     * @param caseId - Case to be checked for unsigned notes
     * @return Boolean - returns True if the case has unsigned Progress Notes, otherwise false
     */
    public static Boolean checkCaseForUnsignedPNs(String caseId) {
        List<VCC_Progress_Note__c> pnList = pNoteRepo.fetchUnsignedProgressNotesFromCaseId(caseId);
        return pnList.size() > 0;
    }

    @AuraEnabled
    /**
     * @description returns a new Progress Note
     * @param paramsFromLWC map from LWC containing needed info/params
     * @return 'VCC_ProgressNote' returns a Progress Note */
    public static VCC_Progress_Note__c createProgressNoteFromTask(Map<String, Object> paramsFromLWC) {
        try {
            Map<String, Object> paramMap = paramsFromLWC;
            //fetch task by ID
            Set<String> myAdditionalTaskFields = new Set<String>{ 'WhatId' };
            Task tsk = (Task) taskRepo.fetchById(String.valueOf(paramMap.get('recordId')), myAdditionalTaskFields);
            // get Case info from Task's Case Id
            Case casesRelatedToTask = getCaseToReturn(tsk.WhatId);
            Case relatedCase = casesRelatedToTask;
            //Update Case Owner, if not already owner, before creating Progress Note / updating Task
            if (relatedCase.OwnerId != UserInfo.getUserId()) {
                relatedCase = updateCaseOwner(relatedCase);
            }
            //set fields on new Progress Note
            paramMap.put('relatedCase', relatedCase);
            VCC_Progress_Note__c progNote = setPNoteFields(paramMap);
            //insert Progress Note in Repo
            List<Database.SaveResult> insertResult = insertProgressNote(progNote);
            if (insertResult[0].isSuccess()) {
                // update the Task
                updateTask(tsk, String.valueOf(paramMap.get('newDescription')), insertResult[0]?.getId());
            }
            //return the Progress Note
            return getPNoteToReturn(insertResult[0]?.getId());
        } catch (Exception except) {
            Logger.error(
                'ERROR Creating Progress Note: ' +
                    except.getMessage() +
                    ' from Task: ' +
                    String.valueOf(paramsFromLWC.get('recordId'))
            );
            Logger.error('Error Stack Trace: ' + except.getStackTraceString());
            Logger.saveLog();
            throw new AuraHandledException(except.getStackTraceString() + ' ' + except.getMessage());
        }
    }
    /**
     * @description call Task repo to DML update a single task
     * @param taskToUpdate list of tasks to update
     * @param description description of the task to be set
     * @param pNoteId id of the progress note used to update the task WhatId
     */
    private static void updateTask(Task taskToUpdate, String description, String pNoteId) {
        taskToUpdate.Description = description;
        taskToUpdate.Status = COMPLETED_STATUS_STRING;
        taskToUpdate.WhatId = pNoteId;
        taskRepo.updateTasks(new List<Task>{ taskToUpdate });
    }

    /**
     * @description updates the case owner
     * @param caseToUpdate case in which we are updating the owner
     * @return 'Case' returns the updated case to be put into the param map used for creating progress note
     */
    @TestVisible
    private static Case updateCaseOwner(Case caseToUpdate) {
        Case transferCase = new Case(Id = caseToUpdate.Id, OwnerId = UserInfo.getUserId());
        List<Database.UpsertResult> upRes = caseRepo.upsertCasesAllOrNoneFalse(new List<Case>{ transferCase });
        if (upRes[0].isSuccess()) {
            return getCaseToReturn(upRes[0]?.getId());
        } else {
            Logger.error('ERROR updating case owner: ' + upRes[0].getErrors()[0].getMessage());
            Logger.error('Record failure: ' + upRes[0]?.getId());
            Logger.saveLog();
            throw new AuraHandledException('ERROR updating case owner: ' + upRes[0].getErrors()[0].getMessage());
        }
    }

    /**
     * @description insert a progress note
     * @param pNoteToInsert note to be inserted
     * @return 'List<Database.SaveResult>' returns the result of the DML operation
     */
    @TestVisible
    private static List<Database.SaveResult> insertProgressNote(VCC_Progress_Note__c pNoteToInsert) {
        Boolean hasTierIII = FeatureManagement.checkPermission('VCC_Pharmacy_Tier_III');
        if (hasTierIII) {
            return pNoteRepoUnsafe.insertProgressNotesAllOrNoneFalseUnsafe(
                new List<VCC_Progress_Note__c>{ pNoteToInsert }
            );
        }
        return pNoteRepo.insertProgressNotesAllOrNoneFalse(new List<VCC_Progress_Note__c>{ pNoteToInsert });
    }

    /**
     * @description takes in a case and a record type name, returns a progress note to be inserted
     * @param paramMap the parameters in a Map<String,Object>, used to reduce size of param list
     * @return 'VCC_Progress_Note__c' returns a progress note that will be inserted later
     */
    @TestVisible
    private static VCC_Progress_Note__c setPNoteFields(Map<String, Object> paramMap) {
        //get TierI or TierII Progress Note Record Type Id
        Id pnRecTypeId = Schema.SObjectType.VCC_Progress_Note__c.getRecordTypeInfosByDeveloperName()
            .get(String.valueOf(paramMap.get('recordTypeName')))
            .getRecordTypeId();
        Case tempCase = (Case) paramMap.get('relatedCase');
        //set PNote fields
        VCC_Progress_Note__c progNote = new VCC_Progress_Note__c();
        progNote.VCC_Requested_Medication__c = String.valueOf(paramMap.get('pnString'));
        progNote.VCC_Medication_Fill_Renewal__c = true;
        progNote.VCC_Controlled_medication__c = Boolean.valueOf(paramMap.get('controlled'));
        progNote.VCC_Non_controlled_medication__c = Boolean.valueOf(paramMap.get('nonControlled'));
        progNote.RecordTypeId = pnRecTypeId;
        progNote.VCC_Case__c = tempCase.Id;
        progNote.VCC_Relative_Type__c = tempCase.VCC_Caller_Relation__c; //? same as case
        progNote.VCC_If_Other_Describe_Relation_Patient__c = tempCase.VCC_Relation_Type_Other__c; //? relation type (if Other)
        progNote.VCC_Caller_Name_Text__c = tempCase.VCC_Caller_Name__c;
        progNote.VCC_Facility__c = String.valueOf(paramMap.get('facilityName'));

        return progNote;
    }

    /**
     * @description get a progress note with field values
     * @param pNoteId the id of progress Note to be returned
     * @return 'VCC_Progress_Note__c' returns a VCC_Progress_Note__c record
     */
    private static VCC_Progress_Note__c getPNoteToReturn(ID pNoteId) {
        Set<String> myAdditionalPNoteFields = new Set<String>{
            'VCC_Requested_Medication__c',
            'VCC_Medication_Fill_Renewal__c',
            'VCC_Controlled_medication__c',
            'VCC_Non_controlled_medication__c',
            'RecordTypeId',
            'VCC_Case__c',
            'VCC_Relative_Type__c',
            'VCC_If_Other_Describe_Relation_Patient__c',
            'VCC_Caller_Name_Text__c',
            'VCC_Facility__c'
        };
        return (VCC_Progress_Note__c) pNoteRepo.fetchById(pNoteId, myAdditionalPNoteFields);
    }

    /**
     * @description get a case with field values
     * @param taskWhatId the id of Case to be returned
     * @return 'Case' returns a Case record
     */
    @TestVisible
    private static Case getCaseToReturn(Id taskWhatId) {
        Set<String> myAdditionalCaseFields = new Set<String>{
            'OwnerId',
            'AccountId',
            'ContactId',
            'Subject',
            'Status',
            'VCC_Caller_Relation__c',
            'Description',
            'VCC_Relation_Type_Other__c',
            'VCC_Caller_Name__c'
        };
        return (Case) caseRepo.fetchById(taskWhatId, myAdditionalCaseFields);
    }

    @AuraEnabled
    /**
     * @description - Get related Tasks from a record. Can be case, account, Pnote,
     * @param recId - Record Id to gather tasks from
     * @return List<Task> - List of Tasks related to the record
     */
    public static List<Task> getRelatedTaskDetail(String recId) {
        List<Task> tskList = new List<Task>();
        if (String.isNotBlank(recId)) {
            String whatObject = Id.valueOf(recId)?.getSObjectType().getDescribe().getName();
            // switch statement to determine object
            switch on (whatObject) {
                when 'VCC_Progress_Note__c' {
                    tskList = taskRepo.fetchTaskFromPNoteRecordId(recId, whatObject);
                }
                when 'Task' {
                    //map to use for inputing multiple params rather than having a long param list
                    Map<String, Object> inputMap = new Map<String, Object>();
                    //add whatObject string to map
                    inputMap.put('whatObject', whatObject);
                    Set<String> myAdditionalTaskFields = new Set<String>{ 'WhatId' };
                    Task taskRecord = (Task) taskRepo.fetchById(recId, myAdditionalTaskFields);
                    inputMap.put('taskRecord', taskRecord);
                    recId = taskRecord?.WhatId;
                    inputMap.put('recId', recId);
                    String taskWhatObject = Id.valueOf(recId).getSObjectType().getDescribe().getName();
                    inputMap.put('taskWhatObject', taskWhatObject);
                    if (taskWhatObject == 'VCC_Progress_Note__c') {
                        Set<String> myAdditionalPNoteFields = new Set<String>{ 'VCC_Case__c' };
                        VCC_Progress_Note__c pNoteRecord = (VCC_Progress_Note__c) pNoteRepo.fetchById(
                            recId,
                            myAdditionalPNoteFields
                        );
                        inputMap.put('pNoteRecord', pNoteRecord);
                        tskList = taskRepo.fetchTaskFromTaskRecordId(inputMap);
                    } else {
                        tskList = taskRepo.fetchTaskFromTaskRecordId(inputMap);
                    }
                }
                when 'Case' {
                    tskList = taskRepo.fetchTaskFromCaseRecordId(recId, whatObject);
                }
                when 'Account' {
                    Contact contRecord = contRepo.getContactFromAccountId(recId)[0];
                    recId = contRecord?.Id;
                    tskList = taskRepo.fetchTaskFromAccountRecordId(recId, whatObject);
                }
            }
        }
        return tskList;
    }
}
