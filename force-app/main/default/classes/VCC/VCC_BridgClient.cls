public with sharing class VCC_BridgClient extends VCC_BaseClient {
    private static final String INVALID_REQUEST_MSG = 'The provided request is invalid.';
    public Id accountId { get; set; }

    @TestVisible
    protected override HTTPRequest createHttpRequest(String httpRequestMethod, Object requestBody) {
        HTTPRequest req = new HTTPRequest();
        req.setMethod(httpRequestMethod);
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setHeader('apiKey', '{!$Credential.Password}');
        req.setTimeout(120000);
        req.setBody(JSON.serialize(requestBody));
        return req;
    }

    public VCC_BaseClient.BaseResponse additionalSignersBase(VCC_BridgAdditionalSignersRQ rq) {
        if (!rq.isValid()) {
            throw new InvalidRequestException(INVALID_REQUEST_MSG);
        }
        setServiceName('vccBridgAdditionalSigners');
        return send(createHttpRequest('POST', rq));
    }

    public VCC_BridgAdditionalSignersRS additionalSigners(VCC_BridgAdditionalSignersRQ rq) {
        return new VCC_BridgAdditionalSignersRS(additionalSignersBase(rq));
    }

    public VCC_BaseClient.BaseResponse allergyBase(VCC_BridgAllergyRQ rq) {
        if (!rq.isValid()) {
            throw new InvalidRequestException(INVALID_REQUEST_MSG);
        }
        setServiceName('vccBridgAllergy');
        return send(createHttpRequest('POST', rq));
    }

    public VCC_BridgAllergyRS allergy(VCC_BridgAllergyRQ rq) {
        return new VCC_BridgAllergyRS(allergyBase(rq));
    }

    public VCC_BaseClient.BaseResponse appointmentsBase(VCC_BridgAppointmentsRQ rq) {
        if (!rq.isValid()) {
            throw new InvalidRequestException(INVALID_REQUEST_MSG);
        }
        setServiceName('vccBridgAppointments');
        return send(createHttpRequest('POST', rq));
    }

    public VCC_BridgAppointmentsRS appointments(VCC_BridgAppointmentsRQ rq) {
        return new VCC_BridgAppointmentsRS(appointmentsBase(rq));
    }

    public VCC_BaseClient.BaseResponse consultsBase(VCC_BridgConsultsRQ rq) {
        if (!rq.isValid()) {
            throw new InvalidRequestException(INVALID_REQUEST_MSG);
        }
        setServiceName('vccBridgConsults');
        return send(createHttpRequest('POST', rq));
    }

    public VCC_BridgConsultsRS consults(VCC_BridgConsultsRQ rq) {
        return new VCC_BridgConsultsRS(consultsBase(rq));
    }

    public VCC_BaseClient.BaseResponse flagsBase(VCC_BridgFlagsRQ rq) {
        if (!rq.isValid()) {
            throw new InvalidRequestException(INVALID_REQUEST_MSG);
        }
        setServiceName('vccBridgFlags');
        return send(createHttpRequest('POST', rq));
    }

    public VCC_BridgFlagsRS flags(VCC_BridgFlagsRQ rq) {
        return new VCC_BridgFlagsRS(flagsBase(rq));
    }

    public VCC_BaseClient.BaseResponse immunizationBase(VCC_BridgImmunizationRQ rq) {
        if (!rq.isValid()) {
            throw new InvalidRequestException(INVALID_REQUEST_MSG);
        }
        setServiceName('vccBridgImmunizations');
        return send(createHttpRequest('POST', rq));
    }

    public VCC_BridgImmunizationRS immunization(VCC_BridgImmunizationRQ rq) {
        return new VCC_BridgImmunizationRS(immunizationBase(rq));
    }

    public VCC_BaseClient.BaseResponse labsBase(VCC_BridgLabsRQ rq) {
        if (!rq.isValid()) {
            throw new InvalidRequestException(INVALID_REQUEST_MSG);
        }
        setServiceName('vccBridgLabs');
        return send(createHttpRequest('POST', rq));
    }

    public VCC_BridgLabsRS labs(VCC_BridgLabsRQ rq) {
        return new VCC_BridgLabsRS(labsBase(rq));
    }

    public VCC_BaseClient.BaseResponse medsBase(VCC_BridgMedsRQ rq) {
        if (VCC_TrainingModeService.isTrainingModeEnabled()) {
            HttpResponse res = new HttpResponse();
            res.setBody(VCC_TrainingModeService.getMedicationsByAccountId(this.accountId));
            return new BaseResponse(res, this.serviceName, this.appName);
        }

        if (!rq.isValid()) {
            throw new InvalidRequestException(INVALID_REQUEST_MSG);
        }

        setServiceName('vccBridgMeds');
        // todo: dev mode
        return send(createHttpRequest('POST', rq));
    }

    public VCC_BridgMedsRS meds(VCC_BridgMedsRQ rq) {
        return new VCC_BridgMedsRS(medsBase(rq));
    }

    public VCC_BaseClient.BaseResponse notesBase(VCC_BridgNotesRQ rq) {
        if (!rq.isValid()) {
            throw new InvalidRequestException(INVALID_REQUEST_MSG);
        }
        setServiceName('vccBridgNotes');
        return send(createHttpRequest('POST', rq));
    }

    public VCC_BridgNotesRS notes(VCC_BridgNotesRQ rq) {
        return new VCC_BridgNotesRS(notesBase(rq));
    }

    public VCC_BaseClient.BaseResponse ordersBase(VCC_BridgOrdersRQ rq) {
        if (!rq.isValid()) {
            throw new InvalidRequestException(INVALID_REQUEST_MSG);
        }
        setServiceName('vccBridgOrders');
        return send(createHttpRequest('POST', rq));
    }

    public VCC_BridgOrdersRS orders(VCC_BridgOrdersRQ rq) {
        return new VCC_BridgOrdersRS(ordersBase(rq));
    }

    public VCC_BaseClient.BaseResponse problemsBase(VCC_BridgProblemsRQ rq) {
        if (!rq.isValid()) {
            throw new InvalidRequestException(INVALID_REQUEST_MSG);
        }
        setServiceName('vccBridgProblems');
        return send(createHttpRequest('POST', rq));
    }

    public VCC_BridgProblemsRS problems(VCC_BridgProblemsRQ rq) {
        return new VCC_BridgProblemsRS(problemsBase(rq));
    }

    public VCC_BaseClient.BaseResponse radiologyExamsBase(VCC_BridgRadiologyExamsRQ rq) {
        if (!rq.isValid()) {
            throw new InvalidRequestException(INVALID_REQUEST_MSG);
        }
        setServiceName('vccBridgradiologyExams');
        return send(createHttpRequest('POST', rq));
    }

    public VCC_BridgRadiologyExamsRS radiologyExams(VCC_BridgRadiologyExamsRQ rq) {
        return new VCC_BridgRadiologyExamsRS(radiologyExamsBase(rq));
    }

    public VCC_BaseClient.BaseResponse visitsBase(VCC_BridgVisitsRQ rq) {
        if (!rq.isValid()) {
            throw new InvalidRequestException(INVALID_REQUEST_MSG);
        }
        setServiceName('vccBridgVisit');
        return send(createHttpRequest('POST', rq));
    }

    public VCC_BridgVisitsRS visits(VCC_BridgVisitsRQ rq) {
        return new VCC_BridgVisitsRS(visitsBase(rq));
    }

    public VCC_BaseClient.BaseResponse vitalsBase(VCC_BridgVitalsRQ rq) {
        if (!rq.isValid()) {
            throw new InvalidRequestException(INVALID_REQUEST_MSG);
        }
        setServiceName('vccBridgVitals');
        return send(createHttpRequest('POST', rq));
    }

    public VCC_BridgVitalsRS vitals(VCC_BridgVitalsRQ rq) {
        return new VCC_BridgVitalsRS(vitalsBase(rq));
    }

    public VCC_BridgClient() {
        super();
        setAppName('Bridg');
    }

    public VCC_BridgClient(Id accountId) {
        super();
        this.accountId = accountId;
        setAppName('Bridg');
    }

    public VCC_BridgClient(Set<VCC_BaseClient.ClientOption> options) {
        super(options);
        setAppName('Bridg');
    }

    private class InvalidRequestException extends Exception {
    }
    private class BridgClientException extends Exception {
    }
}
