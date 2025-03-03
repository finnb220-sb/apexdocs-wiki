public with sharing class VCC_TestRunCalloutService {
    public static VCC_TestRunCalloutService instance {
        get {
            if (privateInstance != null) {
                return privateInstance;
            }
            privateInstance = new VCC_TestRunCalloutService();
            return privateInstance;
        }
    }

    @TestVisible
    private static VCC_TestRunCalloutService privateInstance;

    @TestVisible
    private static VCC_Stub stub() {
        VCC_Stub testRunCalloutServiceStub = new VCC_Stub(VCC_TestRunCalloutService.class);
        VCC_TestRunCalloutService.privateInstance = (VCC_TestRunCalloutService) testRunCalloutServiceStub.instance;
        return testRunCalloutServiceStub;
    }

    public VCC_Test_Run_Callout__c insertNewTestRunCallout(VCC_Test_Run__c testRun, VCC_Callout_Data__c calloutData) {
        VCC_Test_Run_Callout__c testRunCallout = new VCC_Test_Run_Callout__c(VCC_Callout__c = calloutData?.Id, VCC_Test_Run__c = testRun?.Id);

        fflib_ISObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<Schema.SObjectType>{ VCC_Test_Run_Callout__c.SObjectType });
        uow.registerNew(testRunCallout);
        uow.commitWork();
        return testRunCallout;
    }
}
