/**
 * @description VCC Vitals Controller
 * @author Booz Allen
 */
public with sharing class VCC_PatientVitalsController {
    @TestVisible
    private static final String APPLICATION = 'VAHC';

    @TestVisible
    private static final String RETRY_CMD = 'RETRY_CMD';

    @TestVisible
    private static final String NO_RETRY_CMD = 'NO_RETRY_CMD';

    @TestVisible
    /**
     * @description instantiation of vitals repo
     */
    private static VCR_VitalsRepo vitalsRepo {
        get {
            if (vitalsRepo == null) {
                vitalsRepo = new VCR_VitalsRepo();
            }
            return vitalsRepo;
        }
        set;
    }

    /**
     * @description instantiates a vitals health data repo
     */
    @TestVisible
    private static VCR_HealthDataRepo healthDataRepo {
        get {
            return healthDataRepo = healthDataRepo ?? new VCR_HealthDataRepo('vitals');
        }
        set;
    }

    /**
     * @description - Get vitals through VTC
     * @param args - Arguments for the vitals VTC call
     * @return VTC_DataModel - The data model containing the vitals data
     */
    @AuraEnabled(Cacheable=true)
    public static VTC_DataModel fetchVitals(Map<String, Object> args) {
        if (args == null || args.values().isEmpty()) {
            return null;
        }

        args.put('application', APPLICATION);
        try {
            return vitalsRepo.fetchVitals(args);
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
     * @param icn - ICN to query org against
     * @return Returns patient birthyear, and workstream settings
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
