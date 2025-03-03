/*
 * @description Test class for VCC_TrainingModeService
 *
 * @author Patrick Skamarak
 * @since 02/01/2023
 * updated 01/16/2024 by Kyle Martin - PMD compliance
 */
@IsTest
@SuppressWarnings('PMD.CyclomaticComplexity')
private without sharing class VCC_TrainingModeServiceTest {
    @IsTest
    private static void isValidEsigBaseTest() {
        try {
            Assert.isNull(VCC_TrainingModeService.isValidEsigBase(), 'Expected null because this method should return null');
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void signNoteBaseTest() {
        try {
            Assert.isNull(VCC_TrainingModeService.signNoteBase(), 'Expected null because this method should return null');
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void writeNoteBaseTest() {
        try {
            Assert.isNull(VCC_TrainingModeService.writeNoteBase(), 'Expected null because this method should return null');
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void getAllergiesByAccountIdTest() {
        try {
            Assert.isNull(VCC_TrainingModeService.getAllergiesByAccountId(null), 'Expected null because this method should return null');
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void getAppointmentsByAccountIdTest() {
        try {
            Assert.areEqual('{}', VCC_TrainingModeService.getAppointmentsByAccountId(null), 'Expected "{}" because this method should return it');
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void getConsultsByAccountIdTest() {
        try {
            Assert.isNull(VCC_TrainingModeService.getConsultsByAccountId(null), 'Expected null because this method should return null');
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void getDirectivesTest() {
        try {
            Assert.isNull(VCC_TrainingModeService.getDirectives(null), 'Expected null because this method should return null');
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void getDischargeSummariesByAccountIdTest() {
        try {
            Assert.isNull(VCC_TrainingModeService.getDischargeSummariesByAccountId(null), 'Expected null because this method should return null');
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void getFlagsByAccountIdTest() {
        try {
            Assert.isNull(VCC_TrainingModeService.getFlagsByAccountId(null), 'Expected null because this method should return null');
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void getImagingByAccountIdTest() {
        try {
            Assert.isNull(VCC_TrainingModeService.getImagingByAccountId(null), 'Expected null because this method should return null');
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void getImmunizationsByAccountIdTest() {
        try {
            Assert.isNull(VCC_TrainingModeService.getImmunizationsByAccountId(null), 'Expected null because this method should return null');
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void getLabsByAccountIdTest() {
        try {
            Assert.isNull(VCC_TrainingModeService.getLabsByAccountId(null), 'Expected null because this method should return null');
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void getMedicationsByAccountIdTest() {
        try {
            Assert.isNull(VCC_TrainingModeService.getMedicationsByAccountId(null), 'Expected null because this method should return null');
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void refillMedicationsTest() {
        try {
            VCC_TrainingModeService.refillMedications(null);
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void refillMedicationsTestTwoArg() {
        try {
            VCC_TrainingModeService.refillMedications(null, null);
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void refillMedicationsTestThreeArg() {
        try {
            VCC_TrainingModeService.refillMedications(null, null, null);
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void getOrdersByAccountIdTest() {
        try {
            Assert.isNull(VCC_TrainingModeService.getOrdersByAccountId(null), 'Expected null because this method returns null');
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void getPACTDataByAccountIdTest() {
        try {
            Assert.isNull(VCC_TrainingModeService.getPACTDataByAccountId(null), 'Expected null because this method returns null');
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void getProblemsByAccountIdTest() {
        try {
            Assert.isNull(VCC_TrainingModeService.getProblemsByAccountId(null), 'Expected null because this method returns null');
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void getProgressNotesByAccountIdTest() {
        try {
            Assert.isNull(VCC_TrainingModeService.getProgressNotesByAccountId(null), 'Expected null because this method returns null');
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void signProgressNoteTestOneArg() {
        try {
            VCC_TrainingModeService.signProgressNote(null);
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void signProgressNoteTestTwoArg() {
        try {
            VCC_TrainingModeService.signProgressNote(null, null);
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void getVetInfoByAccountIdTest() {
        try {
            Assert.isNull(VCC_TrainingModeService.getVetInfoByAccountId(null), 'Expected null because this method returns null');
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void writeVetInfoTestTwoArg() {
        try {
            VCC_TrainingModeService.writeVetInfo(null, null);
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void writeVetInfoTestThreeArg() {
        try {
            VCC_TrainingModeService.writeVetInfo(null, null, null);
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void writeVetInfoRqTest() {
        try {
            new VCC_TrainingModeService.WriteVetInfoRQ();
            new VCC_TrainingModeService.WriteVetInfoRQ(null);
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void getVisitsByAccountIdTest() {
        try {
            Assert.isNull(VCC_TrainingModeService.getVisitsByAccountId(null), 'Expected null because this method returns null');
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void getVitalsByAccountIdTest() {
        try {
            Assert.isNull(VCC_TrainingModeService.getVitalsByAccountId(null), 'Expected null because this method returns null');
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void isTrainingModeEnabledTest() {
        try {
            Assert.isFalse(VCC_TrainingModeService.isTrainingModeEnabled(), 'Expected false because this method returns false.');
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void resetTrainingDataForUsersTestOneArg() {
        try {
            VCC_TrainingModeService.resetTrainingDataForUsers(null);
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void resetTrainingDataForUsersTestTwoArg() {
        try {
            VCC_TrainingModeService.resetTrainingDataForUsers(null, null);
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void deleteTrainingDataForUsersTest() {
        try {
            VCC_TrainingModeService.deleteTrainingDataForUsers(null);
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void createTrainingDataForUsersTest() {
        try {
            VCC_TrainingModeService.createTrainingDataForUsers(null, null);
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void createMasterTrainingDataTest() {
        try {
            VCC_TrainingModeService.createMasterTrainingData(null, null);
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void createTrainingDataForUserTest() {
        try {
            VCC_TrainingModeService.createTrainingDataForUser(null, null, null);
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
        return;
    }

    @IsTest
    private static void getObjectNameFromIdTest() {
        try {
            Assert.isNull(VCC_TrainingModeService.getObjectNameFromId(null), 'Expected null because this method should return null');
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }

    @IsTest
    private static void getAccountIdTest() {
        try {
            Assert.isNull(VCC_TrainingModeService.getAccountId(null), 'Expected null because this method should return null');
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception ' + thrownException);
        }
    }
}
