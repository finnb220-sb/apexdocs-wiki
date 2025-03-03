public with sharing class VCC_TestRunService {
    public static VCC_TestRunService instance {
        get {
            if (privateInstance != null) {
                return privateInstance;
            }
            privateInstance = new VCC_TestRunService();
            return privateInstance;
        }
    }

    @TestVisible
    private static VCC_TestRunService privateInstance;

    @TestVisible
    private static VCC_Stub stub() {
        VCC_Stub testRunServiceStub = new VCC_Stub(VCC_TestRunService.class);
        VCC_TestRunService.privateInstance = (VCC_TestRunService) testRunServiceStub.instance;
        return testRunServiceStub;
    }

    public VCC_TestRunService() {
        if (privateInstance == null) {
            privateInstance = this;
        } else {
            throw new AuraHandledException('Instance of this class already exists.');
        }
    }

    public VCC_Test_Run__c insertTestRun(VCC_Test_Run__c testRun) {
        return this.insertTestRuns(new List<VCC_Test_Run__c>{ testRun })[0];
    }

    public List<VCC_Test_Run__c> insertTestRuns(List<VCC_Test_Run__c> testRunList) {
        fflib_ISObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<Schema.SObjectType>{ VCC_Test_Run__c.SObjectType });
        uow.registerNew(testRunList);
        uow.commitWork();
        return testRunList;
    }

    public void updateTestRun(VCC_Test_Run__c testRun) {
        this.updateTestRuns(new List<VCC_Test_Run__c>{ testRun });
    }

    public void updateTestRuns(List<VCC_Test_Run__c> testRunList) {
        fflib_ISObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<Schema.SObjectType>{ VCC_Test_Run__c.SObjectType });
        uow.registerDirty(testRunList);
        uow.commitWork();
    }

    public VCC_Test_Run_Callout__c addCalloutData(VCC_Test_Run__c testRun, VCC_HttpIntercept_Observer.HttpData httpData) {
        if (httpData.requestEndpoint == null) {
            return null;
        }
        VCC_Callout_Data__c calloutData = VCC_CalloutDataService.instance.insertNewCalloutData(httpData);
        return VCC_TestRunCalloutService.instance.insertNewTestRunCallout(testRun, calloutData);
    }

    public final String INVALID_CONFIG = 'VCC_Test_Configuration_Data__c record with Id {0} is invalid because {1}.';

    public void raiseInvalidConfigurationException(Id recordId, String invalidReason) {
        throw new InvalidConfigurationException(String.format(this.INVALID_CONFIG, new List<String>{ recordId, invalidReason }));
    }

    public void validateVdifTestConfiguration(VCC_Test_Configuration_Data__c testConfig) {
        if (String.isBlank(testConfig.VCC_ICN__c) && String.isBlank(testConfig.VCC_Account_Id__c)) {
            raiseInvalidConfigurationException(testConfig.Id, 'both VCC_Account_Id__c and VCC_ICN__c are blank.');
        }

        if (String.isBlank(testConfig.VCC_Note_Title_IEN__c) && String.isBlank(testConfig.VCC_Note_Title_IEN_For_Encounter__c)) {
            raiseInvalidConfigurationException(testConfig.Id, 'a value is missing from either VCC_Note_Title_IEN__c or VCC_Note_Title_IEN_For_Encounter__c');
        }

        if (String.isBlank(testConfig.VCC_Note_Title_IEN__c) && String.isBlank(testConfig.VCC_Note_Title_IEN_For_Encounter__c)) {
            raiseInvalidConfigurationException(testConfig.Id, 'both VCC_Note_Title_IEN__c and VCC_Note_Title_IEN_For_Encounter__c have values');
        }

        if (String.isBlank(testCOnfig.VCC_Location_IEN__c)) {
            raiseInvalidConfigurationException(testCOnfig.Id, 'value missing from VCC_Location_IEN__c');
        }
    }

    public class InvalidConfigurationException extends Exception {
    }
}
