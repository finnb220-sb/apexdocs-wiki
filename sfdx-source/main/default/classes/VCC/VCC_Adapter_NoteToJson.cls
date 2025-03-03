public with sharing class VCC_Adapter_NoteToJson {
    @InvocableMethod(label='Convert to Json' category='Notes')
    public static List<String> parse(List<Parameters> paramsList) {
        List<String> parsedNotes = new List<String>();
        String t2tId = ''; //Id identifier for T2T
        for (Parameters params : paramsList) {
            parsedNotes.add(parse(params, new VCC_ProgressNoteCustomSectionSelector().selectByParentConfigId(params.progressNoteConfig.Id)).replace('<br>', ''));
            t2tId = params.noteSObject.Id; //Assignment of t2t recordId
        }
        String t2tData = VCC_T2T_Adapter_Record2JSON.T2TData(t2tId); //fetch data
        if (t2tData != null) {
            parsedNotes[0] = parsedNotes[0].substring(0, parsedNotes[0].length() - 1);
            //remove the terminating bracket from this json string to append t2t data -- preview only
            t2tData = t2tData.substring(1, t2tData.length() - 1);
            // Append the T2T data JSON string to the existing parsed notes JSON string
            parsedNotes[0] += ',' + t2tData + ']';
        }
        return parsedNotes;
    }

    public static String parse(Parameters params, List<VCC_Progress_Note_Custom_Section__mdt> customSections) {
        //get layout info
        VCC_LayoutService.LayoutInfo layoutInfo = VCC_AdapterUtils_Note.getLayoutInfo(params.noteSObject.getSObjectType(), params.progressNoteConfig);

        //get missing data, if any
        params.noteSObject = VCC_AdapterUtils_Note.prepNote(params.noteSObject, VCC_AdapterUtils_Note.getAllFieldNames(layoutInfo, customSections));

        return (new VCC_JsonNoteParser(params.noteSObject, params.progressNoteConfig)).parse(layoutInfo.sectionHashToSectionMap.values(), customSections);
    }

    public class Parameters {
        @InvocableVariable
        public VCC_Progress_Note_Configuration__mdt progressNoteConfig;

        @InvocableVariable
        public SObject noteSObject;
    }
}
