/**
 * @description Modifies provider inforomation of a given vdifParameters object. Also provides test/dummy data
 *
 * @author Liberty
 * @since 01/09/2024
 * @group VAHC
 */
@SuppressWarnings('PMD.ExcessiveParameterList')
public with sharing class VCC_VdifParametersDomain {
    /**
     * @description For testing, populates a vdifParameter object with test data for vdifNote and vdifPatient sections
     *
     * @param vdifParameters
     * @param testConfigurationData
     */
    public void addDataFromTestConfig(VCC_VdifParameters vdifParameters, VCC_Test_Configuration_Data__C testConfigurationData) {
        this.populateVdifNote(vdifParameters.vdifNote, testConfigurationData);
        this.populateVdifPatient(vdifParameters.vdifPatient, testConfigurationData);
    }

    @TestVisible
    private void populateVdifNote(VCC_VdifNote vdifNote, VCC_Test_Configuration_Data__C testConfigurationData) {
        //vdifNote
        if (testConfigurationData.VCC_Additional_Signer_IEN__c != null) {
            vdifNote.additionalSigners = new List<String>{ testConfigurationData.VCC_Additional_Signer_IEN__c };
        }
        vdifNote.noteTitleIen = testConfigurationData.VCC_Note_Title_IEN__c;
        vdifNote.text = testConfigurationData.VCC_Note_Text__c;
    }

    @TestVisible
    private void populateVdifPatient(VCC_VdifPatient vdfiPatient, VCC_Test_Configuration_Data__C testConfigurationData) {
        //vdifPatient
        vdfiPatient.siteCode = testConfigurationData.VCC_Site_Code__c;
        if (String.isNotBlank(testConfigurationData.VCC_ICN__c)) {
            vdfiPatient.pid = VCC_PatientServiceV2.instance.getLocalPidForSite(testConfigurationData.VCC_ICN__c, testConfigurationData.VCC_Site_Code__c);
        } else {
            if (String.isNotBlank(testConfigurationData.VCC_Account_Id__c)) {
                vdfiPatient.pid = VCC_PatientServiceV2.instance.getLocalPidForSite(testConfigurationData.VCC_Account_Id__c, testConfigurationData.VCC_Site_Code__c);
            }
        }
        vdfiPatient.name = testConfigurationData.VCC_Site_Code__c + ' Patient';
    }

    /**
     * @description Populates the provided vdifParameters object with provider based on arguments passed in.
     * also assigns the esig, site code, and token
     *
     * @param vdifParameters
     * @param esig
     * @param siteCode
     * @param duz
     * @param token
     */
    public void populateProviderInfo(VCC_VdifParameters vdifParameters, String esig, String siteCode, String duz, String token) {
        vdifParameters.vdifProvider.name = UserInfo.getLastName() + ', ' + UserInfo.getFirstName();
        if (String.isBlank(duz)) {
            vdifParameters.vdifProvider.duz = VCC_ProviderServiceV2.instance.getProviderDuz(UserInfo.getUserId(), siteCode);
        } else {
            vdifParameters.vdifProvider.duz = duz;
        }
        vdifParameters.vdifProvider.esig = esig;
        vdifParameters.vdifProvider.siteCode = siteCode;
        vdifParameters.vdifProvider.token = token;
    }

    @TestVisible
    private void fillParametersWithDummyData(VCC_VdifParameters vdifParameters) {
        if (vdifParameters == null) {
            return;
        }
        vdifParameters.vdifNote.additionalSigners = new List<String>{ 'test' };
        vdifParameters.vdifNote.itemId = 'test';
        vdifParameters.vdifNote.encounterString = 'test';
        vdifParameters.vdifNote.noteTitleIen = 'test';
        vdifParameters.vdifNote.text = 'test';
        vdifParameters.vdifNote.consultIen = 'test';
        vdifParameters.vdifNote.prfIen = 'test';

        vdifParameters.vdifEncounter.noteTitleIen = 'test';
        vdifParameters.vdifEncounter.locationIen = 'test';
        vdifParameters.vdifEncounter.consultIen = 'test';
        vdifParameters.vdifEncounter.serviceCategory = 'test';
        vdifParameters.vdifEncounter.providers = 'test';
        vdifParameters.vdifEncounter.procedures = 'test';
        vdifParameters.vdifEncounter.diagnoses = 'test';
        vdifParameters.vdifEncounter.immunizations = 'test';
        vdifParameters.vdifEncounter.healthFactors = 'test';
        vdifParameters.vdifEncounter.visitRelatedTos = 'test';
        vdifParameters.vdifEncounter.comments = 'test';

        vdifParameters.vdifPatient.pid = 'test';
        vdifParameters.vdifPatient.siteCode = 'test';
        vdifParameters.vdifPatient.name = 'test';

        vdifParameters.vdifProvider.duz = 'test';
        vdifParameters.vdifProvider.cosignerDuz = 'test';
        vdifParameters.vdifProvider.token = 'test';
        vdifParameters.vdifProvider.esig = 'test';
        vdifParameters.vdifProvider.siteCode = 'test';
        vdifParameters.vdifProvider.name = 'test';
    }
}
