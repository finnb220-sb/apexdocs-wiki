public with sharing class VCC_TaskDomain {
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public Task createFutureRenewalTaskFromCase(Case cse, String facilityName, String facilityData, Date renewalDate, Id taskRTId, Id visnId, String division) {
        Task tsk = new Task();
        tsk.Subject = facilityName + ' - Pharmacy Future Renewal Request';
        tsk.ActivityDate = renewalDate; //? Due Date
        tsk.Description = facilityData; //? Comments 32000
        tsk.WhatId = cse.Id; //? Related To
        tsk.WhoId = cse.ContactId; //? Name
        tsk.RecordTypeId = taskRTId;
        tsk.OwnerId = visnId; //? Pharmacy FRR Queue
        tsk.VISN__c = division;

        return tsk;
    }
}
