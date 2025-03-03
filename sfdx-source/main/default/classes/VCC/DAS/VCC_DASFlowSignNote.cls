/**
 * @description Flow-exposed @InvocableMethod to call DAS signNote
 * @author      Booz Allen
 */
public with sharing class VCC_DASFlowSignNote {
    /**
     * @description Used to stub VCC_DASFlowSignNote in flow tests
     */
    @TestVisible
    private static VCC_DASFlowSignNote flowSignNoteInstance {
        get {
            return flowSignNoteInstance ?? new VCC_DASFlowSignNote();
        }
        private set;
    }

    /**
     * @description Flow exposed method to call DAS signNote to send patient's progress notes to DAS & VistA
     * @param       signNoteRequestList flow request list
     * @return      `List<Result>` flow result list
     */
    @InvocableMethod(label='Sign Note' description='DAS Integration' callout=true category='DAS')
    public static List<Result> signNote(List<Request> signNoteRequestList) {
        return flowSignNoteInstance.handleSignNote(signNoteRequestList);
    }

    /**
     * @description     Instance method for stubbing purposes
     * @param           signNoteRequestList flow request list
     * @return          `List<Result>` flow result list
     */
    public List<Result> handleSignNote(List<Request> signNoteRequestList) {
        try {
            Request flowSignNoteRequest = signNoteRequestList[0];
            VCC_DASSignNoteRQ signNoteRq = new VCC_DASSignNoteRQ();

            signNoteRq.esig = flowSignNoteRequest?.esig;
            signNoteRq.providerLoginSiteCode = flowSignNoteRequest?.providerLoginSiteCode;
            signNoteRq.providerName = flowSignNoteRequest?.providerName;
            signNoteRq.providerUserId = flowSignNoteRequest?.providerUserId;
            signNoteRq.noteIEN = flowSignNoteRequest?.noteIEN;

            VCC_DAS das = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId(flowSignNoteRequest?.providerLoginSiteCode),
                    Label.VCC_VAHC_AppName,
                    flowSignNoteRequest?.recordId
                )
            );

            return new List<Result>{ new Result(das.signNote(signNoteRq)) };
        } catch (VCC_DASException dasException) {
            throw dasException;
        } catch (Exception e) {
            throw new FlowSignNoteException(e);
        }
    }

    /**
     * @description The shape of the request needed for the invocable method VCC_DASFlowSignNote.signNote
     */
    public class Request {
        @InvocableVariable(label='Progress Note or Addendum record Id' required=true)
        public Id recordId;

        @InvocableVariable(label='e-Signature' required=true)
        public String esig;

        @InvocableVariable(label='Provider Site Code' required=true)
        public String providerLoginSiteCode;

        @InvocableVariable(label='Provider Name' required=true)
        public String providerName;

        @InvocableVariable(label='Token' required=true)
        public String providerUserId;

        @InvocableVariable(label='VistA Note Id' required=true)
        public String noteIEN;
    }

    /**
     * @description The shape of the result from invocable method VCC_DASFlowSignNote.signNote
     */
    public class Result {
        @InvocableVariable
        public String text;

        @InvocableVariable
        public String faultMessage;

        /**
         * @description Constructor. Instantiates this class from the DAS API signNote response
         * @param signNoteRs The response from DAS API signNote
         */
        public Result(VCC_DASSignNoteRS signNoteRs) {
            this.text = signNoteRs?.textTO?.text;
            this.faultMessage = signNoteRs?.textTO?.fault?.message;
        }
    }

    /**
     * @description Flow exception class
     */
    public class FlowSignNoteException extends VCC_DASException {
    }
}
