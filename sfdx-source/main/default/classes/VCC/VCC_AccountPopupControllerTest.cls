/**
 * @description Test class for VCC_AccountPopupController
 * @author Booz Allen Hamilton
 * @see VCC_AccountPopupController
 */
@isTest
private with sharing class VCC_AccountPopupControllerTest {
    private static final String USERNAME = 'apc';
    final static Id PERSON_RECORD_TYPE_ID = new VCR_AccountRepo()
        .recordTypeConstant.fromDeveloperName('PersonAccount')
        .Id;

    private static final String RN_PSG_NAME = 'VCC_Registered_Nurse';
    private static final String MP_PSG_NAME = 'VCC_Medical_Provider';
    private static final String MSA_PSG_NAME = 'VCC_Advanced_Medical_Support_Assistant';
    private static final String PHARM_I_PSG_NAME = 'VCC_Pharmacy_I';
    private static final String PHARM_II_PSG_NAME = 'VCC_Pharmacy_II';
    private static final String PHARM_III_PSG_NAME = 'VCC_Pharmacy_III';
    private static final String TED_MP_PSG_NAME = 'TED_Medical_Provider_Group';
    private static final String TED_RN_PSG_NAME = 'TED_Registered_Nurse_Group';
    private static final String LOG_VIEWER_PERM_SET_NAME = 'LoggerLogViewer';

    @TestSetup
    private static void makeData() {
        List<String> psgNames = new List<String>{
            RN_PSG_NAME,
            MP_PSG_NAME,
            MSA_PSG_NAME,
            PHARM_I_PSG_NAME,
            PHARM_II_PSG_NAME,
            PHARM_III_PSG_NAME,
            TED_MP_PSG_NAME,
            TED_RN_PSG_NAME,
            LOG_VIEWER_PERM_SET_NAME
        };
        for (Integer index = 0; index < psgNames.size(); index++) {
            new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .withPermissionSet(psgNames[index])
                .setFields(User.Username, USERNAME + psgNames[index] + '@fake.com')
                .build(true);
        }
    }

    private static List<User> getAllTestUsers() {
        return [SELECT Id, MVIICN__c FROM User WHERE Username LIKE :username + '%'];
    }

    private static User getTestUser(String psgName) {
        return [SELECT Id, MVIICN__c FROM User WHERE Username LIKE :(USERNAME + psgName + '%') LIMIT 1];
    }

    @IsTest
    static void unitShowOwnAccountPopupPositive() {
        Boolean stubbedReturnValue = true;

        VCC_Stub accountModuleStub = VCC_ModuleService.stubModule(VCC_AccountModule.class);
        accountModuleStub.setReturnValue('isRunningUsersAccount', stubbedReturnValue);

        Test.startTest();
        System.runAs(getTestUser(RN_PSG_NAME)) {
            Assert.areEqual(
                VCC_AccountPopupController.showOwnAccountPopup(VATEST_IdFactory.get(Account.SObjectType)),
                stubbedReturnValue,
                'Expected "true" because "isRunningUsersAccount" was stubbed to return "true", which indicates the "Own Account Popup" should be displayed'
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void funcShowOwnAccountPopupPositive() {
        Account testAccount = new Account(
            LastName = 'test',
            VCC_MVI_External_Id__pc = String.valueOf(Crypto.getRandomInteger()),
            RecordTypeId = PERSON_RECORD_TYPE_ID
        );
        insert testAccount;
        User testRunAsUser = getTestUser(RN_PSG_NAME);
        insert new AccountShare(
            AccountId = testAccount.Id,
            UserOrGroupId = testRunAsUser.Id,
            AccountAccessLevel = 'Edit',
            OpportunityAccessLevel = 'Edit'
        );
        System.runAs(testRunAsUser) {
            Test.startTest();
            for (User testUser : getAllTestUsers()) {
                Assert.isFalse(
                    VCC_AccountPopupController.showOwnAccountPopup(testAccount.Id),
                    'Expected "showOwnAccountPopup" method to return "false" because the value of the running user MVIICN__c field does not match the accounts VCC_MVI_External_Id__pc value'
                );
            }
            Test.stopTest();
        }
    }

    private static VCC_AccountPopupController.PopupResponseDTO testBodyGetsertRecentViewAndAcknowledge() {
        Account testAccount = new Account(LastName = 'test', RecordTypeId = PERSON_RECORD_TYPE_ID);
        insert testAccount;
        VCC_AccountPopupController.getsertRecentView(testAccount.Id, VCC_RecentViewHelper.TYPE_IN_PATIENT);
        VCC_AccountPopupController.acknowledgeRecentView(testAccount.Id, VCC_RecentViewHelper.TYPE_SENSITIVE_PATIENT);
        return VCC_AccountPopupController.getPopupFlags(testAccount.Id);
    }

    @IsTest
    static void funcGetsertRecentViewAndAcknowledgeRNPositive() {
        User testUser = getTestUser(RN_PSG_NAME);
        System.runAs(testUser) {
            Test.startTest();
            VCC_AccountPopupController.PopupResponseDTO popupDto = testBodyGetsertRecentViewAndAcknowledge();
            Test.stopTest();
            Assert.isFalse(
                popupDto.isShowSensitivePatientPopup,
                'Expected "isShowSensitivePatientPopup" to be false because that flag was acknowledged by the RN test user'
            );
        }
    }

    @IsTest
    static void funcGetsertRecentViewAndAcknowledgeMPPositive() {
        User testUser = getTestUser(MP_PSG_NAME);
        System.runAs(testUser) {
            Test.startTest();
            VCC_AccountPopupController.PopupResponseDTO popupDto = testBodyGetsertRecentViewAndAcknowledge();
            Test.stopTest();
            Assert.isFalse(
                popupDto.isShowSensitivePatientPopup,
                'Expected "isShowSensitivePatientPopup" to be false because that flag was acknowledged by the MP test user'
            );
        }
    }

    @IsTest
    static void funcGetsertRecentViewAndAcknowledgeAMSAPositive() {
        User testUser = getTestUser(MSA_PSG_NAME);
        System.runAs(testUser) {
            Test.startTest();
            VCC_AccountPopupController.PopupResponseDTO popupDto = testBodyGetsertRecentViewAndAcknowledge();
            Test.stopTest();
            Assert.isFalse(
                popupDto.isShowSensitivePatientPopup,
                'Expected "isShowSensitivePatientPopup" to be false because that flag was acknowledged by the AMSA test user'
            );
        }
    }

    @IsTest
    static void funcGetsertRecentViewAndAcknowledgePharmIPositive() {
        User testUser = getTestUser(PHARM_I_PSG_NAME);
        System.runAs(testUser) {
            Test.startTest();
            VCC_AccountPopupController.PopupResponseDTO popupDto = testBodyGetsertRecentViewAndAcknowledge();
            Test.stopTest();
            Assert.isFalse(
                popupDto.isShowSensitivePatientPopup,
                'Expected "isShowSensitivePatientPopup" to be false because that flag was acknowledged by the Pharm I test user'
            );
        }
    }

    @IsTest
    static void funcGetsertRecentViewAndAcknowledgePharmIIPositive() {
        User testUser = getTestUser(PHARM_II_PSG_NAME);
        System.runAs(testUser) {
            Test.startTest();
            VCC_AccountPopupController.PopupResponseDTO popupDto = testBodyGetsertRecentViewAndAcknowledge();
            Test.stopTest();
            Assert.isFalse(
                popupDto.isShowSensitivePatientPopup,
                'Expected "isShowSensitivePatientPopup" to be false because that flag was acknowledged by the Pharm II test user'
            );
        }
    }

    @IsTest
    static void funcGetsertRecentViewAndAcknowledgePharmIIIPositive() {
        User testUser = getTestUser(PHARM_III_PSG_NAME);
        System.runAs(testUser) {
            Test.startTest();
            VCC_AccountPopupController.PopupResponseDTO popupDto = testBodyGetsertRecentViewAndAcknowledge();
            Test.stopTest();
            Assert.isFalse(
                popupDto.isShowSensitivePatientPopup,
                'Expected "isShowSensitivePatientPopup" to be false because that flag was acknowledged by the Pharm III test user'
            );
        }
    }

    @IsTest
    static void funcGetsertRecentViewAndAcknowledgeTedMPPositive() {
        User testUser = getTestUser(TED_MP_PSG_NAME);
        System.runAs(testUser) {
            Test.startTest();
            VCC_AccountPopupController.PopupResponseDTO popupDto = testBodyGetsertRecentViewAndAcknowledge();
            Test.stopTest();
            Assert.isFalse(
                popupDto.isShowSensitivePatientPopup,
                'Expected "isShowSensitivePatientPopup" to be false because that flag was acknowledged by the Ted MP test user'
            );
        }
    }

    @IsTest
    static void funcGetsertRecentViewAndAcknowledgeTedRNPositive() {
        User testUser = getTestUser(TED_RN_PSG_NAME);
        System.runAs(testUser) {
            Test.startTest();
            VCC_AccountPopupController.PopupResponseDTO popupDto = testBodyGetsertRecentViewAndAcknowledge();
            Test.stopTest();
            Assert.isFalse(
                popupDto.isShowSensitivePatientPopup,
                'Expected "isShowSensitivePatientPopup" to be false because that flag was acknowledged by the Ted RN test user'
            );
        }
    }

    /**
     * @description funcGetPopupFlagsPositive confirms that a user that does not have an existing VCC_Recent_View__c record
     * for a Patient will return a PopupResponseDTO with true values for the booleans that decide whether to show the popup.
     */
    @IsTest
    static void funcGetPopupFlagsPositive() {
        Account testAccount = (Account) VATEST_SObjectFactory.createSObject(
            new Account(FirstName = 'Test', LastName = 'Patient', RecordTypeId = PERSON_RECORD_TYPE_ID),
            true
        );
        User rnUser = getTestUser(RN_PSG_NAME);
        insert new AccountShare(
            AccountId = testAccount.Id,
            UserOrGroupId = rnUser.Id,
            AccountAccessLevel = 'Edit',
            OpportunityAccessLevel = 'Edit'
        );
        System.runAs(rnUser) {
            Test.startTest();
            VCC_AccountPopupController.PopupResponseDTO popupResponse = VCC_AccountPopupController.getPopupFlags(
                testAccount.Id
            );
            Test.stopTest();
            Assert.isTrue(
                popupResponse.isShowSensitivePatientPopup,
                'Expected popupResponse.isShowSensitivePatientPopup to be true, because the Account is new and has not been "viewed" before'
            );
            Assert.isTrue(
                popupResponse.isShowVerifyPatientPopup,
                'Expected popupResponse.isShowVerifyPatientPopup to be true, because the Account is new and has not been "viewed" before'
            );
            Assert.isTrue(
                popupResponse.isFacilityAccessPopup,
                'Expected popupResponse.isFacilityAccessPopup to be true, because the Account is new and has not been "viewed" before'
            );
            Assert.isTrue(
                popupResponse.isShowOwnPatientRecordPopup,
                'Expected popupResponse.isShowOwnPatientRecordPopup to be true, because the Account is new and has not been "viewed" before'
            );
            Assert.isTrue(
                popupResponse.isShowVerifyPatientAddressPopup,
                'Expected popupResponse.isShowVerifyPatientAddressPopup to be true, because the Account is new and has not been "viewed" before'
            );
        }
    }

    @IsTest
    static void unitComputeVerifyCallerHasBypassPermissionPositive() {
        VCC_AccountPopupController.PopupResponseDTO popupResponseDto = new VCC_AccountPopupController.PopupResponseDTO();
        System.runAs(getTestUser(RN_PSG_NAME)) {
            Test.startTest();
            popupResponseDto.computeVerifyCaller(
                new VCC_Recent_View__c(VCC_Type_Verify_Patient__c = false, VCC_Pharmacy_Verify_Addresses__c = ''),
                true
            );
            Test.stopTest();
        }
        Assert.isFalse(
            popupResponseDto.isShowVerifyPatientPopup,
            'Expected isShowVerifyPatientPopup to be "false" because "true" was passed for "hasBypassPermission"'
        );
        Assert.isFalse(
            popupResponseDto.isShowVerifyPatientAddressPopup,
            'Expected isShowVerifyPatientAddressPopup to be "false" because "true" was passed for "hasBypassPermission"'
        );
        Assert.isTrue(
            popupResponseDto.isBypassVerifyCaller,
            'Expected isBypassVerifyCaller to be "true" because "true" was passed for "hasBypassPermission"'
        );
    }

    @IsTest
    static void unitComputeVerifyCallerNoBypassPermissionPopupAcknowledgedLessThanTenMinutesAgoPositive() {
        VCC_AccountPopupController.PopupResponseDTO popupResponseDto = new VCC_AccountPopupController.PopupResponseDTO();
        System.runAs(getTestUser(RN_PSG_NAME)) {
            Test.startTest();
            popupResponseDto.computeVerifyCaller(
                new VCC_Recent_View__c(
                    VCC_Type_Verify_Patient__c = true,
                    VCC_Pharmacy_Verify_Addresses__c = 'Verified Address',
                    LastModifiedDate = Datetime.now()
                ),
                false
            );
            Test.stopTest();
        }
        Assert.isFalse(
            popupResponseDto.isShowVerifyPatientPopup,
            'Expected isShowVerifyPatientPopup to be "false" because the VCC_Recent_View__c record provided has VCC_Type_Verify_Patient__c as "true" and its LastModifiedDate is less than 10 minutes from now'
        );
        Assert.isFalse(
            popupResponseDto.isShowVerifyPatientAddressPopup,
            'Expected isShowVerifyPatientAddressPopup to be "false" because the VCC_Recent_View__c record provided has VCC_Pharmacy_Verify_Addresses__c as "Verified Address" and its LastModifiedDate is less than 10 minutes from now'
        );
        Assert.isFalse(
            popupResponseDto.isBypassVerifyCaller,
            'Expected isBypassVerifyCaller to be "false" because "false" was passed for "hasBypassPermission"'
        );
    }

    @IsTest
    static void unitComputeVerifyCallerNoBypassPermissionPopupAcknowledgedMoreThanTenMinutesAgoPositive() {
        VCC_AccountPopupController.PopupResponseDTO popupResponseDto = new VCC_AccountPopupController.PopupResponseDTO();
        System.runAs(getTestUser(RN_PSG_NAME)) {
            Test.startTest();
            popupResponseDto.computeVerifyCaller(
                new VCC_Recent_View__c(
                    VCC_Type_Verify_Patient__c = true,
                    VCC_Pharmacy_Verify_Addresses__c = 'Verified Address',
                    LastModifiedDate = Datetime.now().addMinutes(-10).addSeconds(-1)
                ),
                false
            );
            Test.stopTest();
        }
        Assert.isTrue(
            popupResponseDto.isShowVerifyPatientPopup,
            'Expected isShowVerifyPatientPopup to be "true" because the VCC_Recent_View__c record provided has VCC_Type_Verify_Patient__c as "true" and its LastModifiedDate is more than 10 minutes from now'
        );
        Assert.isTrue(
            popupResponseDto.isShowVerifyPatientAddressPopup,
            'Expected isShowVerifyPatientAddressPopup to be "true" because the VCC_Recent_View__c record provided has VCC_Pharmacy_Verify_Addresses__c as "Verified Address" and its LastModifiedDate is more than 10 minutes from now'
        );
        Assert.isFalse(
            popupResponseDto.isBypassVerifyCaller,
            'Expected isBypassVerifyCaller to be "false" because "false" was passed for "hasBypassPermission"'
        );
    }

    /**
     * @description funcGetPopupFlagsPositiveWithBypass confirms that a user that has the VCC_Bypass_Caller_Verification custom permission
     * will return a PopupResponseDTO with false as the value for isShowVerifyPatientPopup.
     */
    @IsTest
    static void funcGetPopupFlagsPositiveWithBypass() {
        Account testAccount = (Account) VATEST_SObjectFactory.createSObject(
            new Account(FirstName = 'Test', LastName = 'Patient', RecordTypeId = PERSON_RECORD_TYPE_ID),
            true
        );
        //MP Users have the VCC_Bypass_Caller_Verification custom permission
        User mpUser = getTestUser(MP_PSG_NAME);
        insert new AccountShare(
            AccountId = testAccount.Id,
            UserOrGroupId = mpUser.Id,
            AccountAccessLevel = 'Edit',
            OpportunityAccessLevel = 'Edit'
        );
        System.runAs(mpUser) {
            Test.startTest();
            VCC_AccountPopupController.PopupResponseDTO popupResponse = VCC_AccountPopupController.getPopupFlags(
                testAccount.Id
            );
            Test.stopTest();
            Assert.isTrue(
                popupResponse.isShowSensitivePatientPopup,
                'Expected popupResponse.isShowSensitivePatientPopup to be true, because the Account is new and has not been "viewed" before'
            );
            Assert.isFalse(
                popupResponse.isShowVerifyPatientPopup,
                'Expected popupResponse.isShowVerifyPatientPopup to be false because the running user has the "Bypass" permission'
            );
            Assert.isFalse(
                popupResponse.isShowVerifyPatientAddressPopup,
                'Expected popupResponse.isShowVerifyPatientAddressPopup to be false because the running user has the "Bypass" permission'
            );
            Assert.isTrue(
                popupResponse.isFacilityAccessPopup,
                'Expected popupResponse.isFacilityAccessPopup to be true, because the Account is new and has not been "viewed" before'
            );
            Assert.isTrue(
                popupResponse.isShowOwnPatientRecordPopup,
                'Expected popupResponse.isShowOwnPatientRecordPopup to be true, because the Account is new and has not been "viewed" before'
            );
        }
    }

    @IsTest
    static void funcHandleGetPopupFlagsExceptionDmlExceptionPositive() {
        Exception exceptionToHandle = new DmlException('some dml exception');
        String logTransactionId;
        Boolean isErrorLoggingEnabled;
        System.runAs(getTestUser(RN_PSG_NAME)) {
            Test.startTest();
            Logger.flushBuffer();
            logTransactionId = Logger.getTransactionId();
            isErrorLoggingEnabled = Logger.isErrorEnabled();
            try {
                VCC_AccountPopupController.handleGetPopupFlagsException(exceptionToHandle);
                Assert.fail(
                    'Expected an AuraHandledException to be thrown because one should always' +
                    ' be thrown in the "finally" block of handleGetPopupFlagsException'
                );
            } catch (AuraHandledException resultingException) {
                Assert.areEqual(
                    exceptionToHandle.getMessage(),
                    resultingException.getMessage(),
                    'Expected the resulting exception message from' +
                    ' handleGetPopupFlagsException to match the message of the exception being handled'
                );
            }
            Test.stopTest();
        }
        assertLogWasCreated(logTransactionId, isErrorLoggingEnabled);
    }

    @IsTest
    static void funcHandleGetPopupFlagsExceptionQueryExceptionPositive() {
        Exception exceptionToHandle = new QueryException('some query exception');
        String logTransactionId;
        Boolean isErrorLoggingEnabled;
        System.runAs(getTestUser(RN_PSG_NAME)) {
            Test.startTest();
            Logger.flushBuffer();
            logTransactionId = Logger.getTransactionId();
            isErrorLoggingEnabled = Logger.isErrorEnabled();
            try {
                VCC_AccountPopupController.handleGetPopupFlagsException(exceptionToHandle);
                Assert.fail(
                    'Expected an AuraHandledException to be thrown because one should always' +
                    ' be thrown in the "finally" block of handleGetPopupFlagsException'
                );
            } catch (AuraHandledException resultingException) {
                Assert.areEqual(
                    exceptionToHandle.getMessage(),
                    resultingException.getMessage(),
                    'Expected the resulting exception message from' +
                    ' handleGetPopupFlagsException to match the message of the exception being handled'
                );
            }
            Test.stopTest();
        }
        assertLogWasCreated(logTransactionId, isErrorLoggingEnabled);
    }

    @IsTest
    static void funcHandleGetPopupFlagsExceptionOtherExceptionPositive() {
        Exception exceptionToHandle = new AuraHandledException('some other exception');
        String logTransactionId;
        Boolean isErrorLoggingEnabled;
        System.runAs(getTestUser(RN_PSG_NAME)) {
            Test.startTest();
            Logger.flushBuffer();
            logTransactionId = Logger.getTransactionId();
            isErrorLoggingEnabled = Logger.isErrorEnabled();
            try {
                VCC_AccountPopupController.handleGetPopupFlagsException(exceptionToHandle);
                Assert.fail(
                    'Expected an AuraHandledException to be thrown because one should always' +
                    ' be thrown in the "finally" block of handleGetPopupFlagsException'
                );
            } catch (AuraHandledException resultingException) {
                Assert.areEqual(
                    exceptionToHandle.getMessage(),
                    resultingException.getMessage(),
                    'Expected the resulting exception message from' +
                    ' handleGetPopupFlagsException to match the message of the exception being handled'
                );
            }
            Test.stopTest();
        }
        assertLogWasCreated(logTransactionId, isErrorLoggingEnabled);
    }

    private static void assertLogWasCreated(String logTransactionId, Boolean isErrorLoggingEnabled) {
        System.runAs(getTestUser(LOG_VIEWER_PERM_SET_NAME)) {
            if (!isErrorLoggingEnabled) {
                return;
            }
            Logger__c log = Logger.getLog(logTransactionId);
            Assert.isNotNull(
                log,
                'Expected a log to have been created by handleGetPopupFlagsException via' +
                ' Logger.saveLog() in the "finally" block, but instead found null'
            );
            Assert.areEqual(
                1,
                log.TotalERRORLogEntries__c,
                'Expected one ERROR log entry to have been created from handleGetPopupFlagsException'
            );
        }
    }
}
