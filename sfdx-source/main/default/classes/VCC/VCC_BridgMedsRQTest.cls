@isTest
public with sharing class VCC_BridgMedsRQTest {
    @isTest
    public static void instantiations() {
        VCC_BridgMedsRQ ctor1;
        VCC_BridgMedsRQ ctor2;

        Test.startTest();
        ctor1 = new VCC_BridgMedsRQ('test', 'test');
        ctor2 = new VCC_BridgMedsRQ(new Map<String, Object>{ 'nationalId' => 'test', 'assigningAuthority' => 'test' });
        Test.stopTest();

        System.assert(ctor1 != null, 'Object did not instantiate correctly.');
        System.assert(ctor2 != null, 'Object did not instantiate correctly.');
    }

    @isTest
    public static void isValidTest() {
        VCC_BridgMedsRQ invalid = new VCC_BridgMedsRQ();
        VCC_BridgMedsRQ valid = new VCC_BridgMedsRQ('test', 'test');

        System.assert(invalid.isValid() == false, 'Expected to be invalid.');
        System.assert(valid.isValid() == true, 'Expected to be valid.');
    }
    @isTest
    public static void unitPositiveVBridgMedsRQWithDuration() {
        VCC_BridgMedsRQ isValidBridg;
        Test.startTest();
        isValidBridg = new VCC_BridgMedsRQ('test', 'test', 12);
        Test.stopTest();
        Assert.isNotNull(isValidBridg, 'expected Bridg request to instantiate');
    }

    @isTest
    public static void unitPositiveVBridgMedsRQwithDate() {
        VCC_BridgMedsRQ isValidBridg;
        Test.startTest();
        isValidBridg = new VCC_BridgMedsRQ('test', '01-01-2024', 'test');
        Test.stopTest();

        Assert.isNotNull(isValidBridg, 'expected Bridg request to instantiate');
    }
}
