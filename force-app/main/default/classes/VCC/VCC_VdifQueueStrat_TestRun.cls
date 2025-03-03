/**
 * @description Describes behavior the virtual VdifQueueableCallback.Strategy methods specifically for the
 * Test Run functionality.Each of these methods are called based on the output of each call.
 */
public with sharing class VCC_VdifQueueStrat_TestRun implements VCC_VdifQueueableCallback.Strategy {
    /**
     * @description Based on the type of Test Run enqueued by the user, this constructor chooses the
     * appropriate subStrategy to base the Strategy methods on
     * @param testRun
     * @param testPatientMetadata
     */
    public VCC_VdifQueueStrat_TestRun(VCC_Test_Run__c testRun, VCC_Test_Configuration_Data__c testPatientMetadata) {
        this.testRun = testRun;
        switch on testRun.VCC_Sub_Category__c {
            when 'Create encounter, note, and sign' {
                this.subStrategy = new VCC_VdifTestRun_Encounter(testPatientMetadata);
            }
            when 'Create note, addendum, and sign' {
                this.subStrategy = new VCC_VdifTestRun_Note(testPatientMetadata);
            }
        }
    }

    @TestVisible
    private VCC_VdifQueueStrat_TestRun() {
        Logger.error('Empty constructor.');
        Logger.saveLog();
    }

    private VCC_Test_Run__c testRun { get; set; }

    @TestVisible
    private VCC_VdifQueueableCallback.Strategy subStrategy { get; set; }
    /**
     * @description When a queue job begins, this is called. It correlates a Nebula log to the test run,
     * then calls onQueueableStart on either VCC_VdifTestRun_Encounter or VCC_VdifTestRun_Note to set parameters
     * that will be used in each stage
     * @param vdifQueueableCallback
     */
    public void onQueueableStart(VCC_VdifQueueableCallback vdifQueueableCallback) {
        if (this.testRun.VCC_Log_Correlation_Id__c == null) {
            this.testRun.VCC_Log_Correlation_Id__c = Logger.getTransactionId();
        } else {
            Logger.setParentLogTransactionId(this.testRun.VCC_Log_Correlation_Id__c);
        }
        VCC_HttpIntercept_Observer.observeNext();
        this.subStrategy.onQueueableStart(vdifQueueableCallback);
    }
    /**
     * @description If an exception occurs, this method builds the exception within the VCC_Output__c
     * field on the test run
     * @param e
     * @param vdifQueueableCallback
     */
    public void onException(Exception e, VCC_VdifQueueableCallback vdifQueueableCallback) {
        Logger.error('Exception', e);
        this.testRun.VCC_Status__c = 'FAIL';
        this.testRun.VCC_Output__c = '';
        this.testRun.VCC_Output__c += '\n' + 'Failure during stage: ' + vdifQueueableCallback.getStage();
        this.testRun.VCC_Output__c += '\n' + e.getMessage();
        this.testRun.VCC_Output__c += '\n' + e.getStackTraceString();
        addCalloutData();
        VCC_TestRunService.instance.updateTestRun(this.testRun);
        Logger.saveLog();
    }
    /**
     * @description When a response from a callout is received, validates that the isValidEsigTextTO property is
     * true, then calls the onCalloutResponse method on the appropriate subStrategy
     * @param response
     * @param vdifQueueableCallback
     */
    public void onCalloutResponse(Object response, VCC_VdifQueueableCallback vdifQueueableCallback) {
        switch on vdifQueueableCallback.getStage() {
            when VALIDATE_ESIG {
                VCC_IntegrationTestUtilityService.instance.assert(
                    ((VCC_VdifIsValidEsigRS) response).isValidEsigTextTO.text == 'True',
                    'Expected isValidEsigTextTO.text to be "True"'
                );
            }
            when else {
                this.subStrategy.onCalloutResponse(response, vdifQueueableCallback);
            }
        }
    }
    /**
     * @description Checks what the current stage is. If it is the end of the workflow for Test Runs, then it sets
     * the test run status to PASS and ends the queue chain. If it is not the end, it enqueues the next stage by
     * calling onQueueableEnd on the associated subStrategy.
     * @param vdifQueueableCallback
     */
    public void onQueueableEnd(VCC_VdifQueueableCallback vdifQueueableCallback) {
        if (
            (this.testRun.VCC_Sub_Category__c == 'Create note, addendum, and sign' &&
            vdifQueueableCallback.getPreviousStage() == VCC_VdifQueueableCallback.Stage.CREATE_ADDENDUM) ||
            (this.testRun.VCC_Sub_Category__c == 'Create encounter, note, and sign' &&
            vdifQueueableCallback.getStage() == VCC_VdifQueueableCallback.Stage.SIGN_NOTE)
        ) {
            this.testRun.VCC_Status__c = 'PASS';
            VCC_TestRunService.instance.updateTestRun(this.testRun);
        } else {
            this.subStrategy.onQueueableEnd(vdifQueueableCallback);
        }
        addCalloutData();
        Logger.saveLog();
    }
    /**
     * @description Creates a record of VCC_Callout_Data__c based on the current in-memory state of
     * VCC_HttpIntercept_Observer.HttpData by calling VCC_TestRunService.addCalloutData()
     */
    public void addCalloutData() {
        VCC_HttpIntercept_Observer.HttpData httpData = VCC_HttpIntercept_Observer.getData();
        if (httpData == null) {
            return;
        }
        VCC_TestRunService.instance.addCalloutData(this.testRun, httpData);
    }
}
