/**
 * @author Booz Allen Hamilton
 * @description Holds the invocable method for writing a progress note to VistA.
 */
public with sharing class VCC_DASFlowWriteNote {
    @InvocableMethod(label='Write Note' description='DAS Integration' callout=true category='DAS')
    /**
     * @description Flow-exposed method to write a note to VistA
     * @param flowWriteNoteRequestList
     * @return `List<WriteNoteResult>`
     */
    public static List<Result> writeNote(List<Request> flowWriteNoteRequestList) {
        try {
            Request flowWriteNoteRequest = flowWriteNoteRequestList[0];
            VCC_DASWriteNoteRQ writeNoteRq = new VCC_DASWriteNoteRQ();

            writeNoteRq.text = VCC_DAS.SERVICES.PARSER.parse((SObject) flowWriteNoteRequest?.progressNote);
            writeNoteRq.encounterString = flowWriteNoteRequest?.encounterString;
            writeNoteRq.providerUserId = flowWriteNoteRequest?.providerUserId;
            writeNoteRq.patientLocalPid = (String.isBlank(flowWriteNoteRequest?.patientLocalPid))
                ? null
                : flowWriteNoteRequest?.patientLocalPid.replace(',', '');
            writeNoteRq.titleIEN = flowWriteNoteRequest?.titleIEN;
            writeNoteRq.patientLocalSiteId = flowWriteNoteRequest?.patientLocalSiteId;
            writeNoteRq.authorDUZ = VCC_DAS.SERVICES.UTILITIES.getProviderDuz(
                UserInfo.getUserId(),
                flowWriteNoteRequest?.patientLocalSiteId
            );
            writeNoteRq.patientName = flowWriteNoteRequest?.patientName;

            VCC_DAS das = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId(flowWriteNoteRequest?.patientLocalSiteId),
                    Label.VCC_VAHC_AppName,
                    flowWriteNoteRequest?.recordId
                )
            );

            VCC_DASWriteNoteRS writeNoteRs = das.writeNote(writeNoteRq);

            if (VCC_NoteParserService.didReplaceCharacters == true) {
                Database.update(
                    new VCC_Progress_Note__c(
                        Id = flowWriteNoteRequest?.progressNote?.Id,
                        VCC_CRM_System_Modified_Output_To_VistA__c = true
                    ),
                    true,
                    System.AccessLevel.USER_MODE
                ); //NOPMD
            }

            return new List<Result>{ new Result(writeNoteRs) };
        } catch (VCC_DASException dasException) {
            throw dasException;
        } catch (Exception e) {
            throw new FlowWriteNoteException(e);
        }
    }

    /**
     * @description Flow-exposed class for writeNote
     */
    public class Request {
        @InvocableVariable(label='Progress Note or Addendum record Id' required=true)
        public Id recordId;

        @InvocableVariable(label='Progress Note' required=true)
        public VCC_Progress_Note__c progressNote;

        @InvocableVariable(label='Encounter String' required=true)
        public String encounterString;

        @InvocableVariable(label='Patient Name' required=true)
        public String patientName;

        @InvocableVariable(label='Token' required=true)
        public String providerUserId;

        @InvocableVariable(label='Patient Local PID' required=true)
        public String patientLocalPid;

        @InvocableVariable(label='Patient Site Code' required=true)
        public String patientLocalSiteId;

        @InvocableVariable(label='Note Title IEN' required=true)
        public String titleIEN;
    }

    /**
     * @description flow exposed class for writeNote
     */
    public class Result {
        @InvocableVariable(label='VistA Note Id')
        public String id;

        @InvocableVariable(label='Total Pages')
        public Long totalPages;

        @InvocableVariable(label='Last Page Received by VistA')
        public Long lastPageRecd;

        @InvocableVariable(label='Explanation')
        public String explanation;

        @InvocableVariable(label='VistA Fault Message')
        public String faultMessage;

        public Result(VCC_DASWriteNoteRS writeNoteRs) {
            this.id = writeNoteRs?.noteResultTO?.id;
            this.totalPages = writeNoteRs?.noteResultTO?.totalPages;
            this.lastPageRecd = writeNoteRs?.noteResultTO?.lastPageRecd;
            this.explanation = writeNoteRs?.noteResultTO?.explanation;
            this.faultMessage = writeNoteRs?.noteResultTO?.fault?.message;
        }
    }

    /**
     * @description Exception class
     */
    public class FlowWriteNoteException extends VCC_DASException {
    }
}
