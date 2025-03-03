public with sharing class VCC_VdifQueueable_Esig extends VCC_QueueableWithCallback implements Database.AllowsCallouts {
    public override void execute(Callable callback, QueueableContext context) {
        try {
            callback.call('setStage', new Map<String, Object>{ 'stage' => VCC_VdifQueueableCallback.Stage.VALIDATE_ESIG });
            callback.call('handleQueueableStart', null);

            VCC_VdifParameters vdifParameters = (VCC_VdifParameters) callback.call('getVdifParameters', null);

            VCC_VdifIsValidEsigRQ isValidEsigRQ = new VCC_VdifIsValidEsigRQ(vdifParameters);

            callback.call('handleCalloutResponse', new Map<String, Object>{ 'response' => VCC_APIService.VDIF.isValidEsig(isValidEsigRQ) });

            callback.call('handleQueueableEnd', null);
        } catch (Exception e) {
            callback.call('handleException', new Map<String, Object>{ 'exception' => e });
        }
    }

    public VCC_VdifQueueable_Esig(VCC_VdifQueueableCallback callback) {
        super(callback);
    }
}
