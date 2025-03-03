/**
 * @description VCC Consult Controller
 * @author Booz Allen
 * @see `VCR_HealthDataRepo` to see the shape of the Health Data Config returned to LWC
 */
public with sharing class VCC_ConsultController {
    @TestVisible
    private static final String APPLICATION = 'VAHC';

    @TestVisible
    private static final String RETRY_CMD = 'RETRY_CMD';

    @TestVisible
    private static final String NO_RETRY_CMD = 'NO_RETRY_CMD';

    /**
     * @description if a consult repo doesn\'t exist yet, instantiate a consult repo (responsible for interfacing with VTC)
     */
    @TestVisible
    private static VCR_ConsultRepo consultRepo {
        get {
            return consultRepo = consultRepo ?? new VCR_ConsultRepo();
        }
        set;
    }
    /**
     * @description instiates a consults health data repo
     */
    @TestVisible
    private static VCR_HealthDataRepo healthDataRepo {
        get {
            return healthDataRepo = healthDataRepo ?? new VCR_HealthDataRepo('consults');
        }
        set;
    }

    /**
     * @description - Get Consults through VTC
     * @param args - Arguments for the consults VTC call
     * @return VTC_DataModel - The data model containing the consults data
     */
    @AuraEnabled(Cacheable=true)
    public static VTC_DataModel fetchConsults(Map<String, Object> args) {
        args.put('application', APPLICATION);
        try {
            return consultRepo.fetchConsults(args);
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
        healthDataRepo.setPatientByICN(icn);
        return healthDataRepo.fetchHealthDataConfig();
    }
}
