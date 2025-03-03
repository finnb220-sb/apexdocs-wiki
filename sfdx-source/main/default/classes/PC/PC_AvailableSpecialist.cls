/**
 * @description Represents an available specialist that is a possible candidate for assignment to a PrC Case based on NDTH routing rules.
 *              This class implements the comparable interface to sort for the best specialist out of a list (checks current case-load via total Agent Work Capacity and distance to the Service Location)
 * @author      Booz Allen Hamilton
 * @see         PC_LocationBasedRoutingHelper
 */
public with sharing class PC_AvailableSpecialist implements Comparable {
    @TestVisible
    private static final Double MAX_DISTANCE = 99999; //larger distance than entire Earth circumference
    @TestVisible
    private static final String DISTANCE_UNIT = 'mi'; //miles

    private ServiceResource specialistResource;
    private System.Location hostLocationGeolocation;
    private Double currentCapacityLoad;
    private Double distanceMiles;

    /**
     * @description Constructor for the PC_AvailableSpecialist object
     * @param specialistResource        The ServiceResource for the available specialist
     * @param hostLocationGeolocation   System.Location that holds the geolocation data (lat/long) of the specialist host location
     * @param currentCapacityLoad       The current capacity weight total sum of all open PrC Cases the specialist is currently assigned
     */
    public PC_AvailableSpecialist(
        ServiceResource specialistResource,
        System.Location hostLocationGeolocation,
        Double currentCapacityLoad
    ) {
        this.specialistResource = specialistResource;
        this.hostLocationGeolocation = hostLocationGeolocation;
        this.currentCapacityLoad = currentCapacityLoad ?? 0;
        this.distanceMiles = MAX_DISTANCE;
    }

    /**
     * @description gets the RelatedRecordId (User) of the Service Resource
     * @return      `String` Id of the User tied to the Service Resource
     */
    public String getSpecialistResourceUserId() {
        return specialistResource?.RelatedRecordId;
    }

    /**
     * @description calculates the distance as the crow flies from the Specialist's host location geolocation and the provided service location geolocation
     * @param serviceLocationGeolocation latitude/longitude geolocation data for the service location
     * @return                           `Double` distance in miles between the two locations
     */
    public Double calculateDistanceFromServiceLocation(System.Location serviceLocationGeolocation) {
        this.distanceMiles = this.hostLocationGeolocation != null &&
            serviceLocationGeolocation != null
            ? System.Location.getDistance(this.hostLocationGeolocation, serviceLocationGeolocation, DISTANCE_UNIT)
            : MAX_DISTANCE;

        return this.distanceMiles;
    }

    /**
     * @description comparable implementation to sort the available specialists by current case-load and then distance to the service location
     * @param compareTo  `PC_AvailableSpecialist` object to compare to
     * @return          `Integer` -1 if this is less than the compareTo object, 1 if greater, and 0 if equal
     */
    public Integer compareTo(Object compareTo) {
        PC_AvailableSpecialist compareToAvailSpecialist = (PC_AvailableSpecialist) compareTo;

        //compare current capacity (active case-load)
        if (this.currentCapacityLoad < compareToAvailSpecialist.currentCapacityLoad) {
            return -1;
        } else if (this.currentCapacityLoad > compareToAvailSpecialist.currentCapacityLoad) {
            return 1;
        }

        // Compare distance to service location if current capacities are equal
        if (this.distanceMiles < compareToAvailSpecialist.distanceMiles) {
            return -1;
        } else if (this.distanceMiles > compareToAvailSpecialist.distanceMiles) {
            return 1;
        }

        // Both fields are equal
        return 0;
    }
}
