public with sharing class VCC_GetSudPanelsInvocable {
    @InvocableMethod(Label='Get SUD Panels Invocable' Description='Updates this Progress Note with latest SUD lab results ' callout=true category='Progress Note')
    public static void getSUDLabResults(List<String> recordId) {
        VCC_PatientLabService.updateProgressNoteWithSUDInformation((Id) recordId[0]);
    }
}
