@IsTest
@SuppressWarnings('PMD.ApexDoc')
public with sharing class VCC_BridgImmunizationRQTest {
    @IsTest
    private static void instantiations() {
        VCC_BridgImmunizationRQ ctor1;
        VCC_BridgImmunizationRQ ctor2;

        Test.startTest();
        ctor1 = new VCC_BridgImmunizationRQ('test', 'test');
        ctor2 = new VCC_BridgImmunizationRQ(new Map<String, Object>{ 'nationalId' => 'test', 'assigningAuthority' => 'test' });
        Test.stopTest();

        System.assert(ctor1 != null, 'Object did not instantiate correctly.');
        System.assert(ctor2 != null, 'Object did not instantiate correctly.');
    }

    @IsTest
    private static void isValidTest() {
        VCC_BridgImmunizationRQ invalid = new VCC_BridgImmunizationRQ();
        VCC_BridgImmunizationRQ valid = new VCC_BridgImmunizationRQ('test', 'test');

        System.assert(invalid.isValid() == false, 'Expected to be invalid.');
        System.assert(valid.isValid() == true, 'Expected to be valid.');
    }
}
