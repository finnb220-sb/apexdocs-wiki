@isTest
public with sharing class VCC_BridgAppointmentsRSTest {
    @isTest
    public static void instantiationTest() {
        Test.startTest();
        System.assert(new VCC_BridgAppointmentsRS() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgAppointmentsRS.AppointmentsData() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgAppointmentsRS.Patients() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgAppointmentsRS.AppointmentsDataPatient() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgAppointmentsRS.Appointments() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgAppointmentsRS.Appointment() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgAppointmentsRS(new VCC_BaseClient.BaseResponse()) != null, 'Instantiation failed.');
        Test.stopTest();
    }
}
