/**
 * @author Booz Allen Hamilton
 * @since 5/20/24
 * @description Unit tests for VCR_OperatingHoursRepo class
 * @see VCR_OperatingHoursRepo
 */
@IsTest
private with sharing class VCR_OperatingHoursRepoTest {
    private static final String OPERATING_HOURS_TYPE_STRING = 'Tele-EC';

    final static User VAVET_BASE_USER;
    static {
        VAVET_BASE_USER = new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSet('VAHC_View_Appointment_Utilization')
            .withPermissionSet('VCC_VCV_Appointment_Viewer_Administrator')
            .withPermissionSet('Tele_EC_Operating_Hours_Access')
            .withStandardData()
            .build(true);
    }

    /**
     * @description Verify that we constructed an instance of Repo successfully
     */
    @IsTest
    static void unitItConstructsPositive() {
        Test.startTest();
        VCR_OperatingHoursRepo repo;
        System.runAs(VAVET_BASE_USER) {
            repo = new VCR_OperatingHoursRepo();
        }
        Test.stopTest();
        Assert.isNotNull(repo, 'Expected a valid non-null Repo class to be created');
    }

    /**
     * @description Verify that fetch method for Operating Hours by VISN works as expected when there are records to retrieve
     *  happy path
     */
    @IsTest
    static void funcFetchOpHoursPositive() {
        String visnName = 'VISN 1';
        OperatingHours opHours;
        System.runAs(VAVET_BASE_USER) {
            opHours = (OperatingHours) VATEST_SObjectFactory.createSObject(
                new OperatingHours(Name = visnName + ' Operating Hours', VCC_VISN__c = visnName),
                true
            );
        }
        VCR_OperatingHoursRepo repo = new VCR_OperatingHoursRepo();
        Test.startTest();
        List<OperatingHours> returnedOpHours;
        System.runAs(VAVET_BASE_USER) {
            returnedOpHours = repo.fetchOperatingHoursWithTimeSlots(visnName);
        }
        Test.stopTest();
        Assert.areEqual(
            1,
            returnedOpHours.size(),
            'Expected 1 OperatingHours record to be returned using VISN Name: ' + visnName
        );
        Assert.areEqual(
            opHours.Name,
            returnedOpHours.get(0).Name,
            'Expected our test OperatingHours record to be returned'
        );
    }

    /**
     * @description Verify that fetch method by Operating Hours works as expected when there are no matching records to retrieve
     *  unhappy path
     */
    @IsTest
    static void funcFetchOpHoursNoResultsNegative() {
        String visnName = 'VISN 1';
        VCR_OperatingHoursRepo repo = new VCR_OperatingHoursRepo();
        Test.startTest();
        List<OperatingHours> returnedOpHours;
        System.runAs(VAVET_BASE_USER) {
            returnedOpHours = repo.fetchOperatingHoursWithTimeSlots(visnName);
        }
        Test.stopTest();
        Assert.isNotNull(
            returnedOpHours,
            'Expected an empty list of OperatingHours not a null, to be returned for unknown VISN Name: ' + visnName
        );
        Assert.areEqual(
            0,
            returnedOpHours.size(),
            'Expected an empty list of OperatingHours to be returned for unknown VISN Name: ' + visnName
        );
    }

    /**
     * @description Verify that fetch method by Operating Hours works as expected when invalid input is provided
     *  unhappy path
     */
    @IsTest
    static void funcFetchHolidaysByOpHoursInvalidInputNegative() {
        VCR_OperatingHoursRepo repo = new VCR_OperatingHoursRepo();
        Test.startTest();
        List<OperatingHours> returnedOpHours;
        System.runAs(VAVET_BASE_USER) {
            returnedOpHours = repo.fetchOperatingHoursWithTimeSlots(null);
        }
        Test.stopTest();
        Assert.isNotNull(
            returnedOpHours,
            'Expected an empty list of OperatingHours not a null, to be returned for null VISN Name'
        );
        Assert.areEqual(
            0,
            returnedOpHours.size(),
            'Expected an empty list of OperatingHours to be returned for null VISN Name'
        );
    }

    /**
     * @description Verify that fetch multiple method for Operating Hours by VISN works as expected when there are records to retrieve
     *  happy path
     */
    @IsTest
    static void funcFetchMultipleOpHoursPositive() {
        String visnName1 = 'VISN 1';
        String visnName2 = 'VISN 2';
        List<String> visnList = new List<String>{ visnName1, visnName2 };
        System.runAs(VAVET_BASE_USER) {
            VATEST_SObjectFactory.createSObject(
                new OperatingHours(
                    Name = visnName1 + ' Operating Hours',
                    VCC_VISN__c = visnName1,
                    VCC_Operating_Hours_Type__c = OPERATING_HOURS_TYPE_STRING
                ),
                true
            );
            VATEST_SObjectFactory.createSObject(
                new OperatingHours(
                    Name = visnName2 + ' Operating Hours',
                    VCC_VISN__c = visnName2,
                    VCC_Operating_Hours_Type__c = OPERATING_HOURS_TYPE_STRING
                ),
                true
            );
        }
        VCR_OperatingHoursRepo repo = new VCR_OperatingHoursRepo();
        List<OperatingHours> returnedOpHours;
        Test.startTest();
        System.runAs(VAVET_BASE_USER) {
            returnedOpHours = repo.fetchMultipleOperatingHoursWithTimeSlotsByType(
                visnList,
                OPERATING_HOURS_TYPE_STRING
            );
        }
        Test.stopTest();
        Assert.areEqual(
            2,
            returnedOpHours.size(),
            'Expected 2 OperatingHours record to be returned, actual: ' + returnedOpHours.size()
        );

        Boolean visnsPresent = true;
        for (OperatingHours operatingHoursItem : returnedOpHours) {
            if (!visnList.contains(operatingHoursItem.VCC_VISN__c)) {
                visnsPresent = false;
            }
        }
        Assert.isTrue(visnsPresent, 'Expected VISNS to be present in return.');
    }

    /**
     * @description Verify that fetch multiple method by Operating Hours works as expected when there are no matching records to retrieve
     *  unhappy path
     */
    @IsTest
    static void funcFetchMultipleOpHoursNoResultsNegative() {
        String visnName = 'VISN 1';
        VCR_OperatingHoursRepo repo = new VCR_OperatingHoursRepo();
        List<OperatingHours> returnedOpHours;
        Test.startTest();
        System.runAs(VAVET_BASE_USER) {
            returnedOpHours = repo.fetchMultipleOperatingHoursWithTimeSlotsByType(
                new List<String>{ visnName },
                OPERATING_HOURS_TYPE_STRING
            );
        }
        Test.stopTest();
        Assert.isNotNull(
            returnedOpHours,
            'Expected an empty list of OperatingHours not a null, to be returned for unknown VISN Name: ' + visnName
        );
        Assert.isTrue(
            returnedOpHours.isEmpty(),
            'Expected an empty list of OperatingHours to be returned for unknown VISN List'
        );
    }

    /**
     * @description Verify that fetch multiple method by Operating Hours works as expected when invalid input is provided
     *  unhappy path
     */
    @IsTest
    static void funcFetchMultipleOpHoursInvalidInputNegative() {
        VCR_OperatingHoursRepo repo = new VCR_OperatingHoursRepo();
        List<OperatingHours> returnedOpHours;
        Test.startTest();
        System.runAs(VAVET_BASE_USER) {
            returnedOpHours = repo.fetchMultipleOperatingHoursWithTimeSlotsByType(null, OPERATING_HOURS_TYPE_STRING);
        }
        Test.stopTest();
        Assert.isNotNull(
            returnedOpHours,
            'Expected an empty list of OperatingHours not a null, to be returned for null VISN Name'
        );
        Assert.isTrue(
            returnedOpHours.isEmpty(),
            'Expected an empty list of OperatingHours to be returned for null VISN Name'
        );
    }
}
