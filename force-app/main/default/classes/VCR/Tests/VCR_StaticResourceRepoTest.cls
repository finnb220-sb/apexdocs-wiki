/**
 * @description Tests the VCR_StaticResourceRepo class
 * @author Booz Allen Hamilton
 *
 * @see VCR_StaticResourceRepo for class being tested
 */
@IsTest
private with sharing class VCR_StaticResourceRepoTest {
    @IsTest
    private static void unitConstructorPositive() {
        System.runAs(createTestUser()) {
            Test.startTest();
            try {
                Assert.isNotNull(
                    new VCR_StaticResourceRepo(),
                    'Expected VCR_StaticResourceRepo to construct successfully'
                );
            } catch (Exception thrownException) {
                Assert.fail(
                    'Expected no exception, instead found ' +
                        thrownException.getTypeName() +
                        '\n' +
                        thrownException.getStackTraceString()
                );
            }
            Test.stopTest();
        }
    }

    @IsTest
    private static void funcFetchByNamePositive() {
        System.runAs(createTestUser()) {
            Test.startTest();
            try {
                List<StaticResource> staticResourcesFromFetch = (new VCR_StaticResourceRepo())
                    .fetchByName('VCC_DasWriteNoteAndSign1000');
                Assert.areEqual(1, staticResourcesFromFetch.size(), 'Expected one result from repo');
            } catch (Exception thrownException) {
                Assert.fail(
                    'Expected no exception, instead found ' +
                        thrownException.getTypeName() +
                        '\n' +
                        thrownException.getStackTraceString()
                );
            }
            Test.stopTest();
        }
    }

    @IsTest
    private static void funcFetchByNameEmptyNameNegative() {
        System.runAs(createTestUser()) {
            Test.startTest();
            try {
                List<StaticResource> staticResourcesFromFetch = (new VCR_StaticResourceRepo()).fetchByName('');
                Assert.areEqual(0, staticResourcesFromFetch.size(), 'Expected zero results from repo');
            } catch (Exception thrownException) {
                Assert.fail(
                    'Expected no exception, instead found ' +
                        thrownException.getTypeName() +
                        '\n' +
                        thrownException.getStackTraceString()
                );
            }
            Test.stopTest();
        }
    }

    @IsTest
    private static void funcFetchByNameNullNegative() {
        System.runAs(createTestUser()) {
            Test.startTest();
            try {
                List<StaticResource> staticResourcesFromFetch = (new VCR_StaticResourceRepo()).fetchByName(null);
                Assert.areEqual(0, staticResourcesFromFetch.size(), 'Expected zero results from repo');
            } catch (Exception thrownException) {
                Assert.fail(
                    'Expected no exception, instead found ' +
                        thrownException.getTypeName() +
                        '\n' +
                        thrownException.getStackTraceString()
                );
            }
            Test.stopTest();
        }
    }

    private static User createTestUser() {
        return new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
    }
}
