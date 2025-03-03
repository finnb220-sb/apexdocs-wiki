/**
 * @description Holds the flow invocable methods and variables to call DAS writeNoteAndSign.
 * @author      Booz Allen
 * @since       May 10, 2024
 */

public with sharing class VCC_DASFlowWriteNoteAndSign {
    /**
     * @description Used to stub VCC_DASFlowWriteNoteAndSign in flow tests.
     */
    @TestVisible
    private static VCC_DASFlowWriteNoteAndSign flowWriteNoteAndSignInstance {
        get {
            return flowWriteNoteAndSignInstance = flowWriteNoteAndSignInstance ?? new VCC_DASFlowWriteNoteAndSign();
        }
        private set;
    }

    /**
     * @description Flow invocable method to call DAS writeNoteAndSign. This method is used in the Sign Note flow to send a patient's progress note to DAS & VistA.
     * @param writeNoteAndSignRequestList List<DASWriteNoteAndSignFlowRequest>
     * @return                            List<VCC_DASFlowConsolidatedEndpointResult>
     */
    @InvocableMethod(label='Write Note And Sign' description='DAS Integration' callout=true category='DAS')
    public static List<VCC_DASFlowConsolidatedEndpointResult> writeNoteAndSign(
        List<DASWriteNoteAndSignFlowRequest> writeNoteAndSignRequestList
    ) {
        return flowWriteNoteAndSignInstance.handleWriteNoteAndSign(writeNoteAndSignRequestList);
    }

    /**
     * @description Used in flow invocable method to handle flow requests and perform callout.
     * @param writeNoteAndSignRequestList `List<DASWriteNoteAndSignFlowRequest>`
     * @return                            `List<VCC_DASFlowConsolidatedEndpointResult>`
     */
    public List<VCC_DASFlowConsolidatedEndpointResult> handleWriteNoteAndSign(
        List<DASWriteNoteAndSignFlowRequest> writeNoteAndSignRequestList
    ) {
        List<VCC_DASFlowConsolidatedEndpointResult> noteDASCreationAndSignatureResults = new List<VCC_DASFlowConsolidatedEndpointResult>();
        for (
            DASWriteNoteAndSignFlowRequest flowWriteNoteAndSignRequest : writeNoteAndSignRequestList ??
                new List<VCC_DASFlowWriteNoteAndSign.DASWriteNoteAndSignFlowRequest>()
        ) {
            flowWriteNoteAndSignRequest = flowWriteNoteAndSignRequest ?? new DASWriteNoteAndSignFlowRequest();
            VCC_DASWriteNoteAndSignRQ writeNoteAndSignRequest = new VCC_DASWriteNoteAndSignRQ(
                flowWriteNoteAndSignRequest
            );
            try {
                VCC_DAS das = new VCC_DAS(
                    new VCC_DAS.State(
                        new VCC_SiteId(flowWriteNoteAndSignRequest?.providerLoginSiteCode),
                        Label.VCC_VAHC_AppName,
                        flowWriteNoteAndSignRequest?.recordId
                    )
                );
                noteDASCreationAndSignatureResults.add(
                    new VCC_DASFlowConsolidatedEndpointResult(das.writeNoteAndSign(writeNoteAndSignRequest))
                );
            } catch (VCC_DASConsolidatedEndpointException consolidatedEndpointException) {
                noteDASCreationAndSignatureResults.add(
                    new VCC_DASFlowConsolidatedEndpointResult(consolidatedEndpointException)
                );
            } catch (Exception generalException) {
                noteDASCreationAndSignatureResults.add(new VCC_DASFlowConsolidatedEndpointResult(generalException));
            }
        }
        return noteDASCreationAndSignatureResults;
    }

    /**
     * @description Flow exposed DASWriteNoteAndSignFlowRequest class for writeNoteAndSign
     */
    public class DASWriteNoteAndSignFlowRequest {
        @InvocableVariable(label='Progress Note Record Id' required=true)
        public Id recordId;

        @InvocableVariable(label='Progress Note' required=true)
        public VCC_Progress_Note__c progressNote;

        @InvocableVariable(label='VistA Note Id' required=true)
        public String titleIEN = '';

        @InvocableVariable(label='Encounter' required=true)
        public String encounterString = '';

        @InvocableVariable(label='User DUZ' required=true)
        public String authorDUZ = '';

        @InvocableVariable(label='Cosigner DUZ')
        public String cosignerDUZ = '';

        @InvocableVariable(label='e-Signature' required=true)
        public String esig = '';

        @InvocableVariable(label='Provider Site Code' required=true)
        public String providerLoginSiteCode = '';

        @InvocableVariable(label='Provider Name')
        public String providerName = '';

        @InvocableVariable(label='Token' required=true)
        public String providerUserId = '';

        @InvocableVariable(label='Patient Local PID' required=true)
        public String patientLocalPid = '';

        @InvocableVariable(label='Patient Site Code' required=true)
        public String patientLocalSiteId = '';

        @InvocableVariable(label='Patient Name')
        public String patientName = '';
    }
}
