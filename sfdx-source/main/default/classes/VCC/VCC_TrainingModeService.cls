/**
 * @deprecated Training Mode code is no longer maintained in va-teams. Future work to remove.
 * @description Used in training mode to do something.
 * @author Patrick Skamarak
 * @since 02/12/2024 - CCCM-28188, security remediation
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public without sharing class VCC_TrainingModeService {
    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @return null or void
     */
    public static String isValidEsigBase() {
        return null;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @return null or void
     */
    public static String signNoteBase() {
        return null;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @return null or void
     */
    public static String writeNoteBase() {
        return null;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @return null or void
     * @param accountId the account Id
     */
    public static String getAllergiesByAccountId(String accountId) {
        return null;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @return null or void
     * @param accountId the account Id
     */
    public static String getAppointmentsByAccountId(String accountId) {
        return '{}';
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @return null or void
     * @param accountId the account Id
     */
    public static String getConsultsByAccountId(String accountId) {
        return null;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @return null or void
     * @param accountId the account Id
     */
    public static String getDirectives(String accountId) {
        return null;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @return null or void
     * @param accountId the account Id
     */
    public static String getDischargeSummariesByAccountId(String accountId) {
        return null;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @return null or void
     * @param accountId the account Id
     */
    public static String getFlagsByAccountId(String accountId) {
        return null;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @return null or void
     * @param accountId the account Id
     */
    public static String getImagingByAccountId(String accountId) {
        return null;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @return null or void
     * @param accountId the account Id
     */
    public static String getImmunizationsByAccountId(String accountId) {
        return null;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @return null or void
     * @param accountId the account Id
     */
    public static String getLabsByAccountId(String accountId) {
        return null;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @return null or void
     * @param accountId the account Id
     */
    public static String getMedicationsByAccountId(String accountId) {
        return null;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @param refill list of refill objects
     */
    public static void refillMedications(List<Object> refill) {
        return;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @param recordId the record Id
     * @param refillRequests list of refill requests
     */
    public static void refillMedications(String recordId, List<VCC_MedsService.MedRefillRequest> refillRequests) {
        return;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @param recordId the record Id
     * @param refillRequests list of refill requests
     * @param uow fflib unit of work
     */
    public static void refillMedications(String recordId, List<VCC_MedsService.MedRefillRequest> refillRequests, fflib_ISObjectUnitOfWork uow) {
        return;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @return null or void
     * @param accountId the account Id
     */
    public static String getOrdersByAccountId(String accountId) {
        return null;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @return null or void
     * @param accountId the account Id
     */
    public static String getPACTDataByAccountId(String accountId) {
        return null;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @return null or void
     * @param accountId the account Id
     */
    public static String getProblemsByAccountId(String accountId) {
        return null;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @return null or void
     * @param accountId the account Id
     */
    public static String getProgressNotesByAccountId(String accountId) {
        return null;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @param progressNoteId the account Id
     */
    public static void signProgressNote(Id progressNoteId) {
        return;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @param progressNoteId the account Id
     * @param uow fflib unit of work
     */
    public static void signProgressNote(Id progressNoteId, fflib_ISObjectUnitOfWork uow) {
        return;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @return null or void
     * @param accountId the account Id
     */
    public static String getVetInfoByAccountId(String accountId) {
        return null;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @param accountId the account Id
     * @param writeVetInfoRQ info to write
     */
    public static void writeVetInfo(Id accountId, WriteVetInfoRQ writeVetInfoRQ) {
        return;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @param accountId the account Id
     * @param writeVetInfoRQ info to write
     * @param uow fflib unit of work
     */
    public static void writeVetInfo(Id accountId, WriteVetInfoRQ writeVetInfoRQ, fflib_ISObjectUnitOfWork uow) {
        return;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description an unused class in va-teams Training Mode
     */
    @SuppressWarnings('PMD.ClassNamingConventions')
    public class WriteVetInfoRQ {
        @SuppressWarnings('PMD.FieldNamingConventions')
        public String id;
        public String idType;
        public String userId;
        public List<VCC_MPIParser.EEAssociation> eeAssociations;

        /**
         * @deprecated no longer maintained in va-teams
         * @description a constructor
         */
        public WriteVetInfoRQ() {
            return;
        }

        /**
         * @deprecated no longer maintained in va-teams
         * @description a constructor
         * @param eeAssociations
         */
        public WriteVetInfoRQ(List<VCC_MPIParser.EEAssociation> eeAssociations) {
            return;
        }
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @return null or void
     * @param accountId the account Id
     */
    public static String getVisitsByAccountId(String accountId) {
        return null;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @return null or void
     * @param accountId the account Id
     */
    public static String getVitalsByAccountId(String accountId) {
        return null;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @return false
     */
    public static Boolean isTrainingModeEnabled() {
        return false;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @param userIds set of user id's
     */
    public static void resetTrainingDataForUsers(Set<Id> userIds) {
        return;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @param userIds set of user id's
     * @param uow fflib unit of work
     */
    public static void resetTrainingDataForUsers(Set<Id> userIds, fflib_ISObjectUnitOfWork uow) {
        return;
    }

    @TestVisible
    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @param userIds
     */
    private static void deleteTrainingDataForUsers(Set<Id> userIds) {
        return;
    }

    @TestVisible
    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @param userIds
     * @param uow
     */
    private static void createTrainingDataForUsers(Set<Id> userIds, fflib_ISObjectUnitOfWork uow) {
        return;
    }

    @TestVisible
    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @param trainingModeDataTemplates
     * @param uow
     */
    private static void createMasterTrainingData(List<StaticResource> trainingModeDataTemplates, fflib_ISObjectUnitOfWork uow) {
        return;
    }

    @TestVisible
    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @param user
     * @param trainingModeDataTemplates
     * @param uow
     */
    private static void createTrainingDataForUser(User user, List<StaticResource> trainingModeDataTemplates, fflib_ISObjectUnitOfWork uow) {
        return;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @return null or void
     * @param recordIdOrPrefix
     */
    public static String getObjectNameFromId(String recordIdOrPrefix) {
        return null;
    }

    /**
     * @deprecated no longer maintained in va-teams
     * @description a deprecated training mode method
     * @return null or void
     * @param recordId
     */
    public static String getAccountId(String recordId) {
        return null;
    }
}
