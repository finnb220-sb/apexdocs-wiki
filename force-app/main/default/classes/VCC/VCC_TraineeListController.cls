/**
 * @deprecated VCC_TraineeListController is no longer maintained in va-teams.
 * @description Used to reset training data on trainee users
 * @author      Booz ALlen Hamilton
 * @since       2/13/2024
 */
@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class VCC_TraineeListController {
    private static final Set<Id> TRAINEE_USER_IDS = new Set<Id>();

    static {
        Id traineePermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'VCC_Trainee' WITH USER_MODE LIMIT 1].Id;
        for (PermissionSetAssignment permissionSetAssignment : [
            SELECT AssigneeId
            FROM PermissionSetAssignment
            WHERE PermissionSetId = :traineePermissionSetId
            WITH USER_MODE
        ]) {
            TRAINEE_USER_IDS.add(permissionSetAssignment.AssigneeId);
        }
    }

    @AuraEnabled(Cacheable=true)
    public static List<User> searchUsers(String searchKey) {
        try {
            return getActiveTrainees(new VCC_TrainingModeUserSelector().findBySearchString(searchKey));
        } catch (exception ex) {
            logger.debug(ex.getMessage());
        }
        return new List<User>();
    }

    @AuraEnabled(Cacheable=true)
    public static List<User> searchByDivision(String divisionKey) {
        return getActiveTrainees(new VCC_TrainingModeUserSelector().selectByDivision(divisionKey));
    }

    @AuraEnabled(Cacheable=true)
    public static List<User> searchByTitle(String titleKey) {
        return getActiveTrainees(new VCC_TrainingModeUserSelector().selectByTitle(titleKey));
    }

    @AuraEnabled(Cacheable=true)
    public static List<User> searchByRange(Integer startingNumber, Integer endingNumber) {
        return getActiveTrainees(new VCC_TrainingModeUserSelector().selectByEmployeeNumber(startingNumber, endingNumber));
    }

    @TestVisible
    private static List<User> getActiveTrainees(List<User> users) {
        List<User> traineeUsers = new List<User>();
        for (User user : users) {
            if (user.IsActive && TRAINEE_USER_IDS.contains(user.Id)) {
                traineeUsers.add(user);
            }
        }
        return traineeUsers;
    }

    @AuraEnabled
    public static String resetTrainingDataForUsers(List<String> userIds) {
        return Database.executeBatch(new VCC_ResetTrainingModeDataBatch(new Set<String>(userIds)), 10);
    }

    /**
     * @description  Checks the status of an apex job
     * @param asyncApexJobId id of apex job
     * @return               `AsyncApexJob` of the specified job id
     */
    @AuraEnabled
    public static AsyncApexJob checkJobStatus(String asyncApexJobId) {
        List<AsyncApexJob> asyncApexJobs = [SELECT Id, Status, TotalJobItems, JobItemsProcessed FROM AsyncApexJob WHERE Id = :asyncApexJobId WITH USER_MODE];
        return (asyncApexJobs != null && !asyncApexJobs.isEmpty()) ? asyncApexJobs[0] : null;
    }
}
