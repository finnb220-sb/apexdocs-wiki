public with sharing class VCC_ProgressNoteService {
    public static Metadata.Layout getLayoutByName(String layoutName) {
        return VCC_LayoutService.getPageLayout('VCC_Progress_Note__c', layoutName);
    }

    public class VCC_ProgressNoteServiceException extends Exception {
    }

    public static VCC_Progress_Note_Configuration__mdt getConfig(VCC_Progress_Note__c pn) {
        try {
            if (pn.RecordTypeId != null) {
                return getConfig(new RecordType(Id = pn.RecordTypeId));
            }
        } catch (Exception e) {
            Logger.error('ERROR MESSAGE::: ' + e);
            Logger.saveLog();
        }
        if (pn.Id != null) {
            VCC_ProgressNoteSelector pnSelector = new VCC_ProgressNoteSelector();
            return getConfig(new RecordType(Id = pnSelector.selectByIds(new Set<Id>{ pn.Id })[0].RecordTypeId));
        }
        return null;
    }

    public static VCC_Progress_Note_Configuration__mdt getConfig(RecordType recordType) {
        if (recordType.Id == null) {
            return null;
        }
        Map<Id, Schema.RecordTypeInfo> recTypeInfo = VCC_Progress_Note__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getRecordTypeInfosById();
        return (new VCC_ProgressNoteConfigSelector()).selectByRecordTypeAPIName(recTypeInfo.get(recordType.Id).getDeveloperName());
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public VCC_Progress_Note__c createProgressNote(String pnString, Boolean controlled, Boolean nonControlled, String recordId, String newDescription, String faciilityName) {
        //? customized the order of UOW domain execution
        fflib_ISObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<Schema.SObjectType>{ VCC_Progress_Note__c.SObjectType, Task.SObjectType });
        VCC_Progress_Note__c result = this.createProgressNote(pnString, controlled, nonControlled, recordId, newDescription, uow, faciilityName);
        uow.commitWork();
        return result;
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public VCC_Progress_Note__c createProgressNote(
        String pnString,
        Boolean controlled,
        Boolean nonControlled,
        String recordId,
        String newDescription,
        fflib_ISObjectUnitOfWork uow,
        String faciilityName
    ) {
        VCC_ProgressNoteDomain progressNoteDomain = new VCC_ProgressNoteDomain();
        //? get Case from Task
        Task tsk = [SELECT Id, WhatId FROM Task WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];

        //? get Case info from Task's Case Id
        List<Case> cases = new VCC_CaseSelector().selectById(new Set<Id>{ tsk.WhatId });
        if (cases == null || cases.isEmpty()) {
            throw new VCC_ProgressNoteServiceException('Case not found');
        }
        Case cse = cases[0];
        // Update Case Owner, if not already owner, before creating Progress Note / updating Task
        if (cse.OwnerId != UserInfo.getUserId()) {
            fflib_ISObjectUnitOfWork uowBefore = new fflib_SObjectUnitOfWork(new List<Schema.SObjectType>{ Case.SObjectType });
            Case transferCase = new Case(Id = cse.Id, OwnerId = UserInfo.getUserId());
            uowBefore.registerDirty(transferCase);
            uowBefore.commitWork();
        }

        //? get pnRecTypeId for Pharm progressNote
        Id pnRecTypeId = Schema.SObjectType.VCC_Progress_Note__c.getRecordTypeInfosByDeveloperName().get('VCC_Tier_I_Progress_Note').getRecordTypeId();

        VCC_Progress_Note__c result = progressNoteDomain.newProgressNote(pnString, controlled, nonControlled, cse, pnRecTypeId, faciilityName);

        //? insert progress note
        uow.registerNew(result);

        uow.registerRelationship(tsk, Task.WhatId, result);
        //? update the Task
        tsk.Description = newDescription;
        tsk.Status = 'Completed';
        uow.registerDirty(tsk);

        return result;
    }
}
