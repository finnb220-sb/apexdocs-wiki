Map<String, Object> args = new Map<String, Object> {
        'application' => 'VAHC',
        'icn' => '1013671689V449569',
        'facilityId' => '982'
};
VTC_RecordModel model = (VTC_RecordModel) new VTC_PatientService().call('get_temp_address', args);
System.debug(JSON.serializePretty(model));