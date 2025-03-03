@isTest
public with sharing class VCC_BridgConsultsRQTest {
    @isTest
    public static void instantiations() {
        VCC_BridgConsultsRQ ctor1;
        VCC_BridgConsultsRQ ctor2;
        VCC_BridgConsultsRQ ctor3;

        Test.startTest();
        ctor1 = new VCC_BridgConsultsRQ('test', 'test');
        ctor2 = new VCC_BridgConsultsRQ(new Map<String, Object>{ 'nationalId' => 'test', 'assigningAuthority' => 'test' });
        ctor3 = new VCC_BridgConsultsRQ('test', 'test', 2);
        Test.stopTest();

        System.assert(ctor1 != null, 'Object did not instantiate correctly.');
        System.assert(ctor2 != null, 'Object did not instantiate correctly.');
        System.assert(ctor3 != null, 'Object did not instantiate correctly.');
    }

    @isTest
    public static void isValidTest() {
        VCC_BridgConsultsRQ invalid = new VCC_BridgConsultsRQ();
        VCC_BridgConsultsRQ valid = new VCC_BridgConsultsRQ('test', 'test');

        System.assert(invalid.isValid() == false, 'Expected to be invalid.');
        System.assert(valid.isValid() == true, 'Expected to be valid.');
    }
}
