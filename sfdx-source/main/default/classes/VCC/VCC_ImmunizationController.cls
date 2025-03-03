/**
 * @description Controller for Immunizations component
 * @author Booz Allen
 * @see `VCR_HealthDataRepo` to see the shape of the Health Data Config returned to LWC
 */
public with sharing class VCC_ImmunizationController {
    @TestVisible
    private static final String APPLICATION = 'VAHC';

    @TestVisible
    private static final String RETRY_CMD = 'RETRY_CMD';

    @TestVisible
    private static final String NO_RETRY_CMD = 'NO_RETRY_CMD';

    @TestVisible
    private static VCR_ImmunizationsRepo immunizationsRepo {
        get {
            if (immunizationsRepo == null) {
                immunizationsRepo = new VCR_ImmunizationsRepo();
            }
            return immunizationsRepo;
        }
        set;
    }

    /**
     * @description instantiates a immunizations health data repo
     */
    @TestVisible
    private static VCR_HealthDataRepo healthDataRepo {
        get {
            if (healthDataRepo == null) {
                healthDataRepo = new VCR_HealthDataRepo('immunizations');
            }
            return healthDataRepo;
        }
        set;
    }

    /**
     * @description Get Immunizations by ICN
     * @param args - Auxiliary arguments to pass to the repo
     * @return VTC_DataModel - The data model containing the radiology data
     */
    @AuraEnabled(Cacheable=true)
    public static VTC_DataModel fetchImmunizations(Map<String, Object> args) {
        args.put('application', APPLICATION);

        try {
            return immunizationsRepo.fetchImmunizations(args);
        } catch (Exception caughtException) {
            Logger.error('Fetch orders came back with an exception: ', caughtException);
            Map<String, String> cmdMap = new Map<String, String>{
                'VTC_LimitException' => RETRY_CMD,
                'VTC_CalloutException' => RETRY_CMD,
                'VTC_TimeoutException' => RETRY_CMD
            };
            throw VCC_ExceptionUtils.createAuraHandledException(caughtException, cmdMap, NO_RETRY_CMD);
        } finally {
            Logger.saveLog();
        }
    }
    /**
     * @description - Gets Patient birthyear, and workstream settings, primarily used for the "load more" functionality of this HDR LWC
     * @param icn - ICN to query org against
     * @return Returns patient birthyear, and workstream settings
     */
    @AuraEnabled(Cacheable=true)
    public static VCR_HealthDataRepo.Model fetchHealthDataConfig(String icn) {
        healthDataRepo.setPatientByICN(icn);
        return healthDataRepo.fetchHealthDataConfig();
    }
}
