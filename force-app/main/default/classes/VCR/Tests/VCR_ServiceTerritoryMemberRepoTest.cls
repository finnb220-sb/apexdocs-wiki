/**
 * @author Booz Allen Hamilton
 * @since 5/24/24
 * @description Unit & functional tests for repository to handle all CRUD operations for ServiceTerritoryMember
 *
 * @see VCR_ServiceTerritoryMemberRepo
 */
@IsTest
private class VCR_ServiceTerritoryMemberRepoTest {
    private static final User MOLLY_MIN_ACCESS;
    private static final User VCC_APPT_VIEW_ADMIN;
    private static User drHarryPotterUser;
    private static User drHermioneGraingerUser;
    private static User drRonaldWeasleyUser;
    private static VCR_ServiceTerritoryMemberRepo systemUnderTest;

    static {
        MOLLY_MIN_ACCESS = VATEST_UserFactory.createMinAccessPersonaUser(false);
        VCC_APPT_VIEW_ADMIN = new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .setFields(User.TimeZoneSidKey, 'GMT')
            .withPermissionSet('VCC_VCV_Appointment_Viewer_Administrator')
            .build(true);
    }

    /**
     * @description Test that the repository class is constructed successfully.
     */
    @IsTest
    static void unitItConstructsPositive() {
        Test.startTest();
        System.runAs(MOLLY_MIN_ACCESS) {
            systemUnderTest = new VCR_ServiceTerritoryMemberRepo();
        }
        Test.stopTest();
        Assert.isNotNull(systemUnderTest, 'Expected a Repository to be constructed successfully.');
        Assert.areEqual(
            ServiceTerritoryMember.SObjectType,
            systemUnderTest.SObjectType,
            'Expected Repository to be constructed for ServiceTerritoryMember SobjectType'
        );
    }

    /**
     * @description Test that we can create & return a QueryLocator for all VISNs (empty set)
     */
    @IsTest
    static void unitFetchByVisnsForAllVISNsPositive() {
        createTestData();
        Test.startTest();
        Database.QueryLocator queryLoc;
        System.runAs(VCC_APPT_VIEW_ADMIN) {
            systemUnderTest = new VCR_ServiceTerritoryMemberRepo();
            queryLoc = systemUnderTest.fetchMembersForAllVisns();

            Assert.isNotNull(
                queryLoc,
                'Expected a valid QueryLocator to be returned successfully for empty list of VISN Names.'
            );
            Database.QueryLocatorIterator queryLocIterator = queryLoc.iterator();
            Assert.isTrue(
                queryLocIterator.hasNext(),
                'Expected records to be found and for an Iterator to have records to return.'
            );

            Integer count = 0;
            while (queryLocIterator.hasNext()) {
                SObject record = queryLocIterator.next();
                Assert.isTrue(
                    record instanceof ServiceTerritoryMember,
                    'Expected returned record to be an instance of ServiceTerritoryMember.'
                );

                ServiceTerritoryMember member = (ServiceTerritoryMember) record;
                Assert.isNotNull(
                    member.ServiceTerritory.Name,
                    'Expected ServiceTerritoryMember records to include ServiceTerritory Name field.'
                );
                count++;
            }
            // we should have 1 ServiceTerritoryMember for each ServiceResource/ServiceTerritory combo
            Assert.areEqual(
                [SELECT COUNT() FROM ServiceTerritory] * [SELECT COUNT() FROM ServiceResource],
                count,
                'Expected 1 ServiceTerritoryMember for each  VISN-Provider combination.'
            );
        }
        Test.stopTest();
    }

