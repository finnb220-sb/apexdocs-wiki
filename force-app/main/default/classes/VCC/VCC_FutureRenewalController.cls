/**
 * @description VCC_FutureRenewalController is a class that handles the creation of Task records
 *              for future renewal cases in relation to a specific Case record.
 *              It leverages the VCC_FutureRenewalService for the task creation process.
 */
public with sharing class VCC_FutureRenewalController {
    /**
     * @description This method leverages the VCC_FutureRenewalService to create tasks
     *              associated with the provided Case record and the array of medication renewals by facility map.
     * @param recordId The ID of the related Case record.
     * @param medicationRenewalsByFacilityMap This map holds the Medication Renewals details mapped by Facility.
     * @param renewalDate The date on which the medication renewal will take place.
     * @return List<Task> Returns a list of Task records that were created.
     * @throws AuraHandledException Throws an exception if there was an error during the execution of the task creation process.
     */
    @AuraEnabled
    public static List<Task> handleFutureRenewalTaskCreation(Id recordId, Map<String, String> medicationRenewalsByFacilityMap, Date renewalDate) {
        try {
            // Call service & send results to LWC
            return new VCC_FutureRenewalService().createTasksFromCase(recordId, medicationRenewalsByFacilityMap, renewalDate);
        } catch (Exception e) {
            throw new AuraHandledException(e.getStackTraceString() + ' ' + e.getMessage());
        }
    }
}
