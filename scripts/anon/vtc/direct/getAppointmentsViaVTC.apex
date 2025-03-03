Map<String, Object> args = new Map<String, Object>{
    'application' => 'VAHC',
    'icn' => '1012638924V546709',
    'startDate' => String.valueOf(Date.newInstance(2023, 1, 1)),
    'stopDate' => String.valueOf(Date.newInstance(2044, 7, 25))
};
VTC_DataModel model = (VTC_DataModel) new VTC_PatientService().call('get_appointments', args);
System.debug(JSON.serializePretty(model));

String jsonModel = JSON.serialize(model);
System.debug('appointmentDateTimeFormatted Count::: ' + jsonModel.countMatches('appointmentDateTimeFormatted'));

// YTOLA - 1013010980V728987
// JARDIN - 1013993052V087544
// Lakxum - 1012835270V798147
// Nwhinten - 1012638940V385618
// Nwhinone - 1012638924V546709

