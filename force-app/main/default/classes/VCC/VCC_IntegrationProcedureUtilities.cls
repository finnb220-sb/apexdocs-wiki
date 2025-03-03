/**
 * @description VCC_IntegrationProcedureUtilities is a class used inside of OmniStudio Integration Procedures using the FUNCTION reference. Currently, this classes purpose is to perform the logic behind retreiving the token
 * for OmniStudio Integration Procedures used for the VAHC Scheduling feature. It also is used to perform some data manipulation for Integration Procedures.
 * @author Booz Allen Hamilton
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class VCC_IntegrationProcedureUtilities implements Callable {
    private static String valueToConvert;
    /**
     * @description call method for the Callable interface.
     * @param action The Apex method to call
     * @param args The arguments that will be passed to the apex method
     * @return `Object` invokeMethod Output
     */
    public Object call(String action, Map<String, Object> args) {
        try {
            Map<String, Object> input = (Map<String, Object>) args.get('input');
            Map<String, Object> output = (Map<String, Object>) args.get('output');
            Map<String, Object> options = (Map<String, Object>) args.get('options');

            return invokeMethod(action, input, output, options);
        } catch (Exception error) {
            throw VCC_ExceptionUtils.createAuraHandledException('Invalid input for call method: ' + error.getMessage());
        }
    }

    /**
     * @description invokeMethod calls the referenced Apex method with its arguments
     * @param methodName The Apex method to call
     * @param inputs The arguments to pass to the Apex method
     * @param output The results that will return to the Integration Procedure
     * @param options Options for the Integration Procedure
     * @justification PMD.ExcessiveParameterList is suppressed to allow input arguments required for integration procedure callable interface. PMD.AvoidGlobalModifier is suppressed
     * as OmniStudio Integration Procedure callable interfaces must be marked global as required by the OmniStudio package
     * @return `Boolean` Returns true once all methods called have run
     */
    @SuppressWarnings('PMD.ExcessiveParameterList, PMD.AvoidGlobalModifier')
    global Boolean invokeMethod(
        String methodName,
        Map<String, Object> inputs,
        Map<String, Object> output,
        Map<String, Object> options
    ) {
        switch on methodName {
            when 'toObjArray' {
                List<Object> arguments = (List<Object>) inputs.get('arguments');
                output.put('result', convertStringToObjArray(arguments));
            }
            when 'arrayToObjArray' {
                List<Object> arguments = (List<Object>) inputs.get('arguments');
                output.put('result', convertArrayToObjArray(arguments));
            }
            when 'toSiteIdArray' {
                List<Object> arguments = (List<Object>) inputs.get('arguments');
                output.put('result', convertStringToSiteIdArray(arguments));
            }
            when 'toSiteNameMap' {
                List<Object> arguments = (List<Object>) inputs.get('arguments');
                output.put('result', createSiteToNameMap(arguments));
            }
            when 'convertArrayToString' {
                List<Object> arguments = (List<Object>) inputs.get('arguments');
                output.put('result', convertArrayToString(arguments));
            }
            when 'getSchedulingSSOToken' {
                output.put('result', getSchedulingSSOToken());
            }
            when 'getUserPermission' {
                String permissionName = String.valueOf(inputs.get('permissionName'));
                output.put('booleanPermission', getUserPermission(permissionName));
            }
        }
        return true;
    }
    /**
     * @description convertStringToObjArray takes in a comma delimited string plus a key identifier, and returns an array of Maps ex.
     * Input Argument Example:
     * {"options":{},"input":{"arguments":[{"VLOCITY-FORMULA-LIST":["REMOVED/NO LONGER NECESSARY,REMOVED/NON-VA CARE"]},"Label"]},"output":{}}
     * Output: [{"Label":"REMOVED/NO LONGER NECESSARY"},{"Label":"REMOVED/NON-VA CARE"}]
     * In order to execute on data sent from a Custom Event in an integration procedure loop block this method is needed, as the event will
     * not pass an actual array, or Stringified JSON correctly to the IP. Instead we can send a comma delimited list
     * and this Apex method will convert it into the appropriate format (key, value pair). This format is used as the required shape to execute an Intgration Procedure loop block
     * @param arguments The arguments to use in the method. The current use is a String representing disposition data, and a key of "Label", to return an array of objects that are
     * iterable by the Integration Procedure.
     * @return `List<Map<String, Object>>` returns an array of Maps Ex:[{"Label":"REMOVED/NO LONGER NECESSARY"},{"Label":"REMOVED/NON-VA CARE"}]
     */
    @testVisible
    private List<Map<String, Object>> convertStringToObjArray(List<Object> arguments) {
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        if (arguments.size() < 2) {
            return result;
        }
        Map<String, Object> inputlist = (Map<String, Object>) arguments[0];
        String key = (String) arguments[1];
        List<Object> listofElements = (List<Object>) inputlist.get('VLOCITY-FORMULA-LIST');
        if (!listOfElements.isEmpty()) {
            String valueToConvert = (String) listofElements[0];
            List<String> listOfStringSplit = valueToConvert.split(',');
            for (Object str : listOfStringSplit) {
                result.add(new Map<String, Object>{ key => str });
            }
        }
        return result;
    }

    /**
     * @description convertArrayToObjArray takes in an array of Strings plus a key identifier, and returns an array of Maps ex.
     * Input Argument Example:
     * {"options":{},"input":{"arguments":[{"VLOCITY-FORMULA-LIST":["REGULAR","COMPENSATION & PENSION"]},"AppointmentType"]},"output":{}}
     * Output: [{"AppointmentType":"REGULAR"},{"AppointmentType":"COMPENSATION & PENSION"}]
     * For an OmniStudio Type Ahead Block the data must be an array that has elements in a key/value pair.
     * @param arguments The arguments to use in the method. The current use is for a Type Ahead Block in the Create Appointment Request OmniScript
     * @return `List<Map<String, Object>>` returns an array of Maps Ex:[{"AppointmentType":"REGULAR"},{"AppointmentType":"COMPENSATION & PENSION"}]
     */
    @testVisible
    private List<Map<String, Object>> convertArrayToObjArray(List<Object> arguments) {
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        if (arguments.size() < 2) {
            return result;
        }
        Map<String, Object> inputlist = (Map<String, Object>) arguments[0];
        String key = (String) arguments[1];
        List<Object> listofValues = (List<Object>) inputlist.get('VLOCITY-FORMULA-LIST');
        if (!listofValues.isEmpty()) {
            for (Object str : listofValues) {
                result.add(new Map<String, Object>{ key => str });
            }
        }
        return result;
    }

    /**
     * @description convertStringToSiteIdArray takes in a comma delimited string plus a key identifier, and returns an array of Maps
     * Input Argument Example:
     * {"options":{},"input":{"arguments":[{"VLOCITY-FORMULA-LIST":["984|DAYSHR,983|CHYSHR"]}]},"output":{}}
     * Output: [{"siteId":"984"},{"siteId":"983"}])
     * In order to execute on data sent from a Custom Event in an integration procedure loop block this method is needed, as the event will
     * not pass an actual array, or Stringified JSON correctly to the IP. Instead we can send a command delimited list
     * and this Apex method will convert it into the appropriate format (key, value pair). This format is used as the required shape to execute an Intgration Procedure loop block
     * @param arguments The arguments to use in the method. The current use is a String representing facilities data, and a key of "siteId", to return an array of objects that are
     * iterable by the Integration Procedure.
     * @return `List<Map<String, Object>>` returns an array of Maps Ex:[{"siteId":"984"},{"siteId":"983"}]
     */
    @testVisible
    private List<Map<String, Object>> convertStringToSiteIdArray(List<Object> arguments) {
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        Map<String, Object> inputlist = (Map<String, Object>) arguments[0];
        List<Object> listOfElements = (List<Object>) inputlist.get('VLOCITY-FORMULA-LIST');
        if (!listOfElements.isEmpty()) {
            valueToConvert = (String) listOfElements[0];
            List<String> listOfFacilities = valueToConvert.split(',');
            for (Object str : listOfFacilities) {
                String stringToSplit = (String) str;
                List<String> facilityProperties = stringToSplit.split('\\|');
                if (facilityProperties.size() == 2) {
                    String facilitySiteId = facilityProperties[0];
                    result.add(new Map<String, Object>{ 'siteId' => facilitySiteId });
                }
            }
        }
        return result;
    }

    /**
     * @description createSiteToNameMap. Used via VALUELOOKUP formula function in VCCUpsertExternalAppointments to inject the Facility Name into the record during upsert.
     * Input Argument Example:
     * {"options":{},"input":{"arguments":[{"VLOCITY-FORMULA-LIST":["984|DAYSHR,983|CHYSHR"]}]},"output":{}}
     * Output: [{"siteId":"984"},{"siteId":"983"}])
     * @param arguments The arguments to use in the method.
     * @return `Map<String, Object>` returns a map of Site Id to Facility Name Ex:{"984":"DAYSHR","983":"CHYSHR"}
     */
    @testVisible
    private Map<String, Object> createSiteToNameMap(List<Object> arguments) {
        Map<String, Object> result = new Map<String, Object>();
        Map<String, Object> inputlist = (Map<String, Object>) arguments[0];
        List<Object> listOfElements = (List<Object>) inputlist.get('VLOCITY-FORMULA-LIST');
        if (!listOfElements.isEmpty()) {
            valueToConvert = (String) listOfElements[0];
            List<String> listOfFacilities = valueToConvert.split(',');
            for (Object str : listOfFacilities) {
                String stringToSplit = (String) str;
                List<String> facilityProperties = stringToSplit.split('\\|');
                if (facilityProperties.size() == 2) {
                    String facilityName = facilityProperties[1];
                    String facilitySiteId = facilityProperties[0];
                    result.put(facilitySiteId, facilityName);
                }
            }
        }
        return result;
    }

    /**
     * @description convertArrayToString takes in an Array, and returns a String concatenated with each of the values in the array. This method
     * is marked @TestVisible in order to allow the confirmation of expected results in the test method. Otherwise, we are limited to asserting the
     * true value returned by the invokeMethod method for the callable interface.
     * @param arguments The arguments to use in the method
     * @return `String` Represents the concatenated String value. (ex. WHEELCHAIR FASTING LAB) The string will be empty if no values are present in the argument.
     */
    @TestVisible
    private String convertArrayToString(List<Object> arguments) {
        String result = '';
        if (arguments == null || arguments.isEmpty()) {
            return result;
        }
        Map<String, Object> inputlist = (Map<String, Object>) arguments[0];
        List<Object> valuesToConvert = (List<Object>) inputlist.get('VLOCITY-FORMULA-LIST');
        if (!valuesToConvert.isEmpty()) {
            for (Object str : valuesToConvert) {
                result += str;
                result += ' ';
            }
        }
        return result.trim();
    }

    /**
     * @description getSchedulingSSOToken returns the oAuthSettings to use in the Scheduling Integration Procedures
     * There are three basic conditions that can execute. If we are in the Production Environment, the code will
     * return the user's real oAuth token. If it is not Production, but Mock SSO is false, it will also get the user's
     * real oAuth token. If Mock SSO is turned on, and it is NOT Production, it will return a token from a custom setting.
     * This token is used for testing and development purposes.
     *
     * NOTE: System.isTest() is used in this method to allow the test class to perform assertions on the output of the method.
     * @return `Map<String,Object>` Returns a property map representing the Scheduling oAuth settings for the org Ex: {"token":"exampleToken", "isProd": false}
     */
    @testVisible
    private Map<String, Object> getSchedulingSSOToken() {
        Map<String, Object> oAuthSettings = new Map<String, Object>();
        String token = '';
        VCC_Scheduling_OAuth_Token__c settings = VCC_Scheduling_OAuth_Token__c.getOrgDefaults();
        Boolean isSandbox = new VCR_OrgRepo().orgInfo.isSandbox;
        //Using System.Test.isRunningTest() to allow the value of the token to be known for test assertions.
        if (weAreInProductionOrMockSSOFalse()) {
            if (!System.Test.isRunningTest()) {
                token = IAM_SSOi_OAuthUtility.getVARefreshToken()[0];
            }
        } else {
            if (!System.Test.isRunningTest()) {
                token = settings.VCC_OAuth_Token__c;
            }
        }
        oAuthSettings.put('token', token);
        oAuthSettings.put('isProd', !isSandbox);
        return oAuthSettings;
    }

    /**
     * @description This method checks if the running user is assigned a certain custom permission
     * @param customPermissionsName The name of the custom permission to check for
     * @return `Boolean` The result of whether the User has the custom permission. True or false.
     */
    @testVisible
    private Boolean getUserPermission(String customPermissionsName) {
        Boolean hasCustomPermission = false;
        hasCustomPermission = FeatureManagement.checkPermission(customPermissionsName);
        return hasCustomPermission;
    }

    /**
     * @description This method checks two conditions, and returns true if either are detected.
     * First condition is whether we are in Production. The second condition is whether Mock SSO is turned on for the Scheduling feature.
     * @return `Boolean` The result of the check.
     */
    private Boolean weAreInProductionOrMockSSOFalse() {
        Boolean isSandbox = new VCR_OrgRepo().orgInfo.isSandbox;
        VCC_Scheduling_OAuth_Token__c settings = VCC_Scheduling_OAuth_Token__c.getOrgDefaults();
        if (!isSandbox || settings.VCC_Mock_SSO__c == false) {
            return true;
        }
        return false;
    }
}
