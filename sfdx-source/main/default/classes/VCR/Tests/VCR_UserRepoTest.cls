/**
 * @description Tests the VCR_UserRepoTest class.
 * @author Booz Allen
 *
 * @see VCR_UserRepo for class being tested
 */

@IsTest
public with sharing class VCR_UserRepoTest {
    //test reference constants
    private static final User ADMIN_USER;
    //test data
    private static final Set<String> PERMISSIONS = new Set<String>{ 'VAHC_Standard_VCC_User' };
    static {
        ADMIN_USER = new VATEST_UserBuilder()
            .withUserProfile('System Administrator')
            .withPermissionSets(PERMISSIONS)
            .withStandardData()
            .build(true);
    }

    /**
     * @description Test if the VCR_UserRepo was instantiated
     */
    @IsTest
    static void unitTestConstructorPositive() {
        System.runAs(ADMIN_USER) {
            Test.startTest();
            VCR_UserRepo repo = new VCR_UserRepo();
            Test.stopTest();
            Assert.isNotNull(repo, 'Expected constructor to properly instantiate a VCR_UserRepo');
        }
    }

    /**
     * @description Tests if an ID can be received based on inputed name
     */
    @IsTest
    static void unitTestgetIdByNamePositive() {
        System.runAs(ADMIN_USER) {
            User person = [SELECT Id, name FROM User LIMIT 1];
            String personName = person.name;
            Test.startTest();
            VCR_UserRepo repo = new VCR_UserRepo();
            List<User> users = repo.getIdByName(personName);
            Test.stopTest();
            Assert.areEqual(users[0].Id, person.Id, 'Expected Matchind Ids');
        }
    }

    /**
     * @description positive test of getIdByLastName to ensure a user is returned when their last name is provided as a parameter
     */
    @IsTest
    static void unitTestGetIdByLastNamePositive() {
        System.runAs(ADMIN_USER) {
            User person = [SELECT Id, LastName FROM User LIMIT 1];
            VCR_UserRepo repo = new VCR_UserRepo();

            Test.startTest();

            List<User> results = repo.getIdByLastName(person.LastName);

            Test.stopTest();

            Assert.areEqual(
                results[0].Id,
                person.Id,
                'Expected the Id of the retrieved user to match the user whose last name was provided as a parameter to the getIdByLastName() method'
            );
        }
    }

    /**
     * @description positive test of fetchUsersByIds to ensure a user is returned when a Set of Ids containing their SF Id is provided as a parameter
     */
    @IsTest
    private static void funcFetchUsersByIdsPositive() {
        // Test data setup
        User person = [SELECT Id FROM User LIMIT 1];
        VCR_UserRepo repo = new VCR_UserRepo();

        // Actual test
        Test.startTest();

        List<User> results;
        System.runAs(ADMIN_USER) {
            results = repo.fetchUsersByIds(new Set<String>{ person.Id });
        }

        Test.stopTest();

        // Asserts
        Assert.areEqual(
            person.Id,
            results?.get(0)?.Id,
            'Expected the Id of the retrieved user to match the user whose Id was provided as a parameter to the fetchUsersByIds() method'
        );
    }
}
