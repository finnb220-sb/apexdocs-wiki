/**
 * @description test class for PC_SpecialistOmniStatusController
 * @author      Booz Allen Hamilton
 * @see         PC_SpecialistOmniStatusController
 */
@IsTest
private with sharing class PC_SpecialistOmniStatusControllerTest {
    private final static String PC_AVAILABLE_STATUS = 'PC_Available_Provider_Connect';
    private final static User SPECIALIST_USER;
    static {
        //mixed DML error workaround
        System.runAs(new User(Id = UserInfo.getUserId())) {
            SPECIALIST_USER = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .withPermissionSet('PrC_Specialist_Users')
                .build(true);
        }
    }

    /**
     * @description positive test of getPcServicePresenceStatusId
     */
    @IsTest
    static void unitGetPcServicePresenceStatusIdPositive() {
        Id servicePresenceStatusId = VATEST_IdFactory.get(Type.forName('ServicePresenceStatus'));

        VCR_ServicePresenceStatusRepo mockServicePresenceStatusRepo = (VCR_ServicePresenceStatusRepo) new VATEST_StubBuilder(
                VCR_ServicePresenceStatusRepo.class
            )
            .mockingMethodCall('fetchByDeveloperName', String.class)
            .withParameterValues(PC_AVAILABLE_STATUS)
            .returning(new ServicePresenceStatus(Id = servicePresenceStatusId, DeveloperName = PC_AVAILABLE_STATUS))
            .defineStub();

        PC_SpecialistOmniStatusController.servicePresenceStatusRepo = mockServicePresenceStatusRepo;

        Test.startTest();

        String result;
        System.runAs(SPECIALIST_USER) {
            result = PC_SpecialistOmniStatusController.getPcServicePresenceStatusId();
        }

        Test.stopTest();

        Assert.areEqual(
            servicePresenceStatusId.to15(),
            result,
            'Expected the service presence status Ids to be equal, but they were not.'
        );
    }

    /**
     * @description negative test of getPcServicePresenceStatusId
     */
    @IsTest
    static void unitGetPcServicePresenceStatusIdNegative() {
        String expectedExceptionMsg = 'Query Exception Test';

        VCR_ServicePresenceStatusRepo mockServicePresenceStatusRepo = (VCR_ServicePresenceStatusRepo) new VATEST_StubBuilder(
                VCR_ServicePresenceStatusRepo.class
            )
            .mockingMethodCall('fetchByDeveloperName', String.class)
            .withParameterValues(PC_AVAILABLE_STATUS)
            .throwingException(new QueryException(expectedExceptionMsg))
            .defineStub();

        PC_SpecialistOmniStatusController.servicePresenceStatusRepo = mockServicePresenceStatusRepo;

        Test.startTest();

        String caughtExceptionMsg;
        try {
            System.runAs(SPECIALIST_USER) {
                PC_SpecialistOmniStatusController.getPcServicePresenceStatusId();
            }
        } catch (Exception caughtException) {
            caughtExceptionMsg = caughtException.getMessage();
        }

        Test.stopTest();

        Assert.areEqual(
            caughtExceptionMsg,
            expectedExceptionMsg,
            'Expected the getPcServicePresenceStatusId to throw a Query Exception, but it did not.'
        );
    }
}