    /**
     * @description Test that we can create & return a QueryLocator for specific VISNs
     */
    @IsTest
    static void unitFetchByVisnNamesForSpecificVISNsPositive() {
        createTestData();
        Test.startTest();
        Database.QueryLocator queryLoc;
        System.runAs(VCC_APPT_VIEW_ADMIN) {
            systemUnderTest = new VCR_ServiceTerritoryMemberRepo();
            queryLoc = systemUnderTest.fetchMembersByVisnNames(new List<String>{ 'Test VISN A 0', 'Test VISN A 1' });

            Assert.isNotNull(
                queryLoc,
                'Expected a valid QueryLocator to be returned successfully for a list of valid VISN Names.'
            );
            Database.QueryLocatorIterator queryLocIterator = queryLoc.iterator();
            Assert.isTrue(
                queryLocIterator.hasNext(),
                'Expected records to be found and for an Iterator to have records to return.'
            );

            Integer count = 0;
            while (queryLocIterator.hasNext()) {
                queryLocIterator.next();
                count++;
            }
            // we should have 1 ServiceTerritoryMember for each ServiceResource & our 2 VISNs
            Assert.areEqual(
                2 * [SELECT COUNT() FROM ServiceResource],
                count,
                'Expected 1 ServiceTerritoryMember for each VISN provided (so # of Providers *2).'
            );
        }
        Test.stopTest();
    }

    /**
     * @description Test that we can create & return a QueryLocator for specific VISNs when there are no results
     */
    @IsTest
    static void unitFetchByVisnNamesForEmptyResultsNegative() {
        createTestData();
        Test.startTest();
        Database.QueryLocator queryLoc;
        System.runAs(VCC_APPT_VIEW_ADMIN) {
            systemUnderTest = new VCR_ServiceTerritoryMemberRepo();
            queryLoc = systemUnderTest.fetchMembersByVisnNames(
                new List<String>{ 'Unknown VISN Name1', 'Unknown VISN Name2' }
            );

            Assert.isNotNull(
                queryLoc,
                'Expected a valid (empty but  not null) QueryLocator to be returned when there are no results.'
            );
            Database.QueryLocatorIterator queryLocIterator = queryLoc.iterator();
            Assert.isFalse(
                queryLocIterator.hasNext(),
                'Expected no records to be returned for non-existant VISN names.'
            );
        }
        Test.stopTest();
    }

    /**
     * @description Test that we can create & throw an exception when input is invalid
     */
    @IsTest
    static void unitFetchByVisnNamesWithNullInputNegative() {
        createTestData();
        Test.startTest();
        Database.QueryLocator queryLoc;
        System.runAs(VCC_APPT_VIEW_ADMIN) {
            systemUnderTest = new VCR_ServiceTerritoryMemberRepo();
            try {
                queryLoc = systemUnderTest.fetchMembersByVisnNames(null);
                Assert.isTrue(
                    false,
                    'Expected an IllegalArgumentException to be thrown for a null argument (list of  VISN names).'
                );
            } catch (IllegalArgumentException exc) {
                Assert.isTrue(
                    exc.getMessage().startsWith('Required list of VISN Names to search by must be provided'),
                    'Expected an  IllegalArgumentException to be thrown due to invalid List<String> for  VISN Names provided.'
                );
            }
        }
        Test.stopTest();
    }

    /**
     * @description Test that we can create & return a QueryLocator for specific VISN Ids
     */
    @IsTest
    static void unitFetchByVisnNamesForSpecificVISNIdsPositive() {
        List<ServiceTerritoryMember> members = createTestData();
        List<Id> visnIds = new List<Id>();
        for (ServiceTerritoryMember member : members) {
            visnIds.add(member.ServiceTerritoryId);
        }
        Test.startTest();
        Database.QueryLocator queryLoc;
        System.runAs(VCC_APPT_VIEW_ADMIN) {
            systemUnderTest = new VCR_ServiceTerritoryMemberRepo();
            queryLoc = systemUnderTest.fetchMembersByVisnIds(visnIds);

            Assert.isNotNull(
                queryLoc,
                'Expected a valid QueryLocator to be returned successfully for a list of valid VISN Ids.'
            );
            Database.QueryLocatorIterator queryLocIterator = queryLoc.iterator();
            Assert.isTrue(
                queryLocIterator.hasNext(),
                'Expected records to be found and for an Iterator to have records to return.'
            );

            Integer count = 0;
            while (queryLocIterator.hasNext()) {
                queryLocIterator.next();
                count++;
            }
            // we should have 1 ServiceTerritoryMember for each ServiceResource & VISNs
            Assert.areEqual(members.size(), count, 'Expected 1 ServiceTerritoryMember for each VISN Id provided.');
        }
        Test.stopTest();
    }

