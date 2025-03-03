@isTest
public with sharing class VCC_VaProfileAssociatedPersonsRSTest {
    @IsTest
    static void ctor() {
        Test.startTest();
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        System.runAs(testuser) {
            System.assert(new VCC_VaProfileAssociatedPersonsRS() != null, 'Expected non-null.');
        }
        Test.stopTest();
    }
}
