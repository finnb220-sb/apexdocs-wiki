@IsTest
class VCC_EmailNotificationServiceTest {
    private static final String TEST_CASE_SUBJECT_SUCCESS = 'Test';
    private static final String TEST_CASE_SUBJECT_FAILURE = 'TestFailure';
    private static final String USERNAME_PREFIX = 'antv';
    public static final String VAVET_BASE_PROFILE = 'VAVET Base Profile';
    public static final String HEALTHCLOUDFOUNDATION = 'HealthCloudFoundation';
    public static final String TEST_SEND_EMAIL_ERROR_MESSAGE = 'SendEmail failed. First exception on row 0; first error: INVALID_EMAIL_ADDRESS, Email address is invalid: testgmail.com: [toAddresses, testgmail.com]';
    private static final List<String> PERMISSION_SET_GROUP_NAMES = new List<String>{
        'VCC_Registered_Nurse',
        'VCC_Medical_Provider',
        'TED_Medical_Provider_Group',
        'TED_Registered_Nurse_Group'
    };

    @TestSetup
    static void setup() {
        createAndConfigureTestUsers(PERMISSION_SET_GROUP_NAMES);
    }
    private static void createAndConfigureTestUsers(List<String> permissionSetGroupNames) {
        List<User> userList = createUserList(permissionSetGroupNames);
        update userList;
    }

    private static List<Id> fetchPermissionSetGroupIds(List<String> psgNames) {
        List<Id> psgIds = new List<Id>();

        for (PermissionSetGroup psg : [
            SELECT Id
            FROM PermissionSetGroup
            WHERE DeveloperName IN :psgNames
        ]) {
            psgIds.add(psg.Id);
        }

        return psgIds;
    }

    private static List<User> createUserList(List<String> permissionSetGroupNames) {
        List<User> userList = new List<User>();
        List<Id> psgIds = fetchPermissionSetGroupIds(permissionSetGroupNames);

        Test.calculatePermissionSetGroup(psgIds);

        for (Integer i = 0; i < permissionSetGroupNames.size(); i++) {
            User testUser = createUserWithPermissionsAndConfigurations(permissionSetGroupNames, i);
            userList.add(testUser);
        }
        return userList;
    }
    private static User createUserWithPermissionsAndConfigurations(List<String> permissionSetGroupNames, Integer i) {
        User testUser = VCC_TestDataFactory.insertUser(VAVET_BASE_PROFILE);
        applyPermissionsAndConfigurationsToUser(permissionSetGroupNames, i, testUser);
        return testUser;
    }
    private static void applyPermissionsAndConfigurationsToUser(List<String> permissionSetGroupNames, Integer i, User testUser) {
        VCC_TestDataFactory.addPermSetGroupToUser(permissionSetGroupNames[i], testUser);
        VCC_TestDataFactory.assignPermissionSetByName(testUser, HEALTHCLOUDFOUNDATION);
        testUser.Username = generateUsername(i, testUser);
        testUser.Title = permissionSetGroupNames[i];
    }
    private static String generateUsername(Integer i, User testUser) {
        return USERNAME_PREFIX + testUser.Username + i;
    }
    private static User getTestUser(Integer offset) {
        return [
            SELECT Id, MVIICN__c, Title
            FROM User
            WHERE Username LIKE :USERNAME_PREFIX + '%'
            LIMIT 1
            OFFSET :offset
        ];
    }
    @IsTest
    static void testVCC_EmailNotificationService() {
        Test.startTest();
        for (Integer i = 0; i < PERMISSION_SET_GROUP_NAMES.size(); i++) {
            User testUser = getTestUser(i);
            VCC_EmailNotificationService.EmailResponse emailResponseObj = new VCC_EmailNotificationService.EmailResponse();
            System.runAs(testUser) {
                try {
                    Case c = new Case(RecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Clinical Triage Case').getRecordTypeId());
                    insert c;
                    List<VCC_EmailNotificationService.EmailInfo> emailInfoList = new List<VCC_EmailNotificationService.EmailInfo>();
                    VCC_EmailNotificationService.EmailInfo emailInfoObj = new VCC_EmailNotificationService.EmailInfo();
                    emailInfoObj.templateId = [
                        SELECT Id
                        FROM EmailTemplate
                        ORDER BY CreatedDate DESC
                        LIMIT 1
                    ]
                    .Id;
                    emailInfoObj.subject = TEST_CASE_SUBJECT_SUCCESS;
                    emailInfoObj.objectId = c.Id;

                    emailInfoObj.emails = new List<String>{ 'test@gmail.com' };
                    emailInfoObj.templateBody = 'Test';
                    emailInfoList.add(emailInfoObj);
                    VCC_EmailNotificationService.sendEmail(emailInfoList);
                    emailInfoObj.orgWideAddressId = [
                        SELECT Id
                        FROM OrgWideEmailAddress
                        LIMIT 1
                    ][0]
                    .Id;
                    emailResponseObj = VCC_EmailNotificationService.sendEmail(emailInfoList)[0];
                } catch (Exception e) {
                    Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
                }
            }
            System.Assert.areEqual(emailResponseObj.status, true);
        }
        Test.stopTest();
    }
    @IsTest
    static void testVCC_EmailNotificationService_Failure() {
        // .... Your setup code here
        Test.startTest();
        for (Integer i = 0; i < PERMISSION_SET_GROUP_NAMES.size(); i++) {
            User testUser = getTestUser(i);
            VCC_EmailNotificationService.EmailResponse emailResponseObj = new VCC_EmailNotificationService.EmailResponse();
            System.runAs(testUser) {
                try {
                    Case c = new Case(RecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Clinical Triage Case').getRecordTypeId());
                    insert c;
                    List<VCC_EmailNotificationService.EmailInfo> emailInfoList = new List<VCC_EmailNotificationService.EmailInfo>();
                    VCC_EmailNotificationService.EmailInfo emailInfoObj = new VCC_EmailNotificationService.EmailInfo();
                    emailInfoObj.templateId = [
                        SELECT Id
                        FROM EmailTemplate
                        ORDER BY CreatedDate DESC
                        LIMIT 1
                    ]
                    .Id;
                    emailInfoObj.subject = TEST_CASE_SUBJECT_FAILURE;
                    emailInfoObj.objectId = c.Id;

                    // Set the rest of your email parameter same as previous test

                    emailInfoObj.emails = new List<String>{ 'testgmail.com' };
                    emailInfoObj.templateBody = 'Test';
                    emailInfoList.add(emailInfoObj);
                    VCC_EmailNotificationService.sendEmail(emailInfoList);
                    emailInfoObj.orgWideAddressId = [
                        SELECT Id
                        FROM OrgWideEmailAddress
                        LIMIT 1
                    ][0]
                    .Id;
                    emailResponseObj = VCC_EmailNotificationService.sendEmail(emailInfoList)[0];
                } catch (Exception e) {
                    emailResponseObj.error = e.getMessage();
                    emailResponseObj.status = false;
                    System.assertEquals(TEST_SEND_EMAIL_ERROR_MESSAGE, e.getMessage());
                }
            }
            System.debug('emailResponseObj: ' + emailResponseObj);
            //Assert that status is false
            System.Assert.areEqual(emailResponseObj.status, false);
            //Assert that error message is same as setup
            System.Assert.areEqual(emailResponseObj.error, TEST_SEND_EMAIL_ERROR_MESSAGE);
        }
        Test.stopTest();
    }
}
