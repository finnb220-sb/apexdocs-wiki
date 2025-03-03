@isTest
private with sharing class VCC_DivaRequestTest {
    @isTest
    static void testCtor() {
        VCC_DivaRequest divaRequest = new VCC_DivaRequest();
        System.Assert(divaRequest != null, 'expected diva request be instantiated');
    }
}
