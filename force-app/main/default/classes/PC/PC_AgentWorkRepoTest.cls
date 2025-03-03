/**
 * @description Test class for PC_AgentWorkRepo.
 * @author      Booz Allen
 * @since       2024
 * @see         PC_AgentWorkRepo
 * @see         VCR_AgentWorkRepo
 */
@IsTest
private with sharing class PC_AgentWorkRepoTest {
    private final static User FLP_USER;
    static {
        //mixed DML error workaround
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            FLP_USER = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .withPermissionSet('PrC_FLP_Users')
                .build(true);
        }
    }

    /**
     * @description positive test of getAgentWorkCapacity to ensure that the result wrapper list returns instantiated (since AgentWork records cannot be inserted in a test class)
     */
    @IsTest
    static void funcGetAgentWorkCapacityTestPositive() {
        // Test data setup
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;
        PC_AgentWorkRepo testRepo = new PC_AgentWorkRepo();

        List<PC_AgentWorkRepo.AgentWorkCapacityWrapper> results;

        // Actual test
        Test.startTest();

        System.runAs(FLP_USER) {
            results = testRepo.getAgentWorkCapacity();
        }

        Test.stopTest();

        // Asserts
        //NOTE: cannot insert AgentWork in test class so impossible to directly test query result
        Assert.isNotNull(results, 'Agent Work Capacity for agents not retrieved successfully.');
    }

    /**
     * @description positive test of getAgentWorkCapacityWithDivision to ensure that the result wrapper list returns instantiated (since AgentWork records cannot be inserted in a test class)
     */
    @IsTest
    static void funcGetAgentWorkCapacityWithDivisionTestPositive() {
        // Test data setup
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = true;
        PC_AgentWorkRepo testRepo = new PC_AgentWorkRepo();

        List<PC_AgentWorkRepo.AgentWorkCapacityWrapper> results;

        // Actual test
        Test.startTest();

        System.runAs(FLP_USER) {
            results = testRepo.getAgentWorkCapacity('VISN 1');
        }

        Test.stopTest();

        // Asserts
        //NOTE: cannot insert AgentWork in test class so impossible to directly test query result
        Assert.isNotNull(results, 'Agent Work Capacity for VISN 1 agents not retrieved successfully.');
    }

    /**
     * @description positive test of the AgentWorkCapacityWrapper constructor to ensure the properties populate correctly
     */
    @IsTest
    static void unitAgentWorkCapacityConstructorTest() {
        // Test data setup
        Id testUserId = VATEST_IdFactory.get(Type.forName('User'));

        PC_AgentWorkRepo.AgentWorkCapacityWrapper agentWorkCapacity;

        // Actual test
        Test.startTest();

        System.runAs(FLP_USER) {
            agentWorkCapacity = new PC_AgentWorkRepo.AgentWorkCapacityWrapper(testUserId, 20.0);
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(
            agentWorkCapacity.userId == testUserId && agentWorkCapacity.totalCapacity == 20.0,
            'Agent Work Capacity object not created successfully.'
        );
    }

    /**
     * @description positive test of getAgentWorkByCaseId to ensure the query does not throw an error (since AgentWork records cannot be inserted in a test class)
     */
    @IsTest
    static void funcGetAgentWorkByCaseIdTestPositive() {
        // Test data setup
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;
        PC_AgentWorkRepo testRepo = new PC_AgentWorkRepo();

        // Actual test
        Test.startTest();

        AgentWork result;
        System.runAs(FLP_USER) {
            result = testRepo.getAgentWorkByCaseId(VATEST_IdFactory.get(Type.forName('PC_Case__c')));
        }

        Test.stopTest();

        // Asserts
        //NOTE: cannot insert AgentWork in test class so impossible to directly test query result
        Assert.isNull(result, 'Agent Work by case Id query not executed successfully.');
    }
}
