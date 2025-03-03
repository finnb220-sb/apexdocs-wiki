/**
 * @description Controller for HistoricalVisits component.
 * @author Booz Allen
 */
public with sharing class VCC_HistoricalVisitsController {
    @TestVisible
    private static final String APPLICATION = 'VAHC';

    @TestVisible
    private static final String RETRY_CMD = 'RETRY_CMD';

    @TestVisible
    private static final String NO_RETRY_CMD = 'NO_RETRY_CMD';
    /**
     * @description if a visit repo doesn\'t exist yet, instantiate a visit repo (responsible for interfacing with VTC)
     */
    @TestVisible
    private static VCR_VisitRepo visitRepo {
        get {
            if (visitRepo == null) {
                visitRepo = new VCR_VisitRepo();
            }
            return visitRepo;
        }
        set;
    }
    /**
     * @description instantiates a visits health data repo
     */
    @TestVisible
    private static VCR_HealthDataRepo healthDataRepo {
        get {
            return healthDataRepo = healthDataRepo ?? new VCR_HealthDataRepo('visits');
        }
        set;
    }

    /**
     * @description - Get Visits through VTC
     * @param args - Arguments for the visits VTC call
     * @return VTC_DataModel - The data model containing the visits data
     */
    @AuraEnabled(Cacheable=true)
    public static VTC_DataModel fetchVisits(Map<String, Object> args) {
        args.put('application', APPLICATION);

        try {
            return visitRepo.fetchVisits(args);
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
