/**
 * @description Check if a user (running user, or other specified user) can schedule
 * into a clinics grid by constructing this class and calling getResult()
 * @author Booz Allen Hamilton
 * @since 08/20/2024
 * @see `VCC_AppointmentSchedulingAccessCheckTest`
 * @see `VCC_ScheduleAppointmentController`
 */
public with sharing class VCC_AppointmentSchedulingAccessCheck {
    @TestVisible
    private static final String SITE_ID_KEY = 'siteId';
    @TestVisible
    private static final String CLINIC_IEN_KEY = 'clinicIEN';
    @TestVisible
    private static final String APPLICATION_KEY = 'application';
    @TestVisible
    private static final String MISSING_SITE_ID_MESSAGE = 'First argument "siteId" must not be null.';
    @TestVisible
    private static final String MISSING_CLINIC_IEN_MESSAGE = 'Second argument "clinicIen" must not be null.';
    @TestVisible
    private static final String MISSING_USER_ID_MESSAGE = 'Third argument "userId" must be non-null and for User SObjectType.';
    @TestVisible
    private static final String MISSING_CLINIC_REPO_MESSAGE = 'Fourth argument "clinicRepo" must be non-null and for VCR_ClinicRepo type';

    @TestVisible
    private String siteId;

    @TestVisible
    private String clinicIen;

    @TestVisible
    private Id userId;

    @TestVisible
    private VCC_Result savedResult;

    @TestVisible
    private VCR_ClinicRepo clinicRepo;

    /**
     * @description getter returning a memoized instance of VTC_RepoFactory
     */
    @TestVisible
    private static final VTC_RepoFactory repoFactory {
        get {
            //Memoized instance of Repo Factory
            return VTC_RepoFactory.repoFactory;
        }
    }

    /**
     * @description Enum with values denoting/indicating a users ability to schedule into a clinic
     */
    public enum VCC_Result {
        ALLOWED,
        DENIED
    }

    /**
     * @description empty no-arg constructor for testing
     *
     * @justification to make testing easier
     */
    @TestVisible
    private VCC_AppointmentSchedulingAccessCheck() {
        return;
    }

    /**
     * @description Construct an instance of VCC_AppointmentSchedulingAccessCheck with a vista site ID and
     * the clinic IEN to check if the running user can schedule into the clinic specified by the clinicIen
     * @param siteId the vista site ID
     * @param clinicIen the clinic IEN at the given site
     */
    public VCC_AppointmentSchedulingAccessCheck(String siteId, String clinicIen) {
        this(siteId, clinicIen, UserInfo.getUserId(), new VCR_ClinicRepo());
    }

    /**
     * @description Construct an instance of VCC_AppointmentSchedulingAccessCheck with a vista site ID and
     * the clinic IEN to check if the running user can schedule into the clinic specified by the clinicIen
     * @param siteId the vista site ID
     * @param clinicIen the clinic IEN at the given site
     * @param clinicRepo an instance of VCR_ClinicRepo to perform callouts for VTC_Clinic records
     */
    public VCC_AppointmentSchedulingAccessCheck(String siteId, String clinicIen, VCR_ClinicRepo clinicRepo) {
        this(siteId, clinicIen, UserInfo.getUserId(), clinicRepo);
    }

    /**
     * @description Construct an instance of VCC_AppointmentSchedulingAccessCheck with a vista site ID,
     * clinic IEN, and user Id to check if the given user can schedule into the clinic specified by the clinicIen
     * @param siteId the vista site ID
     * @param clinicIen the clinic IEN at the given site
     * @param userId the user Id to check
     * @param clinicRepo the repo class used to make VTC callouts for Clinic data
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public VCC_AppointmentSchedulingAccessCheck(String siteId, String clinicIen, Id userId, VCR_ClinicRepo clinicRepo) {
        if (siteId == null) {
            throw new IllegalArgumentException(MISSING_SITE_ID_MESSAGE);
        }
        if (clinicIen == null) {
            throw new IllegalArgumentException(MISSING_CLINIC_IEN_MESSAGE);
        }
        if (userId == null || userId.getSobjectType() != User.getSObjectType()) {
            throw new IllegalArgumentException(MISSING_USER_ID_MESSAGE);
        }
        if (clinicRepo == null) {
            throw new IllegalArgumentException(MISSING_CLINIC_REPO_MESSAGE);
        }
        this.clinicRepo = clinicRepo;
        this.clinicIen = clinicIen;
        this.siteId = siteId;
        this.userId = userId;
    }

    /**
     * @description Check running user access to schedule into the clinic
     * @return `VCC_Result` VCC_AppointmentSchedulingAccessCheck.Result.ALLOWED if user can schedule
     * an appoinemnt at the provided clinic. VCC_AppointmentSchedulingAccessCheck.VCC_Result.DENIED otherwise.
     */
    public VCC_Result getResult() {
        if (this.savedResult != null) {
            return this.savedResult;
        }
        VTC_Clinic clinic = this.getClinic();
        if (clinic.prohibitAccess == false) {
            return this.saveAndReturn(VCC_Result.ALLOWED);
        }
        List<VTC_PrivilegedUser> privilegedUsers = clinic?.privilegedUsers;
        if (privilegedUsers == null || privilegedUsers.isEmpty()) {
            return this.saveAndReturn(VCC_Result.DENIED);
        }
        String userDuzAtSite = this.getUserDuz();
        for (VTC_PrivilegedUser privilegedUser : privilegedUsers) {
            if (privilegedUser.ien == userDuzAtSite) {
                return this.saveAndReturn(VCC_Result.ALLOWED);
            }
        }
        return this.saveAndReturn(VCC_Result.DENIED);
    }

    @TestVisible
    private VCC_Result saveAndReturn(VCC_Result result) {
        this.savedResult = result;
        return result;
    }

    @TestVisible
    private String getUserDuz() {
        for (
            IAM_SSOi_Vista_Instance_to_User_DUZ__c vistaInstanceToUserDuz : ((VCR_IAMSSOiVistaInstToUserDUZRepo) repoFactory.createRepo(
                    'IAM_SSOi_Vista_Instance_to_User_DUZ__c',
                    'VCR_IAMSSOiVistaInstToUserDUZRepo'
                ))
                .fetchByUserId(this.userId)
        ) {
            if (vistaInstanceToUserDuz.VistA_Instance__c != this.siteId) {
                continue;
            }
            return vistaInstanceToUserDuz.DUZ__c;
        }
        return null;
    }

    @TestVisible
    private VTC_Clinic getClinic() {
        return (VTC_Clinic) clinicRepo.getClinicByIEN(
            new Map<String, Object>{
                SITE_ID_KEY => this.siteId,
                CLINIC_IEN_KEY => this.clinicIen,
                APPLICATION_KEY => 'VAHC'
            }
        );
    }
}
