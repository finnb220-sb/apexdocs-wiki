@isTest
private with sharing class VCC_DivaResponseTest {
    @isTest
    static void testCtor() {
        VCC_DivaResponse divaRes = new VCC_DivaResponse();
        System.Assert(divaRes != null, 'expected diva response be instantiated');
    }
}
