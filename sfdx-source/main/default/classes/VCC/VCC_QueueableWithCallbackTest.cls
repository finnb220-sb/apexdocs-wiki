@isTest
public with sharing class VCC_QueueableWithCallbackTest {
    @testSetup
    static void makeData() {
        VCC_TestDataFactory.insertUser('System Administrator');
    }
    /**
     * @description create a test user for running tests
     * @return A test user
     **/
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
    }
    @IsTest
    static void executeTest() {
        System.runAs(getTestUser()) {
            Object fakeQueueableContext;
            VCC_ACallable aCallable = new VCC_ACallable();
            VCC_QueueWithCallbackTestClass queueWithCallbackTestObject = new VCC_QueueWithCallbackTestClass(aCallable);

            Test.startTest();
            queueWithCallbackTestObject.execute(aCallable, (System.QueueableContext) fakeQueueableContext);
            System.enqueueJob(queueWithCallbackTestObject);
            Test.stopTest();

            System.assert(aCallable.called == true, 'Callable was not called as expected.');
        }
    }

    private class VCC_QueueWithCallbackTestClass extends VCC_QueueableWithCallback {
        public override void execute(Callable callback, System.QueueableContext queueableContext) {
            callback.call('anAction', new Map<String, Object>{ 'arg1' => 'value' });
        }

        public VCC_QueueWithCallbackTestClass(Callable callback) {
            super(callback);
        }
    }

    private class VCC_ACallable implements Callable {
        public Boolean called = false;

        public Object call(String action, Map<String, Object> args) {
            switch on action {
                when 'anAction' {
                    this.called = true;
                    return 'a return value';
                }
            }
            return null;
        }
    }
}
