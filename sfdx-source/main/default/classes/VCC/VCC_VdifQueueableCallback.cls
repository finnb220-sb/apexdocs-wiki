public with sharing class VCC_VdifQueueableCallback implements Callable {
    public enum Stage {
        ADD_SIGNERS,
        CREATE_ADDENDUM,
        CREATE_ENCOUNTER,
        SIGN_NOTE,
        VALIDATE_ESIG,
        WRITE_NOTE
    }

    public VCC_VdifQueueableCallback(VCC_VdifParameters vdifParameters, Strategy strategy) {
        this.vdifParameters = vdifParameters;
        this.strategy = strategy;
    }

    @TestVisible
    private VCC_VdifQueueableCallback() {
        System.debug(LoggingLevel.INFO, 'Empty constructor.');
    }

    public VCC_VdifParameters vdifParameters { private get; private set; }

    public Stage previousStage { private get; private set; }

    public Stage stage { private get; private set; }

    public Strategy strategy { private get; private set; }

    @TestVisible
    private void setStage(Stage stage) {
        this.stage = stage;
    }

    @TestVisible
    private void setPreviousStage(Stage stage) {
        this.previousStage = stage;
    }

    public Stage getStage() {
        return this.stage;
    }

    public Stage getPreviousStage() {
        return this.previousStage;
    }

    public VCC_VdifParameters getVdifParameters() {
        return this.vdifParameters;
    }

    public Strategy getStrategy() {
        return this.strategy;
    }

    public Id enqueueStage(Stage vdifStage) {
        System.Queueable queueable;
        switch on vdifStage {
            when ADD_SIGNERS {
                queueable = new VCC_VdifQueueable_Signers(this);
            }
            when CREATE_ADDENDUM {
                queueable = new VCC_VdifQueueable_Addendum(this);
            }
            when CREATE_ENCOUNTER {
                queueable = new VCC_VdifQueueable_Encounter(this);
            }
            when SIGN_NOTE {
                queueable = new VCC_VdifQueueable_Sign(this);
            }
            when VALIDATE_ESIG {
                queueable = new VCC_VdifQueueable_Esig(this);
            }
            when WRITE_NOTE {
                queueable = new VCC_VdifQueueable_Write(this);
            }
        }
        if (Test.isRunningTest()) {
            return null;
        }
        return System.enqueueJob(queueable);
    }

    public Object call(String action, Map<String, Object> args) {
        if (String.isBlank(action)) {
            return null;
        }
        if (args == null) {
            args = new Map<String, Object>();
        }

        return this.handleCall(action, args);
    }

    private Object handleCall(String action, Map<String, Object> args) {
        switch on action {
            when 'setStage' {
                this.previousStage = this.stage;
                this.stage = (Stage) args.get('stage');
            }
            when 'getVdifParameters' {
                return getVdifParameters();
            }
            when 'handleQueueableStart' {
                this.strategy.onQueueableStart(this);
            }
            when 'handleException' {
                this.strategy.onException((Exception) args.get('exception'), this);
            }
            when 'handleCalloutResponse' {
                this.strategy.onCalloutResponse(args.get('response'), this);
            }
            when 'handleQueueableEnd' {
                this.strategy.onQueueableEnd(this);
            }
        }
        return null;
    }

    public interface Strategy {
        void onQueueableStart(VCC_VdifQueueableCallback vdifQueueableCallback);
        void onException(Exception e, VCC_VdifQueueableCallback vdifQueueableCallback);
        void onCalloutResponse(Object response, VCC_VdifQueueableCallback vdifQueueableCallback);
        void onQueueableEnd(VCC_VdifQueueableCallback vdifQueueableCallback);
    }
}
