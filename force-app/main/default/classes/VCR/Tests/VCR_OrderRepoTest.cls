/**
 * @description Tests the VCR_OrderRepoTest class
 * @author Booz Allen Hamilton
 *
 * @see VCR_OrderRepo for class being tested
 */
@IsTest
public with sharing class VCR_OrderRepoTest {
    /**
     * @description functional test method to ensure initialization was successful
     */
    @IsTest
    private static void funcEnsureCorrectDefaultInitialization() {
        User adminUser = new VATEST_UserBuilder()
            .withUserProfile('System Administrator')
            .withStandardData()
            .build(true);
        System.runAs(adminUser) {
            Test.startTest();
            Assert.isNotNull(VCR_OrderRepo.patientService, 'Expected patientService to be initialized.');
            Test.stopTest();
        }
    }

    /**
     * @description unit test checking that data is returned with mock data
     */
    @IsTest
    private static void unitGetOrdersReturnsValidDataWhenMockedPositive() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCR_OrderRepo.patientService = mockPatientServiceStub(args, new VTC_DataModel(), 'get_orders');
        User vaVetUser = new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);

        System.runAs(vaVetUser) {
            Test.startTest();
            //args is the arguments to pass to the provider, in this case the fake ICN
            VTC_DataModel ordersDataModel = new VCR_OrderRepo().fetchOrders(args);
            Assert.isNotNull(ordersDataModel, 'Expected valid non-null model to be returned.');
            Test.stopTest();
        }
    }

    /**
     * @description unit test checking that data is returned with mock data
     */
    @IsTest
    private static void unitGetOrdersWithPharmReturnsValidDataWhenMockedPositive() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCR_OrderRepo.patientService = mockPatientServiceStub(args, new VTC_DataModel(), 'get_orders_with_pharmacy');
        User vaVetUser = new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);

        System.runAs(vaVetUser) {
            Test.startTest();
            //args is the arguments to pass to the provider, in this case the fake ICN
            VTC_DataModel ordersDataModel = new VCR_OrderRepo().fetchOrdersWithPharmacy(args);
            Assert.isNotNull(ordersDataModel, 'Expected valid non-null model to be returned.');
            Test.stopTest();
        }
    }

    /**
     * @description method to build VTC_PatientService stub
     * @param args The arguments to pass to the provider
     * @param returnValue the object to be returned
     * @param methodCallName the method to call
     * @return `VTC_PatientService`
     */
    private static VTC_PatientService mockPatientServiceStub(
        Map<String, Object> args,
        Object returnValue,
        String methodCallName
    ) {
        return (VTC_PatientService) new VATEST_StubBuilder(VTC_PatientService.class)
            .mockingMethodCall('call')
            .withParameterTypes(String.class, Map<String, Object>.class)
            .withParameterValues(methodCallName, args)
            .returning(returnValue)
            .defineStub();
    }
}
