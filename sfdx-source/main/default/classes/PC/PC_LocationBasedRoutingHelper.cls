/**
 * @description Helper class that is responsible for aiding PC_LocationBasedRouting with its calculation of the nearest specialist for NDTH agreement routing
 * @author      Booz Allen Hamilton
 * @see         PC_LocationBasedRouting
 * @justification This class needs inherited sharing in order to inherit the sharing from the Flow that calls the PC_LocationBasedRoutingFlow class, which is the invokable action entry point for this class
 */
public inherited sharing class PC_LocationBasedRoutingHelper {
    @TestVisible
    private static final Integer DEFAULT_MAX_CAPACITY = 20;

    public static final Integer MAX_SPECIALIST_CAPACITY;

    static {
        //try to get capacity value for MAX_SPECIALIST_CAPACITY from PC_Specialist Presence Configuration, otherwise default to 20
        try {
            PresenceUserConfig specialistConfig = presenceUserConfigRepo.fetchPresenceUserConfigByDeveloperName(
                'PC_Specialists'
            );
            MAX_SPECIALIST_CAPACITY = specialistConfig?.Capacity ?? DEFAULT_MAX_CAPACITY;
        } catch (QueryException caughtQException) {
            MAX_SPECIALIST_CAPACITY = DEFAULT_MAX_CAPACITY;
            Logger.warn(
                'Failed to retrieve max Capacity value from the PC_Specialist Presence Configuration. Defaulted to ' +
                    DEFAULT_MAX_CAPACITY +
                    ' instead.',
                caughtQException
            );
        }
    }

    /**
     * @description repository for the PrC User detail object
     */
    @TestVisible
    private static PC_PrcUserRepo prcUserDetailRepo {
        get {
            return prcUserDetailRepo = prcUserDetailRepo ?? new PC_PrcUserRepo();
        }
        set;
    }

    /**
     * @description repository for the User SErvice Presence object
     */
    @TestVisible
    private static PC_UserServicePresenceRepo userServicePresenceRepo {
        get {
            return userServicePresenceRepo = userServicePresenceRepo ?? new PC_UserServicePresenceRepo();
        }
        set;
    }

    /**
     * @description repository for Agent Work object
     */
    @TestVisible
    private static PC_AgentWorkRepo agentWorkRepo {
        get {
            return agentWorkRepo = agentWorkRepo ?? new PC_AgentWorkRepo();
        }
        set;
    }

    /**
     * @description repository for the NDTH Service Location object
     */
    @TestVisible
    private static PC_NDTHServiceLocationRepo ndthServiceLocationRepo {
        get {
            return ndthServiceLocationRepo = ndthServiceLocationRepo ?? new PC_NDTHServiceLocationRepo();
        }
        set;
    }

    /**
     * @description repository for the NDTH Host Location object
     */
    @TestVisible
    private static PC_NDTHHostLocationRepo ndthHostLocationRepo {
        get {
            return ndthHostLocationRepo = ndthHostLocationRepo ?? new PC_NDTHHostLocationRepo();
        }
        set;
    }

    /**
     * @description repository for the NDTH Clinical Services object
     */
    @TestVisible
    private static PC_NDTHClinicalServicesRepo ndthClinicalServiceRepo {
        get {
            return ndthClinicalServiceRepo = ndthClinicalServiceRepo ?? new PC_NDTHClinicalServicesRepo();
        }
        set;
    }

    /**
     * @description repository for the VAF Address object
     */
    @TestVisible
    private static VCR_VAFAddressRepo vafAddressRepo {
        get {
            return vafAddressRepo = vafAddressRepo ?? new VCR_VAFAddressRepo();
        }
        set;
    }

    /**
     * @description repository for the Address object
     */
    @TestVisible
    private static VCR_AddressRepo addressRepo {
        get {
            return addressRepo = addressRepo ?? new VCR_AddressRepo();
        }
        set;
    }

    /**
     * @description repository for the Service Resource Skill object
     */
    @TestVisible
    private static VCR_ServiceResourceSkillRepo serviceResourceSkillRepo {
        get {
            return serviceResourceSkillRepo = serviceResourceSkillRepo ?? new VCR_ServiceResourceSkillRepo();
        }
        set;
    }

    /**
     * @description repository for the Presence User Config object
     */
    @TestVisible
    private static VCR_PresenceUserConfigRepo presenceUserConfigRepo {
        get {
            return presenceUserConfigRepo = presenceUserConfigRepo ?? new VCR_PresenceUserConfigRepo();
        }
        set;
    }

    /**
     * @description gets a list of Salesforce User Ids for Specialists that are currently online and available in Omni-channel
     * @return      `Set<Id>` List of Salesforce User Ids available in omni-channel
     * @exception   QueryException UserServicePresence query failure
     */
    public Set<Id> getAvailableSpecialistUserIds() {
        Set<Id> availableSpecialistUserIds = new Set<Id>();

        try {
            for (UserServicePresence presence : userServicePresenceRepo.getCurrentUserServicePresence()) {
                availableSpecialistUserIds.add(presence.UserId);
            }
        } catch (QueryException qException) {
            PC_ExceptionUtils.logAndThrowError(qException.getMessage(), qException);
        }

        if (availableSpecialistUserIds.isEmpty()) {
            PC_ExceptionUtils.logAndThrowError('There are currently no specialists available in Omni-channel.');
        }

        return availableSpecialistUserIds;
    }

    /**
     * @description Retrieves the FLP's service location's Id and geolocation data (lat/long)
     * @param flpUserId the referring provider who initiated the routing request
     * @return          `Schema.Location` Location object with Id and Latitude/Longitude information
     * @exception       QueryException catch, log and re-throw queryExceptions from PrC User Detail query
     */
    public Schema.Location retrieveServiceLocationDetails(String flpUserId) {
        if (String.isBlank(flpUserId)) {
            PC_ExceptionUtils.logAndThrowIllegalArgumentError(
                'No referring FLP User Id was provided to the retrieveServiceLocationDetails method'
            );
        }

        List<PC_User__c> prcUserDetails;
        try {
            prcUserDetails = prcUserDetailRepo.fetchPrcUserByUserId(flpUserId);
        } catch (QueryException caughtQueryException) {
            PC_ExceptionUtils.logAndThrowError(caughtQueryException.getMessage(), caughtQueryException);
        }

        if (prcUserDetails.isEmpty() || prcUserDetails[0].Current_Location__c == null) {
            PC_ExceptionUtils.logAndThrowError(
                'The referring FLP has not selected a current service location so routing calculations cannot begin.'
            );
        }

        Schema.Location referrerServiceLocation = new Schema.Location(
            Id = prcUserDetails?.get(0)?.Current_Location__c,
            Latitude = prcUserDetails?.get(0)?.Latitude__c,
            Longitude = prcUserDetails?.get(0)?.Longitude__c
        );
        return referrerServiceLocation;
    }

    /**
     * @description Retrieves a list of host locations available for NDTH routing via current NDTH Agreement rules based on the provided service location and specialty
     * @param serviceLocationId Location Id of the FLP's service location
     * @param specialty         Specialty (Skill) requested
     * @return `Set<Id>`        Set of possible host locations
     * @exception QueryException exception thrown by NDTH rule junction object queries (NDTH Service Locations, NDTH Clinical Services, NDTH Host Locations)
     */
    public Set<Id> retrieveApplicableHostLocationsForServiceLocationAndSpecialty(
        Id serviceLocationId,
        String specialty
    ) {
        if (String.isBlank(serviceLocationId) || String.isBlank(specialty)) {
            String missingParameter = String.isBlank(serviceLocationId) ? 'Service Location Id' : 'Specialty';
            PC_ExceptionUtils.logAndThrowIllegalArgumentError(
                'No ' +
                    missingParameter +
                    ' was provided to the retrieveApplicableHostLocationsForServiceLocationAndSpecialty method.'
            );
        }

        Set<Id> applicableHostLocations = new Set<Id>();
        try {
            Set<Id> serviceLocationNDTHs = new Set<Id>();
            for (
                PC_NDTH_Service_Locations__c serviceLocation : ndthServiceLocationRepo.getNDTHServiceLocsFromLocId(
                    serviceLocationId
                )
            ) {
                serviceLocationNDTHs.add(serviceLocation.NDTH__c);
            }

            Set<Id> applicableNDTHs = new Set<Id>();
            for (
                PC_NDTH_Clinical_Services__c clinicalService : ndthClinicalServiceRepo.getClinicalServicesFromNDTHsandSkills(
                    serviceLocationNDTHs,
                    specialty
                )
            ) {
                applicableNDTHs.add(clinicalService.NDTH__c);
            }

            for (
                PC_NDTH_Host_Locations__c hostlocation : ndthHostLocationRepo.getHostLocationsFromNDTHs(applicableNDTHs)
            ) {
                applicableHostLocations.add(hostlocation.Location__c);
            }
        } catch (QueryException caughtQueryException) {
            PC_ExceptionUtils.logAndThrowError(caughtQueryException.getMessage(), caughtQueryException);
        }

        if (applicableHostLocations.isEmpty()) {
            PC_ExceptionUtils.logAndThrowError(
                'No applicable Host Locations were found under any available NDTH Agreements for the requested specialty and service location (' +
                    specialty +
                    '|' +
                    serviceLocationId +
                    ')'
            );
        }

        return applicableHostLocations;
    }

    /**
     * @description retrieves a list of service resource skill junctions that satisfy the required criteria for NDTH routing to the provided host locations for the provided specialty
     * @param specialty                     Specialty (Skill) required by Specialist
     * @param hostLocations                 List of possible host locations required by Specialist
     * @param availableSpecialistUserIds    List of all available specialists (provided to reduce query rows so only Specialists active in omni-channel are considered)
     * @return `List<ServiceResourceSkill>` List of Service Resource Skills that satisfy the above criteria
     * @exception QueryException            Exception thrown by Service Resource Skill junction object query
     */
    public List<ServiceResourceSkill> retrieveApplicableServiceResourceSkills(
        String specialty,
        Set<Id> hostLocations,
        Set<Id> availableSpecialistUserIds
    ) {
        if (String.isBlank(specialty) || hostLocations == null || availableSpecialistUserIds == null) {
            String missingParameter = String.isBlank(specialty)
                ? 'Specialty'
                : (hostLocations == null ? 'Host Location Set' : 'Available Specialist User Id Set');
            PC_ExceptionUtils.logAndThrowIllegalArgumentError(
                'A valid ' +
                    missingParameter +
                    ' was not provided to the retrieveApplicableHostLocationsForServiceLocationAndSpecialty method.'
            );
        }

        List<ServiceResourceSkill> applicableServiceResourceSkills = new List<ServiceResourceSkill>();
        try {
            applicableServiceResourceSkills.addAll(
                serviceResourceSkillRepo.getServiceResourceSkillsApplicableToNDTHRoutingCriteria(
                    specialty,
                    hostLocations,
                    availableSpecialistUserIds
                )
            );
        } catch (QueryException caughtException) {
            PC_ExceptionUtils.logAndThrowError(caughtException.getMessage(), caughtException);
        }

        return applicableServiceResourceSkills;
    }

    /**
     * @description retrieves a Map of Specialist User Ids to their aggregated total Capacity for all open PrC Cases they are assigned
     * @return      `Map<Id, Double>` Salesforce User Id (Specialist) to their total capacity load
     * @exception   QueryException Agent Work Aggregate query failure
     */
    public Map<Id, Double> retrieveCurrentAgentWorkCapacities() {
        List<PC_AgentWorkRepo.AgentWorkCapacityWrapper> openAgentWorks;
        try {
            openAgentWorks = agentWorkRepo.getAgentWorkCapacity();
        } catch (QueryException caughtQueryException) {
            PC_ExceptionUtils.logAndThrowError(caughtQueryException.getMessage(), caughtQueryException);
        }

        Map<Id, Double> userIdToTotalCapacityMap = new Map<Id, Double>();
        for (PC_AgentWorkRepo.AgentWorkCapacityWrapper work : openAgentWorks) {
            userIdToTotalCapacityMap.put(work.userId, work.totalCapacity);
        }

        return userIdToTotalCapacityMap;
    }

    /**
     * @description gets address geolocation data related to the provided host locations for distance calculations
     * @param hostLocationIds               Set of Host Location Ids
     * @return `Map<Id, System.Location>`   Map of Host location Id to its associated geolocation data
     * @exception QueryException            Exception thrown by VAF Address and/or standard Address queries
     */
    public Map<Id, System.Location> combineHostLocationsWithGeolocationData(Set<Id> hostLocationIds) {
        if (hostLocationIds == null || hostLocationIds.isEmpty()) {
            PC_ExceptionUtils.logAndThrowIllegalArgumentError(
                'No Host Location Ids were provided to the combineHostLocationsWithGeolocationData method'
            );
        }

        Map<Id, System.Location> hostGeolocationDataMap = new Map<Id, System.Location>();
        try {
            Map<Id, VAF_Address__c> locationIdToVafAddress = vafAddressRepo.getMapOfLocIdToVafAddress(hostLocationIds);
            Map<Id, Schema.Address> locationIdToAddress = addressRepo.getMapOfLocIdToAddress(hostLocationIds);

            for (Id hostLocationId : hostLocationIds) {
                SObject addressObj = locationIdToVafAddress.containsKey(hostLocationId)
                    ? (SObject) locationIdToVafAddress.get(hostLocationId)
                    : (SObject) locationIdToAddress.get(hostLocationId);

                if (
                    addressObj == null ||
                    addressObj.get('VAF_Latitude__c') == null ||
                    addressObj.get('VAF_Longitude__c') == null
                ) {
                    Logger.info('The following Location is missing Address geolocation data: ' + hostLocationId);
                    continue;
                }

                System.Location hostLocationGeolocation = System.Location.newInstance(
                    (Double) addressObj.get('VAF_Latitude__c'),
                    (Double) addressObj.get('VAF_Longitude__c')
                );

                hostGeolocationDataMap.put(hostLocationId, hostLocationGeolocation);
            }
        } catch (QueryException caughtQueryException) {
            PC_ExceptionUtils.logAndThrowError(caughtQueryException.getMessage(), caughtQueryException);
        }

        return hostGeolocationDataMap;
    }
}
