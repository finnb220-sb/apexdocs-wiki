@isTest
public with sharing class VCC_VdifSelectPatientRSTest {
    @isTest
    public static void instantiationTest() {
        VCC_VdifSelectPatientRS selectPatientRS = new VCC_VdifSelectPatientRS();

        System.assert(selectPatientRS != null, 'Response did not instantiate as expected.');
        System.assert(selectPatientRS.patientTO != null, 'Response did not instantiate as expected.');

        System.assert(new VCC_VdifSelectPatientRS.PatientTO() != null, 'Response did not instantiate as expected.');
        System.assert(new VCC_VdifSelectPatientRS.VisitRelatedTO() != null, 'Response did not instantiate as expected.');
        System.assert(new VCC_VdifSelectPatientRS.AddressTO() != null, 'Response did not instantiate as expected.');
        System.assert(new VCC_VdifSelectPatientRS.PhoneNumTO() != null, 'Response did not instantiate as expected.');
        System.assert(new VCC_VdifSelectPatientRS.DemographicSetTO() != null, 'Response did not instantiate as expected.');
        System.assert(new VCC_VdifSelectPatientRS.PersonArray() != null, 'Response did not instantiate as expected.');
        System.assert(new VCC_VdifSelectPatientRS.HospitalLocationTO() != null, 'Response did not instantiate as expected.');
        System.assert(new VCC_VdifSelectPatientRS.Team() != null, 'Response did not instantiate as expected.');
        System.assert(new VCC_VdifSelectPatientRS.SiteTO() != null, 'Response did not instantiate as expected.');
        System.assert(new VCC_VdifSelectPatientRS.TimeSlotArray() != null, 'Response did not instantiate as expected.');
        System.assert(new VCC_VdifSelectPatientRS.ArrayOfTimeSlotTO() != null, 'Response did not instantiate as expected.');
        System.assert(new VCC_VdifSelectPatientRS.TimeSlotTO() != null, 'Response did not instantiate as expected.');
        System.assert(new VCC_VdifSelectPatientRS.DataSourceArray() != null, 'Response did not instantiate as expected.');
        System.assert(new VCC_VdifSelectPatientRS.DataSourceTO() != null, 'Response did not instantiate as expected.');
        System.assert(new VCC_VdifSelectPatientRS.SiteArray() != null, 'Response did not instantiate as expected.');
        System.assert(new VCC_VdifSelectPatientRS.ArrayOfSiteTO() != null, 'Response did not instantiate as expected.');
        System.assert(new VCC_VdifSelectPatientRS.ArrayOfPersonTO() != null, 'Response did not instantiate as expected.');
        System.assert(new VCC_VdifSelectPatientRS.PersonTO() != null, 'Response did not instantiate as expected.');
        System.assert(new VCC_VdifSelectPatientRS.ArrayOfAddressTO() != null, 'Response did not instantiate as expected.');
        System.assert(new VCC_VdifSelectPatientRS.ArrayOfPhoneNumTO() != null, 'Response did not instantiate as expected.');
        System.assert(new VCC_VdifSelectPatientRS.ArrayOfEmailAddresses() != null, 'Response did not instantiate as expected.');
        System.assert(new VCC_VdifSelectPatientRS.ArrayOfDemographicNames() != null, 'Response did not instantiate as expected.');
    }
}
