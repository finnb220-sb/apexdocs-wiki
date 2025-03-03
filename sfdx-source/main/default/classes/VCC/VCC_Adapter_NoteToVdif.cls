/**
 * @description This description is a stub and should be replaced, but I can't abide by suppressing all ApexDoc errors at a class level.
 */
public with sharing class VCC_Adapter_NoteToVdif {
    @InvocableMethod(Label='Write To VDIF' Category='Notes' Callout=true)
    public static List<String> writeNote(List<Parameters> paramsList) {
        List<String> returnStrings = new List<String>();
        List<VCC_Progress_Note__c> pnList = new List<VCC_Progress_Note__c>();
        for (Parameters params : paramsList) {
            if (params.noteSObject instanceof VCC_Addendum__c) {
                String returnString = VCC_NoteService.createAddendum(
                        parse(
                            params,
                            new VCC_ProgressNoteCustomSectionSelector()
                                .selectByParentConfigId(params.progressNoteConfig.Id)
                        ),
                        params.noteAndEncounterParams,
                        params.patientAndProviderParams,
                        params.noteSObject.Id
                    )
                    ?.text;
                returnStrings.add(returnString);
            } else if (params.noteSObject instanceof VCC_Progress_Note__c) {
                String returnString = VCC_NoteService.writeNote(
                        parse(
                                params,
                                new VCC_ProgressNoteCustomSectionSelector()
                                    .selectByParentConfigId(params.progressNoteConfig.Id)
                            )
                            .replace('<br>', ''),
                        params.noteAndEncounterParams,
                        params.patientAndProviderParams,
                        params.noteSObject.Id
                    )
                    ?.id;
                returnStrings.add(returnString);
                if (VCC_NoteParserService.didReplaceCharacters == true) {
                    VCC_Progress_Note__c vccProgressNote = new VCC_Progress_Note__c(
                        Id = params.noteSObject.Id,
                        VCC_CRM_System_Modified_Output_To_VistA__c = true,
                        VCC_Relative_Type__c = ((VCC_Progress_Note__c) params.noteSObject).VCC_Relative_Type__c
                    );
                    pnList.add(vccProgressNote);
                }
            }
        }

        if (!pnList.isEmpty()) {
            if (Schema.SObjectType.VCC_Progress_Note__c.isUpdateable()) {
                Database.update(pnList, true, System.AccessLevel.USER_MODE); //NOPMD
            }
        }
        return returnStrings;
    }

    @SuppressWarnings('PMD.ApexDoc')
    @AuraEnabled(Cacheable=false)
    public static List<String> parseLWC(String pnId, String pnRtId) {
        VCC_Progress_Note__c progressNote = new VCC_Progress_Note__c();
        progressNote.Id = pnId;
        progressNote.RecordTypeId = pnRtId;
        // Get Config
        VCC_Progress_Note_Configuration__mdt config = VCC_ProgressNoteService.getConfig(progressNote);
        // Prep our params
        Parameters params = new Parameters();
        params.progressNoteConfig = config;
        params.noteSObject = progressNote;
        params.noteAndEncounterParams = new VCC_Vdif_NoteAndEncounterParams();
        params.patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();

        //new
        List<String> nToVdiffList = new List<String>();
        nToVdiffList.add(
            VCC_Adapter_NoteToVdif.parse(
                    params,
                    new VCC_ProgressNoteCustomSectionSelector().selectByParentConfigId(params.progressNoteConfig.Id)
                )
                .replace('<br>', '')
        );
        // Parse
        return nToVdiffList;
    }

    @SuppressWarnings('PMD.ApexDoc')
    public static String parse(Parameters params, List<VCC_Progress_Note_Custom_Section__mdt> customSections) {
        //get layout info
        VCC_LayoutService.LayoutInfo layoutInfo = VCC_AdapterUtils_Note.getLayoutInfo(
            params.noteSObject.getSObjectType(),
            params.progressNoteConfig
        );

        //get missing data, if any
        params.noteSObject = VCC_AdapterUtils_Note.prepNote(
            params.noteSObject,
            VCC_AdapterUtils_Note.getAllFieldNames(layoutInfo, customSections)
        );

        String t2tDataVDIF = VCC_T2T_Adapter_Record2JSON.prepVDIFT2TData(params.noteSObject.Id);
        if (t2tDataVDIF != null) {
            return (new VCC_VdifNoteParser(params.noteSObject))
                    .parse(layoutInfo.sectionHashToSectionMap.values(), customSections) + t2tDataVDIF;
        }
        return (new VCC_VdifNoteParser(params.noteSObject))
            .parse(layoutInfo.sectionHashToSectionMap.values(), customSections);
    }

    //    /** adding for DAS */
    public static String parse(
        SObject noteSObject,
        VCC_Progress_Note_Configuration__mdt progressNoteConfig,
        List<VCC_Progress_Note_Custom_Section__mdt> customSections
    ) {
        Parameters params = new Parameters();
        params.noteSObject = noteSObject;
        params.progressNoteConfig = progressNoteConfig;
        return parse(params, customSections).replace('<br>', '');
    }

    @SuppressWarnings('PMD.ApexDoc')
    public class Parameters {
        @InvocableVariable
        public VCC_Progress_Note_Configuration__mdt progressNoteConfig;

        @InvocableVariable
        public SObject noteSObject;

        @InvocableVariable
        public VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams;

        @InvocableVariable
        public VCC_Vdif_PatientAndProviderParams patientAndProviderParams;
    }
}
