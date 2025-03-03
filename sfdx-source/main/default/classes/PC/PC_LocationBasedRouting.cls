/**
 * @description Holds the driver method for NDTH Agreement routing logic for PC Cases (including proximity based tiebreaker that utilizes the FLP's Location Address and compares it in a distance formula with the available Specialist's Location Address)
 * @author      Booze Allen Hamiltons
 * @since       2024
 * @see         PC_LocationBasedRoutingHelper
 * @justification This class needs inherited sharing in order to inherit the sharing from the Flow that calls the PC_LocationBasedRoutingFlow class, which is the invokable action entry point for this class
 */
public inherited sharing class PC_LocationBasedRouting {
    /**
     * @description holds instantiation of the routing helper class
     */
    @TestVisible
    private static PC_LocationBasedRoutingHelper routingHelper {
        get {
            return routingHelper = routingHelper ?? new PC_LocationBasedRoutingHelper();
        }
        set;
    }

    /**
     * @description Retrieves the nearest available specialist's service resource based on the provided FLP's service location and selected specialty
     * @param referringProviderId   User Id of FLP (Referring Provider)
     * @param specialtyName         API name of the specialty
     * @return                      `String` nearest service resource user Id will be returned
     */
    public String getNearestAvailableSpecialist(String referringProviderId, String specialtyName) {
        if (String.isBlank(referringProviderId) || String.isBlank(specialtyName)) {
            String missingParameter = String.isBlank(referringProviderId) ? 'Referring Provider Id' : 'Specialty';
            PC_ExceptionUtils.logAndThrowIllegalArgumentError(
                'No ' + missingParameter + ' was provided to the getNearestAvailableSpecialist method.'
            );
        }

        ///suspend all saveLog calls within the try block so that we can combine and commit all logs generated into one saveLog call in the finally block
        Logger.suspendSaving();
        try {
            Set<Id> availableSpecialistUserIds = routingHelper.getAvailableSpecialistUserIds();

            Schema.Location flpServiceLocation = routingHelper.retrieveServiceLocationDetails(referringProviderId);

            Set<Id> applicableHostLocations = routingHelper.retrieveApplicableHostLocationsForServiceLocationAndSpecialty(
                flpServiceLocation?.Id,
                specialtyName
            );

            List<ServiceResourceSkill> applicableServiceResourceSkills = routingHelper.retrieveApplicableServiceResourceSkills(
                specialtyName,
                applicableHostLocations,
                availableSpecialistUserIds
            );

            List<PC_AvailableSpecialist> applicableSpecialistsSorted = createSortedSpecialistListFromApplicableServiceResourceSkills(
                applicableServiceResourceSkills,
                flpServiceLocation,
                applicableHostLocations
            );

            return applicableSpecialistsSorted.isEmpty()
                ? null
                : applicableSpecialistsSorted[0].getSpecialistResourceUserId();
        } finally {
            ///re-enable saveLog() and then save all logs (generated in the try block) into the database
            Logger.resumeSaving();
            Logger.saveLog();
        }
    }

    /**
     * @description                           generates a sorted list of available Specialists based on their current case load (capacity) and their distance from the given service location
     * @param applicableServiceResourceSkills service resource skills applicable to a PC Case submitted for routing that belong to a list of specialists
     * @param flpServiceLocation              Service Location of a PC Case from which the referring provider (FLP) submitted it
     * @param applicableHostLocations         locations of the applicable specialists
     * @return                                `List<PC_AvailableSpecialist>` sorted list of applicable specialists, with the best specialists sorted to the front based on current case load and distance to the service location
     */
    @TestVisible
    private List<PC_AvailableSpecialist> createSortedSpecialistListFromApplicableServiceResourceSkills(
        List<ServiceResourceSkill> applicableServiceResourceSkills,
        Schema.Location flpServiceLocation,
        Set<Id> applicableHostLocations
    ) {
        Map<Id, Double> userIdToTotalCapacityMap = routingHelper.retrieveCurrentAgentWorkCapacities();

        Map<Id, System.Location> hostLocationGeolocationMap = routingHelper.combineHostLocationsWithGeolocationData(
            applicableHostLocations
        );

        System.Location flpServiceLocationGeolocation = flpServiceLocation?.Latitude != null &&
            flpServiceLocation?.Longitude != null
            ? System.Location.newInstance(flpServiceLocation?.Latitude, flpServiceLocation?.Longitude)
            : null;

        list<PC_AvailableSpecialist> applicableSpecialistsToSort = new List<PC_AvailableSpecialist>();

        for (ServiceResourceSkill servResSkill : applicableServiceResourceSkills) {
            ServiceResource specialistServiceResource = new ServiceResource(
                Id = servResSkill?.ServiceResourceId,
                RelatedRecordId = servResSkill?.ServiceResource?.RelatedRecordId,
                PC_Location__c = servResSkill?.ServiceResource?.PC_Location__c
            );

            Double totalCapacityLoad = userIdToTotalCapacityMap.get(specialistServiceResource.RelatedRecordId);
            if (totalCapacityLoad >= PC_LocationBasedRoutingHelper.MAX_SPECIALIST_CAPACITY) {
                continue;
            }

            System.Location hostLocationGeolocationData = hostLocationGeolocationMap.get(
                servResSkill?.ServiceResource?.PC_Location__c
            );

            PC_AvailableSpecialist applicableSpecialist = new PC_AvailableSpecialist(
                specialistServiceResource,
                hostLocationGeolocationData,
                totalCapacityLoad
            );

            applicableSpecialist.calculateDistanceFromServiceLocation(flpServiceLocationGeolocation);

            applicableSpecialistsToSort.add(applicableSpecialist);
        }

        //sort so that the most applicable specialist moves to the 0 index position
        applicableSpecialistsToSort.sort();
        return applicableSpecialistsToSort;
    }
}
