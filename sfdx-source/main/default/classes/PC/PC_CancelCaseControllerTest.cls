/**
 * @description Test class for PC_PC_CancelCaseController.
 * @author      Booz Allen
 * @see         PC_CancelCaseController
 **/
@isTest
private with sharing class PC_CancelCaseControllerTest {
    private final static User FLP_USER;
    private final static User SPECIALIST_USER;
    static {
        //mixed DML error workaround
        System.runAs(new User(Id = UserInfo.getUserId())) {
            FLP_USER = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .withPermissionSet('PrC_FLP_Users')
                .build(true);
            SPECIALIST_USER = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .withPermissionSet('PrC_Specialist_Users')
                .build(true);
        }
    }

    /**
     * @description positive test of cancelCase to ensure a PC Case's status successfully changes to Cancelled
     */
    @IsTest
    static void unitCancelCasePositive() {
        //Set routing to default skill-based routing from the utility class
        PC_PrcConfigSettingsUtility.ndthRoutingEnabled = false;
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;
        PC_PrcCaseRepo realCaseRepo = new PC_PrcCaseRepo();

        User provider = FLP_USER;

        PC_Case__c testCase = (PC_Case__c) VATEST_SObjectFactory.createSObject(
            new PC_Case__c(
                RecordTypeId = realCaseRepo.recordTypeConstant.fromDeveloperName('Provider_Connect_Case').Id,
                Case_Details__c = 'Test Details',
                Subject__c = 'Chat - Test PC Provider',
                Specialty__c = 'Cardiac Surgery',
                Status__c = 'Open',
                Channel__c = 'Chat',
                Callback_Number__c = null,
                Patient_Account__c = null,
                isRunningTest_DO_NOT_USE__c = true
            )
        );

        PC_Case__c clonedCase = testCase.clone(true, true, true, true);
        clonedCase.Status__c = 'Cancelled';

        PC_PrcCaseRepo mockedCaseRepo = (PC_PrcCaseRepo) new VATEST_StubBuilder(PC_PrcCaseRepo.class)
            .mockingMethodCall('fetchById')
            .withParameterTypes(Id.class, Set<String>.class)
            .withParameterValues(testCase.Id, new Set<String>{ 'Closed__c' })
            .returning(testCase)
            .mockingMethodCall('doUpdate')
            .withParameterTypes(SObject.class)
            .withParameterValues(clonedCase)
            .returning()
            .defineStub();

        PC_CancelCaseController.prcCaseRepo = mockedCaseRepo;

        System.runAs(provider) {
            Test.startTest();

            PC_Case__c closedCase = PC_CancelCaseController.cancelCase(testCase.Id);

            Test.stopTest();

            Assert.areEqual('Cancelled', closedCase.Status__c, 'Expected the PC Case to be Cancelled.');
        }
    }

    /**
     * @description negative test of cancelCase to ensure a PC Custom Exception is thrown with a blank input
     */
    @IsTest
    static void unitCancelCaseBlankInputNegative() {
        //Set routing to default skill-based routing from the utility class
        PC_PrcConfigSettingsUtility.ndthRoutingEnabled = false;
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;

        User provider = FLP_USER;

        String expectedExceptionMessage = PC_CancelCaseController.CASE_ID_BLANK_ERROR_MESSAGE;

        Test.startTest();

        String caughtMessage;
        System.runAs(provider) {
            try {
                PC_CancelCaseController.cancelCase(null);
            } catch (PC_CustomException caughtException) {
                caughtMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        Assert.areEqual(
            expectedExceptionMessage,
            caughtMessage,
            'Expected a custom exception to be thrown when the provided caseId is blank.'
        );
    }

    /**
     * @description negative test of cancelCase to ensure an exception is thrown indicating the case is already closed
     */
    @IsTest
    static void unitCancelCaseAlreadyClosedNegative() {
        //Set routing to default skill-based routing from the utility class
        PC_PrcConfigSettingsUtility.ndthRoutingEnabled = false;
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;

        User provider = SPECIALIST_USER;

        // We cannot use the Object Factory because we need to set a value on the closed field which is not writeable, using JSON.serialize.
        Id caseId = VATEST_IdFactory.get(Type.forName('PC_Case__c'));
        Map<String, Object> toForceCaseToPcCase = new Map<String, Object>();
        toForceCaseToPcCase.put('Closed__c', true);
        String intermediate = JSON.serialize(toForceCaseToPcCase);
        PC_Case__c testCase = (PC_Case__c) JSON.deserialize(intermediate, PC_Case__c.class);
        testCase.Id = caseId;

        PC_PrcCaseRepo mockedCaseRepo = (PC_PrcCaseRepo) new VATEST_StubBuilder(PC_PrcCaseRepo.class)
            .mockingMethodCall('fetchById')
            .withParameterTypes(Id.class, Set<String>.class)
            .withParameterValues(caseId, new Set<String>{ 'Closed__c' })
            .returning(testCase)
            .defineStub();

        PC_CancelCaseController.prcCaseRepo = mockedCaseRepo;

        String expectedExceptionMessage = 'This case is already closed. Please refresh the page.';

        Test.startTest();

        String caughtMessage;
        System.runAs(provider) {
            try {
                PC_CancelCaseController.cancelCase(caseId);
            } catch (AuraHandledException caughtException) {
                caughtMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        Assert.areEqual(
            expectedExceptionMessage,
            caughtMessage,
            'Expected an exception to be thrown by cancelCase indicating that it is already closed.'
        );
    }

    /**
     * @description negative test of cancelCase to ensure a DML exception is thrown
     */
    @IsTest
    static void unitCancelCaseDmlExceptionNegative() {
        //Set routing to default skill-based routing from the utility class
        PC_PrcConfigSettingsUtility.ndthRoutingEnabled = false;
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;

        User provider = SPECIALIST_USER;

        String expectedExceptionMessage = 'DML Exception Message.';
        // We cannot use the Object Factory because we need to set a value on the closed field which is not writeable, using JSON.serialize.
        Id caseId = VATEST_IdFactory.get(Type.forName('PC_Case__c'));
        Map<String, Object> toForceCaseToPcCase = new Map<String, Object>();
        toForceCaseToPcCase.put('Closed__c', false);
        String intermediate = JSON.serialize(toForceCaseToPcCase);
        PC_Case__c testCase = (PC_Case__c) JSON.deserialize(intermediate, PC_Case__c.class);
        testCase.Id = caseId;

        PC_Case__c clonedCase = testCase.clone(true, true, true, true);
        clonedCase.Status__c = 'Cancelled';

        PC_PrcCaseRepo mockedCaseRepo = (PC_PrcCaseRepo) new VATEST_StubBuilder(PC_PrcCaseRepo.class)
            .mockingMethodCall('fetchById')
            .withParameterTypes(Id.class, Set<String>.class)
            .withParameterValues(caseId, new Set<String>{ 'Closed__c' })
            .returning(testCase)
            .mockingMethodCall('doUpdate', SObject.class)
            .withParameterValues(clonedCase)
            .throwingException(new DmlException(expectedExceptionMessage))
            .defineStub();

        PC_CancelCaseController.prcCaseRepo = mockedCaseRepo;

        Test.startTest();

        String caughtMessage;
        System.runAs(provider) {
            try {
                PC_CancelCaseController.cancelCase(caseId);
            } catch (AuraHandledException caughtException) {
                caughtMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        Assert.areEqual(
            expectedExceptionMessage,
            caughtMessage,
            'Expected a DML exception to be thrown by cancelCase.'
        );
    }

    /**
     * @description negative test of cancelCase to ensure a Query exception is thrown
     */
    @IsTest
    static void unitCancelCaseQueryExceptionNegative() {
        //Set routing to default skill-based routing from the utility class
        PC_PrcConfigSettingsUtility.ndthRoutingEnabled = false;
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;

        User provider = SPECIALIST_USER;

        Id caseId = VATEST_IdFactory.get(Type.forName('PC_Case__c'));

        String expectedExceptionMessage = 'Query Exception Message.';

        PC_PrcCaseRepo mockedCaseRepo = (PC_PrcCaseRepo) new VATEST_StubBuilder(PC_PrcCaseRepo.class)
            .mockingMethodCall('fetchById')
            .withParameterTypes(Id.class, Set<String>.class)
            .withParameterValues(caseId, new Set<String>{ 'Closed__c' })
            .throwingException(new QueryException(expectedExceptionMessage))
            .defineStub();

        PC_CancelCaseController.prcCaseRepo = mockedCaseRepo;

        Test.startTest();

        String caughtMessage;
        System.runAs(provider) {
            try {
                PC_CancelCaseController.cancelCase(caseId);
            } catch (AuraHandledException caughtException) {
                caughtMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        Assert.areEqual(
            expectedExceptionMessage,
            caughtMessage,
            'Expected a Query exception to be thrown by cancelCase.'
        );
    }
}
