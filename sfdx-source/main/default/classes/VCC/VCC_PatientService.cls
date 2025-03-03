/**
 * Deprecated 10/18/2022 - Use VCC_PatientServiceV2
 */

public with sharing class VCC_PatientService {
    public static String getVitalsAsString(String accountId, String clientObject) {
        return VCC_lwc_utils.retrieveHDR(accountId, 'vccBridgVitals', clientObject, false);
    }

    public static String getLocalPidForSite(Id accountId, String siteCode) {
        Account patientAccount = new VCC_AccountSelector().selectById(new Set<Id>{ accountId })[0];
        if (String.isBlank(patientAccount.VCC_MVI_External_Id__pc)) {
            return null;
        }
        return getLocalPidForSite(patientAccount.VCC_MVI_External_Id__pc, siteCode);
    }

    public static String getLocalPidForSite(String icn, String siteCode) {
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

    public static List<VCC_PatientVisit> getVisitsByDate(String MVI_Id, String startDate, String stopDate) {
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

    public static List<VCC_PatientVisit> getVisitsByDate(String MVI_Id, DateTime startDate, DateTime stopDate) {
        return getVisitsByDate(MVI_Id, startDate.format('yyyy-MM-dd'), stopDate.format('yyyy-MM-dd'));
    }

    public static List<VCC_PatientVisit> getAllVisits(String MVI_Id) {
        return getVisitsByDate(MVI_Id, '', '');
    }

    public static List<VCC_PatientAllergy> getAllergies(String MVI_Id) {
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

    public static String getVitalsAsString(String accountId) {
        return VCC_lwc_utils.retrieveHDR(accountId, 'vccBridgVitals', 'Account', false);
    }

    public static String getAdditionalSignersBridg(Map<String, Object> params) {
        VCC_BridgAdditionalSignersRS rs = (new VCC_BridgClient())
            .additionalSigners(new VCC_BridgAdditionalSignersRQ(params));
        return JSON.serialize(rs);
    }

    /**
     * @description Used to create SelectPatient RQ with a record Id and calls vdifClient to send HTTP request
     * @param patientAndProviderParams `VCC_Vdif_PatientAndProviderParams` patient params
     * @param recordId `Id` of progress note or addendum
     * @return                         `VCC_VdifSelectPatientRS.VisitRelatedTO`
     */
    @AuraEnabled
    public static VCC_VdifSelectPatientRS.VisitRelatedTO getVisitRelatedTos(
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

    @AuraEnabled
    public static List<PatientToAura> getSELECTPatientData(
        String providerLoginSiteCode,
        String providerName,
        String providerUserId,
        List<String> patientLocalPid,
        String patientLocalSiteId,
        Id recordId
    ) {
        VCC_VdifSelectPatientRQ selectPatientRQ = new VCC_VdifSelectPatientRQ(
            String.valueOf(providerLoginSiteCode),
            String.valueOf(providerName),
            String.valueOf(providerUserId),
            patientLocalPid,
            String.valueOf(patientLocalSiteId)
        );
        selectPatientRQ.recordId = recordId;
        VCC_VdifSelectPatientRS selectPatientRS = (new VCC_VdifClient()).selectPatient(selectPatientRQ);
        List<PatientToAura> patientsAuraList = new List<PatientToAura>();
        for (VCC_VdifSelectPatientRS patientRS : selectPatientRS.patientToList) {
            PatientToAura selectPatientAura = new PatientToAura(patientRS.patientTO);
            patientsAuraList.add(selectPatientAura);
        }
        return patientsAuraList;
    }

    public class PatientToAura {
        public PatientToAura(VCC_VdifSelectPatientRS.patientTO patientTo) {
            this.name = patientTo.name;
            this.dob = patientTo.dob;
            this.ssn = patientTo.ssn;
            this.patientId = patientTO.localPid;
            this.gender = patientTO.gender;
            this.maritalStatus = patientTO.maritalStatus;
            this.serviceConnected = patientTO.serviceConnected;
            this.inpatient = patientTo.inpatient;
            this.patientType = patientTo.patientType;
            this.isVeteran = patientTo.isVeteran;
        }

        public PatientToAura(VCC_DASSelectPatientRS.patientTO patientTo) {
            this.name = patientTo.name;
            this.dob = patientTo.dob;
            this.ssn = patientTo.ssn;
            this.patientId = patientTO.localPid;
            this.gender = patientTO.gender;
            this.maritalStatus = patientTO.maritalStatus;
            this.serviceConnected = patientTO.serviceConnected;
            this.inpatient = patientTo.inpatient;
            this.patientType = patientTo.patientType;
            this.isVeteran = patientTo.isVeteran;
        }

        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public String dob { get; set; }
        @AuraEnabled
        public String patientId { get; set; }
        @AuraEnabled
        public String ssn { get; set; }
        @AuraEnabled
        public String gender { get; set; }
        @AuraEnabled
        public String maritalStatus { get; set; }
        @AuraEnabled
        public Boolean serviceConnected { get; set; }
        @AuraEnabled
        public Boolean inpatient { get; set; }
        @AuraEnabled
        public String patientType { get; set; }
        @AuraEnabled
        public Boolean isVeteran { get; set; }
    }

    class PatientServiceException extends Exception {
    }
}