    /**
     * @description Test that we can create & throw an exception when list of VISN Ids input is invalid
     */
    @IsTest
    static void unitFetchByVisnIdsWithNullInputNegative() {
        createTestData();
        Test.startTest();
        Database.QueryLocator queryLoc;
        System.runAs(VCC_APPT_VIEW_ADMIN) {
            systemUnderTest = new VCR_ServiceTerritoryMemberRepo();
            try {
                queryLoc = systemUnderTest.fetchMembersByVisnIds(null);
                Assert.isTrue(
                    false,
                    'Expected an IllegalArgumentException to be thrown for a null argument (list of  VISN Ids).'
                );
            } catch (IllegalArgumentException exc) {
                Assert.isTrue(
                    exc.getMessage().startsWith('Required list of VISN Ids to search by must be provided'),
                    'Expected an  IllegalArgumentException to be thrown due to invalid List<Id> for  VISN Ids provided.'
                );
            }
        }
        Test.stopTest();
    }

    /**
     * @description Test that we can create & return a query string for specific VISN Names
     */
    @IsTest
    static void unitGetQueryStringForSpecificVISNsPositive() {
        String queryString;
        Test.startTest();
        System.runAs(VCC_APPT_VIEW_ADMIN) {
            systemUnderTest = new VCR_ServiceTerritoryMemberRepo();
            queryString = systemUnderTest.getQueryForNamedVISNs();
        }
        Test.stopTest();
        Assert.isNotNull(
            queryString,
            'Expected a valid query string to be returned successfully to query on a list of valid VISN Names.'
        );
        Assert.isTrue(
            queryString.containsIgnoreCase('ServiceTerritory.Name IN:queryArg'),
            'Expected a query string with a where clause on ServiceTerritory Name for queryArg bind variable.'
        );
    }

    /**
     * @description Test that we can create & return a query string for specific VISN Names
     */
    @IsTest
    static void unitGetQueryStringForSpecificVISNIdsPositive() {
        String queryString;
        Test.startTest();
        System.runAs(VCC_APPT_VIEW_ADMIN) {
            systemUnderTest = new VCR_ServiceTerritoryMemberRepo();
            queryString = systemUnderTest.getQueryForVISNIds();
        }
        Test.stopTest();
        Assert.isNotNull(
            queryString,
            'Expected a valid query string to be returned successfully to query on a list of valid VISN Ids.'
        );
        Assert.isTrue(
            queryString.containsIgnoreCase('ServiceTerritoryId IN:queryArg'),
            'Expected a query string containing a where clause on ServiceTerritoryId for queryArg bind variable.'
        );
    }

    /**
     * @description Test that we can create & return a query string for ALL VISNs
     */
    @IsTest
    static void unitGetQueryStringForAllVISNsPositive() {
        String queryString;
        Test.startTest();
        System.runAs(VCC_APPT_VIEW_ADMIN) {
            systemUnderTest = new VCR_ServiceTerritoryMemberRepo();
            queryString = systemUnderTest.getQueryForAllVISNs();
        }
        Test.stopTest();
        Assert.isNotNull(
            queryString,
            'Expected a valid query string to be returned successfully to query on Users Timezone.'
        );
        Assert.isFalse(
            queryString.containsIgnoreCase(':queryArg'),
            'Expected a query string with a where clause without a queryArg bind variable.'
        );
    }
    /**
     * @description Test that we can create & return a query string for ALL VISNs in users timezone
     */
    @IsTest
    static void unitGetQueryStringForAllVISNsInUserTimezonePositive() {
        String queryString;
        Test.startTest();
        System.runAs(VCC_APPT_VIEW_ADMIN) {
            systemUnderTest = new VCR_ServiceTerritoryMemberRepo();
            queryString = systemUnderTest.getQueryForAllVISNsInUserTimezone();
        }
        Test.stopTest();
        Assert.isNotNull(
            queryString,
            'Expected a valid query string to be returned successfully to query on Users Timezone.'
        );
        Assert.isTrue(
            queryString.containsIgnoreCase('AND ServiceTerritory.OperatingHours.TimeZone = :queryArg'),
            'Expected a query string with a where clause on ServiceTerritory Operating Hours Timezone for queryArg bind variable.'
        );
    }

