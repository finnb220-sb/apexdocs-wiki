/**
 * @description Structure of data given to the flow that invokes createAddendumAndSign or writeNoteAndSign. Also an apex-defined type for use in flows.
 * @author Booz Allen Hamilton
 * @see VCC_DASFlowCreateAddendumAndSign
 * @see VCC_DASFlowWriteNoteAndSign
 */

public with sharing class VCC_DASFlowConsolidatedEndpointResult {
    @InvocableVariable(label='Is Error' description='Has a consolidated endpoint error occurred?')
    @AuraEnabled
    public Boolean isError;

    @InvocableVariable(label='Error Description' description='The DAS consolidated endpoint error description.')
    @AuraEnabled
    public String errorDescription;

    @InvocableVariable(label='Error Message' description='The DAS consolidated endpoint error message.')
    @AuraEnabled
    public String errorMessage;

    @InvocableVariable(label='Error Code' description='The four-digit DAS consolidated endpoint error code.')
    @AuraEnabled
    public String errorCode;

    @InvocableVariable(
        label='Note or Addendum IEN'
        description='If the consolidated endpoint fails after writing the note, this property contains a value.'
    )
    @AuraEnabled
    public String noteOrAddendumIen;

    @InvocableVariable(
        label='Result TextTO text'
        description='If the consolidated endpoint is a success, this property has a value of "OK".'
    )
    @AuraEnabled
    public String text;

    @InvocableVariable(label='System Modified Text Sent to VistA')
    @AuraEnabled
    public Boolean systemModifiedOutputToVista;

    /**
     * @description no-arg constructor for use in flows
     */
    public VCC_DASFlowConsolidatedEndpointResult() {
        return;
    }

    /**
     * @description constructor for consolidated endpoint exception
     * @param consolidatedEndpointException `VCC_DASConsolidatedEndpointException`
     */
    public VCC_DASFlowConsolidatedEndpointResult(VCC_DASConsolidatedEndpointException consolidatedEndpointException) {
        this.isError = true;
        this.errorDescription = consolidatedEndpointException?.getMessage();
        this.errorCode = consolidatedEndpointException?.errorCode;
        this.errorMessage = consolidatedEndpointException?.errorMessage;
        this.noteOrAddendumIen = consolidatedEndpointException?.noteOrAddendumIen;
        this.systemModifiedOutputToVista = false;
    }

    /**
     * @description constructor for general apex exception
     * @param otherThrownException `Exception`
     */
    public VCC_DASFlowConsolidatedEndpointResult(Exception otherThrownException) {
        this.isError = true;
        this.errorDescription = otherThrownException?.getMessage();
        this.systemModifiedOutputToVista = false;
    }

    /**
     * @description constructor for the Write Note and Sign success
     * @param dasWriteNoteSignSuccessRs `VCC_DASWriteNoteSignSuccessRS`
     */
    public VCC_DASFlowConsolidatedEndpointResult(VCC_DASWriteNoteSignSuccessRS dasWriteNoteSignSuccessRs) {
        this.isError = false;
        this.noteOrAddendumIen = dasWriteNoteSignSuccessRs?.textTO?.noteIen;
        this.text = dasWriteNoteSignSuccessRs?.textTO?.text;
        this.systemModifiedOutputToVista = VCC_NoteParserService.didReplaceCharacters;
    }

    /**
     * @description constructor for the Create Addendum and Sign success
     * @param dasCreateAddendumAndSignSuccessRs `VCC_DASCreateAddendumAndSignSuccessRS`
     */
    public VCC_DASFlowConsolidatedEndpointResult(
        VCC_DASCreateAddendumAndSignSuccessRS dasCreateAddendumAndSignSuccessRs
    ) {
        this.isError = false;
        this.noteOrAddendumIen = dasCreateAddendumAndSignSuccessRs?.textTO?.addendumIen;
        this.text = dasCreateAddendumAndSignSuccessRs?.textTO?.text;
        this.systemModifiedOutputToVista = VCC_NoteParserService.didReplaceCharacters;
    }
}
