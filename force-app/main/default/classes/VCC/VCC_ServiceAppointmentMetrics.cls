/**
 * @description Logic for the Service Appointment Metrics Batch
 * @author BAH
 * @see VCC_GenericBatch
 *
 * @justification this class is specifically engineered to generate new ServiceApointmentMetric records. That object is a 'shadow' object for case, because we are not allowed to add fields
 * to standard objects. This class is intended to be run once, and then in a follow up release, discarded. It's purpose is to generate service appointment metic records for existing /
 * historical cases to 'backfill'. As a result, the running user will not be part of the sharing hierarchy but will need to access all the records.
 */
public without sharing class VCC_ServiceAppointmentMetrics extends ABS_BatchExecutioner {
    private static final String EXECUTIONER_NAME = 'VCC_ServiceAppointmentMetrics';
    private final String queryLocatorString;
    private final Map<String, Object> bindVariables;
    private static final String RECORD_TYPE_NAME = 'VCC_Vitrual_Clinic_Visit';
    private List<VCC_Service_Appointment_Metrics__c> upsertRecords;
    private List<VCC_Case_Metrics__c> schedulingCaseMetrics;
    private Map<Id, Id> caseIdToCaseMetricIdMap;
    private List<ServiceAppointment> inputServiceAppointmentList;

    @TestVisible
    private static VCR_CaseMetricRepo caseMetricRepo {
        get {
            return caseMetricRepo ?? new VCR_CaseMetricRepo();
        }
        set;
    }

    @TestVisible
    private static VCR_ServiceAppointmentMetricsRepo serviceAppointmentMetricsRepo {
        get {
            return serviceAppointmentMetricsRepo ?? new VCR_ServiceAppointmentMetricsRepo();
        }
        set;
    }

    @TestVisible
    private static VCR_ServiceAppointmentRepo serviceAppointmentRepo {
        get {
            return serviceAppointmentRepo ?? new VCR_ServiceAppointmentRepo();
        }
        set;
    }

    /**
     * @description Constructor for the VCC_ServiceAppointmentMetrics class
     */
    public VCC_ServiceAppointmentMetrics() {
        queryLocatorString = getQueryLocatorString();
        bindVariables = getBindVariables();
        super.executionerName = EXECUTIONER_NAME;
    }

    /**
     * @description Method to get the Query Locator
     * @return String
     */
    public override String getQueryLocatorString() {
        return serviceAppointmentRepo.getQueryStringForServiceAppointments();
    }

    /**
     * @description Method to get the Query Locator
     * @param  query String
     * @return Database.QueryLocator
     */
    public override Database.QueryLocator getQueryLocator(String query) {
        return serviceAppointmentRepo.getQueryLocatorForServiceAppointments(queryLocatorString);
    }

    /**
     * @description Method to get the Bind Variables
     * @return Map<String, Object>
     */
    public override Map<String, Object> getBindVariables() {
        return new Map<String, Object>{ 'recordTypeName' => RECORD_TYPE_NAME };
    }

    /**
     * @description Method to execute the Service Appointment Metrics Batch
     * @param inputList List<ServiceAppointment> to execute the batch for
     */
    public override void execute(List<SObject> inputList) {
        this.inputServiceAppointmentList = (List<ServiceAppointment>) inputList;
        this.upsertRecords = new List<VCC_Service_Appointment_Metrics__c>();
        this.schedulingCaseMetrics = caseMetricRepo.getScheduleCaseMetrics(getCaseIds(inputServiceAppointmentList));
        this.caseIdToCaseMetricIdMap = getCaseMetricsMap(inputServiceAppointmentList);
        for (ServiceAppointment serviceAppointment : inputServiceAppointmentList) {
            VCC_Service_Appointment_Metrics__c serviceAppointmentMetrics = constructServiceAppointmentMetrics(
                serviceAppointment
            );
            upsertRecords.add(serviceAppointmentMetrics);
        }
        serviceAppointmentMetricsRepo.upsertServiceAppointmentMetrics(upsertRecords);
    }
    /**
     * @description Method to construct the Service Appointment Metrics
     * @param serviceAppointment ServiceAppointment record to construct the metrics for
     * @return VCC_Service_Appointment_Metrics__c
     */
    @TestVisible
    private VCC_Service_Appointment_Metrics__c constructServiceAppointmentMetrics(
        ServiceAppointment serviceAppointment
    ) {
        VCC_Service_Appointment_Metrics__c serviceAppointmentMetrics = doesServiceAppointmentMetricExist(
                serviceAppointment
            )
            ? serviceAppointment.Service_Appointment_Metrics__r
            : new VCC_Service_Appointment_Metrics__c(Service_Appointment__c = serviceAppointment.Id);
        serviceAppointmentMetrics.Case__c = serviceAppointment.Case__c;
        if (!serviceAppointment.Cases__r?.isEmpty()) {
            serviceAppointmentMetrics.Case_Metrics__c = caseIdToCaseMetricIdMap.get(
                serviceAppointment.Cases__r[0]?.ParentId
            );
        }
        return serviceAppointmentMetrics;
    }

    /**
     * @description Method to check if the Service Appointment Metrics exists
     * @param serviceAppointment ServiceAppointment record to check
     * @return Boolean
     */
    @TestVisible
    private static Boolean doesServiceAppointmentMetricExist(ServiceAppointment serviceAppointment) {
        return !serviceAppointment?.Service_Appointment_Metrics__r?.isEmpty();
    }

    /**
     * @description Method to get the Case Ids for the Service Appointments
     * @param serviceAppointments List<ServiceAppointment> to get the Case Ids for
     * @return List<String>
     */
    @TestVisible
    private static List<String> getCaseIds(List<ServiceAppointment> serviceAppointments) {
        List<String> caseIds = new List<String>();
        for (ServiceAppointment serviceAppointment : serviceAppointments) {
            // check before access
            if (serviceAppointment.Cases__r != null && serviceAppointment.Cases__r.size() > 0) {
                caseIds.add(serviceAppointment.Cases__r[0]?.ParentId);
            }
        }
        return caseIds;
    }

    /**
     * @description Method to get the Case Metrics Map
     * @param serviceAppointments List<ServiceAppointment> to get the Case Metrics Map for
     * @return Map<Id, Id>
     */
    @TestVisible
    private Map<Id, Id> getCaseMetricsMap(List<ServiceAppointment> serviceAppointments) {
        Map<Id, VCC_Case_Metrics__c> metricsMap = buildMetricsMap(schedulingCaseMetrics);
        Map<Id, Id> caseIdToCaseMetricIdMap = new Map<Id, Id>();

        for (ServiceAppointment serviceAppointment : serviceAppointments) {
            addCaseMetric(caseIdToCaseMetricIdMap, metricsMap, serviceAppointment);
        }
        return caseIdToCaseMetricIdMap;
    }
    /**
     * @description Method to build the Case Metrics Map
     * @param schedulingCaseMetrics List<VCC_Case_Metrics__c> to build the map from
     * @return Map<Id, VCC_Case_Metrics__c>
     */
    @TestVisible
    private static Map<Id, VCC_Case_Metrics__c> buildMetricsMap(List<VCC_Case_Metrics__c> schedulingCaseMetrics) {
        Map<Id, VCC_Case_Metrics__c> metricsMap = new Map<Id, VCC_Case_Metrics__c>();
        for (VCC_Case_Metrics__c caseMetric : schedulingCaseMetrics) {
            metricsMap.put(caseMetric.VCC_Case__c, caseMetric);
        }
        return metricsMap;
    }
    /**
     * @description Method to add the Case Metric to the Case Id to Case Metric Id Map
     * @param caseIdToCaseMetricIdMap Map<Id, Id> to add the Case Metric to
     * @param metricsMap Map<Id, VCC_Case_Metrics__c> to get the Case Metric from
     * @param serviceAppointment ServiceAppointment to get the Case Id from
     */
    @TestVisible
    private static void addCaseMetric(
        Map<Id, Id> caseIdToCaseMetricIdMap,
        Map<Id, VCC_Case_Metrics__c> metricsMap,
        ServiceAppointment serviceAppointment
    ) {
        if (serviceAppointment?.Cases__r != null && !serviceAppointment.Cases__r.isEmpty()) {
            Id caseId = serviceAppointment?.Cases__r[0]?.ParentId;
            VCC_Case_Metrics__c matchingCaseMetric = metricsMap.get(caseId);
            if (matchingCaseMetric != null) {
                caseIdToCaseMetricIdMap.put(caseId, matchingCaseMetric.Id);
            }
        }
    }
}
