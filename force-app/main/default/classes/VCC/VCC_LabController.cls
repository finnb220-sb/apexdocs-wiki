/**
 * @description VCC Lab Controller
 * @author Booz Allen
 * @see `VCR_HealthDataRepo` to see the shape of the Health Data Config returned to LWC
 */
public with sharing class VCC_LabController {
    @TestVisible
    private static final String APPLICATION = 'VAHC';

    @TestVisible
    private static final String RETRY_CMD = 'RETRY_CMD';

    @TestVisible
    private static final String NO_RETRY_CMD = 'NO_RETRY_CMD';

    /**
     * @description if a lab repo doesn\'t exist yet, instantiate a lab repo (responsible for interfacing with VTC)
     */
    @TestVisible
    private static VCR_LabRepo labRepo {
        get {
            return labRepo = labRepo ?? new VCR_LabRepo();
        }
        set;
    }
    /**
     * @description instantiates a labs health data repo
     */
    @TestVisible
    private static VCR_HealthDataRepo healthDataRepo {
        get {
            return healthDataRepo = healthDataRepo ?? new VCR_HealthDataRepo('labs');
        }
        set;
    }

    /**
     * @description - Get Labs through VTC
     * @param args - Arguments for the labs VTC call
     * @return VTC_DataModel - The data model containing the labs data
     */
    @AuraEnabled(Cacheable=true)
    public static VTC_DataModel fetchLabs(Map<String, Object> args) {
        args.put('application', APPLICATION);
        args.put('type', 'CH,MI');
        try {
            return labRepo.fetchLabs(args);
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
