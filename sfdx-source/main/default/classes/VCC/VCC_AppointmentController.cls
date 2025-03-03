/**
 * @description VCC Appointments Controller
 * @author Booz Allen
 * @see `VCR_HealthDataRepo` to see the shape of the Health Data Config returned to LWC
 */
public with sharing class VCC_AppointmentController {
    @TestVisible
    private static final String APPLICATION = 'VAHC';

    @TestVisible
    private static final String RETRY_CMD = 'RETRY_CMD';

    @TestVisible
    private static final String NO_RETRY_CMD = 'NO_RETRY_CMD';

    /**
     * @description - Initialize VCR_AppointmentsRepo
     */
    @TestVisible
    private static VCR_AppointmentsRepo appointmentsRepo {
        get {
            if (appointmentsRepo == null) {
                appointmentsRepo = new VCR_AppointmentsRepo();
            }
            return appointmentsRepo;
        }
        set;
    }

    /**
     * @description instantiates a appointments health data repo
     */
    @TestVisible
    private static VCR_HealthDataRepo healthDataRepo {
        get {
            if (healthDataRepo == null) {
                healthDataRepo = new VCR_HealthDataRepo('appointments');
            }
            return healthDataRepo;
        }
        set;
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

    /**
     * @description - Get Appointments through VTC
     * @param args - Arguments for the appointments VTC call
     * @return VTC_DataModel - The data model containing the appointments data
     */
    @AuraEnabled(Cacheable=true)
    public static VTC_DataModel fetchAppointments(Map<String, Object> args) {
        args.put('application', APPLICATION);
        try {
            return appointmentsRepo.fetchAppointments(args);
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
}
