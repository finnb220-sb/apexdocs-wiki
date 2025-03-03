Map<String, Object> args = new Map<String, Object>{
    'icn' => '1012844520V803214',
    'max' => 2,
    'startDate' => Date.newInstance(2019, 1, 1),
    'stopDate' => Date.newInstance(2019, 12, 31),
    'noteType' => VTC_NoteType.RADIOLOGY_REPORT
};
VTC_DataModel model = (VTC_DataModel) VCC_ProgressNoteController.fetchNotes(args);
System.debug(JSON.serializePretty(model));