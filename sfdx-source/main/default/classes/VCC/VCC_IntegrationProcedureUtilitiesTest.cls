/**
 * @description Test class for VCC_IntegrationProcedureUtilties
 * @see VCC_IntegrationProcedureUtilities
 * @author Booz Allen Hamilton
 */
@IsTest
public with sharing class VCC_IntegrationProcedureUtilitiesTest {
    final static User SCHEDULING_USER = new VATEST_UserBuilder()
        .withPermissionSet('VCC_Advanced_Medical_Support_Assistant')
        .withPermissionSet('VAHC_Scheduling_User')
        .withUserProfile('VAVET Base Profile')
        .withStandardData()
        .build(true);
    final static User NON_SCHEDULING_USER = new VATEST_UserBuilder()
        .withPermissionSet('VAHC_RN_USER')
        .withUserProfile('VAVET Base Profile')
        .withStandardData()
        .build(true);
    final static User ADMIN = new VATEST_UserBuilder()
        .withUserProfile('System Administrator')
        .withStandardData()
        .build(true);
    final static String NULL_EXCEPTION = 'Invalid input for call method: Attempt to de-reference a null object';

    /**
     * @description Test method that confirms calling the call method with expected parameters returns true for the toObjArray method.
     */
    @IsTest
    private static void unitCallInvokeMethodToObjArrayNullInputNegative() {
        System.runAs(SCHEDULING_USER) {
            String jsonString = '{"options":{}, "output":{}}';
            Map<String, Object> args = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Test.startTest();
            try {
                VCC_IntegrationProcedureUtilities ipUtils = new VCC_IntegrationProcedureUtilities();
                ipUtils.call('toObjArray', args);
                Assert.fail(
                    'Expected an exception to be thrown when passing in null input to ipUtils.call for toObjArray'
                );
            } catch (AuraHandledException error) {
                Assert.areEqual(
                    NULL_EXCEPTION,
                    error.getMessage(),
                    'Expected ' + NULL_EXCEPTION + ' when passing null input on ipUtils.call'
                );
            }
            Test.stopTest();
        }
    }
    /**
     * @description Test method that confirms that passing a single argument outputs the expected data.
     */
    @IsTest
    private static void unitConvertStringToObjArrayWithSingleArgumentPositive() {
        System.runAs(SCHEDULING_USER) {
            String jsonString = '{"options":{},"input":{"arguments":[{"VLOCITY-FORMULA-LIST":["REMOVED/NO LONGER NECESSARY,REMOVED/NON-VA CARE"]}]},"output":{}}';
            Map<String, Object> callArguments = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Map<String, Object> input = (Map<String, Object>) callArguments.get('input');
            List<Object> methodArguments = (List<Object>) input.get('arguments');
            Test.startTest();
            VCC_IntegrationProcedureUtilities ipUtils = new VCC_IntegrationProcedureUtilities();
            List<Map<String, Object>> result = ipUtils.convertStringToObjArray(methodArguments);
            Test.stopTest();
            Assert.areEqual(new List<Map<String, Object>>(), result, 'Expected result to be an empty List of Maps.');
        }
    }
    /**
     * @description Test method that confirms calling the call method with expected parameters returns true for the toObjArray method.
     */
    @IsTest
    private static void unitCallInvokeMethodToObjArrayPositive() {
        System.runAs(SCHEDULING_USER) {
            String jsonString = '{"options":{},"input":{"arguments":[{"VLOCITY-FORMULA-LIST":["REMOVED/NO LONGER NECESSARY,REMOVED/NON-VA CARE"]},"Label"]},"output":{}}';
            Map<String, Object> args = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Test.startTest();
            VCC_IntegrationProcedureUtilities ipUtils = new VCC_IntegrationProcedureUtilities();
            Boolean result = (Boolean) ipUtils.call('toObjArray', args);
            Test.stopTest();
            Assert.isTrue(result, 'Expected result to be true on ipUtils.call.');
        }
    }
    /**
     * @description Test method that confirms calling the call method with expected parameters returns true for the toObjArray method.
     */
    @IsTest
    private static void unitCallInvokeMethodNullInputNegative() {
        System.runAs(SCHEDULING_USER) {
            String jsonString = '{"options":{}, "output":{}}';
            Map<String, Object> args = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Test.startTest();
            try {
                VCC_IntegrationProcedureUtilities ipUtils = new VCC_IntegrationProcedureUtilities();
                Object result = ipUtils.call('toSiteIdArray', args);
                Assert.isFalse((Boolean) result, 'Assertion failed; Epected result to be false');
            } catch (AuraHandledException error) {
                Assert.areEqual(
                    NULL_EXCEPTION,
                    error.getMessage(),
                    'Expected ' + NULL_EXCEPTION + ' when passing null input on ipUtils.call'
                );
            }
            Test.stopTest();
        }
    }

    /**
     * @description Test method that confirms calling the call method with expected parameters returns true for the toSiteIdArray method.
     */
    @IsTest
    private static void unitCallInvokeMethodToSiteIdArrayPositive() {
        System.runAs(SCHEDULING_USER) {
            String jsonString = '{"options":{},"input":{"arguments":[{"VLOCITY-FORMULA-LIST":["984|DAYSHR,"]}]},"output":{}}';
            Map<String, Object> args = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Test.startTest();
            VCC_IntegrationProcedureUtilities ipUtils = new VCC_IntegrationProcedureUtilities();
            Object result = ipUtils.call('toSiteIdArray', args);
            Test.stopTest();
            Assert.areEqual(
                result,
                true,
                'Assertion failed in test method unitCallInvokeMethodToSiteIdArrayPositive; Expected result to be true.'
            );
        }
    }

    /**
     * @description Test method that confirms calling the call method with expected parameters returns true for the toSiteNameMap method.
     */
    @IsTest
    private static void unitCallInvokeMethodToSiteNameMapPositive() {
        System.runAs(SCHEDULING_USER) {
            String jsonString = '{"options":{},"input":{"arguments":[{"VLOCITY-FORMULA-LIST":["984|DAYSHR,"]}]},"output":{}}';
            Map<String, Object> args = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Test.startTest();
            VCC_IntegrationProcedureUtilities ipUtils = new VCC_IntegrationProcedureUtilities();
            Object result = ipUtils.call('toSiteNameMap', args);
            Test.stopTest();
            Assert.areEqual(
                result,
                true,
                'Assertion failed in test method unitCallInvokeMethodToSiteNameMapPositive; Expected result to be true.'
            );
        }
    }

    /**
     * @description Test method that confirms calling the call method with expected parameters returns true for the convertArrayToString method.
     */
    @IsTest
    private static void unitCallInvokeMethodConvertArrayToStringPositive() {
        System.runAs(SCHEDULING_USER) {
            String jsonString = '{"options":{},"input":{"arguments":[{"VLOCITY-FORMULA-LIST":["WHEELCHAIR NEEDED, PATIENT TO ARRIVE AT 8AM FOR LABS"]}]},"output":{}}';
            Map<String, Object> args = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Test.startTest();
            VCC_IntegrationProcedureUtilities ipUtils = new VCC_IntegrationProcedureUtilities();
            Boolean result = (Boolean) ipUtils.call('convertArrayToString', args);
            Test.stopTest();
            Assert.isTrue(
                result,
                'Assertion failed in test method unitCallInvokeMethodConvertArrayToStringPositive; Expected result to be true.'
            );
        }
    }

    /**
     * @description Test method that confirms calling the call method with expected parameters returns true for the getSchedulingSSOToken method.
     */
    @IsTest
    private static void unitCallInvokeMethodGetSchedulingSSOTokenPositive() {
        System.runAs(SCHEDULING_USER) {
            String jsonString = '{"options":{},"input":{"arguments":["",""]},"output":{}}';
            Map<String, Object> args = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Test.startTest();
            VCC_IntegrationProcedureUtilities ipUtils = new VCC_IntegrationProcedureUtilities();
            Object result = ipUtils.call('getSchedulingSSOToken', args);
            Test.stopTest();
            Assert.areEqual(
                result,
                true,
                'Assertion failed in test method unitCallInvokeMethodGetSchedulingSSOTokenPositive; Expected result to be true.'
            );
        }
    }

    /**
     * @description Test method that confirms calling the call method with expected parameters returns true for the getUserPermission method.
     */
    @IsTest
    private static void unitCallInvokeMethodGetUserPermissionPositive() {
        System.runAs(SCHEDULING_USER) {
            String jsonString = '{"options":{},"input":{"permissionName":"VAHC_Scheduling_User"},"output":{}}';
            Map<String, Object> args = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Test.startTest();
            VCC_IntegrationProcedureUtilities ipUtils = new VCC_IntegrationProcedureUtilities();
            Object result = ipUtils.call('getUserPermission', args);
            Test.stopTest();
            Assert.areEqual(
                result,
                true,
                'Assertion failed in test method unitCallInvokeMethodGetUserPermissionPositive; Expected result to be true.'
            );
        }
    }

    /**
     * @description Test method that confirms calling the call method with expected parameters returns true for the convertArrayToObjArray method.
     */
    @IsTest
    private static void unitCallInvokeMethodArrayToObjectArrayPositive() {
        System.runAs(SCHEDULING_USER) {
            String jsonString = '{"options":{},"input":{"arguments":[{"VLOCITY-FORMULA-LIST":["REGULAR","COMPENSATION & PENSION"]},"appointmentTypeLabel"]},"output":{}}';
            Map<String, Object> args = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Test.startTest();
            VCC_IntegrationProcedureUtilities ipUtils = new VCC_IntegrationProcedureUtilities();
            Object result = ipUtils.call('arrayToObjArray', args);
            Test.stopTest();
            Assert.areEqual(result, true, 'Expected result to be true.');
        }
    }

    /**
     * @description Test method that confirms that passing a single facility outputs the expected data type/format.
     */
    @IsTest
    private static void unitConvertStringToSiteIdArrayWithSingleFacilityPositive() {
        System.runAs(SCHEDULING_USER) {
            String jsonString = '{"options":{},"input":{"arguments":[{"VLOCITY-FORMULA-LIST":["984|DAYSHR,"]}]},"output":{}}';
            Map<String, Object> callArguments = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Map<String, Object> input = (Map<String, Object>) callArguments.get('input');
            List<Object> methodArguments = (List<Object>) input.get('arguments');
            Test.startTest();
            VCC_IntegrationProcedureUtilities ipUtils = new VCC_IntegrationProcedureUtilities();
            List<Map<String, Object>> result = ipUtils.convertStringToSiteIdArray(methodArguments);
            Test.stopTest();
            Assert.areEqual(
                '[{"siteId":"984"}]',
                JSON.serialize(result),
                'Assertion failed in test method unitConvertStringToSiteIdArrayWithSingleFacilityPositive; Expected [{"siteId":"984"}]'
            );
        }
    }

    /**
     * @description Test method that confirms that passing a list of multiple facilities outputs the expected data type/format.
     */
    @IsTest
    private static void unitConvertStringToSiteIdArrayWithMultipleFacilityPositive() {
        System.runAs(SCHEDULING_USER) {
            String jsonString = '{"options":{},"input":{"arguments":[{"VLOCITY-FORMULA-LIST":["984|DAYSHR,983|CHYSHR"]}]},"output":{}}';
            Map<String, Object> callArguments = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Map<String, Object> input = (Map<String, Object>) callArguments.get('input');
            List<Object> methodArguments = (List<Object>) input.get('arguments');
            Test.startTest();
            VCC_IntegrationProcedureUtilities ipUtils = new VCC_IntegrationProcedureUtilities();
            List<Map<String, Object>> result = ipUtils.convertStringToSiteIdArray(methodArguments);
            Test.stopTest();
            Assert.areEqual(
                '[{"siteId":"984"},{"siteId":"983"}]',
                JSON.serialize(result),
                'Assertion failed in test method unitConvertStringToSiteIdArrayWithMultipleFacilityPositive; Expected [{"siteId":"984"},{"siteId":"983"}]'
            );
        }
    }

    /**
     * @description Test method that confirms that passing an empty array as an argument does not result in an error.
     */
    @IsTest
    private static void unitConvertStringToSiteIdArrayEmptyArrayPositive() {
        System.runAs(SCHEDULING_USER) {
            String jsonString = '{"options":{},"input":{"arguments":[{"VLOCITY-FORMULA-LIST":[]}]},"output":{}}';
            Map<String, Object> callArguments = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Map<String, Object> input = (Map<String, Object>) callArguments.get('input');
            List<Object> methodArguments = (List<Object>) input.get('arguments');
            Test.startTest();
            VCC_IntegrationProcedureUtilities ipUtils = new VCC_IntegrationProcedureUtilities();
            List<Map<String, Object>> result = ipUtils.convertStringToSiteIdArray(methodArguments);
            Test.stopTest();
            Assert.areEqual(
                '[]',
                JSON.serialize(result),
                'Assertion failed in test method unitConvertStringToSiteIdArrayEmptyArrayPositive; Expected an empty array []'
            );
        }
    }

    /**
     * @description Test method that confirms that passing a malformed string does not cause an error
     */
    @IsTest
    private static void unitConvertStringToSiteIdArrayMalformedStringPositive() {
        System.runAs(SCHEDULING_USER) {
            String jsonString = '{"options":{},"input":{"arguments":[{"VLOCITY-FORMULA-LIST":["984,DAYSHR"]}]},"output":{}}';
            Map<String, Object> callArguments = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Map<String, Object> input = (Map<String, Object>) callArguments.get('input');
            List<Object> methodArguments = (List<Object>) input.get('arguments');
            Test.startTest();
            VCC_IntegrationProcedureUtilities ipUtils = new VCC_IntegrationProcedureUtilities();
            List<Map<String, Object>> result = ipUtils.convertStringToSiteIdArray(methodArguments);
            Test.stopTest();
            Assert.areEqual(
                new List<Map<String, Object>>(),
                result,
                'Assertion failed in test method unitConvertStringToSiteIdArrayMalformedStringPositive; Expected an empty list of maps'
            );
        }
    }

    /**
     * @description Test method that confirms that passing a single facility outputs the expected data type/format.
     */
    @IsTest
    private static void unitCreateSiteToNameMapWithSingleFacilityPositive() {
        System.runAs(SCHEDULING_USER) {
            String jsonString = '{"options":{},"input":{"arguments":[{"VLOCITY-FORMULA-LIST":["984|DAYSHR,"]}]},"output":{}}';
            Map<String, Object> callArguments = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Map<String, Object> input = (Map<String, Object>) callArguments.get('input');
            List<Object> methodArguments = (List<Object>) input.get('arguments');
            Test.startTest();
            VCC_IntegrationProcedureUtilities ipUtils = new VCC_IntegrationProcedureUtilities();
            Map<String, Object> result = ipUtils.createSiteToNameMap(methodArguments);
            Test.stopTest();
            Assert.areEqual(
                '{"984":"DAYSHR"}',
                JSON.serialize(result),
                'Assertion failed in test method unitCreateSiteToNameMapWithSingleFacilityPositive; Expected {"984":"DAYSHR"}'
            );
        }
    }

    /**
     * @description Test method that confirms that passing a list of multiple facilities outputs the expected data type/format.
     */
    @IsTest
    private static void unitCreateSiteToNameMapWithMultipleFacilityPositive() {
        System.runAs(SCHEDULING_USER) {
            String jsonString = '{"options":{},"input":{"arguments":[{"VLOCITY-FORMULA-LIST":["984|DAYSHR,983|CHYSHR"]}]},"output":{}}';
            Map<String, Object> callArguments = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Map<String, Object> input = (Map<String, Object>) callArguments.get('input');
            List<Object> methodArguments = (List<Object>) input.get('arguments');
            Test.startTest();
            VCC_IntegrationProcedureUtilities ipUtils = new VCC_IntegrationProcedureUtilities();
            Map<String, Object> result = ipUtils.createSiteToNameMap(methodArguments);
            Test.stopTest();
            Assert.areEqual(
                '{"983":"CHYSHR","984":"DAYSHR"}',
                JSON.serialize(result),
                'Assertion failed in test method unitCreateSiteToNameMapWithMultipleFacilityPositive; Expected {"983":"CHYSHR","984":"DAYSHR"}'
            );
        }
    }

    /**
     * @description Test method that confirms that passing a malformed string does not cause an error
     */
    @IsTest
    private static void unitCreateSiteToNameMapMalformedStringPositive() {
        System.runAs(SCHEDULING_USER) {
            String jsonString = '{"options":{},"input":{"arguments":[{"VLOCITY-FORMULA-LIST":["983,DAYSHR"]}]},"output":{}}';
            Map<String, Object> callArguments = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Map<String, Object> input = (Map<String, Object>) callArguments.get('input');
            List<Object> methodArguments = (List<Object>) input.get('arguments');
            Test.startTest();
            VCC_IntegrationProcedureUtilities ipUtils = new VCC_IntegrationProcedureUtilities();
            Map<String, Object> result = ipUtils.createSiteToNameMap(methodArguments);
            Test.stopTest();
            Assert.areEqual(
                new Map<String, Object>(),
                result,
                'Assertion failed in test method unitCreateSiteToNameMapMalformedStringPositive; Expected an empty map'
            );
        }
    }

    /**
     * @description Test method that confirms that passing an empty array as an argument does not result in an error.
     */
    @IsTest
    private static void unitCreateSiteToNameMapEmptyArrayPositive() {
        System.runAs(SCHEDULING_USER) {
            String jsonString = '{"options":{},"input":{"arguments":[{"VLOCITY-FORMULA-LIST":[]}]},"output":{}}';
            Map<String, Object> callArguments = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Map<String, Object> input = (Map<String, Object>) callArguments.get('input');
            List<Object> methodArguments = (List<Object>) input.get('arguments');
            Test.startTest();
            VCC_IntegrationProcedureUtilities ipUtils = new VCC_IntegrationProcedureUtilities();
            Map<String, Object> result = ipUtils.createSiteToNameMap(methodArguments);
            Test.stopTest();
            Assert.areEqual(
                new Map<String, Object>(),
                result,
                'Assertion failed in test method unitCreateSiteToNameMapEmptyArrayPositive; Expected an empty map'
            );
        }
    }

    /**
     * @description Test method that confirms that passing a list of multiple elements results in a concatenated String.
     */
    @IsTest
    private static void unitConvertArrayToStringWithMultiplePrereqsPositive() {
        System.runAs(SCHEDULING_USER) {
            String jsonString = '{"options":{},"input":{"arguments":[{"VLOCITY-FORMULA-LIST":["WHEELCHAIR NEEDED", "PATIENT TO ARRIVE AT 8AM FOR LABS"]}]},"output":{}}';
            Map<String, Object> callArguments = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Map<String, Object> input = (Map<String, Object>) callArguments.get('input');
            List<Object> methodArguments = (List<Object>) input.get('arguments');
            Test.startTest();
            VCC_IntegrationProcedureUtilities ipUtils = new VCC_IntegrationProcedureUtilities();
            String result = ipUtils.convertArrayToString(methodArguments);
            Test.stopTest();
            Assert.areEqual(
                'WHEELCHAIR NEEDED PATIENT TO ARRIVE AT 8AM FOR LABS',
                result,
                'Assertion failed in test method unitConvertArrayToStringWithMultiplePrereqsPositive; Expected WHEELCHAIR NEEDED PATIENT TO ARRIVE AT 8AM FOR LABS'
            );
        }
    }

    /**
     * @description Test method that confirms that passing a list of multiple elements results in a concatenated String.
     */
    @IsTest
    private static void unitConvertArrayToStringWithEmptyArrayPositive() {
        System.runAs(SCHEDULING_USER) {
            String jsonString = '{"options":{},"input":{"arguments":[{"VLOCITY-FORMULA-LIST":[]}]},"output":{}}';
            Map<String, Object> callArguments = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Map<String, Object> input = (Map<String, Object>) callArguments.get('input');
            List<Object> methodArguments = (List<Object>) input.get('arguments');
            Test.startTest();
            VCC_IntegrationProcedureUtilities ipUtils = new VCC_IntegrationProcedureUtilities();
            String result = ipUtils.convertArrayToString(methodArguments);
            Test.stopTest();
            Assert.isTrue(
                String.isBlank(result),
                'Assertion failed in test method unitConvertArrayToStringWithEmptyArrayPositive; Expected an empty String'
            );
        }
    }

    /**
     * @description Test method that confirms that passing expected parameters outputs the expected data type/format.
     */
    @IsTest
    private static void unitGetSchedulingSSOTokenMockSSOFalsePositive() {
        System.runAs(ADMIN) {
            insert new VCC_Scheduling_OAuth_Token__c(VCC_Mock_SSO__c = false, VCC_OAuth_Token__c = '');
        }
        System.runAs(SCHEDULING_USER) {
            Boolean isSandbox = new VCR_OrgRepo().orgInfo.isSandbox;
            Test.startTest();
            VCC_IntegrationProcedureUtilities ipUtils = new VCC_IntegrationProcedureUtilities();
            Map<String, Object> oAuthSettings = ipUtils.getSchedulingSSOToken();
            Test.stopTest();
            if (isSandbox == false) {
                Assert.areEqual(
                    '{"isProd":true,"token":""}',
                    JSON.serialize(oAuthSettings),
                    'Assertion failed in test method unitGetSchedulingSSOTokenMockSSOFalsePositive; Expected {"isProd":true,"token":""}'
                );
            } else {
                Assert.areEqual(
                    '{"isProd":false,"token":""}',
                    JSON.serialize(oAuthSettings),
                    'Assertion failed in test method unitGetSchedulingSSOTokenMockSSOFalsePositive; Expected {"isProd":false,"token":""}'
                );
            }
        }
    }

    /**
     * @description Test method that confirms that passing expected parameters outputs the expected data type/format.
     */
    @IsTest
    private static void unitGetSchedulingSSOTokenMockSSOTruePositive() {
        System.runAs(ADMIN) {
            insert new VCC_Scheduling_OAuth_Token__c(VCC_Mock_SSO__c = true, VCC_OAuth_Token__c = '');
        }
        System.runAs(SCHEDULING_USER) {
            Boolean isSandbox = new VCR_OrgRepo().orgInfo.isSandbox;
            Test.startTest();
            VCC_IntegrationProcedureUtilities ipUtils = new VCC_IntegrationProcedureUtilities();
            Map<String, Object> oAuthSettings = ipUtils.getSchedulingSSOToken();
            Test.stopTest();
            if (isSandbox == false) {
                Assert.areEqual(
                    '{"isProd":true,"token":""}',
                    JSON.serialize(oAuthSettings),
                    'Assertion failed in test method unitGetSchedulingSSOTokenMockSSOTruePositive; Expected {"isProd":true,"token":""}'
                );
            } else {
                Assert.areEqual(
                    '{"isProd":false,"token":""}',
                    JSON.serialize(oAuthSettings),
                    'Assertion failed in test method unitGetSchedulingSSOTokenMockSSOTruePositive; Expected {"isProd":false,"token":""}'
                );
            }
        }
    }

    /**
     * @description Positive Unit test for running user with the desired permission set
     */
    @isTest
    private static void unitCallMethodWithSchedulingPermissionPositive() {
        System.runAs(SCHEDULING_USER) {
            String jsonString = '{"options":{},"input":{"permissionName":"VAHC_Scheduling_User"},"output":{}}';
            Map<String, Object> callArguments = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Map<String, Object> input = (Map<String, Object>) callArguments.get('input');
            String methodArgument = (String) input.get('permissionName');
            Test.startTest();
            VCC_IntegrationProcedureUtilities ipUtils = new VCC_IntegrationProcedureUtilities();
            Boolean hasPermission = (Boolean) ipUtils.getUserPermission(methodArgument);
            Test.stopTest();
            Assert.isTrue(
                hasPermission,
                'Assertion failed in test method unitCallMethodWithSchedulingPermissionPositive; Expected value to be true.'
            );
        }
    }

    /**
     * @description Positive unit test for running user without the desired permission set
     */
    @isTest
    private static void unitCallMethodWithoutSchedulingPermissionPositive() {
        System.runAs(NON_SCHEDULING_USER) {
            String jsonString = '{"options":{},"input":{"permissionName":"VAHC_Scheduling_User"},"output":{}}';
            Map<String, Object> callArguments = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Map<String, Object> input = (Map<String, Object>) callArguments.get('input');
            String methodArgument = (String) input.get('permissionName');
            Test.startTest();
            VCC_IntegrationProcedureUtilities ipUtils = new VCC_IntegrationProcedureUtilities();
            Boolean hasPermission = (Boolean) ipUtils.getUserPermission(methodArgument);
            Test.stopTest();
            Assert.isFalse(
                hasPermission,
                'Assertion failed in test method unitCallMethodWithoutSchedulingPermissionPositive; Expected value to be false.'
            );
        }
    }

    /**
     * @description Test method that confirms that passing a single argument outputs the expected data.
     */
    @IsTest
    private static void unitConvertArrayToObjArrayPositive() {
        System.runAs(SCHEDULING_USER) {
            String jsonString = '{"options":{},"input":{"arguments":[{"VLOCITY-FORMULA-LIST":["REGULAR","COMPENSATION & PENSION"]},"appointmentTypeLabel"]},"output":{}}';
            Map<String, Object> callArguments = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Map<String, Object> input = (Map<String, Object>) callArguments.get('input');
            List<Object> methodArguments = (List<Object>) input.get('arguments');
            Test.startTest();
            VCC_IntegrationProcedureUtilities ipUtils = new VCC_IntegrationProcedureUtilities();
            List<Map<String, Object>> result = ipUtils.convertArrayToObjArray(methodArguments);
            Test.stopTest();
            List<Map<String, Object>> expectedObjectList = new List<Map<String, Object>>();
            expectedObjectList.add(new Map<String, Object>{ 'appointmentTypeLabel' => 'REGULAR' });
            expectedObjectList.add(new Map<String, Object>{ 'appointmentTypeLabel' => 'COMPENSATION & PENSION' });

            Assert.areEqual(
                expectedObjectList,
                result,
                'Expected result to match this format: ' + '\n' + JSON.serializePretty(expectedObjectList)
            );
        }
    }
}
