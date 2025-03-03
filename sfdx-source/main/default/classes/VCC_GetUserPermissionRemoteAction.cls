/**
 * @description The purpose of this class is to run in an Omnistudio Remote action, to check if the current running user has a certain permission.
 *  Current Omnistudio functionality runs in User context, this remote action is to bypass that.
 * @author Booz Allen Hamilton
 * @since 4/15/2024
 */
global class VCC_GetUserPermissionRemoteAction implements callable {
    public Boolean call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');

        return invokeMethod(action, input, output, options);
    }
    public Boolean invokeMethod(
        String methodName,
        Map<String, Object> input,
        Map<String, Object> output,
        Map<String, Object> options
    ) {
        // Check if the invoked methodName is the one you want to handle.
        if (methodName.equals('getUserPermission')) {
            // If it is, call your custom method to perform the desired action.
            getUserPermission(input, output, options);
        }

        // Return true to indicate successful execution.
        return true;
    }

    public void getUserPermission(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        Boolean hasCustomPermission = false;
        String customPermissionsName = String.valueOf(input.get('permissionName'));

        //check if the running user has the permission set
        Boolean hasPermission = FeatureManagement.checkPermission(customPermissionsName);

        if (hasPermission == true) {
            hasCustomPermission = true;
        } else {
            hasCustomPermission = false;
        }
        //add the boolean value to the output
        output.put('booleanPermission', hasCustomPermission);
    }
}
