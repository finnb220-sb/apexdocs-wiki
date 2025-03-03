/**
 * @description Test class for VCC_bsContingency
 * @see VCC_bsContingency
 */
@isTest
public class VCC_bsContingencyTest {
    private final static String USERNAMEPREFIX = 'VCC_bsContingencyTest';
    private final static String DIVISION = 'VISN 99';
    /**
     * @description TestSetup for VCC_bsContingencyTest. Creates a Sys Admin Test User and two Bucher+Suter servers (VA Health Connect's telephony solution)
     * then assigns the running user to the first server. The following tests will ensure that the user can be switched from being assigned to either server.
     */
    @TestSetup
    static void testBSDataSetup() {
        // Create Test User
        String uniqueUserName = USERNAMEPREFIX + Datetime.now().getTime() + '@VAHC.com';
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User runningUser = new User(
            Alias = 'standt',
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = standardProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = uniqueUserName
        );
        insert runningUser;
        // Create Test Production Servers
        cnx__Connects_Configuration__c configServer1 = new cnx__Connects_Configuration__c(Name = 'Test Config Server1');
        cnx__Connects_Configuration__c configServer2 = new cnx__Connects_Configuration__c(Name = 'Test Config Server2');

        insert configServer1;
        insert configServer2;

        // Create b+s Assigned User
        cnx__Connects_Configuration_Assignment__c bsAssignedUser = new cnx__Connects_Configuration_Assignment__c();
        bsAssignedUser.cnx__Assigned_User__c = runningUser.Id;
        bsAssignedUser.cnx__Assigned_Connects_Configuration__c = configServer1.Id;
        insert bsAssignedUser;
    }
    /**
     * @description Method to get the running user for the test
     * @return      `User`
     */
    public static User getTestUser() {
        return [SELECT Id, Division FROM User WHERE Username LIKE :USERNAMEPREFIX + '%' LIMIT 1];
    }
    /**
     * @description Test method that ensures that the running user can be switched from one server to the other based on their assignment to the old server Id
     */
    @isTest
    static void testBucherSuterServerBasedOnOldProdServer() {
        User runningUser = getTestUser();
        // Create an instance of the VCC_bsContingency.Inputs class
        VCC_bsContingency.Inputs inputs = new VCC_bsContingency.Inputs();
        inputs.prodServerId = [SELECT Id FROM cnx__Connects_Configuration__c WHERE Name = 'Test Config Server1'].Id;
        inputs.newProdServerId = [SELECT Id FROM cnx__Connects_Configuration__c WHERE Name = 'Test Config Server2'].Id;

        // Add the inputs to Lists
        List<VCC_bsContingency.Inputs> inputLst = new List<VCC_bsContingency.Inputs>();
        inputLst.add(inputs);

        System.runAs(runningUser) {
            // Call the bucherSuterServerMove method
            Test.startTest();
            VCC_bsContingency.bucherSuterServerMove(inputLst);
            Test.stopTest();
        }

        // Verify the B+S Assigned User record was created, has the Test User's Id, and New Production Server Id
        cnx__Connects_Configuration_Assignment__c bsUser = [
            SELECT Id, cnx__Assigned_User__c, cnx__Assigned_Connects_Configuration__c
            FROM cnx__Connects_Configuration_Assignment__c
            WHERE cnx__Assigned_Connects_Configuration__c = :inputs.newprodServerId
            LIMIT 1
        ];
        Assert.areEqual(runningUser.Id, bsUser?.cnx__Assigned_User__c, 'Assertion failed; Expected a reference to the running user');
        Assert.areEqual(inputs.newProdServerId, bsUser?.cnx__Assigned_Connects_Configuration__c, 'Assertion failed; Expected the id of the New Prod Server Id passed as input');
    }
    /**
     * @description Test Method that ensures that the user can be switched back to the original server. Processes the change based on the Division field on the user by including Division in the Inputs
     */
    @isTest
    static void testBucherSuterServerBasedOnDivision() {
        User runningUser = getTestUser();
        runningUser.Division = DIVISION;
        update runningUser;
        // Create an instance of the VCC_bsContingency.Inputs class
        VCC_bsContingency.Inputs inputs = new VCC_bsContingency.Inputs();
        inputs.prodServerId = [SELECT Id FROM cnx__Connects_Configuration__c WHERE Name = 'Test Config Server1'].Id;
        inputs.newProdServerId = [SELECT Id FROM cnx__Connects_Configuration__c WHERE Name = 'Test Config Server2'].Id;
        inputs.division = runningUser.Division;

        // Add the inputs to Method Input List
        List<VCC_bsContingency.Inputs> inputLst = new List<VCC_bsContingency.Inputs>();
        inputLst.add(inputs);

        System.runAs(runningUser) {
            // Call the bucherSuterServerMove method
            Test.startTest();
            VCC_bsContingency.bucherSuterServerMove(inputLst);
            Test.stopTest();
        }

        // Verify the B+S Assigned User record was created, has the Test User's Id, and New Production Server Id
        cnx__Connects_Configuration_Assignment__c bsUser = [
            SELECT Id, cnx__Assigned_User__c, cnx__Assigned_Connects_Configuration__c
            FROM cnx__Connects_Configuration_Assignment__c
            WHERE cnx__Assigned_Connects_Configuration__c = :inputs.newprodServerId
            LIMIT 1
        ];
        Assert.areEqual(runningUser.Id, bsUser?.cnx__Assigned_User__c, 'Assertion failed; Expected a reference to the running user');
        Assert.areEqual(inputs.newProdServerId, bsUser?.cnx__Assigned_Connects_Configuration__c, 'Assertion failed; Expected the id of the New Prod Server Id passed as input');
    }
    /**
     * @description Test Method that ensures that an exception is thrown when a server Id is excluded.
     */
    @isTest
    static void testBucherSuterServerException() {
        User runningUser = getTestUser();
        // Create an instance of the VCC_bsContingency.Inputs class
        VCC_bsContingency.Inputs inputs = new VCC_bsContingency.Inputs();
        inputs.prodServerId = [SELECT Id FROM cnx__Connects_Configuration__c WHERE Name = 'Test Config Server1'].Id;
        inputs.newProdServerId = null;
        inputs.division = runningUser.Division;

        // Add the inputs to Method Input List
        List<VCC_bsContingency.Inputs> inputLst = new List<VCC_bsContingency.Inputs>();
        inputLst.add(inputs);

        System.runAs(runningUser) {
            // Call the bucherSuterServerMove method
            Test.startTest();
            try {
                VCC_bsContingency.bucherSuterServerMove(inputLst);
            } catch (IllegalArgumentException argEx) {
                Assert.areEqual(
                    'Required inputs for server Id\'s are missing.',
                    argEx.getMessage(),
                    'Assertion failed; Expected an exception message that reads: \'Required inputs for server Id\'s are missing.\''
                );
            }
            Test.stopTest();
        }
    }
}
