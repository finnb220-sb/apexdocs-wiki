@isTest
public with sharing class VCC_BridgFlagsRQTest {
    @isTest
    public static void instantiations() {
        VCC_BridgFlagsRQ ctor1;
        VCC_BridgFlagsRQ ctor2;

        Test.startTest();
        ctor1 = new VCC_BridgFlagsRQ('test', 'test');
        ctor2 = new VCC_BridgFlagsRQ(new Map<String, Object>{ 'nationalId' => 'test', 'assigningAuthority' => 'test' });
        Test.stopTest();

        System.assert(ctor1 != null, 'Object did not instantiate correctly.');
        System.assert(ctor2 != null, 'Object did not instantiate correctly.');
    }

    @isTest
    public static void isValidTest() {
        VCC_BridgFlagsRQ invalid = new VCC_BridgFlagsRQ();
        VCC_BridgFlagsRQ valid = new VCC_BridgFlagsRQ('test', 'test');

        System.assert(invalid.isValid() == false, 'Expected to be invalid.');
        System.assert(valid.isValid() == true, 'Expected to be valid.');
    }
}
