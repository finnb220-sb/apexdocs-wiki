public with sharing class VCC_PatientServiceV2 {
    public static VCC_PatientServiceV2 instance {
        get {
            if (privateInstance != null) {
                return privateInstance;
            }
            privateInstance = new VCC_PatientServiceV2();
            return privateInstance;
        }
    }

    @TestVisible
    private static VCC_PatientServiceV2 privateInstance;

    @TestVisible
    private static VCC_Stub stub() {
        VCC_Stub patientServiceStub = new VCC_Stub(VCC_PatientServiceV2.class);
        VCC_PatientServiceV2.privateInstance = (VCC_PatientServiceV2) patientServiceStub.instance;
        return patientServiceStub;
    }

    public String getLocalPidForSite(Id accountId, String siteCode) {
        Account patientAccount = new VCC_AccountSelector().selectById(new Set<Id>{ accountId })[0];
        if (String.isBlank(patientAccount.VCC_MVI_External_Id__pc)) {
            return null;
        }
        return getLocalPidForSite(patientAccount.VCC_MVI_External_Id__pc, siteCode);
    }

    public String getLocalPidForSite(String icn, String siteCode) {
        if (String.isBlank(icn)) {
            return null;
        }
        VCC_MpiRetrieveRQ retrieveRQ = new VCC_MpiRetrieveRQ();
        retrieveRQ.id = icn;
        retrieveRQ.idType = 'ICN';
        retrieveRQ.userId = 'VAHC CRM';
        VCC_MpiRetrieveRS retrieveRS = (new VCCMPIClient()).mpiRetrieve(retrieveRQ);

        if (retrieveRS.vets == null || retrieveRS.vets.size() == 0) {
            return null;
        }
        for (VCC_MpiRetrieveRS.MedicalCenterFacility facility : retrieveRS.vets[0].medicalCenterFacilities) {
            if (facility.facilityId == siteCode) {
                return facility.personId;
            }
        }
        return null;
    }

    public List<VCC_PatientVisit> getVisitsByDate(String MVI_Id, String startDate, String stopDate) {
        VCC_BridgVisitsRQ rq = new VCC_BridgVisitsRQ(MVI_Id, 'USVHA');
        rq.startDate = startDate;
        rq.stopDate = stopDate;

        VCC_BridgVisitsRS rs = (new VCC_BridgClient(
                new Set<VCC_BaseClient.ClientOption>{ VCC_BaseClient.ClientOption.DEBUG_MODE }
            ))
            .visits(rq);

        List<VCC_PatientVisit> patientVisitList = new List<VCC_PatientVisit>();

        if (rs?.sites != null) {
            for (VCC_BridgVisitsRS.VisitSite vs : rs.sites) {
                if (vs?.data?.items != null) {
                    for (VCC_BridgVisitsRS.VisitItem vi : vs.data.items) {
                        patientVisitList.add(new VCC_PatientVisit(vi));
                    }
                }
            }
        }

        return patientVisitList;
    }

    public List<VCC_PatientVisit> getVisitsByDate(String MVI_Id, DateTime startDate, DateTime stopDate) {
        return getVisitsByDate(MVI_Id, startDate.format('yyyy-MM-dd'), stopDate.format('yyyy-MM-dd'));
    }

    public List<VCC_PatientVisit> getAllVisits(String MVI_Id) {
        return getVisitsByDate(MVI_Id, '', '');
    }

    public List<VCC_PatientAllergy> getAllergies(String MVI_Id) {
        VCC_BridgAllergyRQ rq = new VCC_BridgAllergyRQ(MVI_Id, 'USVHA');

        VCC_BridgAllergyRS rs = (new VCC_BridgClient()).allergy(rq);

        List<VCC_PatientAllergy> patientAllergyList = new List<VCC_PatientAllergy>();

        for (VCC_BridgAllergyRS.ClinicalDataPatient patient : rs.clinicalData.patient) {
            for (VCC_BridgAllergyRS.IntoleranceCondition intoleranceCondition : patient.intoleranceConditions) {
                patientAllergyList.add(new VCC_PatientAllergy(intoleranceCondition));
            }
        }

        return patientAllergyList;
    }

    public VCC_VdifSelectPatientRS.VisitRelatedTO getVisitRelatedTos(
        VCC_Vdif_PatientAndProviderParams patientAndProviderParams,
        Id recordId
    ) {
        VCC_VdifSelectPatientRQ selectPatientRQ = new VCC_VdifSelectPatientRQ(
            String.valueOf(patientAndProviderParams.providerLoginSiteCode),
            String.valueOf(patientAndProviderParams.providerName),
            String.valueOf(patientAndProviderParams.providerUserId),
            String.valueOf(patientAndProviderParams.patientLocalPid),
            String.valueOf(patientAndProviderParams.patientLocalSiteId)
        );
        selectPatientRQ.recordId = recordId;
        VCC_VdifSelectPatientRS selectPatientRS = (new VCC_VdifClient()).selectPatient(selectPatientRQ);

        return selectPatientRS?.patientTOList[0]?.patientTO?.visitrelatedTos;
    }

    class PatientServiceException extends Exception {
    }
}
