@isTest
public with sharing class VCC_BridgProblemsRQTest {
    @isTest
    public static void instantiations() {
        VCC_BridgProblemsRQ ctor1;
        VCC_BridgProblemsRQ ctor2;

        Test.startTest();
        ctor1 = new VCC_BridgProblemsRQ('test', 'test');
        ctor2 = new VCC_BridgProblemsRQ(new Map<String, Object>{ 'nationalId' => 'test', 'assigningAuthority' => 'test' });
        Test.stopTest();

        System.assert(ctor1 != null, 'Object did not instantiate correctly.');
        System.assert(ctor2 != null, 'Object did not instantiate correctly.');
    }

    @isTest
    public static void isValidTest() {
        VCC_BridgProblemsRQ invalid = new VCC_BridgProblemsRQ();
        VCC_BridgProblemsRQ valid = new VCC_BridgProblemsRQ('test', 'test');

        System.assert(invalid.isValid() == false, 'Expected to be invalid.');
        System.assert(valid.isValid() == true, 'Expected to be valid.');
    }
}
