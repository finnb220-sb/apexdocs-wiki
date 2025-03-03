/**
 * @description Test class for VCC_OmniRemoteAction
 * @author Booz Allen Hamilton
 * @see `VCC_OmniRemoteAction`
 */
@IsTest
private with sharing class VCC_OmniRemoteActionTest {
    /**
     * @description memoized standard user
     */
    private static User standardUser {
        get {
            return standardUser = standardUser ??
                new VATEST_UserBuilder().withUserProfile('Standard User').withStandardData().build(true);
        }
        set;
    }

    /**
     * @description tests that the reference to the input args (input, output, and options) remains intact after the constructor
     * run and that the inputs are mapped to the expected properties/attributes in ArgTuple
     */
    @IsTest
    static void unitArgTupleConstructorPositive() {
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        String callableMethodName = 'method';
        Map<String, Object> callableArgsMap = new Map<String, Object>{
            'input' => input,
            'output' => output,
            'options' => options
        };

        System.runAs(standardUser) {
            Test.startTest();
            VCC_OmniRemoteAction.ArgTuple argTuple = new VCC_OmniRemoteAction.ArgTuple(
                callableMethodName,
                callableArgsMap
            );
            Test.stopTest();
            Assert.isTrue(
                argTuple.input === input,
                'Expected argTuple.input to reference the same map as local variable "input" given it was passed as the constructors first argument'
            );
            Assert.isTrue(
                argTuple.output === output,
                'Expected argTuple.output to reference the same map as local variable "output" given it was passed as the constructors second argument'
            );
            Assert.isTrue(
                argTuple.options === options,
                'Expected argTuple.options to reference the same map as local variable "options" given it was passed as the constructors third argument'
            );
        }
    }

    /**
     * @description tests that, given null second argument, the constructor throws an IllegalArgumentException with the correct exception message
     */
    @IsTest
    static void unitArgTupleConstructorNullMapNegative() {
        VCC_OmniRemoteAction.ArgTuple argTuple;
        System.runAs(standardUser) {
            Test.startTest();
            try {
                argTuple = new VCC_OmniRemoteAction.ArgTuple('test', null);
                Assert.fail('Expected an IllegalArgumentException because the second constructor argument is null');
            } catch (IllegalArgumentException illegalArgumentException) {
                Assert.areEqual(
                    VCC_OmniRemoteAction.ARG_TUPLE_INVALID_OR_MISSING_MAP,
                    IllegalArgumentException.getMessage(),
                    'Expected exception message to match that stored in variable VCC_OmniRemoteAction.ARG_TUPLE_INVALID_OR_MISSING_MAP given the second constructor argument was null'
                );
            }
            Test.stopTest();
        }
    }

    /**
     * @description tests that, given null second argument, the constructor throws an IllegalArgumentException with the correct exception message
     */
    @IsTest
    static void unitArgTupleConstructorNullMethodNameNegative() {
        VCC_OmniRemoteAction.ArgTuple argTuple;
        System.runAs(standardUser) {
            Test.startTest();
            try {
                argTuple = new VCC_OmniRemoteAction.ArgTuple(
                    null,
                    new Map<String, Object>{
                        'input' => new Map<String, Object>(),
                        'output' => new Map<String, Object>(),
                        'options' => new Map<String, Object>()
                    }
                );
                Assert.fail('Expected an IllegalArgumentException because the first constructor argument is null');
            } catch (IllegalArgumentException illegalArgumentException) {
                Assert.areEqual(
                    VCC_OmniRemoteAction.ARG_TUPLE_INVALID_OR_MISSING_METHOD_NAME,
                    IllegalArgumentException.getMessage(),
                    'Expected exception message to match that stored in variable VCC_OmniRemoteAction.ARG_TUPLE_INVALID_OR_MISSING_MAP given the first constructor argument was null'
                );
            }
            Test.stopTest();
        }
    }

    /**
     * @description class made specifically for testing VCC_OmniRemoteAction because its abstract and cannot be constructed
     */
    class TestRemoteAction extends VCC_OmniRemoteAction {
        public VCC_OmniRemoteAction.ArgTuple receivedTuple;
        public String receivedMethodName;

        protected override Object call(VCC_OmniRemoteAction.ArgTuple argTuple) {
            this.receivedMethodName = argTuple?.methodName;
            this.receivedTuple = argTuple;
            return true;
        }
    }

    /**
     * @description using TestRemoteAction, tests that the methodName and argTuple passed into VCC_OmniRemoteAction.call
     * are received by TestRemoteAction
     */
    @IsTest
    static void unitInvokeMethodPositive() {
        String methodName = 'someMethod';
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        TestRemoteAction testRemoteAction;
        System.runAs(standardUser) {
            Test.startTest();
            testRemoteAction = new TestRemoteAction();
            testRemoteAction.call(
                methodName,
                new Map<String, Object>{ 'input' => input, 'output' => output, 'options' => options }
            );
            Test.stopTest();
        }

        Assert.areEqual(
            methodName,
            testRemoteAction.receivedMethodName,
            'Expected method names to match given TestRemoteAction captures the methodName and assigns it to attribute receivedMethodName'
        );
        VCC_OmniRemoteAction.ArgTuple argTuple = testRemoteAction.receivedTuple;
        Assert.isTrue(
            argTuple.input === input,
            'Expected argTuple.input to reference the same map as local variable "input" given that the map was passed into .call in a map with key "input"'
        );
        Assert.isTrue(
            argTuple.output === output,
            'Expected argTuple.output to reference the same map as local variable "output" given that the map was passed into .call in a map with key "output"'
        );
        Assert.isTrue(
            argTuple.options === options,
            'Expected argTuple.options to reference the same map as local variable "options" given that the map was passed into .call in a map with key "options"'
        );
    }

    /**
     * @description Tests that, given a null method name and an empty map, TestRemoteAction receives the same thing with no exception thrown
     */
    @IsTest
    static void unitInvokeMethodNullNegative() {
        TestRemoteAction testRemoteAction;
        System.runAs(standardUser) {
            Test.startTest();
            testRemoteAction = new TestRemoteAction();
            try {
                testRemoteAction.call((String) null, new Map<String, Object>());
                Assert.fail('Expected an IllegalArgumentException because the first constructor argument is null');
            } catch (IllegalArgumentException illegalArgumentException) {
                Assert.areEqual(
                    VCC_OmniRemoteAction.ARG_TUPLE_INVALID_OR_MISSING_METHOD_NAME,
                    IllegalArgumentException.getMessage(),
                    'Expected exception message to match that stored in variable VCC_OmniRemoteAction.ARG_TUPLE_INVALID_OR_MISSING_MAP given the first constructor argument was null'
                );
            }
            Test.stopTest();
        }
    }
}
