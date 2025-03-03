/**
 * @description Test class for VCC_VaProfileAssociatedPersonsRQ object
 * @author Liberty
 * @since 01/07/2024
 */
@isTest
public with sharing class VCC_VaProfileAssociatedPersonsRQTest {
    @IsTest
    static void ctor() {
        Test.startTest();
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        System.runAs(testuser) {
            System.assert(new VCC_VaProfileAssociatedPersonsRQ() != null, 'Expected non-null.');
        }
        Test.stopTest();
    }
}
