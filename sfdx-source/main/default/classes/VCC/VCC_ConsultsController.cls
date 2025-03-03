/**
 * @author Kumar Balan
 * @group API - Bridg - Consults
 */
@SuppressWarnings('PMD')
public with sharing class VCC_ConsultsController {
    @AuraEnabled
    public static VCC_ConsultResponseWrp getConsults(VCC_ConsultLightningRequestWrp consultReqWrp) {
        /*if (!Test.isRunningTest() && VCC_TrainingModeService.isTrainingModeEnabled()) {
            VCC_ConsultResponseWrp consultResponseWrp = new VCC_ConsultResponseWrp();
            consultResponseWrp.consultModal = (VCC_ConsultModal) JSON.deserialize(VCC_TrainingModeService.getConsultsByAccountId(consultReqWrp.recordId), VCC_ConsultModal.class);
            return consultResponseWrp;
        }*/

        VCC_Workstream_Settings__mdt workstreamSettings = VCC_WorkstreamSettingsController.getWorkstreamSettings();
        VCC_BridgConsultsRQ consultsRQ = new VCC_BridgConsultsRQ(
            VCC_QuerySelector.getContactNationalID(consultReqWrp.recordId),
            'USVHA',
            Integer.valueOf(workstreamSettings.VCC_Consults_Duration__c)
        );

        return VCC_Adapter_BridgToLWC.vccConsult(
            (new VCC_BridgClient(new Set<VCC_BaseClient.ClientOption>{})).consults(consultsRQ)
        );
    }
}
