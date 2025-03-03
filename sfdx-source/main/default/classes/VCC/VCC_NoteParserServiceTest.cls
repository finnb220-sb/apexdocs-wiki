@isTest
public with sharing class VCC_NoteParserServiceTest {
    //adding small change here so it gets deployed to stage3 - again

    private static String username = 'npst';

    @TestSetup
    /**
     * @description test method
     */
    public static void makeData() {
        // List<User> userList = new List<User>();
        List<String> psgNames = new List<String>{
            'VCC_Registered_Nurse',
            'VCC_Medical_Provider',
            'VCC_Advanced_Medical_Support_Assistant',
            'VCC_Pharmacy_I',
            'VCC_Pharmacy_II',
            'VCC_Pharmacy_III',
            'TED_Medical_Provider_Group',
            'TED_Registered_Nurse_Group'
        };

        User testUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser(psgNames[0], testUser);
        VCC_TestDataFactory.assignPermissionSetByName(testUser, 'HealthCloudFoundation');
        update testUser;
    }

    /**
     * @description test method
     * @return A test user
     */

    public static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
    }

    @IsTest
    static void getReplacementCharCodeMapTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            try {
                Map<Integer, Integer> replacementCharMap = VCC_NoteParserService.characterReplacementMap;
                Assert.isNotNull(replacementCharMap, 'Expected non-null value.');
                Assert.isFalse(replacementCharMap.isEmpty(), 'Expected a non-empty map.');
            } catch (Exception e) {
                Assert.fail('Unexpected exception.');
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void getHelpTextsMapTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            try {
                Map<String, String> helpTextsMap = VCC_NoteParserService.helpTextMap;
                Assert.isNotNull(helpTextsMap, 'Expected non-null value.');
                Assert.isFalse(helpTextsMap.isEmpty(), 'Expected a non-empty map.');
            } catch (Exception e) {
                Assert.fail('Unexpected exception.');
            }
        }
        Test.stopTest();
    }
}
