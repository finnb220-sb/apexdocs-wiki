Map<String, Object> args = new Map<String, Object> {
    'icn' => '1012638924V546709',
    'facilityId' => '982'
};
VTC_DataModel model = (VTC_DataModel) VCC_LabController.fetchLabs(args);
System.debug(JSON.serializePretty(model));