    private static List<ServiceTerritoryMember> createTestData() {
        createTestProviderUsers();
        List<ServiceTerritoryMember> members = new List<ServiceTerritoryMember>();
        System.runAs(VCC_APPT_VIEW_ADMIN) {
            List<ServiceResource> providers = new List<ServiceResource>();
            providers.add(
                (ServiceResource) VATEST_SObjectFactory.createSObject(
                    new ServiceResource(
                        Name = 'Dr Harry Potter',
                        RelatedRecordId = drHarryPotterUser.Id,
                        IsActive = true
                    ),
                    true
                )
            );
            providers.add(
                (ServiceResource) VATEST_SObjectFactory.createSObject(
                    new ServiceResource(
                        Name = 'Dr Hermione Grainger',
                        RelatedRecordId = drHermioneGraingerUser.Id,
                        IsActive = true
                    ),
                    true
                )
            );
            providers.add(
                (ServiceResource) VATEST_SObjectFactory.createSObject(
                    new ServiceResource(
                        Name = 'Dr Ronald Weasley',
                        RelatedRecordId = drRonaldWeasleyUser.Id,
                        IsActive = true
                    ),
                    true
                )
            );

            OperatingHours opHours = (OperatingHours) VATEST_SObjectFactory.createSObject(
                new OperatingHours(Name = 'VISN Operating Hours'),
                true
            );

            List<ServiceTerritory> visns = (List<ServiceTerritory>) VATEST_SObjectFactory.createSObjects(
                new ServiceTerritory(Name = 'Test VISN A', IsActive = true, OperatingHoursId = opHours.Id),
                4,
                true
            );

            Integer testYear = Date.today().year();
            for (ServiceTerritory visn : visns) {
                for (ServiceResource provider : providers) {
                    ServiceTerritoryMember member = (ServiceTerritoryMember) VATEST_SObjectFactory.createSObject(
                        new ServiceTerritoryMember(
                            EffectiveStartDate = Date.newInstance(testYear, 1, 1),
                            EffectiveEndDate = Date.newInstance(testYear, 12, 31),
                            ServiceTerritoryId = visn.Id,
                            ServiceResourceId = provider.Id
                        ),
                        true
                    );
                    members.add(member);
                }
                testYear++;
            }
        }
        return members;
    }

    private static void createTestProviderUsers() {
        drHarryPotterUser = new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .setFields(User.TimeZoneSidKey, 'GMT')
            .setFields(User.FirstName, 'Harry')
            .setFields(User.FirstName, 'Potter')
            .withPermissionSet('VCC_VCV_Appointment_Viewer_Administrator')
            .build(true);
        drHermioneGraingerUser = new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .setFields(User.TimeZoneSidKey, 'GMT')
            .setFields(User.FirstName, 'Hermione')
            .setFields(User.FirstName, 'Grainger')
            .withPermissionSet('VCC_VCV_Appointment_Viewer_Administrator')
            .build(true);
        drRonaldWeasleyUser = new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .setFields(User.TimeZoneSidKey, 'GMT')
            .setFields(User.FirstName, 'Ronald')
            .setFields(User.FirstName, 'Weasley')
            .withPermissionSet('VCC_VCV_Appointment_Viewer_Administrator')
            .build(true);
    }
}
