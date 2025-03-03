@isTest
public with sharing class VCC_BridgAdditionalSignersRQTest {
    @isTest
    public static void instantiations() {
        VCC_BridgAdditionalSignersRQ ctor1;
        VCC_BridgAdditionalSignersRQ ctor2;

        Test.startTest();
        ctor1 = new VCC_BridgAdditionalSignersRQ('test', 'test');
        ctor2 = new VCC_BridgAdditionalSignersRQ(new Map<String, Object>{ 'nationalId' => 'test', 'assigningAuthority' => 'test' });
        Test.stopTest();

        System.assert(ctor1 != null, 'Object did not instantiate correctly.');
        System.assert(ctor2 != null, 'Object did not instantiate correctly.');
    }

    @isTest
    public static void isValidTest() {
        VCC_BridgAdditionalSignersRQ invalid = new VCC_BridgAdditionalSignersRQ();
        VCC_BridgAdditionalSignersRQ valid = new VCC_BridgAdditionalSignersRQ('test', 'test');

        //System.assert(invalid.isValid() == false, 'Expected to be invalid.');
        System.assert(valid.isValid() == true, 'Expected to be valid.');
    }
}
