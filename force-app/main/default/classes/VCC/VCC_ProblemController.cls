/**
 * @description Controller for Problems component.
 * @author Booz Allen
 * @see `VCR_ProblemRepo` to see the shape of the Problems Data Config returned to LWC
 */
public with sharing class VCC_ProblemController {
    @TestVisible
    private static final String APPLICATION = 'VAHC';

    @TestVisible
    private static final String RETRY_CMD = 'RETRY_CMD';

    @TestVisible
    private static final String NO_RETRY_CMD = 'NO_RETRY_CMD';

    /**
     * @description instantiates the problems repo
     */
    @TestVisible
    private static VCR_ProblemRepo problemRepo {
        get {
            if (problemRepo == null) {
                problemRepo = new VCR_ProblemRepo();
            }
            return problemRepo;
        }
        set;
    }

    /**
     * @description instantiates a problems health data repo
     */
    @TestVisible
    private static VCR_HealthDataRepo healthDataRepo {
        get {
            if (healthDataRepo == null) {
                healthDataRepo = new VCR_HealthDataRepo('problems');
            }
            return healthDataRepo;
        }
        set;
    }

    /**
     * @description Get Problems by ICN
     * @param args - Auxiliary arguments to pass to the repo
     * @return VTC_DataModel - The data model containing the problems data
     */
    @AuraEnabled(Cacheable=true)
    public static VTC_DataModel fetchProblems(Map<String, Object> args) {
        args.put('application', APPLICATION);

        try {
            return problemRepo.fetchProblems(args);
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
