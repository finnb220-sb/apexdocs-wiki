Map<String, Object> args = new Map<String, Object> {
        'application' => 'VAHC',
        'icn' => 'abc123',
        'facilityId' => '982'
};
VTC_DataModel model = (VTC_DataModel) new VTC_PatientService().call('get_labs', args);
System.debug(JSON.serializePretty(model));