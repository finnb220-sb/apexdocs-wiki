/**
 * @description Controller for VAT Page
 * VAT - VistA Access Test
 * @author Patrick Skamarak
 */
@SuppressWarnings('PMD.ClassNamingConventions')
public with sharing class VCC_VatPageController {
    private static final String NO_TEST_CONFIG_TEMPLATE = 'No test configuration data found for site "{0}" and service "{1}".';

    @TestVisible
    /**
     * @description Run Test For Site Parameters object definition
     */
    private class RunTestForSiteParameters {
        public VCC_TestConfigurationDataSelector testConfigDataSelector = new VCC_TestConfigurationDataSelector();
        public VCC_TestRunDomain testRunDomain = new VCC_TestRunDomain();
        public VCC_VdifParametersDomain vdifParametersDomain = new VCC_VdifParametersDomain();
        /**
         * @description getter/setter
         */
        public String serviceApiName { get; set; }
        /**
         * @description getter/setter
         */
        public String siteCode { get; set; }
        /**
         * @description getter/setter
         */
        public String esig { get; set; }
        /**
         * @description getter/setter
         */
        public String token { get; set; }
        /**
         * @description getter/setter
         */
        public String duz { get; set; }
        /**
         * @description constructor with param map as argument
         *
         * @param params
         */
        public RunTestForSiteParameters(Map<String, Object> params) {
            this.serviceApiName = (String) params.get('serviceApiName');
            this.siteCode = (String) params.get('siteCode');
            this.esig = (String) params.get('esig');
            this.token = (String) params.get('token');
            this.duz = (String) params.get('duz');
        }
    }

    /**
     * @description Run Test For Site Result Object definition
     */
    public class RunTestForSiteResult {
        @AuraEnabled
        public Boolean success;

        @AuraEnabled
        public String failReason;

        @AuraEnabled
        public String siteCode;

        /**
         * @description constructor with arguments
         *
         * @param siteCode
         * @param success
         * @param failReason
         */
        public RunTestForSiteResult(String siteCode, Boolean success, String failReason) {
            this.siteCode = siteCode;
            this.success = success;
            this.failReason = failReason;
        }
    }

    /**
     * @description Run Test for Site starts vdif test run given params map
     *
     * @param parametersObject
     * @return  `RunTestForSiteResult`
     */
    @AuraEnabled
    public static RunTestForSiteResult runTestForSite(Map<String, Object> parametersObject) {
        return runTestForSite(new RunTestForSiteParameters(parametersObject));
    }

    /**
     * @description Run Test for Site starts vdif test run given params object
     *
     * @param parameters
     * @return  `RunTestForSiteResult`
     * @exception
     */
    public static RunTestForSiteResult runTestForSite(RunTestForSiteParameters parameters) {
        try {
            Logger.debug('Initializing vdif test run...');

            List<VCC_Test_Configuration_Data__c> testConfigData;

            testConfigData = parameters.testConfigDataSelector.selectVdifTestPatientDataByServiceAndSite(
                parameters.siteCode,
                parameters.serviceApiName
            );

            if (testConfigData.isEmpty()) {
                throw new VCC_InternalException(
                    String.format(
                        NO_TEST_CONFIG_TEMPLATE,
                        new List<String>{ parameters?.siteCode, parameters?.serviceApiName }
                    )
                );
            }

            VCC_TestRunService.instance.validateVdifTestConfiguration(testConfigData[0]);

            VCC_VdifParameters vdifParameters = new VCC_VdifParameters();

            VCC_Test_Run__c testRun = new VCC_Test_Run__c(
                VCC_Status__c = 'New',
                VCC_Log_Correlation_Id__c = Logger.getTransactionId()
            );

            parameters.testRunDomain.initializeTestRun(testRun, testConfigData[0]);

            VCC_HttpIntercept_Observer.observeNext();
            parameters.vdifParametersDomain.addDataFromTestConfig(vdifParameters, testConfigData[0]);
            parameters.vdifParametersDomain.populateProviderInfo(
                vdifParameters,
                parameters.esig,
                parameters.siteCode,
                parameters.duz,
                parameters.token
            );

            VCC_TestRunService.instance.insertTestRun(testRun);
            vdifParameters.recordId = testRun.Id;
            VCC_TestRunService.instance.addCalloutData(testRun, VCC_HttpIntercept_Observer.getData());

            VCC_VdifQueueStrat_TestRun queueStrategy = new VCC_VdifQueueStrat_TestRun(testRun, testConfigData[0]);

            VCC_VdifQueueableCallback queueableCallback = new VCC_VdifQueueableCallback(
                vdifParameters.clone(),
                queueStrategy
            );

            Id jobId;

            if (!Test.isRunningTest()) {
                jobId = queueableCallback.enqueueStage(VCC_VdifQueueableCallback.Stage.VALIDATE_ESIG);
                Logger.debug('Test run started!');
            }

            if (String.isNotBlank(jobId) && testRun.VCC_Status__c != 'RUNNING') {
                testRun.VCC_Site_Code__c = testConfigData[0].VCC_Site_Code__c;
                testRun.VCC_Status__c = 'RUNNING';
            }

            VCC_TestRunService.instance.updateTestRun(testRun);

            return new RunTestForSiteResult(parameters.siteCode, true, null);
        } catch (Exception e) {
            Logger.error('Exception occurred while starting test run.', e);
            Logger.debug(e.getMessage());

            return new RunTestForSiteResult(parameters.siteCode, false, e.getMessage());
        } finally {
            Logger.saveLog();
        }
    }

    /**
     * @description gets the record tyoe id from test configuration on test patient
     *
     * @return  `Id`
     */
    @AuraEnabled
    public static Id getRecordTypeId() {
        return VCC_Test_Configuration_Data__c.getSObjectType()
            .getDescribe(Schema.SObjectDescribeOptions.DEFERRED)
            .getRecordTypeInfosByDeveloperName()
            .get('VCC_Vdif_Test_Patient')
            .getRecordTypeId();
    }

    /**
     * @description retrieves oauth token
     *
     * @return  `String`
     * @exception
     */
    @AuraEnabled
    public static String getToken() {
        try {
            String token;

            if (VCC_MockSSOServiceV2.instance.isMockSSOEnabled()) {
                token = VCC_MockSSOServiceV2.instance.getMockSSOToken();
            } else {
                token = IAM_SSOi_OAuthUtility.getVaRefreshToken()[0];
            }

            return token;
        } catch (Exception e) {
            throw new AuraHandledException('Failed to retrieve token.');
        }
    }

    /**
     * @description gets the user sites from provider instance settings based on running user info
     *
     * @return  `List<IAM_SSOi_Vista_Instance_to_User_DUZ__c>`
     */
    @AuraEnabled
    public static List<IAM_SSOi_Vista_Instance_to_User_DUZ__c> getUserSites() {
        List<IAM_SSOi_Vista_Instance_to_User_DUZ__c> sites = VCC_ProviderServiceV2.instance.getVistaInstanceSettings(
            UserInfo.getUserId()
        );
        if (sites == null) {
            sites = new List<IAM_SSOi_Vista_Instance_to_User_DUZ__c>();
        }
        return sites;
    }
}
