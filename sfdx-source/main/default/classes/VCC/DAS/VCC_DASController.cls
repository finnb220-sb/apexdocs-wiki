/**
 * @description Apex counterpart for the vccDasController lightning web component.
 */
public with sharing class VCC_DASController {
    /**
     * @description LWC-available method that returns the Integration Type for the given site
     * @param siteId the given site
     * @return `String` the integration type 'DAS' or 'VDIF'
     */
    @AuraEnabled(cacheable=true)
    public static String getSiteIntegrationType(Integer siteId) {
        try {
            VCC_Org_Settings__mdt orgSettings = VCC_DAS.SERVICES.METADATA.getOrgSettings();
            VCC_Site_Specific_Configuration__mdt siteConfiguration = VCC_DAS.SERVICES.METADATA.getSiteSpecificConfiguration(
                siteId,
                orgSettings.vccType__c
            );
            return siteConfiguration.VCC_VistA_Integration__c;
        } catch (VCC_DASException dasException) {
            throw dasException;
        } catch (Exception e) {
            throw new GetSiteIntegrationTypeException(e);
        }
    }

    /**
     * @description Input Argument for the method VCC_DASController.selectPatient to address PMD.ExcessiveParameterLimit
     */
    public class SelectPatientInput {
        @AuraEnabled
        public String providerLoginSiteCode;

        @AuraEnabled
        public String providerName;

        @AuraEnabled
        public String providerUserId;

        @AuraEnabled
        public List<String> patientLocalPid;

        @AuraEnabled
        public String patientLocalSiteId;

        @AuraEnabled
        public String recordId;
    }

    @AuraEnabled
    /**
     * @description LWC-available method that calls DAS API selectPatient
     * @param selectPatientInput
     * @return `List<VCC_PatientService.PatientToAura>`
     */
    public static List<VCC_PatientService.PatientToAura> selectPatient(SelectPatientInput selectPatientInput) {
        try {
            VCC_DASSelectPatientRQ dasSelectPatientRq = new VCC_DASSelectPatientRQ();

            dasSelectPatientRq.patientLocalPid = selectPatientInput?.patientLocalPid;
            dasSelectPatientRq.patientLocalSiteId = selectPatientInput?.patientLocalSiteId;
            dasSelectPatientRq.providerLoginSiteCode = selectPatientInput?.providerLoginSiteCode;
            dasSelectPatientRq.providerName = selectPatientInput?.providerName;
            dasSelectPatientRq.providerUserId = selectPatientInput?.providerUserId;

            VCC_DAS das = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId(selectPatientInput?.providerLoginSiteCode),
                    Label.VCC_VAHC_AppName,
                    selectPatientInput?.recordId
                )
            );

            List<VCC_DASSelectPatientRS> dasSelectPatientRs = das.selectPatient(dasSelectPatientRq);

            List<VCC_PatientService.PatientToAura> patientsAuraList = new List<VCC_PatientService.PatientToAura>();

            if (!dasSelectPatientRS.isEmpty()) {
                for (VCC_DASSelectPatientRS patientRS : dasSelectPatientRs) {
                    if (patientRS.patientTO != null) {
                        VCC_PatientService.PatientToAura selectPatientAura = new VCC_PatientService.PatientToAura(
                            patientRS.patientTO
                        );
                        patientsAuraList.add(selectPatientAura);
                    }
                }
            }

            return patientsAuraList;
        } catch (VCC_DASException dasException) {
            throw dasException;
        } catch (Exception e) {
            throw new SelectPatientException(e);
        }
    }

    /**
     * @description Exception class for getSiteIntegrationType method
     */
    public class GetSiteIntegrationTypeException extends VCC_DASException {
    }

    /**
     * @description Exception class for selectPatient method
     */
    public class SelectPatientException extends VCC_DASException {
    }
}
