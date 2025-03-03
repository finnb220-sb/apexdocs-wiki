/**
 * @author Booz Allen Hamilton
 * @since 5/23/24
 * @description Service class (engine/worker) for VCC_AppointmentUtilQueueable
 *
 * @see VCC_AppointmentUtilQueueable
 * @see VCC_AppointmentUtilizationService
 * @see VCR_ServiceTerritoryMemberRepo
 * @see VCC_AppointmentUtilQueueableServiceTest
 */
public with sharing class VCC_AppointmentUtilQueueableService {
    private VCC_AppointmentUtilQueueable.AppointmentUtilizationData data;

    private VCR_SerializableQueryLocatorChunk resultsIterator;
    @TestVisible
    private Integer position = 0; // position in result set
    @TestVisible
    private Integer batchSize = 1;

    @TestVisible
    private static VCR_ServiceTerritoryMemberRepo memoizedTerritoryMemberRepo;

    @TestVisible
    private static VCR_ServiceTerritoryMemberRepo territoryMemberRepo {
        get {
            if (memoizedTerritoryMemberRepo == null) {
                memoizedTerritoryMemberRepo = new VCR_ServiceTerritoryMemberRepo();
            }
            return memoizedTerritoryMemberRepo;
        }
        set;
    }

    @TestVisible
    private static VCC_AppointmentUtilizationService service {
        get {
            if (service == null) {
                service = new VCC_AppointmentUtilizationService();
            }
            return service;
        }
        set;
    }

    /**
     * @description Create an instance of the service class for the AppointmentUtilQueueable
     */
    public VCC_AppointmentUtilQueueableService() {
        this.resultsIterator = new VCR_SerializableQueryLocatorChunk(ServiceTerritoryMember.SObjectType);
    }

    /**
     * @description Set our batch size from the config record
     *
     * @param config `VCC_Appointment_Utilization_Config__mdt` custom metadata record specifying batch size
     */
    public void setConfig(VCC_Appointment_Utilization_Config__mdt config) {
        this.batchSize = Integer.valueOf(config.Queueable_Batch_Size__c);
    }

    /**
     * @description Get the ServiceTerritoryMember records (junction object between ServiceTerritory, aka VISN, and
     *  ServiceResource, aka Provider, for use in calculating utilization metrics.
     *
     * @param data `VCC_AppointmentUtilQueueable.AppointmentUtilizationData` instance containing
     *  necessary input data for calculating utilization metrics
     */
    public void fetchData(VCC_AppointmentUtilQueueable.AppointmentUtilizationData data) {
        this.data = data;
        // Fetch ServiceTerritoryMembers for our ServiceTerritories (keyed off VISN Names)
        Object queryBindVars = this.data.getVisnData();
        String queryString;
        Map<String, Object> bindVars = new Map<String, Object>();
        if (queryBindVars == null) {
            queryString = territoryMemberRepo.getQueryForAllVISNsInUserTimezone();
            bindVars.put('queryArg', (String) UserInfo.getTimeZone().toString());
        } else if (this.data.doQueryByIds()) {
            queryString = territoryMemberRepo.getQueryForVISNIds();
            bindVars.put('queryArg', (List<Id>) queryBindVars);
        } else {
            queryString = territoryMemberRepo.getQueryForNamedVISNs();
            bindVars.put('queryArg', (List<String>) queryBindVars);
        }
        this.resultsIterator.init(queryString, bindVars);
    }

    /**
     * @description Generate the Utilization Metrics for our data set. Called by controlling Queueable instance
     */
    public void execute() {
        // Get an iterator
        // Iterate over the records
        List<ServiceTerritoryMember> members = (List<ServiceTerritoryMember>) this.resultsIterator.getRecords(
            position,
            this.batchSize
        );
        // for each date in our range, calculate utilization for our current set of members.
        // we are calculating metrics for StartDate through EndDate, but not including EndDate.
        // This is because we want to process all records in a 24 hour period.
        for (Date currentDate = this.data.startDate; currentDate < this.data.endDate;) {
            Date endDate = currentDate.addDays(1);
            VCC_DateRange vccDateRange = new VCC_DateRange(currentDate, endDate);
            service.calculateUtilizationForTerritoryMembersInRange(members, vccDateRange);
            currentDate = currentDate.addDays(1);
        }
        // increment our offset into record set for next iteration if necessary
        this.position += members.size();
    }

    /**
     * @description Determine if the chain of queueable jobs is complete - true for yes, false for no (kickoff another job)
     *
     * @return `Boolean` true if we have processed all records, false otherwise
     */

    public Boolean hasExitCriteriaBeenMet() {
        return (this.position >= this.resultsIterator.getNumRecords());
    }
}
