Map<String, Object> args = new Map<String, Object> {
    'icn' => 'abc123',
    'facilityId' => '982'
};
VTC_DataModel model = (VTC_DataModel) VCC_RadiologyController.fetchRadiology(args);
System.debug(JSON.serializePretty(model));