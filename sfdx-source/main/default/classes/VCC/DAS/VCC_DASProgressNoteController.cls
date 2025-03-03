/**
 * @description The DAS-equilvalent to VCC_ProgressNoteController. Created around the ~1.5/1.6 release
 * when DAS integration was first introduced. Effectively this class just converts `ActionParams` into
 * the DAS flow invocable.
 *
 * @author Booz Allen Hamilton
 */
@SuppressWarnings('PMD.ClassNamingConventions')
public with sharing class VCC_DASProgressNoteController {
    /**
     * @description Input for the @InvocableMethod 'progressNoteAction' in this same parent class
     */
    public class ActionParams {
        @InvocableVariable
        public String actionName;

        @InvocableVariable
        public VCC_Progress_Note__c pnRecord;

        @InvocableVariable
        public VCC_Addendum__c addendumRecord;

        @InvocableVariable
        public VCC_Vdif_PatientAndProviderParams patientAndProviderParams;

        @InvocableVariable
        public VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams;
    }

    @InvocableMethod(Category='Progress Note' Callout=true)
    /**
     * @description @InvocableMethod called from the flow 'VCC_DAS_Sign_Progress_Note_with_Callouts'
     * @param params an instance of `ActionParams` in this same parent class
     * @return A `List<String>`
     */
    public static List<String> progressNoteAction(List<ActionParams> params) {
        //creating these variables for easier code readability
        ActionParams param = params[0];

        List<String> stringListToReturn = new List<String>();

        if (params.size() == 1) {
            switch on param.actionName {
                when 'ValidateEsig' {
                    stringListToReturn.add(validateEsig(param));
                }
                when 'WriteNote' {
                    //VCC_DASFlowWriteNote is invoked directly from the flow to match original vdif flow (as of 07/18/2023)
                    stringListToReturn.add('');
                }
                when 'CreateEncounter' {
                    stringListToReturn.add(createEncounter(param));
                }
                when 'SignNote' {
                    stringListToReturn.add(signNote(param));
                }
                when 'GetNoteText' {
                    //VCC_Adapter_NoteToJson is invoked directly from the flow (at time of writing, 07/18/2023)
                    stringListToReturn.add('');
                }
                when 'AddSigners' {
                    stringListToReturn.add(addSigners(param));
                }
                when 'CreateAddendum' {
                    //VCC_DASFlowCreateAddendum is invoked directly from the flow to match original vdif flow (as of 07/18/2023)
                    stringListToReturn.add('');
                }
                when 'GetVisitRelatedTos' {
                    stringListToReturn.add(selectPatient(param));
                }
                when 'GetEncounterString' {
                    stringListToReturn.add(getEncounterString(param));
                }
                when else {
                    throw new ProgressNoteControllerException(
                        param.actionName + ' doesn\'t exist or has not been configured.'
                    );
                }
            }
        }
        return stringListToReturn;
    }

    /**
     * @description Wrapper calling method of the same name on VCC_ProgressNoteController
     * @param progressNoteOrAddendum
     * @param providers
     */
    public static void createSigners(Id progressNoteOrAddendum, List<VCC_VDIFResponseParser.ProviderTO> providers) {
        VCC_ProgressNoteController.createSigners(progressNoteOrAddendum, providers);
    }

    /**
     * @description Builds `VCC_DASFlowIsValidEsig.Request` and invokes that invocable method.
     * @param param
     * @return `String`
     */
    public static String validateEsig(ActionParams param) {
        VCC_DASFlowIsValidEsig.Request flowIsValidEsigRequest = new VCC_DASFlowIsValidEsig.Request();

        flowIsValidEsigRequest.criteria = param?.patientAndProviderParams?.eSig;
        flowIsValidEsigRequest.providerLoginSiteCode = param?.patientAndProviderParams?.providerLoginSiteCode;
        flowIsValidEsigRequest.providerName = param?.patientAndProviderParams?.providerName;
        flowIsValidEsigRequest.providerUserId = param?.patientAndProviderParams?.providerUserId;
        flowIsValidEsigRequest.recordId = param?.addendumRecord?.Id ?? param?.pnRecord?.Id;
        Boolean isValid = VCC_DASFlowIsValidEsig.isValidEsig(
                new List<VCC_DASFlowIsValidEsig.Request>{ flowIsValidEsigRequest }
            )[0]
            .isValid;
        return (isValid == true) ? 'True' : 'False'; //flow expects the return value in this format
    }

    /**
     * @description Builds `VCC_DASFlowSaveNoteAndEncounter.Request` and invokes the invocable method.
     * @param param
     * @return `String`
     */
    public static String createEncounter(ActionParams param) {
        VCC_DASFlowSaveNoteAndEncounter.Request flowSaveNoteAndEncounterRequest = new VCC_DASFlowSaveNoteAndEncounter.Request();
        flowSaveNoteAndEncounterRequest.noteAndEncounterLocationIen = param
            ?.noteAndEncounterParams
            ?.noteAndEncounterLocationIen;
        flowSaveNoteAndEncounterRequest.noteAndEncounterNoteTitleIen = param
            ?.noteAndEncounterParams
            ?.noteAndEncounterNoteTitleIen;
        flowSaveNoteAndEncounterRequest.providerUserId = param?.patientAndProviderParams?.providerUserId;
        flowSaveNoteAndEncounterRequest.patientLocalPid = String.valueOf(
            param?.patientAndProviderParams?.patientLocalPid
        );
        flowSaveNoteAndEncounterRequest.patientLocalSiteId = param?.patientAndProviderParams?.patientLocalSiteId;
        flowSaveNoteAndEncounterRequest.primaryDiagnosis = param?.noteAndEncounterParams?.primaryDiagnosis;
        flowSaveNoteAndEncounterRequest.secondaryDiagnosis = param?.noteAndEncounterParams?.secondaryDiagnosis;
        flowSaveNoteAndEncounterRequest.procedureCode = param?.noteAndEncounterParams?.procedureCode;
        flowSaveNoteAndEncounterRequest.noteAndEncounterVisitRelatedTos = (param
                ?.noteAndEncounterParams
                ?.noteAndEncounterVisitRelatedTos == null)
            ? ''
            : param.noteAndEncounterParams.noteAndEncounterVisitRelatedTos;
        flowSaveNoteAndEncounterRequest.patientName = param?.patientAndProviderParams?.patientName;
        flowSaveNoteAndEncounterRequest.recordId = (param?.addendumRecord?.Id == null)
            ? param?.pnRecord?.Id
            : param.addendumRecord.Id;
        VCC_DASFlowSaveNoteAndEncounter.Result flowSaveNoteAndEncounterResult = VCC_DASFlowSaveNoteAndEncounter.saveNoteAndEncounter(
            new List<VCC_DASFlowSaveNoteAndEncounter.Request>{ flowSaveNoteAndEncounterRequest }
        )[0];
        return flowSaveNoteAndEncounterResult.text;
    }

    /**
     * @description Builds `VCC_DASFlowGetAdditionalSigners.Request` and invokes that invocable
     * @param param
     * @return `String`
     */
    public static String addSigners(ActionParams param) {
        VCC_Progress_Note__c pnRecord = param?.pnRecord;
        VCC_Addendum__c addendumRecord = param?.addendumRecord;
        VCC_DASFlowGetAdditionalSigners.Request flowGetAdditionalSignersRequest = new VCC_DASFlowGetAdditionalSigners.Request();
        flowGetAdditionalSignersRequest.itemId = param?.noteAndEncounterParams?.itemId;
        flowGetAdditionalSignersRequest.providerLoginSiteCode = param?.patientAndProviderParams?.providerLoginSiteCode;
        flowGetAdditionalSignersRequest.providerUserId = param?.patientAndProviderParams?.providerUserId;
        flowGetAdditionalSignersRequest.recordId = addendumRecord?.Id ?? pnRecord?.Id;
        if (VCC_Named_Toggle__mdt.getInstance('New_Vista_User_Search').VCC_State__c == false || Test.isRunningTest()) {
            if (
                param?.noteAndEncounterParams?.supplementalParameters != null &&
                param?.noteAndEncounterParams?.supplementalParameters != ''
            ) {
                List<VCC_VDIFResponseParser.ProviderTO> pvds = (List<VCC_VDIFResponseParser.ProviderTO>) JSON.deserialize(
                    param?.noteAndEncounterParams?.supplementalParameters,
                    List<VCC_VDIFResponseParser.ProviderTO>.class
                );
                List<String> supParam = new List<String>();
                for (VCC_VDIFResponseParser.ProviderTO provider : pvds) {
                    supParam.add(provider.duz);
                }
                if (pnRecord != null) {
                    VCC_DASProgressNoteController.createSigners(pnRecord.Id, pvds);
                } else if (addendumRecord != null) {
                    VCC_DASProgressNoteController.createSigners(addendumRecord.Id, pvds);
                }
            }
        }
        VCC_DASFlowGetAdditionalSigners.getAdditionalSigners(
            new List<VCC_DASFlowGetAdditionalSigners.Request>{ flowGetAdditionalSignersRequest }
        );
        return ''; // this had no return value in the original VCC_ProgressNoteController
    }

    /**
     * @description Builds `VCC_DASFlowGenerateEncounterString.Request` and invokes that invocable method.
     * @param param
     * @return `String`
     */
    public static String getEncounterString(ActionParams param) {
        VCC_DASFlowGenerateEncounterString.Request flowGenerateEncounterStringRequest = new VCC_DASFlowGenerateEncounterString.Request();
        flowGenerateEncounterStringRequest.noteAndEncounterParameters = param?.noteAndEncounterParams;
        return VCC_DASFlowGenerateEncounterString.generateEncounterString(
                new List<VCC_DASFlowGenerateEncounterString.Request>{ flowGenerateEncounterStringRequest }
            )[0]
            .encounterString;
    }

    /**
     * @description Builds `VCC_DASFlowSignNote.Request` and invokes that invocable method.
     * @param param
     * @return `String`
     */
    public static String signNote(ActionParams param) {
        VCC_DASFlowSignNote.Request flowSignNoteRequest = new VCC_DASFlowSignNote.Request();
        flowSignNoteRequest.esig = param?.patientAndProviderParams?.eSig;
        flowSignNoteRequest.noteIEN = param?.noteAndEncounterParams?.itemId;
        flowSignNoteRequest.providerLoginSiteCode = param?.patientAndProviderParams?.providerLoginSiteCode;
        flowSignNoteRequest.providerName = param?.patientAndProviderParams?.providerName;
        flowSignNoteRequest.providerUserId = param?.patientAndProviderParams?.providerUserId;
        flowSignNoteRequest.recordId = (param?.addendumRecord?.Id == null)
            ? param?.pnRecord?.Id
            : param.addendumRecord.Id;
        VCC_DASFlowSignNote.Result flowSignNoteResult = VCC_DASFlowSignNote.signNote(
            new List<VCC_DASFlowSignNote.Request>{ flowSignNoteRequest }
        )[0];
        return flowSignNoteResult.text;
    }

    /**
     * @description Builds `VCC_DASFlowSelectPatient.Request` and invokes that invocable method.
     * @param param
     * @return `String`
     */
    public static String selectPatient(ActionParams param) {
        VCC_DASFlowSelectPatient.Request flowSelectPatientRequest = new VCC_DASFlowSelectPatient.Request();
        flowSelectPatientRequest.providerLoginSiteCode = param?.patientAndProviderParams?.providerLoginSiteCode;
        flowSelectPatientRequest.providerName = param?.patientAndProviderParams?.providerName;
        flowSelectPatientRequest.providerUserId = param?.patientAndProviderParams?.providerUserId;
        flowSelectPatientRequest.patientLocalPid = new List<String>{
            String.valueOf(param?.patientAndProviderParams?.patientLocalPid)
        };
        flowSelectPatientRequest.patientLocalSiteId = param?.patientAndProviderParams?.patientLocalSiteId;
        flowSelectPatientRequest.recordId = param?.pnRecord?.Id;
        VCC_DASFlowSelectPatient.Result flowSelectPatientResult = VCC_DASFlowSelectPatient.selectPatient(
            new List<VCC_DASFlowSelectPatient.Request>{ flowSelectPatientRequest }
        )[0];
        if (flowSelectPatientResult.selectPatientRSList.isEmpty()) {
            return '';
        }
        return JSON.serialize(flowSelectPatientResult?.selectPatientRSList[0]?.patientTO?.visitrelatedTos);
    }

    class ProgressNoteControllerException extends VCC_DASException {
    }
}
