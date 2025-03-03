/**
 * @description Apex controller for handling navigation from a Visualforce page to a Lightning Flow.
 */
public with sharing class CancelServiceAppointment {
    private transient final ServiceAppointment serviceAppointment;

    @TestVisible
    private VCR_ServiceAppointmentRepo serviceAppointmentRepo {
        get {
            if (serviceAppointmentRepo == null) {
                serviceAppointmentRepo = new VCR_ServiceAppointmentRepo();
            }
            return serviceAppointmentRepo;
        }
        private set;
    }

    /**
     * @description Constructor for CancelServiceAppointment initializes the controller with the current ServiceAppointment record.
     * @param stdController StandardController for the ServiceAppointment object.
     */
    public CancelServiceAppointment(ApexPages.StandardController stdController) {
        this.serviceAppointment = (ServiceAppointment) stdController.getRecord();
    }

    /**
     * @description startCancelServiceAppointmentFlow starts the Logic of the visualforce page
     * @return Final PageReference to the corresponding flow
     */
    public String startCancelServiceAppointmentFlow() {
        if (String.isBlank(serviceAppointment.Id)) {
            return null;
        }
        String recordId = serviceAppointment.Id;

        ServiceAppointment serviceAppt = (ServiceAppointment) serviceAppointmentRepo.fetchById(recordId);
        String recordTypeName = serviceAppt.RecordType.Name;

        if (String.isBlank(recordTypeName)) {
            return null;
        }

        if (recordTypeName == 'Virtual Clinic Visit') {
            return new VCC_PageRefHelper()
                    .getFlowRedirectPageReference('VCC_Cancel_Service_Appointment', serviceAppointment.Id)
                    .getUrl() + '&varFromListView=true';
        }
        return new VCC_PageRefHelper()
                .getFlowRedirectPageReference('Inbound_Cancel_Appointment_Flow', serviceAppointment.Id)
                .getUrl() + '&varPageRedirect=true';
    }
}
