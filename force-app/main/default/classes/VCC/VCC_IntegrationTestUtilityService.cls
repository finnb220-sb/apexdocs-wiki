public with sharing class VCC_IntegrationTestUtilityService {
    public static VCC_IntegrationTestUtilityService instance {
        get {
            if (privateInstance != null) {
                return privateInstance;
            }
            privateInstance = new VCC_IntegrationTestUtilityService();
            return privateInstance;
        }
    }

    @TestVisible
    private static VCC_IntegrationTestUtilityService privateInstance;

    @TestVisible
    private static VCC_Stub stub() {
        VCC_Stub integrationTestUtilServiceStub = new VCC_Stub(VCC_IntegrationTestUtilityService.class);
        VCC_IntegrationTestUtilityService.privateInstance = (VCC_IntegrationTestUtilityService) integrationTestUtilServiceStub.instance;
        return integrationTestUtilServiceStub;
    }

    public void assert(Boolean condition, String message) {
        if (condition == true) {
            return;
        }
        throw new AssertFailedException(message);
    }

    public List<VCC_Test_Configuration_Data__c> getVdifTestRunConfigData(List<String> siteCodes) {
        return this.getVdifTestRunConfigData(siteCodes, new VCC_TestConfigurationDataSelector());
    }

    public List<VCC_Test_Configuration_Data__c> getVdifTestRunConfigData(List<String> siteCodes, VCC_TestConfigurationDataSelector testConfigDataSelector) {
        if (siteCodes == null || siteCodes.isEmpty()) {
            return new List<VCC_Test_Configuration_Data__c>();
        }
        return testConfigDataSelector.selectVdifTestPatientData(siteCodes);
    }

    public class AssertFailedException extends Exception {
    }
}
