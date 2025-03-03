@isTest
public with sharing class VCC_BridgVisitsRQTest {
    @isTest
    public static void instantiations() {
        VCC_BridgVisitsRQ ctor1;
        VCC_BridgVisitsRQ ctor2;

        Test.startTest();
        ctor1 = new VCC_BridgVisitsRQ('test', 'test');
        ctor2 = new VCC_BridgVisitsRQ(new Map<String, Object>{ 'nationalId' => 'test', 'assigningAuthority' => 'test' });
        Test.stopTest();

        System.assert(ctor1 != null, 'Object did not instantiate correctly.');
        System.assert(ctor2 != null, 'Object did not instantiate correctly.');
    }

    @isTest
    public static void isValidTest() {
        VCC_BridgVisitsRQ invalid = new VCC_BridgVisitsRQ();
        VCC_BridgVisitsRQ valid = new VCC_BridgVisitsRQ('test', 'test');

        System.assert(invalid.isValid() == false, 'Expected to be invalid.');
        System.assert(valid.isValid() == true, 'Expected to be valid.');
    }
}
