/**
 * @description Test class for VCC_DASBaseRQ
 * @author      Booz Allen
 * @see         VCC_DASBaseRQ
 */
@IsTest
public with sharing class VCC_DASBaseRQTest {
    /**
     * @description This is a test class that extends VCC_DASBaseRQ.
     * It overrides the isValid method to return true if the testProperty is not an empty string.
     * @see VCC_DASBaseRQ
     */
    public class TestBaseRQ extends VCC_DASBaseRQ {
        public String testProperty {
            get {
                return propertyGetter(testProperty);
            }
            set;
        }

        /**
         * @description This method returns true if the testProperty is not an empty string.
         * @return Boolean
         */
        public override Boolean isValid() {
            if (testProperty != '') {
                return true;
            }
            return false;
        }
    }

    /**
     * @description This test method tests the getter and setter of the testProperty and the isValid method.
     * It asserts that the initial value of testProperty is an empty string, and that it can be set to a new value.
     * It also asserts that the isValid method returns true when the testProperty is not an empty string.
     */
    @IsTest
    static void baseRqGetterTest() {
        Test.startTest();
        try {
            TestBaseRQ testBaseRq = new TestBaseRQ();
            Assert.areEqual('', testBaseRq.testProperty, 'Expected an empty string.');
            testBaseRq.testProperty = 'test';
            Assert.areEqual('test', testBaseRq.testProperty, 'Expected the value to equal test.');
            Assert.areEqual(true, testBaseRq.isValid(), 'Expected isValid to be true.');
        } catch (Exception e) {
            Assert.fail('Unexpected exception ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void baseRqSerializeTest() {
        Test.startTest();
        try {
            TestBaseRQ testBaseRq = new TestBaseRQ();
            Map<String, Object> roundTripSerializeDeserialize = (Map<String, Object>) JSON.deserializeUntyped(
                JSON.serialize(testBaseRq)
            );
            Assert.areEqual('', roundTripSerializeDeserialize.get('testProperty'), 'Expected an empty string');
        } catch (Exception e) {
            Assert.fail('Unexpected exception ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void baseRqIsValidTest() {
        Test.startTest();
        try {
            TestBaseRQ testBaseRq = new TestBaseRQ();
            Assert.areEqual(false, testBaseRq.isValid(), 'Expected isValid to be true.');
        } catch (Exception e) {
            Assert.fail('Unexpected exception ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }
}
