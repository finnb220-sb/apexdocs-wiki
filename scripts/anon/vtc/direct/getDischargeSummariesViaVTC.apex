Map<String, Object> args = new Map<String, Object> {
    'application' => 'VAHC',
    'icn' => '1012638924V546709',
    'startDate'=> '1950-01-01-',
    'stopDate' => '2050-01-01'
};
VTC_DataModel model = (VTC_DataModel) new VTC_PatientService().call('get_discharge_summaries', args);
System.debug(JSON.serializePretty(model));