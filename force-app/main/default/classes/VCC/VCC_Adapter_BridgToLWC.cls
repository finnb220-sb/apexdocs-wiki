/**
 * @description This class is a bridge between the VCC Adapter and the LWC components.
 * This class is deprecated and will be removed in the future.
 */
public with sharing class VCC_Adapter_BridgToLWC {
    /**
     * @description Exception class
     */
    @SuppressWarnings('PMD.InnerClassNamingConventions')
    private class VAHC_Exception extends Exception {
    }

    /**
     * @description Appointments RS to LWC
     * @param appointmentsRS Appointments Response
     * @return VCC_AppointmentResponseWrp
     */
    public static VCC_AppointmentResponseWrp vccAppointment(VCC_BridgAppointmentsRS appointmentsRS) {
        VCC_AppointmentResponseWrp appointmentResWrp = new VCC_AppointmentResponseWrp();
        appointmentResWrp.statusCode = appointmentsRS.statusCode;
        appointmentResWrp.isMaxRecordsError = appointmentsRS.isMaxRecordsError;
        appointmentResWrp.appointmentModal = (VCC_AppointmentModal) JSON.deserialize(
            JSON.serialize(new Map<String, Object>{ 'appointmentsData' => appointmentsRS.appointmentsData }),
            VCC_AppointmentModal.class
        );
        return appointmentResWrp;
    }

    /**
     * @description Consults RS to LWC
     * @param consultsRS Consults Response
     * @return VCC_ConsultResponseWrp
     */
    public static VCC_ConsultResponseWrp vccConsult(VCC_BridgConsultsRS consultsRS) {
        VCC_ConsultResponseWrp consultResWrp = new VCC_ConsultResponseWrp();
        consultResWrp.isMaxRecordsError = consultsRS.isMaxRecordsError;
        consultResWrp.statusCode = consultsRS.statusCode;
        consultResWrp.consultModal = (VCC_ConsultModal) JSON.deserialize(
            JSON.serialize(new Map<String, Object>{ 'sites' => consultsRS.sites }),
            VCC_ConsultModal.class
        );
        return consultResWrp;
    }

    /**
     * @description Discharge Summary RS to LWC
     * @param notesRS Notes Response
     * @return VCC_DischargeSummaryResponseWrp
     */
    public static VCC_DischargeSummaryResponseWrp vccDischargeSummaryList(VCC_BridgNotesRS notesRS) {
        VCC_DischargeSummaryResponseWrp dischargeSummaryResponseWrp = new VCC_DischargeSummaryResponseWrp();
        dischargeSummaryResponseWrp.statusCode = notesRS.statusCode;
        dischargeSummaryResponseWrp.isMaxRecordsError = notesRS.isMaxRecordsError;
        dischargeSummaryResponseWrp.dischargeSummaryModal = (VCC_DischargeSummaryModal) JSON.deserialize(
            JSON.serialize(new Map<String, Object>{ 'sites' => notesRS.sites }),
            VCC_DischargeSummaryModal.class
        );
        return dischargeSummaryResponseWrp;
    }

    /**
     * @description Flags RS to LWC
     * @param flagsRS Flags Response
     * @return VCC_FlagResponseWrp
     */
    public static VCC_FlagResponseWrp transformRS(VCC_BridgFlagsRS flagsRS) {
        //flags is a bit more complex, and needs more work
        return null;
    }

    /**
     * @description Immunization RS to LWC
     * @param immunizationRS Immunization Response
     * @return VCC_ImmunizationResponseWrp
     */
    public static VCC_ImmunizationResponseWrp vccImmunizationList(VCC_BridgImmunizationRS immunizationRS) {
        VCC_immunizationResponseWrp immunizationResWrp = new VCC_immunizationResponseWrp();
        immunizationResWrp.isMaxRecordsError = immunizationRS.isMaxRecordsError;
        immunizationResWrp.statusCode = immunizationRS.statusCode;
        immunizationResWrp.responseBody = JSON.serialize(immunizationRS);
        return immunizationResWrp;
    }

    /**
     * @description Labs RS to LWC
     * @param labsRS Labs Response
     * @return VCC_LabResponseWrp
     */
    public static VCC_LabResponseWrp vccLab(VCC_BridgLabsRS labsRS) {
        VCC_LabResponseWrp labResWrp = new VCC_LabResponseWrp();
        labResWrp.statusCode = labsRS.statusCode;
        labResWrp.labModal = (VCC_LabModal) JSON.deserialize(
            JSON.serialize(new Map<String, Object>{ 'sites' => labsRS.sites }),
            VCC_LabModal.class
        );
        return labResWrp;
    }

    /**
     * @description Meds RS to LWC
     * @param medsRS Meds Response
     * @return VCC_MedsListController.MedsWrapper
     */
    public static VCC_MedsListController.MedsWrapper vccMedicationList(VCC_BridgMedsRS medsRS) {
        String response = JSON.serialize(new Map<String, Object>{ 'sites' => medsRS.sites });

        Boolean isMaxRecordsError = medsRS.isMaxRecordsError;
        VCC_BridgMedsResponseParser bridgParser = (VCC_BridgMedsResponseParser) JSON.deserialize(
            response,
            VCC_BridgMedsResponseParser.class
        );
        List<VCC_MedsListController.FormattedMed> medList = new List<VCC_MedsListController.FormattedMed>();
        List<String> errorList = new List<String>();
        if (bridgParser?.sites != null) {
            Integer sitesWithLimitError = 0;
            for (VCC_BridgMedsResponseParser.Site site : bridgParser.sites) {
                //Check for limit errors within response
                if (!site?.errorSection?.errors.isEmpty()) {
                    for (VCC_BridgMedsResponseParser.Error responseError : site.errorSection.errors) {
                        if (responseError?.displayMessage.contains('Exceeded Max Records')) {
                            errorList.add(responseError.displayMessage);
                            sitesWithLimitError++;
                        }
                    }
                }
                // this collection only holds formatted meds for the current site of the loop
                List<VCC_MedsListController.FormattedMed> formattedMedsForThisSite = new List<VCC_MedsListController.FormattedMed>();

                if (site?.results?.meds?.med != null) {
                    for (VCC_BridgMedsResponseParser.Medication med : site.results.meds.med) {
                        if (med != null) {
                            VCC_MedsListController.FormattedMed formattedMed = new VCC_MedsListController.FormattedMed(
                                med
                            );
                            medList.add(formattedMed);
                            formattedMedsForThisSite.add(formattedMed);
                        }
                    }
                    // appending formatted meds to this site
                    site.results.meds.formattedMed = formattedMedsForThisSite;
                }
            }
            //If all sites have the limit error, throw an exception
            if (!bridgParser?.sites.isEmpty() && bridgParser?.sites.size() == sitesWithLimitError) {
                throw new VAHC_Exception('Exceeded Max Records');
            }
        }

        VCC_MedsListController.MedsWrapper medsResponse = new VCC_MedsListController.MedsWrapper(
            JSON.serialize(medList),
            errorList,
            bridgParser
        );
        medsResponse.isMaxRecordsError = isMaxRecordsError;
        return medsResponse;
    }

    /**
     * @description Notes RS to LWC
     * @param notesRS Notes Response
     * @return String
     */
    public static String transformRS(VCC_BridgNotesRS notesRS) {
        //vccHistoricalProgressNotes makes its calout directly to VCC_lwc_utils.retrieveHDR
        return null;
    }

    /**
     * @description Orders RS to LWC
     * @param ordersRS Orders Response
     * @return VCC_OrderResponseWrp
     */
    public static VCC_OrderResponseWrp vccOrderList(VCC_BridgOrdersRS ordersRS) {
        //system.debug(JSON.serialize(ordersRS.sites[0].results.orders.order[0].entered.value));
        VCC_OrderResponseWrp orderResWrp = new VCC_OrderResponseWrp();
        orderResWrp.statusCode = ordersRS.statusCode;
        orderResWrp.isMaxRecordsError = ordersRS.isMaxRecordsError;
        orderResWrp.responseBody = JSON.serialize(new Map<String, Object>{ 'sites' => ordersRS.sites })
            .replace('"group_s"', '"group"');
        return orderResWrp;
    }

    /**
     * @description Problems RS to LWC
     * @param problemsRS Problems Response
     * @return VCC_ProblemResponseWrp
     */
    public static VCC_ProblemResponseWrp vccProblemList(VCC_BridgProblemsRS problemsRS) {
        VCC_ProblemResponseWrp problemResWrp = new VCC_ProblemResponseWrp();
        problemResWrp.statusCode = problemsRS.statusCode;
        problemResWrp.problemModal = (VCC_ProblemModal) JSON.deserialize(
            JSON.serialize(new Map<String, Object>{ 'sites' => problemsRS.sites }),
            VCC_ProblemModal.class
        );
        return problemResWrp;
    }

    /**
     * @description Radiology Exams RS to LWC
     * @param radiologyExamsRS Radiology Exams Response
     * @return VCC_RadiologyResponseWrp
     */
    public static VCC_RadiologyResponseWrp vccRediologyList(VCC_BridgRadiologyExamsRS radiologyExamsRS) {
        VCC_RadiologyResponseWrp radiologyResWrp = new VCC_RadiologyResponseWrp();
        radiologyResWrp.isMaxRecordsError = radiologyExamsRS.isMaxRecordsError;
        radiologyResWrp.statusCode = radiologyExamsRS.statusCode;
        radiologyResWrp.responseBody = JSON.serialize(new Map<String, Object>{ 'sites' => radiologyExamsRS.sites })
            .replace('"exception_s"', '"exception"')
            .replace('"dateTime_s"', '"dateTime"')
            .replace('"case_s"', '"case"');

        return radiologyResWrp;
    }

    /**
     * @description Vitals RS to LWC
     * @param vitalsRS Vitals Response
     * @return String
     */
    public static String vccVitals(VCC_BridgVitalsRS vitalsRS) {
        String response = JSON.serialize(new Map<String, Object>{ 'sites' => vitalsRS.sites })
            .replace('"exception_s"', '"exception"');
        return response;
    }
}
