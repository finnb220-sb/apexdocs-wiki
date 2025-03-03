/**
 * @description Responsible for all CRUD operations on HDR data.
 * @author Booz Allen
 * @justification This class is designed to encapsulate all CRUD operations on the Account object. At times, this means the methods in this class may need to be run in a `without sharing` context.
 *      However, the goal is to minimize those as much as possible. Therefore, this class is marked as `inherited sharing`. This allows the calling code to dictate the sharing context in which the methods are run.
 */
public virtual inherited sharing class VCR_HealthDataRepo {
    @TestVisible
    private static final String NULL_OR_EMPTY_ICN_ERROR_MSG = 'ICN passed into \'setPatientByIcn\' was blank. Cannot search for patient with a null or empty ICN.';

    @TestVisible
    private static final String WRONG_NUMBER_OF_PATIENTS_RETURNED_FROM_ICN_MSG = 'Retrieving patient by ICN returned an incorrect number of results. Expected 1. Actual: ';

    @TestVisible
    private Account patientAccount;
    @TestVisible
    private VCC_WorkstreamSettingsController.VCC_Model workstreamSettings;

    /**
     * @description Workstream Settings Controller returns a modeled version of workstream settings. If adding another workstream settings property reference the inner class VCC_WorkstreamSettingsController.VCC_Model
     */
    @TestVisible
    private static VCC_WorkstreamSettingsController workstreamSettingsController {
        get {
            if (workstreamSettingsController == null) {
                workstreamSettingsController = new VCC_WorkstreamSettingsController();
            }
            return workstreamSettingsController;
        }
        set;
    }

    /**
     * @description Account repo
     */
    @TestVisible
    private static VCR_AccountRepo accountRepo {
        get {
            if (accountRepo == null) {
                accountRepo = new VCR_AccountRepo();
            }
            return accountRepo;
        }
        set;
    }

    /**
     * @description Constructor for the VCR_HealthDataRepo
     * @param healthDataType The type of health data we are working with
     */
    public VCR_HealthDataRepo(String healthDataType) {
        this.workstreamSettings = workstreamSettingsController.getSettingsInMemory(healthDataType);
    }

    /**
     * @description returns an easy to use shape to be consumed by the "vccLab" LWC.
     * @return `Model` Model object to be consumed by the vccLab lwc.
     */
    public Model fetchHealthDataConfig() {
        return new Model().setAccountDOB(this.patientAccount).setWorkstreamSettings(this.workstreamSettings);
    }

    /**
     * @description Given a patient ICN, Go find the person account in our DB that corresponds to it.
     * Then set the internal patientAccount field to it.
     * @param icn `String` ICN that corresponds to the current patient.
     * @throws VCC_InvalidArgumentException If a null or blank ICN is passed to the method.
     * @throws VCC_InvalidArgumentException If the wrong number of Patients are returned from our query.
     */
    public void setPatientByICN(String icn) {
        if (String.isBlank(icn)) {
            throw new VCC_InvalidArgumentException(NULL_OR_EMPTY_ICN_ERROR_MSG);
        }

        List<Account> personAccountsWithICN = accountRepo.fetchPersonAccountsViaICN(new Set<String>{ icn });

        if (personAccountsWithICN.size() != 1) {
            throw new VCC_InvalidArgumentException(
                WRONG_NUMBER_OF_PATIENTS_RETURNED_FROM_ICN_MSG + personAccountsWithICN.size()
            );
        }

        this.patientAccount = personAccountsWithICN[0];
    }

    /**
     * @description Model for this class that's returned to the UI e.g. by the vccLab LWC
     */
    public class Model {
        /**
         * @description Patient's birth year
         */
        @AuraEnabled
        public String patientBirthYear { get; set; }
        /**
         * @description Workstream Settings
         */
        @AuraEnabled
        public VCC_WorkstreamSettingsController.VCC_Model workstreamSettings { get; set; }
        /**
         * @description The start year for the callout
         */
        @AuraEnabled
        public String calloutStartYear { get; set; }
        /**
         * @description The end year for the callout
         */
        @AuraEnabled
        public String calloutEndYear { get; set; }

        /**
         * @description setting account date of birth
         * @param acct  patient account
         * @return      `Model`
         */
        public Model setAccountDOB(Account acct) {
            if (acct?.Date_of_Birth__pc != null) {
                this.patientBirthYear = acct.Date_of_Birth__pc.split('/')[2];
            } else {
                this.patientBirthYear = null;
            }
            return this;
        }
        /**
         * @description  set workstream settings (start and end year)
         * @param settings workstream settings
         * @return         `Model`
         */
        public Model setWorkstreamSettings(VCC_WorkstreamSettingsController.VCC_Model settings) {
            this.calloutStartYear = settings?.startDate.split('/')[2];
            this.calloutEndYear = settings?.endDate.split('/')[2];
            this.workstreamSettings = settings;
            return this;
        }
    }
}
