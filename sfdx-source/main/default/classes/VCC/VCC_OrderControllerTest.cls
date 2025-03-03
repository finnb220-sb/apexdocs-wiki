/**
 * @description Test class for VCC_OrderController
 * @author Booz Allen
 *
 * @see VCC_OrderController
 */
@isTest
private with sharing class VCC_OrderControllerTest {
    @IsTest
    /**
     * @description functional test method to ensure initialization was successful
     */
    private static void funcEnsureCorrectDefaultInitialization() {
        User vaVetUser = createTestUser();
        System.runAs(vaVetUser) {
            Test.startTest();
            VCC_OrderController orderController = new VCC_OrderController();
            Test.stopTest();
            Assert.isNotNull(orderController, 'Expected class to be initialized.');
            Assert.isNotNull(VCC_OrderController.orderRepo, 'Expected order Repo to be initialized.');
            Assert.isNotNull(VCC_OrderController.healthDataRepo, 'Expected order Repo to be initialized.');
        }
    }

    @IsTest
    /**
     * @description unit test to get order from fetch and transform the vtc order to vcc order type positive
     */
    private static void unitGetOrderPositive() {
        User vaVetUser = createTestUser();
        Map<String, Object> args = new Map<String, Object>{
            'icn' => 'fakeICN',
            'max' => 200,
            'startDate' => '2022-01-01',
            'endDate' => '2023-01-01',
            'application' => 'VAHC'
        };

        //Creating test data
        VTC_Provider testProvider = new VTC_Provider();
        testProvider.name = 'test';

        VTC_Order order = new VTC_Order();
        order.provider = testProvider;
        order.start = Datetime.now();
        order.signed = Datetime.now();
        order.released = Datetime.now();

        VTC_Site testSite = new VTC_Site();
        testSite.records.add(order);

        VTC_DataModel dataModel = new VTC_DataModel();
        dataModel.sites = new List<VTC_Site>{ testSite };

        VCC_OrderController.healthDataRepo = createHealthDataRepo('orders');
        VCC_OrderController.orderRepo = createOrderRepo(args, dataModel);
        System.runAs(vaVetUser) {
            Test.startTest();
            VTC_DataModel model = VCC_OrderController.getOrders(args);
            Assert.isNotNull(model, 'Expected model to be returned');
            Assert.isNotNull(
                model.sites.get(0).records[0] instanceof VCC_OrderController.VCC_Order,
                'Expected record to be instance of custom VCC_Order'
            );
            VCC_OrderController.VCC_Order orderData = (VCC_OrderController.VCC_Order) model.sites.get(0).records[0];
            Assert.isNotNull(orderData.providerName, 'Expected record to have provider name');
            Assert.isNotNull(orderData.releasedDateFormatted, 'Expected record to have releasedDateFormatted');
            Assert.isNotNull(orderData.startDateStr, 'Expected record to have provider startDateStr');
            Assert.isNotNull(orderData.signedDateStr, 'Expected record to have provider signedDateStr');
            Assert.isNotNull(orderData.startDateFormatted, 'Expected record to have provider startDateFormatted');
            Assert.isNotNull(orderData.signedDateFormatted, 'Expected record to have provider signedDateFormatted');

            Test.stopTest();
        }
    }

    @IsTest
    /**
     * @description unit test to get health data
     */
    private static void unitGetHealthDataPositive() {
        VCC_OrderController.healthDataRepo = createHealthDataRepo('orders');
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VCR_HealthDataRepo.Model healthDataConfig = (VCR_HealthDataRepo.Model) VCC_OrderController.fetchHealthDataConfig(
                'fakeICN'
            );
            Assert.isTrue(healthDataConfig != null, 'Expected valid non-null model to be returned.');
        }
        Test.stopTest();
    }

    @IsTest
    /**
     * @description unit test to catch VTC Internal Exception and expect a no retry command
     */
    private static void unitFetchOrderVTCExceptionNoRetry() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCC_OrderController.healthDataRepo = createHealthDataRepo('orders');
        VCC_OrderController.orderRepo = createOrderRepoException(args, new VTC_InternalException());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            try {
                VCC_OrderController.fetchOrders(args);
                Assert.fail('Expected exception to be thrown.');
            } catch (AuraHandledException caughtException) {
                Assert.areEqual(
                    caughtException.getMessage(),
                    VCC_OrderController.NO_RETRY_CMD,
                    'Expected a NO_RETRY_CMD to be a part of exception thrown but got back ' +
                    caughtException.getMessage()
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    /**
     * @description unit test to catch VTC Limit Exception and expect a retry command
     */
    private static void unitFetchOrderVTCExceptionRetry() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCC_OrderController.healthDataRepo = createHealthDataRepo('orders');
        VCC_OrderController.orderRepo = createOrderRepoException(args, new VTC_LimitException());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            try {
                VCC_OrderController.fetchOrders(args);
                Assert.fail('Expected exception to be thrown.');
            } catch (AuraHandledException caughtException) {
                Assert.areEqual(
                    caughtException.getMessage(),
                    VCC_OrderController.RETRY_CMD,
                    'Expected a RETRY_CMD to be a part of exception thrown but got back ' + caughtException.getMessage()
                );
            }
        }
        Test.stopTest();
    }

    /**
     * @description method to build VCR_OrderRepo stub mocking fetchOrder
     * @param args The arguments to pass to the provider
     * @param returnValue the object to be returned
     * @return `VCR_OrderRepo`
     */
    private static VCR_OrderRepo createOrderRepo(Map<String, Object> args, Object returnValue) {
        return (VCR_OrderRepo) new VATEST_StubBuilder(VCR_OrderRepo.class)
            .mockingMethodCall('fetchOrdersWithPharmacy')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .returning(returnValue)
            .defineStub();
    }

    private static VCR_HealthDataRepo createHealthDataRepo(String healthDataType) {
        VCC_WorkstreamSettingsController.VCC_Model workstreamSettingsModel = new VCC_WorkstreamSettingsController.VCC_Model(
            'orders',
            Datetime.now(),
            Datetime.now(),
            12,
            10
        );

        Account patientAccount = new Account(Date_of_Birth__pc = '4/20/1999');
        VCR_HealthDataRepo.Model healthDataRepoModel = new VCR_HealthDataRepo.Model()
            .setAccountDOB(patientAccount)
            .setWorkstreamSettings(workstreamSettingsModel);

        return (VCR_HealthDataRepo) new VATEST_StubBuilder(VCR_HealthDataRepo.class)
            .mockingMethodCall('fetchHealthDataConfig')
            .withParameterTypes()
            .returning(healthDataRepoModel)
            .mockingMethodCall('setPatientByICN')
            .withParameterTypes(String.class)
            .withParameterValues('fakeICN')
            .returning()
            .defineStub();
    }

    /**
     * @description method to build VCR_OrderRepo stub
     * @param args The arguments to pass to the provider
     * @param returnException the exception to be returned
     * @return `VCR_OrderRepo`
     */
    private static VCR_OrderRepo createOrderRepoException(Map<String, Object> args, Exception returnException) {
        return (VCR_OrderRepo) new VATEST_StubBuilder(VCR_OrderRepo.class)
            .mockingMethodCall('fetchOrdersWithPharmacy')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .throwingException(returnException)
            .defineStub();
    }

    /**
     * @description method to create a test user
     * @return `User` returns a user to be used for testing
     */
    private static User createTestUser() {
        return new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
    }
}
