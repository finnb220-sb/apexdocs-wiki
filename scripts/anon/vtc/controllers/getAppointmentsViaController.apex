Map<String, Object> args = new Map<String, Object>{
    'icn' => '1012638924V546709',
    'startDate' => '2023-06-21', //String.valueOf(Date.newInstance(2023, 6, 20)),
    'stopDate' => '2024-06-21'
};
VCR_HealthDataRepo.Model model = VCC_AppointmentController.fetchHealthDataConfig('1012638924V546709');
System.debug('fetchHealthDataConfig: ' + JSON.serializePretty(model));

VTC_DataModel model2 = (VTC_DataModel) VCC_AppointmentController.fetchAppointments(args);
System.debug('fetchAppointments: ' + JSON.serializePretty(model2));
