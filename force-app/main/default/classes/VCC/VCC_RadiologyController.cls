/**
 * @description Controller for Radiology component.
 * @author Booz Allen
 */
public with sharing class VCC_RadiologyController {
    @TestVisible
    private static final String APPLICATION = 'VAHC';

    @TestVisible
    private static final String RETRY_CMD = 'RETRY_CMD';

    @TestVisible
    private static final String NO_RETRY_CMD = 'NO_RETRY_CMD';

    /**
     * @description if a radiology repo doesn't exist yet, instantiate a radiology repo (responsible for interfacing with VTC)
     */
    @TestVisible
    private static VCR_RadiologyRepo radiologyRepo {
        get {
            return radiologyRepo = radiologyRepo ?? new VCR_RadiologyRepo();
        }
        set;
    }

    /**
     * @description instiates a labs health data repo
     */
    @TestVisible
    private static VCR_HealthDataRepo healthDataRepo {
        get {
            return healthDataRepo = healthDataRepo ?? new VCR_HealthDataRepo('radiology');
        }
        set;
    }

    /**
     * @description Get Radiology by ICN
     * @param args - Auxiliary arguments to pass to the repo
     * @return VTC_DataModel - The data model containing the radiology data
     */
    @AuraEnabled(Cacheable=true)
    public static VTC_DataModel fetchRadiology(Map<String, Object> args) {
        args.put('application', APPLICATION);

        try {
            return radiologyRepo.fetchRadiology(args);
        } catch (Exception excep) {
            Logger.error('Fetch orders came back with an exception: ', excep);
            Map<String, String> cmdMap = new Map<String, String>{
                'VTC_LimitException' => RETRY_CMD,
                'VTC_CalloutException' => RETRY_CMD,
                'VTC_TimeoutException' => RETRY_CMD
            };
            throw VCC_ExceptionUtils.createAuraHandledException(excep, cmdMap, NO_RETRY_CMD);
        } finally {
            Logger.saveLog();
        }
    }

    /**
     * @description - Gets Patient birthyear, and workstream settings, primarily used for the "load more" functionality of this HDR LWC
     * @param icn - patient identifier to query patient bday
     * @return Returns patient birthyear, and workstream settings
     * @see VCR_HealthDataRepo.Model
     */
    @AuraEnabled(Cacheable=true)
    public static VCR_HealthDataRepo.Model fetchHealthDataConfig(String icn) {
        if (String.isBlank(icn)) {
            return null;
        }
        healthDataRepo.setPatientByICN(icn);
        return healthDataRepo.fetchHealthDataConfig();
    }
}
