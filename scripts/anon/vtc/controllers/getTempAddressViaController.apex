Map<String, Object> args = new Map<String, Object> {
    'icn' => '1013671689V449569',
    'facilityId' => '982'
};
VTC_RecordModel model = (VTC_RecordModel) VCC_MedsListController.getTemporaryAddress(args, true);
System.debug(JSON.serializePretty(model));