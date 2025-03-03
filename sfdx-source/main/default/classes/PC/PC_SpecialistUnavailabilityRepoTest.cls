/**
 * @description test class for PC_SpecialistUnavailabilityRepo.
 * @author      Booz Allen
 * @since       2024
 * @see         PC_SpecialistUnavailabilityRepo
 */
@IsTest
public class PC_SpecialistUnavailabilityRepoTest {
    @testSetup
    private static void testSetup() {
        VATEST_SObjectFactory.createSObject(
            new Schema.Location(
                Name = 'Test Location1',
                RecordTypeId = Schema.SObjectType.Location.getRecordTypeInfosByName()
                    .get('VA Facility')
                    .getRecordTypeId(),
                VAF_Facility_Type__c = 'va_health_facility',
                LocationType = 'Site',
                VAF_Facility_ID__c = '100'
            ),
            true
        );
    }
    @IsTest
    private static void insertpcSpecialistUnavailabilityTestPositive() {
        // Test data setup
        PC_SpecialistUnavailabilityRepo pcSpecUnavailabilityRepo = new PC_SpecialistUnavailabilityRepo();

        Set<String> flpPermissionSetNames = new Set<String>{
            'PrC_FLP_App_Access',
            'PC_User_BaseObjectWithNoTabVisibility_ReadWrite'
        };
        VATEST_UserBuilder pcTestFLPWithAccessBuilder = new VATEST_UserBuilder();
        pcTestFLPWithAccessBuilder.withPermissionSets(flpPermissionSetNames)
            .withUserProfile('VAVET Base Profile')
            .withStandardData();
        pcTestFLPWithAccessBuilder.resultingUser.LastName = 'testWithAccess';
        pcTestFLPWithAccessBuilder.resultingUser.Division = 'VISN 9';
        pcTestFLPWithAccessBuilder.build(true);

        User runAsUser = pcTestFLPWithAccessBuilder.resultingUser;

        Schema.Location testLocation = [SELECT Id FROM Location LIMIT 1];

        PC_Specialist_Unavailability__c psu = new PC_Specialist_Unavailability__c(
            PC_Specialty__c = 'Cardiology',
            PC_VISN__c = runAsUser.Division,
            FLP_Current_Location__c = testLocation.Id
        );

        // Actual test
        Test.startTest();

        System.runAs(runAsUser) {
            pcSpecUnavailabilityRepo.insertPCSpecialistUnavailability(psu);
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(
            [SELECT Id FROM PC_Specialist_Unavailability__c WHERE Id = :psu.Id LIMIT 1].size() > 0,
            'New PC_Specialist_Unavailability__c record not inserted successfully.'
        );
    }

    @IsTest
    private static void insertpcSpecialistUnavailabilityTestNegative() {
        // Test data setup
        PC_SpecialistUnavailabilityRepo pcSpecUnavailabilityRepo = new PC_SpecialistUnavailabilityRepo();

        VATEST_UserBuilder pcTestFLPWithoutAccessBuilder = new VATEST_UserBuilder();
        pcTestFLPWithoutAccessBuilder.withPermissionSet('PrC_Specialist_App_Access')
            .withUserProfile('VAVET Base Profile')
            .withStandardData();
        pcTestFLPWithoutAccessBuilder.resultingUser.Division = 'VISN 9';
        pcTestFLPWithoutAccessBuilder.build(true);

        User runAsUser = pcTestFLPWithoutAccessBuilder.resultingUser;

        Boolean hasDmlFailure = false;

        Schema.Location testLocation = [SELECT Id FROM Location LIMIT 1];

        PC_Specialist_Unavailability__c psu = new PC_Specialist_Unavailability__c(
            PC_Specialty__c = 'Cardiology',
            PC_VISN__c = runAsUser.Division,
            FLP_Current_Location__c = testLocation.Id
        );

        // Actual test
        Test.startTest();

        System.runAs(runAsUser) {
            try {
                pcSpecUnavailabilityRepo.insertPCSpecialistUnavailability(psu);
            } catch (SecurityException e) {
                hasDmlFailure = true;
            }
        }

        Test.stopTest();
        // Asserts
        Assert.isTrue(
            hasDmlFailure,
            'New PC_Specialist_Unavailability__c record without access should not insert successfully.'
        );
    }
}
