Map<String, Object> args = new Map<String, Object> {
        'application' => 'VAHC',
        'facilityId' => new List<String> { '982', '983', '984'},
        'parseAlert' => true
};
VTC_RecordModel model = (VTC_RecordModel) new VTC_PatientService().call('get_alerts', args);
System.debug(JSON.serializePretty(model));