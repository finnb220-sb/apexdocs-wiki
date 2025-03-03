public with sharing class VCC_VdifQueueable_Encounter extends VCC_QueueableWithCallback implements Database.AllowsCallouts {
    public override void execute(Callable callback, QueueableContext context) {
        try {
            callback.call('setStage', new Map<String, Object>{ 'stage' => VCC_VdifQueueableCallback.Stage.CREATE_ENCOUNTER });
            callback.call('handleQueueableStart', null);

            VCC_VdifParameters vdifParameters = (VCC_VdifParameters) callback.call('getVdifParameters', null);

            VCC_VdifSaveNoteAndEncounterRQ saveNoteAndEncounterRQ = new VCC_VdifSaveNoteAndEncounterRQ(vdifParameters);

            callback.call('handleCalloutResponse', new Map<String, Object>{ 'response' => VCC_APIService.VDIF.saveNoteAndEncounter(saveNoteAndEncounterRQ) });

            callback.call('handleQueueableEnd', null);
        } catch (Exception e) {
            callback.call('handleException', new Map<String, Object>{ 'exception' => e });
        }
    }

    public VCC_VdifQueueable_Encounter(VCC_VdifQueueableCallback callback) {
        super(callback);
    }
}
