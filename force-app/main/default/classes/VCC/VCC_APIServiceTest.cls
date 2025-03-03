@isTest
public with sharing class VCC_APIServiceTest {
    @isTest
    public static void debugModeTest() {
        System.assert(!VCC_APIService.Bridg.isDebugModeEnabled(), 'Debug mode should not be enabled.');
        System.assert(!VCC_APIService.VDIF.isDebugModeEnabled(), 'Debug mode should not be enabled.');
        System.assert(!VCC_APIService.Bridg.isTrainingModeEnabled(), 'Training mode should not be enabled.');
        System.assert(!VCC_APIService.VDIF.isTrainingModeEnabled(), 'Training mode should not be enabled.');

        VCC_APIService.debugMode(true);
        VCC_APIService.trainingMode(true);

        System.assert(VCC_APIService.Bridg.isDebugModeEnabled(), 'Debug mode should be enabled.');
        System.assert(VCC_APIService.VDIF.isDebugModeEnabled(), 'Debug mode should be enabled.');
        System.assert(VCC_APIService.Bridg.isTrainingModeEnabled(), 'Training mode should be enabled.');
        System.assert(VCC_APIService.VDIF.isTrainingModeEnabled(), 'Training mode should be enabled.');
    }
}
