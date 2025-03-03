@IsTest
private with sharing class VCC_TraineeListControllerTest {
    @IsTest
    private static void ctor() {
        VCC_TraineeListController traineeListController = new VCC_TraineeListController();
        System.assert(traineeListController != null, 'Expected class to be initialized.');
    }

    @IsTest
    private static void searchUsers() {
        VCC_TraineeListController.searchUsers('');
    }

    @IsTest
    private static void searchByDivision() {
        VCC_TraineeListController.searchByDivision('');
    }

    @IsTest
    private static void searchByTitle() {
        VCC_TraineeListController.searchByTitle('');
    }

    @IsTest
    private static void searchUsersByRange() {
        VCC_TraineeListController.searchByRange(1, 1);
    }

    @IsTest
    private static void getActiveTrainees() {
        VCC_TraineeListController.getActiveTrainees(new List<User>());
    }

    @IsTest
    private static void resetTrainingDataForUsers() {
        VCC_TraineeListController.resetTrainingDataForUsers(new List<String>());
    }

    @IsTest
    private static void checkJobStatus() {
        VCC_TraineeListController.checkJobStatus('');
    }
}
