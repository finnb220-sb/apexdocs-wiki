/**
 * @description Methods required for VistA encounters VCC_DASSaveNoteAndEncounter & VCC_DASWriteNote
 */
public with sharing class VCC_DASServiceEncounter {
    /**
     * @description Create procedure string for DAS saveNoteAndEncounter
     * @return `String`
     * @param procedureCode
     * @param providerDuz
     **/
    public String createProcedureString(CodeSet procedureCode, String providerDuz) {
        if (procedureCode == null || procedureCode.Id == null || String.isBlank((String) procedureCode.Id)) {
            return '';
        }
        procedureCode = (new VCC_CodeSetSelector()).selectByIds(new Set<Id>{ procedureCode?.Id })[0];
        return VCC_EncounterService.createProcedureString(procedureCode, providerDuz);
    }

    /**
     * @description
     */
    public String getEncounterServiceCategory() {
        return (Test.isRunningTest()) ? 'test' : VCC_EncounterService.getEncounterServiceCategory();
    }

    /**
     * @description Create diagnosis string for DAS saveNoteAndEncounter
     * @return `String`
     * @param primaryCode
     * @param secondaryCode
     **/
    public String createDiagnosisString(CodeSet primaryCode, CodeSet secondaryCode) {
        VCC_CodeSetSelector codeSetSelector = new VCC_CodeSetSelector();
        if (primaryCode != null && primaryCode.Id != null && String.isNotBlank((String) primaryCode.Id)) {
            primaryCode = codeSetSelector.selectByIds(new Set<Id>{ primaryCode?.Id })[0];
        }
        if (secondaryCode != null && secondaryCode.Id != null && String.isNotBlank((String) secondaryCode.Id)) {
            secondaryCode = codeSetSelector.selectByIds(new Set<Id>{ secondaryCode?.Id })[0];
        }
        return VCC_EncounterService.createDiagnosisString(
            primaryCode,
            secondaryCode,
            VCC_EncounterService.DiagnosisTemplateType.DAS
        );
    }

    /**
     * @description find the encounter string in the response or an error message
     * @param text text that might contain the encounter string
     * @return `String` encounter string
     */
    public String getAndReturnEncounterStringOrReturnErrorMessage(String text) {
        return VCC_EncounterService.getAndReturnEncounterStringOrReturnErrorMessage(text);
    }

    /**
     * @description Generates an encounter string for writing a note to VistA that is not encounterable.
     * @param generateEncounterStringRequest the request from `VCC_DASFlowGenerateEncounterString`
     * @return `String` the encounter string
     */
    public String generateEncounterString(VCC_DASFlowGenerateEncounterString.Request generateEncounterStringRequest) {
        VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams = generateEncounterStringRequest.noteAndEncounterParameters;

        Integer locationIen;
        try {
            locationIen = Integer.valueOf(noteAndEncounterParams?.noteAndEncounterLocationIen);
        } catch (Exception e) {
            locationIen = null;
        }

        if (locationIen == null) {
            throw new GenerateEncounterStringException('Invalid location IEN: ' + String.valueOf(locationIen));
        }

        String encounterString;

        try {
            encounterString = VCC_ProgressNoteController.generateEncounterString(
                locationIen,
                (noteAndEncounterParams?.noShowNoWelfare == null) ? false : noteAndEncounterParams?.noShowNoWelfare,
                (noteAndEncounterParams?.noShowWithWelfare == null) ? false : noteAndEncounterParams?.noShowWithWelfare
            );
        } catch (Exception e) {
            throw new GenerateEncounterStringException(e.getMessage());
        }
        return encounterString;
    }

    /**
     * @description Exception for generateEncounterString
     */
    public class GenerateEncounterStringException extends VCC_DASException {
    }

    /**
     * @description Exception for getRecordTypeApiName
     */
    public class GetRecordTypeApiNameException extends VCC_DASException {
    }
}
