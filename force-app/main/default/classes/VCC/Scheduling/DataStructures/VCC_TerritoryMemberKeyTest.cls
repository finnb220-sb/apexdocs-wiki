/**
 * @description Test class for VCC_TerritoryMemberKey Class.
 * @see VCC_TerritoryMemberKey
 */
@IsTest
private class VCC_TerritoryMemberKeyTest {
    private static VCC_TerritoryMemberKey systemUnderTest;
    private static final User MOLLY_MIN_ACCESS;

    static {
        MOLLY_MIN_ACCESS = VATEST_UserFactory.createMinAccessPersonaUser(false);
    }

    /**
     * @description Asserts that when passing a ServiceTerritoryMember to the constructor,
     * the internal properties, serviceTerritoryMemberId, serviceResourceId & serviceTerritoryId
     * are set.
     */
    @IsTest
    static void unitConstructorSetsInternalPropertiesWhenPassedSObjectPositive() {
        ServiceTerritoryMember expectedData = generateServiceTerritoryMember();

        System.runAs(MOLLY_MIN_ACCESS) {
            Test.startTest();
            systemUnderTest = new VCC_TerritoryMemberKey(expectedData);
            Test.stopTest();
        }

        Assert.areEqual(
            systemUnderTest.serviceTerritoryMemberId,
            expectedData.Id,
            'Expected constructor to set the internal \'serviceTerritoryMemberId\' field equal to the Id of the ServiceTerritoryMember passed in.'
        );
        Assert.areEqual(
            systemUnderTest.serviceResourceId,
            expectedData.ServiceResourceId,
            'Expected constructor to set the internal \'ServiceResourceId\' field equal to the Id of the ServiceResource related to the ServiceTerritoryMember passed in.'
        );
        Assert.areEqual(
            systemUnderTest.serviceTerritoryId,
            expectedData.ServiceTerritoryId,
            'Expected constructor to set the internal \'serviceTerritoryId\' field equal to the Id ServiceTerritory related to the ServiceTerritoryMember passed in.'
        );
    }

    /**
     * @description Asserts that when passing in a serviceResourceId, and serviceTerritoryId to the constructor,
     * both related properties are set in the object.
     */
    @IsTest
    static void unitConstructorSetsInternalPropertiesWhenPassedIdsPositive() {
        ServiceResource expectedResource = (ServiceResource) VATEST_SObjectFactory.createSObject(
            new ServiceResource(),
            false
        );
        ServiceTerritory expectedTerritory = (ServiceTerritory) VATEST_SObjectFactory.createSObject(
            new ServiceTerritory(),
            false
        );

        System.runAs(MOLLY_MIN_ACCESS) {
            Test.startTest();
            systemUnderTest = new VCC_TerritoryMemberKey(expectedResource.Id, expectedTerritory.Id);
            Test.stopTest();
        }
        Assert.areEqual(
            systemUnderTest.serviceResourceId,
            expectedResource.Id,
            'Expected constructor to set the internal \'ServiceResourceId\' field equal to the Id of the ServiceResource passed in.'
        );
        Assert.areEqual(
            systemUnderTest.serviceTerritoryId,
            expectedTerritory.Id,
            'Expected constructor to set the internal \'serviceTerritoryId\' field equal to the Id ServiceTerritory passed in.'
        );
    }

    /**
     * @description  Asserts that the equals method returns true when two different objects
     * have the same serviceResourceId and serviceTerritoryId
     */
    @IsTest
    static void unitEqualsComparesOnRelatedRecordsIdsPositive() {
        systemUnderTest = new VCC_TerritoryMemberKey(generateServiceTerritoryMember());
        VCC_TerritoryMemberKey comparedObj = new VCC_TerritoryMemberKey(
            systemUnderTest.serviceResourceId,
            systemUnderTest.serviceTerritoryId
        );
        Boolean result;
        System.runAs(MOLLY_MIN_ACCESS) {
            Test.startTest();
            result = systemUnderTest.equals(comparedObj);
            Test.stopTest();
        }
        Assert.isTrue(
            result,
            'Expected two objects to compare based on \'ServiceResourceId\' and \'ServiceTerritoryId\'.'
        );
    }

    /**
     * @description Asserts that equals returns false when one of the two properties are different.
     */
    @IsTest
    static void unitEqualsComparesOnRelatedRecordsIdsNegative() {
        systemUnderTest = new VCC_TerritoryMemberKey(generateServiceTerritoryMember());

        VCC_TerritoryMemberKey comparedObj = new VCC_TerritoryMemberKey(
            systemUnderTest.serviceResourceId,
            generateServiceTerritoryMember().ServiceTerritoryId
        );
        Boolean result;
        System.runAs(MOLLY_MIN_ACCESS) {
            Test.startTest();
            result = systemUnderTest.equals(comparedObj);
            Test.stopTest();
        }
        Assert.isFalse(result, 'Expected to return false when given a different \'ServiceTerritoryId\'.');
    }

    /**
     * @description Asserts that the custom defined hashcode method is deterministic based on StartDateTime
     * and endDateTime. It does this by running the hashCode method 1,000 times and adding each iteration
     * to a set collection. If any of the 1,000 differ from one another, the set collection will be larger
     * than size of 1. 1,000 is chosen as it is a larger Number of ServiceTerritoryMembers than what we would
     * expect for a given run.
     */
    @IsTest
    static void unitHashCodeIsDeterministicPositive() {
        systemUnderTest = new VCC_TerritoryMemberKey(generateServiceTerritoryMember());
        Set<Integer> hashCodes = new Set<Integer>();
        System.runAs(MOLLY_MIN_ACCESS) {
            Test.startTest();
            for (Integer counter = 0; counter < 1000; counter++) {
                hashCodes.add(systemUnderTest.hashCode());
            }
            Test.stopTest();
        }
        Assert.areEqual(1, hashCodes.size(), 'Expected Hashcode function to never return a different value.');
    }

    /**
     * @description utility method for generating test data.
     * @return ServiceTerritoryMember returns a ServiceTerritoryMember for us to run tests with.
     */
    private static ServiceTerritoryMember generateServiceTerritoryMember() {
        ServiceResource expectedResource = (ServiceResource) VATEST_SObjectFactory.createSObject(
            new ServiceResource(),
            false
        );
        ServiceTerritory expectedTerritory = (ServiceTerritory) VATEST_SObjectFactory.createSObject(
            new ServiceTerritory(),
            false
        );
        return (ServiceTerritoryMember) VATEST_SObjectFactory.createSObject(
            new ServiceTerritoryMember(
                ServiceResourceId = expectedResource.Id,
                ServiceTerritoryId = expectedTerritory.Id
            ),
            false
        );
    }
}
