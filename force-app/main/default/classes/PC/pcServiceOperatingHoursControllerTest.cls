/**
 * @description Test class for pcServiceOperatingHoursController
 * @author      Booz Allen
 * @since       2024
 * @see         pcServiceOperatingHoursController
 */
@IsTest
@SuppressWarnings('PMD.ClassNamingConventions')
public with sharing class pcServiceOperatingHoursControllerTest {
    @IsTest
    static void unitGetOperatingHoursTest() {
        User specialistManagerUser = generateUserWithAccess('PrC_Specialist_Manager_Users');
        String serviceId;
        pcServiceOperatingHoursController.DataTableResponse response;

        System.runAs(specialistManagerUser) {
            PC_Service__c service = new PC_Service__c();
            service.PC_Time_Zone__c = 'Central Standard Time'; //Bama Represent!
            insert service;
            serviceId = service.Id;

            //Operating Hour is created automatically when a Service is created
            List<PC_Operating_Hours__c> autoCreatedOperatingHours = [SELECT Id FROM PC_Operating_Hours__c];

            PC_Exception__c exceptionTest = new PC_Exception__c();
            exceptionTest.PC_Date__c = System.today();
            exceptionTest.PC_Start_Time__c = Time.newInstance(1, 2, 3, 4);
            exceptionTest.PC_End_Time__c = Time.newInstance(1, 2, 3, 4);
            exceptionTest.PC_Operating_Hours__c = autoCreatedOperatingHours[0].Id;
            exceptionTest.PC_Service__c = service.Id;
            insert exceptionTest;

            Test.startTest();
            response = pcServiceOperatingHoursController.getOperatingHours(serviceId);
            Test.stopTest();
        }

        System.assertEquals(serviceId, response.Id, 'Expected values to match');
        System.assert(response.TimeSlots.size() > 0, 'Expected values to match');
        System.assert(response.Exceptions.size() > 0, 'Expected values to match');
    }

    @IsTest
    static void unitExceptionTableWrapperCompareTotest() {
        pcServiceOperatingHoursController.ExceptionTableWrapper earlierDate = new pcServiceOperatingHoursController.ExceptionTableWrapper();
        earlierDate.DateHold = Date.newInstance(2023, 1, 1);

        pcServiceOperatingHoursController.ExceptionTableWrapper laterDate = new pcServiceOperatingHoursController.ExceptionTableWrapper();
        laterDate.DateHold = Date.newInstance(2023, 1, 2);

        pcServiceOperatingHoursController.ExceptionTableWrapper[] wrappers = new List<pcServiceOperatingHoursController.ExceptionTableWrapper>{
            laterDate,
            earlierDate
        };
        wrappers.sort();

        System.assertEquals(earlierDate, wrappers[0], 'Expected earlierDate to be first');
        System.assertEquals(laterDate, wrappers[1], 'Expected laterDate to be second');
    }

    /**
     * @description Helper method to generate an FLP test user for use in test methods
     * @param permissionSetName Name of the Permission Set which governs the type of User
     * @return `User` FLP salesforce user with the appropriate permission set group
     */
    private static User generateUserWithAccess(String permissionSetName) {
        return new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .withPermissionSet(permissionSetName)
            .build(true);
    }
}
