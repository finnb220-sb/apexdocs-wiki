public with sharing class VCC_FutureRenewalService {
    public class VCC_FutureRenewalServiceException extends Exception {
    }

    public List<Task> createTasksFromCase(Id recordId, Map<String, String> medicationRenewalsByFacilityMap, Date renewalDate) {
        fflib_ISObjectUnitOfWork uow = VCC_UoWDomain.createUoW();
        List<Task> createdTasksToInsert = this.createTasksFromCase(recordId, medicationRenewalsByFacilityMap, renewalDate, uow);
        uow.commitWork();
        return createdTasksToInsert;
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public List<Task> createTasksFromCase(Id recordId, Map<String, String> medicationRenewalsByFacilityMap, Date renewalDate, fflib_ISObjectUnitOfWork uow) {
        VCC_TaskDomain taskDomain = new VCC_TaskDomain();
        //? get the Case object
        Case cse = new VCC_CaseSelector().selectById(new Set<Id>{ recordId })[0];
        //? get recordType
        RecordType taskRT = [
            SELECT Id, Name, SobjectType, DeveloperName
            FROM RecordType
            WHERE SobjectType = 'Task' AND Name = 'VAHC Pharmacy Renewal Request' AND IsActive = TRUE
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        //? get the VISN Task Queue
        Group frrQueue = [
            SELECT Id, Name, DeveloperName
            FROM Group
            WHERE Type = 'Queue' AND DeveloperName = 'VCC_Pharmacy_FRR_Queue'
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        //? get the Current User division
        String division = [
            SELECT Division
            FROM User
            WHERE Id = :UserInfo.getUserId()
            WITH SECURITY_ENFORCED
        ][0]
        .Division;

        //? bulk for each facility
        //? make a collection by Facility to iterate thru
        List<Task> createdTasksToInsert = new List<Task>();
        for (String facilityKey : medicationRenewalsByFacilityMap.keySet()) {
            //? call the task domain
            //? add the returned created task to list of tasks
            createdTasksToInsert.add(
                taskDomain.createFutureRenewalTaskFromCase(cse, facilityKey, medicationRenewalsByFacilityMap.get(facilityKey), renewalDate, taskRT.Id, frrQueue.Id, division)
            );
        }
        //? insert list of tasks
        uow.registerNew(createdTasksToInsert);
        return createdTasksToInsert;
    }
}
