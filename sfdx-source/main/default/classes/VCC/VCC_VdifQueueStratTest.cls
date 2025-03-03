@isTest
public with sharing class VCC_VdifQueueStratTest implements VCC_VdifQueueableCallback.Strategy {
    public Boolean onQueueableStartCalled = false;
    public Boolean onExceptionCalled = false;
    public Boolean onCalloutResponseCalled = false;
    public Boolean onQueueableEndCalled = false;

    public Boolean throwMockException = false;

    /**
     * @description This method is used to mock calls to onQueueableStart
     * @param vdifQueueableCallback
     * @exception
     */
    public void onQueueableStart(VCC_VdifQueueableCallback vdifQueueableCallback) {
        this.onQueueableStartCalled = true;
        if (this.throwMockException == true) {
            throw new MockException('MOCK EXCEPTION');
        }
    }
    /**
     * @description This method is used to mock calls to onException
     * @param e
     * @param vdifQueueableCallback
     */
    public void onException(Exception e, VCC_VdifQueueableCallback vdifQueueableCallback) {
        this.onExceptionCalled = true;
    }
    /**
     * @description This method is used to mock calls to onCalloutResponse
     * @param response
     * @param vdifQueueableCallback
     */
    public void onCalloutResponse(Object response, VCC_VdifQueueableCallback vdifQueueableCallback) {
        this.onCalloutResponseCalled = true;
    }
    /**
     * @description This method is used to mock calls to onQueueableEnd
     * @param vdifQueueableCallback
     */
    public void onQueueableEnd(VCC_VdifQueueableCallback vdifQueueableCallback) {
        this.onQueueableEndCalled = true;
    }
    /**
     * @description Custom exception class
     */
    public class MockException extends Exception {
    }
}
