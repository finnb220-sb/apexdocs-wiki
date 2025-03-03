public with sharing class VCC_BridgProxy extends VCC_ApiProxy {
    private VCC_BridgClient bridgClient {
        get {
            return (VCC_BridgClient) this.client;
        }
    }

    public VCC_BridgAdditionalSignersRS additionalSigners(VCC_BridgAdditionalSignersRQ rq) {
        return bridgClient.additionalSigners(rq);
    }

    public VCC_BridgAllergyRS allergy(VCC_BridgAllergyRQ rq) {
        return bridgClient.allergy(rq);
    }

    public VCC_BridgAppointmentsRS appointments(VCC_BridgAppointmentsRQ rq) {
        return bridgClient.appointments(rq);
    }

    public VCC_BridgConsultsRS consults(VCC_BridgConsultsRQ rq) {
        return bridgClient.consults(rq);
    }

    public VCC_BridgFlagsRS flags(VCC_BridgFlagsRQ rq) {
        return bridgClient.flags(rq);
    }

    public VCC_BridgImmunizationRS immunization(VCC_BridgImmunizationRQ rq) {
        return bridgClient.immunization(rq);
    }

    public VCC_BridgLabsRS labs(VCC_BridgLabsRQ rq) {
        return bridgClient.labs(rq);
    }

    public VCC_BridgMedsRS meds(VCC_BridgMedsRQ rq) {
        return bridgClient.meds(rq);
    }

    public VCC_BridgNotesRS notes(VCC_BridgNotesRQ rq) {
        return bridgClient.notes(rq);
    }

    public VCC_BridgOrdersRS orders(VCC_BridgOrdersRQ rq) {
        return bridgClient.orders(rq);
    }

    public VCC_BridgProblemsRS problems(VCC_BridgProblemsRQ rq) {
        return bridgClient.problems(rq);
    }

    public VCC_BridgRadiologyExamsRS radiologyExams(VCC_BridgRadiologyExamsRQ rq) {
        return bridgClient.radiologyExams(rq);
    }

    public VCC_BridgVisitsRS visits(VCC_BridgVisitsRQ rq) {
        return bridgClient.visits(rq);
    }

    public VCC_BridgVitalsRS vitals(VCC_BridgVitalsRQ rq) {
        return bridgClient.vitals(rq);
    }

    protected override System.Type getClientType() {
        return VCC_BridgClient.class;
    }
}
