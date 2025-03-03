Map<String, Object> args = new Map<String, Object>{
    'application' => 'VAHC',
    'icn' => '1012638924V546709',
    'facilityId' => '982',
    'startDate' => '2004-07-24',
    'stopDate' => '2024-07-24'
};
VTC_DataModel model = (VTC_DataModel) new VTC_PatientService().call('get_problems', args);
System.debug(JSON.serializePretty(model));

String jsonModel = JSON.serialize(model);
System.debug('snomedClinicalTermDescription Count::: ' + jsonModel.countMatches('snomedClinicalTermDescription'));

