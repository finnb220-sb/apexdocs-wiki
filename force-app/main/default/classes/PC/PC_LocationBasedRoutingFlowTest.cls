/**
 * @description Test class for the PC_LocationBasedRoutingFlow class
 * @author      Booze Allen Hamilton
 * @see         PC_LocationBasedRoutingFlow
 */
@IsTest
private with sharing class PC_LocationBasedRoutingFlowTest {
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
     * @description Tests a successful call of the getNearestAvailableSpecialistForFlow invocable method for routing an FLP's PC Case to the best available specialist with the provided skill (specialty)
     */
    @IsTest
    private static void unitGetNearestAvailableSpecialistForFlowPositive() {
        User runAsUser = FLP_USER;

        PC_LocationBasedRoutingFlow.PrcCaseRoutingFlowInput flowInput = new PC_LocationBasedRoutingFlow.PrcCaseRoutingFlowInput();
        flowInput.userid = FLP_USER.Id;
        flowInput.skillName = 'Cardiology';

        PC_LocationBasedRoutingFlow.routingDriver = (PC_LocationBasedRouting) new VATEST_StubBuilder(
                PC_LocationBasedRouting.class
            )
            .mockingMethodCall('getNearestAvailableSpecialist')
            .withParameterTypes(String.class, String.class)
            .withParameterValues(FLP_USER.Id, 'Cardiology')
            .returning(SPECIALIST_USER.Id)
            .defineStub();

        // Actual test
        Test.startTest();

        List<String> results;
        System.runAs(runAsUser) {
            results = PC_LocationBasedRoutingFlow.getNearestAvailableSpecialistForFlow(
                new List<PC_LocationBasedRoutingFlow.PrcCaseRoutingFlowInput>{ flowInput }
            );
        }

        Test.stopTest();

        Assert.areEqual(
            SPECIALIST_USER.Id,
            results[0],
            'Expected getNearestAvailableSpecialistForFlow to return the SPECIALIST_USER.Id, but it did not.'
        );
    }

    /**
     * @description Tests a negative call of the getNearestAvailableSpecialistForFlow invocable method where it throws an exception due to invalid input
     */
    @IsTest
    private static void unitGetNearestAvailableSpecialistForFlowNegative() {
        User runAsUser = FLP_USER;

        PC_LocationBasedRoutingFlow.PrcCaseRoutingFlowInput flowInputNoValues = new PC_LocationBasedRoutingFlow.PrcCaseRoutingFlowInput();

        // Actual test
        Test.startTest();

        String caughtExceptionMessage = '';
        System.runAs(runAsUser) {
            try {
                PC_LocationBasedRoutingFlow.getNearestAvailableSpecialistForFlow(
                    new List<PC_LocationBasedRoutingFlow.PrcCaseRoutingFlowInput>{ flowInputNoValues }
                );
            } catch (Exception caughtException) {
                caughtExceptionMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        Assert.areEqual(
            'Invalid input found for the invocable method, getNearestAvailableSpecialistForFlow',
            caughtExceptionMessage,
            'Expected getNearestAvailableSpecialistForFlow to throw an error due to missing input values, but it did not'
        );
    }
}
