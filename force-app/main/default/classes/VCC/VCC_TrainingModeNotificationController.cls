/**
 * VCC_TrainingModeNotificationController
 * @description Controller class for vvcTrainingModeNotification lwc.
 * @author Liberty
 * @date 12/6/2021
 */
@SuppressWarnings('PMD')
public with sharing class VCC_TrainingModeNotificationController {
    private static final Boolean IS_TRAINING_MODE_ENABLED = VCC_TrainingModeService.isTrainingModeEnabled();
    private static final Boolean IS_TRAINER = VCC_SecurityService.hasPermissionSet(UserInfo.getUserId(), 'VCC_Trainer');
    private static final Boolean IS_TRAINEE = VCC_SecurityService.hasPermissionSet(UserInfo.getUserId(), 'VCC_Trainee');

    @AuraEnabled
    public static Model getModel() {
        return new Model();
    }

    @AuraEnabled
    public static String resetMyTrainingData() {
        Set<String> userIds = new Set<String>{ UserInfo.getUserId() };
        return Database.executeBatch(new VCC_ResetTrainingModeDataBatch(userIds), 1);
    }

    @AuraEnabled
    public static String resetTrainingDataForUsers(List<String> userIds) {
        Set<String> uIds = new Set<String>();
        uIds.addAll(userIds);
        return Database.executeBatch(new VCC_ResetTrainingModeDataBatch(uIds), 10);
    }

    @AuraEnabled
    public static AsyncApexJob checkJobStatus(String asyncApexJobId) {
        return [SELECT Id, Status, TotalJobItems, JobItemsProcessed FROM AsyncApexJob WHERE Id = :asyncApexJobId LIMIT 1];
    }

    private static List<TrainingUser> getTrainingUsers() {
        List<TrainingUser> trainingUsers = new List<TrainingUser>();
        try {
            for (PermissionSetAssignment permissionSetAssignment : [
                SELECT Id, AssigneeId, Assignee.FirstName, Assignee.LastName, Assignee.Username, Assignee.EmployeeNumber
                FROM PermissionSetAssignment
                WHERE PermissionSet.Name = 'VCC_Trainee'
            ]) {
                trainingUsers.add(
                    new TrainingUser(
                        permissionSetAssignment.AssigneeId,
                        permissionSetAssignment.Assignee.FirstName,
                        permissionSetAssignment.Assignee.LastName,
                        permissionSetAssignment.Assignee.Username,
                        permissionSetAssignment.Assignee.EmployeeNumber
                    )
                );
            }
        } catch (Exception e) {
        }
        return trainingUsers;
    }

    public class Model {
        @AuraEnabled
        public Boolean isTrainingModeEnabled { get; set; }
        @AuraEnabled
        public Boolean isTrainer { get; set; }
        @AuraEnabled
        public Boolean isTrainee { get; set; }
        @AuraEnabled
        public List<TrainingUser> trainingUsers { get; set; }

        public Model() {
            this.isTrainingModeEnabled = IS_TRAINING_MODE_ENABLED;
            this.isTrainer = IS_TRAINER;
            this.isTrainee = IS_TRAINEE;
            this.trainingUsers = getTrainingUsers();
        }
    }

    public class TrainingUser {
        @AuraEnabled
        public String userId { get; set; }
        @AuraEnabled
        public String firstName { get; set; }
        @AuraEnabled
        public String lastName { get; set; }
        @AuraEnabled
        public String username { get; set; }
        @AuraEnabled
        public String employeeNumber { get; set; }

        public TrainingUser() {
        }

        public TrainingUser(String assigneeId, String firstName, String lastName, String username, String employeeNumber) {
            this.userId = assigneeId;
            this.firstName = firstName;
            this.lastName = lastName;
            this.username = username;
            this.employeeNumber = employeeNumber;
        }
    }
}
