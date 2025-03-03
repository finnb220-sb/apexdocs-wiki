public with sharing class VCC_PatientVisitService {
    //boilerplate code start
    public static VCC_PatientVisitService instance {
        get {
            if (privateInstance != null) {
                return privateInstance;
            }
            privateInstance = new VCC_PatientVisitService();
            return privateInstance;
        }
    }

    @TestVisible
    private static VCC_PatientVisitService privateInstance;

    @TestVisible
    private static VCC_Stub stub() {
        VCC_Stub patientVisitServiceStub = new VCC_Stub(VCC_PatientVisitService.class);
        VCC_PatientVisitService.privateInstance = (VCC_PatientVisitService) patientVisitServiceStub.instance;
        return patientVisitServiceStub;
    }
    //boilerplate code end

    public final String EXCEPTION_TEMPLATE = 'VCC_PatientVisitService: {0}.';

    public void raiseVisitServiceException(String reason) {
        throw new PatientVisitServiceException(String.format(this.EXCEPTION_TEMPLATE, new List<String>{ reason }));
    }

    public VCC_BridgVisitsRS.VisitItem getVisitByUid(URN visitUrn, String icn) {
        if (visitUrn == null || icn == null) {
            raiseVisitServiceException('Arguments cannot be null');
        }
        if (!VCC_UrnService.instance.isValidUrn(visitUrn) || !visitUrn.namespaceSpecificSection.startsWith('visit')) {
            raiseVisitServiceException('Invalid URN');
        }

        VCC_BridgVisitsRQ visitsRq = new VCC_BridgVisitsRQ();
        visitsRq.nationalId = icn;
        visitsRq.uid = visitUrn.toString();

        HTTPRequest req = new HTTPRequest();
        req.setMethod('POST');
        req.setEndpoint(VCC_EndpointService.getEndpoint('Bridg', 'vccBridgVisit'));
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setHeader('apiKey', '{!$Credential.Password}');
        req.setTimeout(120000);
        req.setBody(JSON.serialize(visitsRq));

        HttpResponse res = VCC_HttpService.send(req);

        if (res.getStatusCode() != 200) {
            throw new VCC_RemoteServiceException(res.getBody());
        }

        VCC_BridgVisitsRS visitRs = (VCC_BridgVisitsRS) JSON.deserialize(res.getBody(), VCC_BridgVisitsRS.class);
        if (
            visitRs.sites.size() == 0 ||
            visitRs.sites[0].data.totalItems == null ||
            Integer.valueOf(visitRs.sites[0].data.totalItems) == 0
        ) {
            raiseVisitServiceException('No visit found for the given uid');
        }

        return visitRs.sites[0].data.items[0];
    }

    public class PatientVisitServiceException extends Exception {
    }
}
