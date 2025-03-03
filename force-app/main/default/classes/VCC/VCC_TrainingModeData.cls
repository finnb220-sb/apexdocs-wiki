public with sharing class VCC_TrainingModeData {
    public String type { get; set; }
    public String data { get; set; }

    public VCC_TrainingModeData() {
    }

    public VCC_TrainingModeData(String type, String data) {
        this.type = type;
        this.data = data;
    }
}
