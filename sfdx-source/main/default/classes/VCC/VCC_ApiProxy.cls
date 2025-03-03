public abstract class VCC_ApiProxy {
    protected VCC_BaseClient client {
        get {
            init();
            return this.clientInstance;
        }
    }

    private VCC_BaseClient clientInstance;

    protected abstract System.Type getClientType();

    private void init() {
        if (this.clientInstance != null) {
            return;
        }
        this.clientInstance = (VCC_BaseClient) getClientType().newInstance();
    }

    public Boolean isTrainingModeEnabled() {
        return client.CLIENT_OPTIONS.contains(VCC_BaseClient.ClientOption.TRAINING_MODE);
    }

    public Boolean isDebugModeEnabled() {
        return client.CLIENT_OPTIONS.contains(VCC_BaseClient.ClientOption.DEBUG_MODE);
    }

    public void debugMode(Boolean isDebug) {
        if (isDebug == true) {
            client.CLIENT_OPTIONS.add(VCC_BaseClient.ClientOption.DEBUG_MODE);
        } else if (isDebug == false) {
            client.CLIENT_OPTIONS.remove(VCC_BaseClient.ClientOption.DEBUG_MODE);
        }
    }

    public void trainingMode(Boolean isTraining) {
        if (isTraining == true) {
            client.CLIENT_OPTIONS.add(VCC_BaseClient.ClientOption.TRAINING_MODE);
        } else if (isTraining == false) {
            client.CLIENT_OPTIONS.remove(VCC_BaseClient.ClientOption.TRAINING_MODE);
        }
    }

    @TestVisible
    private void setClientStub(VCC_Stub stub) {
        this.clientInstance = (VCC_BaseClient) stub.instance;
    }
}
