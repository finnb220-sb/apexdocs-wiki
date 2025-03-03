Map<String, Object> args = new Map<String, Object> {
    'icn' => '1012638924V546709',
};
VTC_DataModel model = VCC_DischargeSummaryController.getDischargeSummary(args);
System.debug(JSON.serializePretty(model));