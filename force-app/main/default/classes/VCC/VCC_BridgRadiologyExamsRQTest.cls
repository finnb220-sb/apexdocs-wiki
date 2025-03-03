@isTest
public with sharing class VCC_BridgRadiologyExamsRQTest {
    @isTest
    public static void instantiations() {
        VCC_BridgRadiologyExamsRQ ctor1;
        VCC_BridgRadiologyExamsRQ ctor2;

        Test.startTest();
        ctor1 = new VCC_BridgRadiologyExamsRQ('test', 'test');
        ctor2 = new VCC_BridgRadiologyExamsRQ(new Map<String, Object>{ 'nationalId' => 'test', 'assigningAuthority' => 'test' });
        Test.stopTest();

        System.assert(ctor1 != null, 'Object did not instantiate correctly.');
        System.assert(ctor2 != null, 'Object did not instantiate correctly.');
    }

    @isTest
    public static void isValidTest() {
        VCC_BridgRadiologyExamsRQ invalid = new VCC_BridgRadiologyExamsRQ();
        VCC_BridgRadiologyExamsRQ valid = new VCC_BridgRadiologyExamsRQ('test', 'test');

        System.assert(invalid.isValid() == false, 'Expected to be invalid.');
        System.assert(valid.isValid() == true, 'Expected to be valid.');
    }
}
