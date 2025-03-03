/**
 * @description Class for holding a Map of Territory Member keys to a Tuple of Confirmed and All appointment VCC_TimeSlotCollections.
 * The tuple holds the Completed appointments in its `key` property and the collection of all appointments in its `value` property.
 *
 * @see VCC_TwoTuple
 * @see VCC_TimeSlotCollection
 * @see VCC_TimeSlot
 * @see VCC_AppointmentUtilizationService
 */
public with sharing class VCC_TerritoryMemberToAppointmentsMap {
    @TestVisible
    private Map<VCC_TerritoryMemberKey, VCC_TwoTuple> territoryMemberKeyToCompletedNonCompletedApptsMap;
    @TestVisible
    private static final String COMPLETED = 'Completed';
    @TestVisible
    private static final String INVALID_APPOINTMENT_EXCEPTION = 'Cannot calculate utilization for an appointment that is not assigned a ServiceResource!';

    private Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection> territoryMemberKeyToUsedApptsMap;

    /**
     * @description Constructor that instantiates the resultant map.
     */
    public VCC_TerritoryMemberToAppointmentsMap() {
        this.territoryMemberKeyToCompletedNonCompletedApptsMap = new Map<VCC_TerritoryMemberKey, VCC_TwoTuple>();
        this.territoryMemberKeyToUsedApptsMap = new Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection>();
    }

    /**
     * @description Wrapper around the internal map so that we can still call containsKey on it without direct access.
     * @param key `VCC_TerritoryMemberKey` Key that we are checking for a value against.
     *
     * @return `Boolean` Returns true if the internal map has a corresponding value for the passed in key. Else false.
     */
    public Boolean containsKey(VCC_TerritoryMemberKey key) {
        return this.territoryMemberKeyToCompletedNonCompletedApptsMap.containsKey(key);
    }

    /**
     * @description We store the Collection Completed appointments in the respective tuples 'key' property. This returns that property.
     * This method is not 100% safe on its own, and behaves similarly to a map.
     * !!! Developers should call containsKey before calling this!!!
     * @param key `VCC_TerritoryMemberKey` TerritoryMember related to the completed appointments the caller is looking for.
     *
     * @return `VCC_TimeSlotCollection` Collection of timeslots representing the completed/confirmed appointments.
     */
    public VCC_TimeSlotCollection getCompletedAppointments(VCC_TerritoryMemberKey key) {
        return (VCC_TimeSlotCollection) this.territoryMemberKeyToCompletedNonCompletedApptsMap.get(key)?.valueOne;
    }

    /**
     * @description We store the Collection All appointments in the respective tuples 'value' property. This returns that property.
     * This method is not 100% safe on its own, and behaves similarly to a map.
     * !!! Developers should call containsKey before calling this!!!
     * @param key `VCC_TerritoryMemberKey` TerritoryMember related to the completed appointments the caller is looking for.
     *
     * @return `VCC_TimeSlotCollection` Collection of timeslots representing the completed/confirmed appointments.
     */
    public VCC_TimeSlotCollection getAllAppointments(VCC_TerritoryMemberKey key) {
        return (VCC_TimeSlotCollection) this.territoryMemberKeyToCompletedNonCompletedApptsMap.get(key)?.valueTwo;
    }

    /**
     * @description Wrapper around the internal map to determine if the used map contains entries for given key.
     * @param key `VCC_TerritoryMemberKey` Key that we are checking for a value against.
     *
     * @return `Boolean` Returns true if the internal used map has a corresponding value for the passed in key. Else false.
     */
    public Boolean usedMapContainsKey(VCC_TerritoryMemberKey key) {
        return this.territoryMemberKeyToUsedApptsMap.containsKey(key);
    }

    /**
     * @description We store the Collection Completed (Used only - NOT including canceled at last minute) appointments in the respective
     *     tuples 'key' property. This returns that property.
     * This method is not 100% safe on its own, and behaves similarly to a map.
     * @param key `VCC_TerritoryMemberKey` TerritoryMember related to the used (aka Completed and not Canceled at last minute) appointments the caller is looking for.
     *
     * @return `VCC_TimeSlotCollection` Collection of timeslots representing the completed/used appointments or null if there are no used appointments for key
     */
    public VCC_TimeSlotCollection getUsedAppointments(VCC_TerritoryMemberKey key) {
        return this.territoryMemberKeyToUsedApptsMap.get(key);
    }

    /**
     * @description Given a list of Appointments of unknown statuses, key them to TerritoryMembers, and add them to the respective buckets, Completed and non-completed.
     * @param appointmentsInRange `List<ServiceAppointment>` List of Appointments we need to put into TerritoryMemberKey => < Completed => All > buckets.
     * @throws `InvalidArgumentException` if an appointment passed to this method does not have an assigned resource.
     */
    public void putAllAppointmentsInResultantMap(List<ServiceAppointment> appointmentsInRange) {
        for (ServiceAppointment currentAppointment : appointmentsInRange) {
            //This should never evaluate to true as our query filters on AssignedResources
            //But if Someone uses this method incorrectly, and passes in invalid data, we should let them know.
            if (
                currentAppointment.ServiceResources == null ||
                (currentAppointment.ServiceResources != null && currentAppointment.ServiceResources.isEmpty())
            ) {
                throw new InvalidArgumentException(
                    INVALID_APPOINTMENT_EXCEPTION + '\n' + JSON.serializePretty(currentAppointment)
                );
            }

            //There is likely only one Assigned resource for any appointment.
            //At time of construction, we do not do multi-resource scheduling
            //but, It would be irresponsible to not loop through just in-case as the data model allows for multiple resources...
            for (AssignedResource personWhoIsWorkingTheAppointment : currentAppointment.ServiceResources) {
                this.addAppointmentToRespectiveBuckets(currentAppointment, personWhoIsWorkingTheAppointment);
            }
        }
    }

    /**
     * @description Given an appointment and an assigned resource, this method Constructs a TerritoryMemberKey and
     * then adds the appointment to the needed buckets, Completed Appointments and all appointments
     * @param appt `ServiceAppointment` ServiceAppointment that we need to add to the relevant collections.
     * @param resource `AssignedResource` the person working the appointment.
     */
    @TestVisible
    private void addAppointmentToRespectiveBuckets(ServiceAppointment appt, AssignedResource resource) {
        VCC_TerritoryMemberKey key = new VCC_TerritoryMemberKey(resource.ServiceResourceId, appt.ServiceTerritoryId);
        if (!this.territoryMemberKeyToCompletedNonCompletedApptsMap.containsKey(key)) {
            this.createBucketForAppointment(appt, key);
            return;
        }
        //Implicit else
        VCC_TwoTuple completedToAllAppointments = this.territoryMemberKeyToCompletedNonCompletedApptsMap.get(key);
        if (appt.Status == COMPLETED || appt.Cancelled_Date__c >= appt.SchedStartTime) {
            //Add the completed or no-show appointment
            ((VCC_TimeSlotCollection) completedToAllAppointments.valueOne).add(appt);
            if (appt.Status == COMPLETED && appt.Cancelled_Date__c == null) {
                this.territoryMemberKeyToUsedApptsMap.get(key).add(appt);
            }
        }
        //always add to the All collection
        ((VCC_TimeSlotCollection) completedToAllAppointments.valueTwo).add(appt);
    }

    /**
     * @description Helper method that handles creating buckets for the given appt & key (represents unique combination of
     *  a Provider, VISN & Date). We are managing three containers of appointments
     *  1. All Appointments for a given key
     *  2. Completed & Canceled AFTER start date for a given key
     *  3. ONLY Completed Appointments for a given key (so excluding the last-minute cancellations)
     * Called when first Appointment is added for given key by `addAppointmentToRespectiveBuckets`. All other
     * Appointments are added to bucket(s) created here.
     *
     * @param appt `ServiceAppointment` Appointment to inspect to determine in which bucket(s) it belongs
     * @param key `VCC_TerritoryMemberKey` Represents the unique combination of a Provider (ServiceResource),
     *  VISN (ServiceTerritory) and Date.
     */
    private void createBucketForAppointment(ServiceAppointment appt, VCC_TerritoryMemberKey key) {
        VCC_TimeSlotCollection usedAppointments = (appt.Status == COMPLETED &&
            appt.Cancelled_Date__c == null)
            ? new VCC_TimeSlotCollection(appt)
            : new VCC_TimeSlotCollection();
        VCC_TimeSlotCollection completedAndNoShowAppointments = (appt.Status == COMPLETED ||
            appt.Cancelled_Date__c >= appt.SchedStartTime)
            ? new VCC_TimeSlotCollection(appt)
            : new VCC_TimeSlotCollection();
        VCC_TimeSlotCollection allAppointments = new VCC_TimeSlotCollection(appt);
        this.territoryMemberKeyToCompletedNonCompletedApptsMap.put(
            key,
            new VCC_TwoTuple(completedAndNoShowAppointments, allAppointments)
        );
        this.territoryMemberKeyToUsedApptsMap.put(key, usedAppointments);
    }

    /**
     * @description thrown when an invalid appointment is passed to this class.
     */
    public class InvalidArgumentException extends Exception {
    }
}
