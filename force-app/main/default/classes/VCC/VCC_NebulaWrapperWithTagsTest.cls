/**
 * @description Test class for VCC_NebulaWrapperWithTags
 * @author Booz Allen Hamilton
 * @see VCC_NebuleWrapperWithTags
 */

@IsTest
private class VCC_NebulaWrapperWithTagsTest {
    /**
     * @description Creating an Admin test user
     * @return `User`
     */
    private static User createTestAdminUser() {
        return (new VATEST_UserBuilder())
            .withStandardData()
            .withUserProfile('System Administrator')
            .withPermissionSets(
                new Set<String>(
                    new List<String>{
                        'VAHC_RN_User',
                        'VAHC_Write_Clinical_Triage_Progress_Note',
                        'VAHC_Read_Progress_Notes',
                        'VAHC_Write_Virtual_Clinic_Visit_Progress_Note',
                        'VAHC_MP_User'
                    }
                )
            )
            .build(true);
    }

    @IsTest
    static void unitConstructorPositive() {
        System.runAs(createTestAdminUser()) {
            Test.startTest();
            Set<String> tags = new Set<String>{ 'test' };
            VCC_NebulaWrapperWithTags nebulaWrapper = new VCC_NebulaWrapperWithTags(tags);
            Assert.isTrue(nebulaWrapper.tags.containsAll(tags), 'Expected "tags" attribute to contain the test tag');
            Test.stopTest();
        }
    }

    @IsTest
    static void unitAddTagsPositive() {
        System.runAs(createTestAdminUser()) {
            Test.startTest();
            Set<String> tags = new Set<String>{ 'test' };
            VCC_NebulaWrapperWithTags nebulaWrapper = new VCC_NebulaWrapperWithTags();
            Assert.isTrue(nebulaWrapper.tags.isEmpty(), 'Expected "tags" attribute to be empty');
            nebulaWrapper.addTags(tags);
            Assert.isTrue(nebulaWrapper.tags.containsAll(tags), 'Expected "tags" attribute to contain the test tag');
            Test.stopTest();
        }
    }

    @IsTest
    static void unitRemoveTagsPositive() {
        System.runAs(createTestAdminUser()) {
            Test.startTest();
            Set<String> tags = new Set<String>{ 'test' };
            VCC_NebulaWrapperWithTags nebulaWrapper = new VCC_NebulaWrapperWithTags(tags);
            Assert.isTrue(nebulaWrapper.tags.containsAll(tags), 'Expected "tags" attribute to contain the test tag');
            nebulaWrapper.removeTags(tags);
            Assert.isTrue(nebulaWrapper.tags.isEmpty(), 'Expected "tags" attribute to be empty');
            Test.stopTest();
        }
    }

    @IsTest
    static void unitDebugPositive() {
        System.runAs(createTestAdminUser()) {
            Test.startTest();
            Set<String> tags = new Set<String>{ 'test' };
            VCC_NebulaWrapperWithTags nebulaWrapper = new VCC_NebulaWrapperWithTags(tags);
            Assert.isNotNull(nebulaWrapper.debug('test'), 'Expected non-null return value');
            Test.stopTest();
        }
    }

    @IsTest
    static void unitErrorPositive() {
        System.runAs(createTestAdminUser()) {
            Test.startTest();
            Set<String> tags = new Set<String>{ 'test' };
            VCC_NebulaWrapperWithTags nebulaWrapper = new VCC_NebulaWrapperWithTags(tags);
            Assert.isNotNull(nebulaWrapper.error('test', new NullPointerException()), 'Expected non-null return value');
            Test.stopTest();
        }
    }
}
