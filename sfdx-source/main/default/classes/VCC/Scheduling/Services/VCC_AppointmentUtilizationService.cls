/**
 * @description Service class that contains the business logic for calculating VCC_AppointmentUtilization Metrics
 * @see VCC_TerritoryMemberToTimeSlotMap
 * @see VCC_DateRange
 * @see VCC_TimeSlot
 * @see VCC_TimeSlotCollection
 */
public with sharing class VCC_AppointmentUtilizationService {
    private static final String DEFAULT_VISN_CONFIG = 'DEFAULT_VISN_CONFIG';
    private Map<Id, List<VCC_TimeSlot>> resourceIdToAbsencesMap;
    private Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection> territoryMemberToHolidaysMap;

    private static final VTC_RepoFactory repoFactory {
        get {
            //Memoized instance of Repo Factory
            return VTC_RepoFactory.repoFactory;
        }
    }

    @TestVisible
    private static VCC_OperatingHoursHolidayService operatingHoursHolidayService {
        get {
            if (operatingHoursHolidayService == null) {
                operatingHoursHolidayService = new VCC_OperatingHoursHolidayService();
            }
            return operatingHoursHolidayService;
        }
        set;
    }

    @TestVisible
    private static VCR_AppointmentUtilizationRepo appointmentUtilRepo {
        get {
            if (appointmentUtilRepo == null) {
                appointmentUtilRepo = new VCR_AppointmentUtilizationRepo();
            }
            return appointmentUtilRepo;
        }
        set;
    }

    @TestVisible
    private static VCR_AppointmentSlotConfigRepo apptSlotConfigRepo {
        get {
            if (apptSlotConfigRepo == null) {
                apptSlotConfigRepo = new VCR_AppointmentSlotConfigRepo();
            }
            return apptSlotConfigRepo;
        }
        set;
    }

    /**
     * @description For each Territory member, this method calculates their total utilization percentage and inserts a metric record with that data, for future reporting.
     * @param territoryMembers `List<ServiceTerritoryMember>` List of providers we need to run the calculation on.
     * @param range `VCC_DateRange` The Date range we are calculating on.
     */
    public void calculateUtilizationForTerritoryMembersInRange(
        List<ServiceTerritoryMember> territoryMembers,
        VCC_DateRange range
    ) {
        //Get territoryToTimeSlotMap
        VCC_TerritoryMemberToTimeSlotMap territoryMemberKeyToTimeSlotMap = getServiceTerritoryMemberKeyToAvailableTimeSlotMap(
            territoryMembers,
            range
        );
        //Delete existing in range
        this.deleteExistingUtilizationRecordsInRange(
            territoryMemberKeyToTimeSlotMap.relatedResourceIds,
            territoryMemberKeyToTimeSlotMap.relatedTerritoryIds,
            range
        );

        //Get ServiceAppointments
        VCC_TerritoryMemberToAppointmentsMap territoryMemberToCompletedAndNonCompletedAppointments = getTerritoryMemberToAppointmentsMap(
            territoryMemberKeyToTimeSlotMap.relatedResourceIds,
            territoryMemberKeyToTimeSlotMap.relatedTerritoryIds,
            range
        );

        Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection> terMemberKeyToTimeSlotCollectionMap = territoryMemberKeyToTimeSlotMap.getMap();

        List<VCC_Appointment_Utilization__c> resultantRecords = getResultantRecords(
            terMemberKeyToTimeSlotCollectionMap,
            territoryMemberToCompletedAndNonCompletedAppointments,
            range
        );

        appointmentUtilRepo.doCreate(resultantRecords);
    }

    /**
     * @description For each territory member passed into the service, we need to create a utilization record in memory.
     * @param terMemberKeyToTimeSlotCollectionMap `Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection>` Map of Territory members to their net available hours.
     * @param territoryMemberToCompletedAndNonCompletedAppointments `VCC_TerritoryMemberToAppointmentsMap` Map of Territory members to their categorized Service appointments.
     * @param range `VCC_DateRange`
     *
     * @return `List<VCC_Appointment_Utilization__c>` Returns a list of metrics records with total net slots, total scheduled slots, and gross utilized slots fields populated.
     * @see VCC_TerritoryMemberToAppointmentsMap
     * @see VCC_DateRange
     * @see VCC_TimeSlot
     *
     */
    @TestVisible
    private List<VCC_Appointment_Utilization__c> getResultantRecords(
        Map<VCC_TerritoryMemberKey, VCC_TimeSlotCollection> terMemberKeyToTimeSlotCollectionMap,
        VCC_TerritoryMemberToAppointmentsMap territoryMemberToCompletedAndNonCompletedAppointments,
        VCC_DateRange range
    ) {
        Map<String, VCC_Appointment_Slot_Config__mdt> configsByLabel = apptSlotConfigRepo.fetchAppointmentSlotConfigs();
        Integer defaultSlotLength = Integer.valueOf(
            configsByLabel.get(DEFAULT_VISN_CONFIG).Appointment_Slot_Duration_in_minutes__c
        );
        List<VCC_Appointment_Utilization__c> resultantRecords = new List<VCC_Appointment_Utilization__c>();
        for (VCC_TerritoryMemberKey key : terMemberKeyToTimeSlotCollectionMap.keySet()) {
            Integer slotLength = configsByLabel.containsKey(key.visnName)
                ? Integer.valueOf(configsByLabel.get(key.visnName).Appointment_Slot_Duration_in_minutes__c)
                : defaultSlotLength;
            VCC_TimeSlotCollection currentCollection = terMemberKeyToTimeSlotCollectionMap.get(key);

            //Calculate slots that were available for the service provider
            Integer netAvailableSlots = currentCollection.calculateTotalNumSlots(slotLength);

            //Calcuate slots from completed and past appointments
            Integer allScheduledSlots = territoryMemberToCompletedAndNonCompletedAppointments.containsKey(key)
                ? territoryMemberToCompletedAndNonCompletedAppointments.getAllAppointments(key)
                      .calculateTotalNumSlots(slotLength)
                : 0;

            Integer completedOrCancelledAppointmentsSlots = territoryMemberToCompletedAndNonCompletedAppointments.containsKey(
                    key
                )
                ? territoryMemberToCompletedAndNonCompletedAppointments.getCompletedAppointments(key)
                      .calculateTotalNumSlots(slotLength)
                : 0;
            Integer usedSlots = territoryMemberToCompletedAndNonCompletedAppointments.usedMapContainsKey(key)
                ? territoryMemberToCompletedAndNonCompletedAppointments.getUsedAppointments(key)
                      .calculateTotalNumSlots(slotLength)
                : 0;
            //If the user is working, create the record else do not.
            if (netAvailableSlots > 0) {
                resultantRecords.add(
                    new VCC_Appointment_Utilization__c(
                        VCC_Date__c = range.startDateTime.date(),
                        VCC_Net_Available_Slots__c = netAvailableSlots,
                        VCC_Net_Scheduled_Slots__c = allScheduledSlots,
                        VCC_Actual_Used_Slots__c = usedSlots,
                        VCC_Gross_Utilized_Slots__c = completedOrCancelledAppointmentsSlots,
                        VCC_Service_Resource__c = key.serviceResourceId,
                        VCC_Service_Territory__c = key.serviceTerritoryId,
                        VCC_Shift_Description__c = currentCollection.concatDescriptions()
                    )
                );
            }
        }
        return resultantRecords;
    }

    @TestVisible
    private void deleteExistingUtilizationRecordsInRange(
        Set<Id> relatedResourceIds,
        Set<Id> relatedTerritoryIds,
        VCC_DateRange dateRange
    ) {
        appointmentUtilRepo.doDelete(
            appointmentUtilRepo.getAppointmentUtilizationRecordsWithinRangeRelatedToTerritoryMembers(
                relatedResourceIds,
                relatedTerritoryIds,
                dateRange
            )
        );
    }

    @TestVisible
    private VCC_TerritoryMemberToAppointmentsMap getTerritoryMemberToAppointmentsMap(
        Set<Id> relatedResourceIds,
        Set<Id> relatedTerritoryIds,
        VCC_DateRange range
    ) {
        VCC_TerritoryMemberToAppointmentsMap resultantMap = new VCC_TerritoryMemberToAppointmentsMap();
        VCR_ServiceAppointmentRepo apptRepo = (VCR_ServiceAppointmentRepo) repoFactory.createRepo(
            ServiceAppointment.SObjectType
        );
        List<ServiceAppointment> appts = apptRepo.getServiceAppointmentsRelatedToTerritoryMembersInRange(
            relatedResourceIds,
            relatedTerritoryIds,
            range
        );
        resultantMap.putAllAppointmentsInResultantMap(appts);
        return resultantMap;
    }

    /**
     * @description Given a list of ServiceTerritoryMembers, map each serviceTerritory member to a collection of their available time slots.
     * @param territoryMembers `List<ServiceTerritoryMember>` List of ServiceTerritoryMembers we want to calculate for.
     * @param range `VCC_DateRange` Range that we are concerned with in this calculation.
     *
     * @return `VCC_TerritoryMemberToTimeSlotMap` Custom data structure that maps a ServiceTerritoryMember to their TimeSlots. Map based.
     * @see VCC_TerritoryMemberToTimeSlotMap
     * @see VCC_DateRange
     * @see VCC_TimeSlot
     * @see VCC_TimeSlotCollection
     */
    @TestVisible
    private VCC_TerritoryMemberToTimeSlotMap getServiceTerritoryMemberKeyToAvailableTimeSlotMap(
        List<ServiceTerritoryMember> territoryMembers,
        VCC_DateRange range
    ) {
        VCC_TerritoryMemberToTimeSlotMap resultantCollection = new VCC_TerritoryMemberToTimeSlotMap(territoryMembers);
        VCR_ShiftRepo shiftRepo = (VCR_ShiftRepo) repoFactory.createRepo(Shift.SObjectType);
        List<Shift> confirmedShiftsInRange = shiftRepo.getConfirmedShiftsRelatedToServiceTerritoryMembersInDateRange(
            range,
            resultantCollection.relatedTerritoryIds,
            resultantCollection.relatedResourceIds
        );
        resultantCollection.putAllShiftsIntoResultantMap(confirmedShiftsInRange, range);

        //Get the absences in range
        this.resourceIdToAbsencesMap = getResourceIDToAbsenceMap(resultantCollection.relatedResourceIds, range);
        //Get holidays
        this.territoryMemberToHolidaysMap = operatingHoursHolidayService.getHolidayTimeSlotsForProvidersAndDates(
            range,
            territoryMembers
        );
        this.removeDisqualifyingSlots(resultantCollection);

        return resultantCollection;
    }

    @TestVisible
    private void removeDisqualifyingSlots(VCC_TerritoryMemberToTimeSlotMap resultantCollection) {
        for (VCC_TerritoryMemberKey terrMemberKey : resultantCollection.getMap().keySet()) {
            //Remove any absences
            if (this.resourceIdToAbsencesMap.containsKey(terrMemberKey.serviceResourceId)) {
                resultantCollection
                    /*@Justification The referenced getMap method is a custom method and not the standard Apex Collection getMap*/
                    .getMap()
                    .get(terrMemberKey)
                    .filterOutTimeSlots(this.resourceIdToAbsencesMap.get(terrMemberKey.serviceResourceId));
            }
            //Remove any holidays
            if (this.territoryMemberToHolidaysMap.containsKey(terrMemberKey)) {
                resultantCollection
                    /*@Justification The referenced getMap method is a custom method and not the standard Apex Collection getMap*/
                    .getMap()
                    .get(terrMemberKey)
                    .filterOutTimeSlots(this.territoryMemberToHolidaysMap.get(terrMemberKey).getTimeSlots());
            }
        }
    }

    /**
     * @description Given a Set of Service resource ids and a date range, this fetches their related absences in range
     * and structures them into a map of Id => VCC_TimeSlots so that we can filter our existing collections on them.
     * @param resourceIds `Set<Id>` Set of the Ids of ServiceResources we are looking for absences for.
     * @param range `VCC_DateRange` Date range we are concerned with.
     *
     * @return  `Map<Id, List<VCC_TimeSlot>>` Map of ServiceResource Id to a collection of their absences
     * normalized as VCC_TimeSLots
     *
     */
    @TestVisible
    private Map<Id, List<VCC_TimeSlot>> getResourceIDToAbsenceMap(Set<Id> resourceIds, VCC_DateRange range) {
        VCR_ResourceAbsenceRepo absenceRepo = (VCR_ResourceAbsenceRepo) repoFactory.createRepo(
            ResourceAbsence.SObjectType
        );
        List<ResourceAbsence> absences = absenceRepo.getAbsencesInDateRangeForServiceResourcesInList(
            resourceIds,
            range
        );
        Map<Id, List<VCC_TimeSlot>> resourceIDToAbsencesAsTimeSlotsMap = new Map<Id, List<VCC_TimeSlot>>();

        for (ResourceAbsence curAbsence : absences) {
            VCC_TimeSlot timeSlotToAdd = new VCC_TimeSlot(curAbsence.Start, curAbsence.End);

            if (!resourceIDToAbsencesAsTimeSlotsMap.containsKey(curAbsence.ResourceId)) {
                resourceIDToAbsencesAsTimeSlotsMap.put(curAbsence.ResourceId, new List<VCC_TimeSlot>{ timeSlotToAdd });
            } else {
                resourceIDToAbsencesAsTimeSlotsMap.get(curAbsence.ResourceId).add(timeSlotToAdd);
            }
        }
        return resourceIDToAbsencesAsTimeSlotsMap;
    }
}
