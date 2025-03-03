@isTest
public with sharing class VCC_BridgNotesRQTest {
    @isTest
    public static void instantiations() {
        VCC_BridgNotesRQ ctor1;
        VCC_BridgNotesRQ ctor2;

        Test.startTest();
        ctor1 = new VCC_BridgNotesRQ('test', 'test');
        ctor2 = new VCC_BridgNotesRQ(new Map<String, Object>{ 'nationalId' => 'test', 'assigningAuthority' => 'test' });
        Test.stopTest();

        System.assert(ctor1 != null, 'Object did not instantiate correctly.');
        System.assert(ctor2 != null, 'Object did not instantiate correctly.');
    }

    @isTest
    public static void isValidTest() {
        VCC_BridgNotesRQ invalid = new VCC_BridgNotesRQ();
        VCC_BridgNotesRQ valid = new VCC_BridgNotesRQ('test', 'test');

        System.assert(invalid.isValid() == false, 'Expected to be invalid.');
        System.assert(valid.isValid() == true, 'Expected to be valid.');
    }
}
