/**
 * @description Test class for the VCC_TerritoryMemberToAppointmentsMap class.
 * @see VCC_TerritoryMemberToAppointmentsMap
 */
@IsTest
private with sharing class VCC_TerritoryMemberToAppointmentsMapTest {
    private static final User MOLLY_MIN_ACCESS;

    private static final DateTime START_RANGE;
    private static final VCC_TerritoryMemberToAppointmentsMap SYSTEM_UNDER_TEST;

    static {
        START_RANGE = DateTime.newInstance(System.now().year(), 1, 1);
        MOLLY_MIN_ACCESS = VATEST_UserFactory.createMinAccessPersonaUser(false);
        MOLLY_MIN_ACCESS.TimeZoneSidKey = UserInfo.getTimeZone().getID();
        SYSTEM_UNDER_TEST = new VCC_TerritoryMemberToAppointmentsMap();
    }

    @IsTest
    private static void unitConstructorSetsInternalPropertiesPositive() {
        System.runAs(MOLLY_MIN_ACCESS) {
            Assert.isNotNull(
                SYSTEM_UNDER_TEST.territoryMemberKeyToCompletedNonCompletedApptsMap,
                'Expected constructor to instantiate internal map.'
            );
        }
    }

    /**
     * @description Tests the containsKey method when there does not contain a key.
     */
    @IsTest
    private static void unitContainsKeyNegative() {
        Boolean result;
        Test.startTest();
        {
            System.runAs(MOLLY_MIN_ACCESS) {
                result = SYSTEM_UNDER_TEST.containsKey(null);
            }
        }
        Assert.isFalse(
            result,
            'Expected ContainsKey to return false when passed in a key that does not exist in the internal collection.'
        );
    }

    /**
     * @description Tests the containsKey method when there is in fact a key.
     */
    @IsTest
    private static void unitContainsKeyPositive() {
        Boolean result;
        VCC_TerritoryMemberKey testKey = new VCC_TerritoryMemberKey(
            VATEST_IdFactory.get(ServiceResource.SObjectType),
            VATEST_IdFactory.get(ServiceTerritory.SObjectType)
        );
        SYSTEM_UNDER_TEST.territoryMemberKeyToCompletedNonCompletedApptsMap.put(
            testKey,
            new VCC_TwoTuple(new VCC_TimeSlotCollection(), new VCC_TimeSlotCollection())
        );
        Test.startTest();
        {
            System.runAs(MOLLY_MIN_ACCESS) {
                result = SYSTEM_UNDER_TEST.containsKey(testKey);
            }
        }
        Assert.isTrue(
            result,
            'Expected ContainsKey to return true when passed in a key that exists in the internal collection.'
        );
    }

    /**
     * @description Tests the GetCompletedAppointments method when there is a value in the completed appointments bucket for the key passed in.
     * Assert: The expected collection is returned.
     */
    @IsTest
    private static void unitGetCompletedAppointmentsPositive() {
        VCC_TerritoryMemberKey testKey = new VCC_TerritoryMemberKey(
            VATEST_IdFactory.get(ServiceResource.SObjectType),
            VATEST_IdFactory.get(ServiceTerritory.SObjectType)
        );

        VCC_TimeSlotCollection expectedCollection = new VCC_TimeSlotCollection();
        SYSTEM_UNDER_TEST.territoryMemberKeyToCompletedNonCompletedApptsMap.put(
            testKey,
            new VCC_TwoTuple(expectedCollection, null)
        );

        VCC_TimeSlotCollection result;

        Test.startTest();
        {
            System.runAs(MOLLY_MIN_ACCESS) {
                result = SYSTEM_UNDER_TEST.getCompletedAppointments(testKey);
            }
        }
        Assert.areEqual(
            result,
            expectedCollection,
            'Expected getCompletedAppointments to return the \'valueOne\' property of the VCC_TwoTuple injected in this test.'
        );
    }

    /**
     * @description Tests the GetCompletedAppointments method when there is no CompletedAppointments bucket for the key passed in.
     */
    @IsTest
    private static void unitGetCompletedAppointmentsNegative() {
        VCC_TerritoryMemberKey testKey = new VCC_TerritoryMemberKey(
            VATEST_IdFactory.get(ServiceResource.SObjectType),
            VATEST_IdFactory.get(ServiceTerritory.SObjectType)
        );

        VCC_TimeSlotCollection result;
        Test.startTest();
        {
            System.runAs(MOLLY_MIN_ACCESS) {
                result = SYSTEM_UNDER_TEST.getCompletedAppointments(testKey);
            }
        }
        Assert.isNull(
            result,
            'Expected \'getCompletedAppointments\' to return null when passed in a key that does not exist in the internal collection.'
        );
    }
    /**
     * @description Tests the GetCompletedAppointments method when there is a value in the completed appointments bucket for the key passed in.
     * Assert: The expected collection is returned.
     */
    @IsTest
    private static void unitGetAllAppointmentsPositive() {
        VCC_TerritoryMemberKey testKey = new VCC_TerritoryMemberKey(
            VATEST_IdFactory.get(ServiceResource.SObjectType),
            VATEST_IdFactory.get(ServiceTerritory.SObjectType)
        );

        VCC_TimeSlotCollection expectedCollection = new VCC_TimeSlotCollection();
        SYSTEM_UNDER_TEST.territoryMemberKeyToCompletedNonCompletedApptsMap.put(
            testKey,
            new VCC_TwoTuple(null, expectedCollection)
        );

        VCC_TimeSlotCollection result;

        Test.startTest();
        {
            System.runAs(MOLLY_MIN_ACCESS) {
                result = SYSTEM_UNDER_TEST.getAllAppointments(testKey);
            }
        }
        Assert.areEqual(
            result,
            expectedCollection,
            'Expected \'getAllAppointments\' to return the \'valueTwo\' property of the VCC_TwoTuple injected in this test.'
        );
    }

    /**
     * @description Tests the GetCompletedAppointments method when there is no CompletedAppointments bucket for the key passed in.
     */
    @IsTest
    private static void unitGetAllAppointmentsNegative() {
        VCC_TerritoryMemberKey testKey = new VCC_TerritoryMemberKey(
            VATEST_IdFactory.get(ServiceResource.SObjectType),
            VATEST_IdFactory.get(ServiceTerritory.SObjectType)
        );

        VCC_TimeSlotCollection result;
        Test.startTest();
        {
            System.runAs(MOLLY_MIN_ACCESS) {
                result = SYSTEM_UNDER_TEST.getAllAppointments(testKey);
            }
        }
        Assert.isNull(
            result,
            'Expected \'getAllAppointments\' to return null when passed in a key that does not exist in the internal collection.'
        );
    }

    /**
     * @description Given two appointments, one which was cancelled in advance, and one which was completed.
     * Assert: The completed appointments bucket is property added to.
     * Assert: The All appointments bucket is properly added to.
     */
    @IsTest
    private static void unitAddToRespectiveBucketsPositive() {
        ServiceResource personWhoIsWorking = (ServiceResource) VATEST_SObjectFactory.createSObject(
            new ServiceResource()
        );
        ServiceTerritory placeTheyAreWorking = (ServiceTerritory) VATEST_SObjectFactory.createSObject(
            new ServiceTerritory()
        );

        ServiceAppointment apptToAddToBothBuckets = (ServiceAppointment) VATEST_SObjectFactory.createSObject(
            (new ServiceAppointment(
                Status = VCC_TerritoryMemberToAppointmentsMap.COMPLETED,
                SchedStartTime = START_RANGE,
                SchedEndTime = START_RANGE.addMinutes(30),
                ServiceTerritoryId = placeTheyAreWorking.Id
            ))
        );
        ServiceAppointment apptToAddOnlyToSecondBucket = (ServiceAppointment) VATEST_SObjectFactory.createSObject(
            (new ServiceAppointment(
                Status = 'someone cancelled before it started:(',
                SchedStartTime = START_RANGE.addMinutes(60),
                SchedEndTime = START_RANGE.addMinutes(90),
                ServiceTerritoryId = placeTheyAreWorking.Id,
                Cancelled_Date__c = START_RANGE.addDays(-1)
            ))
        );
        AssignedResource assignmentToFirstAppointment = (AssignedResource) VATEST_SObjectFactory.createSObject(
            new AssignedResource(
                ServiceResourceId = personWhoIsWorking.Id,
                ServiceAppointmentId = apptToAddToBothBuckets.Id
            )
        );
        AssignedResource assignmentToSecondAppointment = (AssignedResource) VATEST_SObjectFactory.createSObject(
            new AssignedResource(
                ServiceResourceId = personWhoIsWorking.Id,
                ServiceAppointmentId = apptToAddToBothBuckets.Id
            )
        );
        Test.startTest();
        {
            System.runAs(MOLLY_MIN_ACCESS) {
                SYSTEM_UNDER_TEST.addAppointmentToRespectiveBuckets(
                    apptToAddToBothBuckets,
                    assignmentToFirstAppointment
                );
                SYSTEM_UNDER_TEST.addAppointmentToRespectiveBuckets(
                    apptToAddOnlyToSecondBucket,
                    assignmentToSecondAppointment
                );
            }
        }
        Test.stopTest();
        VCC_TerritoryMemberKey key = new VCC_TerritoryMemberKey(personWhoIsWorking.Id, placeTheyAreWorking.Id);
        Assert.areEqual(
            1,
            SYSTEM_UNDER_TEST.getCompletedAppointments(key).size(),
            'Expected only one appointment to be added to the Completed Appointments bucket.'
        );
        Assert.areEqual(
            30,
            SYSTEM_UNDER_TEST.getCompletedAppointments(key).getTimeInMinutes(),
            'Expected only the first appointment to increment the time calculations.'
        );
        Assert.areEqual(
            2,
            SYSTEM_UNDER_TEST.getAllAppointments(key).size(),
            'Expected both appointments to be added to the All Appointments bucket.'
        );
        Assert.areEqual(
            60,
            SYSTEM_UNDER_TEST.getAllAppointments(key).getTimeInMinutes(),
            'Expected both Appointments to increment the time calculations.'
        );
    }

    /**
     * @description Given four appointments, three which were completed, one which was cancelled after the scheduled start
     * Assert: The used appointments bucket is property added to (3)
     * Assert: The completedAndNoShow appointments bucket is properly added to (4)
     */
    @IsTest
    private static void unitAddUsedSlotsToRespectiveBucketsPositive() {
        ServiceResource personWhoIsWorking = (ServiceResource) VATEST_SObjectFactory.createSObject(
            new ServiceResource()
        );
        ServiceTerritory placeTheyAreWorking = (ServiceTerritory) VATEST_SObjectFactory.createSObject(
            new ServiceTerritory()
        );

        ServiceAppointment apptToAddToAllBuckets = (ServiceAppointment) VATEST_SObjectFactory.createSObject(
            (new ServiceAppointment(
                Status = VCC_TerritoryMemberToAppointmentsMap.COMPLETED,
                SchedStartTime = START_RANGE,
                SchedEndTime = START_RANGE.addMinutes(30),
                ServiceTerritoryId = placeTheyAreWorking.Id
            ))
        );
        ServiceAppointment apptToAddOnlyToTotalCountBucket = (ServiceAppointment) VATEST_SObjectFactory.createSObject(
            (new ServiceAppointment(
                Status = 'someone cancelled before it started:(',
                SchedStartTime = START_RANGE.addMinutes(60),
                SchedEndTime = START_RANGE.addMinutes(90),
                ServiceTerritoryId = placeTheyAreWorking.Id,
                Cancelled_Date__c = START_RANGE.addDays(-1)
            ))
        );
        ServiceAppointment apptLaterInDayToAddToAllBuckets = (ServiceAppointment) VATEST_SObjectFactory.createSObject(
            (new ServiceAppointment(
                Status = VCC_TerritoryMemberToAppointmentsMap.COMPLETED,
                SchedStartTime = START_RANGE.addMinutes(120),
                SchedEndTime = START_RANGE.addMinutes(150),
                ServiceTerritoryId = placeTheyAreWorking.Id
            ))
        );
        ServiceAppointment apptToAddToCompletedAndTotalBuckets = (ServiceAppointment) VATEST_SObjectFactory.createSObject(
            (new ServiceAppointment(
                Status = 'someone cancelled after it started',
                SchedStartTime = START_RANGE.addMinutes(240),
                SchedEndTime = START_RANGE.addMinutes(270),
                ServiceTerritoryId = placeTheyAreWorking.Id,
                Cancelled_Date__c = START_RANGE.addMinutes(250)
            ))
        );
        AssignedResource assignmentToCompletedAppointment = (AssignedResource) VATEST_SObjectFactory.createSObject(
            new AssignedResource(
                ServiceResourceId = personWhoIsWorking.Id,
                ServiceAppointmentId = apptToAddToAllBuckets.Id
            )
        );
        AssignedResource assignmentToCanceledAppointment = (AssignedResource) VATEST_SObjectFactory.createSObject(
            new AssignedResource(
                ServiceResourceId = personWhoIsWorking.Id,
                ServiceAppointmentId = apptToAddOnlyToTotalCountBucket.Id
            )
        );

        AssignedResource assignmentToCompletedAppointmentLaterInDay = (AssignedResource) VATEST_SObjectFactory.createSObject(
            new AssignedResource(
                ServiceResourceId = personWhoIsWorking.Id,
                ServiceAppointmentId = apptLaterInDayToAddToAllBuckets.Id
            )
        );

        AssignedResource assignmentToCanceledAfterItStarted = (AssignedResource) VATEST_SObjectFactory.createSObject(
            new AssignedResource(
                ServiceResourceId = personWhoIsWorking.Id,
                ServiceAppointmentId = apptToAddToCompletedAndTotalBuckets.Id
            )
        );

        Test.startTest();
        {
            System.runAs(MOLLY_MIN_ACCESS) {
                SYSTEM_UNDER_TEST.addAppointmentToRespectiveBuckets(
                    apptToAddToAllBuckets,
                    assignmentToCompletedAppointment
                );
                SYSTEM_UNDER_TEST.addAppointmentToRespectiveBuckets(
                    apptToAddOnlyToTotalCountBucket,
                    assignmentToCanceledAppointment
                );
                SYSTEM_UNDER_TEST.addAppointmentToRespectiveBuckets(
                    apptLaterInDayToAddToAllBuckets,
                    assignmentToCompletedAppointmentLaterInDay
                );
                SYSTEM_UNDER_TEST.addAppointmentToRespectiveBuckets(
                    apptToAddToCompletedAndTotalBuckets,
                    assignmentToCanceledAfterItStarted
                );
            }
        }
        Test.stopTest();
        VCC_TerritoryMemberKey key = new VCC_TerritoryMemberKey(personWhoIsWorking.Id, placeTheyAreWorking.Id);
        Assert.areEqual(
            3,
            SYSTEM_UNDER_TEST.getCompletedAppointments(key).size(),
            'Expected all appointments except canceled (before scheduled start date) to be added to the Completed Appointments bucket.'
        );
        Assert.areEqual(
            90,
            SYSTEM_UNDER_TEST.getCompletedAppointments(key).getTimeInMinutes(),
            'Expected all completed appointments (3) to increment the time calculations.'
        );
        Assert.areEqual(
            4,
            SYSTEM_UNDER_TEST.getAllAppointments(key).size(),
            'Expected all appointments to be added to the All Appointments bucket.'
        );
        Assert.areEqual(
            120,
            SYSTEM_UNDER_TEST.getAllAppointments(key).getTimeInMinutes(),
            'Expected all Appointments to increment the time calculations.'
        );
        Assert.isTrue(
            SYSTEM_UNDER_TEST.usedMapContainsKey(key),
            'Expected Used (Completed not Canceled after start time) bucket to contain entries for our ServiceResource & ServiceTerritory.'
        );
        Assert.areEqual(
            2,
            SYSTEM_UNDER_TEST.getUsedAppointments(key).size(),
            'Expected only Completed Appointments to be added to the Actual Used bucket.'
        );
        Assert.areEqual(
            60,
            SYSTEM_UNDER_TEST.getUsedAppointments(key).getTimeInMinutes(),
            'Expected only Completed Appointments to increment time in the Actual Used bucket.'
        );
    }

    @IsTest
    private static void unitPutAllAppointmentsInResultantMapNegative() {
        List<ServiceAppointment> appts = new List<ServiceAppointment>{ new ServiceAppointment() };
        String errorMessage;
        try {
            Test.startTest();
            System.runAs(MOLLY_MIN_ACCESS) {
                SYSTEM_UNDER_TEST.putAllAppointmentsInResultantMap(appts);
                Assert.fail(
                    'Expected an exception to be thrown when there is no one assigned to a ServiceAppointment passed in.'
                );
            }
            Test.stopTest();
        } catch (VCC_TerritoryMemberToAppointmentsMap.InvalidArgumentException invalidApptsException) {
            errorMessage = invalidApptsException.getMessage();
        }

        Assert.isTrue(
            errorMessage.contains(VCC_TerritoryMemberToAppointmentsMap.INVALID_APPOINTMENT_EXCEPTION),
            'Expected the exceptions message to be set by internal \'INVALID_APPOINTMENT_EXCEPTION\' constant.'
        );
    }
}
