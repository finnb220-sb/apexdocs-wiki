/**
 * @description Test class for Discharge Summary Controller.
 * @author BAH
 * @see VCC_DischargeSummaryController
 */
@IsTest
private with sharing class VCC_DischargeSummaryControllerTest {
    private static final String FAKE_ICN = 'FAKEICN';
    private static final Map<String, Object> VALID_ARGS = new Map<String, Object>{
        'application' => 'VTC_Default',
        VCC_DischargeSummaryController.ICN_KEY => FAKE_ICN,
        VCC_DischargeSummaryController.ENCOUNTER_KEY => 'fakeKey'
    };
    @IsTest
    private static void unitHealthDataRepoPositive() {
        VCR_HealthDataRepo expected = new VCR_HealthDataRepo('dischargeSummary');
        VCR_HealthDataRepo result;
        VCC_DischargeSummaryController.healthDataRepo = expected;
        Test.startTest();
        System.runAs(getTestUser()) {
            result = VCC_DischargeSummaryController.healthDataRepo;
        }
        Test.stopTest();
        Assert.isNotNull(result, 'Expected functional dependency injection of singleton property \'healthDataRepo\'. ');
        Assert.areEqual(
            result,
            expected,
            'Expected internal singleton property \'healthDataRepo\' to return dependency injected instance.'
        );
    }

    @IsTest
    private static void unitDischargeSummaryRepoPositive() {
        VCR_DischargeSummaryRepo expected = new VCR_DischargeSummaryRepo();
        VCR_DischargeSummaryRepo result;
        VCC_DischargeSummaryController.dischargeRepo = expected;
        Test.startTest();
        System.runAs(getTestUser()) {
            result = VCC_DischargeSummaryController.dischargeRepo;
        }
        Test.stopTest();
        Assert.isNotNull(result, 'Expected functional dependency injection of singleton property \'dischargeRepo\'. ');
        Assert.areEqual(
            result,
            expected,
            'Expected internal singleton property \'dischargeRepo\' to return dependency injected instance.'
        );
    }

    @IsTest
    private static void unitFetchHealthDataPositive() {
        VATEST_StubTuple healthDataStubTuple = new VATEST_StubBuilder(VCR_HealthDataRepo.class)
            .mockingMethodCall('setPatientByICN')
            .withParameterTypes(String.class)
            .withParameterValues(FAKE_ICN)
            .returning()
            .mockingMethodCall('fetchHealthDataConfig')
            .withParameterTypes()
            .returning(new VCR_HealthDataRepo.Model().setAccountDOB(null).setWorkstreamSettings(null))
            .defineStubTuple();
        VCC_DischargeSummaryController.healthDataRepo = (VCR_HealthDataRepo) healthDataStubTuple.stubbedClass;
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_DischargeSummaryController.fetchHealthDataConfig(FAKE_ICN);
        }
        Test.stopTest();
        Assert.isTrue(
            healthDataStubTuple.assertAllMockedMethodsWereCalled(),
            'Expected VCC_DischargeSummaryController.fetchHealthDataConfig to call .setICN, and fetchHealthDataConfig.'
        );
    }
    @IsTest
    private static void unitFetchHealthDataNullArgumentNegative() {
        VCR_HealthDataRepo.Model result;
        Test.startTest();
        System.runAs(getTestUser()) {
            result = VCC_DischargeSummaryController.fetchHealthDataConfig(null);
        }
        Test.stopTest();
        Assert.isNull(result, 'Expected fetchHealthDataConfig to guard against a null ICN.');
    }

    @IsTest
    private static void unitFetchHealthDataThrowsExceptionNegative() {
        String expectedExceptionMessage = 'This is expected';
        Boolean auraHandledExceptionThrown;

        String actualMessage;
        VCC_DischargeSummaryController.healthDataRepo = (VCR_HealthDataRepo) new VATEST_StubBuilder(
                VCR_HealthDataRepo.class
            )
            .mockingMethodCall('setPatientByICN')
            .withParameterTypes(String.class)
            .withParameterValues(FAKE_ICN)
            .throwingException(new QueryException(expectedExceptionMessage))
            .defineStub();
        Test.startTest();
        System.runAs(getTestUser()) {
            try {
                VCC_DischargeSummaryController.fetchHealthDataConfig(FAKE_ICN);
                Assert.fail('Expected Exception to be thrown!');
            } catch (AuraHandledException auraException) {
                auraHandledExceptionThrown = true;
                actualMessage = auraException.getMessage();
            }
        }
        Test.stopTest();
        Assert.isTrue(auraHandledExceptionThrown, 'Expected aura handled exception to be thrown!');
        Assert.isNotNull(actualMessage, 'Expected aura handled exception message to be set!');
        Assert.isTrue(
            actualMessage.contains(expectedExceptionMessage),
            'Expected Aura handled Exception\'s message to be set by the Exception that was thrown'
        );
    }

    @IsTest
    private static void unitGetDischargeSummaryPositive() {
        VATEST_StubTuple dischargeSummaryStubTuple = new VATEST_StubBuilder(VCR_DischargeSummaryRepo.class)
            .mockingMethodCall('fetchDischargeSummary')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(
                new Map<String, Object>{
                    'icn' => FAKE_ICN,
                    'application' => VCC_DischargeSummaryController.APPLICATION
                }
            )
            .returning(new VTC_DataModel())
            .defineStubTuple();
        VCC_DischargeSummaryController.dischargeRepo = (VCR_DischargeSummaryRepo) dischargeSummaryStubTuple.stubbedClass;
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_DischargeSummaryController.getDischargeSummary(new Map<String, Object>{ 'icn' => FAKE_ICN });
        }
        Test.stopTest();
        Assert.isTrue(
            dischargeSummaryStubTuple.assertAllMockedMethodsWereCalled(),
            'Expected getDischargeSummary to inject the application into the args and to call fetchDischargeSummary.'
        );
    }

    @IsTest
    private static void unitGetDischargeSummaryNullArgsNegative() {
        Object result;
        Test.startTest();
        System.runAs(getTestUser()) {
            result = VCC_DischargeSummaryController.getDischargeSummary(null);
        }
        Test.stopTest();
        Assert.isNull(result, 'Expected \'getDischargeSummary\' to guard against a null args map and return null');
    }

    @IsTest
    private static void unitGetDischargeSummaryEmptyArgsNegative() {
        Object result;

        Test.startTest();
        System.runAs(getTestUser()) {
            result = VCC_DischargeSummaryController.getDischargeSummary(new Map<String, Object>());
        }
        Test.stopTest();
        Assert.isNull(result, 'Expected \'getDischargeSummary\' to guard against an empty args map and return null');
    }

    @IsTest
    private static void unitGetDischargeSummaryHitsALimitNegative() {
        String expectedExceptionMessage = 'RETRY_CMD';
        VCC_DischargeSummaryController.dischargeRepo = (VCR_DischargeSummaryRepo) new VATEST_StubBuilder(
                VCR_DischargeSummaryRepo.class
            )
            .mockingMethodCall('fetchDischargeSummary')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(
                new Map<String, Object>{
                    'icn' => FAKE_ICN,
                    'application' => VCC_DischargeSummaryController.APPLICATION
                }
            )
            .throwingException(new VTC_LimitException(expectedExceptionMessage))
            .defineStub();
        Boolean auraHandledExceptionThrown;
        Test.startTest();
        System.runAs(getTestUser()) {
            try {
                VCC_DischargeSummaryController.getDischargeSummary(new Map<String, Object>{ 'icn' => FAKE_ICN });
                Assert.fail('Expected Exception to be thrown!');
            } catch (AuraHandledException auraException) {
                auraHandledExceptionThrown = true;
            }
            Assert.isTrue(
                auraHandledExceptionThrown,
                'Expected getDischargeSummary to rethrow the exception as an AurahandledException'
            );
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitGetDischargeSummaryThrowsUnexpectedExceptionNegative() {
        String expectedExceptionMessage = 'NO_RETRY_CMD';

        VCC_DischargeSummaryController.dischargeRepo = (VCR_DischargeSummaryRepo) new VATEST_StubBuilder(
                VCR_DischargeSummaryRepo.class
            )
            .mockingMethodCall('fetchDischargeSummary')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(
                new Map<String, Object>{
                    'icn' => FAKE_ICN,
                    'application' => VCC_DischargeSummaryController.APPLICATION
                }
            )
            .throwingException(new VTC_InternalException(expectedExceptionMessage))
            .defineStub();
        Boolean auraHandledExceptionThrown = false;
        Test.startTest();
        System.runAs(getTestUser()) {
            try {
                VCC_DischargeSummaryController.getDischargeSummary(new Map<String, Object>{ 'icn' => FAKE_ICN });
                Assert.fail('Expected Exception to be thrown!');
            } catch (AuraHandledException auraException) {
                auraHandledExceptionThrown = true;
            }
            Assert.isTrue(
                auraHandledExceptionThrown,
                'Expected getDischargeSummary to rethrow the exception as an AurahandledException'
            );
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitItShouldFindLocationPositive() {
        VTC_DataModel visits = new VTC_DataModel();
        String expectedEncounterId = 'expected!';
        String expectedLocationName = 'expectedLocationName';
        List<VTC_Record> expectedRecords = new List<VTC_Visit>{ new VTC_Visit() };
        ((VTC_Visit) expectedRecords[0]).uid = expectedEncounterId;
        ((VTC_Visit) expectedRecords[0]).locationName = expectedLocationName;
        visits.sites = new List<VTC_Site>{ new VTC_Site(), new VTC_Site(), new VTC_Site(), new VTC_Site() };
        visits.sites[0].records = expectedRecords;
        String result;
        Test.startTest();
        System.runAs(getTestUser()) {
            result = new VCC_DischargeSummaryController().findLocationNameFromVisits(visits, expectedEncounterId);
        }
        Test.stopTest();
        Assert.areEqual(
            expectedLocationName,
            result,
            'Expected findLocationsFromVisits to return the expected locationName!'
        );
    }

    @IsTest
    private static void unitItShouldThrowExceptionWithNullVisitsNegative() {
        VTC_DataModel visits = new VTC_DataModel();
        String expectedEncounterId = 'expected!';
        String result;
        Boolean exceptionThrown;
        Test.startTest();
        System.runAs(getTestUser()) {
            try {
                result = new VCC_DischargeSummaryController().findLocationNameFromVisits(visits, expectedEncounterId);
            } catch (VCC_DischargeSummaryController.InvalidLocationDataException invalidLocationDataException) {
                exceptionThrown = true;
            }
        }
        Test.stopTest();
        Assert.isTrue(
            exceptionThrown,
            'Expected findLocationsFromVisits to throw an error when a null visits model is passed in.!'
        );
    }
    @IsTest
    private static void unitItShouldThrowExceptionWithEmptyVisitsNegative() {
        VTC_DataModel visits = new VTC_DataModel();
        visits.sites = new List<VTC_Site>();
        String expectedEncounterId = 'expected!';
        String result;
        Boolean exceptionThrown;
        Test.startTest();
        System.runAs(getTestUser()) {
            try {
                result = new VCC_DischargeSummaryController().findLocationNameFromVisits(visits, expectedEncounterId);
            } catch (VCC_DischargeSummaryController.InvalidLocationDataException invalidLocationDataException) {
                exceptionThrown = true;
            }
        }
        Test.stopTest();
        Assert.isTrue(
            exceptionThrown,
            'Expected findLocationsFromVisits to throw an error when a empty sites model is passed in!'
        );
    }

    @IsTest
    private static void unitItShouldThrowExceptionWithBlankLocationNameNegative() {
        VTC_DataModel visits = new VTC_DataModel();
        String expectedEncounterId = 'expected!';
        List<VTC_Record> expectedRecords = new List<VTC_Visit>{ new VTC_Visit() };
        ((VTC_Visit) expectedRecords[0]).uid = expectedEncounterId;
        visits.sites = new List<VTC_Site>{ new VTC_Site(), new VTC_Site(), new VTC_Site(), new VTC_Site() };
        visits.sites[3].records = expectedRecords;
        String result;
        Boolean exceptionThrown;

        Test.startTest();
        System.runAs(getTestUser()) {
            try {
                result = new VCC_DischargeSummaryController().findLocationNameFromVisits(visits, expectedEncounterId);
            } catch (VCC_DischargeSummaryController.InvalidLocationDataException invalidLocationDataException) {
                exceptionThrown = true;
            }
        }
        Test.stopTest();
        Assert.isTrue(
            exceptionThrown,
            'Expected findLocationsFromVisits to throw an error when a visit is found but the locationName is null!'
        );
    }

    @IsTest
    private static void unitItShouldThrowExceptionWhenNoVisitsFoundNegative() {
        VTC_DataModel visits = new VTC_DataModel();
        String expectedEncounterId = 'expected!';
        List<VTC_Record> expectedRecords = new List<VTC_Visit>{ new VTC_Visit() };
        ((VTC_Visit) expectedRecords[0]).uid = expectedEncounterId;
        visits.sites = new List<VTC_Site>{ new VTC_Site(), new VTC_Site(), new VTC_Site(), new VTC_Site() };
        visits.sites[0].records = expectedRecords;
        String result;
        Boolean exceptionThrown;

        Test.startTest();
        System.runAs(getTestUser()) {
            try {
                result = new VCC_DischargeSummaryController().findLocationNameFromVisits(visits, 'wrongEncounterId');
            } catch (VCC_DischargeSummaryController.InvalidLocationDataException invalidLocationDataException) {
                exceptionThrown = true;
            }
        }
        Test.stopTest();
        Assert.isTrue(
            exceptionThrown,
            'Expected findLocationsFromVisits to throw an error when no visit matching the encounterId is found!'
        );
    }

    @IsTest
    private static void unitArgsAreValidPositive() {
        Boolean resultNullArgs = false;
        Boolean resultEmptyArgs = false;
        Boolean resultDoesNotContainICNKey = false;
        Boolean resultDoesNotContainEncounterKey = false;
        Boolean resultDoesNotContainICNValue = false;
        Boolean resultDoesNotContainEncounterIdValue = false;
        Boolean resultIsValid = false;
        Test.startTest();
        System.runAs(getTestUser()) {
            resultNullArgs = VCC_DischargeSummaryController.argsAreValid(null);
            resultEmptyArgs = VCC_DischargeSummaryController.argsAreValid(new Map<String, Object>());
            resultDoesNotContainICNKey = VCC_DischargeSummaryController.argsAreValid(
                new Map<String, Object>{ 'fakeKey' => 'fakeVal' }
            );
            resultDoesNotContainEncounterKey = VCC_DischargeSummaryController.argsAreValid(
                new Map<String, Object>{ VCC_DischargeSummaryController.ICN_KEY => null }
            );
            resultDoesNotContainICNValue = VCC_DischargeSummaryController.argsAreValid(
                new Map<String, Object>{
                    VCC_DischargeSummaryController.ICN_KEY => null,
                    VCC_DischargeSummaryController.ENCOUNTER_KEY => null
                }
            );
            resultDoesNotContainEncounterIdValue = VCC_DischargeSummaryController.argsAreValid(
                new Map<String, Object>{
                    VCC_DischargeSummaryController.ICN_KEY => FAKE_ICN,
                    VCC_DischargeSummaryController.ENCOUNTER_KEY => null
                }
            );
            resultIsValid = VCC_DischargeSummaryController.argsAreValid(VALID_ARGS);
        }
        Test.stopTest();
        Assert.isFalse(resultNullArgs, 'Expected argsAreValid to return false when args are null.');
        Assert.isFalse(resultEmptyArgs, 'Expected argsAreValid to return false when args is an empty map.');
        Assert.isFalse(
            resultDoesNotContainICNKey,
            'Expected argsAreValid to return false when it is non empty and does not contain an icn key.'
        );
        Assert.isFalse(
            resultDoesNotContainEncounterKey,
            'Expected argsAreValid to return false when it does not contain an encounterId key.'
        );
        Assert.isFalse(
            resultDoesNotContainICNValue,
            'Expected argsAreValid to return false when it does not contain a value for the icn key.'
        );
        Assert.isFalse(
            resultDoesNotContainEncounterIdValue,
            'Expected argsAreValid to return false when it does not contain a value for the encounterId key.'
        );
        Assert.isTrue(
            resultIsValid,
            'Expected argsAreValid to return true when it contains a key and a value for icn and encounterId.'
        );
    }

    @IsTest
    private static void unitGetLocationNamePositive() {
        VTC_DataModel visits = new VTC_DataModel();
        String expectedEncounterId = (String) VALID_ARGS.get('uid');
        String expectedLocationName = 'expectedLocationName';
        List<VTC_Record> expectedRecords = new List<VTC_Visit>{ new VTC_Visit() };
        ((VTC_Visit) expectedRecords[0]).uid = expectedEncounterId;
        ((VTC_Visit) expectedRecords[0]).locationName = expectedLocationName;
        visits.sites = new List<VTC_Site>{ new VTC_Site(), new VTC_Site(), new VTC_Site(), new VTC_Site() };
        visits.sites[0].records = expectedRecords;

        String result;
        VCC_DischargeSummaryController.visitRepo = (VCR_VisitRepo) new VATEST_StubBuilder(VCR_VisitRepo.class)
            .mockingMethodCall('fetchVisits')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(VALID_ARGS)
            .returning(visits)
            .defineStub();
        Test.startTest();
        {
            System.runAs(getTestUser()) {
                result = VCC_DischargeSummaryController.getLocationName(VALID_ARGS);
            }
        }
        Test.stopTest();
        Assert.areEqual(
            expectedLocationName,
            result,
            'Expected getLocationName to find the locationName from the mocked response.'
        );
    }
    @IsTest
    private static void unitGetLocationNameInvalidArgsNegative() {
        String result = '';
        Test.startTest();
        {
            System.runAs(getTestUser()) {
                result = VCC_DischargeSummaryController.getLocationName(new Map<String, Object>());
            }
        }
        Test.stopTest();
        Assert.isNull(result, 'Expected getLocationName to return null when args are invalid.');
    }

    @IsTest
    private static void unitGetLocationNameThrowsInvalidLocationDataExceptionNegative() {
        Boolean exceptionThrown;
        VCC_DischargeSummaryController.visitRepo = getVisitRepoThrowingException(
            new VCC_DischargeSummaryController.InvalidLocationDataException('Something bad happened'),
            VALID_ARGS
        );
        Test.startTest();
        {
            System.runAs(getTestUser()) {
                try {
                    VCC_DischargeSummaryController.getLocationName(VALID_ARGS);
                    Assert.fail('Expected an exception to be thrown');
                } catch (AuraHandledException invalidDataException) {
                    exceptionThrown = true;
                }
            }
        }
        Test.stopTest();
        Assert.isTrue(
            exceptionThrown,
            'Expected VCC_DischargeSummaryController to rethrow the exception as an auraHandledException.'
        );
    }

    @IsTest
    private static void unitGetLocationNameThrowsLimitExceptionNegative() {
        Boolean exceptionThrown;
        VCC_DischargeSummaryController.visitRepo = getVisitRepoThrowingException(
            new VTC_LimitException('Something bad happened'),
            VALID_ARGS
        );
        Test.startTest();
        {
            System.runAs(getTestUser()) {
                try {
                    VCC_DischargeSummaryController.getLocationName(VALID_ARGS);
                    Assert.fail('Expected an exception to be thrown');
                } catch (AuraHandledException limitException) {
                    exceptionThrown = true;
                }
            }
        }
        Test.stopTest();
        Assert.isTrue(
            exceptionThrown,
            'Expected VCC_DischargeSummaryController to rethrow the exception as an auraHandledException.'
        );
    }
    @IsTest
    private static void unitGetLocationNameThrowsUnknownExceptionNegative() {
        VCC_DischargeSummaryController.visitRepo = getVisitRepoThrowingException(
            new UnknownException('Something bad happened'),
            VALID_ARGS
        );
        Boolean exceptionThrown;
        Test.startTest();
        {
            System.runAs(getTestUser()) {
                try {
                    VCC_DischargeSummaryController.getLocationName(VALID_ARGS);
                    Assert.fail('Expected an exception to be thrown');
                } catch (AuraHandledException unknownException) {
                    exceptionThrown = true;
                }
            }
        }
        Test.stopTest();
        Assert.isTrue(
            exceptionThrown,
            'Expected VCC_DischargeSummaryController to rethrow the exception as an auraHandledException.'
        );
    }

    private static VCR_VisitRepo getVisitRepoThrowingException(Exception except, Map<String, Object> args) {
        return (VCR_VisitRepo) new VATEST_StubBuilder(VCR_VisitRepo.class)
            .mockingMethodCall('fetchVisits')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .throwingException(except)
            .defineStub();
    }
    private static User getTestUser() {
        return new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
    }

    /**
     * @description Exception type for us to throw in our tests.
     */
    private class UnknownException extends Exception {
    }
}
