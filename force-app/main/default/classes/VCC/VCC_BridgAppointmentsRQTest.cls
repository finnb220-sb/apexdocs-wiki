@isTest
public with sharing class VCC_BridgAppointmentsRQTest {
    @isTest
    public static void instantiations() {
        VCC_BridgAppointmentsRQ ctor1;
        VCC_BridgAppointmentsRQ ctor2;

        Test.startTest();
        ctor1 = new VCC_BridgAppointmentsRQ('test', 'test');
        ctor2 = new VCC_BridgAppointmentsRQ(new Map<String, Object>{ 'nationalId' => 'test', 'assigningAuthority' => 'test' });
        Test.stopTest();

        System.assert(ctor1 != null, 'Object did not instantiate correctly.');
        System.assert(ctor2 != null, 'Object did not instantiate correctly.');
    }

    @isTest
    public static void isValidTest() {
        VCC_BridgAppointmentsRQ invalid = new VCC_BridgAppointmentsRQ();
        VCC_BridgAppointmentsRQ valid = new VCC_BridgAppointmentsRQ('test', 'test');

        System.assert(invalid.isValid() == false, 'Expected to be invalid.');
        System.assert(valid.isValid() == true, 'Expected to be valid.');
    }
}
