/**
 * @description This class is dedicated to a flow invocable method saveNoteAndEncounter. It contains the method as well as its input and output types.
 * @author Booz Allen Hamilton
 */

public with sharing class VCC_DASFlowSaveNoteAndEncounter {
    /**
     * @description Used to stub VCC_DASFlowSaveNoteAndEncounter in flow tests
     */
    @TestVisible
    private static VCC_DASFlowSaveNoteAndEncounter flowSaveNoteAndEncounterInstance {
        get {
            return flowSaveNoteAndEncounterInstance = flowSaveNoteAndEncounterInstance ??
                new VCC_DASFlowSaveNoteAndEncounter();
        }
        private set;
    }

    /**
     * @description A method, available to the flow. Performs DAS API saveNoteAndEncounter
     * @param flowSaveNoteAndEncounterRequestList
     * @return `List<Result>`
     */
    @InvocableMethod(label='Save Note And Encounter' description='DAS Integration' callout=true category='DAS')
    public static List<Result> saveNoteAndEncounter(List<Request> flowSaveNoteAndEncounterRequestList) {
        return flowSaveNoteAndEncounterInstance.handleSaveNoteAndEncounter(flowSaveNoteAndEncounterRequestList);
    }

    /**
     * @description Used in flow invocable method to handle flow requests and perform callout.
     * @param flowSaveNoteAndEncounterRequestList
     * @return `List<Result>`
     */

    public List<Result> handleSaveNoteAndEncounter(List<Request> flowSaveNoteAndEncounterRequestList) {
        try {
            Request flowSaveNoteAndEncounterRequest = flowSaveNoteAndEncounterRequestList[0];
            VCC_DASSaveNoteAndEncounterRQ saveNoteAndEncounterRq = new VCC_DASSaveNoteAndEncounterRQ();

            saveNoteAndEncounterRq.providerUserId = flowSaveNoteAndEncounterRequest?.providerUserId;
            saveNoteAndEncounterRq.patientLocalPid = flowSaveNoteAndEncounterRequest?.patientLocalPid?.replace(',', '');
            saveNoteAndEncounterRq.patientName = flowSaveNoteAndEncounterRequest?.patientName;
            saveNoteAndEncounterRq.patientLocalSiteId = flowSaveNoteAndEncounterRequest?.patientLocalSiteId;
            saveNoteAndEncounterRq.noteAndEncounterLocationIen = flowSaveNoteAndEncounterRequest
                ?.noteAndEncounterLocationIen;
            saveNoteAndEncounterRq.noteAndEncounterNoteTitleIen = flowSaveNoteAndEncounterRequest
                ?.noteAndEncounterNoteTitleIen;
            saveNoteAndEncounterRq.noteAndEncounterVisitRelatedTos = flowSaveNoteAndEncounterRequest
                ?.noteAndEncounterVisitRelatedTos;
            saveNoteAndEncounterRq.noteAndEncounterServiceCategory = VCC_DAS.SERVICES.ENCOUNTER.getEncounterServiceCategory();
            saveNoteAndEncounterRq.noteAndEncounterProcedures = VCC_DAS.SERVICES.ENCOUNTER.createProcedureString(
                flowSaveNoteAndEncounterRequest?.procedureCode,
                VCC_DAS.SERVICES.UTILITIES.getProviderDuz(
                    UserInfo.getUserId(),
                    flowSaveNoteAndEncounterRequest?.patientLocalSiteId
                )
            );
            saveNoteAndEncounterRq.noteAndEncounterDiagnoses = VCC_DAS.SERVICES.ENCOUNTER.createDiagnosisString(
                flowSaveNoteAndEncounterRequest?.primaryDiagnosis,
                flowSaveNoteAndEncounterRequest?.secondaryDiagnosis
            );

            VCC_DAS das = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId(flowSaveNoteAndEncounterRequest?.patientLocalSiteId),
                    Label.VCC_VAHC_AppName,
                    flowSaveNoteAndEncounterRequest?.recordId
                )
            );

            return new List<Result>{ new Result(das.saveNoteAndEncounter(saveNoteAndEncounterRq)) };
        } catch (VCC_DASException dasException) {
            throw dasException;
        } catch (Exception e) {
            throw new FlowSaveNoteAndEncounterException(e);
        }
    }

    /**
     * @description Shape of the request for the invocable method in this class
     */
    public class Request {
        @InvocableVariable(label='Progress Note or Addendum record Id' required=true)
        public Id recordId;

        @InvocableVariable(label='Token' required=true)
        public String providerUserId;

        @InvocableVariable(label='Patient Name' required=true)
        public String patientName;

        @InvocableVariable(label='Patient Local PID' required=true)
        public String patientLocalPid;

        @InvocableVariable(label='Patient Site Code' required=true)
        public String patientLocalSiteId;

        @InvocableVariable(label='Location IEN' required=true)
        public String noteAndEncounterLocationIen;

        @InvocableVariable(label='Visit Related To\'s')
        public String noteAndEncounterVisitRelatedTos;

        @InvocableVariable(label='Note Title IEN' required=true)
        public String noteAndEncounterNoteTitleIen;

        @InvocableVariable(label='Primary Diagnosis' required=true)
        public CodeSet primaryDiagnosis;

        @InvocableVariable(label='Secondary Diagnosis' required=true)
        public CodeSet secondaryDiagnosis;

        @InvocableVariable(label='Procedure Code' required=true)
        public CodeSet procedureCode;
    }

    /**
     * @description Shape of the result of the invocable method in this class
     */
    public class Result {
        @InvocableVariable(label='Encounter String or Error' required=true)
        public String text;

        /**
         * @description Builds this class given the result of DAS API writeNoteAndSign
         * @param saveNoteAndEncounterRs the result of DAS API writeNoteAndSign
         */
        public Result(VCC_DASSaveNoteAndEncounterRS saveNoteAndEncounterRs) {
            this.text = VCC_DAS.SERVICES.ENCOUNTER.getAndReturnEncounterStringOrReturnErrorMessage(
                saveNoteAndEncounterRs?.textTO?.text
            );
        }
    }

    /**
     * @description A DAS exception thrown when this invocable encounters an exception that isn't a DAS exception
     */
    public class FlowSaveNoteAndEncounterException extends VCC_DASException {
    }
}
