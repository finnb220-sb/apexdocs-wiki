/**
 * @description VCC Directives Controller
 * @author Booz Allen
 */
public with sharing class VCC_DirectivesController {
    @TestVisible
    private final static String ASSIGNING_AUTHORITY = 'USVHA';
    @TestVisible
    private final static String APPLICATION = 'VAHC';

    /**
     * @description if a directives Repo  doesn\'t exist yet, instantiate a directives repo (responsible for interfacing with VTC)
     */
    @TestVisible
    private static VCR_DirectivesRepo directivesRepo {
        get {
            if (directivesRepo == null) {
                directivesRepo = new VCR_DirectivesRepo();
            }
            return directivesRepo;
        }
        set;
    }
    /**
     * @description instiates a directives health data repo
     */
    @TestVisible
    private static VCR_HealthDataRepo healthDataRepo {
        get {
            if (healthDataRepo == null) {
                healthDataRepo = new VCR_HealthDataRepo('directives');
            }
            return healthDataRepo;
        }
        set;
    }

    /**
     * @description - Get Directives through VTC
     * @param args The arguments to pass to the provider - ICN/National Id, max number to return, start date and end date of data to return
     * @return `VTC_DataModel` - The data model containing the Directives data
     */
    @AuraEnabled(Cacheable=true)
    public static VTC_DataModel fetchDirectives(Map<String, Object> args) {
        args.put('application', APPLICATION);
        args.put('noteType', VTC_NoteType.ADVANCE_DIRECTIVE);
        try {
            return directivesRepo.getDirectives(args);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
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
