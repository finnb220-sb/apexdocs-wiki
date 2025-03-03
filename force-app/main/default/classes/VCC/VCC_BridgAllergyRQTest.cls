@isTest
public with sharing class VCC_BridgAllergyRQTest {
    @isTest
    public static void instantiations() {
        VCC_BridgAllergyRQ ctor1;
        VCC_BridgAllergyRQ ctor2;

        Test.startTest();
        ctor1 = new VCC_BridgAllergyRQ('test', 'test');
        ctor2 = new VCC_BridgAllergyRQ(new Map<String, Object>{ 'nationalId' => 'test', 'assigningAuthority' => 'test' });
        Test.stopTest();

        System.assert(ctor1 != null, 'Object did not instantiate correctly.');
        System.assert(ctor2 != null, 'Object did not instantiate correctly.');
    }

    @isTest
    public static void isValidTest() {
        VCC_BridgAllergyRQ invalid = new VCC_BridgAllergyRQ();
        VCC_BridgAllergyRQ valid = new VCC_BridgAllergyRQ('test', 'test');

        System.assert(invalid.isValid() == false, 'Expected to be invalid.');
        System.assert(valid.isValid() == true, 'Expected to be valid.');
    }
}
