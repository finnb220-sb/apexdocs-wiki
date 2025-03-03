@isTest
public with sharing class VCC_BridgOrdersRQTest {
    @isTest
    public static void instantiations() {
        VCC_BridgOrdersRQ ctor1;
        VCC_BridgOrdersRQ ctor2;
        VCC_BridgOrdersRQ ctor3;

        Test.startTest();
        ctor1 = new VCC_BridgOrdersRQ('test', 'test');
        ctor2 = new VCC_BridgOrdersRQ(new Map<String, Object>{ 'nationalId' => 'test', 'assigningAuthority' => 'test' });
        ctor3 = new VCC_BridgOrdersRQ('test', 'test', 2);
        Test.stopTest();

        System.assert(ctor1 != null, 'Object did not instantiate correctly.');
        System.assert(ctor2 != null, 'Object did not instantiate correctly.');
        System.assert(ctor3 != null, 'Object did not instantiate correctly.');
    }

    @isTest
    public static void isValidTest() {
        VCC_BridgOrdersRQ invalid = new VCC_BridgOrdersRQ();
        VCC_BridgOrdersRQ valid = new VCC_BridgOrdersRQ('test', 'test');

        System.assert(invalid.isValid() == false, 'Expected to be invalid.');
        System.assert(valid.isValid() == true, 'Expected to be valid.');
    }
}
