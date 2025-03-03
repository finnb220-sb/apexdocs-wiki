/**
 * @description Unit test to check if the remote action class checks and verifies that a user has a certain permission.
 * @author Booz Allen Hamilton
 * @since 5/2/2024
 * @see VCC_GetUserPermissionRemoteAction
 */
@IsTest
public class VCC_GetUserPermissionRemoteActionTest {
    final static User SCHEDULING_USER;
    final static User NON_SCHEDULING_USER;
    final static String EXTENSION_CLASS = 'VCC_GetUserPermissionRemoteAction';
    static {
        SCHEDULING_USER = new VATEST_UserBuilder()
            .withPermissionSet('VAHC_Scheduling_User')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);

        NON_SCHEDULING_USER = new VATEST_UserBuilder()
            .withPermissionSet('VAHC_Scheduling_Mock_Data_User')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
    }

    /**
     * @description positive unit testing for running user with the desired permission set
     */
    @isTest
    private static void testCallMethodWithSchedulingPermission() {
        System.runAs(SCHEDULING_USER) {
            Test.startTest();
            Callable extension = (Callable) Type.forName(EXTENSION_CLASS).newInstance();

            Map<String, Object> input = new Map<String, Object>{ 'permissionName' => 'VAHC_Scheduling_User' };

            Map<String, Object> output = new Map<String, Object>{ 'booleanPermission' => null };

            Map<String, Object> options = new Map<String, Object>{ 'option1' => true };

            Map<String, Object> args = new Map<String, Object>{
                'input' => input,
                'output' => output,
                'options' => options
            };
            Boolean result = (Boolean) extension.call('getUserPermission', args);
            Boolean hasPermission = (Boolean) output.get('booleanPermission');
            Test.stopTest();
            //checks if the invokeMethod had a Successful execution
            Assert.isTrue(result, 'Returned false instead');
            //Checks if hasPermission is true for scheduling user
            Assert.isTrue(hasPermission, 'Returned false instead');
        }
    }

    /**
     * @description negative unit testing for running user with the desired permission set
     */
    @isTest
    private static void testCallMethodWithNonSchedulingPermission() {
        System.runAs(NON_SCHEDULING_USER) {
            Test.startTest();
            Callable extension = (Callable) Type.forName(EXTENSION_CLASS).newInstance();

            Map<String, Object> input = new Map<String, Object>{ 'permissionName' => 'VAHC_Scheduling_User' };

            Map<String, Object> output = new Map<String, Object>{ 'booleanPermission' => null };

            Map<String, Object> options = new Map<String, Object>{ 'option1' => true };

            Map<String, Object> args = new Map<String, Object>{
                'input' => input,
                'output' => output,
                'options' => options
            };
            Boolean result = (Boolean) extension.call('getUserPermission', args);
            Boolean hasPermission = (Boolean) output.get('booleanPermission');
            Test.stopTest();
            //checks if the invokeMethod had a Successful execution
            Assert.isTrue(result, 'Returned false instead');
            //Check if the hasPermission is False on Non Scheduling user
            Assert.isFalse(hasPermission, 'Returned True Instead');
        }
    }
}
