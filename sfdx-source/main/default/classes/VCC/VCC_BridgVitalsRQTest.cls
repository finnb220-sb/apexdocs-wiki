@isTest
public with sharing class VCC_BridgVitalsRQTest {
    @isTest
    public static void instantiations() {
        VCC_BridgVitalsRQ ctor1;
        VCC_BridgVitalsRQ ctor2;

        Test.startTest();
        ctor1 = new VCC_BridgVitalsRQ('test', 'test');
        ctor2 = new VCC_BridgVitalsRQ(new Map<String, Object>{ 'nationalId' => 'test', 'assigningAuthority' => 'test' });
        Test.stopTest();

        System.assert(ctor1 != null, 'Object did not instantiate correctly.');
        System.assert(ctor2 != null, 'Object did not instantiate correctly.');
    }

    @isTest
    public static void isValidTest() {
        VCC_BridgVitalsRQ invalid = new VCC_BridgVitalsRQ();
        VCC_BridgVitalsRQ valid = new VCC_BridgVitalsRQ('test', 'test');

        System.assert(invalid.isValid() == false, 'Expected to be invalid.');
        System.assert(valid.isValid() == true, 'Expected to be valid.');
    }
}
